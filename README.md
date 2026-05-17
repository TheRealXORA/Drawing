# Drawing Library

A Roblox drawing library that renders 2D shapes directly on your screen using real Roblox `GuiObject` instances, parented inside a hidden `ScreenGui`. Every shape is made entirely from `Frame`, `UIStroke`, `UIGradient`, and `UICorner` instances.

The library supports lines, squares, circles, and every regular polygon from a triangle up to a dodecagon, plus a flexible N-sided polygon (`NGon`) for any number of vertices. Every shape shares a common set of base properties and supports sub-objects like `Stroke`, `Gradient`, and `AutoRotation` for more advanced visual effects.

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
  - [Outlines (Polygons only)](#outlines-polygons-only)
- [UDim2 Auto-Conversion](#udim2-auto-conversion)
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

When you are done with a shape, always clean it up to avoid memory leaks:

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
Drawing.IsInShape(Shape: DrawingObject, Target: Vector2 | UDim2 | Vector3 | BasePart | Model, OnScreenCheck: boolean?) -> boolean
```

Returns `true` if the given `Target` position lies within the bounds of `Shape`. Works for all shape types including polygons.

| Parameter     | Type                                         | Description                                            |
|---------------|----------------------------------------------|--------------------------------------------------------|
| Shape         | DrawingObject                                | A valid drawing object returned by `Drawing.new`       |
| Target        | Vector2 / UDim2 / Vector3 / BasePart / Model | The position to test against the shape                 |
| OnScreenCheck | boolean?                                     | When `false`, skips the on-screen check for 3D targets |

**Example 1 — Check if the screen center is inside a circle:**

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Circle = Drawing.new("Circle")
Circle.Position = Center
Circle.Radius   = 80
Circle.Color    = Color3.fromRGB(0, 200, 255)
Circle.Filled   = true
Circle.Visible  = true

local IsInside = Drawing.IsInShape(Circle, Center)
print(IsInside) -- true, the center of the screen is inside the circle
```

**Example 2 — Check if a specific pixel is inside a square:**

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Square = Drawing.new("Square")
Square.Position = Center
Square.Size     = Vector2.new(200, 120)
Square.Color    = Color3.fromRGB(255, 180, 0)
Square.Filled   = true
Square.Visible  = true

local IsInside = Drawing.IsInShape(Square, Center + Vector2.new(50, 20))
print(IsInside) -- true, the point is within the square bounds
```

**Example 3 — Check if a point is inside a triangle:**

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Triangle = Drawing.new("Triangle")
Triangle.Position = Center
Triangle.PointA   = Vector2.new(0, -70)
Triangle.PointB   = Vector2.new(60, 40)
Triangle.PointC   = Vector2.new(-60, 40)
Triangle.Color    = Color3.fromRGB(100, 255, 140)
Triangle.Filled   = true
Triangle.Visible  = true

local IsInside = Drawing.IsInShape(Triangle, Center + Vector2.new(0, 10))
print(IsInside) -- true, the point is inside the triangle
```

**Example 4 — Check using a point offset from center against a hexagon:**

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Hexagon = Drawing.new("Hexagon")
Hexagon.Position = Center
Hexagon.Radius   = 100
Hexagon.Color    = Color3.fromRGB(180, 80, 255)
Hexagon.Filled   = true
Hexagon.Visible  = true

local IsInside = Drawing.IsInShape(Hexagon, Center + Vector2.new(50, 30))
print(IsInside) -- true or false depending on if that offset lands inside the hexagon
```

---

## Shared Properties

Every drawing object inherits these base properties regardless of shape type.

| Property     | Type    | Default             | Description                                        |
|--------------|---------|---------------------|----------------------------------------------------|
| Visible      | boolean | `true`              | Whether the shape is rendered on screen            |
| Transparency | number  | `1`                 | Opacity from `0` (invisible) to `1` (fully opaque) |
| Color        | Color3  | `Color3.new(1,1,1)` | Fill color of the shape                            |
| ZIndex       | number  | `0`                 | Render order — higher values draw on top           |
| AnchorPoint  | Vector2 | `Vector2.one / 2`   | Pivot point for positioning (0–1 range on each axis) |

### Shared Methods

| Method       | Description                                                              |
|--------------|--------------------------------------------------------------------------|
| `:Remove()`  | Destroys the underlying GuiObject instance and clears the drawing object |
| `:Destroy()` | Alias for `:Remove()`                                                    |

---

## Sub-Objects

Sub-objects are special nested tables attached to drawing objects that control extra visual behaviour like borders, gradients, corner rounding, and auto-spinning. **You cannot assign a sub-object directly** — you must set its properties one by one.

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

```luau
Shape.Stroke.Enabled      = true
Shape.Stroke.Color        = Color3.fromRGB(0, 0, 0)
Shape.Stroke.Thickness    = 2
Shape.Stroke.Transparency = 1
Shape.Stroke.LineJoinMode = Enum.LineJoinMode.Round
```

| Property     | Type              | Default                   | Description                                       |
|--------------|-------------------|---------------------------|---------------------------------------------------|
| Enabled      | boolean           | `true`                    | Whether the stroke is drawn                       |
| Color        | Color3            | `Color3.new(1,1,1)`       | Color of the stroke                               |
| Thickness    | number            | `1`                       | Width of the stroke in pixels                     |
| Transparency | number            | `1`                       | Opacity from `0` (invisible) to `1` (fully opaque) |
| LineJoinMode | Enum.LineJoinMode | `Enum.LineJoinMode.Miter` | Corner join style for the stroke                  |
| Gradient     | Gradient          | —                         | Gradient applied to the stroke (read-only handle) |

---

### Gradient

Controls a color or transparency gradient applied across the shape. Available on `Line`, `Square`, `Circle`, polygon fill, polygon `Outlines`, and `Stroke`.

```luau
Shape.Gradient.Enabled      = true
Shape.Gradient.Rotation     = 45
Shape.Gradient.Color        = ColorSequence.new(Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 0, 255))
Shape.Gradient.Transparency = NumberSequence.new(0)
Shape.Gradient.Offset       = Vector2.new(0, 0)
```

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

```luau
Shape.AutoRotation.Enabled = true
Shape.AutoRotation.Amount  = 90
Shape.AutoRotation.Speed   = 1
Shape.AutoRotation.Start   = 0
Shape.AutoRotation.End     = 360
```

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

Controls the corner rounding of the shape via a `UICorner` instance. Available on `Line`, `Square`, and `Circle`. You do not set `Rounder` directly — instead you set its `CornerRadius` property, which is a `UDim`.

```luau
-- Slightly round the corners of a square
Shape.Rounder.CornerRadius = UDim.new(0, 8)

-- Fully round — turns a square into a pill/circle shape
Shape.Rounder.CornerRadius = UDim.new(1, 0)
```

> **Note:** `Circle` already sets `CornerRadius` to `UDim.new(1, 0)` by default to achieve its circular shape. Changing it will distort the circle. For `Line` and `Square`, the default is `UDim.new(0, 0)` (sharp corners).

---

### Outlines (Polygons only)

Available on all polygon shapes (`Triangle`, `Quad`, … `NGon`). Controls the border lines drawn along each edge of the polygon. Cannot be assigned directly — set individual properties.

```luau
Shape.Outlines.Visible      = true
Shape.Outlines.Color        = Color3.fromRGB(0, 0, 0)
Shape.Outlines.Thickness    = 2
Shape.Outlines.Transparency = 1
Shape.Outlines.ZIndex       = 1
```

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

## UDim2 Auto-Conversion

The properties `Position`, `Size`, `From`, and `To` all accept either a `Vector2` **or** a `UDim2`. When you assign a `UDim2`, the library automatically converts it to a `Vector2` using the current viewport resolution before storing it.

This means if you read the property back after setting it with a `UDim2`, **you will get a `Vector2`**, not the original `UDim2` you passed in. This is expected behaviour.

```luau
local Square = Drawing.new("Square")

-- You can set with UDim2 — scale and offset are both supported
Square.Position = UDim2.new(0.5, 0, 0.5, 0) -- center of screen
Square.Size     = UDim2.fromOffset(200, 100)

-- Reading it back will return a Vector2, not a UDim2
print(Square.Position) -- Vector2 (e.g. 960, 540 on a 1920x1080 screen)
```

> **Note:** The conversion happens at the moment of assignment using the viewport size at that time. If the screen is resized afterwards, the stored `Vector2` will not update automatically — re-assign the `UDim2` to recalculate.

---

## Shapes

All examples below use `workspace.CurrentCamera.ViewportSize / 2` to position shapes in the center of the screen.

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

> **Note:** `From` and `To` accept `Vector2` or `UDim2`. When set with a `UDim2`, the value is immediately converted and stored as a `Vector2`. Reading `From` or `To` back will always return a `Vector2`.

**Sub-objects:** `Stroke`, `Gradient`, `Rounder`

#### Methods

```luau
Line:Trace(From: Vector2 | Vector3 | BasePart | Model, To: Vector2 | Vector3 | BasePart | Model)
```

Automatically updates `From` and `To` by converting 3D world targets to screen positions on each call. If either target goes off-screen, the line is hidden automatically and shown again once both targets are visible.

---

#### 1. Basic Line

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Line = Drawing.new("Line")
Line.From      = Center + Vector2.new(-100, 0)
Line.To        = Center + Vector2.new(100, 0)
Line.Thickness = 3
Line.Color     = Color3.fromRGB(255, 255, 255)
Line.Visible   = true
```

#### 2. Line with Stroke

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Line = Drawing.new("Line")
Line.From      = Center + Vector2.new(-100, 0)
Line.To        = Center + Vector2.new(100, 0)
Line.Thickness = 3
Line.Color     = Color3.fromRGB(255, 80, 80)
Line.Visible   = true

Line.Stroke.Enabled      = true
Line.Stroke.Color        = Color3.fromRGB(0, 0, 0)
Line.Stroke.Thickness    = 2
Line.Stroke.Transparency = 1
```

#### 3. Line with Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Line = Drawing.new("Line")
Line.From      = Center + Vector2.new(-100, 0)
Line.To        = Center + Vector2.new(100, 0)
Line.Thickness = 3
Line.Color     = Color3.fromRGB(255, 255, 255)
Line.Visible   = true

Line.Gradient.Enabled  = true
Line.Gradient.Color    = ColorSequence.new(Color3.fromRGB(255, 80, 180), Color3.fromRGB(80, 180, 255))
Line.Gradient.Rotation = 0
```

#### 4. Line with Stroke & Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Line = Drawing.new("Line")
Line.From      = Center + Vector2.new(-100, 0)
Line.To        = Center + Vector2.new(100, 0)
Line.Thickness = 4
Line.Color     = Color3.fromRGB(255, 255, 255)
Line.Visible   = true

Line.Stroke.Enabled      = true
Line.Stroke.Color        = Color3.fromRGB(0, 0, 0)
Line.Stroke.Thickness    = 2
Line.Stroke.Transparency = 1

Line.Gradient.Enabled  = true
Line.Gradient.Color    = ColorSequence.new(Color3.fromRGB(255, 80, 180), Color3.fromRGB(80, 180, 255))
Line.Gradient.Rotation = 0
```

> **Note:** `Line` does not support `AutoRotation`. Its angle is always computed from `From` and `To`.

---

### Square

Draws a rectangle that can be filled or just outlined.

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

> **Note:** When `Filled` is `false`, `Stroke.Enabled` is forced to `true` automatically so the border is always visible.

---

#### 1. Basic Square

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Square = Drawing.new("Square")
Square.Position = Center
Square.Size     = Vector2.new(150, 150)
Square.Color    = Color3.fromRGB(255, 255, 255)
Square.Filled   = true
Square.Visible  = true
```

#### 2. Square with Stroke

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Square = Drawing.new("Square")
Square.Position = Center
Square.Size     = Vector2.new(150, 150)
Square.Color    = Color3.fromRGB(255, 120, 40)
Square.Filled   = true
Square.Visible  = true

Square.Stroke.Enabled      = true
Square.Stroke.Color        = Color3.fromRGB(255, 255, 255)
Square.Stroke.Thickness    = 3
Square.Stroke.Transparency = 1
```

#### 3. Square with Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Square = Drawing.new("Square")
Square.Position = Center
Square.Size     = Vector2.new(150, 150)
Square.Color    = Color3.fromRGB(255, 255, 255)
Square.Filled   = true
Square.Visible  = true

Square.Gradient.Enabled  = true
Square.Gradient.Color    = ColorSequence.new(Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 220, 0))
Square.Gradient.Rotation = 45
```

#### 4. Square with Stroke & Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Square = Drawing.new("Square")
Square.Position = Center
Square.Size     = Vector2.new(150, 150)
Square.Color    = Color3.fromRGB(255, 255, 255)
Square.Filled   = true
Square.Visible  = true

Square.Stroke.Enabled      = true
Square.Stroke.Color        = Color3.fromRGB(255, 255, 255)
Square.Stroke.Thickness    = 3
Square.Stroke.Transparency = 1

Square.Gradient.Enabled  = true
Square.Gradient.Color    = ColorSequence.new(Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 220, 0))
Square.Gradient.Rotation = 45
```

#### 5. Square with AutoRotation

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Square = Drawing.new("Square")
Square.Position = Center
Square.Size     = Vector2.new(150, 150)
Square.Color    = Color3.fromRGB(255, 120, 40)
Square.Filled   = true
Square.Visible  = true

Square.AutoRotation.Enabled = true
Square.AutoRotation.Amount  = 60
Square.AutoRotation.Speed   = 1
```

