import XCTest
@testable import Colors

final class HSBColorDominantColorsTests: XCTestCase {
    func testHSVColorDominantColorsTests() {
        let colors = [
            HSBColor(hue: 1, saturation: 128, brightness: 255),
            HSBColor(hue: 2, saturation: 130, brightness: 200),
            HSBColor(hue: 2, saturation: 128, brightness: 220),
            
            HSBColor(hue: 1, saturation: 126, brightness: 0),
            HSBColor(hue: 1, saturation: 10, brightness: 10)
        ]
        
        XCTAssert(colors.dominantColor(saturationRange: 50...255, brightnessUnitRange: 20...255) == HSBColor(hue: 2, saturation: 129, brightness: 210))
    }

    static var allTests = [
        ("testHSVColorDominantColorsTests", testHSVColorDominantColorsTests),
    ]
}
