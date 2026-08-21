# OpenFoundation Implementation Progress

## Status legend

| Status | Meaning |
|---|---|
| source | declaration/implementation source exists, not yet verified in this change |
| verified | target-specific compile/link/runtime evidence exists |
| incomplete | callable subset exists with an `INCOMPLETE_IMPLEMENTATION` marker |
| inherited | fixed Swift standard library owns the type; OpenFoundation does not redeclare it |
| planned | declaration does not exist yet |

## Package boundary

| Item | Status | Completion evidence |
|---|---|---|
| `OpenFoundation` library product | verified except Windows | Native, normal WASM, and Embedded WASM geometry fixture compile/link/runtime |
| full Swift Foundation re-export | verified except Windows | Native type-identity tests and normal WASM geometry/localization fixtures |
| full Swift type-identity helper | verified except Windows | Three Native tests, including direct Foundation `LocalizedStringResource` round-trip |
| regular WASM localized-string supplement | verified | fixed-SDK compile/link/runtime covers interpolation metadata, Codable round-trip, explicit `.atURL` table lookup with positional replacement, default rendering, and explicit `.forClass` coding failure |
| Embedded Foundation-free branch | verified for documented subset | Embedded link-symbol audit and 307,745-byte release fixture contain no Foundation-family dependency; separate runtime fixtures cover values, math, URL, encoding, and file I/O |
| backend-independent `OpenFoundation` target | verified | geometry-only expanded link graph selects neither Embedded capability backend |
| `OpenFoundationEmbeddedMath` capability product | verified | fixed Embedded SDK compile/link/runtime; symbol graph contains math hooks and no file hooks |
| `OpenFoundationEmbeddedFileSystem` capability product | verified | fixed Embedded SDK compile/link/runtime with explicit WASI `/tmp` preopen; symbol graph contains file hooks and no math hooks |
| `OpenFoundationEmbeddedMathSmoke` executable target | verified | math success behavior passed on the fixed Embedded SDK |
| `OpenFoundationEmbeddedFileSystemSmoke` executable target | verified | scalar-key metadata, five encodings, URL rejection/decoding, file round trips, and typed failures passed on the fixed Embedded SDK |
| `OpenFoundationLocalizationSmoke` executable target | verified | Native and regular WASM localized resource behavior passed on the fixed SDK, including a processed `.strings` table |
| OpenCoreGraphics dependency migration | verified | 980 Native tests plus normal and Embedded WASM target builds |
| OpenWidgetKit dependency wiring | verified except unpublished pin and Windows M7 | 97 Native tests, Apple/replacement API verification, and normal WASM API/compiler/behavior targets using the local localized-value supplement |
| CFCG value family canonical ownership | verified | Native, normal WASM, and Embedded WASM geometry fixture compile/link/runtime |
| OpenCoreGraphics direct re-export | verified | Native, normal WASM, and Embedded WASM target builds |
| OpenCoreImage direct dependency and re-export | verified | exact-snapshot Native and normal WASM target builds |

## Embedded surface

| Family | Current scope | Status |
|---|---|---|
| `Data` | Array-backed CoW bytes, mutation, scoped buffer access, file read/write | verified for documented subset |
| `DataIOError` | unsupported URL/path, read errno, write errno | verified |
| `URL` | local absolute file URL, UTF-8 percent-encoded path, and absolute serialized URL subset | incomplete |
| `Date` / `TimeInterval` | epoch value, comparison | verified for current fixture surface |
| `String.Encoding` | ASCII, UTF-8, UTF-16BE, ISO Latin-1, Mac OS Roman | incomplete |
| `AnyHashable` | String/Int/UInt/Bool/Double/Float scalar-key subset; arbitrary erasure and cross-numeric equality are not advertised | incomplete |
| `NSAttributedString` | immutable plain string | incomplete |
| math | Double/Float wrappers required by current Open packages | verified |
| CFCG values | architecture-correct `CGFloat` plus point, size, rect, edge, vector, affine transform, and components | verified |

## Undeclared Embedded API families

The following APIs are not present and must not be inferred from the package name:

- `Bundle` and resource discovery;
- locale, calendar, time zone, formatter, and internationalization APIs;
- JSON/plist encoders and decoders;
- networking, URL loading, file manager, process, notification, run loop, and timer APIs;
- Objective-C bridge types and coding/runtime facilities;
- complete Foundation `Data`, `URL`, `Date`, or attributed-string surface.

An API moves from this list only after its owner, production caller, failure contract, Embedded size cost, and
target-specific tests are defined.

## Verification still required

- [ ] Inspect expanded package declarations on Windows; Native, normal WASM, and Embedded WASM were inspected.
- [x] Prove the geometry-only full Swift graph does not resolve either Embedded capability backend.
- [x] Prove each Embedded composition links only the capability products it selected.
- [ ] Compile and link OpenFoundation on Windows; Native, normal WASM, and Embedded WASM passed with the pinned snapshot.
- [ ] Run the full Swift re-export and type-identity fixture on Windows; the Native fixture passed and normal WASM re-export compiled and ran.
- [x] Run Embedded success/failure behavior for byte, encoding, URL, math, and file I/O paths.
- [x] Re-run OpenCoreGraphics behavior tests and normal/Embedded WASM target builds.
- [ ] Compile OpenWidgetKit on Windows using the same toolchain Foundation runtime.
- [x] Compare release WASM fixtures under identical settings: full Swift 60,439,915 bytes; Embedded 307,745 bytes (99.491% smaller, 196.40x ratio).
- [x] Record dependency/link-symbol evidence proving the geometry-only Embedded fixture does not link Foundation-family libraries or Embedded math/file-system backends.

No unchecked item may be reported as verified.
