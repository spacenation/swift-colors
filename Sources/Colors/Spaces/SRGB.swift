import Foundation

/// sRGB with standard gamma transfer function (IEC 61966-2-1).
public enum SRGB: ColorSpace {
    public struct Components: ColorComponents {
        public var storage: SIMD3<Float>
        @inlinable public init(storage: SIMD3<Float>) { self.storage = storage }

        @inlinable public var r: Float { storage.x }
        @inlinable public var g: Float { storage.y }
        @inlinable public var b: Float { storage.z }
    }

    public static let name = "sRGB"

    @inlinable
    static func linearToGamma(_ c: Float) -> Float {
        c <= 0.0031308 ? 12.92 * c : 1.055 * powf(c, 1.0 / 2.4) - 0.055
    }

    @inlinable
    static func gammaToLinear(_ c: Float) -> Float {
        c <= 0.04045 ? c / 12.92 : powf((c + 0.055) / 1.055, 2.4)
    }

    @inlinable
    public static func toXYZ(_ c: Components) -> XYZD65.Components {
        let linear = SIMD3<Float>(
            gammaToLinear(c.storage.x),
            gammaToLinear(c.storage.y),
            gammaToLinear(c.storage.z)
        )
        return LinearSRGB.toXYZ(.init(storage: linear))
    }

    @inlinable
    public static func fromXYZ(_ xyz: XYZD65.Components) -> Components {
        let linear = LinearSRGB.fromXYZ(xyz)
        return .init(storage: SIMD3(
            linearToGamma(linear.storage.x),
            linearToGamma(linear.storage.y),
            linearToGamma(linear.storage.z)
        ))
    }
}
