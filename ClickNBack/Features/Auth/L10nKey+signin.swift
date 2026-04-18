//

import Foundation

extension L10nKey {
    enum SignIn {
        enum Screen {
            static let title = LocalizedStringResource("signin.screen.title", table: "SignIn")
            static let offlineBanner = LocalizedStringResource("signin.screen.offline_banner", table: "SignIn")
            static let waitingMessage = LocalizedStringResource("signin.screen.waiting", table: "SignIn")
        }
        
        enum Form {
            static let emailField = LocalizedStringResource("signin.form.emailField", table: "SignIn")
            static let passwordField = LocalizedStringResource("signin.form.passwordField", table: "SignIn")
            static let button = LocalizedStringResource("signin.form.button", table: "SignIn")
        }
        
        enum Result {
            static let successMessage = LocalizedStringResource("signin.result.success", table: "SignIn")
            static let errorMessage = LocalizedStringResource("signin.result.error", table: "SignIn")
            static let badCredentialsMessage = LocalizedStringResource("signin.result.bad_credentials", table: "SignIn")
            static let noConnectivityMessage = LocalizedStringResource("signin.result.no_connectivity", table: "SignIn")
            static let timeoutMessage = LocalizedStringResource("signin.result.timeout", table: "SignIn")
        }
    }
}
