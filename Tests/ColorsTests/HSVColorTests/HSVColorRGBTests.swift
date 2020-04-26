import XCTest
@testable import Colors

final class HSVColorTests: XCTestCase {
    func testHSVColorRGBInitTests() {
        XCTAssert(HSVColor(hue: 0, saturation: 0, value: 0) == HSVColor(red: 0, green: 0, blue: 0))
        XCTAssert(HSVColor(hue: 0, saturation: 0, value: 127) == HSVColor(red: 127, green: 127, blue: 127))
        XCTAssert(HSVColor(hue: 0, saturation: 0, value: 255) == HSVColor(red: 255, green: 255, blue: 255))
    }

    static var allTests = [
        ("testHSVColorRGBInitTests", testHSVColorRGBInitTests),
    ]
}