---

### Circle

Draws a circle defined by a center position and a radius.

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

> **Note:** `Stroke.LineJoinMode` is pre-set to `Enum.LineJoinMode.Round` for smooth circle borders. When `Filled` is `false`, `Stroke.Enabled` is forced to `true` automatically.

---

#### 1. Basic Circle

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Circle = Drawing.new("Circle")
Circle.Position = Center
Circle.Radius   = 80
Circle.Color    = Color3.fromRGB(255, 255, 255)
Circle.Filled   = true
Circle.Visible  = true
```

#### 2. Circle with Stroke

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Circle = Drawing.new("Circle")
Circle.Position = Center
Circle.Radius   = 80
Circle.Color    = Color3.fromRGB(40, 120, 255)
Circle.Filled   = true
Circle.Visible  = true

Circle.Stroke.Enabled      = true
Circle.Stroke.Color        = Color3.fromRGB(255, 255, 255)
Circle.Stroke.Thickness    = 3
Circle.Stroke.Transparency = 1
```

#### 3. Circle with Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Circle = Drawing.new("Circle")
Circle.Position = Center
Circle.Radius   = 80
Circle.Color    = Color3.fromRGB(255, 255, 255)
Circle.Filled   = true
Circle.Visible  = true

Circle.Gradient.Enabled  = true
Circle.Gradient.Color    = ColorSequence.new(Color3.fromRGB(0, 200, 255), Color3.fromRGB(180, 0, 255))
Circle.Gradient.Rotation = 0
```

#### 4. Circle with Stroke & Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Circle = Drawing.new("Circle")
Circle.Position = Center
Circle.Radius   = 80
Circle.Color    = Color3.fromRGB(255, 255, 255)
Circle.Filled   = true
Circle.Visible  = true

Circle.Stroke.Enabled      = true
Circle.Stroke.Color        = Color3.fromRGB(255, 255, 255)
Circle.Stroke.Thickness    = 3
Circle.Stroke.Transparency = 1

Circle.Gradient.Enabled  = true
Circle.Gradient.Color    = ColorSequence.new(Color3.fromRGB(0, 200, 255), Color3.fromRGB(180, 0, 255))
Circle.Gradient.Rotation = 0
```

