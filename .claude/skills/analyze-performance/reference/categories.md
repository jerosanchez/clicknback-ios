# Performance Bottleneck Categories

| Category | Symptoms | Instrument to Use |
|---|---|---|
| **SwiftUI rendering** | Dropped frames, janky scrolling, slow animations | Xcode SwiftUI instrument |
| **Main thread work** | UI freeze, unresponsive taps, slow transitions | Time Profiler |
| **Network** | Slow screen loads, redundant API calls, large payloads | Network instrument or Charles Proxy |
| **Memory** | Growing footprint, OS-killed app, leaks, retain cycles | Leaks + Allocations instruments |
| **Concurrency** | Inconsistent state, occasional data corruption, thread explosion | Thread Performance Checker |
