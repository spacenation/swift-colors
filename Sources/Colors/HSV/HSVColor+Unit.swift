import Foundation

public extension HSVColor {
    /// Initializes a new Color struct with the provided HSV color parameters
    ///
    /// - parameter hueUnit: The 360 degrees hue represented as Float from 0.0 to 1.0
    /// - parameter saturationUnit: The saturation represented as Float from 0.0 to 1.0
    /// - parameter valueUnit: The value represented as Float from 0.0 to 1.0
    /// - returns: `HSVColor` struct
    init(hueUnit: Float, saturationUnit: Float, valueUnit: Float) {
        self.hue = UInt8(Float(UInt8.max) * max(0, min(hueUnit, 1)))
        self.saturation = UInt8(Float(UInt8.max) * max(0, min(saturationUnit, 1)))
        self.value = UInt8(Float(UInt8.max) * max(0, min(valueUnit, 1)))
    }
}

public extension HSVColor {
    var unitHue: Float {
        get { Float(hue) / Float(UInt8.max) }
        set { hue = UInt8(Float(UInt8.max) * max(0, min(newValue, 1))) }
    }
    
    var unitSaturation: Float {
        get { Float(saturation) / Float(UInt8.max) }
        set { saturation = UInt8(Float(UInt8.max) * max(0, min(newValue, 1))) }
    }
    
    var unitValue: Float {
        get { Float(value) / Float(UInt8.max) }
        set { value = UInt8(Float(UInt8.max) * max(0, min(newValue, 1))) }
    }
}
