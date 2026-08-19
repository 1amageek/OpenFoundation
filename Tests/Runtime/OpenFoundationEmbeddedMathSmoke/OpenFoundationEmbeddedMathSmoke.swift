import OpenFoundation

@main
private enum OpenFoundationEmbeddedMathSmoke {
    static func main() throws {
        #if hasFeature(Embedded)
        guard sin(0.0) == 0,
              cos(0.0) == 1,
              tan(0.0) == 0,
              atan2(0.0, 1.0) == 0,
              sqrt(4.0) == 2,
              hypot(3.0, 4.0) == 5,
              pow(2.0, 3.0) == 8,
              exp(0.0) == 1,
              log(1.0) == 0,
              log2(8.0) == 3,
              log10(100.0) == 2,
              acos(1.0) == 0,
              floor(1.75) == 1,
              ceil(1.25) == 2 else {
            throw EmbeddedMathSmokeError.unexpectedResult
        }
        print("OpenFoundation Embedded math smoke: PASS")
        #else
        fatalError("OpenFoundationEmbeddedMathSmoke requires Embedded Swift")
        #endif
    }
}

#if hasFeature(Embedded)
private enum EmbeddedMathSmokeError: Error {
    case unexpectedResult
}
#endif
