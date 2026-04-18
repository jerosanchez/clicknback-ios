//

import ClickNBack
import Foundation
import Testing

@MainActor
@Suite("ConsoleLogger")
struct ConsoleLoggerTests {

    @Test
    func debug_includesLevelLabel_inOutput() {
        // Arrange
        let sut = makeSUT()

        // Act
        let output = captureOutput { sut.debug("any message") }

        // Assert
        #expect(output.contains("[\(LogLevel.debug.rawValue.uppercased())]"))
    }

    @Test
    func debug_includesEmoji_inOutput() {
        // Arrange
        let sut = makeSUT()

        // Act
        let output = captureOutput { sut.debug("any message") }

        // Assert
        #expect(output.contains("🔵"))
    }

    @Test
    func debug_includesMessage_inOutput() {
        // Arrange
        let message = "debug message content"
        let sut = makeSUT()

        // Act
        let output = captureOutput { sut.debug(message) }

        // Assert
        #expect(output.contains(message))
    }

    @Test
    func info_includesLevelLabel_inOutput() {
        // Arrange
        let sut = makeSUT()

        // Act
        let output = captureOutput { sut.info("any message") }

        // Assert
        #expect(output.contains("[\(LogLevel.info.rawValue.uppercased())]"))
    }

    @Test
    func info_includesEmoji_inOutput() {
        // Arrange
        let sut = makeSUT()

        // Act
        let output = captureOutput { sut.info("any message") }

        // Assert
        #expect(output.contains("🟢"))
    }

    @Test
    func warning_includesLevelLabel_inOutput() {
        // Arrange
        let sut = makeSUT()

        // Act
        let output = captureOutput { sut.warning("any message") }

        // Assert
        #expect(output.contains("[\(LogLevel.warning.rawValue.uppercased())]"))
    }

    @Test
    func warning_includesEmoji_inOutput() {
        // Arrange
        let sut = makeSUT()

        // Act
        let output = captureOutput { sut.warning("any message") }

        // Assert
        #expect(output.contains("🟡"))
    }

    @Test
    func error_includesLevelLabel_inOutput() {
        // Arrange
        let sut = makeSUT()

        // Act
        let output = captureOutput { sut.error("any message") }

        // Assert
        #expect(output.contains("[\(LogLevel.error.rawValue.uppercased())]"))
    }

    @Test
    func error_includesEmoji_inOutput() {
        // Arrange
        let sut = makeSUT()

        // Act
        let output = captureOutput { sut.error("any message") }

        // Assert
        #expect(output.contains("🔴"))
    }

    @Test
    func log_includesTimestamp_inOutput() {
        // Arrange
        let dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        let sut = makeSUT(dateFormat: dateFormat)

        // Act
        let output = captureOutput { sut.info("any message") }

        // Assert
        // Compare up to seconds to avoid millisecond skew between arrange and act
        let timestampPrefix = String(formatter.string(from: Date()).prefix(19))
        #expect(output.contains(timestampPrefix))
    }

    @Test
    func init_appliesCustomDateFormat_inOutput() {
        // Arrange
        let customFormat = "dd/MM/yyyy"
        let formatter = DateFormatter()
        formatter.dateFormat = customFormat
        let sut = makeSUT(dateFormat: customFormat)

        // Act
        let output = captureOutput { sut.info("any message") }

        // Assert
        #expect(output.contains(formatter.string(from: Date())))
    }

    // MARK: - Helpers

    private func makeSUT(dateFormat: String = "yyyy-MM-dd HH:mm:ss.SSS") -> ConsoleLogger {
        ConsoleLogger(dateFormat: dateFormat)
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
