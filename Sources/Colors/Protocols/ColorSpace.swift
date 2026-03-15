public enum WhitePoint: Sendable {
    case D65
    case D50
}

/// Every color space declares how to round-trip through XYZ D65.
/// XYZ D65 is the hub — all conversions go through it.
/// This lets users define arbitrary color spaces and get
/// free conversion to everything else.
public protocol ColorSpace: Sendable {
    /// The SIMD-backed component storage
    associatedtype Components: ColorComponents

    static var name: String { get }
    static var whitePoint: WhitePoint { get }

    /// Convert FROM this space TO XYZ D65
    static func toXYZ(_ components: Components) -> XYZD65.Components

    /// Convert FROM XYZ D65 INTO this space
    static func fromXYZ(_ xyz: XYZD65.Components) -> Components
}

public extension ColorSpace {
    static var whitePoint: WhitePoint { .D65 }
}
