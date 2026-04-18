//

import SwiftUI

public enum AppTypography {
    // MARK: - Display Styles (large headings)

    static let displayLarge: Font = .system(size: 32, weight: .bold, design: .default)
    static let displaySmall: Font = .system(size: 28, weight: .bold, design: .default)

    // MARK: - Headline Styles

    enum Headline {
        static let large: Font = .system(size: 24, weight: .semibold, design: .default)
        static let medium: Font = .system(size: 20, weight: .semibold, design: .default)
        static let small: Font = .system(size: 18, weight: .semibold, design: .default)
    }

    // MARK: - Body Styles

    enum Body {
        static let large: Font = .system(size: 18, weight: .regular, design: .default)
        static let medium: Font = .system(size: 16, weight: .regular, design: .default)
        static let small: Font = .system(size: 14, weight: .regular, design: .default)
    }

    // MARK: - Label Styles (form labels, button text)

    enum Label {
        static let large: Font = .system(size: 14, weight: .semibold, design: .default)
        static let medium: Font = .system(size: 12, weight: .semibold, design: .default)
        static let small: Font = .system(size: 11, weight: .semibold, design: .default)
    }

    // MARK: - Caption Styles (secondary, muted text)

    enum Caption {
        static let large: Font = .system(size: 13, weight: .regular, design: .default)
        static let medium: Font = .system(size: 12, weight: .regular, design: .default)
        static let small: Font = .system(size: 11, weight: .regular, design: .default)
    }
}
