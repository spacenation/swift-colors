import XCTest
@testable import Colors

final class ToneRegionTests: XCTestCase {

    func testContains() {
        let neon = ToneRegion(L: 0.65...0.80, S: 0.85...1.0)
        let vivid = Color<OKLCh>(L: 0.72, S: 0.9, h: 150, gamut: RGBGamut.sRGB)
        XCTAssertTrue(neon.contains(vivid, in: .sRGB))

        let pastel = Color<OKLCh>(L: 0.85, S: 0.3, h: 150, gamut: RGBGamut.sRGB)
        XCTAssertFalse(neon.contains(pastel, in: .sRGB))
    }

    func testCenter() {
        let region = ToneRegion(L: 0.4...0.6, S: 0.2...0.8)
        XCTAssertEqual(region.center.L, 0.5, accuracy: 0.001)
        XCTAssertEqual(region.center.S, 0.5, accuracy: 0.001)
    }

    func testColorAtCenter() {
        let region = ToneRegion(L: 0.4...0.6, S: 0.4...0.6)
        let color = region.color(h: 90, in: .sRGB)
        XCTAssertEqual(color.components.L, 0.5, accuracy: 0.01)
        XCTAssertEqual(color.saturation(in: .sRGB), 0.5, accuracy: 0.01)
        XCTAssertEqual(color.components.h, 90, accuracy: 0.01)
    }

    func testColorAtPosition() {
        let region = ToneRegion(L: 0.2...0.8, S: 0.0...1.0)
        // lt=0, st=0 → lower bounds
        let low = region.color(h: 45, lt: 0, st: 0, in: .sRGB)
        XCTAssertEqual(low.components.L, 0.2, accuracy: 0.01)
        XCTAssertEqual(low.saturation(in: .sRGB), 0.0, accuracy: 0.01)

        // lt=1, st=1 → upper bounds
        let high = region.color(h: 45, lt: 1, st: 1, in: .sRGB)
        XCTAssertEqual(high.components.L, 0.8, accuracy: 0.01)
        XCTAssertEqual(high.saturation(in: .sRGB), 1.0, accuracy: 0.01)
    }

    func testPredefinedRegions() {
        // Neon center color should be contained in neon
        let color = ToneRegion.neon.color(h: 120, in: .sRGB)
        XCTAssertTrue(ToneRegion.neon.contains(color, in: .sRGB))
        XCTAssertFalse(ToneRegion.deep.contains(color, in: .sRGB))
    }
}
