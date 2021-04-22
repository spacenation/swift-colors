import Foundation

public struct HSBKColor: Hashable, Codable {
    public var hue: UInt16
    public var saturation: UInt16
    public var brightness: UInt16
    public var kelvin: Kelvin
    
    public init(hue: UInt16, saturation: UInt16, brightness: UInt16, kelvin: Kelvin = .neutral) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.kelvin = kelvin
    }
}
