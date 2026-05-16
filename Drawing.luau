local RunService = game:GetService("RunService")
local ActiveAutoRotations, HeartbeatConnection = {}
local HiddenUI = gethui and gethui() or game:GetService("CoreGui").RobloxGui
local Drawing = {}

local DrawingDirectory = HiddenUI:FindFirstChild("Drawing Directory") or Instance.new("ScreenGui", HiddenUI)
DrawingDirectory.Name = "Drawing Directory"
DrawingDirectory.ResetOnSpawn = false
DrawingDirectory.IgnoreGuiInset = true
DrawingDirectory.DisplayOrder = 2147483648

local BaseObject = setmetatable({
    __SHAPE = "Unknown",
    Visible = true,
    Transparency = 1,
    Color = Color3.new(1, 1, 1),
    ZIndex = 0,
    AnchorPoint = Vector2.one / 2,
    Remove = function(Self)
        pcall(Self.__INSTANCE.Destroy, Self.__INSTANCE)
        setmetatable(Self, nil)
    end,
    Destroy = function(Self)
        pcall(Self.__INSTANCE.Destroy, Self.__INSTANCE)
        setmetatable(Self, nil)
    end
}, {
    __add = function(Self, Object)
        local Clone = table.clone(Self)
        for Index, Value in Object do
            Clone[Index] = Value
        end
        return Clone
    end
})

local Letters = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L" }
local SideCounts = { Triangle = 3, Quad = 4, Pentagon = 5,Hexagon = 6, Heptagon = 7, Octagon = 8, Nonagon = 9, Decagon = 10, Hendecagon = 11, Dodecagon = 12 }



--// HELPER FUNCTIONS



local function AssertType(Value, ExpectedType, PropertyName)
    assert(typeof(Value) == ExpectedType, "Property '" .. PropertyName .. "' Expects " .. ExpectedType .. " But Got " .. typeof(Value))
end

local function GetCamera()
    local Camera = workspace.CurrentCamera
    if not (typeof(Camera) == "Instance" and Camera.ClassName == "Camera") then return end
    return Camera, Camera.ViewportSize
end

local function ConvertUDim2ToVector2(Value)
    AssertType(Value, "UDim2", "Value")
    local Camera, Resolution = GetCamera()
    if not Camera then return Vector2.new(Value.X.Offset, Value.Y.Offset) end
    return Vector2.new(
        Value.X.Scale * Resolution.X + Value.X.Offset,
        Value.Y.Scale * Resolution.Y + Value.Y.Offset
    )
end

local function GetClosestPoint(Part, Camera, HalfResolution)
    local ToCenter = Part.Position - Camera.CFrame.p
    local ViewRayDirection = (Camera:ViewportPointToRay(HalfResolution.X, HalfResolution.Y)).Direction
    local ProjectionLength = ToCenter:Dot(ViewRayDirection)
    if ProjectionLength < 0 then return end
    local HalfSize = Part.Size * 0.5
    local ProjectedPoint = Camera.CFrame.p + ViewRayDirection * ProjectionLength
    local Projected = Part.CFrame:PointToObjectSpace(ProjectedPoint)
    local Clamped = vector.create(
        math.clamp(Projected.X, -HalfSize.X, HalfSize.X),
        math.clamp(Projected.Y, -HalfSize.Y, HalfSize.Y),
        math.clamp(Projected.Z, -HalfSize.Z, HalfSize.Z)
    )
    return Part.CFrame:PointToWorldSpace(Clamped)
end

