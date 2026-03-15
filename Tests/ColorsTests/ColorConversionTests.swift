import XCTest
@testable import Colors

final class ColorConversionTests: XCTestCase {

    // MARK: - Roundtrip tests

    func testOKLabRoundtrip() {
        let original = Color<OKLab>(.init(storage: SIMD3(0.72, 0.1, -0.05)))
        let back = original.converted(to: XYZD65.self).converted(to: OKLab.self)
        XCTAssertEqual(original.components.L, back.components.L, accuracy: 0.001)
        XCTAssertEqual(original.components.a, back.components.a, accuracy: 0.001)
        XCTAssertEqual(original.components.b, back.components.b, accuracy: 0.001)
    }

    func testOKLChRoundtrip() {
        let original = Color<OKLCh>(L: 0.72, C: 0.15, h: 28)
        let back = original.converted(to: XYZD65.self).converted(to: OKLCh.self)
        XCTAssertEqual(original.components.L, back.components.L, accuracy: 0.001)
        XCTAssertEqual(original.components.C, back.components.C, accuracy: 0.001)
        XCTAssertEqual(original.components.h, back.components.h, accuracy: 0.1)
    }

    func testSRGBRoundtrip() {
        let original = Color<SRGB>(.init(storage: SIMD3(0.8, 0.3, 0.5)))
        let back = original.converted(to: XYZD65.self).converted(to: SRGB.self)
        XCTAssertEqual(original.components.r, back.components.r, accuracy: 0.001)
        XCTAssertEqual(original.components.g, back.components.g, accuracy: 0.001)
        XCTAssertEqual(original.components.b, back.components.b, accuracy: 0.001)
    }

    func testLinearSRGBRoundtrip() {
        let original = Color<LinearSRGB>(.init(storage: SIMD3(0.5, 0.2, 0.8)))
        let back = original.converted(to: XYZD65.self).converted(to: LinearSRGB.self)
        XCTAssertEqual(original.components.r, back.components.r, accuracy: 0.001)
        XCTAssertEqual(original.components.g, back.components.g, accuracy: 0.001)
        XCTAssertEqual(original.components.b, back.components.b, accuracy: 0.001)
    }

    func testDisplayP3Roundtrip() {
        let original = Color<DisplayP3>(.init(storage: SIMD3(0.7, 0.4, 0.6)))
        let back = original.converted(to: XYZD65.self).converted(to: DisplayP3.self)
        XCTAssertEqual(original.components.r, back.components.r, accuracy: 0.001)
        XCTAssertEqual(original.components.g, back.components.g, accuracy: 0.001)
        XCTAssertEqual(original.components.b, back.components.b, accuracy: 0.001)
    }

    // MARK: - Known value tests

    func testBlackConversion() {
        let black = Color<OKLCh>(L: 0.0, C: 0.0, h: 0.0)
        let srgb = black.converted(to: SRGB.self)
        XCTAssertEqual(srgb.components.r, 0.0, accuracy: 0.001)
        XCTAssertEqual(srgb.components.g, 0.0, accuracy: 0.001)
        XCTAssertEqual(srgb.components.b, 0.0, accuracy: 0.001)
    }

    func testWhiteConversion() {
        let white = Color<OKLCh>(L: 1.0, C: 0.0, h: 0.0)
        let srgb = white.converted(to: SRGB.self)
        XCTAssertEqual(srgb.components.r, 1.0, accuracy: 0.02)
        XCTAssertEqual(srgb.components.g, 1.0, accuracy: 0.02)
        XCTAssertEqual(srgb.components.b, 1.0, accuracy: 0.02)
    }

    func testMultiSpaceChain() {
        // OKLCh → sRGB → OKLab → XYZ → OKLCh
        let original = Color<OKLCh>(L: 0.65, C: 0.12, h: 150)
        let back = original
            .converted(to: SRGB.self)
            .converted(to: OKLab.self)
            .converted(to: XYZD65.self)
            .converted(to: OKLCh.self)
        XCTAssertEqual(original.components.L, back.components.L, accuracy: 0.01)
        XCTAssertEqual(original.components.C, back.components.C, accuracy: 0.01)
        XCTAssertEqual(original.components.h, back.components.h, accuracy: 1.0)
    }

    // MARK: - HSB known-value tests

    func testHSBPrimaryRed() {
        let rgb = Color<HSB>(h: 0, s: 1, b: 1).converted(to: SRGB.self)
        XCTAssertEqual(rgb.components.r, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.g, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.b, 0.0, accuracy: 0.001)
    }

