/// CIE XYZ D65 — the hub space. All conversions route through here.
public enum XYZD65: ColorSpace {
    public struct Components: ColorComponents {
        public var storage: SIMD3<Float>
        @inlinable public init(storage: SIMD3<Float>) { self.storage = storage }

        @inlinable public var X: Float { storage.x }
        @inlinable public var Y: Float { storage.y }
        @inlinable public var Z: Float { storage.z }
    }

    public static let name = "XYZ D65"

    @inlinable
    public static func toXYZ(_ c: Components) -> Components { c }
    @inlinable
    public static func fromXYZ(_ xyz: Components) -> Components { xyz }
}
