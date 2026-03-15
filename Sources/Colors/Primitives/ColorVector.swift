import Foundation

// MARK: - Normalized saturation

extension Color where CS == OKLCh {
    /// Normalized saturation S ∈ [0,1] relative to the gamut boundary at this L and h.
    /// S = C / maxChroma(L, h). Returns 0 if no chroma is available.
    @inlinable
    public func saturation(in gamut: RGBGamut) -> Float {
        let maxC = gamut.maxChroma(L: components.L, h: components.h)
        return maxC > 0 ? components.C / maxC : 0
    }
}

// MARK: - Vector operations (OKLCh)

extension Color where CS == OKLCh {
    /// Vector negation in the a-b plane: (a, b) → (-a, -b).
    /// Returns the complementary color — the one that cancels this color to neutral.
    @inlinable
    public func complementary() -> Color<OKLCh> {
        let h = components.h < 180 ? components.h + 180 : components.h - 180
        return Color<OKLCh>(.init(storage: SIMD3(components.L, components.C, h)))
    }

    /// Rotate the hue vector by an angle in degrees.
    @inlinable
    public func rotated(by degrees: Float) -> Color<OKLCh> {
        var h = components.h + degrees
        h = h.truncatingRemainder(dividingBy: 360)
        if h < 0 { h += 360 }
        return Color<OKLCh>(.init(storage: SIMD3(components.L, components.C, h)))
    }

    /// Scale the chroma (vector magnitude) by a factor.
    @inlinable
    public func withChromaScaled(by factor: Float) -> Color<OKLCh> {
        Color<OKLCh>(.init(storage: SIMD3(components.L, components.C * factor, components.h)))
    }

    /// Return a new color with the given lightness, preserving hue and chroma.
    @inlinable
    public func withLightness(_ L: Float) -> Color<OKLCh> {
        Color<OKLCh>(.init(storage: SIMD3(L, components.C, components.h)))
    }

    /// Return a new color with the given chroma, preserving lightness and hue.
    @inlinable
    public func withChroma(_ C: Float) -> Color<OKLCh> {
        Color<OKLCh>(.init(storage: SIMD3(components.L, C, components.h)))
    }

    /// Return a new color with the given hue angle, preserving lightness and chroma.
    @inlinable
    public func withHue(_ h: Float) -> Color<OKLCh> {
        Color<OKLCh>(.init(storage: SIMD3(components.L, components.C, h)))
    }

    /// Angular distance between two hue angles, in degrees (0–180).
    @inlinable
    public static func angularDistance(_ a: Float, _ b: Float) -> Float {
        let d = abs(a - b).truncatingRemainder(dividingBy: 360)
        return Swift.min(d, 360 - d)
    }
}

// MARK: - Vector operations (OKLab)

extension Color where CS == OKLab {
    /// Negate the a-b vector: (L, a, b) → (L, -a, -b).
    /// Returns the opponent color that cancels this one to neutral.
    @inlinable
    public func negated() -> Color<OKLab> {
        Color<OKLab>(.init(storage: SIMD3(components.L, -components.a, -components.b)))
    }
}
