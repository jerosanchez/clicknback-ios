//

import SwiftUI

public enum AppColors {
    // MARK: - Semantic Colors

    enum Semantic {
        static var primary: Color = .accentColor
        static var secondary: Color =
            .init(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
                    : UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
            })
    }

    // MARK: - Status Colors

    enum Status {
        static var success: Color = .init(UIColor.systemGreen)
        static var warning: Color = .init(UIColor.systemOrange)
        static var error: Color = .init(UIColor.systemRed)
    }

    // MARK: - Background Colors

    enum Background {
        static var primary: Color = .init(.systemBackground)
        static var secondary: Color = .init(.secondarySystemBackground)
        static var tertiary: Color = .init(.tertiarySystemBackground)
    }

    // MARK: - Text Colors

    enum Text {
        static var primary: Color = .init(.label)
        static var secondary: Color = .init(.secondaryLabel)
        static var tertiary: Color = .init(.tertiaryLabel)
        static var disabled: Color = .init(.quaternaryLabel)
    }

    // MARK: - Overlay & Border Colors

    enum Overlay {
        static var light: Color = .black.opacity(0.15)
        static var medium: Color = .black.opacity(0.3)
        static var heavy: Color = .black.opacity(0.5)
    }

    enum Border {
        static var border: Color = .init(.separator)
    }
}
