//

import SwiftUI

public enum AppColors {
    // MARK: - Brand Colors

    enum Brand {
        static var splashBackground: Color = Color(red: 0.05, green: 0.12, blue: 0.30)
    }

    // MARK: - Semantic Colors

    enum Semantic {
        /// Brand navy on light backgrounds; sky-blue on dark — both derived from the brand hue.
        static var primary: Color = .init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.53, green: 0.75, blue: 0.93, alpha: 1.0)  // #87BFED
                : UIColor(red: 0.05, green: 0.12, blue: 0.30, alpha: 1.0)  // #0D1F4D
        })
        /// Royal blue — one step lighter and more vibrant than primary, same hue family.
        static var secondary: Color = .init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.37, green: 0.65, blue: 0.91, alpha: 1.0)  // #5EA6E8
                : UIColor(red: 0.11, green: 0.35, blue: 0.67, alpha: 1.0)  // #1C59AB
        })
    }

    // MARK: - Status Colors

    enum Status {
        /// Rich forest-green — more premium than systemGreen and pairs well with navy.
        static var success: Color = .init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.27, green: 0.79, blue: 0.52, alpha: 1.0)  // #45C985
                : UIColor(red: 0.07, green: 0.53, blue: 0.32, alpha: 1.0)  // #128851
        })
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
