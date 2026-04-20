# Bug Categories

| Category | Symptoms |
|---|---|
| **State / data flow** | Wrong value shown, stale data, success returned but wrong result displayed |
| **ViewModel logic** | State not set correctly, wrong transition, missing `await` |
| **UseCase mapping** | Error mapped incorrectly, success returns wrong model |
| **API / Decoding** | Silent nil, decode failure, wrong endpoint, wrong HTTP method |
| **Storage** | Token not persisted, wrong key, read returning nil |
| **Swift 6 / Concurrency** | Data race, main actor violation, retain cycle |
| **SwiftUI rendering** | View not updating, wrong state displayed, layout issue |
