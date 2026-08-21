#if !hasFeature(Embedded)
import OpenFoundation
import OpenFoundationToolchainIdentity
import Testing

@Test
func valueTypesAreVisibleThroughOpenFoundation() {
    let date = Date(timeIntervalSince1970: 1_234)
    let data = Data([0x4F, 0x70, 0x65, 0x6E])
    let url = URL(fileURLWithPath: "/tmp/open-foundation")
    var mutatedData = data
    mutatedData[0] = 0x58

    #expect(date.timeIntervalSince1970 == 1_234)
    #expect(Array(data) == [0x4F, 0x70, 0x65, 0x6E])
    #expect(Array(mutatedData) == [0x58, 0x70, 0x65, 0x6E])
    #expect(url.isFileURL)
}

@Test
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
func localizedStringResourcesAreVisibleThroughOpenFoundation() throws {
    let resource: LocalizedStringResource = "OpenFoundation"
    let foundationResource = roundTripToolchainFoundationLocalizedStringResource(resource)
    let encoded = try JSONEncoder().encode(resource)
    let decoded = try JSONDecoder().decode(LocalizedStringResource.self, from: encoded)

    #expect(foundationResource == resource)
    #expect(decoded == resource)
    #expect(String(localized: resource) == "OpenFoundation")
}

@Test
func fullSwiftReexportsToolchainFoundationGeometry() {
    let scalar: CGFloat = 3
    let point = CGPoint(x: 1, y: 2)
    let size = CGSize(width: 3, height: 4)
    let rect = CGRect(origin: point, size: size)
    let edge = CGRectEdge.maxYEdge
    let vector = CGVector(dx: 5, dy: 6)
    let transform = CGAffineTransform(
        a: 1,
        b: 2,
        c: 3,
        d: 4,
        tx: 5,
        ty: 6
    )
    let components = CGAffineTransformComponents(
        scale: size,
        horizontalShear: 0.25,
        rotation: 0.5,
        translation: vector
    )
    let date = Date(timeIntervalSince1970: 42)
    let foundationScalar = roundTripToolchainFoundationFloat(scalar)
    let foundationPoint = roundTripToolchainFoundationPoint(point)
    let foundationSize = roundTripToolchainFoundationSize(size)
    let foundationRect = roundTripToolchainFoundationRect(rect)
    let foundationEdge = roundTripToolchainFoundationRectEdge(edge)
    let foundationDate = roundTripToolchainFoundationDate(date)

    #expect(foundationScalar == 3)
    #expect(foundationPoint.y == 2)
    #expect(foundationSize.width == 3)
    #expect(foundationRect.origin.x == 1)
    #expect(foundationRect.size.height == 4)
    #expect(foundationEdge == .maxYEdge)
    #expect(vector.dy == 6)
    #expect(transform.c == 3)
    #expect(components.horizontalShear == 0.25)
    #if canImport(Darwin)
    let foundationVector = roundTripToolchainFoundationVector(vector)
    let foundationTransform = roundTripToolchainFoundationTransform(transform)
    let foundationComponents = roundTripToolchainFoundationTransformComponents(components)
    #expect(foundationVector.dy == 6)
    #expect(foundationTransform.c == 3)
    #expect(foundationComponents.horizontalShear == 0.25)
    #endif
    #expect(foundationDate.timeIntervalSince1970 == 42)
}
#endif