#### 5. Circle with AutoRotation (spinning gradient)

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Circle = Drawing.new("Circle")
Circle.Position = Center
Circle.Radius   = 80
Circle.Color    = Color3.fromRGB(255, 255, 255)
Circle.Filled   = true
Circle.Visible  = true

Circle.Gradient.Enabled  = true
Circle.Gradient.Color    = ColorSequence.new(Color3.fromRGB(0, 200, 255), Color3.fromRGB(180, 0, 255))
Circle.Gradient.Rotation = 0

Circle.Gradient.AutoRotation.Enabled = true
Circle.Gradient.AutoRotation.Amount  = 120
Circle.Gradient.AutoRotation.Speed   = 1
```

---

### Polygon Shapes

The following shapes all share the same property set and behave identically. Each shape defines its vertices using named point properties (`PointA`, `PointB`, etc.) relative to `Position`.

| Shape      | Sides | Point Properties           |
|------------|-------|----------------------------|
| Triangle   | 3     | `PointA`, `PointB`, `PointC` |
| Quad       | 4     | `PointA` … `PointD`        |
| Pentagon   | 5     | `PointA` … `PointE`        |
| Hexagon    | 6     | `PointA` … `PointF`        |
| Heptagon   | 7     | `PointA` … `PointG`        |
| Octagon    | 8     | `PointA` … `PointH`        |
| Nonagon    | 9     | `PointA` … `PointI`        |
| Decagon    | 10    | `PointA` … `PointJ`        |
| Hendecagon | 11    | `PointA` … `PointK`        |
| Dodecagon  | 12    | `PointA` … `PointL`        |

#### Shared Polygon Properties

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

> **Tip:** Setting `Radius > 0` is the easiest way to draw a regular polygon. All vertices are spaced evenly around `Position` at the given radius, so you don't need to set any `PointX` values manually.

---

### Triangle

#### 1. Basic Triangle

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Triangle = Drawing.new("Triangle")
Triangle.Position = Center
Triangle.PointA   = Vector2.new(0, -80)
Triangle.PointB   = Vector2.new(70, 40)
Triangle.PointC   = Vector2.new(-70, 40)
Triangle.Color    = Color3.fromRGB(255, 255, 255)
Triangle.Filled   = true
Triangle.Visible  = true
```

