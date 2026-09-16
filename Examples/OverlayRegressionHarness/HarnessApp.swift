import UIKit
import WebKit
@testable import AssembledChat

@main
final class HarnessAppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: "Harness",
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = HarnessSceneDelegate.self
        return configuration
    }
}

final class HarnessSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = HarnessViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}

@MainActor
final class HarnessViewController: UIViewController {
    private enum LocalChatFixture {
        static let configuration = AssembledChatConfiguration(companyId: "local-fixture")

        static let html = """
        <!doctype html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            html, body { height: 100%; margin: 0; font: 17px -apple-system; }
            body { background: transparent; }
            button { min-height: 44px; font: inherit; }
            #launcher { position: fixed; right: 20px; bottom: 20px; }
            #chat { position: fixed; inset: 0; background: white; padding: 80px 24px; }
          </style>
        </head>
        <body>
          <button id="launcher" aria-label="Ask us a question" hidden>Ask us a question</button>
          <main id="chat" hidden>
            <p>LOCAL FIXTURE READY</p>
            <button id="ask" aria-label="Ask us a question">Ask us a question</button>
            <button id="attachment" aria-label="Attach image">Attach image</button>
            <input id="file" type="file" accept="image/*" hidden>
          </main>
          <script>
            const launcher = document.getElementById("launcher");
            const chat = document.getElementById("chat");
            const file = document.getElementById("file");

            function emit(type) {
              window.postMessage({ type }, "*");
            }

            function setChatVisible(isVisible) {
              chat.hidden = !isVisible;
              if (isVisible) launcher.hidden = true;
            }

            launcher.addEventListener("click", () => {
              launcher.hidden = true;
              setChatVisible(true);
              emit("ASSEMBLED_OPEN");
            });

            document.getElementById("attachment").addEventListener("click", () => {
              file.click();
            });

            window.addEventListener("message", event => {
              const message = event.data || {};
              if (message.type === "SET_VISIBILITY") {
                setChatVisible(Boolean(message.isVisible));
              } else if (message.type === "SET_LAUNCHER_VISIBILITY") {
                launcher.hidden = !message.isVisible;
                if (message.isVisible) chat.hidden = true;
              }
            });

            window.addEventListener("DOMContentLoaded", () => {
              emit("ASSEMBLED_LOADED");
            });
          </script>
        </body>
        </html>
        """
    }

    private var chat: AssembledChat?
    private var replacementWindow: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "Overlay Regression Harness"
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.textAlignment = .center

