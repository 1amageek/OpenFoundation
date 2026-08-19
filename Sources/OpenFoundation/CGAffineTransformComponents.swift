#if hasFeature(Embedded) || !canImport(Darwin)
@frozen
public struct CGAffineTransformComponents: Equatable, Hashable, Sendable, CustomDebugStringConvertible {
    public var scale: CGSize
    public var horizontalShear: CGFloat
    public var rotation: CGFloat
    public var translation: CGVector

    public init() {
        self.scale = .zero
        self.horizontalShear = 0
        self.rotation = 0
        self.translation = .zero
    }

    public init(
        scale: CGSize,
        horizontalShear: CGFloat,
        rotation: CGFloat,
        translation: CGVector
    ) {
        self.scale = scale
        self.horizontalShear = horizontalShear
        self.rotation = rotation
        self.translation = translation
    }

    public var debugDescription: String {
        "CGAffineTransformComponents(scale: \(scale), horizontalShear: \(horizontalShear), rotation: \(rotation), translation: \(translation))"
    }
}
#endif
