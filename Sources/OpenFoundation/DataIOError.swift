#if hasFeature(Embedded)
public enum DataIOError: Error, Equatable, Sendable, CustomStringConvertible {
    case unsupportedURL(url: String)
    case unsupportedFilePath(path: String)
    case readFailed(path: String, code: Int32)
    case writeFailed(path: String, code: Int32)

    public var description: String {
        switch self {
        case .unsupportedURL(let url):
            return "Only file URLs are supported by Embedded OpenFoundation: \(url)"
        case .unsupportedFilePath(let path):
            return "Only absolute, NUL-free file paths are supported by Embedded OpenFoundation: \(path)"
        case .readFailed(let path, let code):
            return "Failed to read \(path) (error \(code))"
        case .writeFailed(let path, let code):
            return "Failed to write \(path) (error \(code))"
        }
    }
}
#endif
