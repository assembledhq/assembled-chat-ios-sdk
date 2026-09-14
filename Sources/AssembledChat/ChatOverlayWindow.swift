import UIKit

/// Hosts the window-level chat overlay used by `AssembledChat.initialize()`.
///
/// WebKit presents native UI (the `<input type="file">` picker, camera, share
/// sheets) from the view controller that owns the web view. A bare view added
/// directly to the app's key window has no owning view controller, so those
/// presentations silently fail. Giving the overlay its own window and root view
/// controller gives WebKit a reliable presenter.
final class ChatOverlayWindow: UIWindow {

    private weak var previousKeyWindow: UIWindow?

    init(chatView: AssembledChatView, keyWindow: UIWindow) {
        if let scene = keyWindow.windowScene {
            super.init(windowScene: scene)
        } else {
            super.init(frame: keyWindow.frame)
        }

        windowLevel = keyWindow.windowLevel + 1
        backgroundColor = .clear
        rootViewController = ChatHostViewController(chatView: chatView)
        isHidden = false

        chatView.visibilityDidChange = { [weak self] isVisible in
            self?.chatVisibilityDidChange(isVisible)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func chatVisibilityDidChange(_ isVisible: Bool) {
        if isVisible {
            if !isKeyWindow {
                previousKeyWindow = Self.currentKeyWindow(excluding: self)
                makeKey()
            }
        } else {
            restorePreviousKeyWindow()
        }
    }

    private func restorePreviousKeyWindow() {
        if isKeyWindow, let previous = previousKeyWindow, !previous.isHidden {
            previous.makeKey()
        }
        previousKeyWindow = nil
    }

    func dismantle() {
        restorePreviousKeyWindow()
        isHidden = true
        rootViewController = nil
        windowScene = nil
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self || hitView == rootViewController?.view {
            return nil
        }
        return hitView
    }

    private static func currentKeyWindow(excluding window: UIWindow) -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow && $0 !== window }
    }
}

final class ChatHostViewController: UIViewController {

    private let chatView: AssembledChatView

    init(chatView: AssembledChatView) {
        self.chatView = chatView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        chatView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chatView)

        NSLayoutConstraint.activate([
            chatView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .all
    }
}
