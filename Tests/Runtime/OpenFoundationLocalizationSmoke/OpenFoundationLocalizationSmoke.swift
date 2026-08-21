import OpenFoundation

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
@main
private enum OpenFoundationLocalizationSmoke {
    static func main() throws {
        let name = "WASM"
        let resource: LocalizedStringResource = "Hello, \(name)!"
        let encoded = try JSONEncoder().encode(resource)
        let decoded = try JSONDecoder().decode(LocalizedStringResource.self, from: encoded)

        guard decoded == resource else {
            throw LocalizationSmokeError.codingRoundTripMismatch
        }
        guard resource.key == "Hello, %@!" else {
            throw LocalizationSmokeError.interpolationKeyMismatch
        }
        guard String(localized: resource) == "Hello, WASM!" else {
            throw LocalizationSmokeError.localizedValueMismatch
        }

        #if os(WASI)
        guard CommandLine.arguments.count == 2 else {
            throw LocalizationSmokeError.missingBundlePath
        }
        let localizedBundleURL = URL(fileURLWithPath: CommandLine.arguments[1])
        #else
        let localizedBundleURL = Bundle.module.bundleURL
        #endif
        let localizedResource = LocalizedStringResource(
            "Order: \(name) then \("OpenFoundation")",
            locale: Locale(identifier: "en"),
            bundle: .atURL(localizedBundleURL)
        )
        let localizedValue = String(localized: localizedResource)
        guard localizedValue == "Order: OpenFoundation then WASM" else {
            throw LocalizationSmokeError.bundleLocalizationMismatch(localizedValue)
        }

        #if os(WASI)
        let classResource = LocalizedStringResource(
            "Class bundle",
            bundle: .forClass(LocalizationBundleMarker.self)
        )
        do {
            _ = try JSONEncoder().encode(classResource)
            throw LocalizationSmokeError.classBundleCodingUnexpectedlySucceeded
        } catch is EncodingError {
            // The portable failure is intentional because WASI cannot restore AnyClass identity.
        }
        #endif

        print("OpenFoundation localization smoke: PASS")
    }
}

private enum LocalizationSmokeError: Error {
    case codingRoundTripMismatch
    case interpolationKeyMismatch
    case localizedValueMismatch
    case missingBundlePath
    case bundleLocalizationMismatch(String)
    case classBundleCodingUnexpectedlySucceeded
}

private final class LocalizationBundleMarker {}
