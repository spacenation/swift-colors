import Foundation

/// HSB (Hue–Saturation–Brightness), also known as HSV.
/// H ∈ [0, 360°], S ∈ [0, 1], B ∈ [0, 1].
public enum HSB: ColorSpace {
    public struct Components: ColorComponents {
        public var storage: SIMD3<Float>
        @inlinable public init(storage: SIMD3<Float>) { self.storage = storage }

        @inlinable public var h: Float { storage.x }  // degrees 0–360
        @inlinable public var s: Float { storage.y }
        @inlinable public var b: Float { storage.z }
    }

    public static let name = "HSB"

    @inlinable
    public static func toXYZ(_ c: Components) -> XYZD65.Components {
        SRGB.toXYZ(toSRGB(c))
    }

    @inlinable
    public static func fromXYZ(_ xyz: XYZD65.Components) -> Components {
        fromSRGB(SRGB.fromXYZ(xyz))
    }

    // MARK: - HSB ↔ sRGB

    @inlinable
    static func toSRGB(_ c: Components) -> SRGB.Components {
        let s = c.s
        let b = c.b
        guard s > 0 else { return .init(storage: SIMD3(b, b, b)) }

        let h6 = (c.h.truncatingRemainder(dividingBy: 360)) / 60
        let sector = Int(h6)
        let f = h6 - Float(sector)
        let p = b * (1 - s)
        let q = b * (1 - s * f)
        let t = b * (1 - s * (1 - f))

        let r: Float, g: Float, bl: Float
        switch sector % 6 {
        case 0: r = b; g = t; bl = p
        case 1: r = q; g = b; bl = p
        case 2: r = p; g = b; bl = t
        case 3: r = p; g = q; bl = b
        case 4: r = t; g = p; bl = b
        default: r = b; g = p; bl = q
        }
        return .init(storage: SIMD3(r, g, bl))
    }

    @inlinable
    static func fromSRGB(_ c: SRGB.Components) -> Components {
        let r = c.r, g = c.g, b = c.b
        let maxC = max(r, g, b)
        let minC = min(r, g, b)
        let delta = maxC - minC

        let brightness = maxC
        let saturation: Float = maxC > 0 ? delta / maxC : 0

        var hue: Float = 0
        if delta > 0 {
            if maxC == r {
                hue = 60 * ((g - b) / delta).truncatingRemainder(dividingBy: 6)
            } else if maxC == g {
                hue = 60 * ((b - r) / delta + 2)
            } else {
                hue = 60 * ((r - g) / delta + 4)
            }
            if hue < 0 { hue += 360 }
        }
        return .init(storage: SIMD3(hue, saturation, brightness))
    }
}
