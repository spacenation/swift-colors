import Foundation

extension HSBColor {
    public init(red: UInt8, green: UInt8, blue: UInt8) {
        var hueDegrees: Float = 0
        var unitSaturation: Float
        var unitBrightness: Float
        
        let unitRed = Float(red) / Float(UInt8.max)
        let unitGreen = Float(green) / Float(UInt8.max)
        let unitBlue = Float(blue) / Float(UInt8.max)
        
        let unitMax = max(unitRed, unitGreen, unitBlue)
        let unitMin = min(unitRed, unitGreen, unitBlue)
        let unitDelta = unitMax - unitMin
        
        if unitMax == 0 || unitMin == 1 {
            unitSaturation = 0
        } else {
            unitSaturation = unitDelta / (1 - abs(unitMax + unitMin - 1))
        }
        
        unitBrightness = (unitMax + unitMin) / 2
        
        if unitDelta == 0 {
            hueDegrees = 0
        } else if unitMax == unitRed {
            hueDegrees = 60 * ((unitGreen - unitBlue) / unitDelta)
        } else if unitMax == unitGreen {
            hueDegrees = 60 * ((unitBlue - unitRed) / unitDelta + 2)
        } else if unitMax == unitBlue {
            hueDegrees = 60 * ((unitRed - unitGreen) / unitDelta + 4)
        }
        
        if hueDegrees < 0 {
            hueDegrees += 360
        }
        
        let unitHue = hueDegrees / 360.0
        
        self.init(hueUnit: unitHue, saturationUnit: unitSaturation, brightnessUnit: unitBrightness)
    }
}
