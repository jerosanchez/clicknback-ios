//

@testable import ClickNBack
import Testing

@MainActor
@Suite("AppLanguage")
struct AppLanguageTests {

    // MARK: - locale

    @Test
    func locale_usesEnglishIdentifier_forEnglishCase() {
        // Arrange
        let sut = AppLanguage.english

        // Assert
        #expect(sut.locale.identifier == AppLanguage.english.rawValue)
    }

    @Test
    func locale_usesSpanishIdentifier_forSpanishCase() {
        // Arrange
        let sut = AppLanguage.spanish

        // Assert
        #expect(sut.locale.identifier == AppLanguage.spanish.rawValue)
    }

    // MARK: - rawValue

    @Test
    func rawValue_isEn_forEnglishCase() {
        #expect(AppLanguage.english.rawValue == "en")
    }

    @Test
    func rawValue_isEs_forSpanishCase() {
        #expect(AppLanguage.spanish.rawValue == "es")
    }

    // MARK: - CaseIterable

    @Test
    func allCases_containsBothLanguages() {
        #expect(AppLanguage.allCases.contains(.english))
        #expect(AppLanguage.allCases.contains(.spanish))
    }

    @Test
    func allCases_containsExactlyTwoCases() {
        #expect(AppLanguage.allCases.count == 2)
    }
}