local function ConvertTargetToScreenPosition(Target, PropertyName, OnScreenCheck)
    local Type = typeof(Target)
    
    if Type == "Instance" and (Target:IsA("BasePart") or Target.ClassName == "Model") then
        local Camera, Resolution = GetCamera()
        if not Camera then return end
        local IsModel = Target.ClassName == "Model"
        local HalfResolution = Resolution / 2
        local TargetPart
        
        if IsModel then
            local BestDistance = math.huge
            
            for _, Descendant in Target:GetDescendants() do
                if not Descendant:IsA("BasePart") then continue end
                
                local ClosestPoint = GetClosestPoint(Descendant, Camera, HalfResolution)
                if not ClosestPoint then continue end
                
                local Position, OnScreen = Camera:WorldToViewportPoint(ClosestPoint)
                if OnScreenCheck ~= false and not OnScreen then continue end
                
                local Distance = (Vector2.new(Position.X, Position.Y) - HalfResolution).Magnitude
                if Distance >= BestDistance then continue end
                
                BestDistance = Distance
                TargetPart = Descendant
            end
            
            if not TargetPart then return end
        else
            TargetPart = Target
        end
        
        local ClosestPoint = GetClosestPoint(TargetPart, Camera, HalfResolution)
        if not ClosestPoint or not select(2, Camera:WorldToViewportPoint(ClosestPoint)) then return end
        
        local FinalPosition = IsModel and Camera:WorldToViewportPoint(Target:GetPivot().p) or Camera:WorldToViewportPoint(TargetPart.Position)
        return Vector2.new(FinalPosition.X, FinalPosition.Y)
    elseif Type == "Vector3" then
        local Camera = GetCamera()
        if not Camera then return end
        
        local Position, OnScreen = Camera:WorldToViewportPoint(Target)
        if not OnScreen then return end
        
        return Vector2.new(Position.X, Position.Y)
    elseif Type == "UDim2" then
        return ConvertUDim2ToVector2(Target)
    elseif Type == "Vector2" then
        return Target
    else
        error(PropertyName .. " Expects Vector2 Or UDim2 Or Vector3 Or BasePart Or Model But Got " .. Type, 2)
    end
end

local function CreateDrawingObject(ObjectType, UpdateFunction)
    return setmetatable({}, {
        __index = ObjectType,
        __newindex = function(_, Key, Value)
            if table.find({ "__SHAPE", "__INSTANCE", "Remove", "Destroy", "Trace" }, Key) then
                error("You Cannot Set " .. Key)
            elseif ObjectType.Stroke and Key == "Stroke" or ObjectType.Gradient and Key == "Gradient" or ObjectType.Outlines and Key == "Outlines" or ObjectType.AutoRotation and Key == "AutoRotation" then
                error("Cannot Set " .. Key .. " Directly, Use " .. ObjectType.__SHAPE .. "Drawing." .. Key .. ".PropertyName")
            end
            
            if ObjectType.__SHAPE == "NGon" then
                if Key == "Points" then
                    assert(typeof(Value) == "number" and Value == math.floor(Value) and Value >= 3, "Points Must Be A Whole Integer >= 3")
                    local OldCount = ObjectType.Points
                    ObjectType.Points = Value
                    for Index = OldCount + 1, Value do
                        if ObjectType["Point" .. Index] ~= nil then continue end
                        ObjectType["Point" .. Index] = Vector2.zero
                    end
                    UpdateFunction()
                    return
                end
                
                local PointIndex = tonumber(Key:match("^Point(%d+)$"))
                
                if PointIndex then
                    assert(PointIndex >= 1 and PointIndex <= ObjectType.Points, "Point Index " .. PointIndex .. " Is Out Of Range (1 To " .. ObjectType.Points .. ")")
                    assert(typeof(Value) == "Vector2", "Property '" .. Key .. "' Expects Vector2 But Got " .. typeof(Value))
                    ObjectType[Key] = Value
                    UpdateFunction()
                    return
                end
            end
            
            assert(ObjectType[Key] ~= nil, "Invalid Property '" .. Key .. "' For " .. ObjectType.__SHAPE)
            
            if table.find({"Position", "From", "To", "Size"}, Key) then
                assert(typeof(Value) == "Vector2" or typeof(Value) == "UDim2", "Property '" .. Key .. "' Expects Vector2 Or UDim2 But Got " .. typeof(Value))
                Value = typeof(Value) == "UDim2" and ConvertUDim2ToVector2(Value) or Value
            else
                AssertType(Value, typeof(ObjectType[Key]), Key)
            end
            
            ObjectType[Key] = Value
            UpdateFunction()
        end
    })
end

local function ConvertTransparency(Transparency)
    return math.clamp(1 - Transparency, 0, 1)
