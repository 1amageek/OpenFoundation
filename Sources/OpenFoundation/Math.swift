#if hasFeature(Embedded)
public func sin(_ value: Double) -> Double { _openFoundationSin(value) }
public func cos(_ value: Double) -> Double { _openFoundationCos(value) }
public func tan(_ value: Double) -> Double { _openFoundationTan(value) }
public func atan2(_ y: Double, _ x: Double) -> Double { _openFoundationAtan2(y, x) }
public func sqrt(_ value: Double) -> Double { _openFoundationSqrt(value) }
public func hypot(_ x: Double, _ y: Double) -> Double { _openFoundationHypot(x, y) }
public func pow(_ base: Double, _ exponent: Double) -> Double { _openFoundationPow(base, exponent) }
public func exp(_ value: Double) -> Double { _openFoundationExp(value) }
public func log(_ value: Double) -> Double { _openFoundationLog(value) }
public func log2(_ value: Double) -> Double { _openFoundationLog2(value) }
public func log10(_ value: Double) -> Double { _openFoundationLog10(value) }
public func acos(_ value: Double) -> Double { _openFoundationAcos(value) }
public func floor(_ value: Double) -> Double { _openFoundationFloor(value) }
public func ceil(_ value: Double) -> Double { _openFoundationCeil(value) }

public func sin(_ value: Float) -> Float { Float(_openFoundationSin(Double(value))) }
public func cos(_ value: Float) -> Float { Float(_openFoundationCos(Double(value))) }
public func tan(_ value: Float) -> Float { Float(_openFoundationTan(Double(value))) }
public func atan2(_ y: Float, _ x: Float) -> Float {
    Float(_openFoundationAtan2(Double(y), Double(x)))
}
public func sqrt(_ value: Float) -> Float { Float(_openFoundationSqrt(Double(value))) }
public func hypot(_ x: Float, _ y: Float) -> Float {
    Float(_openFoundationHypot(Double(x), Double(y)))
}
public func pow(_ base: Float, _ exponent: Float) -> Float {
    Float(_openFoundationPow(Double(base), Double(exponent)))
}
public func exp(_ value: Float) -> Float { Float(_openFoundationExp(Double(value))) }
public func log(_ value: Float) -> Float { Float(_openFoundationLog(Double(value))) }
public func log2(_ value: Float) -> Float { Float(_openFoundationLog2(Double(value))) }
public func log10(_ value: Float) -> Float { Float(_openFoundationLog10(Double(value))) }
public func acos(_ value: Float) -> Float { Float(_openFoundationAcos(Double(value))) }
public func floor(_ value: Float) -> Float { Float(_openFoundationFloor(Double(value))) }
public func ceil(_ value: Float) -> Float { Float(_openFoundationCeil(Double(value))) }
#endif
