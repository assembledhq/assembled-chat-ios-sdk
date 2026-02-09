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

    // MARK: - UI Customization

    /// When enabled, will hide the "X" close button in the chat header.
    public let disableCloseButton: Bool

    /// When enabled, will hide the header. Best used in conjunction with embedded display mode.
    public let disableHeader: Bool

    /// Set the icon displayed for the file attachment button in the text input bar.
    public let attachmentIconVariant: AttachmentIconVariant?

    /// Set the border radius of the text input bar at the bottom of the chat widget (e.g. "6px").
    public let inputBorderRadius: String?

    /// Set the border radius of chat message bubbles (e.g. "6px").
    public let messageBorderRadius: String?

    /// Set the background color of the chat interface (hex format).
    public let backgroundColor: String?

    /// Set the color for user message bubbles (hex format).
    public let userBubbleColor: String?

    /// Set the color for assistant/bot message bubbles (hex format).
    public let assistantBubbleColor: String?

    public init(
        companyId: String,
        profileId: String? = nil,
        activated: Bool = true,
        disableLauncher: Bool = false,
        buttonColor: String? = nil,
        debug: Bool = false,
        jwtToken: String? = nil,
        userData: UserData? = nil,
        disableCloseButton: Bool = false,
        disableHeader: Bool = false,
        attachmentIconVariant: AttachmentIconVariant? = nil,
        inputBorderRadius: String? = nil,
        messageBorderRadius: String? = nil,
        backgroundColor: String? = nil,
        userBubbleColor: String? = nil,
        assistantBubbleColor: String? = nil
    ) {
        self.companyId = companyId
        self.profileId = profileId
        self.activated = activated
        self.disableLauncher = disableLauncher
        self.buttonColor = buttonColor
        self.debug = debug
        self.jwtToken = jwtToken
        self.userData = userData
        self.disableCloseButton = disableCloseButton
        self.disableHeader = disableHeader
        self.attachmentIconVariant = attachmentIconVariant
        self.inputBorderRadius = inputBorderRadius
        self.messageBorderRadius = messageBorderRadius
        self.backgroundColor = backgroundColor
        self.userBubbleColor = userBubbleColor
        self.assistantBubbleColor = assistantBubbleColor
    }
}

// MARK: - Supporting Types

/// Icon variant options for the file attachment button.
public enum AttachmentIconVariant: String {
    case paperclip
    case plus
    case image
}