    func testHSBPrimaryGreen() {
        let rgb = Color<HSB>(h: 120, s: 1, b: 1).converted(to: SRGB.self)
        XCTAssertEqual(rgb.components.r, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.g, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.b, 0.0, accuracy: 0.001)
    }

    func testHSBPrimaryBlue() {
        let rgb = Color<HSB>(h: 240, s: 1, b: 1).converted(to: SRGB.self)
        XCTAssertEqual(rgb.components.r, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.g, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.b, 1.0, accuracy: 0.001)
    }

    func testHSBSecondaryCyan() {
        let rgb = Color<HSB>(h: 180, s: 1, b: 1).converted(to: SRGB.self)
        XCTAssertEqual(rgb.components.r, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.g, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.b, 1.0, accuracy: 0.001)
    }

    func testHSBSecondaryYellow() {
        let rgb = Color<HSB>(h: 60, s: 1, b: 1).converted(to: SRGB.self)
        XCTAssertEqual(rgb.components.r, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.g, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.b, 0.0, accuracy: 0.001)
    }

    func testHSBSecondaryMagenta() {
        let rgb = Color<HSB>(h: 300, s: 1, b: 1).converted(to: SRGB.self)
        XCTAssertEqual(rgb.components.r, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.g, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.b, 1.0, accuracy: 0.001)
    }

    func testHSBBlack() {
        let rgb = Color<HSB>(h: 0, s: 0, b: 0).converted(to: SRGB.self)
        XCTAssertEqual(rgb.components.r, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.g, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.b, 0.0, accuracy: 0.001)
    }

    func testHSBWhite() {
        let rgb = Color<HSB>(h: 0, s: 0, b: 1).converted(to: SRGB.self)
        XCTAssertEqual(rgb.components.r, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.g, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.b, 1.0, accuracy: 0.001)
    }

    func testHSBMidGray() {
        let rgb = Color<HSB>(h: 0, s: 0, b: 0.5).converted(to: SRGB.self)
        XCTAssertEqual(rgb.components.r, 0.5, accuracy: 0.001)
        XCTAssertEqual(rgb.components.g, 0.5, accuracy: 0.001)
        XCTAssertEqual(rgb.components.b, 0.5, accuracy: 0.001)
    }

    func testHSBOrange() {
        // H=30, S=1, B=1 → R=1.0, G=0.5, B=0.0
        let rgb = Color<HSB>(h: 30, s: 1, b: 1).converted(to: SRGB.self)
        XCTAssertEqual(rgb.components.r, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.g, 0.5, accuracy: 0.001)
        XCTAssertEqual(rgb.components.b, 0.0, accuracy: 0.001)
    }

    func testHSBPastelBlue() {
        // H=210, S=0.5, B=0.8 → R=0.4, G=0.6, B=0.8
        let rgb = Color<HSB>(h: 210, s: 0.5, b: 0.8).converted(to: SRGB.self)
        XCTAssertEqual(rgb.components.r, 0.4, accuracy: 0.001)
        XCTAssertEqual(rgb.components.g, 0.6, accuracy: 0.001)
        XCTAssertEqual(rgb.components.b, 0.8, accuracy: 0.001)
    }

    func testHSBDarkRed() {
        // H=0, S=1, B=0.5 → R=0.5, G=0, B=0
        let rgb = Color<HSB>(h: 0, s: 1, b: 0.5).converted(to: SRGB.self)
        XCTAssertEqual(rgb.components.r, 0.5, accuracy: 0.001)
        XCTAssertEqual(rgb.components.g, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgb.components.b, 0.0, accuracy: 0.001)
    }

    func testHSBMutedGreen() {
        // H=120, S=0.5, B=0.6 → R=0.3, G=0.6, B=0.3
        let rgb = Color<HSB>(h: 120, s: 0.5, b: 0.6).converted(to: SRGB.self)
        XCTAssertEqual(rgb.components.r, 0.3, accuracy: 0.001)
        XCTAssertEqual(rgb.components.g, 0.6, accuracy: 0.001)
        XCTAssertEqual(rgb.components.b, 0.3, accuracy: 0.001)
    }

