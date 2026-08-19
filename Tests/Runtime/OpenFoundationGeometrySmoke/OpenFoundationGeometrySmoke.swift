import OpenFoundation

@main
private enum OpenFoundationGeometrySmoke {
    static func main() throws {
        let point = CGPoint(x: 2, y: 3)
        let size = CGSize(width: 5, height: 7)
        let rect = CGRect(origin: point, size: size)
        let edge = CGRectEdge.maxXEdge
        let vector = CGVector(dx: 11, dy: 13)
        let transform = CGAffineTransform(
            a: 1,
            b: 0,
            c: 0,
            d: 1,
            tx: vector.dx,
            ty: vector.dy
        )
        let components = CGAffineTransformComponents(
            scale: size,
            horizontalShear: 0,
            rotation: 0,
            translation: vector
        )

        guard rect.origin.x == 2,
              rect.size.height == 7,
              edge.rawValue == 2,
              transform.tx == 11,
              components.translation.dy == 13 else {
            throw GeometrySmokeError.valueSemanticsMismatch
        }

        #if arch(i386) || arch(arm) || arch(wasm32)
        let expectedScalarSize = MemoryLayout<Float>.size
        #else
        let expectedScalarSize = MemoryLayout<Double>.size
        #endif
        guard MemoryLayout<CGFloat>.size == expectedScalarSize else {
            throw GeometrySmokeError.scalarWidthMismatch
        }

        print("OpenFoundation geometry smoke: PASS")
    }
}

private enum GeometrySmokeError: Error {
    case valueSemanticsMismatch
    case scalarWidthMismatch
}
