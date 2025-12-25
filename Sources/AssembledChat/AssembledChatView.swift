import UIKit
import WebKit

public class AssembledChatView: UIView {
    
    private var webView: WKWebView!
    private var messageBridge: MessageBridge!
    private let configuration: AssembledChatConfiguration
    weak var delegate: AssembledChatDelegate?
    
    private var isLoaded = false
    private var isOpen = false
    private var pendingOperations: [() -> Void] = []
    private let stateQueue = DispatchQueue(label: "com.assembled.chat.state")

    // MARK: - Initialization
    
    /// Initialize the chat view with configuration
    /// - Parameter configuration: Chat configuration options
    public init(configuration: AssembledChatConfiguration, delegate: AssembledChatDelegate? = nil) {
        self.configuration = configuration
        self.delegate = delegate
        super.init(frame: .zero)
        setupWebView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        
        if #available(iOS 14.0, *) {
            let preferences = WKWebpagePreferences()
            preferences.allowsContentJavaScript = true
            webConfiguration.defaultWebpagePreferences = preferences
        }
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.contentInsetAdjustmentBehavior = .always
        webView.isOpaque = false
        webView.backgroundColor = .clear
        
        addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        messageBridge = MessageBridge(webView: webView)
        messageBridge.delegate = self
        injectBridgeScript()
    }
    
    private func injectBridgeScript() {
        let bridgeScript = """
        (function() {
            window.addEventListener('message', function(event) {
                if (event.data && event.data.type) {
                    window.webkit.messageHandlers.assembledChat.postMessage(event.data);
                }
            });
            
            if (typeof window.Assembled === 'undefined') {
                window.Assembled = {};
            }
        })();
        """
        
        let script = WKUserScript(
            source: bridgeScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        webView.configuration.userContentController.addUserScript(script)
    }
    
    private static let baseURL = "\(MessageBridge.trustedOrigin)/public_chat.html"
    
    public func load() {
        guard var urlComponents = URLComponents(string: Self.baseURL) else {
            delegate?.assembledChat(didReceiveError: ChatError.invalidConfiguration("Invalid base URL"))
            return
        }
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "company_id", value: configuration.companyId)
        ]
        
        if let profileId = configuration.profileId {
            queryItems.append(URLQueryItem(name: "profile_id", value: profileId))
        }
        
        if configuration.debug {
            queryItems.append(URLQueryItem(name: "debug", value: "true"))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            delegate?.assembledChat(didReceiveError: ChatError.invalidConfiguration("Invalid URL"))
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    public func open() {
        guard !isOpen else {
            return
        }
        
        executeWhenReady {
            self.isOpen = true
            self.isHidden = false
            self.messageBridge.setVisibility(true)
        }
    }
    
    public func close() {
        guard isOpen else {
            return
        }
        
        executeWhenReady {
            self.isOpen = false
            self.isHidden = true
            self.messageBridge.setVisibility(false)
        }
    }
    
    public func authenticateUser(jwtToken: String, userData: UserData?) {
        executeWhenReady {
            self.messageBridge.authenticateUser(jwtToken: jwtToken, userData: userData)
        }
    }
    
    public func setUserData(_ userData: UserData) {
        executeWhenReady {
            self.messageBridge.updateUserData(userData)
        }
    }
    
    public func setDebug(_ enabled: Bool) {
        executeWhenReady {
            self.messageBridge.setDebug(enabled)
        }
    }
    
    public func showLauncher() {
        executeWhenReady {
            self.messageBridge.setLauncherVisibility(true)
        }
    }
    
    public func hideLauncher() {
        executeWhenReady {
            self.messageBridge.setLauncherVisibility(false)
        }
    }
    
    private func executeWhenReady(_ operation: @escaping () -> Void) {
        stateQueue.async { [weak self] in
            guard let self = self else { return }
            if self.isLoaded {
                DispatchQueue.main.async { operation() }
            } else {
                self.pendingOperations.append(operation)
            }
        }
    }

    private func markAsLoaded() {
        stateQueue.async { [weak self] in
            guard let self = self else { return }
            self.isLoaded = true
            let operations = self.pendingOperations
            self.pendingOperations.removeAll()
            DispatchQueue.main.async {
                for operation in operations {
                    operation()
                }
            }
        }
    }
    
    deinit {
        messageBridge.cleanup()
    }
}

extension AssembledChatView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        injectViewportMetaTag()
    }
    
    private func injectViewportMetaTag() {
        let viewportScript = """
        (function() {
            var viewport = document.querySelector('meta[name="viewport"]');
            if (!viewport) {
                viewport = document.createElement('meta');
                viewport.setAttribute('name', 'viewport');
                document.getElementsByTagName('head')[0].appendChild(viewport);
            }
            viewport.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');
        })();
        """
        
        webView.evaluateJavaScript(viewportScript) { _, error in
            if let error = error {
                self.delegate?.assembledChat(didReceiveError: ChatError.bridgeError("Failed to inject viewport meta tag: \(error.localizedDescription)"))
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.assembledChat(didReceiveError: ChatError.networkError(error))
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        delegate?.assembledChat(didReceiveError: ChatError.networkError(error))
    }
}

extension AssembledChatView: MessageBridgeDelegate {
    func messageBridge(_ bridge: MessageBridge, didReceiveEvent event: ChatEvent) {
        switch event {
        case .loaded:
            markAsLoaded()
            delegate?.assembledChatDidLoad()
            
        case .opened:
            isHidden = false
            isOpen = true
            delegate?.assembledChatDidOpen()
            
        case .closed:
            isHidden = true
            isOpen = false
            delegate?.assembledChatDidClose()
            
        case .settingsLoaded:
            break
            
        case .notificationsReceived(let notifications):
            let decodedNotifications = notifications.compactMap { notificationData -> ChatNotification? in
                guard let jsonData = try? JSONSerialization.data(withJSONObject: notificationData),
                      let notification = try? JSONDecoder().decode(ChatNotification.self, from: jsonData) else {
                    return nil
                }
                return notification
            }
            
            for notification in decodedNotifications {
                delegate?.assembledChat(didReceiveNotification: notification)
            }
        }
    }
    
    func messageBridge(_ bridge: MessageBridge, didReceiveError error: Error) {
        delegate?.assembledChat(didReceiveError: error)
    }
}

/// Delegate protocol for receiving chat events and notifications.
///
/// All methods have default implementations and are optional to implement.
public protocol AssembledChatDelegate: AnyObject {
    /// Called when the chat widget has finished loading and is ready to use.
    func assembledChatDidLoad()
    
    /// Called when the chat widget is opened and becomes visible.
    func assembledChatDidOpen()
    
    /// Called when the chat widget is closed and becomes hidden.
    func assembledChatDidClose()
    
    /// Called when an error occurs in the chat widget.
    /// - Parameter error: The error that occurred.
    func assembledChat(didReceiveError error: Error)
    
    /// Called when a chat notification is received.
    /// - Parameter notification: The notification data.
    func assembledChat(didReceiveNotification notification: ChatNotification)
}

public extension AssembledChatDelegate {
    func assembledChatDidLoad() {}
    func assembledChatDidOpen() {}
    func assembledChatDidClose() {}
    func assembledChat(didReceiveError error: Error) {}
    func assembledChat(didReceiveNotification notification: ChatNotification) {}
}

