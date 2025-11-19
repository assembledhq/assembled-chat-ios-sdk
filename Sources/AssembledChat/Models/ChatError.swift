import Foundation

public enum ChatError: LocalizedError {
    case initializationFailed(String)
    case authenticationFailed(String)
    case invalidConfiguration(String)
    case networkError(Error)
    case bridgeError(String)
    case notReady
    case invalidUserData(String)
    case timeout
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .initializationFailed(let message):
            return "Failed to initialize chat: \(message)"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .invalidConfiguration(let message):
            return "Invalid configuration: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .bridgeError(let message):
            return "JavaScript bridge error: \(message)"
        case .notReady:
            return "Chat widget is not ready. Please call initialize() first."
        case .invalidUserData(let message):
            return "Invalid user data: \(message)"
        case .timeout:
            return "Operation timed out"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}

public struct ChatNotification: Codable {
    /// The unique identifier for the notification.
    public let id: String
    
    /// The current state of the notification.
    public let state: String
    
    /// The conversation message associated with this notification, if any.
    public let conversationMessage: ConversationMessage?
    
    enum CodingKeys: String, CodingKey {
        case id = "external_id"
        case state
        case conversationMessage = "conversation_message"
    }
}

public struct ConversationMessage: Codable {
    /// The unique identifier for the message.
    public let id: String
    
    /// The text content of the message.
    public let content: String?
    
    /// The date and time when the message was created.
    public let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "external_id"
        case content
        case createdAt = "created_at"
    }
}

