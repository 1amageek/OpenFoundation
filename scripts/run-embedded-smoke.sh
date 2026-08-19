#!/bin/sh

set -eu

OPEN_FOUNDATION_ROOT=$(
    CDPATH= cd -- "$(dirname -- "$0")/.." && pwd
)
OPEN_FOUNDATION_TOOLCHAIN="org.swift.64202608141a"
OPEN_FOUNDATION_SDK="swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-08-14-a_wasm-embedded"
OPEN_FOUNDATION_TARGET_TRIPLE="wasm32-unknown-wasip1"
OPEN_FOUNDATION_PLATFORM_IMPLEMENTATION="embedded/EmbeddedPlatformPOSIX.swiftmodule/wasm32-unknown-wasip1.swiftmodule"
OPEN_FOUNDATION_SCRATCH="${OPEN_FOUNDATION_ROOT}/.build/embedded-smoke"
OPEN_FOUNDATION_WASM="${OPEN_FOUNDATION_SCRATCH}/out/Products/Debug-webassembly-wasm32/OpenFoundationEmbeddedSmoke.wasm"
OPEN_FOUNDATION_TEMP=$(mktemp -d "${TMPDIR:-/tmp}/open-foundation-smoke.XXXXXX")

cleanup() {
    rm -rf -- "${OPEN_FOUNDATION_TEMP}"
}
trap cleanup EXIT HUP INT TERM

cd "${OPEN_FOUNDATION_ROOT}"

printf 'Toolchain: %s\n' "${OPEN_FOUNDATION_TOOLCHAIN}"
printf 'Swift SDK: %s\n' "${OPEN_FOUNDATION_SDK}"
printf 'Target triple: %s\n' "${OPEN_FOUNDATION_TARGET_TRIPLE}"
printf 'Embedded platform implementation: %s\n' \
    "${OPEN_FOUNDATION_PLATFORM_IMPLEMENTATION}"

perl -e 'alarm shift @ARGV; exec @ARGV' 300 \
    env TOOLCHAINS="${OPEN_FOUNDATION_TOOLCHAIN}" \
    xcrun swift build \
    --scratch-path "${OPEN_FOUNDATION_SCRATCH}" \
    --swift-sdk "${OPEN_FOUNDATION_SDK}" \
    --product OpenFoundationEmbeddedSmoke

perl -e 'alarm shift @ARGV; exec @ARGV' 30 \
    node --no-warnings --experimental-wasi-unstable-preview1 -e '
const fs = require("node:fs");
const { WASI } = require("node:wasi");
const wasmPath = process.argv[1];
const hostDirectory = process.argv[2];
const guestDirectory = "/openfoundation-probe";
const guestFile = `${guestDirectory}/roundtrip.bin`;
const wasi = new WASI({
    version: "preview1",
    args: [wasmPath, guestFile],
    env: {},
    preopens: { [guestDirectory]: hostDirectory }
});
WebAssembly.instantiate(
    fs.readFileSync(wasmPath),
    { wasi_snapshot_preview1: wasi.wasiImport }
).then(({ instance }) => wasi.start(instance));
' "${OPEN_FOUNDATION_WASM}" "${OPEN_FOUNDATION_TEMP}"