    func testHSBRoundtrip() {
        let original = Color<HSB>(h: 210, s: 0.5, b: 0.8)
        let back = original.converted(to: XYZD65.self).converted(to: HSB.self)
        XCTAssertEqual(original.components.h, back.components.h, accuracy: 0.5)
        XCTAssertEqual(original.components.s, back.components.s, accuracy: 0.001)
        XCTAssertEqual(original.components.b, back.components.b, accuracy: 0.001)
    }

    func testHSBToSRGBSpecialization() {
        let hsb = Color<HSB>(h: 210, s: 0.5, b: 0.8)
        // Via specialization
        let direct = ColorConverter.convert(hsb, to: SRGB.self)
        // Via hub
        let viaHub = hsb.converted(to: XYZD65.self).converted(to: SRGB.self)
        XCTAssertEqual(direct.components.r, viaHub.components.r, accuracy: 0.001)
        XCTAssertEqual(direct.components.g, viaHub.components.g, accuracy: 0.001)
        XCTAssertEqual(direct.components.b, viaHub.components.b, accuracy: 0.001)
    }

    func testSRGBToHSBSpecialization() {
        let srgb = Color<SRGB>(.init(storage: SIMD3(0.4, 0.6, 0.8)))
        // Via specialization
        let direct = ColorConverter.convert(srgb, to: HSB.self)
        // Via hub
        let viaHub = srgb.converted(to: XYZD65.self).converted(to: HSB.self)
        XCTAssertEqual(direct.components.h, viaHub.components.h, accuracy: 0.5)
        XCTAssertEqual(direct.components.s, viaHub.components.s, accuracy: 0.001)
        XCTAssertEqual(direct.components.b, viaHub.components.b, accuracy: 0.001)
    }

    // MARK: - Specialization tests

    func testOKLChToOKLabSpecialization() {
        let oklch = Color<OKLCh>(L: 0.7, C: 0.15, h: 60)
        // Via specialization
        let direct = ColorConverter.convert(oklch, to: OKLab.self)
        // Via hub
        let viaHub = oklch.converted(to: XYZD65.self).converted(to: OKLab.self)
        XCTAssertEqual(direct.components.L, viaHub.components.L, accuracy: 0.001)
        XCTAssertEqual(direct.components.a, viaHub.components.a, accuracy: 0.001)
        XCTAssertEqual(direct.components.b, viaHub.components.b, accuracy: 0.001)
    }
}

// MARK: - Gamut tests

final class GamutTests: XCTestCase {

    func testSRGBGamutContainsNeutral() {
        // Achromatic colors (C=0) should be in gamut
        let gray = OKLCh.Components(storage: SIMD3(0.5, 0.0, 0.0))
        XCTAssertTrue(RGBGamut.sRGB.contains(gray))
    }

    func testSRGBGamutClamping() {
        let saturated = OKLCh.Components(storage: SIMD3(0.7, 0.4, 150))
        let clamped = RGBGamut.sRGB.clamp(saturated)
        // Chroma must be reduced
        XCTAssertLessThan(clamped.C, saturated.C)
        // Clamped sRGB values should be near [0,1]
        let srgb = Color<OKLCh>(clamped).converted(to: SRGB.self).components
        XCTAssertEqual(srgb.r.clamped(to: 0...1), srgb.r, accuracy: 0.05)
        XCTAssertEqual(srgb.g.clamped(to: 0...1), srgb.g, accuracy: 0.05)
        XCTAssertEqual(srgb.b.clamped(to: 0...1), srgb.b, accuracy: 0.05)
    }

    func testMaxChroma() {
        let maxC = RGBGamut.sRGB.maxChroma(L: 0.7, h: 150)
        XCTAssertGreaterThan(maxC, 0)
        XCTAssertLessThan(maxC, 0.4)
        let atMax = OKLCh.Components(storage: SIMD3(0.7, maxC, 150))
        XCTAssertTrue(RGBGamut.sRGB.contains(atMax))
    }

    func testHuePayload() {
        let coral = Color<OKLCh>(L: 0.72, C: 0.15, h: 28)
        let payload = coral.huePayload(gamut: .hueGamutC)
        XCTAssertGreaterThan(payload.x, 0)
        XCTAssertGreaterThan(payload.y, 0)
        XCTAssertLessThanOrEqual(payload.x, 1)
        XCTAssertLessThanOrEqual(payload.y, 1)
    }

    func testGamutRelativeSaturation() {
        let color = Color<OKLCh>(L: 0.7, S: 0.5, h: 120, gamut: RGBGamut.sRGB)
        XCTAssertTrue(RGBGamut.sRGB.contains(color.components))
    }
}