#### 2. Triangle with Stroke (Outlines)

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Triangle = Drawing.new("Triangle")
Triangle.Position = Center
Triangle.PointA   = Vector2.new(0, -80)
Triangle.PointB   = Vector2.new(70, 40)
Triangle.PointC   = Vector2.new(-70, 40)
Triangle.Color    = Color3.fromRGB(255, 160, 0)
Triangle.Filled   = true
Triangle.Visible  = true

Triangle.Outlines.Visible   = true
Triangle.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Triangle.Outlines.Thickness = 2
```

#### 3. Triangle with Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Triangle = Drawing.new("Triangle")
Triangle.Position = Center
Triangle.PointA   = Vector2.new(0, -80)
Triangle.PointB   = Vector2.new(70, 40)
Triangle.PointC   = Vector2.new(-70, 40)
Triangle.Color    = Color3.fromRGB(255, 255, 255)
Triangle.Filled   = true
Triangle.Visible  = true

Triangle.Gradient.Enabled  = true
Triangle.Gradient.Color    = ColorSequence.new(Color3.fromRGB(0, 255, 120), Color3.fromRGB(0, 80, 255))
Triangle.Gradient.Rotation = 90
```

#### 4. Triangle with Stroke & Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Triangle = Drawing.new("Triangle")
Triangle.Position = Center
Triangle.PointA   = Vector2.new(0, -80)
Triangle.PointB   = Vector2.new(70, 40)
Triangle.PointC   = Vector2.new(-70, 40)
Triangle.Color    = Color3.fromRGB(255, 255, 255)
Triangle.Filled   = true
Triangle.Visible  = true

Triangle.Outlines.Visible   = true
Triangle.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Triangle.Outlines.Thickness = 2

Triangle.Gradient.Enabled  = true
Triangle.Gradient.Color    = ColorSequence.new(Color3.fromRGB(0, 255, 120), Color3.fromRGB(0, 80, 255))
Triangle.Gradient.Rotation = 90
```

#### 5. Triangle with AutoRotation

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Triangle = Drawing.new("Triangle")
Triangle.Position = Center
Triangle.PointA   = Vector2.new(0, -80)
Triangle.PointB   = Vector2.new(70, 40)
Triangle.PointC   = Vector2.new(-70, 40)
Triangle.Color    = Color3.fromRGB(100, 220, 100)
Triangle.Filled   = true
Triangle.Visible  = true

Triangle.AutoRotation.Enabled = true
Triangle.AutoRotation.Amount  = 45
Triangle.AutoRotation.Speed   = 1
```

---

### Quad

#### 1. Basic Quad

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Quad = Drawing.new("Quad")
Quad.Position = Center
Quad.PointA   = Vector2.new(-90, -60)
Quad.PointB   = Vector2.new(90, -60)
Quad.PointC   = Vector2.new(90, 60)
Quad.PointD   = Vector2.new(-90, 60)
Quad.Color    = Color3.fromRGB(255, 255, 255)
Quad.Filled   = true
Quad.Visible  = true
```

#### 2. Quad with Stroke (Outlines)

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Quad = Drawing.new("Quad")
Quad.Position = Center
Quad.PointA   = Vector2.new(-90, -60)
Quad.PointB   = Vector2.new(90, -60)
Quad.PointC   = Vector2.new(90, 60)
Quad.PointD   = Vector2.new(-90, 60)
Quad.Color    = Color3.fromRGB(80, 180, 255)
Quad.Filled   = true
Quad.Visible  = true

Quad.Outlines.Visible   = true
Quad.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Quad.Outlines.Thickness = 2
```

#### 3. Quad with Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Quad = Drawing.new("Quad")
Quad.Position = Center
Quad.PointA   = Vector2.new(-90, -60)
Quad.PointB   = Vector2.new(90, -60)
Quad.PointC   = Vector2.new(90, 60)
Quad.PointD   = Vector2.new(-90, 60)
Quad.Color    = Color3.fromRGB(255, 255, 255)
Quad.Filled   = true
Quad.Visible  = true

Quad.Gradient.Enabled  = true
Quad.Gradient.Color    = ColorSequence.new(Color3.fromRGB(255, 100, 0), Color3.fromRGB(255, 220, 50))
Quad.Gradient.Rotation = 0
```

#### 4. Quad with Stroke & Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Quad = Drawing.new("Quad")
Quad.Position = Center
Quad.PointA   = Vector2.new(-90, -60)
Quad.PointB   = Vector2.new(90, -60)
Quad.PointC   = Vector2.new(90, 60)
Quad.PointD   = Vector2.new(-90, 60)
Quad.Color    = Color3.fromRGB(255, 255, 255)
Quad.Filled   = true
Quad.Visible  = true

Quad.Outlines.Visible   = true
Quad.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Quad.Outlines.Thickness = 2

Quad.Gradient.Enabled  = true
Quad.Gradient.Color    = ColorSequence.new(Color3.fromRGB(255, 100, 0), Color3.fromRGB(255, 220, 50))
Quad.Gradient.Rotation = 0
```