end

local function ApplyAutoRotation(Parent, OnTick)
    local AutoRotation = { Enabled = false, Amount = 90, Speed = 1, Start = 0, End = 360 }
    
    local function Tick(DeltaTime)
        local Range = AutoRotation.End - AutoRotation.Start
        if Range <= 0 then return end
        local Step = AutoRotation.Amount * AutoRotation.Speed * DeltaTime
        if OnTick then
            OnTick(AutoRotation, Step)
        else
            Parent.Rotation = AutoRotation.Start + ((Parent.Rotation - AutoRotation.Start + Step) % Range)
        end
    end
    
    return setmetatable({}, {
        __index = AutoRotation,
        __newindex = function(_, Key, Value)
            assert(AutoRotation[Key] ~= nil, "Invalid Property '" .. Key .. "' For Auto Rotation")
            AssertType(Value, typeof(AutoRotation[Key]), Key)
            AutoRotation[Key] = Value
            
            if Key ~= "Enabled" then return end
            
            if Value then
                if not table.find(ActiveAutoRotations, Tick) then
                    table.insert(ActiveAutoRotations, Tick)
                end
                if HeartbeatConnection then return end
                HeartbeatConnection = RunService.Heartbeat:Connect(function(DeltaTime)
                    for _, Tick in ActiveAutoRotations do
                        task.spawn(Tick, DeltaTime)
                    end
                    
                    if #ActiveAutoRotations ~= 0 then return end
                    HeartbeatConnection:Disconnect()
                    HeartbeatConnection = nil
                end)
            else
                local ID = table.find(ActiveAutoRotations, Tick)
                if not ID then return end
                table.remove(ActiveAutoRotations, ID)
            end
        end,
    })
end

local function ApplyRoundness(Parent)
    local Rounder = Instance.new("UICorner", Parent)
    Rounder.CornerRadius = UDim.new(0, 0)
    return Rounder
end

local function ApplyGradient(Parent)
    local Gradient = Instance.new("UIGradient", Parent)
    
    local Properties = {
        Enabled = false,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.new(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
        }),
        Rotation = 0,
        Transparency = NumberSequence.new(0),
        Offset = Vector2.new(0, 0),
        AutoRotation = ApplyAutoRotation(Gradient)
    }
    
    for Property, Value in Properties do
        if Property == "AutoRotation" or Gradient[Property] == nil then continue end
        Gradient[Property] = Value
    end
    
    return setmetatable({}, {
        __index = Properties,
        __newindex = function(_, Key, Value)
            if Properties[Key] == nil or Key == "AutoRotation" then return end
            Properties[Key] = Value
            Gradient[Key] = Value
        end,
    })
end

local function ApplyStroke(Parent)
    local UIStroke = Instance.new("UIStroke", Parent)
    
    local Stroke = {
        Enabled = true,
        Color = Color3.new(1, 1, 1),
        Transparency = 1,
        Thickness = 1,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Gradient = ApplyGradient(UIStroke),
    }
    
    for Property, Value in Stroke do
        if Property == "Gradient" or UIStroke[Property] == nil then continue end
        UIStroke[Property] = Property == "Transparency" and ConvertTransparency(Value) or Value
    end
    
    return setmetatable({}, {
        __index = Stroke,
        __newindex = function(_, Key, Value)
            if Key == "Gradient" then
                error("Cannot Set Gradient Directly, Use Stroke.Gradient.PropertyName")
            end
            
            assert(UIStroke[Key] ~= nil, "Invalid Property '" .. Key .. "' For Stroke Object")
            AssertType(Value, typeof(Stroke[Key]), Key)
            
            Value = Key == "Transparency" and ConvertTransparency(Value) or Value
            Stroke[Key] = Value
            UIStroke[Key] = Value
        end
    })
end



--// DRAWING FUNCTIONS



