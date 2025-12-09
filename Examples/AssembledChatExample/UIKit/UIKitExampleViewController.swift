//
//  UIKitExampleViewController.swift
//  AssembledChatExample
//
//  UIKit implementation example
//

import UIKit
import AssembledChat

class UIKitExampleViewController: UIViewController {
    
    // MARK: - Properties
    private var chat: AssembledChat?
    private let companyId = UserDefaults.standard.string(forKey: "companyId") ?? "your-company-id"
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .regular)
        imageView.image = UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: config)
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Assembled Chat SDK"
        label.font = .preferredFont(forTextStyle: .title2)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "UIKit Integration Example"
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let initializeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Initialize Chat", for: .normal)
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let openChatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Chat", for: .normal)
        button.setImage(UIImage(systemName: "message.fill"), for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let closeChatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close Chat", for: .normal)
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let showLauncherButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Launcher", for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let hideLauncherButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Hide Launcher", for: .normal)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let openViewControllerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Full Screen Chat", for: .normal)
        button.setImage(UIImage(systemName: "rectangle.portrait"), for: .normal)
        button.backgroundColor = .systemIndigo
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Status: Not initialized"
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "UIKit Example"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        // Setup header
        let headerStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel, subtitleLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 12
        headerStack.alignment = .center
        
        contentStackView.addArrangedSubview(headerStack)
        
        // Add action buttons
        contentStackView.addArrangedSubview(createSectionLabel("Initialization"))
        contentStackView.addArrangedSubview(initializeButton)
        
        contentStackView.addArrangedSubview(createSectionLabel("Chat Controls"))
        contentStackView.addArrangedSubview(openChatButton)
        contentStackView.addArrangedSubview(closeChatButton)
        
        contentStackView.addArrangedSubview(createSectionLabel("Launcher Controls"))
        contentStackView.addArrangedSubview(showLauncherButton)
        contentStackView.addArrangedSubview(hideLauncherButton)
        
        contentStackView.addArrangedSubview(createSectionLabel("Navigation"))
        contentStackView.addArrangedSubview(openViewControllerButton)
        
        contentStackView.addArrangedSubview(createSectionLabel("Status"))
        contentStackView.addArrangedSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            initializeButton.heightAnchor.constraint(equalToConstant: 50),
            openChatButton.heightAnchor.constraint(equalToConstant: 50),
            closeChatButton.heightAnchor.constraint(equalToConstant: 50),
            showLauncherButton.heightAnchor.constraint(equalToConstant: 50),
            hideLauncherButton.heightAnchor.constraint(equalToConstant: 50),
            openViewControllerButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func createSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }
    
    private func setupActions() {
        initializeButton.addTarget(self, action: #selector(initializeChat), for: .touchUpInside)
        openChatButton.addTarget(self, action: #selector(openChat), for: .touchUpInside)
        closeChatButton.addTarget(self, action: #selector(closeChat), for: .touchUpInside)
        showLauncherButton.addTarget(self, action: #selector(showLauncher), for: .touchUpInside)
        hideLauncherButton.addTarget(self, action: #selector(hideLauncher), for: .touchUpInside)
        openViewControllerButton.addTarget(self, action: #selector(openFullScreenChat), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func initializeChat() {
        let config = AssembledChatConfiguration(companyId: companyId)
        chat = AssembledChat(configuration: config)
        chat?.delegate = self
        
        Task {
            do {
                try await chat?.initialize()
                await MainActor.run {
                    updateStatus("Initialized successfully")
                    enableButtons()
                }
            } catch {
                await MainActor.run {
                    updateStatus("Initialization failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func openChat() {
        chat?.open()
        updateStatus("Chat opened")
    }
    
    @objc private func closeChat() {
        chat?.close()
        updateStatus("Chat closed")
    }
    
    @objc private func showLauncher() {
        chat?.showLauncher()
        updateStatus("Launcher shown")
    }
    
    @objc private func hideLauncher() {
        chat?.hideLauncher()
        updateStatus("Launcher hidden")
    }
    
    @objc private func openFullScreenChat() {
        let chatVC = FullScreenChatViewController(companyId: companyId)
        let navController = UINavigationController(rootViewController: chatVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    // MARK: - Helpers
    private func enableButtons() {
        openChatButton.isEnabled = true
        closeChatButton.isEnabled = true
        showLauncherButton.isEnabled = true
        hideLauncherButton.isEnabled = true
    }
    
    private func updateStatus(_ message: String) {
        statusLabel.text = "Status: \(message)"
    }
}

// MARK: - AssembledChatDelegate
extension UIKitExampleViewController: AssembledChatDelegate {
    func assembledChat(didReceiveError error: Error) {
        updateStatus("Error: \(error.localizedDescription)")
        print("❌ Chat error: \(error)")
    }
    
    func assembledChatDidOpen() {
        updateStatus("Chat is now open")
        print("✅ Chat opened")
    }
    
    func assembledChatDidClose() {
        updateStatus("Chat is now closed")
        print("✅ Chat closed")
    }
}