        let buttons = [
            makeButton("Local fixture attachment", id: "harness.attachment", action: #selector(runAttachment)),
            makeButton("Show launcher", id: "harness.launcher", action: #selector(runLauncher)),
            makeButton("Initialize only", id: "harness.initializeOnly", action: #selector(runInitializeOnly)),
            makeButton("Host alert over chat", id: "harness.alert", action: #selector(runAlert)),
            makeButton("Replace host + keyboard", id: "harness.keyboard", action: #selector(runKeyboard)),
            makeButton("Portrait host", id: "harness.orientation", action: #selector(runOrientation))
        ]

        let stack = UIStackView(arrangedSubviews: [titleLabel] + buttons)
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func makeButton(
        _ title: String,
        id: String,
        action: Selector
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.accessibilityIdentifier = id
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func configuration() -> AssembledChatConfiguration {
        LocalChatFixture.configuration
    }

    private func startChat(open: Bool) async throws {
        chat?.teardown()
        let chat = AssembledChat(
            configuration: configuration(),
            fixtureHTML: LocalChatFixture.html
        )
        self.chat = chat
        try await chat.initialize()
        if open {
            chat.open()
        }
    }

    @objc private func runAttachment() {
        let host = ScenarioViewController(
            title: "Local fixture host",
            statusID: "harness.fixtureHost"
        )
        host.onAppearOnce = { [weak self] in
            Task { try? await self?.startChat(open: true) }
        }
        host.modalPresentationStyle = .pageSheet
        present(host, animated: true)
    }

    @objc private func runLauncher() {
        Task {
            try? await startChat(open: false)
            chat?.showLauncher()
        }
    }

    @objc private func runInitializeOnly() {
        let host = StatusProbeViewController()
        host.onAppearOnce = { [weak self, weak host] in
            Task {
                try? await self?.startChat(open: false)
                try? await Task.sleep(nanoseconds: 500_000_000)
                host?.recordCurrentAppearance()
            }
        }
        host.modalPresentationStyle = .fullScreen
        present(host, animated: true)
    }

    @objc private func runAlert() {
        Task {
            try? await startChat(open: true)
            try? await Task.sleep(nanoseconds: 5_000_000_000)

            let alert = UIAlertController(
                title: "HOST ALERT — MUST BE VISIBLE",
                message: "The host presented this while chat was open.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Reachable", style: .default))
            present(alert, animated: true)
        }
    }

    @objc private func runKeyboard() {
        guard let scene = view.window?.windowScene,
              let sceneDelegate = scene.delegate as? HarnessSceneDelegate else {
            return
        }
        weak var originalWindow = view.window

        Task {
            try? await startChat(open: true)
            try? await Task.sleep(nanoseconds: 5_000_000_000)

            let probe = KeyboardProbeViewController()
            let replacement = UIWindow(windowScene: scene)
            replacement.rootViewController = probe
            replacement.isHidden = false
            replacementWindow = replacement
            sceneDelegate.window = replacement
            originalWindow?.isHidden = true

            try? await Task.sleep(nanoseconds: 2_000_000_000)
            chat?.close()
            try? await Task.sleep(nanoseconds: 500_000_000)
            chat?.open()
            try? await Task.sleep(nanoseconds: 500_000_000)
            probe.retainChat(chat)
            probe.record(keyWindow: scene.windows.first(where: \.isKeyWindow), expected: replacement)
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            chat?.close()
        }
    }

    @objc private func runOrientation() {
        let host = PortraitProbeViewController()
        host.onAppearOnce = { [weak self] in
            Task { try? await self?.startChat(open: true) }
        }
        host.modalPresentationStyle = .fullScreen
        present(host, animated: true)
    }
}

class ScenarioViewController: UIViewController {
    var onAppearOnce: (() -> Void)?
    private let heading: String
    private let statusID: String
    private var appeared = false

    init(title: String, statusID: String) {
        heading = title
        self.statusID = statusID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let label = UILabel()
        label.text = heading
        label.font = .preferredFont(forTextStyle: .title1)
        label.textAlignment = .center
        label.accessibilityIdentifier = statusID
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !appeared else { return }
        appeared = true
        onAppearOnce?()
    }
}

final class StatusProbeViewController: ScenarioViewController {
    init() {
        super.init(title: "INITIALIZE-ONLY HOST VISIBLE", statusID: "harness.initializeHost")
        overrideUserInterfaceStyle = .light
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.05, green: 0.12, blue: 0.24, alpha: 1)
        view.subviews.compactMap { $0 as? UILabel }.forEach { $0.textColor = .white }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    func recordCurrentAppearance() {
        let statusStyle = view.window?.windowScene?.statusBarManager?.statusBarStyle
        let lightStatus = statusStyle == .lightContent
        let label = UILabel()
        label.text = lightStatus ? "APPEARANCE PASS" : "APPEARANCE FAIL"
        label.accessibilityIdentifier = "harness.appearanceResult"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 48)
        ])
    }
}

final class PortraitProbeViewController: ScenarioViewController {
    init() {
        super.init(title: "PORTRAIT-ONLY HOST", statusID: "harness.portraitHost")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
}

final class KeyboardProbeViewController: UIViewController {
    private let resultLabel = UILabel()
    private let reattachLabel = UILabel()
    private var retainedChat: AssembledChat?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        resultLabel.textAlignment = .center
        resultLabel.accessibilityIdentifier = "harness.keyboardResult"

        reattachLabel.textAlignment = .center
        reattachLabel.accessibilityIdentifier = "harness.reattachResult"

        let field = UITextField()
        field.placeholder = "Keyboard must appear"
        field.borderStyle = .roundedRect
        field.accessibilityIdentifier = "harness.keyboardField"

        let stack = UIStackView(arrangedSubviews: [resultLabel, reattachLabel, field])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func record(keyWindow: UIWindow?, expected: UIWindow) {
        resultLabel.text = keyWindow === expected ? "KEY WINDOW PASS" : "KEY WINDOW FAIL"
        reattachLabel.text = containsVisibleWebView(in: expected)
            ? "CHAT REATTACH PASS"
            : "CHAT REATTACH FAIL"
    }

    func retainChat(_ chat: AssembledChat?) {
        retainedChat = chat
    }

    private func containsVisibleWebView(in view: UIView) -> Bool {
        guard !view.isHidden, view.alpha > 0.01 else { return false }
        if view is WKWebView {
            return view.window != nil
        }
        return view.subviews.contains(where: containsVisibleWebView)
    }
}