local function DrawLine(Parent)
    local Line = BaseObject + {
        __SHAPE = "Line",
        __INSTANCE = Instance.new("Frame", Parent or DrawingDirectory),
        From = Vector2.zero,
        To = Vector2.zero,
        Thickness = 1,
    }
    
    local Frame = Line.__INSTANCE
    Frame.BorderSizePixel = 0
    
    Line.Rounder = ApplyRoundness(Frame)
    Line.Stroke = ApplyStroke(Frame)
    Line.Gradient = ApplyGradient(Frame)
    
    local function UpdateLine()
        local Direction = (Line.To - Line.From)
        local Center = (Line.To + Line.From) / 2
        
        Frame.Visible = Line.Visible
        Frame.BackgroundTransparency = ConvertTransparency(Line.Transparency)
        Frame.BackgroundColor3 = Line.Color
        Frame.ZIndex = Line.ZIndex
        Frame.AnchorPoint = Line.AnchorPoint
        
        Frame.Size = UDim2.fromOffset(Direction.Magnitude, Line.Thickness)
        Frame.Position = UDim2.fromOffset(Center.X, Center.Y)
        Frame.Rotation = math.deg(math.atan2(Direction.Y, Direction.X))
    end; UpdateLine()
    
    function Line:Trace(From, To)
        From, To = ConvertTargetToScreenPosition(From, "From"), ConvertTargetToScreenPosition(To, "To")
        if From and To then
            Line.Visible = true
            Line.From, Line.To = From, To
        else
            Line.Visible = false
        end
        UpdateLine()
    end
    
    return CreateDrawingObject(Line, UpdateLine)
end

local function DrawSquare()
    local Square = BaseObject + {
        __SHAPE = "Square",
        __INSTANCE = Instance.new("Frame", DrawingDirectory),
        Size = Vector2.zero,
        Position = Vector2.zero,
        Filled = true,
        Rotation = 0,
    }
    
    local Frame = Square.__INSTANCE
    Frame.BorderSizePixel = 0
    
    Square.Rounder = ApplyRoundness(Frame)
    Square.Stroke = ApplyStroke(Frame)
    Square.Gradient = ApplyGradient(Frame)
    Square.AutoRotation = ApplyAutoRotation(Frame)
    
    local function UpdateSquare()
        Frame.Visible = Square.Visible
        Frame.BackgroundTransparency = Square.Filled and ConvertTransparency(Square.Transparency) or 1
        Frame.BackgroundColor3 = Square.Color
        Frame.ZIndex = Square.ZIndex
        Frame.AnchorPoint = Square.AnchorPoint
        
        Frame.Size = UDim2.fromOffset(Square.Size.X, Square.Size.Y)
        Frame.Position = UDim2.fromOffset(Square.Position.X, Square.Position.Y)
        
        Square.Stroke.Enabled = not Square.Filled or Square.Stroke.Enabled
    end; UpdateSquare()
    
    return CreateDrawingObject(Square, UpdateSquare)
end

local function DrawCircle()
    local Circle = BaseObject + {
        __SHAPE = "Circle",
        __INSTANCE = Instance.new("Frame", DrawingDirectory),
        Radius = 0,
        Position = Vector2.zero,
        Filled = true,
        Rotation = 0,
    }
    
    local Frame = Circle.__INSTANCE
    Frame.BorderSizePixel = 0
    
    Circle.Rounder = ApplyRoundness(Frame)
    Circle.Stroke = ApplyStroke(Frame)
    Circle.Gradient = ApplyGradient(Frame)
    Circle.AutoRotation = ApplyAutoRotation(Frame)
    
    Circle.Rounder.CornerRadius = UDim.new(1, 0)
    Circle.Stroke.LineJoinMode = Enum.LineJoinMode.Round
    
    local function UpdateCircle()
        Frame.Visible = Circle.Visible
        Frame.BackgroundTransparency = Circle.Filled and ConvertTransparency(Circle.Transparency) or 1
        Frame.BackgroundColor3 = Circle.Color
        Frame.ZIndex = Circle.ZIndex
        Frame.AnchorPoint = Circle.AnchorPoint
        
        Frame.Size = UDim2.fromOffset(Circle.Radius * 2, Circle.Radius * 2)
        Frame.Position = UDim2.fromOffset(Circle.Position.X, Circle.Position.Y)
        
        Circle.Stroke.Enabled = not Circle.Filled or Circle.Stroke.Enabled
    end; UpdateCircle()
    
    return CreateDrawingObject(Circle, UpdateCircle)
