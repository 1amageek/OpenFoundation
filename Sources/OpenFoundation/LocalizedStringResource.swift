#if (os(WASI) || os(Windows)) && !hasFeature(Embedded)
extension String {
    public struct LocalizationValue: Equatable, Codable, Sendable, ExpressibleByStringInterpolation {
        let pattern: String
        let replacements: [String]

        public init(_ value: String) {
            pattern = value
            replacements = []
        }

        public init(stringLiteral value: String) {
            self.init(value)
        }

        public init(stringInterpolation: StringInterpolation) {
            pattern = stringInterpolation.pattern
            replacements = stringInterpolation.replacements
        }

        public struct StringInterpolation: StringInterpolationProtocol, Sendable {
            var pattern: String
            var replacements: [String]

            public init(literalCapacity: Int, interpolationCount: Int) {
                pattern = ""
                pattern.reserveCapacity(literalCapacity + interpolationCount * 2)
                replacements = []
                replacements.reserveCapacity(interpolationCount)
            }

            public mutating func appendLiteral(_ literal: String) {
                pattern.append(literal)
            }

            public mutating func appendInterpolation(_ string: String) {
                appendReplacement(string)
            }

            public mutating func appendInterpolation(_ substring: Substring) {
                appendReplacement(String(substring))
            }

            @available(
                *,
                deprecated,
                message: "Localized string interpolation uses an unlocalized description for this value. Use String(describing:) to make that conversion explicit."
            )
            public mutating func appendInterpolation<Value>(_ value: Value) {
                appendReplacement(String(describing: value))
            }

            private mutating func appendReplacement(_ replacement: String) {
                pattern.append("%@")
                replacements.append(replacement)
            }
        }
    }
}

public protocol CustomLocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource { get }
}

public struct LocalizedStringResource:
    Equatable,
    Codable,
    Sendable,
    CustomLocalizedStringResourceConvertible,
    ExpressibleByStringInterpolation
{
    public let key: String
    public let defaultValue: String.LocalizationValue
    public let table: String?
    public var locale: Locale
    public let bundle: BundleDescription

    public enum BundleDescription: Sendable {
        case main
        case forClass(AnyClass)
        case atURL(URL)
    }

    public init(
        _ keyAndValue: String.LocalizationValue,
        table: String? = nil,
        locale: Locale = .current,
        bundle: BundleDescription = .main,
        comment: StaticString? = nil
    ) {
        key = keyAndValue.pattern
        defaultValue = keyAndValue
        self.table = table
        self.locale = locale
        self.bundle = bundle
        _ = comment
    }

    public init(
        _ key: StaticString,
        defaultValue: String.LocalizationValue,
        table: String? = nil,
        locale: Locale = .current,
        bundle: BundleDescription = .main,
        comment: StaticString? = nil
    ) {
        self.key = String(describing: key)
        self.defaultValue = defaultValue
        self.table = table
        self.locale = locale
        self.bundle = bundle
        _ = comment
    }

    @_disfavoredOverload
    public init(
        _ keyAndValue: String.LocalizationValue,
        table: String? = nil,
        locale: Locale = .current,
        bundle: Bundle,
        comment: StaticString? = nil
    ) {
        self.init(
            keyAndValue,
            table: table,
            locale: locale,
            bundle: .atURL(bundle.bundleURL),
            comment: comment
        )
    }

    @_disfavoredOverload
    public init(
        _ key: StaticString,
        defaultValue: String.LocalizationValue,
        table: String? = nil,
        locale: Locale = .current,
        bundle: Bundle,
        comment: StaticString? = nil
    ) {
        self.init(
            key,
            defaultValue: defaultValue,
            table: table,
            locale: locale,
            bundle: .atURL(bundle.bundleURL),
            comment: comment
        )
    }

    public init(stringLiteral value: String) {
        self.init(String.LocalizationValue(value))
    }

    public init(stringInterpolation: String.LocalizationValue.StringInterpolation) {
        self.init(String.LocalizationValue(stringInterpolation: stringInterpolation))
    }

    public var localizedStringResource: LocalizedStringResource { self }

    public static func == (lhs: LocalizedStringResource, rhs: LocalizedStringResource) -> Bool {
        lhs.key == rhs.key
            && lhs.defaultValue == rhs.defaultValue
            && lhs.table == rhs.table
            && lhs.locale.identifier == rhs.locale.identifier
            && bundlesAreEqual(lhs.bundle, rhs.bundle)
    }

    private enum CodingKeys: String, CodingKey {
        case key
        case defaultValue
        case table
        case localeIdentifier
        case bundleKind
        case bundleURL
    }

    private enum EncodedBundleKind: String, Codable {
        case main
        case atURL
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        defaultValue = try container.decode(String.LocalizationValue.self, forKey: .defaultValue)
        table = try container.decodeIfPresent(String.self, forKey: .table)
        locale = Locale(identifier: try container.decode(String.self, forKey: .localeIdentifier))
        switch try container.decode(EncodedBundleKind.self, forKey: .bundleKind) {
        case .main:
            bundle = .main
        case .atURL:
            bundle = .atURL(try container.decode(URL.self, forKey: .bundleURL))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(defaultValue, forKey: .defaultValue)
        try container.encodeIfPresent(table, forKey: .table)
        try container.encode(locale.identifier, forKey: .localeIdentifier)
        switch bundle {
        case .main:
            try container.encode(EncodedBundleKind.main, forKey: .bundleKind)
        case .forClass(let type):
            throw EncodingError.invalidValue(
                type,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "This platform cannot restore an AnyClass bundle identity after decoding."
                )
            )
        case .atURL(let url):
            try container.encode(EncodedBundleKind.atURL, forKey: .bundleKind)
            try container.encode(url, forKey: .bundleURL)
        }
    }

    fileprivate var localizedPattern: String {
        switch bundle {
        case .main:
            return defaultValue.pattern
        case .forClass:
            return defaultValue.pattern
        case .atURL(let url):
            for tableURL in localizedTableURLs(bundleURL: url) {
                do {
                    let data = try Data(contentsOf: tableURL)
                    let propertyList = try PropertyListSerialization.propertyList(
                        from: data,
                        options: [],
                        format: nil
                    )
                    if let strings = propertyList as? [String: String],
                       let localized = strings[key] {
                        return localized
                    }
                } catch {
                    continue
                }
            }
            // Foundation localization falls back to the default value when a
            // table is absent, unreadable, malformed, or lacks the requested key.
            return defaultValue.pattern
        }
    }

    private func localizedTableURLs(bundleURL: URL) -> [URL] {
        let tableName = table ?? "Localizable"
        let normalizedLocale = locale.identifier.replacingOccurrences(of: "_", with: "-")
        let language = normalizedLocale.split(separator: "-").first.map(String.init)
        var localizations = [normalizedLocale]
        if let language, language != normalizedLocale {
            localizations.append(language)
        }
        localizations.append("Base")

        var result = localizations.map { localization in
            bundleURL
                .appendingPathComponent("\(localization).lproj")
                .appendingPathComponent("\(tableName).strings")
        }
        result.append(bundleURL.appendingPathComponent("\(tableName).strings"))
        return result
    }

    private static func bundlesAreEqual(
        _ lhs: BundleDescription,
        _ rhs: BundleDescription
    ) -> Bool {
        switch (lhs, rhs) {
        case (.main, .main):
            return true
        case (.forClass(let lhsType), .forClass(let rhsType)):
            return ObjectIdentifier(lhsType) == ObjectIdentifier(rhsType)
        case (.atURL(let lhsURL), .atURL(let rhsURL)):
            return lhsURL == rhsURL
        default:
            return false
        }
    }
}

