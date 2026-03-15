import Foundation

public struct HueColorPayload: Sendable {
    public let x, y: Float
    public let bri: UInt8  // 0–254

    @inlinable
    public init(x: Float, y: Float, bri: UInt8) {
        self.x = x
        self.y = y
        self.bri = bri
    }
}

extension Color where CS == OKLCh {
    /// Produces the Hue API payload, clamped to the specified bulb gamut.
    @inlinable
    public func huePayload(gamut: RGBGamut = .hueGamutC) -> HueColorPayload {
        let clamped = gamut.clamp(components)
        let xyz = OKLCh.toXYZ(clamped)
        let sum = xyz.X + xyz.Y + xyz.Z
        guard sum > 0 else {
            return HueColorPayload(x: 0.3127, y: 0.3290, bri: 0)
        }
        let cx = xyz.X / sum
        let cy = xyz.Y / sum
        let Y = xyz.Y
        let bri: Float = Y <= 0.0031308
            ? 12.92 * Y
            : 1.055 * powf(Y, 1.0 / 2.4) - 0.055
        let briByte = UInt8(Swift.min(Swift.max(bri * 254, 0), 254))
        return HueColorPayload(x: cx, y: cy, bri: briByte)
    }

    /// JSON-ready dictionary for PUT /lights/{id}/state
    public func hueStateDict(gamut: RGBGamut = .hueGamutC) -> [String: Any] {
        let p = huePayload(gamut: gamut)
        return ["xy": [p.x, p.y], "bri": p.bri, "colormode": "xy"]
    }
}
