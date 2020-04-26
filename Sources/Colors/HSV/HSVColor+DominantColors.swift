import Foundation

extension Collection where Element == HSVColor {
    public func dominantColor(saturationRange: ClosedRange<UInt8> = UInt8.min...UInt8.max, valueUnitRange: ClosedRange<UInt8> = UInt8.min...UInt8.max) -> HSVColor? {
        let filteredColors = filter { saturationRange.contains($0.saturation) && valueUnitRange.contains($0.value) }
        let colorBins = Dictionary(grouping: filteredColors) { $0.hue }
        
        guard colorBins.count != 0 else { return nil }
        
        if let dominantBin = colorBins.max(by: { $0.key > $1.key }) {
            let elementsCount: Int = dominantBin.value.count
            let saturationSum: Int = dominantBin.value.reduce(0) { $0 + Int($1.saturation) }
            let valueSum: Int = dominantBin.value.reduce(0) { $0 + Int($1.value) }
            let averageSaturation = UInt8(saturationSum / elementsCount)
            let averageValue = UInt8(valueSum / elementsCount)
            return HSVColor(hue: dominantBin.key, saturation: averageSaturation, value: averageValue)
        } else {
            return nil
        }
    }
}
