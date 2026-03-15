/// Reusable 3×3 SIMD-backed matrix for color space transforms.
@frozen
public struct Matrix3x3: Sendable, Equatable {
    public var r0: SIMD3<Float>
    public var r1: SIMD3<Float>
    public var r2: SIMD3<Float>

    @inlinable
    public init(rows: (SIMD3<Float>, SIMD3<Float>, SIMD3<Float>)) {
        self.r0 = rows.0
        self.r1 = rows.1
        self.r2 = rows.2
    }

    @inlinable
    public static func * (lhs: Matrix3x3, rhs: SIMD3<Float>) -> SIMD3<Float> {
        SIMD3(
            lhs.r0.x * rhs.x + lhs.r0.y * rhs.y + lhs.r0.z * rhs.z,
            lhs.r1.x * rhs.x + lhs.r1.y * rhs.y + lhs.r1.z * rhs.z,
            lhs.r2.x * rhs.x + lhs.r2.y * rhs.y + lhs.r2.z * rhs.z
        )
    }

    public var inverted: Matrix3x3 {
        let a = r0.x, b = r0.y, c = r0.z
        let d = r1.x, e = r1.y, f = r1.z
        let g = r2.x, h = r2.y, i = r2.z

        let det = a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g)
        let invDet = 1.0 / det

        return Matrix3x3(rows: (
            SIMD3((e * i - f * h) * invDet, (c * h - b * i) * invDet, (b * f - c * e) * invDet),
            SIMD3((f * g - d * i) * invDet, (a * i - c * g) * invDet, (c * d - a * f) * invDet),
            SIMD3((d * h - e * g) * invDet, (b * g - a * h) * invDet, (a * e - b * d) * invDet)
        ))
    }
}