end

local function DrawPolygon(ShapeName, DefaultPoints)
    local IsNGon = ShapeName == "NGon"
    local SideCount = #DefaultPoints
    
    local Polygon = BaseObject + {
        __SHAPE = ShapeName,
        __INSTANCE = Instance.new("Folder", DrawingDirectory),
        Position = Vector2.zero,
        Filled = true,
        Radius = 0,
        Rotation = 0,
    }
    
    if IsNGon then
        Polygon.Points = SideCount
        for Index = 1, SideCount do
            Polygon["Point" .. Index] = DefaultPoints[Index]
        end
    else
        for Index, Point in DefaultPoints do
            Polygon["Point" .. Letters[Index]] = Point
        end
    end
    
    local Folder = Polygon.__INSTANCE
    local Lines = {
        Inner = { DrawLine(Folder) },
        Outer = {}
    }
    for Index = 1, SideCount do
        table.insert(Lines.Outer, DrawLine(Folder))
    end
    
    --// Gradient
    
    local GradientAutoRotation = setmetatable({}, {
        __index = function(_, Key)
            return Lines.Inner[1] and Lines.Inner[1].Gradient.AutoRotation[Key]
        end,
        __newindex = function(_, Key, Value)
            for _, Line in Lines.Inner do Line.Gradient.AutoRotation[Key] = Value end
        end,
    })
    
    local Gradient = setmetatable({}, {
        __index = function(_, Key)
            if Key == "AutoRotation" then return GradientAutoRotation end
            return Lines.Inner[1] and Lines.Inner[1].Gradient[Key]
        end,
        __newindex = function(_, Key, Value)
            for _, Line in Lines.Inner do Line.Gradient[Key] = Value end
        end,
    })
    
    Polygon.Gradient = Gradient
    
    
    
    --// Outlines
    
    
    
    local Outlines = {
        Visible = true,
        Transparency = 1,
        Color = Color3.new(1, 1, 1),
        ZIndex = 0,
        Thickness = 1,
    }
    
    local OutlinesGradientAutoRotation = setmetatable({}, {
        __index = function(_, Key)
            return Lines.Outer[1].Gradient.AutoRotation[Key]
        end,
        __newindex = function(_, Key, Value)
            for _, Line in Lines.Outer do Line.Gradient.AutoRotation[Key] = Value end
        end
    })
    
    local OutlinesGradient = setmetatable({}, {
        __index = function(_, Key)
            if Key == "AutoRotation" then return OutlinesGradientAutoRotation end
            return Lines.Outer[1].Gradient[Key]
        end,
        __newindex = function(_, Key, Value)
            for _, Line in Lines.Outer do Line.Gradient[Key] = Value end
        end
    })
    
    Outlines.Gradient = OutlinesGradient
    
    local OutlinesStrokeGradientAutoRotation = setmetatable({}, {
        __index = function(_, Key)
            return Lines.Outer[1].Stroke.Gradient.AutoRotation[Key]
        end,
        __newindex = function(_, Key, Value)
            for _, Line in Lines.Outer do Line.Stroke.Gradient.AutoRotation[Key] = Value end
        end
    })
    
    local OutlinesStrokeGradient = setmetatable({}, {
        __index = function(_, Key)
            if Key == "AutoRotation" then return OutlinesStrokeGradientAutoRotation end
            return Lines.Outer[1].Stroke.Gradient[Key]
        end,
        __newindex = function(_, Key, Value)
            for _, Line in Lines.Outer do Line.Stroke.Gradient[Key] = Value end
        end
    })
    
    local OutlinesStroke = setmetatable({}, {
        __index = function(_, Key)
            if Key == "Gradient" then return OutlinesStrokeGradient end
            return Lines.Outer[1].Stroke[Key]
        end,
        __newindex = function(_, Key, Value)
            for _, Line in Lines.Outer do Line.Stroke[Key] = Value end
        end,
    })
    
    Outlines.Stroke = OutlinesStroke
    
    
    
    --// Update
    
    
    
    local function GetPoints()
        local OffsetX = Polygon.Position.X
        local OffsetY = Polygon.Position.Y
        local Points = {}
        local Count = IsNGon and Polygon.Points or SideCount
        
        if Polygon.Radius > 0 then
            for Index = 1, Count do
                local Angle = (Index / Count) * (math.pi * 2) - math.pi / 2
                table.insert(Points, Vector2.new(
                    OffsetX + math.cos(Angle) * Polygon.Radius,
                    OffsetY + math.sin(Angle) * Polygon.Radius
                ))
            end
        else
            if IsNGon then
                for Index = 1, Count do
                    local Value = Polygon["Point" .. Index]
                    if Value == nil then break end
                    table.insert(Points, Vector2.new(OffsetX + Value.X, OffsetY + Value.Y))
                end
            else
                for _, Letter in Letters do
                    local Value = Polygon["Point" .. Letter]
                    if Value == nil then break end
                    table.insert(Points, Vector2.new(OffsetX + Value.X, OffsetY + Value.Y))
                end
            end
        end
        
        if Polygon.Rotation ~= 0 then
            local Radians = math.rad(Polygon.Rotation)
            local Cos, Sin = math.cos(Radians), math.sin(Radians)
            local RotatedPoints = {}
            for _, Point in Points do
                local DeltaX, DeltaY = Point.X - Polygon.Position.X, Point.Y - Polygon.Position.Y
                table.insert(RotatedPoints, Vector2.new(
                    Polygon.Position.X + DeltaX * Cos - DeltaY * Sin,
                    Polygon.Position.Y + DeltaX * Sin + DeltaY * Cos
                ))
            end
            Points = RotatedPoints
        end
        
        return Points
    end
    
    local function LineIntersection(PointA, PointB, ScanY)
        if not ((PointA.Y <= ScanY and PointB.Y >= ScanY) or (PointA.Y >= ScanY and PointB.Y <= ScanY)) then return end
        if PointA.Y == PointB.Y then return end
        local Progress = (ScanY - PointA.Y) / (PointB.Y - PointA.Y)
        if not (Progress >= 0 and Progress < 1) then return end
        return PointA.X + Progress * (PointB.X - PointA.X)
    end
    
    local function UpdatePolygon()
        local Points = GetPoints()
        local PointCount = #Points
        
        local Edges = {}
        
        for Index = 1, PointCount do
            table.insert(Edges, { Points[Index], Points[Index % PointCount + 1] })
        end
        
        while #Lines.Outer < PointCount do
            table.insert(Lines.Outer, DrawLine(Folder))
            Outlines.Stroke.Gradient.AutoRotation.Enabled = Outlines.Gradient.Enabled
            Outlines.Gradient.AutoRotation.Enabled = Outlines.Gradient.Enabled
        end
        
        for Index, Edge in Edges do
            local Line = Lines.Outer[Index]
            local Direction = Edge[2] - Edge[1]
            local Extend = Direction.Magnitude > 0 and Direction.Unit * (Outlines.Thickness / 2) or Vector2.zero
            
            Line.From = Edge[1] - Extend
            Line.To = Edge[2] + Extend
            Line.Visible = Outlines.Visible
            Line.Transparency = Outlines.Transparency
            Line.Color = Outlines.Color
            Line.Thickness = Outlines.Thickness
            Line.ZIndex = Outlines.ZIndex + 1
            Line.Rounder.CornerRadius = UDim.new(1, 0)
            Line.Stroke.Enabled = Outlines.Stroke.Enabled
            Line.Gradient.Enabled = Outlines.Gradient.Enabled
            Line.Stroke.LineJoinMode = Enum.LineJoinMode.Round
        end
        
        for Index = PointCount + 1, #Lines.Outer do
            Lines.Outer[Index].Visible = false
        end
        
        local MinY, MaxY = math.huge, -math.huge
        
        for _, Point in Points do
            MinY = math.min(MinY, Point.Y)
            MaxY = math.max(MaxY, Point.Y)
        end
        
        MinY = math.floor(MinY)
        MaxY = math.ceil(MaxY)
        
        local LineCount = MaxY - MinY + 1
        
        while LineCount > #Lines.Inner do
            table.insert(Lines.Inner, DrawLine(Folder))
        end
        
        for Index = LineCount + 1, #Lines.Inner do
            Lines.Inner[Index].Visible = false
        end
        
        if Polygon.Filled then
            for Y = MinY, MaxY do
                local LineIndex = Y - MinY + 1
                local FillLine = Lines.Inner[LineIndex]
                local Intersections = {}
                
                for _, Edge in Edges do
                    local Intersect = LineIntersection(Edge[1], Edge[2], Y)
                    if Intersect then table.insert(Intersections, Intersect) end
                end
                
                if #Intersections >= 2 then
                    table.sort(Intersections)
                    
                    for I = 1, #Intersections - 1, 2 do
                        FillLine.From = Vector2.new(Intersections[I], Y)
                        FillLine.To = Vector2.new(Intersections[I + 1], Y)
                        FillLine.Thickness = 1
                        FillLine.Stroke.Enabled = false
                        FillLine.Visible = Polygon.Visible
                        FillLine.Color = Polygon.Color
                        FillLine.Transparency = Polygon.Transparency
                        FillLine.ZIndex = Polygon.ZIndex
                        
                        LineIndex = LineIndex + 1
                        if LineIndex <= #Lines.Inner then
                            FillLine = Lines.Inner[LineIndex]
                        end
                    end
                else
                    FillLine.Visible = false
                end
            end
        else
            for _, Line in Lines.Inner do Line.Visible = false end
        end
    end; UpdatePolygon()
    
    Polygon.Outlines = setmetatable({}, {
        __index = function(_, Key)
            return Outlines[Key]
        end,
        __newindex = function(_, Key, Value)
            if Key == "Stroke" or Key == "Gradient" then
                error("Cannot set " .. Key .. " directly, use Outlines." .. Key .. ".PropertyName")
            end
            assert(Outlines[Key] ~= nil, "Invalid property '" .. Key .. "' for Outlines")
            AssertType(Value, typeof(Outlines[Key]), Key)
            
            Outlines[Key] = Value
            UpdatePolygon()
        end,
    })
    
    Polygon.AutoRotation = ApplyAutoRotation(nil, function(AutoRotation, Step)
        local Range = AutoRotation.End - AutoRotation.Start
        Polygon.Rotation = AutoRotation.Start + ((Polygon.Rotation - AutoRotation.Start + Step) % Range)
        UpdatePolygon()
    end)
        
    return CreateDrawingObject(Polygon, UpdatePolygon)
