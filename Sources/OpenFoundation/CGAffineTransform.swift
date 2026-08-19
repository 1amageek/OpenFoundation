#if hasFeature(Embedded) || !canImport(Darwin)
@frozen
public struct CGAffineTransform: Equatable, Hashable, Sendable, CustomDebugStringConvertible {
    public var a: CGFloat
    public var b: CGFloat
    public var c: CGFloat
    public var d: CGFloat
    public var tx: CGFloat
    public var ty: CGFloat

    public init() {
        self.init(a: 0, b: 0, c: 0, d: 0, tx: 0, ty: 0)
    }

    public init(a: CGFloat, b: CGFloat, c: CGFloat, d: CGFloat, tx: CGFloat, ty: CGFloat) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.tx = tx
        self.ty = ty
    }

    public init(_ a: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat, _ tx: CGFloat, _ ty: CGFloat) {
        self.init(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }

    public var debugDescription: String {
        "CGAffineTransform(a: \(a), b: \(b), c: \(c), d: \(d), tx: \(tx), ty: \(ty))"
    }
}

extension CGAffineTransform {
    public typealias Components = CGAffineTransformComponents
}
#endif
