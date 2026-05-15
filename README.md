# Drawing Library

A Roblox drawing library that renders 2D shapes using ScreenGui elements inside a hidden UI container. Supports lines, squares, circles, and all polygon types from triangle up to dodecagon, plus an arbitrary N-sided polygon.

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
  - [Outlines (Polygons only)](#outlines-polygons-only)
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

---

## Getting Started

```luau
local Drawing = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheRealXORA/Drawing/refs/heads/main/Drawing.luau", true))()

local Circle = Drawing.new("Circle")
Circle.Radius   = 50
Circle.Position = Vector2.new(200, 200)
Circle.Color    = Color3.fromRGB(255, 80, 80)
Circle.Filled   = true
Circle.Visible  = true
```

---

## Drawing.new

```luau
Drawing.new(Shape: string) -> DrawingObject
```

Creates and returns a new drawing object for the given shape name. The name is case-insensitive and strips non-word characters before lookup.

**Valid shape names:**
`line`, `square`, `circle`, `triangle`, `quad`, `pentagon`, `hexagon`, `heptagon`, `octagon`, `nonagon`, `decagon`, `hendecagon`, `dodecagon`, `ngon`

```lua
local Square = Drawing.new("Square")
local Line   = Drawing.new("line")      -- case-insensitive
local NGon   = Drawing.new("NGon")
```

---

## Drawing.IsInShape

```lua
Drawing.IsInShape(Shape: DrawingObject, Target: Vector2 | UDim2 | Vector3 | BasePart | Model, OnScreenCheck: boolean?) -> boolean
```

Returns `true` if `Target` lies within the bounds of `Shape`. Works for all shape types.

| Parameter     | Type                                          | Description                                                       |
|---------------|-----------------------------------------------|-------------------------------------------------------------------|
| Shape         | DrawingObject                                 | A valid drawing object returned by `Drawing.new`                  |
| Target        | Vector2 / UDim2 / Vector3 / BasePart / Model  | The position to test                                              |
| OnScreenCheck | boolean (optional)                            | When `false`, skips the on-screen check for 3D targets            |

```lua
local IsInside = Drawing.IsInShape(Circle, Vector2.new(200, 200))
-- true if the point is inside the circle
```

---

## Shared Properties

Every drawing object inherits these base properties regardless of shape.

| Property     | Type     | Default              | Description                                          |
|--------------|----------|----------------------|------------------------------------------------------|
| Visible      | boolean  | `true`               | Whether the shape is rendered                        |
| Transparency | number   | `1`                  | Opacity from `0` (invisible) to `1` (fully opaque)  |
| Color        | Color3   | `Color3.new(1,1,1)`  | Fill color of the shape                              |
| ZIndex       | number   | `0`                  | Render order; higher values draw on top              |
| AnchorPoint  | Vector2  | `Vector2.one / 2`    | Pivot point for position (0–1 range on each axis)    |

### Shared Methods

| Method                    | Description                                        |
|---------------------------|----------------------------------------------------|
| `:Remove()`               | Destroys the underlying instance and clears the object |
| `:Destroy()`              | Alias for `:Remove()`                              |

---

## Sub-Objects

Sub-objects are nested tables attached to drawing objects. You cannot assign them directly — set their properties individually.

### Stroke

Available on: `Line`, `Square`, `Circle`, and all polygon **Outlines**.

```lua
Shape.Stroke.Color     = Color3.fromRGB(0, 0, 0)
Shape.Stroke.Thickness = 2
Shape.Stroke.Enabled   = true
```

| Property     | Type               | Default                    | Description                             |
|--------------|--------------------|----------------------------|-----------------------------------------|
| Enabled      | boolean            | `true`                     | Whether the stroke is drawn             |
| Color        | Color3             | `Color3.new(1,1,1)`        | Stroke color                            |
| Thickness    | number             | `1`                        | Stroke width in pixels                  |
| LineJoinMode | Enum.LineJoinMode  | `Enum.LineJoinMode.Miter`  | Corner join style                       |
| Gradient     | [Gradient](#gradient) | —                       | Stroke gradient sub-object (read-only handle) |

---

### Gradient

Available on: `Line`, `Square`, `Circle`, polygon fill, polygon `Outlines`, and `Stroke`.

```lua
Shape.Gradient.Enabled    = true
Shape.Gradient.Rotation   = 45
Shape.Gradient.Color      = ColorSequence.new(Color3.fromRGB(255,0,0), Color3.fromRGB(0,0,255))
Shape.Gradient.Offset     = Vector2.new(0, 0)
Shape.Gradient.Transparency = NumberSequence.new(0)
```

| Property     | Type            | Default                                                                 | Description                                     |
|--------------|-----------------|-------------------------------------------------------------------------|-------------------------------------------------|
| Enabled      | boolean         | `false`                                                                 | Whether the gradient is applied                 |
| Color        | ColorSequence   | White → Black → White                                                   | Color gradient across the shape                 |
| Rotation     | number          | `0`                                                                     | Rotation of the gradient in degrees             |
| Transparency | NumberSequence  | `NumberSequence.new(0)`                                                 | Transparency gradient across the shape          |
| Offset       | Vector2         | `Vector2.new(0, 0)`                                                     | Offset of the gradient origin                   |
| AutoRotation | [AutoRotation](#autorotation) | —                                                         | Auto-rotation sub-object (read-only handle)     |

---

### AutoRotation

Available on: `Square`, `Circle`, all polygon shapes, and `Gradient`.

```lua
Shape.AutoRotation.Enabled = true
Shape.AutoRotation.Amount  = 90
Shape.AutoRotation.Speed   = 1
Shape.AutoRotation.Start   = 0
Shape.AutoRotation.End     = 360
```

| Property | Type    | Default | Description                                                        |
|----------|---------|---------|--------------------------------------------------------------------|
| Enabled  | boolean | `false` | Whether auto-rotation is active                                    |
| Amount   | number  | `90`    | Degrees rotated per second (before Speed multiplier)               |
| Speed    | number  | `1`     | Multiplier applied to Amount                                       |
| Start    | number  | `0`     | Minimum rotation bound (degrees)                                   |
| End      | number  | `360`   | Maximum rotation bound (degrees); rotation wraps within this range |

> **Note:** `Line` does not have `AutoRotation`. Its angle is derived from `From` and `To`.

---

### Outlines (Polygons only)

Available on: all polygon shapes (`Triangle`, `Quad`, … `NGon`).

Controls the border lines drawn along each edge of the polygon. Cannot be set directly — set individual properties.

```lua
Shape.Outlines.Visible      = true
Shape.Outlines.Color        = Color3.fromRGB(0, 0, 0)
Shape.Outlines.Thickness    = 2
Shape.Outlines.Transparency = 1
Shape.Outlines.ZIndex       = 1
```

| Property     | Type    | Default             | Description                                    |
|--------------|---------|---------------------|------------------------------------------------|
| Visible      | boolean | `true`              | Whether outline edges are rendered             |
| Transparency | number  | `1`                 | Opacity of the outlines                        |
| Color        | Color3  | `Color3.new(1,1,1)` | Color of the outline edges                     |
| ZIndex       | number  | `0`                 | Render order for outlines                      |
| Thickness    | number  | `1`                 | Width of each outline edge in pixels           |
| Gradient     | [Gradient](#gradient) | —         | Gradient applied to outline edges              |
| Stroke       | [Stroke](#stroke) | —             | Stroke applied to outline edges                |

---

## Shapes

---

### Line

Draws a straight line between two points.

| Property     | Type    | Default         | Description                                |
|--------------|---------|-----------------|--------------------------------------------|
| From         | Vector2 | `Vector2.zero`  | Start point of the line                    |
| To           | Vector2 | `Vector2.zero`  | End point of the line                      |
| Thickness    | number  | `1`             | Width of the line in pixels                |
| Visible      | boolean | `true`          | Inherited from base                        |
| Transparency | number  | `1`             | Inherited from base                        |
| Color        | Color3  | `Color3.new(1,1,1)` | Inherited from base                    |
| ZIndex       | number  | `0`             | Inherited from base                        |
| AnchorPoint  | Vector2 | `Vector2.one/2` | Inherited from base                        |

**Sub-objects:** `Stroke`, `Gradient`, `Rounder`

#### Methods

```lua
Line:Trace(From: Vector2|Vector3|BasePart|Model, To: Vector2|Vector3|BasePart|Model)
```

Automatically updates `From` and `To` by converting 3D targets to screen positions each call. If either target is off-screen the line is hidden automatically.

#### Example

```lua
local Line = Drawing.new("Line")
Line.From      = Vector2.new(100, 100)
Line.To        = Vector2.new(400, 300)
Line.Thickness = 2
Line.Color     = Color3.fromRGB(255, 255, 0)
Line.Visible   = true
```

---

### Square

Draws a rectangle that can be filled or unfilled.

| Property     | Type    | Default             | Description                                           |
|--------------|---------|---------------------|-------------------------------------------------------|
| Position     | Vector2 | `Vector2.zero`      | Position on screen                                    |
| Size         | Vector2 | `Vector2.zero`      | Width and height in pixels                            |
| Filled       | boolean | `true`              | If `false`, only the stroke/outline is drawn          |
| Rotation     | number  | `0`                 | Rotation in degrees                                   |
| Visible      | boolean | `true`              | Inherited from base                                   |
| Transparency | number  | `1`                 | Inherited from base                                   |
| Color        | Color3  | `Color3.new(1,1,1)` | Inherited from base                                   |
| ZIndex       | number  | `0`                 | Inherited from base                                   |
| AnchorPoint  | Vector2 | `Vector2.one/2`     | Inherited from base                                   |

**Sub-objects:** `Stroke`, `Gradient`, `Rounder`, `AutoRotation`

> **Note:** When `Filled` is `false`, `Stroke.Enabled` is forced to `true` automatically so the border is always visible.

#### Example

```lua
local Square = Drawing.new("Square")
Square.Position = Vector2.new(200, 200)
Square.Size     = Vector2.new(150, 100)
Square.Color    = Color3.fromRGB(50, 120, 255)
Square.Filled   = true
Square.Visible  = true
```

---

### Circle

Draws a circle defined by a center position and radius.

| Property     | Type    | Default             | Description                                           |
|--------------|---------|---------------------|-------------------------------------------------------|
| Position     | Vector2 | `Vector2.zero`      | Center of the circle on screen                        |
| Radius       | number  | `0`                 | Radius in pixels                                      |
| Filled       | boolean | `true`              | If `false`, only the stroke/outline is drawn          |
| Rotation     | number  | `0`                 | Rotation in degrees (affects gradient orientation)    |
| Visible      | boolean | `true`              | Inherited from base                                   |
| Transparency | number  | `1`                 | Inherited from base                                   |
| Color        | Color3  | `Color3.new(1,1,1)` | Inherited from base                                   |
| ZIndex       | number  | `0`                 | Inherited from base                                   |
| AnchorPoint  | Vector2 | `Vector2.one/2`     | Inherited from base                                   |

**Sub-objects:** `Stroke`, `Gradient`, `Rounder`, `AutoRotation`

> **Note:** `Stroke.LineJoinMode` is pre-set to `Enum.LineJoinMode.Round` for smooth circle borders.

#### Example

```lua
local Circle = Drawing.new("Circle")
Circle.Position = Vector2.new(300, 300)
Circle.Radius   = 60
Circle.Color    = Color3.fromRGB(255, 80, 80)
Circle.Filled   = true
Circle.Visible  = true
```

---

### Polygon Shapes

The following shapes all share the same property set and work identically. Each shape defines its vertices using named point properties.

**Shapes:** `Triangle`, `Quad`, `Pentagon`, `Hexagon`, `Heptagon`, `Octagon`, `Nonagon`, `Decagon`, `Hendecagon`, `Dodecagon`

| Shape       | Points | Point Properties              |
|-------------|--------|-------------------------------|
| Triangle    | 3      | `PointA`, `PointB`, `PointC`  |
| Quad        | 4      | `PointA` … `PointD`           |
| Pentagon    | 5      | `PointA` … `PointE`           |
| Hexagon     | 6      | `PointA` … `PointF`           |
| Heptagon    | 7      | `PointA` … `PointG`           |
| Octagon     | 8      | `PointA` … `PointH`           |
| Nonagon     | 9      | `PointA` … `PointI`           |
| Decagon     | 10     | `PointA` … `PointJ`           |
| Hendecagon  | 11     | `PointA` … `PointK`           |
| Dodecagon   | 12     | `PointA` … `PointL`           |

#### Shared Polygon Properties

| Property     | Type    | Default             | Description                                                                           |
|--------------|---------|---------------------|---------------------------------------------------------------------------------------|
| Position     | Vector2 | `Vector2.zero`      | Origin offset applied to all points                                                   |
| Filled       | boolean | `true`              | Whether the interior is filled                                                        |
| Radius       | number  | `0`                 | When `> 0`, points are auto-computed around a circle of this radius (ignores PointX)  |
| Rotation     | number  | `0`                 | Rotation in degrees applied around `Position`                                         |
| PointX       | Vector2 | `Vector2.zero`      | Local offset for each vertex (relative to `Position`)                                 |
| Visible      | boolean | `true`              | Inherited from base                                                                   |
| Transparency | number  | `1`                 | Inherited from base                                                                   |
| Color        | Color3  | `Color3.new(1,1,1)` | Inherited from base                                                                   |
| ZIndex       | number  | `0`                 | Inherited from base                                                                   |
| AnchorPoint  | Vector2 | `Vector2.one/2`     | Inherited from base                                                                   |

**Sub-objects:** `Gradient`, `Outlines`, `AutoRotation`

> **Tip:** Setting `Radius > 0` is the easiest way to draw a regular polygon. The points are evenly spaced on a circle of the given radius around `Position`.

---

### Triangle

#### Example

```lua
local Triangle = Drawing.new("Triangle")
Triangle.Position = Vector2.new(300, 300)
Triangle.PointA   = Vector2.new(0, -80)
Triangle.PointB   = Vector2.new(70, 50)
Triangle.PointC   = Vector2.new(-70, 50)
Triangle.Color    = Color3.fromRGB(100, 220, 100)
Triangle.Filled   = true
Triangle.Visible  = true
```

---

### Quad

#### Example

```lua
local Quad = Drawing.new("Quad")
Quad.Position = Vector2.new(300, 300)
Quad.PointA   = Vector2.new(-80, -60)
Quad.PointB   = Vector2.new(80, -60)
Quad.PointC   = Vector2.new(80, 60)
Quad.PointD   = Vector2.new(-80, 60)
Quad.Color    = Color3.fromRGB(255, 160, 0)
Quad.Filled   = true
Quad.Visible  = true
```

---

### Pentagon

#### Example

```lua
local Pentagon = Drawing.new("Pentagon")
Pentagon.Position = Vector2.new(300, 300)
Pentagon.Radius   = 80
Pentagon.Color    = Color3.fromRGB(180, 100, 255)
Pentagon.Filled   = true
Pentagon.Visible  = true
```

---

### Hexagon

#### Example

```lua
local Hexagon = Drawing.new("Hexagon")
Hexagon.Position = Vector2.new(300, 300)
Hexagon.Radius   = 80
Hexagon.Color    = Color3.fromRGB(0, 200, 180)
Hexagon.Filled   = true
Hexagon.Visible  = true
```

---

### Heptagon

#### Example

```lua
local Heptagon = Drawing.new("Heptagon")
Heptagon.Position = Vector2.new(300, 300)
Heptagon.Radius   = 80
Heptagon.Color    = Color3.fromRGB(255, 80, 160)
Heptagon.Filled   = true
Heptagon.Visible  = true
```

---

### Octagon

#### Example

```lua
local Octagon = Drawing.new("Octagon")
Octagon.Position = Vector2.new(300, 300)
Octagon.Radius   = 80
Octagon.Color    = Color3.fromRGB(80, 160, 255)
Octagon.Filled   = true
Octagon.Visible  = true
```

---

### Nonagon

#### Example

```lua
local Nonagon = Drawing.new("Nonagon")
Nonagon.Position = Vector2.new(300, 300)
Nonagon.Radius   = 80
Nonagon.Color    = Color3.fromRGB(255, 200, 50)
Nonagon.Filled   = true
Nonagon.Visible  = true
```

---

### Decagon

#### Example

```lua
local Decagon = Drawing.new("Decagon")
Decagon.Position = Vector2.new(300, 300)
Decagon.Radius   = 80
Decagon.Color    = Color3.fromRGB(50, 255, 120)
Decagon.Filled   = true
Decagon.Visible  = true
```

---

### Hendecagon

#### Example

```lua
local Hendecagon = Drawing.new("Hendecagon")
Hendecagon.Position = Vector2.new(300, 300)
Hendecagon.Radius   = 80
Hendecagon.Color    = Color3.fromRGB(255, 100, 50)
Hendecagon.Filled   = true
Hendecagon.Visible  = true
```

---

### Dodecagon

#### Example

```lua
local Dodecagon = Drawing.new("Dodecagon")
Dodecagon.Position = Vector2.new(300, 300)
Dodecagon.Radius   = 80
Dodecagon.Color    = Color3.fromRGB(150, 255, 200)
Dodecagon.Filled   = true
Dodecagon.Visible  = true
```

---

### NGon

An arbitrary polygon with a configurable number of sides. Extends the shared polygon properties with two extras.

| Property   | Type    | Default  | Description                                                                               |
|------------|---------|----------|-------------------------------------------------------------------------------------------|
| Points     | number  | `3`      | Number of vertices (whole integer ≥ 3). Increasing this adds new `PointN` properties      |
| PointN     | Vector2 | `Vector2.zero` | Local offset for vertex N, where N is `1` through `Points`                          |

All other shared polygon properties and sub-objects apply.

> **Note:** Setting `Points` to a higher value automatically creates the missing `PointN` entries initialized to `Vector2.zero`. Reducing `Points` does not delete the old entries, but they are ignored during rendering.

#### Example

```lua
-- 5-sided NGon using Radius
local NGon = Drawing.new("NGon")
NGon.Points   = 5
NGon.Position = Vector2.new(300, 300)
NGon.Radius   = 80
NGon.Color    = Color3.fromRGB(200, 150, 255)
NGon.Filled   = true
NGon.Visible  = true

-- 5-sided NGon using manual points
local NGon2 = Drawing.new("NGon")
NGon2.Points  = 5
NGon2.Point1  = Vector2.new(0, -80)
NGon2.Point2  = Vector2.new(76, -25)
NGon2.Point3  = Vector2.new(47, 65)
NGon2.Point4  = Vector2.new(-47, 65)
NGon2.Point5  = Vector2.new(-76, -25)
NGon2.Color   = Color3.fromRGB(200, 150, 255)
NGon2.Filled  = true
NGon2.Visible = true
```

---

## Target Types

Several properties and methods accept a flexible target type that is automatically converted to a `Vector2` screen position:

| Type           | Behaviour                                                                 |
|----------------|---------------------------------------------------------------------------|
| `Vector2`      | Used directly as a screen position                                        |
| `UDim2`        | Converted using the current viewport resolution                           |
| `Vector3`      | Projected via `Camera:WorldToViewportPoint`; returns `nil` if off-screen  |
| `BasePart`     | Closest visible surface point projected to screen                         |
| `Model`        | Closest descendant `BasePart` to the screen center, pivot used for final position |
