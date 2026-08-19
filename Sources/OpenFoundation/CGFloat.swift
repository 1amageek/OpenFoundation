#if hasFeature(Embedded)
#if arch(i386) || arch(arm) || arch(wasm32)
public typealias CGFloat = Float
#else
public typealias CGFloat = Double
#endif

extension CGFloat {
    public var native: CGFloat { self }
}
#endif
