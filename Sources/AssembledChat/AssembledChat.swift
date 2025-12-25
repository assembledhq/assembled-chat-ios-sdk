import UIKit
import WebKit

/// The main class for integrating Assembled's chat widget into your iOS application.
///
/// `AssembledChat` provides a WebKit-based chat interface that connects to Assembled's chat service.
/// Initialize the chat with your company ID, then call `initialize()` before using other methods.
///
/// Example usage:
/// ```swift
/// let config = AssembledChatConfiguration(companyId: "your-company-id")
/// let chat = AssembledChat(configuration: config)
/// chat.delegate = self
///
/// Task {
///     try await chat.initialize()
///     chat.open()
/// }
/// ```
public class AssembledChat {
    
    /// The configuration used to initialize the chat widget.
    public let configuration: AssembledChatConfiguration
    
    /// The delegate that receives chat events and errors.
    public weak var delegate: AssembledChatDelegate? {
        didSet {
            chatView?.delegate = delegate
        }
    }
    
    private var chatView: AssembledChatView?
    private var isInitialized = false
    private var initializationID: UUID?

    public init(configuration: AssembledChatConfiguration) {
        self.configuration = configuration
    }

    public static let defaultInitializationTimeout: TimeInterval = 10.0

    /// Initializes the chat widget by adding it to the key window.
    /// - Parameter timeout: Maximum time to wait for initialization. Defaults to 10 seconds.
    /// - Throws: `ChatError.initializationFailed` if the key window cannot be found.
    /// - Throws: `ChatError.timeout` if initialization does not complete within the timeout period.
    public func initialize(timeout: TimeInterval = AssembledChat.defaultInitializationTimeout) async throws {
        guard !isInitialized else { return }

        let initID = UUID()
        initializationID = initID
        defer { initializationID = nil }

        try await runWithTimeout(timeout: timeout, onTimeout: { [weak self] in
            self?.initializationID = nil
        }) { [weak self] in
            guard let self = self else { return }
            try await self.performInitialization(initializationID: initID)
        }
    }

    private func runWithTimeout(
        timeout: TimeInterval,
        onTimeout: @escaping () -> Void,
        operation: @escaping () async throws -> Void
    ) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                onTimeout()
                throw ChatError.timeout
            }
            group.addTask {
                try await operation()
            }

            do {
                guard let _ = try await group.next() else {
                    group.cancelAll()
                    return
                }
                group.cancelAll()
                await Self.drainTaskGroup(&group)
            } catch {
                group.cancelAll()
                await Self.drainTaskGroup(&group)
                throw error
            }
        }
    }

    private static func drainTaskGroup(_ group: inout ThrowingTaskGroup<Void, Error>) async {
        do {
            while let _ = try await group.next() { }
        } catch is CancellationError {
            // Ignore cancellation from the timeout task.
        } catch {
            // Ignore other errors since the caller already handled the first result.
        }
    }

    private func performInitialization(initializationID: UUID) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: ChatError.unknown("Instance was deallocated"))
                    return
                }

                guard self.initializationID == initializationID else {
                    continuation.resume(throwing: CancellationError())
                    return
                }

                guard !self.isInitialized else {
                    continuation.resume()
                    return
                }

                guard let window = self.getKeyWindow() else {
                    continuation.resume(throwing: ChatError.initializationFailed("No key window found"))
                    return
                }

                let chatView = AssembledChatView(configuration: self.configuration, delegate: self.delegate)
                chatView.translatesAutoresizingMaskIntoConstraints = false
                chatView.isHidden = false

                window.addSubview(chatView)
                NSLayoutConstraint.activate([
                    chatView.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor),
                    chatView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                    chatView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                    chatView.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor)
                ])

                self.chatView = chatView
                chatView.load()
                self.isInitialized = true
                self.initializationID = nil
                continuation.resume()
            }
        }
    }
    
    /// Opens the chat widget, making it visible to the user.
    ///
    /// The chat must be initialized before calling this method.
    /// If the chat is not ready, this method will report an error to the delegate.
    public func open() {
        guard isInitialized else {
            delegate?.assembledChat(didReceiveError: ChatError.notReady)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.chatView?.open()
        }
    }
    
    /// Closes the chat widget, hiding it from the user.
    ///
    /// The chat must be initialized before calling this method.
    /// If the chat is not ready, this method will report an error to the delegate.
    public func close() {
        guard isInitialized else {
            delegate?.assembledChat(didReceiveError: ChatError.notReady)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.chatView?.close()
        }
    }
    
    /// Shows the chat launcher button (if applicable).
    public func showLauncher() {
        guard isInitialized else {
            delegate?.assembledChat(didReceiveError: ChatError.notReady)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.chatView?.showLauncher()
        }
    }
    
    /// Hides the chat launcher button (if applicable).
    public func hideLauncher() {
        guard isInitialized else {
            delegate?.assembledChat(didReceiveError: ChatError.notReady)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.chatView?.hideLauncher()
        }
    }
    
    /// Authenticates a user with the chat widget using a JWT token.
    public func authenticateUser(jwtToken: String, userData: UserData? = nil) async throws {
        guard isInitialized else {
            throw ChatError.notReady
        }
        
        await MainActor.run {
            self.chatView?.authenticateUser(jwtToken: jwtToken, userData: userData)
        }
    }
    
    /// Updates the user data associated with the chat session.
    public func setUserData(_ userData: UserData) async throws {
        guard isInitialized else {
            throw ChatError.notReady
        }
        
        await MainActor.run {
            self.chatView?.setUserData(userData)
        }
    }
    
    /// Enables or disables debug mode for the chat widget.
    ///
    /// - Parameter enabled: Whether debug mode should be enabled.
    public func setDebug(_ enabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.chatView?.setDebug(enabled)
        }
    }
    
    /// Indicates whether the chat widget has been initialized and is ready to use.
    public var isReady: Bool {
        isInitialized
    }
    
    /// Tears down the chat widget, removing it from the view hierarchy and cleaning up resources.
    ///
    /// After calling this method, you must call `initialize()` again before using the chat.
    public func teardown() {
        DispatchQueue.main.async { [weak self] in
            self?.chatView?.removeFromSuperview()
            self?.chatView = nil
            self?.isInitialized = false
        }
    }
    
    private func getKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first(where: \.isKeyWindow)
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

public extension AssembledChat {
    convenience init(companyId: String) {
        let configuration = AssembledChatConfiguration(companyId: companyId)
        self.init(configuration: configuration)
    }
    
    convenience init(companyId: String, profileId: String?) {
        let configuration = AssembledChatConfiguration(companyId: companyId, profileId: profileId)
        self.init(configuration: configuration)
    }
}

