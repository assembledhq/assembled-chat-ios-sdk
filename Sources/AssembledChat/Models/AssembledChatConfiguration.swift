import Foundation

/// Configuration settings for the Assembled chat widget.
///
/// Use this struct to customize the behavior and appearance of the chat widget.
public struct AssembledChatConfiguration {
    /// Your company's unique identifier in the Assembled system.
    public let companyId: String
    
    /// Optional profile ID for multi-profile chat configurations.
    public let profileId: String?
    
    /// Whether the chat widget is activated.
    public let activated: Bool
    
    /// Whether to disable the chat launcher button.
    public let disableLauncher: Bool
    
    /// Optional custom color for the chat button (hex format).
    public let buttonColor: String?
    
    /// Whether to enable debug mode for additional logging.
    public let debug: Bool
    
    /// Optional JWT token for user authentication.
    public let jwtToken: String?
    
    /// Optional user data to associate with the chat session.
    public let userData: UserData?
    
    public init(
        companyId: String,
        profileId: String? = nil,
        activated: Bool = true,
        disableLauncher: Bool = false,
        buttonColor: String? = nil,
        debug: Bool = false,
        jwtToken: String? = nil,
        userData: UserData? = nil
    ) {
        self.companyId = companyId
        self.profileId = profileId
        self.activated = activated
        self.disableLauncher = disableLauncher
        self.buttonColor = buttonColor
        self.debug = debug
        self.jwtToken = jwtToken
        self.userData = userData
    }
}

