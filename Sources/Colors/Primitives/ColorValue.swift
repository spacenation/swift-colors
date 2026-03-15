/// A type-safe color in a specific color space.
/// Zero overhead — the generic parameter is erased at runtime,
/// but the compiler uses it to enforce conversion correctness.
@frozen
public struct Color<CS: ColorSpace>: Equatable, Hashable, Codable, Sendable {
    public var components: CS.Components

    @inlinable
    public init(_ components: CS.Components) {
        self.components = components
    }
}

// MARK: - HSB convenience initializer

extension Color where CS == HSB {
    @inlinable
    public init(h: Float, s: Float, b: Float) {
        self.init(HSB.Components(storage: SIMD3(h, s, b)))
    }
}

// MARK: - OKLCh convenience initializers

extension Color where CS == OKLCh {
    @inlinable
    public init(L: Float, C: Float, h: Float) {
        self.init(OKLCh.Components(storage: SIMD3(L, C, h)))
    }

    /// Normalized saturation API: S ∈ [0,1] instead of raw chroma
    @inlinable
    public init<G: Gamut>(L: Float, S: Float, h: Float, gamut: G)
        where G.Space == OKLCh
    {
        let C = S * gamut.maxChroma(L: L, h: h)
        self.init(L: L, C: C, h: h)
    }
}
