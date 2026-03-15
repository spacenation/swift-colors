import Foundation

public enum OKLCh: ColorSpace {
    public struct Components: ColorComponents {
        public var storage: SIMD3<Float>
        @inlinable public init(storage: SIMD3<Float>) { self.storage = storage }

        @inlinable public var L: Float { storage.x }
        @inlinable public var C: Float { storage.y }
        @inlinable public var h: Float { storage.z }  // degrees 0–360
    }

    public static let name = "OKLCh"

    @inlinable
    public static func toXYZ(_ c: Components) -> XYZD65.Components {
        // OKLCh → OKLab → XYZ (two-hop, inlined)
        let hRad = c.h * (.pi / 180)
        let lab = OKLab.Components(storage: SIMD3(
            c.L,
            c.C * cosf(hRad),
            c.C * sinf(hRad)
        ))
        return OKLab.toXYZ(lab)
    }

    @inlinable
    public static func fromXYZ(_ xyz: XYZD65.Components) -> Components {
        let lab = OKLab.fromXYZ(xyz)
        let C = hypotf(lab.a, lab.b)
        let h = atan2f(lab.b, lab.a) * (180 / .pi)
        return .init(storage: SIMD3(lab.L, C, h < 0 ? h + 360 : h))
    }
}
