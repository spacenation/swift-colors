import Foundation

public struct Color: Codable, Equatable {
    public var hue: Double
    public var saturation: Double
    public var brightness: Double
    
    /// Initializes a new Color struct with the provided HSB color parameters
    ///
    /// - parameter hue: The 360 degrees hue value represented as Double from 0.0 to 1.0
    /// - parameter saturation: The saturation value represented as Double from 0.0 to 1.0
    /// - parameter brightness: The brightness value represented as Double from 0.0 to 1.0
    /// - returns: Color struct with default alpha value of 1.0
    public init(hue: Double, saturation: Double, brightness: Double) {
        self.hue = max(0, min(hue, 1))
        self.saturation = max(0, min(saturation, 1))
        self.brightness = max(0, min(brightness, 1))
    }
    
    public init(hue: Hue, saturation: Double, brightness: Double) {
        self.init(hue: hue.value, saturation: saturation, brightness: brightness)
    }

    /// Initializes a new Color struct with the provided RGBA color parameters
    ///
    /// - parameter red: Red component value represented as Double from 0.0 to 1.0
    /// - parameter green: Green component represented as Double from 0.0 to 1.0
    /// - parameter blue: Blue component  value represented as Double from 0.0 to 1.0
    /// - returns: Color struct
    public init(red: Double, green: Double, blue: Double) {
        var hue: Double
        var saturation: Double
        var brightness: Double

        let minRGB: Double = min(red, min(green, blue))
        let maxRGB: Double = max(red, max(green, blue))

        if minRGB == maxRGB {
            hue = 0
            saturation = 0
            brightness = minRGB
        } else {
            let dValue: Double = (red == minRGB) ? green - blue : ((blue == minRGB) ? red - green : blue - red)
            let interimHue: Double = (red == minRGB) ? 3 : ((blue == minRGB) ? 1 : 5)
            hue = (interimHue - dValue / (maxRGB - minRGB)) / 6.0
            saturation = (maxRGB - minRGB) / maxRGB
            brightness = maxRGB
        }

        self.init(hue: hue, saturation: saturation, brightness: brightness)
    }
}
