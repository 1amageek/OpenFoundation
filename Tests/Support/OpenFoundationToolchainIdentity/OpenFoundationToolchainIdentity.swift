import Foundation

public func roundTripToolchainFoundationDate(_ value: Date) -> Date {
    value
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public func roundTripToolchainFoundationLocalizedStringResource(
    _ value: LocalizedStringResource
) -> LocalizedStringResource {
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
