/// Linear sRGB — sRGB primaries without gamma companding.
public enum LinearSRGB: ColorSpace {
    public struct Components: ColorComponents {
        public var storage: SIMD3<Float>
        @inlinable public init(storage: SIMD3<Float>) { self.storage = storage }

        @inlinable public var r: Float { storage.x }
        @inlinable public var g: Float { storage.y }
        @inlinable public var b: Float { storage.z }
    }

    public static let name = "Linear sRGB"

    @usableFromInline static let toXYZMatrix = Matrix3x3(rows: (
        SIMD3(0.4123907993, 0.3575843394, 0.1804807884),
        SIMD3(0.2126390059, 0.7151686788, 0.0721923154),
        SIMD3(0.0193308187, 0.1191947798, 0.9505321522)
    ))

    @usableFromInline static let fromXYZMatrix = Matrix3x3(rows: (
        SIMD3( 3.2409699419, -1.5373831776, -0.4986107603),
        SIMD3(-0.9692436363,  1.8759675015,  0.0415550574),
        SIMD3( 0.0556300797, -0.2039769589,  1.0569715142)
    ))

    @inlinable
    public static func toXYZ(_ c: Components) -> XYZD65.Components {
        .init(storage: toXYZMatrix * c.storage)
    }

    @inlinable
    public static func fromXYZ(_ xyz: XYZD65.Components) -> Components {
        .init(storage: fromXYZMatrix * xyz.storage)
    }
}