#### 5. Quad with AutoRotation

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Quad = Drawing.new("Quad")
Quad.Position = Center
Quad.PointA   = Vector2.new(-90, -60)
Quad.PointB   = Vector2.new(90, -60)
Quad.PointC   = Vector2.new(90, 60)
Quad.PointD   = Vector2.new(-90, 60)
Quad.Color    = Color3.fromRGB(255, 160, 0)
Quad.Filled   = true
Quad.Visible  = true

Quad.AutoRotation.Enabled = true
Quad.AutoRotation.Amount  = 30
Quad.AutoRotation.Speed   = 1
```

---

### Pentagon

#### 1. Basic Pentagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Pentagon = Drawing.new("Pentagon")
Pentagon.Position = Center
Pentagon.Radius   = 80
Pentagon.Color    = Color3.fromRGB(255, 255, 255)
Pentagon.Filled   = true
Pentagon.Visible  = true
```

#### 2. Pentagon with Stroke (Outlines)

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Pentagon = Drawing.new("Pentagon")
Pentagon.Position = Center
Pentagon.Radius   = 80
Pentagon.Color    = Color3.fromRGB(255, 220, 60)
Pentagon.Filled   = true
Pentagon.Visible  = true

Pentagon.Outlines.Visible   = true
Pentagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Pentagon.Outlines.Thickness = 2
```

#### 3. Pentagon with Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Pentagon = Drawing.new("Pentagon")
Pentagon.Position = Center
Pentagon.Radius   = 80
Pentagon.Color    = Color3.fromRGB(255, 255, 255)
Pentagon.Filled   = true
Pentagon.Visible  = true

Pentagon.Gradient.Enabled  = true
Pentagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(180, 60, 255), Color3.fromRGB(255, 80, 160))
Pentagon.Gradient.Rotation = 45
```

#### 4. Pentagon with Stroke & Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Pentagon = Drawing.new("Pentagon")
Pentagon.Position = Center
Pentagon.Radius   = 80
Pentagon.Color    = Color3.fromRGB(255, 255, 255)
Pentagon.Filled   = true
Pentagon.Visible  = true

Pentagon.Outlines.Visible   = true
Pentagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Pentagon.Outlines.Thickness = 2

Pentagon.Gradient.Enabled  = true
Pentagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(180, 60, 255), Color3.fromRGB(255, 80, 160))
Pentagon.Gradient.Rotation = 45
```

#### 5. Pentagon with AutoRotation

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Pentagon = Drawing.new("Pentagon")
Pentagon.Position = Center
Pentagon.Radius   = 80
Pentagon.Color    = Color3.fromRGB(180, 100, 255)
Pentagon.Filled   = true
Pentagon.Visible  = true

Pentagon.AutoRotation.Enabled = true
Pentagon.AutoRotation.Amount  = 40
Pentagon.AutoRotation.Speed   = 1
```

---

### Hexagon

#### 1. Basic Hexagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Hexagon = Drawing.new("Hexagon")
Hexagon.Position = Center
Hexagon.Radius   = 80
Hexagon.Color    = Color3.fromRGB(255, 255, 255)
Hexagon.Filled   = true
Hexagon.Visible  = true
```

#### 2. Hexagon with Stroke (Outlines)

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Hexagon = Drawing.new("Hexagon")
Hexagon.Position = Center
Hexagon.Radius   = 80
Hexagon.Color    = Color3.fromRGB(0, 200, 180)
Hexagon.Filled   = true
Hexagon.Visible  = true

Hexagon.Outlines.Visible   = true
Hexagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Hexagon.Outlines.Thickness = 2
```

#### 3. Hexagon with Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Hexagon = Drawing.new("Hexagon")
Hexagon.Position = Center
Hexagon.Radius   = 80
Hexagon.Color    = Color3.fromRGB(255, 255, 255)
Hexagon.Filled   = true
Hexagon.Visible  = true

Hexagon.Gradient.Enabled  = true
Hexagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(0, 220, 180), Color3.fromRGB(0, 100, 255))
Hexagon.Gradient.Rotation = 60
```

#### 4. Hexagon with Stroke & Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Hexagon = Drawing.new("Hexagon")
Hexagon.Position = Center
Hexagon.Radius   = 80
Hexagon.Color    = Color3.fromRGB(255, 255, 255)
Hexagon.Filled   = true
Hexagon.Visible  = true

Hexagon.Outlines.Visible   = true
Hexagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Hexagon.Outlines.Thickness = 2

Hexagon.Gradient.Enabled  = true
Hexagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(0, 220, 180), Color3.fromRGB(0, 100, 255))
Hexagon.Gradient.Rotation = 60
```

#### 5. Hexagon with AutoRotation

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Hexagon = Drawing.new("Hexagon")
Hexagon.Position = Center
Hexagon.Radius   = 80
Hexagon.Color    = Color3.fromRGB(0, 200, 180)
Hexagon.Filled   = true
Hexagon.Visible  = true

Hexagon.AutoRotation.Enabled = true
Hexagon.AutoRotation.Amount  = 30
Hexagon.AutoRotation.Speed   = 1
```

---

### Heptagon

#### 1. Basic Heptagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Heptagon = Drawing.new("Heptagon")
Heptagon.Position = Center
Heptagon.Radius   = 80
Heptagon.Color    = Color3.fromRGB(255, 255, 255)
Heptagon.Filled   = true
Heptagon.Visible  = true
```

