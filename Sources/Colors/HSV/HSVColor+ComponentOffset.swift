import Foundation

public extension HSVColor {
    func maxComponentOffset(with color: HSVColor) -> UInt8 {
        [self.hue - color.hue, self.saturation - color.saturation, self.value - color.value].max() ?? 0
    }
}
