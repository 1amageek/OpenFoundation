import Foundation

public func roundTripToolchainFoundationDate(_ value: Date) -> Date {
    value
}

public func roundTripToolchainFoundationRect(_ value: CGRect) -> CGRect {
    value
}

public func roundTripToolchainFoundationFloat(_ value: CGFloat) -> CGFloat {
    value
}

public func roundTripToolchainFoundationPoint(_ value: CGPoint) -> CGPoint {
    value
}

public func roundTripToolchainFoundationSize(_ value: CGSize) -> CGSize {
    value
}

public func roundTripToolchainFoundationRectEdge(_ value: CGRectEdge) -> CGRectEdge {
    value
}

#if canImport(Darwin)
public func roundTripToolchainFoundationVector(_ value: CGVector) -> CGVector {
    value
}

public func roundTripToolchainFoundationTransform(
    _ value: CGAffineTransform
) -> CGAffineTransform {
    value
}

public func roundTripToolchainFoundationTransformComponents(
    _ value: CGAffineTransformComponents
) -> CGAffineTransformComponents {
    value
}
#endif
