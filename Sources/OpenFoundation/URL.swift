#if hasFeature(Embedded)
// FIXME(INCOMPLETE_IMPLEMENTATION): Embedded URL supports local absolute file URLs and the absolute serialized URL subset needed by current Open packages, without relative resolution or full RFC normalization.
// Data file I/O uses only validated absolute, NUL-free filesystem paths; unsupported file representations and network loading fail explicitly at the Data boundary.
// Remove this marker after URL normalization, relative resolution, authority handling, and filesystem representation match the advertised Foundation surface in target-specific tests.
public struct URL: Equatable, Hashable, Sendable, CustomStringConvertible {
    public let path: String
    private let serialized: String
    private let fileURL: Bool
    internal let hasSupportedFileSystemRepresentation: Bool

    public init(fileURLWithPath path: String) {
        let isSupported = Self.isSupportedAbsoluteFileSystemPath(path)
        self.path = path
        if isSupported {
            self.serialized = "file://\(Self.percentEncodedPath(path))"
        } else {
            self.serialized = "file:\(Self.percentEncodedPath(path))"
        }
        self.fileURL = true
        self.hasSupportedFileSystemRepresentation = isSupported
    }

    public init?(string: String) {
        let result = Self.parse(string)
        guard result.isValid else { return nil }
        self.path = result.path
        self.serialized = string
        self.fileURL = result.isFileURL
        self.hasSupportedFileSystemRepresentation = result.isFileURL
    }

    public var isFileURL: Bool { fileURL }
    public var absoluteString: String { serialized }
    public var description: String { absoluteString }

    private static func isASCIILetter(_ byte: UInt8) -> Bool {
        (0x41...0x5A).contains(byte) || (0x61...0x7A).contains(byte)
    }

    private static func isValidScheme(_ bytes: ArraySlice<UInt8>) -> Bool {
        for byte in bytes {
            if !isASCIILetter(byte),
               !(0x30...0x39).contains(byte),
               byte != 0x2B,
               byte != 0x2D,
               byte != 0x2E {
                return false
            }
        }
        return true
    }

    private static func isASCIIFileScheme(_ bytes: ArraySlice<UInt8>) -> Bool {
        guard bytes.count == 4 else { return false }
        let start = bytes.startIndex
        return (bytes[start] | 0x20) == 0x66
            && (bytes[start + 1] | 0x20) == 0x69
            && (bytes[start + 2] | 0x20) == 0x6C
            && (bytes[start + 3] | 0x20) == 0x65
    }

    private struct ParseResult {
        let path: String
        let isFileURL: Bool
        let isValid: Bool

        static var invalid: ParseResult {
            ParseResult(path: "", isFileURL: false, isValid: false)
        }
    }

    private static func parse(_ string: String) -> ParseResult {
        let bytes = Array(string.utf8)
        guard let schemeEnd = bytes.firstIndex(of: 0x3A),
              schemeEnd > 0,
              isASCIILetter(bytes[0]),
              isValidScheme(bytes[..<schemeEnd]) else {
            return ParseResult.invalid
        }

        let scheme = bytes[..<schemeEnd]
        let remainderStart = schemeEnd + 1
        if isASCIIFileScheme(scheme) {
            var index = remainderStart
            var containsComponentDelimiter = false
            while index < bytes.count {
                let byte = bytes[index]
                if byte == 0x3F || byte == 0x23 {
                    containsComponentDelimiter = true
                }
                index += 1
            }

            guard !containsComponentDelimiter,
                  bytes.count >= remainderStart + 3,
                  bytes[remainderStart] == 0x2F,
                  bytes[remainderStart + 1] == 0x2F,
                  bytes[remainderStart + 2] == 0x2F,
                  !(bytes.count > remainderStart + 3 && bytes[remainderStart + 3] == 0x2F),
                  let decodedPath = percentDecodedPath(bytes[(remainderStart + 2)...]),
                  isSupportedAbsoluteFileSystemPath(decodedPath) else {
                return ParseResult.invalid
            }
            return ParseResult(path: decodedPath, isFileURL: true, isValid: true)
        }

        var pathStart = remainderStart
        if bytes.count >= remainderStart + 2,
           bytes[remainderStart] == 0x2F,
           bytes[remainderStart + 1] == 0x2F {
            pathStart += 2
            while pathStart < bytes.count,
                  bytes[pathStart] != 0x2F,
                  bytes[pathStart] != 0x3F,
                  bytes[pathStart] != 0x23 {
                pathStart += 1
            }
        }
        var pathEnd = pathStart
        while pathEnd < bytes.count,
              bytes[pathEnd] != 0x3F,
              bytes[pathEnd] != 0x23 {
            pathEnd += 1
        }
        if pathStart < bytes.count, bytes[pathStart] == 0x2F {
            return ParseResult(
                path: String(decoding: bytes[pathStart..<pathEnd], as: UTF8.self),
                isFileURL: false,
                isValid: true
            )
        }
        if pathStart == remainderStart {
            return ParseResult(
                path: String(decoding: bytes[pathStart..<pathEnd], as: UTF8.self),
                isFileURL: false,
                isValid: true
            )
        }
        return ParseResult(path: "", isFileURL: false, isValid: true)
    }

    private static func isSupportedAbsoluteFileSystemPath(_ path: String) -> Bool {
        let bytes = path.utf8
        return bytes.first == 0x2F && !bytes.contains(0)
    }

    private static func percentEncodedPath(_ path: String) -> String {
        let hexadecimal = Array("0123456789ABCDEF".utf8)
        var result: [UInt8] = []
        result.reserveCapacity(path.utf8.count)

        for byte in path.utf8 {
            if isUnreservedPathByte(byte) || byte == 0x2F {
                result.append(byte)
            } else {
                result.append(0x25)
                result.append(hexadecimal[Int(byte >> 4)])
                result.append(hexadecimal[Int(byte & 0x0F)])
            }
        }
        return String(decoding: result, as: UTF8.self)
    }

    private static func percentDecodedPath(_ path: ArraySlice<UInt8>) -> String? {
        let source = Array(path)
        var result: [UInt8] = []
        result.reserveCapacity(source.count)
        var index = 0

        while index < source.count {
            let byte = source[index]
            if byte == 0x25 {
                guard index + 2 < source.count,
                      let high = hexadecimalValue(source[index + 1]),
                      let low = hexadecimalValue(source[index + 2]) else {
                    return nil
                }
                result.append((high << 4) | low)
                index += 3
            } else {
                result.append(byte)
                index += 1
            }
        }

        guard !result.contains(0) else { return nil }
        return String(bytes: result, encoding: .utf8)
    }

    private static func isUnreservedPathByte(_ byte: UInt8) -> Bool {
        (0x41...0x5A).contains(byte)
            || (0x61...0x7A).contains(byte)
            || (0x30...0x39).contains(byte)
            || byte == 0x2D
            || byte == 0x2E
            || byte == 0x5F
            || byte == 0x7E
    }

    private static func hexadecimalValue(_ byte: UInt8) -> UInt8? {
        switch byte {
        case 0x30...0x39:
            return byte - 0x30
        case 0x41...0x46:
            return byte - 0x41 + 10
        case 0x61...0x66:
            return byte - 0x61 + 10
        default:
            return nil
        }
    }
}
#endif
