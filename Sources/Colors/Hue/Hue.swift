import Foundation

//ExpressibleByFloatLiteral
public struct Hue: Equatable, ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    
    public var value: Double
    
    public init(floatLiteral value: Self.FloatLiteralType) {
        self.value = value
    }
}

public extension Hue {
    static let red: Hue = 0.0
    static let redOrange: Hue = .init(floatLiteral: 15.0 / 360.0)
    static let orange: Hue = .init(floatLiteral: 30.0 / 360.0)
    static let orangeYellow: Hue = .init(floatLiteral: 45.0 / 360.0)
    
    static let yellow: Hue = .init(floatLiteral: 60.0 / 360.0)
    static let yellowChartreuse: Hue = .init(floatLiteral: 75.0 / 360.0)
    static let chartreuse: Hue = .init(floatLiteral: 90.0 / 360.0)
    static let chartreuseGreen: Hue = .init(floatLiteral: 105.0 / 360.0)
    
    static let green: Hue = .init(floatLiteral: 120.0 / 360.0)
    static let greenAquamarine: Hue = .init(floatLiteral: 135.0 / 360.0)
    static let aquamarine: Hue = .init(floatLiteral: 150.0 / 360.0)
    static let aquamarineCyan: Hue = .init(floatLiteral: 165.0 / 360.0)
    
    static let cyan: Hue = .init(floatLiteral: 180.0 / 360.0)
    static let cyanAzure: Hue = .init(floatLiteral: 195.0 / 360.0)
    static let azure: Hue = .init(floatLiteral: 210.0 / 360.0)
    static let azureBlue: Hue = .init(floatLiteral: 225.0 / 360.0)
    
    static let blue: Hue = .init(floatLiteral: 240.0 / 360.0)
    static let blueViolet: Hue = .init(floatLiteral: 255.0 / 360.0)
    static let violet: Hue = .init(floatLiteral: 270.0 / 360.0)
    static let violetMagenta: Hue = .init(floatLiteral: 285.0 / 360.0)
    
    static let magenta: Hue = .init(floatLiteral: 300.0 / 360.0)
    static let magentaRose: Hue = .init(floatLiteral: 315.0 / 360.0)
    static let rose: Hue = .init(floatLiteral: 330.0 / 360.0)
    static let roseRed: Hue = .init(floatLiteral: 345.0 / 360.0)
}