#### 2. Heptagon with Stroke (Outlines)

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Heptagon = Drawing.new("Heptagon")
Heptagon.Position = Center
Heptagon.Radius   = 80
Heptagon.Color    = Color3.fromRGB(255, 100, 180)
Heptagon.Filled   = true
Heptagon.Visible  = true

Heptagon.Outlines.Visible   = true
Heptagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Heptagon.Outlines.Thickness = 2
```

#### 3. Heptagon with Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Heptagon = Drawing.new("Heptagon")
Heptagon.Position = Center
Heptagon.Radius   = 80
Heptagon.Color    = Color3.fromRGB(255, 255, 255)
Heptagon.Filled   = true
Heptagon.Visible  = true

Heptagon.Gradient.Enabled  = true
Heptagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(255, 0, 120), Color3.fromRGB(255, 180, 0))
Heptagon.Gradient.Rotation = 0
```

#### 4. Heptagon with Stroke & Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Heptagon = Drawing.new("Heptagon")
Heptagon.Position = Center
Heptagon.Radius   = 80
Heptagon.Color    = Color3.fromRGB(255, 255, 255)
Heptagon.Filled   = true
Heptagon.Visible  = true

Heptagon.Outlines.Visible   = true
Heptagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Heptagon.Outlines.Thickness = 2

Heptagon.Gradient.Enabled  = true
Heptagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(255, 0, 120), Color3.fromRGB(255, 180, 0))
Heptagon.Gradient.Rotation = 0
```

#### 5. Heptagon with AutoRotation

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Heptagon = Drawing.new("Heptagon")
Heptagon.Position = Center
Heptagon.Radius   = 80
Heptagon.Color    = Color3.fromRGB(255, 80, 160)
Heptagon.Filled   = true
Heptagon.Visible  = true

Heptagon.AutoRotation.Enabled = true
Heptagon.AutoRotation.Amount  = 35
Heptagon.AutoRotation.Speed   = 1
```

---

### Octagon

#### 1. Basic Octagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Octagon = Drawing.new("Octagon")
Octagon.Position = Center
Octagon.Radius   = 80
Octagon.Color    = Color3.fromRGB(255, 255, 255)
Octagon.Filled   = true
Octagon.Visible  = true
```

#### 2. Octagon with Stroke (Outlines)

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Octagon = Drawing.new("Octagon")
Octagon.Position = Center
Octagon.Radius   = 80
Octagon.Color    = Color3.fromRGB(60, 140, 255)
Octagon.Filled   = true
Octagon.Visible  = true

Octagon.Outlines.Visible   = true
Octagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Octagon.Outlines.Thickness = 2
```

#### 3. Octagon with Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Octagon = Drawing.new("Octagon")
Octagon.Position = Center
Octagon.Radius   = 80
Octagon.Color    = Color3.fromRGB(255, 255, 255)
Octagon.Filled   = true
Octagon.Visible  = true

Octagon.Gradient.Enabled  = true
Octagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(0, 120, 255), Color3.fromRGB(80, 255, 200))
Octagon.Gradient.Rotation = 0
```

#### 4. Octagon with Stroke & Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Octagon = Drawing.new("Octagon")
Octagon.Position = Center
Octagon.Radius   = 80
Octagon.Color    = Color3.fromRGB(255, 255, 255)
Octagon.Filled   = true
Octagon.Visible  = true

Octagon.Outlines.Visible   = true
Octagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Octagon.Outlines.Thickness = 2

Octagon.Gradient.Enabled  = true
Octagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(0, 120, 255), Color3.fromRGB(80, 255, 200))
Octagon.Gradient.Rotation = 0
```

#### 5. Octagon with AutoRotation

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Octagon = Drawing.new("Octagon")
Octagon.Position = Center
Octagon.Radius   = 80
Octagon.Color    = Color3.fromRGB(80, 160, 255)
Octagon.Filled   = true
Octagon.Visible  = true

Octagon.AutoRotation.Enabled = true
Octagon.AutoRotation.Amount  = 25
Octagon.AutoRotation.Speed   = 1
```

---

### Nonagon

#### 1. Basic Nonagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Nonagon = Drawing.new("Nonagon")
Nonagon.Position = Center
Nonagon.Radius   = 80
Nonagon.Color    = Color3.fromRGB(255, 255, 255)
Nonagon.Filled   = true
Nonagon.Visible  = true
```

#### 2. Nonagon with Stroke (Outlines)

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Nonagon = Drawing.new("Nonagon")
Nonagon.Position = Center
Nonagon.Radius   = 80
Nonagon.Color    = Color3.fromRGB(255, 200, 50)
Nonagon.Filled   = true
Nonagon.Visible  = true

Nonagon.Outlines.Visible   = true
Nonagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Nonagon.Outlines.Thickness = 2
```

#### 3. Nonagon with Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Nonagon = Drawing.new("Nonagon")
Nonagon.Position = Center
Nonagon.Radius   = 80
Nonagon.Color    = Color3.fromRGB(255, 255, 255)
Nonagon.Filled   = true
Nonagon.Visible  = true

Nonagon.Gradient.Enabled  = true
Nonagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(255, 220, 0), Color3.fromRGB(255, 100, 0))
Nonagon.Gradient.Rotation = 90
```

#### 4. Nonagon with Stroke & Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Nonagon = Drawing.new("Nonagon")
Nonagon.Position = Center
Nonagon.Radius   = 80
Nonagon.Color    = Color3.fromRGB(255, 255, 255)
Nonagon.Filled   = true
Nonagon.Visible  = true

Nonagon.Outlines.Visible   = true
Nonagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Nonagon.Outlines.Thickness = 2

