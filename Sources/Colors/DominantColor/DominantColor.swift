#if canImport(CoreGraphics) && canImport(Accelerate)
import CoreGraphics

/// A dominant color extracted from an image via k-means clustering.
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public struct DominantColor: Sendable, Equatable, Comparable {
    /// The color in sRGB.
    public let color: Color<SRGB>

    /// Percentage of image pixels belonging to this cluster (0–100).
    public let percentage: Int

    public static func < (lhs: DominantColor, rhs: DominantColor) -> Bool {
        lhs.percentage < rhs.percentage
    }

    /// Extract dominant colors from a `CGImage` using k-means clustering
    /// with the Accelerate framework.
    ///
    /// - Parameters:
    ///   - image: Source image (any size — internally scaled to 256×256).
    ///   - count: Number of dominant colors to find (1–10). Default is 5.
    ///   - maxIterations: Maximum k-means iterations before stopping. Default is 50.
    /// - Returns: Dominant colors sorted by percentage (largest first).
    public static func extract(
        from image: CGImage,
        count: Int = 5,
        maxIterations: Int = 50
    ) -> [DominantColor] {
        var calculator = KMeansCalculator(k: count, maxIterations: maxIterations)
        return calculator.run(image: image)
    }

    /// Async variant — uses BNNSGraph-accelerated argMin on macOS 26+ / iOS 26+,
    /// falls back to the standard implementation on older systems.
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
    public static func extract(
        from image: CGImage,
        count: Int = 5,
        maxIterations: Int = 50
    ) async -> [DominantColor] {
        if #available(macOS 26.0, iOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *) {
            var calculator = BNNSKMeansCalculator(k: count, maxIterations: maxIterations)
            return await calculator.run(image: image)
        }
        var calculator = KMeansCalculator(k: count, maxIterations: maxIterations)
        return calculator.run(image: image)
    }
}

let kMeansDimension = 256
let kMeansConvergenceTolerance = 10

struct Centroid {
    var red: Float
    var green: Float
    var blue: Float
    var pixelCount: Int = 0
}

#endif