extension String {
    @_disfavoredOverload
    public init(localized resource: LocalizedStringResource) {
        self = Self.substituting(
            resource.defaultValue.replacements,
            into: resource.localizedPattern
        )
    }

    private static func substituting(_ replacements: [String], into pattern: String) -> String {
        guard !replacements.isEmpty else { return pattern }
        var result = ""
        result.reserveCapacity(pattern.count)
        var replacementIndex = 0
        var index = pattern.startIndex

        while index < pattern.endIndex {
            guard pattern[index] == "%" else {
                result.append(pattern[index])
                index = pattern.index(after: index)
                continue
            }

            let markerEnd = pattern.index(after: index)
            guard markerEnd < pattern.endIndex else {
                result.append("%")
                break
            }
            if pattern[markerEnd] == "%" {
                result.append("%")
                index = pattern.index(after: markerEnd)
                continue
            }
            if pattern[markerEnd] == "@", replacementIndex < replacements.count {
                result.append(replacements[replacementIndex])
                replacementIndex += 1
                index = pattern.index(after: markerEnd)
                continue
            }

            var positionEnd = markerEnd
            while positionEnd < pattern.endIndex,
                  pattern[positionEnd].wholeNumberValue != nil {
                positionEnd = pattern.index(after: positionEnd)
            }
            if positionEnd > markerEnd,
               positionEnd < pattern.endIndex,
               pattern[positionEnd] == "$" {
                let specifier = pattern.index(after: positionEnd)
                if specifier < pattern.endIndex,
                   pattern[specifier] == "@",
                   let oneBasedPosition = Int(pattern[markerEnd..<positionEnd]),
                   replacements.indices.contains(oneBasedPosition - 1) {
                    result.append(replacements[oneBasedPosition - 1])
                    index = pattern.index(after: specifier)
                    continue
                }
            }

            result.append("%")
            index = markerEnd
        }

        return result
    }
}
#endif
