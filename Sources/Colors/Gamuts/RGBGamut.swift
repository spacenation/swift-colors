/// A gamut defined by an RGB triangle in CIE xy chromaticity space.
/// Use this for Hue bulbs, display gamuts, or any triangular color volume.
public struct RGBGamut: Gamut, Sendable {
    public typealias Space = OKLCh

    public struct Vertex: Sendable {
        public let x, y: Float
        public init(x: Float, y: Float) {
            self.x = x
            self.y = y
        }
    }

    public let red, green, blue: Vertex

    public init(red: Vertex, green: Vertex, blue: Vertex) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    @inlinable
    public func contains(_ components: OKLCh.Components) -> Bool {
        let xy = Self.xyFromOKLCh(components)
        return Self.triangleContains(point: xy, r: red, g: green, b: blue)
    }

    @inlinable
    public func clamp(_ components: OKLCh.Components) -> OKLCh.Components {
        guard !contains(components) else { return components }
        let xyz = OKLCh.toXYZ(components)
        let xy = Self.xyFromOKLCh(components)
        let clamped = Self.closestOnTriangle(to: xy, r: red, g: green, b: blue)
        return Self.oklchFromXY(clamped, Y: xyz.Y)
    }

    @inlinable
    public func maxChroma(L: Float, h: Float) -> Float {
        // Binary search: 16 iterations → 0.4/65536 precision
        var lo: Float = 0, hi: Float = 0.4
        for _ in 0..<16 {
            let mid = (lo + hi) / 2
            let test = OKLCh.Components(storage: SIMD3(L, mid, h))
            contains(test) ? (lo = mid) : (hi = mid)
        }
        return lo
    }}

// MARK: - Geometry helpers

extension RGBGamut {
    @inlinable
    static func xyFromOKLCh(_ c: OKLCh.Components) -> (x: Float, y: Float) {
        let xyz = OKLCh.toXYZ(c)
        let sum = xyz.X + xyz.Y + xyz.Z
        guard sum > 0 else { return (0.3127, 0.3290) }  // D65 white point
        return (xyz.X / sum, xyz.Y / sum)
    }

    @inlinable
    static func oklchFromXY(_ xy: (x: Float, y: Float), Y: Float) -> OKLCh.Components {
        guard xy.y > 0 else {
            return OKLCh.Components(storage: SIMD3(0, 0, 0))
        }
        // Reconstruct XYZ from xy chromaticity, preserving original luminance
        let X = (xy.x / xy.y) * Y
        let Z = ((1.0 - xy.x - xy.y) / xy.y) * Y
        return OKLCh.fromXYZ(XYZD65.Components(storage: SIMD3(X, Y, Z)))
    }

    @inlinable
    static func triangleContains(
        point: (x: Float, y: Float),
        r: Vertex, g: Vertex, b: Vertex
    ) -> Bool {
        let d1 = edgeCross(point, r, g)
        let d2 = edgeCross(point, g, b)
        let d3 = edgeCross(point, b, r)
        let hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0)
        let hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0)
        return !(hasNeg && hasPos)
    }

    @inlinable
    static func edgeCross(
        _ p: (x: Float, y: Float),
        _ v1: Vertex, _ v2: Vertex
    ) -> Float {
        (p.x - v2.x) * (v1.y - v2.y) - (v1.x - v2.x) * (p.y - v2.y)
    }

    @inlinable
    static func closestOnTriangle(
        to p: (x: Float, y: Float),
        r: Vertex, g: Vertex, b: Vertex
    ) -> (x: Float, y: Float) {
        let edges: [(Vertex, Vertex)] = [(r, g), (g, b), (b, r)]
        var bestDist: Float = .greatestFiniteMagnitude
        var bestPoint: (x: Float, y: Float) = (p.x, p.y)

        for (a, b) in edges {
            let closest = closestOnSegment(p: p, a: a, b: b)
            let dx = closest.x - p.x
            let dy = closest.y - p.y
            let dist = dx * dx + dy * dy
            if dist < bestDist {
                bestDist = dist
                bestPoint = closest
            }
        }

        return bestPoint
    }

    @inlinable
    static func closestOnSegment(
        p: (x: Float, y: Float),
        a: Vertex, b: Vertex
    ) -> (x: Float, y: Float) {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let lenSq = dx * dx + dy * dy
        guard lenSq > 0 else { return (a.x, a.y) }
        let t = ((p.x - a.x) * dx + (p.y - a.y) * dy) / lenSq
        let clamped = Swift.max(0, Swift.min(1, t))
        return (a.x + clamped * dx, a.y + clamped * dy)
    }
}

// MARK: - Built-in gamuts

public extension RGBGamut {
    static let sRGB = RGBGamut(
        red:   .init(x: 0.6400, y: 0.3300),
        green: .init(x: 0.3000, y: 0.6000),
        blue:  .init(x: 0.1500, y: 0.0600)
    )
    static let displayP3 = RGBGamut(
        red:   .init(x: 0.6800, y: 0.3200),
        green: .init(x: 0.2650, y: 0.6900),
        blue:  .init(x: 0.1500, y: 0.0600)
    )
    static let hueGamutC = RGBGamut(
        red:   .init(x: 0.6915, y: 0.3083),
        green: .init(x: 0.1700, y: 0.7000),
        blue:  .init(x: 0.1532, y: 0.0475)
    )
    static let hueGamutB = RGBGamut(
        red:   .init(x: 0.6750, y: 0.3220),
        green: .init(x: 0.4090, y: 0.5180),
        blue:  .init(x: 0.1670, y: 0.0400)
    )
}