end

local function CreateEmptyPoints(Amount)
    local EmptyPoints = {}
    for Index = 1, Amount do
        table.insert(EmptyPoints, Vector2.zero)
    end
    return EmptyPoints
end

local function DrawTriangle()
    return DrawPolygon("Triangle", CreateEmptyPoints(3))
end

local function DrawQuad()
    return DrawPolygon("Quad", CreateEmptyPoints(4))
end

local function DrawPentagon()
    return DrawPolygon("Pentagon", CreateEmptyPoints(5))
end

local function DrawHexagon()
    return DrawPolygon("Hexagon", CreateEmptyPoints(6))
end

local function DrawHeptagon()
    return DrawPolygon("Heptagon", CreateEmptyPoints(7))
end

local function DrawOctagon()
    return DrawPolygon("Octagon", CreateEmptyPoints(8))
end

local function DrawNonagon()
    return DrawPolygon("Nonagon", CreateEmptyPoints(9))
end

local function DrawDecagon()
    return DrawPolygon("Decagon", CreateEmptyPoints(10))
end

local function DrawHendecagon()
    return DrawPolygon("Hendecagon", CreateEmptyPoints(11))
end

local function DrawDodecagon()
    return DrawPolygon("Dodecagon", CreateEmptyPoints(12))
end

