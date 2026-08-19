#if hasFeature(Embedded)
@frozen
public struct CGRect: Sendable, CustomDebugStringConvertible {
    public var origin: CGPoint
    public var size: CGSize

    public init() {
        self.init(origin: .zero, size: .zero)
    }

    public init(origin: CGPoint, size: CGSize) {
        self.origin = origin
        self.size = size
    }

    public init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
    }

    public static let zero = CGRect()
    public static let null = CGRect(
        origin: CGPoint(x: .infinity, y: .infinity),
        size: .zero
    )
    public static let infinite = CGRect(
        x: -.greatestFiniteMagnitude / 2,
        y: -.greatestFiniteMagnitude / 2,
        width: .greatestFiniteMagnitude,
        height: .greatestFiniteMagnitude
    )

    public var debugDescription: String {
        "(\(origin.x), \(origin.y), \(size.width), \(size.height))"
    }
}

extension CGRect: Equatable {
    public static func == (lhs: CGRect, rhs: CGRect) -> Bool {
        if _openFoundationCGRectIsNull(lhs) && _openFoundationCGRectIsNull(rhs) {
            return true
        }
        if _openFoundationCGRectIsNull(lhs) || _openFoundationCGRectIsNull(rhs) {
            return false
        }
        return _openFoundationStandardizedCGRectValues(lhs) ==
            _openFoundationStandardizedCGRectValues(rhs)
    }
}

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        if _openFoundationCGRectIsNull(self) {
            hasher.combine(CGFloat.infinity)
            hasher.combine(CGFloat.infinity)
            hasher.combine(CGFloat.zero)
            hasher.combine(CGFloat.zero)
            return
        }
        let values = _openFoundationStandardizedCGRectValues(self)
        hasher.combine(values.minX)
        hasher.combine(values.minY)
        hasher.combine(values.width)
        hasher.combine(values.height)
    }
}

private func _openFoundationCGRectIsNull(_ rect: CGRect) -> Bool {
    rect.origin.x.isNaN || rect.origin.y.isNaN ||
        rect.size.width.isNaN || rect.size.height.isNaN ||
        (rect.origin.x == .infinity && rect.origin.y == .infinity)
}

private func _openFoundationStandardizedCGRectValues(
    _ rect: CGRect
) -> (minX: CGFloat, minY: CGFloat, width: CGFloat, height: CGFloat) {
    let minX = Swift.min(rect.origin.x, rect.origin.x + rect.size.width)
    let minY = Swift.min(rect.origin.y, rect.origin.y + rect.size.height)
    return (
        minX: minX,
        minY: minY,
        width: Swift.abs(rect.size.width),
        height: Swift.abs(rect.size.height)
    )
}
#endif