Nonagon.Gradient.Enabled  = true
Nonagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(255, 220, 0), Color3.fromRGB(255, 100, 0))
Nonagon.Gradient.Rotation = 90
```

#### 5. Nonagon with AutoRotation

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Nonagon = Drawing.new("Nonagon")
Nonagon.Position = Center
Nonagon.Radius   = 80
Nonagon.Color    = Color3.fromRGB(255, 200, 50)
Nonagon.Filled   = true
Nonagon.Visible  = true

Nonagon.AutoRotation.Enabled = true
Nonagon.AutoRotation.Amount  = 25
Nonagon.AutoRotation.Speed   = 1
```

---

### Decagon

#### 1. Basic Decagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Decagon = Drawing.new("Decagon")
Decagon.Position = Center
Decagon.Radius   = 80
Decagon.Color    = Color3.fromRGB(255, 255, 255)
Decagon.Filled   = true
Decagon.Visible  = true
```

#### 2. Decagon with Stroke (Outlines)

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Decagon = Drawing.new("Decagon")
Decagon.Position = Center
Decagon.Radius   = 80
Decagon.Color    = Color3.fromRGB(30, 200, 90)
Decagon.Filled   = true
Decagon.Visible  = true

Decagon.Outlines.Visible   = true
Decagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Decagon.Outlines.Thickness = 2
```

#### 3. Decagon with Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Decagon = Drawing.new("Decagon")
Decagon.Position = Center
Decagon.Radius   = 80
Decagon.Color    = Color3.fromRGB(255, 255, 255)
Decagon.Filled   = true
Decagon.Visible  = true

Decagon.Gradient.Enabled  = true
Decagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(0, 255, 100), Color3.fromRGB(0, 180, 80))
Decagon.Gradient.Rotation = 0
```

#### 4. Decagon with Stroke & Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Decagon = Drawing.new("Decagon")
Decagon.Position = Center
Decagon.Radius   = 80
Decagon.Color    = Color3.fromRGB(255, 255, 255)
Decagon.Filled   = true
Decagon.Visible  = true

Decagon.Outlines.Visible   = true
Decagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Decagon.Outlines.Thickness = 2

Decagon.Gradient.Enabled  = true
Decagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(0, 255, 100), Color3.fromRGB(0, 180, 80))
Decagon.Gradient.Rotation = 0
```

#### 5. Decagon with AutoRotation

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Decagon = Drawing.new("Decagon")
Decagon.Position = Center
Decagon.Radius   = 80
Decagon.Color    = Color3.fromRGB(50, 255, 120)
Decagon.Filled   = true
Decagon.Visible  = true

Decagon.AutoRotation.Enabled = true
Decagon.AutoRotation.Amount  = 20
Decagon.AutoRotation.Speed   = 1
```

---

### Hendecagon

#### 1. Basic Hendecagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Hendecagon = Drawing.new("Hendecagon")
Hendecagon.Position = Center
Hendecagon.Radius   = 80
Hendecagon.Color    = Color3.fromRGB(255, 255, 255)
Hendecagon.Filled   = true
Hendecagon.Visible  = true
```

#### 2. Hendecagon with Stroke (Outlines)

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Hendecagon = Drawing.new("Hendecagon")
Hendecagon.Position = Center
Hendecagon.Radius   = 80
Hendecagon.Color    = Color3.fromRGB(220, 80, 30)
Hendecagon.Filled   = true
Hendecagon.Visible  = true

Hendecagon.Outlines.Visible   = true
Hendecagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Hendecagon.Outlines.Thickness = 2
```

#### 3. Hendecagon with Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Hendecagon = Drawing.new("Hendecagon")
Hendecagon.Position = Center
Hendecagon.Radius   = 80
Hendecagon.Color    = Color3.fromRGB(255, 255, 255)
Hendecagon.Filled   = true
Hendecagon.Visible  = true

Hendecagon.Gradient.Enabled  = true
Hendecagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(255, 80, 0), Color3.fromRGB(255, 200, 50))
Hendecagon.Gradient.Rotation = 45
```

#### 4. Hendecagon with Stroke & Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Hendecagon = Drawing.new("Hendecagon")
Hendecagon.Position = Center
Hendecagon.Radius   = 80
Hendecagon.Color    = Color3.fromRGB(255, 255, 255)
Hendecagon.Filled   = true
Hendecagon.Visible  = true

Hendecagon.Outlines.Visible   = true
Hendecagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Hendecagon.Outlines.Thickness = 2

Hendecagon.Gradient.Enabled  = true
Hendecagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(255, 80, 0), Color3.fromRGB(255, 200, 50))
Hendecagon.Gradient.Rotation = 45
```

#### 5. Hendecagon with AutoRotation

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Hendecagon = Drawing.new("Hendecagon")
Hendecagon.Position = Center
Hendecagon.Radius   = 80
Hendecagon.Color    = Color3.fromRGB(255, 100, 50)
Hendecagon.Filled   = true
Hendecagon.Visible  = true

Hendecagon.AutoRotation.Enabled = true
Hendecagon.AutoRotation.Amount  = 18
Hendecagon.AutoRotation.Speed   = 1
```

---

### Dodecagon

#### 1. Basic Dodecagon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Dodecagon = Drawing.new("Dodecagon")
Dodecagon.Position = Center
Dodecagon.Radius   = 80
Dodecagon.Color    = Color3.fromRGB(255, 255, 255)
Dodecagon.Filled   = true
Dodecagon.Visible  = true
```

#### 2. Dodecagon with Stroke (Outlines)

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Dodecagon = Drawing.new("Dodecagon")
Dodecagon.Position = Center
Dodecagon.Radius   = 80
Dodecagon.Color    = Color3.fromRGB(100, 220, 180)
Dodecagon.Filled   = true
Dodecagon.Visible  = true

Dodecagon.Outlines.Visible   = true
Dodecagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Dodecagon.Outlines.Thickness = 2
```

