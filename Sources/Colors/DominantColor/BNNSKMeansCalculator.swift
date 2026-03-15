#if canImport(CoreGraphics) && canImport(Accelerate)
import Accelerate
import CoreGraphics

/// BNNSGraph-accelerated k-means — uses neural network argMin for cluster assignment.
@available(macOS 26.0, iOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
struct BNNSKMeansCalculator: ~Copyable {
    let k: Int
    let maxIterations: Int
    let pixelCount: Int

    let redStorage: UnsafeMutableBufferPointer<Float>
    let greenStorage: UnsafeMutableBufferPointer<Float>
    let blueStorage: UnsafeMutableBufferPointer<Float>

    let redBuffer: vImage.PixelBuffer<vImage.PlanarF>
    let greenBuffer: vImage.PixelBuffer<vImage.PlanarF>
    let blueBuffer: vImage.PixelBuffer<vImage.PlanarF>

    var distances: UnsafeMutableBufferPointer<Float>

    let argMinContext: BNNSGraph.Context

    var centroids: [Centroid] = []

    let rgbImageFormat = vImage_CGImageFormat(
        bitsPerComponent: 32,
        bitsPerPixel: 32 * 3,
        colorSpace: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGBitmapInfo(
            rawValue: kCGBitmapByteOrder32Host.rawValue |
            CGBitmapInfo.floatComponents.rawValue |
            CGImageAlphaInfo.none.rawValue
        )
    )!

    init(k: Int, maxIterations: Int) {
        self.k = max(1, min(k, 10))
        self.maxIterations = maxIterations
        self.pixelCount = kMeansDimension * kMeansDimension

        redStorage = .allocate(capacity: pixelCount)
        greenStorage = .allocate(capacity: pixelCount)
        blueStorage = .allocate(capacity: pixelCount)

        let stride = kMeansDimension * MemoryLayout<Float>.stride

        redBuffer = vImage.PixelBuffer<vImage.PlanarF>(
            data: redStorage.baseAddress!,
            width: kMeansDimension, height: kMeansDimension,
            byteCountPerRow: stride
        )
        greenBuffer = vImage.PixelBuffer<vImage.PlanarF>(
            data: greenStorage.baseAddress!,
            width: kMeansDimension, height: kMeansDimension,
            byteCountPerRow: stride
        )
        blueBuffer = vImage.PixelBuffer<vImage.PlanarF>(
            data: blueStorage.baseAddress!,
            width: kMeansDimension, height: kMeansDimension,
            byteCountPerRow: stride
        )

        distances = .allocate(capacity: pixelCount * self.k)

        let n = pixelCount
        let kk = self.k
        argMinContext = try! BNNSGraph.makeContext { builder in
            let input = builder.argument(
                name: "distances",
                dataType: Float.self,
                shape: [kk, n]
            )
            let indices = input.argMin(axis: 0, keepDimension: false)
            return [indices]
        }
    }

    deinit {
        redStorage.deallocate()
        greenStorage.deallocate()
        blueStorage.deallocate()
        distances.deallocate()
    }

    // MARK: - Run

    mutating func run(image: CGImage) async -> [DominantColor] {
        loadImage(image)
        initializeCentroids()

        var iterationCount = 0
        var converged = false
        while !converged && iterationCount < maxIterations {
            converged = await updateCentroids()
            iterationCount += 1
        }

        return centroids
            .map { DominantColor(
                color: Color<SRGB>(.init(storage: SIMD3($0.red, $0.green, $0.blue))),
                percentage: Int(Float($0.pixelCount) / Float(pixelCount) * 100)
            )}
            .sorted(by: >)
    }

    // MARK: - Image Loading

    private func loadImage(_ image: CGImage) {
        var format = rgbImageFormat
        let planar: [vImage.PixelBuffer<vImage.PlanarF>] = try! vImage.PixelBuffer<vImage.InterleavedFx3>(
            cgImage: image,
            cgImageFormat: &format
        ).planarBuffers()

        planar[0].scale(destination: redBuffer)
        planar[1].scale(destination: greenBuffer)
        planar[2].scale(destination: blueBuffer)
    }

    // MARK: - Deterministic K-Means++ Initialization

    private mutating func initializeCentroids() {
        centroids.removeAll()

        let centerIndex = pixelCount / 2
        centroids.append(Centroid(
            red: redStorage[centerIndex],
            green: greenStorage[centerIndex],
            blue: blueStorage[centerIndex]
        ))

        let tmp = UnsafeMutableBufferPointer(
            start: distances.baseAddress!,
            count: pixelCount
        )

        for i in 1 ..< k {
            distanceSquared(
                x0: greenStorage.baseAddress!, x1: centroids[i - 1].green,
                y0: blueStorage.baseAddress!, y1: centroids[i - 1].blue,
                z0: redStorage.baseAddress!, z1: centroids[i - 1].red,
                n: pixelCount,
                result: tmp.baseAddress!
            )

            var maxVal: Float = 0
            var maxIdx: vDSP_Length = 0
            vDSP_maxvi(tmp.baseAddress!, 1, &maxVal, &maxIdx, vDSP_Length(pixelCount))
            let idx = Int(maxIdx)
            centroids.append(Centroid(
                red: redStorage[idx],
                green: greenStorage[idx],
                blue: blueStorage[idx]
            ))
        }
    }

    // MARK: - Centroid Update

    private mutating func updateCentroids() async -> Bool {
        let pixelCounts = centroids.map(\.pixelCount)

        populateDistances()
        let centroidIndices = await makeCentroidIndices()

        for centroid in centroids.enumerated() {
            let indices = centroidIndices.enumerated().filter {
                $0.element == centroid.offset
            }.map {
                UInt($0.offset + 1)
            }

            centroids[centroid.offset].pixelCount = indices.count

            if !indices.isEmpty {
                centroids[centroid.offset].red = vDSP.mean(vDSP.gather(redStorage, indices: indices))
                centroids[centroid.offset].green = vDSP.mean(vDSP.gather(greenStorage, indices: indices))
                centroids[centroid.offset].blue = vDSP.mean(vDSP.gather(blueStorage, indices: indices))
            }
        }

        return pixelCounts.elementsEqual(centroids.map(\.pixelCount)) { a, b in
            abs(a - b) < kMeansConvergenceTolerance
        }
    }

    // MARK: - Accelerate Helpers

    private func populateDistances() {
        for centroid in centroids.enumerated() {
            distanceSquared(
                x0: greenStorage.baseAddress!, x1: centroid.element.green,
                y0: blueStorage.baseAddress!, y1: centroid.element.blue,
                z0: redStorage.baseAddress!, z1: centroid.element.red,
                n: pixelCount,
                result: distances.baseAddress!.advanced(by: pixelCount * centroid.offset)
            )
        }
    }

    /// BNNSGraph-accelerated argMin across k centroids.
    private func makeCentroidIndices() async -> [Int32] {
        var args = argMinContext.argumentNames().map { name in
            argMinContext.tensor(argument: name, fillKnownDynamicShapes: false)!
        }

        args[0].allocate(as: Int32.self, count: pixelCount)
        args[1].allocate(initializingFrom: UnsafeBufferPointer(distances))

        try! await argMinContext.executeFunction(arguments: &args)
        let result = args[0].makeArray(of: Int32.self)
        args.forEach { $0.deallocate() }
        return result
    }

    private func distanceSquared(
        x0: UnsafePointer<Float>, x1: Float,
        y0: UnsafePointer<Float>, y1: Float,
        z0: UnsafePointer<Float>, z1: Float,
        n: Int,
        result: UnsafeMutablePointer<Float>
    ) {
        var x = subtract(a: x0, b: x1, n: n)
        vDSP.square(x, result: &x)

        var y = subtract(a: y0, b: y1, n: n)
        vDSP.square(y, result: &y)

        var z = subtract(a: z0, b: z1, n: n)
        vDSP.square(z, result: &z)

        vDSP_vadd(x, 1, y, 1, result, 1, vDSP_Length(n))
        vDSP_vadd(result, 1, z, 1, result, 1, vDSP_Length(n))
    }

    private func subtract(a: UnsafePointer<Float>, b: Float, n: Int) -> [Float] {
        [Float](unsafeUninitializedCapacity: n) { buffer, count in
            vDSP_vsub(a, 1, [b], 0, buffer.baseAddress!, 1, vDSP_Length(n))
            count = n
        }
    }
}

#endif
