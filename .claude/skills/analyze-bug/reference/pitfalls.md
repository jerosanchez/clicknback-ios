# Common Swift / iOS Pitfalls

## Swift 6 / Concurrency

- Missing `@MainActor` on ViewModel — mutations happen off main, causing data races
- `Task { }` without `[weak self]` — retains ViewModel after View is gone
- Unstructured task outlives its owner — state updated after dealloc

## SwiftUI

- `@Observable` property read inside `.task {}` doesn't trigger re-render if set before the modifier runs
- `.id(x)` forces view recreation — destroys and recreates the whole subtree including child state
- `.task {}` modifier cancelled and relaunched on every re-render — use `.onAppear` for one-shot work

## Decoding

- API renamed a JSON field → `CodingKeys` mismatch → property silently `nil`
- `JSONDecoder` missing `dateDecodingStrategy` → date parsing returns `nil`
- `APIClientError.decodingError` swallowed and surfaced as `unexpectedError` in UI

## Error Mapping

- `LoginError.badCredentials` mapped from wrong HTTP status code → check `RemoteAuthRepository+login.swift`
- `unexpectedError(Error?)` surfaced raw to UI — must map to a user-friendly message in the ViewModel

## Storage

- Token written to `UserDefaults` instead of `CompositionRoot.secureStorage`
- Key mismatch: verify `AuthTokenStorageKey` raw values match what's stored and read
- `KeyValueStorage.set` throws silently if storage is full or value is not `Encodable`
