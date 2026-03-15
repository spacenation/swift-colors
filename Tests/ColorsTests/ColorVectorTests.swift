import XCTest
@testable import Colors

final class ColorVectorTests: XCTestCase {

    // MARK: - Complement

    func testComplementIsInvolution() {
        let color = Color<OKLCh>(L: 0.7, C: 0.15, h: 45)
        let back = color.complementary().complementary()
        XCTAssertEqual(color.components.h, back.components.h, accuracy: 0.001)
        XCTAssertEqual(color.components.C, back.components.C, accuracy: 0.001)
    }

    func testComplementVectorsCancelInOKLab() {
        let color = Color<OKLCh>(L: 0.7, C: 0.15, h: 45)
        let comp = color.complementary()
        let lab1 = color.converted(to: OKLab.self)
        let lab2 = comp.converted(to: OKLab.self)
        // (a, b) + (-a, -b) = (0, 0)
        XCTAssertEqual(lab1.components.a + lab2.components.a, 0, accuracy: 0.001)
        XCTAssertEqual(lab1.components.b + lab2.components.b, 0, accuracy: 0.001)
        // L preserved
        XCTAssertEqual(lab1.components.L, lab2.components.L, accuracy: 0.001)
    }

    // MARK: - Rotation

    func testTriadicSumsToZero() {
        let color = Color<OKLCh>(L: 0.65, C: 0.12, h: 30)
        let c1 = color.converted(to: OKLab.self)
        let c2 = color.rotated(by: 120).converted(to: OKLab.self)
        let c3 = color.rotated(by: 240).converted(to: OKLab.self)
        // Three vectors at 120° sum to zero in a-b
        XCTAssertEqual(c1.components.a + c2.components.a + c3.components.a, 0, accuracy: 0.001)
        XCTAssertEqual(c1.components.b + c2.components.b + c3.components.b, 0, accuracy: 0.001)
    }

    func testTetradicSumsToZero() {
        let color = Color<OKLCh>(L: 0.6, C: 0.1, h: 15)
        let labs = [0, 90, 180, 270].map { color.rotated(by: Float($0)).converted(to: OKLab.self) }
        let sumA = labs.reduce(Float(0)) { $0 + $1.components.a }
        let sumB = labs.reduce(Float(0)) { $0 + $1.components.b }
        XCTAssertEqual(sumA, 0, accuracy: 0.001)
        XCTAssertEqual(sumB, 0, accuracy: 0.001)
    }

    func testFullRotationReturnsToOriginal() {
        let color = Color<OKLCh>(L: 0.7, C: 0.15, h: 100)
        let rotated = color.rotated(by: 360)
        XCTAssertEqual(color.components.h, rotated.components.h, accuracy: 0.001)
    }

    func testNegativeRotation() {
        let color = Color<OKLCh>(L: 0.7, C: 0.15, h: 30)
        let rotated = color.rotated(by: -60)
        XCTAssertEqual(rotated.components.h, 330, accuracy: 0.001)
    }

    // MARK: - Saturation

    func testSaturationAtMaxChroma() {
        let L: Float = 0.7, h: Float = 150
        let maxC = RGBGamut.sRGB.maxChroma(L: L, h: h)
        let color = Color<OKLCh>(L: L, C: maxC, h: h)
        XCTAssertEqual(color.saturation(in: .sRGB), 1.0, accuracy: 0.01)
    }

    func testSaturationAtZeroChroma() {
        let color = Color<OKLCh>(L: 0.5, C: 0, h: 0)
        XCTAssertEqual(color.saturation(in: .sRGB), 0)
    }

    func testSaturationRoundtrip() {
        let S: Float = 0.6
        let color = Color<OKLCh>(L: 0.7, S: S, h: 200, gamut: RGBGamut.sRGB)
        XCTAssertEqual(color.saturation(in: .sRGB), S, accuracy: 0.01)
    }

    // MARK: - Modifiers

    func testWithLightness() {
        let color = Color<OKLCh>(L: 0.5, C: 0.1, h: 90)
        let bright = color.withLightness(0.9)
        XCTAssertEqual(bright.components.L, 0.9, accuracy: 0.001)
        XCTAssertEqual(bright.components.C, color.components.C, accuracy: 0.001)
        XCTAssertEqual(bright.components.h, color.components.h, accuracy: 0.001)
    }

