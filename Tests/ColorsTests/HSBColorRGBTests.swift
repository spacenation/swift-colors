import XCTest
@testable import Colors

final class HSBColorTests: XCTestCase {
    func testHSBColorRGBInitTests() {
        XCTAssert(HSBColor(hue: 0, saturation: 0, brightness: 255) == HSBColor(red: 255, green: 255, blue: 255))
        XCTAssert(HSBColor(hue: 0, saturation: 0, brightness: 127) == HSBColor(red: 127, green: 127, blue: 127))
        XCTAssert(HSBColor(hue: 127, saturation: 63, brightness: 127) == HSBColor(red: 96, green: 159, blue: 159))
        XCTAssert(HSBColor(hue: 0, saturation: 0, brightness: 0) == HSBColor(red: 0, green: 0, blue: 0))
    }

    static var allTests = [
        ("testHSBColorRGBInitTests", testHSBColorRGBInitTests),
    ]
}
