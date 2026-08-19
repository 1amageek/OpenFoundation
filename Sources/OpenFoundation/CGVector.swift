#if hasFeature(Embedded) || !canImport(Darwin)
@frozen
public struct CGVector: Equatable, Hashable, Sendable, CustomDebugStringConvertible {
    public var dx: CGFloat
    public var dy: CGFloat

    public init() {
        self.init(dx: 0, dy: 0)
    }

    public init(dx: CGFloat, dy: CGFloat) {
        self.dx = dx
        self.dy = dy
    }

    public init(dx: Int, dy: Int) {
        self.init(dx: CGFloat(dx), dy: CGFloat(dy))
    }

    public static let zero = CGVector()

    public var debugDescription: String {
        "(\(dx), \(dy))"
    }
}
#endif
