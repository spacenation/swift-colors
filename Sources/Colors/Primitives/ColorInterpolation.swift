/// Linear interpolation in OKLab — perceptually uniform blending.
/// Handles hue discontinuities correctly because it operates in
/// Cartesian (a, b) coordinates, not polar (C, h).
extension Color where CS == OKLab {
    /// Interpolate toward another color.
    /// t = 0 returns self, t = 1 returns other.
    @inlinable
    public func interpolated(to other: Color<OKLab>, t: Float) -> Color<OKLab> {
        Color<OKLab>(.init(storage:
            components.storage * (1 - t) + other.components.storage * t
        ))
    }

    /// Generate evenly-spaced colors from self to other (inclusive).
    @inlinable
    public func steps(to other: Color<OKLab>, count: Int) -> [Color<OKLab>] {
        guard count > 1 else { return count == 1 ? [self] : [] }
        let n = Float(count - 1)
        return (0..<count).map { i in
            interpolated(to: other, t: Float(i) / n)
        }
    }
}

/// Generic interpolation — converts both colors to OKLab first.
extension Color {
    /// Interpolate toward another color through OKLab space.
    /// Works between any two color spaces.
    @inlinable
    public func interpolated<Other: ColorSpace>(
        to other: Color<Other>,
        t: Float
    ) -> Color<OKLab> {
        let lab1 = ColorConverter.convert(self, to: OKLab.self)
        let lab2 = ColorConverter.convert(other, to: OKLab.self)
        return lab1.interpolated(to: lab2, t: t)
    }

    /// Generate evenly-spaced colors through OKLab space.
    /// Works between any two color spaces.
    @inlinable
    public func steps<Other: ColorSpace>(
        to other: Color<Other>,
        count: Int
    ) -> [Color<OKLab>] {
        let lab1 = ColorConverter.convert(self, to: OKLab.self)
        let lab2 = ColorConverter.convert(other, to: OKLab.self)
        return lab1.steps(to: lab2, count: count)
    }
}
