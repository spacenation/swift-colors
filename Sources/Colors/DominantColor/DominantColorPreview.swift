#if canImport(CoreGraphics) && canImport(Accelerate) && canImport(SwiftUI)
import SwiftUI
import CoreGraphics

@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct DominantColorsPreview: View {
    let name: String
    @State private var colors: [DominantColor] = []
    @State private var cgImage: CGImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let cgImage {
                Image(decorative: cgImage, scale: 1)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            HStack(spacing: 4) {
                ForEach(Array(colors.enumerated()), id: \.offset) { _, dc in
                    let oklch = dc.color.converted(to: OKLCh.self)
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(oklch.swiftUIColor())
                            .frame(height: 50)
                        Text("\(dc.percentage)%")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
        .padding()
        .background(.black)
        .task {
            guard let url = Bundle.module.url(forResource: name, withExtension: "jpg")
                    ?? Bundle.module.url(forResource: name, withExtension: "png"),
                  let source = CGDataProvider(url: url as CFURL),
                  let image = url.pathExtension == "png"
                    ? CGImage(pngDataProviderSource: source, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                    : CGImage(jpegDataProviderSource: source, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            else { return }

            cgImage = image
            colors = await DominantColor.extract(from: image)
        }
    }
}

@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("Dominant Colors") {
    DominantColorsPreview(name: "tokyo")
        .frame(width: 400, height: 400)
}

#endif
