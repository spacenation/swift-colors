import Foundation

extension Collection where Element == HSBColor {
    public func dominantColor(saturationRange: ClosedRange<UInt8> = UInt8.min...UInt8.max, brightnessRange: ClosedRange<UInt8> = UInt8.min...UInt8.max) -> HSBColor? {
        let filteredColors = filter { saturationRange.contains($0.saturation) && brightnessRange.contains($0.brightness) }
        let colorBins = Dictionary(grouping: filteredColors) { $0.hue }
        
        guard colorBins.count != 0 else { return nil }
        
        if let dominantBin = colorBins.max(by: { $0.value.count < $1.value.count }) {
            let elementsCount: Int = dominantBin.value.count
            let saturationSum: Int = dominantBin.value.reduce(0) { $0 + Int($1.saturation) }
            let brightnessSum: Int = dominantBin.value.reduce(0) { $0 + Int($1.brightness) }
            let averageSaturation = UInt8(saturationSum / elementsCount)
            let averageBrightness = UInt8(brightnessSum / elementsCount)
            return HSBColor(hue: dominantBin.key, saturation: averageSaturation, brightness: averageBrightness)
        } else {
            return nil
        }
    }
}