local function DrawNGon()
    return DrawPolygon("NGon", CreateEmptyPoints(3))
end

local DrawingFunctions = {
    ["line"] = DrawLine,
    ["square"] = DrawSquare,
    ["circle"] = DrawCircle,
    ["triangle"] = DrawTriangle,
    ["quad"] = DrawQuad,
    ["pentagon"] = DrawPentagon,
    ["hexagon"] = DrawHexagon,
    ["heptagon"] = DrawHeptagon,
    ["octagon"] = DrawOctagon,
    ["nonagon"] = DrawNonagon,
    ["decagon"] = DrawDecagon,
    ["hendecagon"] = DrawHendecagon,
    ["dodecagon"] = DrawDodecagon,
    ["ngon"] = DrawNGon,
}



--// DRAWING API



function Drawing.new(Shape)
    assert(typeof(Shape) == "string", "Expected A Shape Name But Got " .. typeof(Shape))
    Shape = Shape:lower():gsub("%W", "")
    local DrawShape = DrawingFunctions[Shape]
    assert(DrawShape, "Expected A Valid Shape Name But Got " .. Shape)
    return DrawShape()
end

function Drawing.IsInShape(Shape, Target, OnScreenCheck)
    assert(typeof(Shape) == "table" and Shape.__SHAPE, "Shape Expects A Valid Drawing Object But Got " .. typeof(Shape))
    local ShapeType = Shape.__SHAPE
    local Position = ConvertTargetToScreenPosition(Target, "Position/Target", OnScreenCheck)
    
    if ShapeType == "Circle" then
        return (Position - Shape.Position).Magnitude <= Shape.Radius
    elseif ShapeType == "Square" then
        local Left = Shape.Position.X - Shape.AnchorPoint.X * Shape.Size.X
        local Top = Shape.Position.Y - Shape.AnchorPoint.Y * Shape.Size.Y
        return Position.X >= Left and Position.X <= Left + Shape.Size.X and Position.Y >= Top and Position.Y <= Top + Shape.Size.Y
    elseif ShapeType == "Line" then
        local LineDirection = Shape.To - Shape.From
        local LineLengthSquared = LineDirection:Dot(LineDirection)
        local HowFarAlongLine = LineLengthSquared > 0 and math.clamp((Position - Shape.From):Dot(LineDirection) / LineLengthSquared, 0, 1) or 0
        local ClosestPointOnLine = Shape.From + LineDirection * HowFarAlongLine
        return (Position - ClosestPointOnLine).Magnitude <= Shape.Thickness / 2
    else
        local Count = SideCounts[ShapeType] or (ShapeType == "NGon" and (Shape.Points or 3))
        local Verts = {}
        
        if Shape.Radius > 0 then
            for Index = 1, Count do
                local Angle = (Index / Count) * (math.pi * 2) - math.pi / 2
                table.insert(Verts, Vector2.new(
                    Shape.Position.X + math.cos(Angle) * Shape.Radius,
                    Shape.Position.Y + math.sin(Angle) * Shape.Radius
                ))
            end
        elseif ShapeType == "NGon" then
            for Index = 1, Count do
                local Point = Shape["Point" .. Index]
                if not Point then break end
                table.insert(Verts, Shape.Position + Point)
            end
        else
            for _, Letter in Letters do
                local Point = Shape["Point" .. Letter]
                if not Point then break end
                table.insert(Verts, Shape.Position + Point)
            end
        end
        
        local IsInside = false
        local VertexCount = #Verts
        local PreviousIndex = VertexCount
       
        for Index = 1, VertexCount do
            local CurrentVertex = Verts[Index]
            local PreviousVertex = Verts[PreviousIndex]
            local EdgeCrossesRay = (CurrentVertex.Y > Position.Y) ~= (PreviousVertex.Y > Position.Y)
            
            if EdgeCrossesRay then
                local RayCrossX = (PreviousVertex.X - CurrentVertex.X) * (Position.Y - CurrentVertex.Y) / (PreviousVertex.Y - CurrentVertex.Y) + CurrentVertex.X
                
                if Position.X < RayCrossX then
                    IsInside = not IsInside
                end
            end
            
            PreviousIndex = Index
        end
        
        return IsInside
    end
    
    return false
end

return Drawing
