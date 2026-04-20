// MARK: - Protocol
// ✅ Describe the contract, usage scope, thread safety, and each method's behavior

/// Abstracts persistent key-value storage for application data.
///
/// Conforming types must be safe to call from any actor context.
/// Obtain instances via `CompositionRoot` — use `settingsStorage` for
/// non-sensitive data and `secureStorage` for tokens and credentials.
public protocol KeyValueStorage {

    /// Persists a value under the given key, overwriting any existing entry.
    ///
    /// - Parameters:
    ///   - value: The encodable value to store.
    ///   - key: The storage key used to retrieve the value later.
    /// - Throws: `StorageError.encodingFailed` if the value cannot be serialized,
    ///   or `StorageError.unavailable` if the storage backend is not accessible.
    func set<T: Encodable>(_ value: T, forKey key: String) throws

    /// Retrieves and decodes the value stored under the given key.
    ///
    /// - Parameter key: The storage key to look up.
    /// - Returns: The decoded value of type `T`, or `nil` if the key does not exist
    ///   or the stored data cannot be decoded into the requested type.
    func value<T: Decodable>(forKey key: String) -> T?
}

// MARK: - Use Case
// ✅ What business rule it orchestrates; what side effects it produces; all outcome branches

/// Authenticates a user and persists the returned tokens to secure storage.
///
/// Coordinates between `AuthRepository` (remote auth) and `KeyValueStorage`
/// (token persistence). On success, both access and refresh tokens are stored
/// before the result is returned to the caller.
///
/// - Example:
/// ```swift
/// let result = await loginUseCase.execute(with: credentials)
/// if case .success = result { navigator.navigate(to: .home) }
/// ```
public final class LoginUseCase {

    /// Signs in with the provided credentials.
    ///
    /// Stores `AuthTokens` to `secureStorage` on `.success` as a side effect.
    ///
    /// - Parameter credentials: The email/password pair to authenticate with.
    /// - Returns: `.success(AuthTokens)` on valid credentials, or a typed
    ///   `LoginError` on failure (`.badCredentials`, `.serverError`, `.noConnectivity`).
    public func execute(with credentials: LoginCredentials) async -> Result<AuthTokens, LoginError> { fatalError() }
}

// MARK: - Repository Protocol
// ✅ The storage/network abstraction boundary; who calls it; error mapping

/// Abstracts remote authentication operations.
///
/// Concrete implementations (e.g. `RemoteAuthRepository`) live in the Infra layer
/// and are injected at composition time. Consume only this protocol in use cases —
/// never import `RemoteAuthRepository` directly.
public protocol AuthRepository {

    /// Authenticates the user and returns a token pair on success.
    ///
    /// - Parameter credentials: The email/password pair to validate.
    /// - Returns: `.success(AuthTokens)` on valid credentials, or a typed `AuthError`
    ///   mapping common HTTP status codes (401 → `.badCredentials`, 5xx → `.serverError`).
    func login(with credentials: LoginCredentials) async -> Result<AuthTokens, AuthError>
}

// MARK: - ViewModel
// ✅ What screen it drives; State cases and transitions; public async methods

/// Drives the Sign In screen state and user interactions.
///
/// **State transitions:**
/// - `.idle` → `.loading` when `signInTapped()` is called
/// - `.loading` → `.success` on valid credentials
/// - `.loading` → `.error(LoginError)` on failure
///
/// On `.success`, subscribers (typically the container) should navigate to Home.
@Observable final class SignInViewModel {

    /// Submits the sign-in form with the current email and password fields.
    ///
    /// Transitions state to `.loading` immediately, then to `.success` or
    /// `.error` based on the result of `LoginUseCase`. Always call from a
    /// `Task` launched on `@MainActor`.
    func signInTapped() async { fatalError() }
}

// MARK: - Error Enum
// ✅ Document each case: what produces it, what the caller should do

/// Errors that can be produced during sign-in.
public enum LoginError: Error, Equatable {

    /// The email or password did not match a known account (HTTP 401).
    /// Present an inline error message prompting the user to check their credentials.
    case badCredentials

    /// The server returned an unexpected status code or malformed payload.
    /// Show a generic "Something went wrong" message; do not surface raw details.
    case serverError

    /// The device has no internet connection.
    /// Show a "Check your connection" message with a retry affordance.
    case noConnectivity

    /// An unrecoverable error with an optional underlying cause for logging only.
    case unexpectedError(Error?)
}
