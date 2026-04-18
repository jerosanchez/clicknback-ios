//

import ClickNBack
import Foundation
import Testing

@MainActor
@Suite("ConsoleAnalyticsTracker")
struct ConsoleAnalyticsTrackerTests {

    @Test
    func track_includesEventName_inOutput() {
        // Arrange
        let event = makeEvent(name: "user-signed-in")
        let sut = makeSUT()

        // Act
        let output = captureOutput { sut.track(event) }

        // Assert
        #expect(output.contains(event.name))
    }

    @Test
    func track_includesEventProperties_inOutput() {
        // Arrange
        let event = makeEvent(properties: ["screen": "login"])
        let sut = makeSUT()

        // Act
        let output = captureOutput { sut.track(event) }

        // Assert
        #expect(output.contains("screen"))
        #expect(output.contains("login"))
    }

    @Test
    func track_includesTimestamp_inOutput() {
        // Arrange
        let dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        let sut = makeSUT()

        // Act
        let output = captureOutput { sut.track(makeEvent()) }

        // Assert — compare up to seconds to avoid millisecond skew
        let timestampPrefix = String(formatter.string(from: Date()).prefix(19))
        #expect(output.contains(timestampPrefix))
    }

    @Test
    func track_includesAnalyticsEmoji_inOutput() {
        // Arrange
        let sut = makeSUT()

        // Act
        let output = captureOutput { sut.track(makeEvent()) }

        // Assert
        #expect(output.contains("📊"))
    }

    @Test
    func track_includesEventLabel_inOutput() {
        // Arrange
        let sut = makeSUT()

        // Act
        let output = captureOutput { sut.track(makeEvent()) }

        // Assert
        #expect(output.contains("EVENT:"))
    }

    // MARK: - Helpers

    private func makeSUT() -> ConsoleAnalyticsTracker {
        ConsoleAnalyticsTracker()
    }

    private func makeEvent(
        name: String = "test-event",
        properties: [String: Any] = [:]
    ) -> MockAnalyticsEvent {
        MockAnalyticsEvent(name: name, properties: properties)
    }

    private func captureOutput(_ block: () -> Void) -> String {
        let pipe = Pipe()
        let original = dup(STDOUT_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        block()
        fflush(stdout)
        dup2(original, STDOUT_FILENO)
        close(original)
        pipe.fileHandleForWriting.closeFile()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
