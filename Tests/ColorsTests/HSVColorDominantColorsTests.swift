import XCTest
@testable import Colors

final class HSVColorDominantColorsTests: XCTestCase {
    func testHSVColorDominantColorsTests() {
        let colors = [
            HSVColor(hue: 1, saturation: 128, value: 255),
            HSVColor(hue: 2, saturation: 255, value: 255),
            HSVColor(hue: 1, saturation: 126, value: 0),
            HSVColor(hue: 1, saturation: 0, value: 0)
        ]
        
        XCTAssert(colors.dominantColor(saturationRange: 50...255) == HSVColor(hue: 1, saturation: 127, value: 127))
    }

    static var allTests = [
        ("testHSVColorDominantColorsTests", testHSVColorDominantColorsTests),
    ]
}
