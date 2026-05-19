# Drawing Library

A Roblox drawing library that renders 2D shapes directly on your screen using `GuiObject` instances. Every shape is built entirely from `Frame`, `UIStroke`, `UIGradient`, and `UICorner` instances.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Drawing.new](#drawingnew)
- [Drawing.IsInShape](#drawingsisinshape)
- [Shared Properties](#shared-properties)
- [Sub-Objects](#sub-objects)
  - [Stroke](#stroke)
  - [Gradient](#gradient)
  - [AutoRotation](#autorotation)
  - [Rounder](#rounder)
  - [Outlines](#outlines-polygons-only)
- [Shapes](#shapes)
  - [Line](#line)
  - [Square](#square)
  - [Circle](#circle)
  - [Triangle](#triangle)
  - [Quad](#quad)
  - [Pentagon](#pentagon)
  - [Hexagon](#hexagon)
  - [Heptagon](#heptagon)
  - [Octagon](#octagon)
  - [Nonagon](#nonagon)
  - [Decagon](#decagon)
  - [Hendecagon](#hendecagon)
  - [Dodecagon](#dodecagon)
  - [NGon](#ngon)
- [UDim2 Auto-Conversion](#udim2-auto-conversion)
- [Target Types](#target-types)

---

## Getting Started

Load the library and create your first shape:

```luau
local Drawing = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheRealXORA/Drawing/refs/heads/main/Drawing.luau", true))()

local Circle = Drawing.new("Circle")
Circle.Radius   = 50
Circle.Position = workspace.CurrentCamera.ViewportSize / 2
Circle.Color    = Color3.fromRGB(255, 80, 80)
Circle.Filled   = true
Circle.Visible  = true
```

Always clean up shapes when you are done with them to avoid memory leaks:

```luau
Circle:Destroy()
-- or
Circle:Remove()
```

---

## Drawing.new

```luau
Drawing.new(Shape: string) -> DrawingObject
```

Creates and returns a new drawing object for the given shape name. The name is **case-insensitive** and all non-word characters are stripped before lookup, so `"NGon"`, `"ngon"`, and `"n-gon"` all resolve to the same shape.

**Valid shape names:**

| Name         | Shape                    |
|--------------|--------------------------|
| `line`       | Straight line            |
| `square`     | Rectangle                |
| `circle`     | Circle                   |
| `triangle`   | 3-sided polygon          |
| `quad`       | 4-sided polygon          |
| `pentagon`   | 5-sided polygon          |
| `hexagon`    | 6-sided polygon          |
| `heptagon`   | 7-sided polygon          |
| `octagon`    | 8-sided polygon          |
| `nonagon`    | 9-sided polygon          |
| `decagon`    | 10-sided polygon         |
| `hendecagon` | 11-sided polygon         |
| `dodecagon`  | 12-sided polygon         |
| `ngon`       | N-sided polygon (custom) |

```luau
local Square = Drawing.new("Square")
local Line   = Drawing.new("line")   -- case-insensitive
local NGon   = Drawing.new("NGon")
```

---

## Drawing.IsInShape

```luau
Drawing.IsInShape(Shape: DrawingObject, Target: Vector2 | UDim2 | Vector3 | BasePart | Model, OnScreenCheck: boolean?) -> boolean (InShape), number (Distance)
```

Returns `true` if the given `Target` position lies within the bounds of `Shape`. Works for all shape types including polygons.

| Parameter     | Type                                         | Description                                            |
|---------------|----------------------------------------------|--------------------------------------------------------|
| Shape         | DrawingObject                                | A valid drawing object returned by `Drawing.new`       |
| Target        | Vector2 / UDim2 / Vector3 / BasePart / Model | The position to test against the shape                 |
| OnScreenCheck | boolean?                                     | When `false`, skips the on-screen check for 3D targets |

**Example 1 — Point inside a circle:**

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Circle = Drawing.new("Circle")
Circle.Position = Center
Circle.Radius   = 80
Circle.Color    = Color3.fromRGB(0, 200, 255)
Circle.Filled   = true
Circle.Visible  = true

local IsInside, Distance = Drawing.IsInShape(Circle, Center)
print(IsInside, Distance) -- true, 0
```

**Example 2 — Offset point inside a square:**

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Square = Drawing.new("Square")
Square.Position = Center
Square.Size     = Vector2.new(200, 120)
Square.Color    = Color3.fromRGB(255, 180, 0)
Square.Filled   = true
Square.Visible  = true

local IsInside, Distance = Drawing.IsInShape(Square, Center + Vector2.new(50, 20))
print(IsInside, Distance) -- true, distance from shape edge
```

**Example 3 — Point inside a hexagon with a 3D part as the target:**

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Hexagon = Drawing.new("Hexagon")
Hexagon.Position = Center
Hexagon.Radius   = 100
Hexagon.Color    = Color3.fromRGB(180, 80, 255)
Hexagon.Filled   = true
Hexagon.Visible  = true

local Part = workspace:FindFirstChild("SomePart")
if Part then
    local IsInside, Distance = Drawing.IsInShape(Hexagon, Part)
    print(IsInside, Distance)
end
```

---

## Shared Properties

Every drawing object inherits these base properties regardless of shape type.

| Property     | Type    | Default             | Description                                          |
|--------------|---------|---------------------|------------------------------------------------------|
| Visible      | boolean | `true`              | Whether the shape is rendered on screen              |
| Transparency | number  | `1`                 | Opacity from `0` (invisible) to `1` (fully opaque)  |
| Color        | Color3  | `Color3.new(1,1,1)` | Fill color of the shape                              |
| ZIndex       | number  | `0`                 | Render order — higher values draw on top             |
| AnchorPoint  | Vector2 | `Vector2.one / 2`   | Pivot point for positioning (0–1 range on each axis) |

### Shared Methods

| Method       | Description                                                              |
|--------------|--------------------------------------------------------------------------|
| `:Remove()`  | Destroys the underlying GuiObject instance and clears the drawing object |
| `:Destroy()` | Alias for `:Remove()`                                                    |

---

## Sub-Objects

Sub-objects are nested tables attached to drawing objects that control extra visual behaviour like borders, gradients, corner rounding, and auto-spinning. **You cannot assign a sub-object directly** — you must set its properties individually.

```luau
-- ✅ Correct
Shape.Stroke.Color   = Color3.fromRGB(255, 0, 0)
Shape.Stroke.Enabled = true

-- ❌ Wrong — will throw an error
Shape.Stroke = { Color = Color3.fromRGB(255, 0, 0) }
```

---

### Stroke

Controls the border drawn around the shape. Available on `Line`, `Square`, `Circle`, and all polygon `Outlines`.

| Property     | Type              | Default                   | Description                                        |
|--------------|-------------------|---------------------------|----------------------------------------------------|
| Enabled      | boolean           | `true`                    | Whether the stroke is drawn                        |
| Color        | Color3            | `Color3.new(1,1,1)`       | Color of the stroke                                |
| Thickness    | number            | `1`                       | Width of the stroke in pixels                      |
| Transparency | number            | `1`                       | Opacity from `0` (invisible) to `1` (fully opaque) |
| LineJoinMode | Enum.LineJoinMode | `Enum.LineJoinMode.Miter` | Corner join style for the stroke                   |
| Gradient     | Gradient          | —                         | Gradient applied to the stroke (read-only handle)  |

---

### Gradient

Controls a color or transparency gradient applied across the shape. Available on `Line`, `Square`, `Circle`, polygon fill, polygon `Outlines`, and `Stroke`.

| Property     | Type           | Default                 | Description                                                  |
|--------------|----------------|-------------------------|--------------------------------------------------------------|
| Enabled      | boolean        | `false`                 | Whether the gradient is applied                              |
| Color        | ColorSequence  | White → Black → White   | Color gradient mapped across the shape                       |
| Rotation     | number         | `0`                     | Rotation of the gradient direction in degrees                |
| Transparency | NumberSequence | `NumberSequence.new(0)` | Transparency gradient mapped across the shape                |
| Offset       | Vector2        | `Vector2.new(0, 0)`     | Offset of the gradient origin point                          |
| AutoRotation | AutoRotation   | —                       | Auto-rotation sub-object for the gradient (read-only handle) |

---

### AutoRotation

Automatically rotates a shape or gradient every frame using `RunService.Heartbeat`. Available on `Square`, `Circle`, all polygon shapes, and `Gradient`.

The rotation loops between `Start` and `End` degrees, incrementing by `Amount * Speed` degrees per second.

| Property | Type    | Default | Description                                                          |
|----------|---------|---------|----------------------------------------------------------------------|
| Enabled  | boolean | `false` | Whether auto-rotation is active                                      |
| Amount   | number  | `90`    | Base degrees rotated per second                                      |
| Speed    | number  | `1`     | Multiplier applied on top of `Amount`                                |
| Start    | number  | `0`     | Lower bound of the rotation range in degrees                         |
| End      | number  | `360`   | Upper bound of the rotation range; rotation wraps back at this value |

> **Note:** `Line` does not support `AutoRotation` — its angle is always derived from the `From` and `To` positions.

---

### Rounder

Controls the corner rounding of the shape via a `UICorner` instance. Available on `Line`, `Square`, and `Circle`. Set the `CornerRadius` property directly — it accepts a `UDim`.

| Property     | Type | Default        | Description                  |
|--------------|------|----------------|------------------------------|
| CornerRadius | UDim | `UDim.new(0,0)`| Radius of the corner rounding |

```luau
Shape.Rounder.CornerRadius = UDim.new(0, 8)  -- slightly rounded
Shape.Rounder.CornerRadius = UDim.new(1, 0)  -- fully rounded (pill/circle)
```

> **Note:** `Circle` already sets `CornerRadius` to `UDim.new(1, 0)` by default. Changing it will distort the shape.

---

### Outlines (Polygons only)

Available on all polygon shapes (`Triangle`, `Quad`, … `NGon`). Controls the border lines drawn along each edge of the polygon.

| Property     | Type     | Default             | Description                            |
|--------------|----------|---------------------|----------------------------------------|
| Visible      | boolean  | `true`              | Whether the outline edges are rendered |
| Transparency | number   | `1`                 | Opacity of the outlines                |
| Color        | Color3   | `Color3.new(1,1,1)` | Color of the outline edges             |
| ZIndex       | number   | `0`                 | Render order for the outlines          |
| Thickness    | number   | `1`                 | Width of each outline edge in pixels   |
| Gradient     | Gradient | —                   | Gradient applied to the outline edges  |
| Stroke       | Stroke   | —                   | Stroke applied to the outline edges    |

---

## Shapes

All examples position shapes at the center of the screen using `workspace.CurrentCamera.ViewportSize / 2`. Each example demonstrates all available properties and sub-objects for that shape.

---

### Line

Draws a straight line between two screen positions.

| Property     | Type           | Default             | Description                 |
|--------------|----------------|---------------------|-----------------------------|
| From         | Vector2\|UDim2 | `Vector2.zero`      | Start point of the line     |
| To           | Vector2\|UDim2 | `Vector2.zero`      | End point of the line       |
| Thickness    | number         | `1`                 | Width of the line in pixels |
| Visible      | boolean        | `true`              | Inherited from base         |
| Transparency | number         | `1`                 | Inherited from base         |
| Color        | Color3         | `Color3.new(1,1,1)` | Inherited from base         |
| ZIndex       | number         | `0`                 | Inherited from base         |
| AnchorPoint  | Vector2        | `Vector2.one / 2`   | Inherited from base         |

**Sub-objects:** `Stroke`, `Gradient`, `Rounder`

> **Note:** `Line` does not support `AutoRotation`. Its angle is always computed from `From` and `To`.

#### Method: Trace

```luau
Line:Trace(From: Vector2 | Vector3 | BasePart | Model, To: Vector2 | Vector3 | BasePart | Model)
```

Automatically updates `From` and `To` by converting 3D world targets to screen positions on each call. If either target goes off-screen, the line is hidden automatically and shown again once both targets are visible.

#### Example

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Line = Drawing.new("Line")
Line.From         = Center + Vector2.new(-100, 0)
Line.To           = Center + Vector2.new(100, 0)
Line.Thickness    = 4
Line.Color        = Color3.fromRGB(255, 255, 255)
Line.Transparency = 1
Line.ZIndex       = 0
Line.Visible      = true

-- Stroke
Line.Stroke.Enabled      = true
Line.Stroke.Color        = Color3.fromRGB(0, 0, 0)
Line.Stroke.Thickness    = 2
Line.Stroke.Transparency = 1
Line.Stroke.LineJoinMode = Enum.LineJoinMode.Round

-- Gradient
Line.Gradient.Enabled      = true
Line.Gradient.Color        = ColorSequence.new(Color3.fromRGB(255, 80, 180), Color3.fromRGB(80, 180, 255))
Line.Gradient.Rotation     = 0
Line.Gradient.Transparency = NumberSequence.new(0)
Line.Gradient.Offset       = Vector2.new(0, 0)

-- Rounder
Line.Rounder.CornerRadius = UDim.new(0, 4)
```

---

### Square

Draws a rectangle that can be filled or outlined.

| Property     | Type           | Default             | Description                                 |
|--------------|----------------|---------------------|---------------------------------------------|
| Position     | Vector2\|UDim2 | `Vector2.zero`      | Position of the square on screen            |
| Size         | Vector2\|UDim2 | `Vector2.zero`      | Width and height of the square in pixels    |
| Filled       | boolean        | `true`              | If `false`, only the stroke border is drawn |
| Rotation     | number         | `0`                 | Rotation of the square in degrees           |
| Visible      | boolean        | `true`              | Inherited from base                         |
| Transparency | number         | `1`                 | Inherited from base                         |
| Color        | Color3         | `Color3.new(1,1,1)` | Inherited from base                         |
| ZIndex       | number         | `0`                 | Inherited from base                         |
| AnchorPoint  | Vector2        | `Vector2.one / 2`   | Inherited from base                         |

**Sub-objects:** `Stroke`, `Gradient`, `Rounder`, `AutoRotation`

> **Note:** When `Filled` is `false`, `Stroke.Enabled` is forced to `true` automatically.

#### Example

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Square = Drawing.new("Square")
Square.Position    = Center
Square.Size        = Vector2.new(150, 150)
Square.Filled      = true
Square.Rotation    = 0
Square.Color       = Color3.fromRGB(255, 255, 255)
Square.Transparency = 1
Square.ZIndex      = 0
Square.Visible     = true

-- Stroke
Square.Stroke.Enabled      = true
Square.Stroke.Color        = Color3.fromRGB(0, 0, 0)
Square.Stroke.Thickness    = 3
Square.Stroke.Transparency = 1
Square.Stroke.LineJoinMode = Enum.LineJoinMode.Miter

-- Gradient
Square.Gradient.Enabled      = true
Square.Gradient.Color        = ColorSequence.new(Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 220, 0))
Square.Gradient.Rotation     = 45
Square.Gradient.Transparency = NumberSequence.new(0)
Square.Gradient.Offset       = Vector2.new(0, 0)

-- Rounder
Square.Rounder.CornerRadius = UDim.new(0, 8)

-- AutoRotation
Square.AutoRotation.Enabled = true
Square.AutoRotation.Amount  = 60
Square.AutoRotation.Speed   = 1
Square.AutoRotation.Start   = 0
Square.AutoRotation.End     = 360
```

---

### Circle

Draws a circle defined by a center position and radius.

| Property     | Type           | Default             | Description                                             |
|--------------|----------------|---------------------|---------------------------------------------------------|
| Position     | Vector2\|UDim2 | `Vector2.zero`      | Center of the circle on screen                          |
| Radius       | number         | `0`                 | Radius of the circle in pixels                          |
| Filled       | boolean        | `true`              | If `false`, only the stroke border is drawn             |
| Rotation     | number         | `0`                 | Rotation in degrees (mainly affects gradient direction) |
| Visible      | boolean        | `true`              | Inherited from base                                     |
| Transparency | number         | `1`                 | Inherited from base                                     |
| Color        | Color3         | `Color3.new(1,1,1)` | Inherited from base                                     |
| ZIndex       | number         | `0`                 | Inherited from base                                     |
| AnchorPoint  | Vector2        | `Vector2.one / 2`   | Inherited from base                                     |

**Sub-objects:** `Stroke`, `Gradient`, `Rounder`, `AutoRotation`

> **Note:** `Stroke.LineJoinMode` is pre-set to `Enum.LineJoinMode.Round` for smooth borders. When `Filled` is `false`, `Stroke.Enabled` is forced to `true` automatically.

#### Example

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Circle = Drawing.new("Circle")
Circle.Position    = Center
Circle.Radius      = 80
Circle.Filled      = true
Circle.Rotation    = 0
Circle.Color       = Color3.fromRGB(255, 255, 255)
Circle.Transparency = 1
Circle.ZIndex      = 0
Circle.Visible     = true

-- Stroke
Circle.Stroke.Enabled      = true
Circle.Stroke.Color        = Color3.fromRGB(0, 0, 0)
Circle.Stroke.Thickness    = 3
Circle.Stroke.Transparency = 1

-- Gradient
Circle.Gradient.Enabled      = true
Circle.Gradient.Color        = ColorSequence.new(Color3.fromRGB(0, 200, 255), Color3.fromRGB(180, 0, 255))
Circle.Gradient.Rotation     = 0
Circle.Gradient.Transparency = NumberSequence.new(0)
Circle.Gradient.Offset       = Vector2.new(0, 0)

-- Gradient AutoRotation (spinning gradient)
Circle.Gradient.AutoRotation.Enabled = true
Circle.Gradient.AutoRotation.Amount  = 120
Circle.Gradient.AutoRotation.Speed   = 1
Circle.Gradient.AutoRotation.Start   = 0
Circle.Gradient.AutoRotation.End     = 360

-- Rounder (avoid changing this on circles — it distorts the shape)
-- Circle.Rounder.CornerRadius = UDim.new(1, 0) -- already set by default
```

---

## Polygon Shapes

All polygon shapes share the same property set. Vertices are defined using named point properties (`PointA`, `PointB`, etc.) relative to `Position`.

| Shape      | Sides | Point Properties             |
|------------|-------|------------------------------|
| Triangle   | 3     | `PointA`, `PointB`, `PointC` |
| Quad       | 4     | `PointA` … `PointD`          |
| Pentagon   | 5     | `PointA` … `PointE`          |
| Hexagon    | 6     | `PointA` … `PointF`          |
| Heptagon   | 7     | `PointA` … `PointG`          |
| Octagon    | 8     | `PointA` … `PointH`          |
| Nonagon    | 9     | `PointA` … `PointI`          |
| Decagon    | 10    | `PointA` … `PointJ`          |
| Hendecagon | 11    | `PointA` … `PointK`          |
| Dodecagon  | 12    | `PointA` … `PointL`          |

### Shared Polygon Properties

| Property     | Type           | Default             | Description                                                                         |
|--------------|----------------|---------------------|-------------------------------------------------------------------------------------|
| Position     | Vector2\|UDim2 | `Vector2.zero`      | Origin offset added to all vertex points                                            |
| Filled       | boolean        | `true`              | Whether the interior of the polygon is filled                                       |
| Radius       | number         | `0`                 | When `> 0`, vertices are auto-computed evenly around a circle; `PointX` is ignored |
| Rotation     | number         | `0`                 | Rotation in degrees applied around `Position`                                       |
| PointX       | Vector2        | `Vector2.zero`      | Local offset for each named vertex, relative to `Position`                          |
| Visible      | boolean        | `true`              | Inherited from base                                                                 |
| Transparency | number         | `1`                 | Inherited from base                                                                 |
| Color        | Color3         | `Color3.new(1,1,1)` | Inherited from base                                                                 |
| ZIndex       | number         | `0`                 | Inherited from base                                                                 |
| AnchorPoint  | Vector2        | `Vector2.one / 2`   | Inherited from base                                                                 |

**Sub-objects:** `Gradient`, `Outlines`, `AutoRotation`

> **Tip:** Setting `Radius > 0` is the easiest way to draw a regular polygon — all vertices are spaced evenly around `Position` so you don't need to set `PointX` values manually.

---

### Triangle

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Triangle = Drawing.new("Triangle")
Triangle.Position    = Center
Triangle.PointA      = Vector2.new(0, -80)
Triangle.PointB      = Vector2.new(70, 40)
Triangle.PointC      = Vector2.new(-70, 40)
Triangle.Filled      = true
Triangle.Rotation    = 0
Triangle.Color       = Color3.fromRGB(255, 255, 255)
Triangle.Transparency = 1
Triangle.ZIndex      = 0
Triangle.Visible     = true

-- Outlines
Triangle.Outlines.Visible      = true
Triangle.Outlines.Color        = Color3.fromRGB(0, 0, 0)
Triangle.Outlines.Thickness    = 2
Triangle.Outlines.Transparency = 1
Triangle.Outlines.ZIndex       = 1

-- Gradient
Triangle.Gradient.Enabled      = true
Triangle.Gradient.Color        = ColorSequence.new(Color3.fromRGB(0, 255, 120), Color3.fromRGB(0, 80, 255))
Triangle.Gradient.Rotation     = 90
Triangle.Gradient.Transparency = NumberSequence.new(0)
Triangle.Gradient.Offset       = Vector2.new(0, 0)

-- AutoRotation
Triangle.AutoRotation.Enabled = true
Triangle.AutoRotation.Amount  = 45
Triangle.AutoRotation.Speed   = 1
Triangle.AutoRotation.Start   = 0
Triangle.AutoRotation.End     = 360
```

---

### Quad

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Quad = Drawing.new("Quad")
Quad.Position    = Center
Quad.PointA      = Vector2.new(-90, -60)
Quad.PointB      = Vector2.new(90, -60)
Quad.PointC      = Vector2.new(90, 60)
Quad.PointD      = Vector2.new(-90, 60)
Quad.Filled      = true
Quad.Rotation    = 0
Quad.Color       = Color3.fromRGB(255, 255, 255)
Quad.Transparency = 1
Quad.ZIndex      = 0
Quad.Visible     = true

-- Outlines
Quad.Outlines.Visible      = true
Quad.Outlines.Color        = Color3.fromRGB(0, 0, 0)
Quad.Outlines.Thickness    = 2
Quad.Outlines.Transparency = 1
Quad.Outlines.ZIndex       = 1

-- Gradient
Quad.Gradient.Enabled      = true
Quad.Gradient.Color        = ColorSequence.new(Color3.fromRGB(255, 100, 0), Color3.fromRGB(255, 220, 50))
Quad.Gradient.Rotation     = 0
Quad.Gradient.Transparency = NumberSequence.new(0)
Quad.Gradient.Offset       = Vector2.new(0, 0)

-- AutoRotation
Quad.AutoRotation.Enabled = true
Quad.AutoRotation.Amount  = 30
Quad.AutoRotation.Speed   = 1
Quad.AutoRotation.Start   = 0
Quad.AutoRotation.End     = 360
```

---

### Pentagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Pentagon = Drawing.new("Pentagon")
Pentagon.Position    = Center
Pentagon.Radius      = 80
Pentagon.Filled      = true
Pentagon.Rotation    = 0
Pentagon.Color       = Color3.fromRGB(255, 255, 255)
Pentagon.Transparency = 1
Pentagon.ZIndex      = 0
Pentagon.Visible     = true

-- Outlines
Pentagon.Outlines.Visible      = true
Pentagon.Outlines.Color        = Color3.fromRGB(0, 0, 0)
Pentagon.Outlines.Thickness    = 2
Pentagon.Outlines.Transparency = 1
Pentagon.Outlines.ZIndex       = 1

-- Gradient
Pentagon.Gradient.Enabled      = true
Pentagon.Gradient.Color        = ColorSequence.new(Color3.fromRGB(180, 60, 255), Color3.fromRGB(255, 80, 160))
Pentagon.Gradient.Rotation     = 45
Pentagon.Gradient.Transparency = NumberSequence.new(0)
Pentagon.Gradient.Offset       = Vector2.new(0, 0)

-- AutoRotation
Pentagon.AutoRotation.Enabled = true
Pentagon.AutoRotation.Amount  = 40
Pentagon.AutoRotation.Speed   = 1
Pentagon.AutoRotation.Start   = 0
Pentagon.AutoRotation.End     = 360
```

---

### Hexagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Hexagon = Drawing.new("Hexagon")
Hexagon.Position    = Center
Hexagon.Radius      = 80
Hexagon.Filled      = true
Hexagon.Rotation    = 0
Hexagon.Color       = Color3.fromRGB(255, 255, 255)
Hexagon.Transparency = 1
Hexagon.ZIndex      = 0
Hexagon.Visible     = true

-- Outlines
Hexagon.Outlines.Visible      = true
Hexagon.Outlines.Color        = Color3.fromRGB(0, 0, 0)
Hexagon.Outlines.Thickness    = 2
Hexagon.Outlines.Transparency = 1
Hexagon.Outlines.ZIndex       = 1

-- Gradient
Hexagon.Gradient.Enabled      = true
Hexagon.Gradient.Color        = ColorSequence.new(Color3.fromRGB(0, 220, 180), Color3.fromRGB(0, 100, 255))
Hexagon.Gradient.Rotation     = 60
Hexagon.Gradient.Transparency = NumberSequence.new(0)
Hexagon.Gradient.Offset       = Vector2.new(0, 0)

-- AutoRotation
Hexagon.AutoRotation.Enabled = true
Hexagon.AutoRotation.Amount  = 30
Hexagon.AutoRotation.Speed   = 1
Hexagon.AutoRotation.Start   = 0
Hexagon.AutoRotation.End     = 360
```

---

### Heptagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Heptagon = Drawing.new("Heptagon")
Heptagon.Position    = Center
Heptagon.Radius      = 80
Heptagon.Filled      = true
Heptagon.Rotation    = 0
Heptagon.Color       = Color3.fromRGB(255, 255, 255)
Heptagon.Transparency = 1
Heptagon.ZIndex      = 0
Heptagon.Visible     = true

-- Outlines
Heptagon.Outlines.Visible      = true
Heptagon.Outlines.Color        = Color3.fromRGB(0, 0, 0)
Heptagon.Outlines.Thickness    = 2
Heptagon.Outlines.Transparency = 1
Heptagon.Outlines.ZIndex       = 1

-- Gradient
Heptagon.Gradient.Enabled      = true
Heptagon.Gradient.Color        = ColorSequence.new(Color3.fromRGB(255, 0, 120), Color3.fromRGB(255, 180, 0))
Heptagon.Gradient.Rotation     = 0
Heptagon.Gradient.Transparency = NumberSequence.new(0)
Heptagon.Gradient.Offset       = Vector2.new(0, 0)

-- AutoRotation
Heptagon.AutoRotation.Enabled = true
Heptagon.AutoRotation.Amount  = 35
Heptagon.AutoRotation.Speed   = 1
Heptagon.AutoRotation.Start   = 0
Heptagon.AutoRotation.End     = 360
```

---

### Octagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Octagon = Drawing.new("Octagon")
Octagon.Position    = Center
Octagon.Radius      = 80
Octagon.Filled      = true
Octagon.Rotation    = 0
Octagon.Color       = Color3.fromRGB(255, 255, 255)
Octagon.Transparency = 1
Octagon.ZIndex      = 0
Octagon.Visible     = true

-- Outlines
Octagon.Outlines.Visible      = true
Octagon.Outlines.Color        = Color3.fromRGB(0, 0, 0)
Octagon.Outlines.Thickness    = 2
Octagon.Outlines.Transparency = 1
Octagon.Outlines.ZIndex       = 1

-- Gradient
Octagon.Gradient.Enabled      = true
Octagon.Gradient.Color        = ColorSequence.new(Color3.fromRGB(0, 120, 255), Color3.fromRGB(80, 255, 200))
Octagon.Gradient.Rotation     = 0
Octagon.Gradient.Transparency = NumberSequence.new(0)
Octagon.Gradient.Offset       = Vector2.new(0, 0)

-- AutoRotation
Octagon.AutoRotation.Enabled = true
Octagon.AutoRotation.Amount  = 25
Octagon.AutoRotation.Speed   = 1
Octagon.AutoRotation.Start   = 0
Octagon.AutoRotation.End     = 360
```

---

### Nonagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Nonagon = Drawing.new("Nonagon")
Nonagon.Position    = Center
Nonagon.Radius      = 80
Nonagon.Filled      = true
Nonagon.Rotation    = 0
Nonagon.Color       = Color3.fromRGB(255, 255, 255)
Nonagon.Transparency = 1
Nonagon.ZIndex      = 0
Nonagon.Visible     = true

-- Outlines
Nonagon.Outlines.Visible      = true
Nonagon.Outlines.Color        = Color3.fromRGB(0, 0, 0)
Nonagon.Outlines.Thickness    = 2
Nonagon.Outlines.Transparency = 1
Nonagon.Outlines.ZIndex       = 1

-- Gradient
Nonagon.Gradient.Enabled      = true
Nonagon.Gradient.Color        = ColorSequence.new(Color3.fromRGB(255, 220, 0), Color3.fromRGB(255, 100, 0))
Nonagon.Gradient.Rotation     = 90
Nonagon.Gradient.Transparency = NumberSequence.new(0)
Nonagon.Gradient.Offset       = Vector2.new(0, 0)

-- AutoRotation
Nonagon.AutoRotation.Enabled = true
Nonagon.AutoRotation.Amount  = 25
Nonagon.AutoRotation.Speed   = 1
Nonagon.AutoRotation.Start   = 0
Nonagon.AutoRotation.End     = 360
```

---

### Decagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Decagon = Drawing.new("Decagon")
Decagon.Position    = Center
Decagon.Radius      = 80
Decagon.Filled      = true
Decagon.Rotation    = 0
Decagon.Color       = Color3.fromRGB(255, 255, 255)
Decagon.Transparency = 1
Decagon.ZIndex      = 0
Decagon.Visible     = true

-- Outlines
Decagon.Outlines.Visible      = true
Decagon.Outlines.Color        = Color3.fromRGB(0, 0, 0)
Decagon.Outlines.Thickness    = 2
Decagon.Outlines.Transparency = 1
Decagon.Outlines.ZIndex       = 1

-- Gradient
Decagon.Gradient.Enabled      = true
Decagon.Gradient.Color        = ColorSequence.new(Color3.fromRGB(0, 255, 100), Color3.fromRGB(0, 180, 80))
Decagon.Gradient.Rotation     = 0
Decagon.Gradient.Transparency = NumberSequence.new(0)
Decagon.Gradient.Offset       = Vector2.new(0, 0)

-- AutoRotation
Decagon.AutoRotation.Enabled = true
Decagon.AutoRotation.Amount  = 20
Decagon.AutoRotation.Speed   = 1
Decagon.AutoRotation.Start   = 0
Decagon.AutoRotation.End     = 360
```

---

### Hendecagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Hendecagon = Drawing.new("Hendecagon")
Hendecagon.Position    = Center
Hendecagon.Radius      = 80
Hendecagon.Filled      = true
Hendecagon.Rotation    = 0
Hendecagon.Color       = Color3.fromRGB(255, 255, 255)
Hendecagon.Transparency = 1
Hendecagon.ZIndex      = 0
Hendecagon.Visible     = true

-- Outlines
Hendecagon.Outlines.Visible      = true
Hendecagon.Outlines.Color        = Color3.fromRGB(0, 0, 0)
Hendecagon.Outlines.Thickness    = 2
Hendecagon.Outlines.Transparency = 1
Hendecagon.Outlines.ZIndex       = 1

-- Gradient
Hendecagon.Gradient.Enabled      = true
Hendecagon.Gradient.Color        = ColorSequence.new(Color3.fromRGB(255, 80, 0), Color3.fromRGB(255, 200, 50))
Hendecagon.Gradient.Rotation     = 45
Hendecagon.Gradient.Transparency = NumberSequence.new(0)
Hendecagon.Gradient.Offset       = Vector2.new(0, 0)

-- AutoRotation
Hendecagon.AutoRotation.Enabled = true
Hendecagon.AutoRotation.Amount  = 18
Hendecagon.AutoRotation.Speed   = 1
Hendecagon.AutoRotation.Start   = 0
Hendecagon.AutoRotation.End     = 360
```

---

### Dodecagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Dodecagon = Drawing.new("Dodecagon")
Dodecagon.Position    = Center
Dodecagon.Radius      = 80
Dodecagon.Filled      = true
Dodecagon.Rotation    = 0
Dodecagon.Color       = Color3.fromRGB(255, 255, 255)
Dodecagon.Transparency = 1
Dodecagon.ZIndex      = 0
Dodecagon.Visible     = true

-- Outlines
Dodecagon.Outlines.Visible      = true
Dodecagon.Outlines.Color        = Color3.fromRGB(0, 0, 0)
Dodecagon.Outlines.Thickness    = 2
Dodecagon.Outlines.Transparency = 1
Dodecagon.Outlines.ZIndex       = 1

-- Gradient
Dodecagon.Gradient.Enabled      = true
Dodecagon.Gradient.Color        = ColorSequence.new(Color3.fromRGB(100, 255, 200), Color3.fromRGB(0, 180, 140))
Dodecagon.Gradient.Rotation     = 0
Dodecagon.Gradient.Transparency = NumberSequence.new(0)
Dodecagon.Gradient.Offset       = Vector2.new(0, 0)

-- AutoRotation
Dodecagon.AutoRotation.Enabled = true
Dodecagon.AutoRotation.Amount  = 15
Dodecagon.AutoRotation.Speed   = 1
Dodecagon.AutoRotation.Start   = 0
Dodecagon.AutoRotation.End     = 360
```

---

### NGon

An arbitrary polygon with a configurable number of sides. Shares all the same properties as the fixed polygon shapes, with two additional properties.

| Property | Type    | Default        | Description                                                                           |
|----------|---------|----------------|---------------------------------------------------------------------------------------|
| Points   | number  | `3`            | Number of vertices (whole integer ≥ 3). Increasing this creates new `PointN` entries |
| PointN   | Vector2 | `Vector2.zero` | Local offset for vertex N, where N is `1` through `Points`                            |

> **Note:** Increasing `Points` automatically creates new `PointN` entries initialized to `Vector2.zero`. Decreasing `Points` does not remove old entries — they are simply ignored during rendering.

#### Example — Radius mode

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local NGon = Drawing.new("NGon")
NGon.Points      = 6
NGon.Position    = Center
NGon.Radius      = 80
NGon.Filled      = true
NGon.Rotation    = 0
NGon.Color       = Color3.fromRGB(255, 255, 255)
NGon.Transparency = 1
NGon.ZIndex      = 0
NGon.Visible     = true

-- Outlines
NGon.Outlines.Visible      = true
NGon.Outlines.Color        = Color3.fromRGB(0, 0, 0)
NGon.Outlines.Thickness    = 2
NGon.Outlines.Transparency = 1
NGon.Outlines.ZIndex       = 1

-- Gradient
NGon.Gradient.Enabled      = true
NGon.Gradient.Color        = ColorSequence.new(Color3.fromRGB(180, 80, 255), Color3.fromRGB(80, 180, 255))
NGon.Gradient.Rotation     = 45
NGon.Gradient.Transparency = NumberSequence.new(0)
NGon.Gradient.Offset       = Vector2.new(0, 0)

-- AutoRotation
NGon.AutoRotation.Enabled = true
NGon.AutoRotation.Amount  = 50
NGon.AutoRotation.Speed   = 1
NGon.AutoRotation.Start   = 0
NGon.AutoRotation.End     = 360
```

#### Example — Manual points (arrow shape)

You can skip `Radius` and place each vertex manually using `PointN` properties:

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local NGon = Drawing.new("NGon")
NGon.Points   = 8
NGon.Position = Center

NGon.Point1 = Vector2.new(-80,  -20)
NGon.Point2 = Vector2.new(  0,  -20)
NGon.Point3 = Vector2.new(  0,  -50)
NGon.Point4 = Vector2.new( 80,    0)
NGon.Point5 = Vector2.new(  0,   50)
NGon.Point6 = Vector2.new(  0,   20)
NGon.Point7 = Vector2.new(-80,   20)
NGon.Point8 = Vector2.new(-80,  -20)

NGon.Color   = Color3.fromRGB(255, 220, 60)
NGon.Filled  = true
NGon.Visible = true

NGon.Outlines.Visible   = true
NGon.Outlines.Color     = Color3.fromRGB(200, 150, 0)
NGon.Outlines.Thickness = 2
```

---

## UDim2 Auto-Conversion

The properties `Position`, `Size`, `From`, and `To` all accept either a `Vector2` or a `UDim2`. When you assign a `UDim2`, the library automatically converts it to a `Vector2` using the current viewport resolution.

This means if you read the property back after setting it with a `UDim2`, **you will get a `Vector2`**, not the original `UDim2`. This is expected behaviour.

```luau
local Square = Drawing.new("Square")

Square.Position = UDim2.new(0.5, 0, 0.5, 0) -- center of screen
Square.Size     = UDim2.fromOffset(200, 100)

print(Square.Position) -- Vector2 (e.g. 960, 540 on a 1920x1080 screen)
```

> **Note:** The conversion happens at the moment of assignment. If the screen is resized afterwards, the stored `Vector2` will not update automatically — re-assign the `UDim2` to recalculate.

---

## Target Types

Properties like `Position`, `From`, `To`, and `Size`, as well as functions like `:Trace()` and `Drawing.IsInShape()`, all accept a flexible target type that is automatically resolved to a `Vector2` screen position.

| Type       | Behaviour                                                                                         |
|------------|---------------------------------------------------------------------------------------------------|
| `Vector2`  | Used directly as a screen position                                                                |
| `UDim2`    | Converted to `Vector2` using the current viewport resolution at the time of assignment            |
| `Vector3`  | Projected via `Camera:WorldToViewportPoint` — returns `nil` if off-screen                        |
| `BasePart` | The closest visible surface point of the part is projected to screen                             |
| `Model`    | The closest descendant `BasePart` to screen center is used; final position comes from model pivot |

> **Important:** When a `UDim2` is assigned to any property, it is immediately converted to a `Vector2`. Reading the property back after assigning a `UDim2` will always return a `Vector2`.
