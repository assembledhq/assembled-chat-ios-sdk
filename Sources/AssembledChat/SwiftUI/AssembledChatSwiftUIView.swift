import SwiftUI
import UIKit

@available(iOS 13.0, *)
public struct AssembledChatSwiftUIView: UIViewRepresentable {
    
    private let configuration: AssembledChatConfiguration
    private let delegate: AssembledChatDelegate?
    
    public init(configuration: AssembledChatConfiguration, delegate: AssembledChatDelegate? = nil) {
        self.configuration = configuration
        self.delegate = delegate
    }
    
    public init(companyId: String, delegate: AssembledChatDelegate? = nil) {
        self.configuration = AssembledChatConfiguration(companyId: companyId)
        self.delegate = delegate
    }
    
    public func makeUIView(context: Context) -> AssembledChatView {
        let chatView = AssembledChatView(configuration: configuration, delegate: delegate)
        chatView.load()
        return chatView
    }
    
    public func updateUIView(_ uiView: AssembledChatView, context: Context) {}
}

@available(iOS 13.0, *)
public class AssembledChatManager: ObservableObject {
    
    @Published public private(set) var isLoaded = false
    @Published public private(set) var isOpen = false
    @Published public private(set) var error: Error?
    @Published public private(set) var notifications: [ChatNotification] = []
    
    private let chat: AssembledChat
    
    public var chatInstance: AssembledChat {
        chat
    }
    
    public init(configuration: AssembledChatConfiguration) {
        self.chat = AssembledChat(configuration: configuration)
        self.chat.delegate = self
    }
    
    public convenience init(companyId: String) {
        let configuration = AssembledChatConfiguration(companyId: companyId)
        self.init(configuration: configuration)
    }
    
    public convenience init(companyId: String, profileId: String?) {
        let configuration = AssembledChatConfiguration(companyId: companyId, profileId: profileId)
        self.init(configuration: configuration)
    }
    
    public func initialize() async throws {
        try await chat.initialize()
    }
    
    public func open() {
        chat.open()
    }
    
    public func close() {
        chat.close()
    }
    
    public func authenticateUser(jwtToken: String, userData: UserData? = nil) async throws {
        try await chat.authenticateUser(jwtToken: jwtToken, userData: userData)
    }
    
    public func setUserData(_ userData: UserData) async throws {
        try await chat.setUserData(userData)
    }
    
    public func setDebug(_ enabled: Bool) {
        chat.setDebug(enabled)
    }
    
    public var isReady: Bool {
        chat.isReady
    }
}

@available(iOS 13.0, *)
extension AssembledChatManager: AssembledChatDelegate {
    public func assembledChatDidLoad() {
        Task { @MainActor in
            self.isLoaded = true
        }
    }
    
    public func assembledChatDidOpen() {
        Task { @MainActor in
            self.isOpen = true
        }
    }
    
    public func assembledChatDidClose() {
        Task { @MainActor in
            self.isOpen = false
        }
    }
    
    public func assembledChat(didReceiveError error: Error) {
        Task { @MainActor in
            self.error = error
        }
    }
    
    public func assembledChat(didReceiveNotification notification: ChatNotification) {
        Task { @MainActor in
            self.notifications.append(notification)
        }
    }
}

@available(iOS 13.0, *)
private struct AssembledChatManagerKey: EnvironmentKey {
    static let defaultValue: AssembledChatManager? = nil
}

@available(iOS 13.0, *)
public extension EnvironmentValues {
    var assembledChatManager: AssembledChatManager? {
        get { self[AssembledChatManagerKey.self] }
        set { self[AssembledChatManagerKey.self] = newValue }
    }
}

@available(iOS 13.0, *)
public extension View {
    func assembledChatManager(_ manager: AssembledChatManager) -> some View {
        environment(\.assembledChatManager, manager)
    }
}

@available(iOS 13.0, *)
public struct AssembledChatFloatingButton: View {
    
    @ObservedObject private var manager: AssembledChatManager
    private let position: Position
    private let offset: CGSize
    private let buttonColor: Color
    private let iconSize: CGFloat
    private let buttonSize: CGFloat
    private let shadowRadius: CGFloat
    private let shadowOpacity: Double
    
    public enum Position {
        case topLeading
        case topTrailing
        case bottomLeading
        case bottomTrailing
    }
    
    /// Default offset provides standard spacing from screen edges.
    /// -20 points matches common iOS design patterns for floating action buttons,
    /// providing comfortable padding while keeping the button visible.
    public init(
        manager: AssembledChatManager,
        position: Position = .bottomTrailing,
        offset: CGSize = CGSize(width: -20, height: -20),
        buttonColor: Color = .blue,
        iconSize: CGFloat = 28,
        buttonSize: CGFloat = 56,
        shadowRadius: CGFloat = 10,
        shadowOpacity: Double = 0.2
    ) {
        self.manager = manager
        self.position = position
        self.offset = offset
        self.buttonColor = buttonColor
        self.iconSize = iconSize
        self.buttonSize = buttonSize
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
    }
    
    public var body: some View {
        Button(action: {
            if manager.isOpen {
                manager.close()
            } else {
                manager.open()
            }
        }) {
            Image(systemName: manager.isOpen ? "xmark.circle.fill" : "bubble.left.and.bubble.right.fill")
                .font(.system(size: iconSize))
                .foregroundColor(.white)
                .frame(width: buttonSize, height: buttonSize)
                .background(buttonColor)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: 5)
        }
        .overlay(
            notificationBadge
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        .offset(offset)
    }
    
    @ViewBuilder
    private var notificationBadge: some View {
        if !manager.notifications.isEmpty && !manager.isOpen {
            Circle()
                .fill(Color.red)
                .frame(width: 20, height: 20)
                .overlay(
                    Text("\(manager.notifications.count)")
                        .font(.caption)
                        .foregroundColor(.white)
                )
                .offset(x: 18, y: -18)
        }
    }
    
    private var alignment: Alignment {
        switch position {
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        case .bottomLeading: .bottomLeading
        case .bottomTrailing: .bottomTrailing
        }
    }
}

