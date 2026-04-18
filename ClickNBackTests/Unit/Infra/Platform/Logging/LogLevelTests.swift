//

import ClickNBack
import Testing

@MainActor
@Suite("LogLevel")
struct LogLevelTests {

    // MARK: - emoji

    @Test
    func emoji_returnsBlueCircle_forDebugLevel() {
        #expect(LogLevel.debug.emoji == "🔵")
    }

    @Test
    func emoji_returnsGreenCircle_forInfoLevel() {
        #expect(LogLevel.info.emoji == "🟢")
    }

    @Test
    func emoji_returnsYellowCircle_forWarningLevel() {
        #expect(LogLevel.warning.emoji == "🟡")
    }

    @Test
    func emoji_returnsRedCircle_forErrorLevel() {
        #expect(LogLevel.error.emoji == "🔴")
    }

    // MARK: - rawValue

    @Test
    func rawValue_isDebug_forDebugLevel() {
        #expect(LogLevel.debug.rawValue == "debug")
    }

    @Test
    func rawValue_isInfo_forInfoLevel() {
        #expect(LogLevel.info.rawValue == "info")
    }

    @Test
    func rawValue_isWarning_forWarningLevel() {
        #expect(LogLevel.warning.rawValue == "warning")
    }

    @Test
    func rawValue_isError_forErrorLevel() {
        #expect(LogLevel.error.rawValue == "error")
    }
}
