#if hasFeature(Embedded)
// FIXME(INCOMPLETE_IMPLEMENTATION): Embedded metadata and text paths currently preserve only the immutable plain-string portion of NSAttributedString.
// OpenCoreImage and OpenSpriteKit can construct this type in production, but attributes are not representable and must not be reported as preserved.
// Remove this marker after attribute runs, equality, and failure behavior have portable implementations and target-specific tests.
public final class NSAttributedString: Hashable, Sendable {
    public let string: String

    public init(string: String) {
        self.string = string
    }

    public static func == (lhs: NSAttributedString, rhs: NSAttributedString) -> Bool {
        lhs.string == rhs.string
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(string)
    }
}
#endif
