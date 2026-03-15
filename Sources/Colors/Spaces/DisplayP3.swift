import Foundation

/// Display P3 with sRGB transfer function.
public enum DisplayP3: ColorSpace {
    public struct Components: ColorComponents {
        public var storage: SIMD3<Float>
        @inlinable public init(storage: SIMD3<Float>) { self.storage = storage }

        @inlinable public var r: Float { storage.x }
        @inlinable public var g: Float { storage.y }
        @inlinable public var b: Float { storage.z }
    }

    public static let name = "Display P3"

    @usableFromInline static let toXYZMatrix = Matrix3x3(rows: (
        SIMD3(0.4865709486, 0.2656676932, 0.1982172852),
        SIMD3(0.2289745641, 0.6917385218, 0.0792869141),
        SIMD3(0.0000000000, 0.0451133819, 1.0439443689)
    ))

    @usableFromInline static let fromXYZMatrix = Matrix3x3(rows: (
        SIMD3( 2.4934969119, -0.9313836179, -0.4027107845),
        SIMD3(-0.8294889696,  1.7626640603,  0.0236246858),
        SIMD3( 0.0358458302, -0.0761723893,  0.9568845240)
    ))

    @inlinable
    public static func toXYZ(_ c: Components) -> XYZD65.Components {
        let linear = SIMD3<Float>(
            SRGB.gammaToLinear(c.storage.x),
            SRGB.gammaToLinear(c.storage.y),
            SRGB.gammaToLinear(c.storage.z)
        )
        return .init(storage: toXYZMatrix * linear)
    }

    @inlinable
    public static func fromXYZ(_ xyz: XYZD65.Components) -> Components {
        let linear = fromXYZMatrix * xyz.storage
        return .init(storage: SIMD3(
            SRGB.linearToGamma(linear.x),
            SRGB.linearToGamma(linear.y),
            SRGB.linearToGamma(linear.z)
        ))
    }
}