#### 3. Dodecagon with Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Dodecagon = Drawing.new("Dodecagon")
Dodecagon.Position = Center
Dodecagon.Radius   = 80
Dodecagon.Color    = Color3.fromRGB(255, 255, 255)
Dodecagon.Filled   = true
Dodecagon.Visible  = true

Dodecagon.Gradient.Enabled  = true
Dodecagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(100, 255, 200), Color3.fromRGB(0, 180, 140))
Dodecagon.Gradient.Rotation = 0
```

#### 4. Dodecagon with Stroke & Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Dodecagon = Drawing.new("Dodecagon")
Dodecagon.Position = Center
Dodecagon.Radius   = 80
Dodecagon.Color    = Color3.fromRGB(255, 255, 255)
Dodecagon.Filled   = true
Dodecagon.Visible  = true

Dodecagon.Outlines.Visible   = true
Dodecagon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
Dodecagon.Outlines.Thickness = 2

Dodecagon.Gradient.Enabled  = true
Dodecagon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(100, 255, 200), Color3.fromRGB(0, 180, 140))
Dodecagon.Gradient.Rotation = 0
```

#### 5. Dodecagon with AutoRotation

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local Dodecagon = Drawing.new("Dodecagon")
Dodecagon.Position = Center
Dodecagon.Radius   = 80
Dodecagon.Color    = Color3.fromRGB(150, 255, 200)
Dodecagon.Filled   = true
Dodecagon.Visible  = true

Dodecagon.AutoRotation.Enabled = true
Dodecagon.AutoRotation.Amount  = 15
Dodecagon.AutoRotation.Speed   = 1
```

---

### NGon

An arbitrary polygon with a configurable number of sides. Shares all the same properties as the fixed polygon shapes, with two additional properties specific to it.

| Property | Type    | Default        | Description                                                                           |
|----------|---------|----------------|---------------------------------------------------------------------------------------|
| Points   | number  | `3`            | Number of vertices (whole integer ≥ 3). Increasing this creates new `PointN` entries |
| PointN   | Vector2 | `Vector2.zero` | Local offset for vertex N, where N is `1` through `Points`                            |

All shared polygon properties and sub-objects apply.

> **Note:** Increasing `Points` automatically creates the new `PointN` entries initialized to `Vector2.zero`. Decreasing `Points` does not remove old entries — they are simply ignored during rendering.

---

#### 1. Basic NGon

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local NGon = Drawing.new("NGon")
NGon.Points   = 6
NGon.Position = Center
NGon.Radius   = 80
NGon.Color    = Color3.fromRGB(255, 255, 255)
NGon.Filled   = true
NGon.Visible  = true
```

#### 2. NGon with Stroke (Outlines)

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local NGon = Drawing.new("NGon")
NGon.Points   = 6
NGon.Position = Center
NGon.Radius   = 80
NGon.Color    = Color3.fromRGB(200, 150, 255)
NGon.Filled   = true
NGon.Visible  = true

NGon.Outlines.Visible   = true
NGon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
NGon.Outlines.Thickness = 2
```

#### 3. NGon with Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local NGon = Drawing.new("NGon")
NGon.Points   = 6
NGon.Position = Center
NGon.Radius   = 80
NGon.Color    = Color3.fromRGB(255, 255, 255)
NGon.Filled   = true
NGon.Visible  = true

NGon.Gradient.Enabled  = true
NGon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(180, 80, 255), Color3.fromRGB(80, 180, 255))
NGon.Gradient.Rotation = 45
```

#### 4. NGon with Stroke & Gradient

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local NGon = Drawing.new("NGon")
NGon.Points   = 6
NGon.Position = Center
NGon.Radius   = 80
NGon.Color    = Color3.fromRGB(255, 255, 255)
NGon.Filled   = true
NGon.Visible  = true

NGon.Outlines.Visible   = true
NGon.Outlines.Color     = Color3.fromRGB(255, 255, 255)
NGon.Outlines.Thickness = 2

NGon.Gradient.Enabled  = true
NGon.Gradient.Color    = ColorSequence.new(Color3.fromRGB(180, 80, 255), Color3.fromRGB(80, 180, 255))
NGon.Gradient.Rotation = 45
```

#### 5. NGon with AutoRotation

```luau
local Center = workspace.CurrentCamera.ViewportSize / 2

local NGon = Drawing.new("NGon")
NGon.Points   = 6
NGon.Position = Center
NGon.Radius   = 80
NGon.Color    = Color3.fromRGB(200, 150, 255)
NGon.Filled   = true
NGon.Visible  = true

NGon.AutoRotation.Enabled = true
NGon.AutoRotation.Amount  = 50
NGon.AutoRotation.Speed   = 1
```

#### Custom Manual Points Example

You can skip `Radius` and place each vertex manually using `PointN` properties. This example creates an arrow shape with 8 points:

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

## Target Types

Properties like `Position`, `From`, `To`, and `Size`, as well as functions like `:Trace()` and `Drawing.IsInShape()`, all accept a flexible target type that is automatically resolved to a `Vector2` screen position.

| Type       | Behaviour                                                                                         |
|------------|---------------------------------------------------------------------------------------------------|
| `Vector2`  | Used directly as a screen position                                                                |
| `UDim2`    | Converted to `Vector2` using the current viewport resolution at the time of assignment            |
| `Vector3`  | Projected via `Camera:WorldToViewportPoint` — returns `nil` if off-screen                        |
| `BasePart` | The closest visible surface point of the part is projected to screen                             |
| `Model`    | The closest descendant `BasePart` to screen center is used; final position comes from model pivot |

> **Important:** When a `UDim2` is assigned to any property, it is immediately converted to a `Vector2` and that is what gets stored. Reading the property back after assigning a `UDim2` will always return a `Vector2`.
