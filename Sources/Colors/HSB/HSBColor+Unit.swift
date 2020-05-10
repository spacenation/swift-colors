import Foundation

public extension HSBColor {
    /// Initializes a new Color struct with the provided HSV color parameters
    ///
    /// - parameter hueUnit: The 360 degrees hue represented as Float from 0.0 to 1.0
    /// - parameter saturationUnit: The saturation represented as Float from 0.0 to 1.0
    /// - parameter brightnessUnit: The brightness represented as Float from 0.0 to 1.0
    /// - returns: `HSVColor` struct
    init(hueUnit: Float, saturationUnit: Float, brightnessUnit: Float) {
        self.hue = UInt8(Float(UInt8.max) * max(0, min(hueUnit, 1)))
        self.saturation = UInt8(Float(UInt8.max) * max(0, min(saturationUnit, 1)))
        self.brightness = UInt8(Float(UInt8.max) * max(0, min(brightnessUnit, 1)))
    }
}

public extension HSBColor {
    var unitHue: Float {
        get { Float(hue) / Float(UInt8.max) }
        set { hue = UInt8(Float(UInt8.max) * max(0, min(newValue, 1))) }
    }
    
    var unitSaturation: Float {
        get { Float(saturation) / Float(UInt8.max) }
        set { saturation = UInt8(Float(UInt8.max) * max(0, min(newValue, 1))) }
    }
    
    var unitBrightness: Float {
        get { Float(brightness) / Float(UInt8.max) }
        set { brightness = UInt8(Float(UInt8.max) * max(0, min(newValue, 1))) }
    }
}
