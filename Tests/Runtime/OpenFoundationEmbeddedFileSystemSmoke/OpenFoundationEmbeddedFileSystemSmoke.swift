import OpenFoundation

@main
private enum OpenFoundationEmbeddedFileSystemSmoke {
    static func main() throws {
        #if hasFeature(Embedded)
        try verifyPortableAnyHashable()
        print("OpenFoundation Embedded file-system smoke: AnyHashable PASS")
        try verifyStringEncodings()
        print("OpenFoundation Embedded file-system smoke: encodings PASS")
        try verifyURLValidation()
        print("OpenFoundation Embedded file-system smoke: URL PASS")
        try verifyFileIO()
        print("OpenFoundation Embedded file-system smoke: PASS")
        #else
        fatalError("OpenFoundationEmbeddedFileSystemSmoke requires Embedded Swift")
        #endif
    }

    #if hasFeature(Embedded)
    private static func verifyPortableAnyHashable() throws {
        let key = AnyHashable("Open")
        let values = [key: 7]
        guard key.stringValue == "Open",
              values[AnyHashable("Open")] == 7,
              AnyHashable(7) == AnyHashable(7) else {
            throw EmbeddedFileSystemSmokeError.portableAnyHashableMismatch
        }
    }

    private static func verifyStringEncodings() throws {
        guard Array("Open".utf8) == [0x4F, 0x70, 0x65, 0x6E] else {
            throw EmbeddedFileSystemSmokeError.stringEncodingRoundTripFailed
        }
        let fixtures: [(String, String.Encoding)] = [
            ("Open", .ascii),
            ("Open 🚀", .utf8),
            ("Open 🚀", .utf16BigEndian),
            ("café", .isoLatin1),
            ("ÄOpen", .macOSRoman)
        ]

        for (value, encoding) in fixtures {
            guard let encoded = value.data(using: encoding) else {
                throw EmbeddedFileSystemSmokeError.stringEncodingRoundTripFailed
            }
            guard let decoded = String(data: encoded, encoding: encoding) else {
                throw EmbeddedFileSystemSmokeError.stringEncodingRoundTripFailed
            }
            guard decoded == value else {
                throw EmbeddedFileSystemSmokeError.stringEncodingRoundTripFailed
            }
        }

        guard "Open".data(using: String.Encoding(rawValue: UInt.max)) == nil,
              String(data: Data([0xC0, 0xAF]), encoding: .utf8) == nil else {
            throw EmbeddedFileSystemSmokeError.unsupportedEncodingAccepted
        }
    }

    private static func verifyURLValidation() throws {
        if let _ = URL(string: "file://host/path") {
            throw EmbeddedFileSystemSmokeError.invalidFileURLAccepted
        }
        print("OpenFoundation Embedded URL authority rejection: PASS")
        if let _ = URL(string: "file:///tmp/value?query") {
            throw EmbeddedFileSystemSmokeError.invalidFileURLAccepted
        }
        print("OpenFoundation Embedded URL query rejection: PASS")
        if let _ = URL(string: "file:///tmp/value#fragment") {
            throw EmbeddedFileSystemSmokeError.invalidFileURLAccepted
        }
        print("OpenFoundation Embedded URL fragment rejection: PASS")
        if let _ = URL(string: "file:///tmp/%ZZ") {
            throw EmbeddedFileSystemSmokeError.invalidFileURLAccepted
        }
        print("OpenFoundation Embedded URL percent rejection: PASS")
        guard URL(string: "FILE:///tmp/value")?.path == "/tmp/value" else {
            throw EmbeddedFileSystemSmokeError.invalidFileURLAccepted
        }
        print("OpenFoundation Embedded URL scheme normalization: PASS")
        guard URL(string: "file:///tmp/value%20with%20space")?.path == "/tmp/value with space" else {
            throw EmbeddedFileSystemSmokeError.invalidFileURLAccepted
        }
        print("OpenFoundation Embedded URL percent decoding: PASS")

        let relativeURL = URL(fileURLWithPath: "relative")
        do {
            try Data().write(to: relativeURL)
            throw EmbeddedFileSystemSmokeError.relativeFilePathAccepted
        } catch DataIOError.unsupportedFilePath(path: let path) where path == "relative" {
        }

        guard let remoteURL = URL(string: "https://example.com/value") else {
            throw EmbeddedFileSystemSmokeError.remoteURLConstructionFailed
        }
        do {
            _ = try Data(contentsOf: remoteURL)
            throw EmbeddedFileSystemSmokeError.remoteURLReadAccepted
        } catch DataIOError.unsupportedURL(url: let value) where value == remoteURL.absoluteString {
        }
    }

    private static func verifyFileIO() throws {
        let path = "/tmp/open-foundation-embedded-file-smoke"
        let url = URL(fileURLWithPath: path)
        let expected = Data([0x4F, 0x70, 0x65, 0x6E])
        try expected.write(to: url)
        guard try Data(contentsOf: url) == expected else {
            throw EmbeddedFileSystemSmokeError.fileRoundTripFailed
        }

        let emptyURL = URL(fileURLWithPath: path + ".empty")
        try Data().write(to: emptyURL)
        guard try Data(contentsOf: emptyURL).isEmpty else {
            throw EmbeddedFileSystemSmokeError.emptyFileRoundTripFailed
        }

        let missingPath = path + ".missing"
        do {
            _ = try Data(contentsOf: URL(fileURLWithPath: missingPath))
            throw EmbeddedFileSystemSmokeError.missingFileReadSucceeded
        } catch DataIOError.readFailed(path: let failedPath, code: _) where failedPath == missingPath {
        }
    }
    #endif
}

#if hasFeature(Embedded)
private enum EmbeddedFileSystemSmokeError: Error {
    case portableAnyHashableMismatch
    case stringEncodingRoundTripFailed
    case unsupportedEncodingAccepted
    case invalidFileURLAccepted
    case relativeFilePathAccepted
    case remoteURLConstructionFailed
    case remoteURLReadAccepted
    case fileRoundTripFailed
    case emptyFileRoundTripFailed
    case missingFileReadSucceeded
}
#endif
