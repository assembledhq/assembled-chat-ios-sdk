import Foundation
import WebKit

internal protocol MessageBridgeDelegate: AnyObject {
    func messageBridge(_ bridge: MessageBridge, didReceiveEvent event: ChatEvent)
    func messageBridge(_ bridge: MessageBridge, didReceiveError error: Error)
}

internal class MessageBridge: NSObject, WKScriptMessageHandler {
    weak var delegate: MessageBridgeDelegate?
    private weak var webView: WKWebView?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(webView: WKWebView) {
        self.webView = webView
        super.init()
        setupMessageHandlers()
    }
    
    private func setupMessageHandlers() {
        guard let webView = webView else { return }
        webView.configuration.userContentController.add(self, name: "assembledChat")
    }
    
    func cleanup() {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "assembledChat")
    }
        
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "assembledChat",
              let body = message.body as? [String: Any],
              let type = body["type"] as? String else {
            return
        }
        
        handleMessage(type: type, body: body)
    }
    
    private func handleMessage(type: String, body: [String: Any]) {
        let event: ChatEvent
        
        switch type {
        case "ASSEMBLED_LOADED":
            event = .loaded
        case "ASSEMBLED_ACTIVE", "ASSEMBLED_OPEN":
            event = .opened
        case "ASSEMBLED_INACTIVE", "ASSEMBLED_CLOSE":
            event = .closed
        case "ASSEMBLED_LOADED_SETTINGS":
            if let settingsData = body["settings_and_activation"] {
                event = .settingsLoaded(settingsData)
            } else {
                event = .settingsLoaded([:])
            }
        case "ASSEMBLED_NOTIFICATIONS":
            if let notificationsData = body["notifications"] as? [[String: Any]] {
                event = .notificationsReceived(notificationsData)
            } else {
                event = .notificationsReceived([])
            }
        case "ASSEMBLED_ERROR":
            let errorMessage = body["message"] as? String ?? "Unknown error"
            delegate?.messageBridge(self, didReceiveError: ChatError.bridgeError(errorMessage))
            return
        default:
            return
        }
        
        delegate?.messageBridge(self, didReceiveEvent: event)
    }
    
    func sendMessage(_ message: [String: Any]) {
        guard let webView = webView else { return }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: message),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            delegate?.messageBridge(self, didReceiveError: ChatError.bridgeError("Failed to serialize message"))
            return
        }
        
        let script = "window.postMessage(\(jsonString), '*');"
        webView.evaluateJavaScript(script) { _, error in
            if let error = error {
                self.delegate?.messageBridge(self, didReceiveError: ChatError.bridgeError(error.localizedDescription))
            }
        }
    }
    
    func authenticateUser(jwtToken: String, userData: UserData?) {
        var message: [String: Any] = [
            "type": "USER_DATA_UPDATE",
            "jwtToken": jwtToken
        ]
        
        if let userData = userData {
            if let userDataDict = try? userData.asDictionary() {
                message["userData"] = userDataDict
            }
        }
        
        sendMessage(message)
    }
    
    func updateUserData(_ userData: UserData) {
        guard let userDataDict = try? userData.asDictionary() else { return }
        
        let message: [String: Any] = [
            "type": "USER_DATA_UPDATE",
            "userData": userDataDict
        ]
        
        sendMessage(message)
    }
    
    func setVisibility(_ isVisible: Bool) {
        let message: [String: Any] = [
            "type": "SET_VISIBILITY",
            "isVisible": isVisible
        ]
        
        sendMessage(message)
    }
    
    func setDebug(_ enabled: Bool) {
        let message: [String: Any] = [
            "type": "SET_DEBUG",
            "debug": enabled
        ]
        
        sendMessage(message)
    }
    
    func setLauncherVisibility(_ isVisible: Bool) {
        let message: [String: Any] = [
            "type": "SET_LAUNCHER_VISIBILITY",
            "isVisible": isVisible
        ]
        
        sendMessage(message)
    }
}

internal enum ChatEvent {
    case loaded
    case opened
    case closed
    case settingsLoaded(Any)
    case notificationsReceived([[String: Any]])
}

