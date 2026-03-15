import Foundation

/// Static, zero-allocation conversion between any two color spaces.
/// All paths go through XYZ D65. For direct neighbors (e.g. OKLCh↔OKLab),
/// specializations short-circuit the hub for one less matrix multiply.
public enum ColorConverter {

    @inlinable
    public static func convert<From: ColorSpace, To: ColorSpace>(
        _ color: Color<From>,
        to: To.Type = To.self
    ) -> Color<To> {
        let xyz = From.toXYZ(color.components)
        let dest = To.fromXYZ(xyz)
        return Color<To>(dest)
    }

    // Specialization: skip XYZ for OKLCh → OKLab
    @inlinable
    public static func convert(
        _ color: Color<OKLCh>,
        to _: OKLab.Type
    ) -> Color<OKLab> {
        let hRad = color.components.h * (.pi / 180)
        return Color<OKLab>(.init(storage: SIMD3(
            color.components.L,
            color.components.C * cosf(hRad),
            color.components.C * sinf(hRad)
        )))
    }

    // Specialization: skip XYZ for OKLab → OKLCh
    @inlinable
    public static func convert(
        _ color: Color<OKLab>,
        to _: OKLCh.Type
    ) -> Color<OKLCh> {
        let C = hypotf(color.components.a, color.components.b)
        let h = atan2f(color.components.b, color.components.a) * (180 / .pi)
        return Color<OKLCh>(.init(storage: SIMD3(
            color.components.L,
            C,
            h < 0 ? h + 360 : h
        )))
    }

    // Specialization: skip XYZ for HSB → sRGB
    @inlinable
    public static func convert(
        _ color: Color<HSB>,
        to _: SRGB.Type
    ) -> Color<SRGB> {
        Color<SRGB>(HSB.toSRGB(color.components))
    }

    // Specialization: skip XYZ for sRGB → HSB
    @inlinable
    public static func convert(
        _ color: Color<SRGB>,
        to _: HSB.Type
    ) -> Color<HSB> {
        Color<HSB>(HSB.fromSRGB(color.components))
    }
}

// MARK: - Ergonomic extension on Color

extension Color {
    @inlinable
    public func converted<To: ColorSpace>(to: To.Type) -> Color<To> {
        ColorConverter.convert(self, to: To.self)
    }
}
