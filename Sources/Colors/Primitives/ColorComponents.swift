/// All component storage is SIMD-backed and value-semantic.
/// Float for performance; the generic parameter on `Color<CS>`
/// ensures type safety at zero runtime cost.
public protocol ColorComponents: Equatable, Hashable, Codable, Sendable {
    var storage: SIMD3<Float> { get }
    init(storage: SIMD3<Float>)
}

extension Comparable {
    @inlinable
    public func clamped(to range: ClosedRange<Self>) -> Self {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
