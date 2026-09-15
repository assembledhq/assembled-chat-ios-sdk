import UIKit

/// Gives the window-level chat view a view-controller owner without creating
/// another UIWindow.
///
/// WebKit needs an owning view controller to present native UI such as the
/// photo/file picker. The controller's root view is placed in the app's existing
/// window, leaving status bar appearance, alerts, keyboard focus, and
/// orientation under the host app's control.
final class ChatOverlayHost {

    private let hostViewController: ChatHostViewController
    private weak var hostWindow: UIWindow?
    private weak var hostWindowScene: UIWindowScene?

    init(chatView: AssembledChatView, keyWindow: UIWindow) {
        hostViewController = ChatHostViewController(chatView: chatView)
        hostWindowScene = keyWindow.windowScene
        attach(to: keyWindow)
        hostViewController.view.isHidden = true

        chatView.visibilityDidChange = { [weak self] isVisible in
            self?.setVisible(isVisible)
        }
    }

    deinit {
        let controller = hostViewController
        let cleanup = {
            controller.chatView.visibilityDidChange = nil
            controller.viewIfLoaded?.removeFromSuperview()
        }

        if Thread.isMainThread {
            cleanup()
        } else {
            DispatchQueue.main.async(execute: cleanup)
        }
    }

    private func setVisible(_ isVisible: Bool) {
        if isVisible {
            reattachIfNeeded()
            hostViewController.view.isHidden = false
            hostWindow?.bringSubviewToFront(hostViewController.view)
        } else {
            hostViewController.view.isHidden = true
        }
    }

    /// If the host app replaces its root window (for example at login/logout),
    /// move chat into the new active hierarchy the next time it opens.
    private func reattachIfNeeded() {
        guard hostViewController.view.window == nil ||
                hostWindow == nil ||
                hostWindow?.isHidden == true else {
            return
        }
        guard let scene = hostWindowScene,
              let keyWindow = scene.windows.first(where: \.isKeyWindow) else {
            return
        }
        attach(to: keyWindow)
    }

    private func attach(to window: UIWindow) {
        detach()

        // Keep the same window-level z-ordering as the original implementation:
        // host presentations added later can still appear above chat. The root
        // view belongs to ChatHostViewController, giving WebKit the presenter it
        // needs without inserting views into UIKit/SwiftUI-managed hierarchies.
        window.addSubview(hostViewController.view)
        hostViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostViewController.view.topAnchor.constraint(equalTo: window.topAnchor),
            hostViewController.view.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            hostViewController.view.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            hostViewController.view.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        ])

        hostWindow = window
        hostWindowScene = window.windowScene
    }

    private func detach() {
        hostViewController.view.removeFromSuperview()
    }

    func dismantle() {
        hostViewController.chatView.visibilityDidChange = nil
        detach()
        hostWindow = nil
        hostWindowScene = nil
    }
}

final class ChatHostViewController: UIViewController {

    let chatView: AssembledChatView

    init(chatView: AssembledChatView) {
        self.chatView = chatView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = PassthroughRootView()
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
}

private final class PassthroughRootView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView === self ? nil : hitView
    }
}
