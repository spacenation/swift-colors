/// A gamut defines the boundary of reproducible colors within a color space.
/// User-definable: implement this to describe any device's color volume.
public protocol Gamut: Sendable {
    associatedtype Space: ColorSpace

    /// Returns true if the color is within this gamut
    func contains(_ components: Space.Components) -> Bool

    /// Clamps the color to the nearest in-gamut color
    func clamp(_ components: Space.Components) -> Space.Components

    /// Maps a normalized 0–1 chroma to the maximum chroma at this L and h
    /// (only meaningful for cylindrical spaces like OKLCh)
    func maxChroma(L: Float, h: Float) -> Float
}

public extension Gamut {
    func maxChroma(L: Float, h: Float) -> Float { 1.0 }
}
