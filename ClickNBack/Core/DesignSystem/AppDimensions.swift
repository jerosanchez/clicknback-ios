//

import SwiftUI

public enum AppDimensions {
    // MARK: - Splash Screen

    enum Splash {
        static let iconSize: CGFloat = 120 // primary outer icon
        static let overlayIconSize: CGFloat = 44 // secondary overlay icon
        static let appNameLetterSpacing: CGFloat = 2
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let extraLarge: CGFloat = 16

        static let full: CGFloat = 999 // Fully rounded corner radius =  circle
    }

    // MARK: - Border Width

    enum Border {
        static let small: CGFloat = 0.5
        static let medium: CGFloat = 1
        static let large: CGFloat = 2
    }

    // MARK: - Icon Sizes

    enum Icon {
        static let small: CGFloat = 16
        static let medium: CGFloat = 24
        static let large: CGFloat = 40
        static let extraLarge: CGFloat = 60
    }

    // MARK: - Button Dimensions

    enum Button {
        static let height: CGFloat = 48
        static let cornerRadius: CGFloat = CornerRadius.medium
    }

    // MARK: - Text Field Dimensions

    enum TextField {
        static let height: CGFloat = 48
        static let cornerRadius: CGFloat = CornerRadius.medium
    }

    // MARK: - Other Components

    static let separatorHeight: CGFloat = 1
    static let badgeSize: CGFloat = 20
}