    func testChromaScaling() {
        let color = Color<OKLCh>(L: 0.7, C: 0.2, h: 45)
        let scaled = color.withChromaScaled(by: 0.5)
        XCTAssertEqual(scaled.components.C, 0.1, accuracy: 0.001)
    }

    // MARK: - OKLab negation

    func testOKLabNegation() {
        let lab = Color<OKLab>(.init(storage: SIMD3(0.7, 0.1, -0.05)))
        let neg = lab.negated()
        XCTAssertEqual(neg.components.L, lab.components.L, accuracy: 0.001)
        XCTAssertEqual(neg.components.a, -lab.components.a, accuracy: 0.001)
        XCTAssertEqual(neg.components.b, -lab.components.b, accuracy: 0.001)
    }
}

final class ColorInterpolationTests: XCTestCase {

    func testInterpolationEndpoints() {
        let a = Color<OKLab>(.init(storage: SIMD3(0.5, 0.1, -0.1)))
        let b = Color<OKLab>(.init(storage: SIMD3(0.8, -0.05, 0.15)))

        let atZero = a.interpolated(to: b, t: 0)
        let atOne = a.interpolated(to: b, t: 1)

        XCTAssertEqual(atZero.components.storage.x, a.components.storage.x, accuracy: 0.0001)
        XCTAssertEqual(atOne.components.storage.x, b.components.storage.x, accuracy: 0.0001)
    }

    func testInterpolationMidpoint() {
        let a = Color<OKLab>(.init(storage: SIMD3(0.4, 0.1, -0.1)))
        let b = Color<OKLab>(.init(storage: SIMD3(0.8, -0.1, 0.1)))
        let mid = a.interpolated(to: b, t: 0.5)

        XCTAssertEqual(mid.components.L, 0.6, accuracy: 0.001)
        XCTAssertEqual(mid.components.a, 0.0, accuracy: 0.001)
        XCTAssertEqual(mid.components.b, 0.0, accuracy: 0.001)
    }

    func testMidpointOfComplementsIsNeutral() {
        let color = Color<OKLCh>(L: 0.7, C: 0.15, h: 60)
        let comp = color.complementary()
        let mid = color.interpolated(to: comp, t: 0.5)
        // Midpoint of a color and its complement in OKLab → neutral (a≈0, b≈0)
        XCTAssertEqual(mid.components.a, 0, accuracy: 0.001)
        XCTAssertEqual(mid.components.b, 0, accuracy: 0.001)
    }

    func testStepsCount() {
        let a = Color<OKLab>(.init(storage: SIMD3(0.3, 0.1, 0.0)))
        let b = Color<OKLab>(.init(storage: SIMD3(0.9, -0.1, 0.0)))
        XCTAssertEqual(a.steps(to: b, count: 5).count, 5)
        XCTAssertEqual(a.steps(to: b, count: 1).count, 1)
        XCTAssertEqual(a.steps(to: b, count: 0).count, 0)
    }

    func testStepsEndpoints() {
        let a = Color<OKLab>(.init(storage: SIMD3(0.3, 0.1, 0.05)))
        let b = Color<OKLab>(.init(storage: SIMD3(0.9, -0.1, -0.05)))
        let result = a.steps(to: b, count: 5)

        XCTAssertEqual(result.first!.components.L, a.components.L, accuracy: 0.001)
        XCTAssertEqual(result.last!.components.L, b.components.L, accuracy: 0.001)
    }

    func testCrossSpaceInterpolation() {
        let srgb = Color<SRGB>(.init(storage: SIMD3(1, 0, 0)))  // red
        let oklch = Color<OKLCh>(L: 0.5, C: 0, h: 0)            // neutral gray
        let mid = srgb.interpolated(to: oklch, t: 0.5)
        // Should produce a desaturated reddish color in OKLab
        XCTAssertGreaterThan(mid.components.L, 0)
        XCTAssertGreaterThan(mid.components.a, 0)  // red has positive a
    }
}
