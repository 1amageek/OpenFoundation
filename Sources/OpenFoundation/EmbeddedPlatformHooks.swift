#if hasFeature(Embedded)
// Embedded capability implementations are selected by the final executable.
// These declarations intentionally keep OpenFoundation independent from every
// concrete backend while preserving one stable C ABI for platform packages.

@_extern(c, "open_foundation_sin")
internal func _openFoundationSin(_ value: Double) -> Double

@_extern(c, "open_foundation_cos")
internal func _openFoundationCos(_ value: Double) -> Double

@_extern(c, "open_foundation_tan")
internal func _openFoundationTan(_ value: Double) -> Double

@_extern(c, "open_foundation_atan2")
internal func _openFoundationAtan2(_ y: Double, _ x: Double) -> Double

@_extern(c, "open_foundation_sqrt")
internal func _openFoundationSqrt(_ value: Double) -> Double

@_extern(c, "open_foundation_hypot")
internal func _openFoundationHypot(_ x: Double, _ y: Double) -> Double

@_extern(c, "open_foundation_pow")
internal func _openFoundationPow(_ base: Double, _ exponent: Double) -> Double

@_extern(c, "open_foundation_exp")
internal func _openFoundationExp(_ value: Double) -> Double

@_extern(c, "open_foundation_log")
internal func _openFoundationLog(_ value: Double) -> Double

@_extern(c, "open_foundation_log2")
internal func _openFoundationLog2(_ value: Double) -> Double

@_extern(c, "open_foundation_log10")
internal func _openFoundationLog10(_ value: Double) -> Double

@_extern(c, "open_foundation_acos")
internal func _openFoundationAcos(_ value: Double) -> Double

@_extern(c, "open_foundation_floor")
internal func _openFoundationFloor(_ value: Double) -> Double

@_extern(c, "open_foundation_ceil")
internal func _openFoundationCeil(_ value: Double) -> Double

// A successful read transfers one allocation to Swift. Data copies the bytes
// into its CoW owner and calls the matching release hook exactly once before
// the initializer returns. No pointer escapes that boundary.
@_extern(c, "open_foundation_read_file")
internal func open_foundation_read_file(
    _ path: UnsafePointer<CChar>?,
    _ outputBytes: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>?,
    _ outputCount: UnsafeMutablePointer<Int>?
) -> Int32

@_extern(c, "open_foundation_write_file")
internal func open_foundation_write_file(
    _ path: UnsafePointer<CChar>?,
    _ bytes: UnsafePointer<UInt8>?,
    _ count: Int
) -> Int32

@_extern(c, "open_foundation_release_bytes")
internal func open_foundation_release_bytes(_ bytes: UnsafeMutableRawPointer?)
#endif
