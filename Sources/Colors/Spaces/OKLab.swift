import Foundation

public enum OKLab: ColorSpace {
    public struct Components: ColorComponents {
        public var storage: SIMD3<Float>
        @inlinable public init(storage: SIMD3<Float>) { self.storage = storage }

        @inlinable public var L: Float { storage.x }
        @inlinable public var a: Float { storage.y }
        @inlinable public var b: Float { storage.z }
    }

    public static let name = "OKLab"

    // XYZ → LMS
    @usableFromInline static let m1 = Matrix3x3(rows: (
        SIMD3( 0.8189330101,  0.3618667424, -0.1288597137),
        SIMD3( 0.0329845436,  0.9293118715,  0.0361456387),
        SIMD3( 0.0482003018,  0.2643662691,  0.6338517070)
    ))

    // LMS (cbrt) → Lab
    @usableFromInline static let m2 = Matrix3x3(rows: (
        SIMD3( 0.2104542553,  0.7936177850, -0.0040720468),
        SIMD3( 1.9779984951, -2.4285922050,  0.4505937099),
        SIMD3( 0.0259040371,  0.7827717662, -0.8086757660)
    ))

    // Precomputed inverses for the hot path
    // Lab → LMS (cbrt)
    @usableFromInline static let m2Inv = Matrix3x3(rows: (
        SIMD3( 1.0000000000,  0.3963377774,  0.2158037573),
        SIMD3( 1.0000000000, -0.1055613458, -0.0638541728),
        SIMD3( 1.0000000000, -0.0894841775, -1.2914855480)
    ))

    // LMS → XYZ
    @usableFromInline static let m1Inv = Matrix3x3(rows: (
        SIMD3( 1.2270138511, -0.5577999807,  0.2812561490),
        SIMD3(-0.0405801784,  1.1122568696, -0.0716766787),
        SIMD3(-0.0763812845, -0.4214819784,  1.5861632204)
    ))

    @inlinable
    public static func toXYZ(_ c: Components) -> XYZD65.Components {
        // OKLab → LMS (cube) → LMS (linear) → XYZ
        let lmsCbrt = m2Inv * c.storage
        let lms = lmsCbrt * lmsCbrt * lmsCbrt
        let xyz = m1Inv * lms
        return .init(storage: xyz)
    }

    @inlinable
    public static func fromXYZ(_ xyz: XYZD65.Components) -> Components {
        let lms = m1 * xyz.storage
        // Cube root — element-wise cbrtf handles negative values correctly
        let lmsCbrt = SIMD3<Float>(cbrtf(lms.x), cbrtf(lms.y), cbrtf(lms.z))
        let lab = m2 * lmsCbrt
        return .init(storage: lab)
    }
}
