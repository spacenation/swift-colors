/// A named rectangular region in the L × S plane that defines color character
/// independent of hue. L is lightness [0,1], S is normalized saturation [0,1]
/// (C / maxChroma at that L and h).
///
/// Because S is gamut-relative, the region maps cleanly onto any gamut —
/// the irregular boundary is absorbed by the normalization.
public struct ToneRegion: Sendable, Equatable {
    public let L: ClosedRange<Float>
    public let S: ClosedRange<Float>

    @inlinable
    public init(L: ClosedRange<Float>, S: ClosedRange<Float>) {
        self.L = L
        self.S = S
    }

    /// The center point of this region.
    @inlinable
    public var center: (L: Float, S: Float) {
        (
            L: (L.lowerBound + L.upperBound) / 2,
            S: (S.lowerBound + S.upperBound) / 2
        )
    }

    /// Check whether an OKLCh color falls within this region.
    @inlinable
    public func contains(_ color: Color<OKLCh>, in gamut: RGBGamut) -> Bool {
        let s = color.saturation(in: gamut)
        return L.contains(color.components.L) && S.contains(s)
    }

    /// Create a color at the center of this region with the given hue.
    @inlinable
    public func color(h: Float, in gamut: RGBGamut) -> Color<OKLCh> {
        let c = center
        return Color<OKLCh>(L: c.L, S: c.S, h: h, gamut: gamut)
    }

    /// Create a color at a specific position within the region.
    /// `lt` and `st` are normalized positions (0 = lower bound, 1 = upper bound).
    @inlinable
    public func color(h: Float, lt: Float = 0.5, st: Float = 0.5, in gamut: RGBGamut) -> Color<OKLCh> {
        let l = L.lowerBound + (L.upperBound - L.lowerBound) * lt
        let s = S.lowerBound + (S.upperBound - S.lowerBound) * st
        return Color<OKLCh>(L: l, S: s, h: h, gamut: gamut)
    }
}

// MARK: - Predefined regions

extension ToneRegion {
    /// Bright and fully saturated — electric, glowing.
    public static let neon   = ToneRegion(L: 0.65...0.80, S: 0.85...1.0)
    /// Rich and saturated at moderate lightness — bold, punchy.
    public static let vivid  = ToneRegion(L: 0.45...0.65, S: 0.80...1.0)
    /// Light and low saturation — soft, airy.
    public static let pastel = ToneRegion(L: 0.75...0.92, S: 0.15...0.45)
    /// Medium saturation and lightness — balanced, warm.
    public static let muted  = ToneRegion(L: 0.45...0.65, S: 0.30...0.60)
    /// Saturated at low lightness — rich, moody.
    public static let deep   = ToneRegion(L: 0.25...0.45, S: 0.70...1.0)
    /// Low saturation and low lightness — subdued, shadowy.
    public static let dark   = ToneRegion(L: 0.15...0.35, S: 0.10...0.45)
    /// Very light, barely tinted — whisper of color.
    public static let light  = ToneRegion(L: 0.85...0.97, S: 0.05...0.25)
}
