import Foundation

/// Configuration settings for the Assembled chat widget.
///
/// Use this struct to customize the behavior and appearance of the chat widget.
/// In addition to the typed properties below, the ``options`` dictionary lets you
/// pass arbitrary key-value pairs that are forwarded to the chat widget as URL
/// query parameters. This means new configuration options can be used immediately
/// without an SDK update.
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
    
    /// Additional configuration options forwarded to the chat widget as
    /// URL query parameters.
    ///
    /// Keys use `snake_case` matching the widget's `data-*` attributes
    /// (strip `data-`, replace hyphens with underscores). If a key
    /// overlaps with a typed property above, the ``options`` value wins.
    ///
    /// See https://support.assembled.com/hc/en-us/articles/33739515754637
    /// for the full list of supported keys.
    public let options: [String: String]
    
    public init(
        companyId: String,
        profileId: String? = nil,
        activated: Bool = true,
        disableLauncher: Bool = false,
        buttonColor: String? = nil,
        debug: Bool = false,
        jwtToken: String? = nil,
        userData: UserData? = nil,
        options: [String: String] = [:]
    ) {
        self.companyId = companyId
        self.profileId = profileId
        self.activated = activated
        self.disableLauncher = disableLauncher
        self.buttonColor = buttonColor
        self.debug = debug
        self.jwtToken = jwtToken
        self.userData = userData
        self.options = options
    }
}

// MARK: - Internal helpers

extension AssembledChatConfiguration {
    /// Keys that are always handled directly by ``AssembledChatView/load()``
    /// and must not be duplicated from the ``options`` dictionary.
    private static let reservedKeys: Set<String> = ["company_id", "profile_id"]

    /// Merged query parameters from typed properties and ``options``.
    /// Typed properties form the base; ``options`` entries override on conflict.
    /// Returns a sorted array of tuples so the resulting URL is stable across
    /// runs, making it easier to debug and more cache-friendly.
    internal var allQueryParameters: [(key: String, value: String)] {
        var params: [String: String] = [:]

        if !activated {
            params["activated"] = "false"
        }
        if disableLauncher {
            params["disable_launcher"] = "true"
        }
        if let buttonColor = buttonColor {
            params["button_color"] = buttonColor
        }
        if debug {
            params["debug"] = "true"
        }

        for (key, value) in options where !Self.reservedKeys.contains(key) {
            params[key] = value
        }

        return params.sorted { $0.key < $1.key }
    }
}

