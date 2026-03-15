#if canImport(SwiftUI)
import SwiftUI

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Color where CS == OKLCh {
    @inlinable
    public func swiftUIColor() -> SwiftUI.Color {
        let srgb = converted(to: SRGB.self).components
        return SwiftUI.Color(
            red:   Double(Swift.min(Swift.max(srgb.r, 0), 1)),
            green: Double(Swift.min(Swift.max(srgb.g, 0), 1)),
            blue:  Double(Swift.min(Swift.max(srgb.b, 0), 1))
        )
    }
}

// MARK: - Playground

#if !os(tvOS)
@available(macOS 14.0, iOS 17.0, watchOS 10.0, *)
struct ColorPlayground: View {
    @State private var paletteL: Float = 0.72
    @State private var paletteS: Float = 0.85
    let root: Colors.Color<OKLCh> = .init(L: 0.72, C: 0.15, h: 28)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                namedHues
                complementSection
                harmonies
                interpolationGradient
                lightnessRamp
                chromaRamp
                gamutBoundary
                toneRegions
            }
            .padding()
        }
        .background(SwiftUI.Color.black)
    }

    // MARK: - 24 named hues

    /// 60 HSV hues converted to OKLCh hue angles — balanced categories.
    private static let oklchHues: [Float] = (0..<60).map { i in
        let hsvHue = Double(i) / 60.0
        let r: Float, g: Float, b: Float
        let h6 = hsvHue * 6
        let sector = Int(h6) % 6
        let f = Float(h6 - Double(sector))
        let q = 1 - f
        switch sector {
        case 0: r = 1; g = f; b = 0
        case 1: r = q; g = 1; b = 0
        case 2: r = 0; g = 1; b = f
        case 3: r = 0; g = q; b = 1
        case 4: r = f; g = 0; b = 1
        default: r = 1; g = 0; b = q
        }
        let srgb = Colors.Color<SRGB>(.init(storage: SIMD3(r, g, b)))
        return srgb.converted(to: OKLCh.self).components.h
    }

    /// 24 HSV hues converted to OKLCh hue angles — balanced categories.
    private static let oklchHues24: [Float] = (0..<24).map { i in
        let hsvHue = Double(i) / 24.0
        let r: Float, g: Float, b: Float
        let h6 = hsvHue * 6
        let sector = Int(h6) % 6
        let f = Float(h6 - Double(sector))
        let q = 1 - f
        switch sector {
        case 0: r = 1; g = f; b = 0
        case 1: r = q; g = 1; b = 0
        case 2: r = 0; g = 1; b = f
        case 3: r = 0; g = q; b = 1
        case 4: r = f; g = 0; b = 1
        default: r = 1; g = 0; b = q
        }
        let srgb = Colors.Color<SRGB>(.init(storage: SIMD3(r, g, b)))
        return srgb.converted(to: OKLCh.self).components.h
    }

    private var namedHues: some View {
        VStack(alignment: .leading, spacing: 6) {
            label(String(format: "60 hues — HSV spacing · OKLCh L=%.2f S=%.2f", paletteL, paletteS))
            HStack(spacing: 1) {
                ForEach(Array(0..<60), id: \.self) { i in
                    let h = Self.oklchHues[i]
                    let c = Colors.Color<OKLCh>(L: paletteL, S: paletteS, h: h, gamut: RGBGamut.sRGB)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(c.swiftUIColor())
                        .frame(height: 30)
                }
            }
            label("24 hues — 6 × 4 grid")
            HStack(spacing: 4) {
                ForEach(Array(0..<6), id: \.self) { col in
                    VStack(spacing: 4) {
                        ForEach(Array(0..<4), id: \.self) { row in
                            let h = Self.oklchHues24[col * 4 + row]
                            let c = Colors.Color<OKLCh>(L: paletteL, S: paletteS, h: h, gamut: RGBGamut.sRGB)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(c.swiftUIColor())
                                .frame(height: 40)
                        }
                    }
                }
            }
            namedHueSliders
        }
    }

    private var namedHueSliders: some View {
        VStack(spacing: 4) {
            sliderRow("L", value: $paletteL, range: 0...1, format: "%.2f")
            sliderRow("S", value: $paletteS, range: 0...1, format: "%.2f")
        }
    }

    private func sliderRow(
        _ name: String,
        value: Binding<Float>,
        range: ClosedRange<Double>,
        format: String
    ) -> some View {
        HStack(spacing: 8) {
            Text(name)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 12)
            Slider(value: Binding(
                get: { Double(value.wrappedValue) },
                set: { value.wrappedValue = Float($0) }
            ), in: range)
            Text(String(format: format, value.wrappedValue))
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 40)
        }
    }

    // MARK: - Complement: vector negation

    private var complementSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            label("Complement — (a,b) → (-a,-b)")
            HStack(spacing: 4) {
                swatch(root, caption: String(format: "h=%.0f°", root.components.h))
                SwiftUI.Color.white.opacity(0.3).frame(width: 1, height: 50)
                swatch(root.complementary(), caption: String(format: "h=%.0f°", root.complementary().components.h))
                Spacer()
                // Midpoint should be neutral
                let mid = root.interpolated(to: root.complementary(), t: 0.5)
                    .converted(to: OKLCh.self)
                swatch(mid, caption: "midpoint")
            }
        }
    }

    // MARK: - Harmonies: rotations that sum to zero

    private var harmonies: some View {
        VStack(alignment: .leading, spacing: 10) {
            label("Harmonies — vector rotations")

            harmonyRow("Triadic (120°)", offsets: [0, 120, 240])
            harmonyRow("Tetradic (90°)", offsets: [0, 90, 180, 270])
            harmonyRow("Split comp (±30°)", offsets: [0, 150, 210])
            harmonyRow("Analogous (±30°)", offsets: [0, -30, 30])
            harmonyRow("Major chord", offsets: [0, 120, 210])
            harmonyRow("Minor chord", offsets: [0, 90, 210])
        }
    }

    private func harmonyRow(_ name: String, offsets: [Float]) -> some View {
        HStack(spacing: 4) {
            Text(name)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 140, alignment: .leading)
            ForEach(Array(offsets.enumerated()), id: \.offset) { _, deg in
                let c = root.rotated(by: deg)
                swatch(c, caption: String(format: "%.0f°", c.components.h))
            }
        }
    }

    // MARK: - Interpolation gradient

    private var interpolationGradient: some View {
        VStack(alignment: .leading, spacing: 6) {
            label("Interpolation — OKLab lerp (perceptually uniform)")
            let a = Colors.Color<OKLCh>(L: 0.7, C: 0.2, h: 30)
            let b = Colors.Color<OKLCh>(L: 0.7, C: 0.2, h: 270)
            let n = 32
            let gradient = a.steps(to: b, count: n).map { $0.converted(to: OKLCh.self) }
            HStack(spacing: 1) {
                ForEach(0..<n, id: \.self) { i in
                    gradient[i].swiftUIColor()
                        .frame(height: 30)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            Text("h=30° → h=270° through neutral (not around the wheel)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white.opacity(0.35))
        }
    }

    // MARK: - Lightness ramp

    private var lightnessRamp: some View {
        VStack(alignment: .leading, spacing: 6) {
            label("Lightness — same hue & saturation, L varies")
            let steps = 16
            HStack(spacing: 1) {
                ForEach(0..<steps, id: \.self) { i in
                    let L = Float(i) / Float(steps - 1)
                    let c = root.withLightness(L)
                    c.swiftUIColor()
                        .frame(height: 30)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            Text("L=0.0 (black) → L=1.0 (white)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white.opacity(0.35))
        }
    }

    // MARK: - Chroma ramp

    private var chromaRamp: some View {
        VStack(alignment: .leading, spacing: 6) {
            label("Chroma — same hue & lightness, C scales 0→max")
            let steps = 16
            let maxC = RGBGamut.sRGB.maxChroma(L: root.components.L, h: root.components.h)
            HStack(spacing: 1) {
                ForEach(0..<steps, id: \.self) { i in
                    let C = maxC * Float(i) / Float(steps - 1)
                    let c = root.withChroma(C)
                    c.swiftUIColor()
                        .frame(height: 30)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            Text(String(format: "C=0 (neutral) → C=%.3f (gamut edge)", maxC))
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white.opacity(0.35))
        }
    }

    // MARK: - Gamut boundary per hue

    private var gamutBoundary: some View {
        VStack(alignment: .leading, spacing: 6) {
            label("Gamut boundary — maxChroma per hue at L=0.72")
            let hueCount = 120
            let maxAll: Float = (0..<hueCount)
                .map { RGBGamut.sRGB.maxChroma(L: 0.72, h: Float($0) * 3) }
                .max() ?? 1
            HStack(alignment: .bottom, spacing: 1) {
                ForEach(0..<hueCount, id: \.self) { i in
                    let h = Float(i) * 3
                    let maxC = RGBGamut.sRGB.maxChroma(L: 0.72, h: h)
                    let height = CGFloat(maxC / maxAll) * 60
                    let c = Colors.Color<OKLCh>(L: 0.72, C: maxC, h: h)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(c.swiftUIColor())
                        .frame(height: Swift.max(height, 2))
                }
            }
            Text("Bar height = maxChroma at that hue. Notice the uneven reach.")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white.opacity(0.35))
        }
    }

    // MARK: - Tone regions: L × S map

    private static let toneGridRows = 20
    private static let toneGridCols = 20
    private static let toneCellW: CGFloat = 24
    private static let toneCellH: CGFloat = 12
    private static let toneTotalW: CGFloat = CGFloat(toneGridCols) * toneCellW
    private static let toneTotalH: CGFloat = CGFloat(toneGridRows) * toneCellH

    private static let namedRegions: [(String, ToneRegion)] = [
        ("Neon",   .neon),
        ("Vivid",  .vivid),
        ("Pastel", .pastel),
        ("Muted",  .muted),
        ("Deep",   .deep),
        ("Dark",   .dark),
        ("Light",  .light),
    ]

    private var toneRegions: some View {
        VStack(alignment: .leading, spacing: 6) {
            label("Tone regions — L × S space at h=\(Int(root.components.h))°")
            toneGrid
            toneAxisLabels
        }
    }

    private var toneGrid: some View {
        ZStack(alignment: .topLeading) {
            toneColorGrid
            toneRegionOverlays
        }
        .frame(width: Self.toneTotalW, height: Self.toneTotalH)
    }

    // L on x-axis (0→1), S on y-axis (1→0, top is high S)
    private var toneColorGrid: some View {
        VStack(spacing: 0) {
            ForEach(Array(0..<Self.toneGridRows), id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(Array(0..<Self.toneGridCols), id: \.self) { col in
                        toneCell(row: row, col: col)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private func toneCell(row: Int, col: Int) -> some View {
        let L = Float(col) / Float(Self.toneGridCols - 1)
        let S = 1 - Float(row) / Float(Self.toneGridRows - 1)
        let c = Colors.Color<OKLCh>(L: L, S: S, h: root.components.h, gamut: RGBGamut.sRGB)
        return c.swiftUIColor()
            .frame(width: Self.toneCellW, height: Self.toneCellH)
    }

    private var toneRegionOverlays: some View {
        ForEach(Array(Self.namedRegions.enumerated()), id: \.offset) { _, entry in
            toneRegionRect(name: entry.0, region: entry.1)
        }
    }

    private func toneRegionRect(name: String, region: ToneRegion) -> some View {
        let w = CGFloat(region.L.upperBound - region.L.lowerBound) * Self.toneTotalW
        let h = CGFloat(region.S.upperBound - region.S.lowerBound) * Self.toneTotalH
        let x = CGFloat(region.L.lowerBound) * Self.toneTotalW
        let y = CGFloat(1 - region.S.upperBound) * Self.toneTotalH
        return RoundedRectangle(cornerRadius: 2)
            .stroke(SwiftUI.Color.white.opacity(0.8), lineWidth: 1)
            .frame(width: w, height: h)
            .overlay(
                Text(name)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2)
            )
            .offset(x: x, y: y)
    }

    private var toneAxisLabels: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("L=0")
                Spacer()
                Text("L=1")
            }
            .frame(width: Self.toneTotalW)
            Text("↑ S=1 (gamut edge)  ↓ S=0 (neutral)")
        }
        .font(.system(size: 9, design: .monospaced))
        .foregroundColor(.white.opacity(0.35))
    }

    // MARK: - Helpers

    private func swatch(_ color: Colors.Color<OKLCh>, caption: String) -> some View {
        VStack(spacing: 2) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color.swiftUIColor())
                .frame(width: 50, height: 50)
            Text(caption)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
        }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .foregroundColor(.white.opacity(0.7))
    }
}

@available(macOS 14.0, iOS 17.0, watchOS 10.0, *)
#Preview("Color Playground") {
    ColorPlayground()
        .frame(width: 560, height: 700)
}
#endif

#endif
