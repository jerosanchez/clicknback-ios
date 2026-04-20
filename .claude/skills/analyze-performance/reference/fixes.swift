// MARK: - SwiftUI Rendering Fixes

// ❌ One large @Observable causes the entire view to re-render on any property change
@Observable final class BigViewModel {
    var nameForHeader: String = ""
    var itemsForList: [Item] = []  // changing this re-renders the header too
}

// ✅ Split into smaller @Observable objects — Views re-render only for properties they read
@Observable final class HeaderViewModel { var name: String = "" }
@Observable final class ListViewModel { var items: [Item] = [] }

// ❌ Computed work directly in body — runs on every render
var body: some View {
    Text(items.sorted { $0.date > $1.date }.first?.title ?? "")
}

// ✅ Computed property on @Observable — SwiftUI caches it
@Observable final class VM {
    var items: [Item] = []
    var latestItemTitle: String { items.max(by: { $0.date < $1.date })?.title ?? "" }
}

// MARK: - Main Thread Fixes

// ✅ Move heavy computation off @MainActor with a detached task
func processItems(_ items: [Item]) async {
    let sorted = await Task.detached(priority: .userInitiated) {
        items.sorted { $0.date > $1.date }  // Sendable value returned
    }.value
    state = .success(sorted)  // back on MainActor via @Observable
}

// MARK: - Network Fixes

// ✅ Deduplicate in-flight requests
private var fetchTask: Task<Void, Never>?

func loadData() {
    guard fetchTask == nil else { return }
    fetchTask = Task {
        defer { fetchTask = nil }
        // fetch...
    }
}

// MARK: - Memory Fixes

// ❌ Retain cycle — ViewModel never deallocated after the View disappears
Task { await self.loadData() }

// ✅ Weak capture — safe for long-lived tasks
Task { [weak self] in
    guard let self else { return }
    await self.loadData()
}

// ✅ Cancel outstanding tasks when ViewModel is deallocated
deinit {
    fetchTask?.cancel()
}
