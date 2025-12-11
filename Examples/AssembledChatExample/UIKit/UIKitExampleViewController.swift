//
//  UIKitExampleViewController.swift
//  AssembledChatExample
//
//  UIKit implementation example - matches SwiftUI design
//

import UIKit
import AssembledChat

class UIKitExampleViewController: UIViewController {
    
    // MARK: - Properties
    private var userName: String = ""
    private var userEmail: String = ""
    private var companyId: String = "your-company-id"
    private var isDebugEnabled: Bool = false
    private var statusMessage: String?
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .onDrag
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
    
    // Header
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
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "UIKit Integration Example"
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    // User Info Fields
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let companyIdTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Company ID"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    private lazy var saveUserInfoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(" Save User Info", for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: #selector(saveUserInfo), for: .touchUpInside)
        return button
    }()
    
    // Chat Action Buttons
    private lazy var openChatModalButton: UIButton = {
        let button = createActionButton(title: "Open Chat Modal", icon: "arrow.up.right.square", color: .systemBlue)
        button.addTarget(self, action: #selector(openChatModal), for: .touchUpInside)
        return button
    }()
    
    private lazy var openFullScreenButton: UIButton = {
        let button = createActionButton(title: "Open Full Screen Chat", icon: "rectangle.portrait", color: .systemBlue)
        button.addTarget(self, action: #selector(openFullScreenChat), for: .touchUpInside)
        return button
    }()
    
    private lazy var debugModeButton: UIButton = {
        let button = createActionButton(title: "Enable Debug Mode", icon: "ant", color: .systemBlue)
        button.addTarget(self, action: #selector(toggleDebugMode), for: .touchUpInside)
        return button
    }()
    
    // Status Labels
    private let sdkVersionLabel = UIKitExampleViewController.createStatusRow(title: "SDK Version", value: "1.0.0")
    private let debugModeLabel = UIKitExampleViewController.createStatusRow(title: "Debug Mode", value: "Disabled")
    private let userLabel = UIKitExampleViewController.createStatusRow(title: "User", value: "Not set")
    
    private let statusMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserDefaults()
        setupUI()
        updateUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "UIKit Example"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        // Header Section
        let headerStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel, subtitleLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 12
        headerStack.alignment = .center
        contentStackView.addArrangedSubview(headerStack)
        
        // User Information Section
        let userInfoSection = createGroupBox(
            title: "User Information",
            icon: "person.circle",
            content: [nameTextField, emailTextField, companyIdTextField, saveUserInfoButton]
        )
        contentStackView.addArrangedSubview(userInfoSection)
        
        // Chat Actions Section
        let chatActionsSection = createGroupBox(
            title: "Chat Actions",
            icon: "bubble.left",
            content: [openChatModalButton, openFullScreenButton, debugModeButton]
        )
        contentStackView.addArrangedSubview(chatActionsSection)
        
        // Status Section
        let statusSection = createGroupBox(
            title: "Status",
            icon: "info.circle",
            content: [sdkVersionLabel, debugModeLabel, userLabel, statusMessageLabel]
        )
        contentStackView.addArrangedSubview(statusSection)
        
        // Constraints
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
        ])
        
        // Populate text fields
        nameTextField.text = userName
        emailTextField.text = userEmail
        companyIdTextField.text = companyId
    }
    
    private func createGroupBox(title: String, icon: String, content: [UIView]) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12
        
        // Header
        let iconImage = UIImageView(image: UIImage(systemName: icon))
        iconImage.tintColor = .secondaryLabel
        iconImage.contentMode = .scaleAspectFit
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        
        let headerStack = UIStackView(arrangedSubviews: [iconImage, titleLabel])
        headerStack.spacing = 6
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Content stack
        let contentStack = UIStackView(arrangedSubviews: content)
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(headerStack)
        container.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            iconImage.widthAnchor.constraint(equalToConstant: 16),
            iconImage.heightAnchor.constraint(equalToConstant: 16),
            
            headerStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            headerStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            headerStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            contentStack.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            contentStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
        ])
        
        return container
    }
    
    private func createActionButton(title: String, icon: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(" \(title)", for: .normal)
        button.setImage(UIImage(systemName: icon), for: .normal)
        button.tintColor = color
        button.contentHorizontalAlignment = .center
        button.layer.borderWidth = 1
        button.layer.borderColor = color.cgColor
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }
    
    private static func createStatusRow(title: String, value: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel.textColor = .secondaryLabel
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 15, weight: .medium)
        valueLabel.textAlignment = .right
        valueLabel.tag = 100 // Tag to find the value label later
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.distribution = .equalSpacing
        return stack
    }
    
    // MARK: - Actions
    @objc private func saveUserInfo() {
        userName = nameTextField.text ?? ""
        userEmail = emailTextField.text ?? ""
        companyId = companyIdTextField.text ?? "your-company-id"
        
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        UserDefaults.standard.set(companyId, forKey: "companyId")
        
        statusMessage = "User info saved successfully"
        updateUI()
        
        // Dismiss keyboard
        view.endEditing(true)
    }
    
    @objc private func openChatModal() {
        let chatVC = FullScreenChatViewController(companyId: companyId)
        let navController = UINavigationController(rootViewController: chatVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    @objc private func openFullScreenChat() {
        let chatVC = FullScreenChatViewController(companyId: companyId)
        let navController = UINavigationController(rootViewController: chatVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc private func toggleDebugMode() {
        isDebugEnabled.toggle()
        statusMessage = "Debug mode \(isDebugEnabled ? "enabled" : "disabled")"
        updateUI()
    }
    
    // MARK: - Helpers
    private func loadUserDefaults() {
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        if let savedCompanyId = UserDefaults.standard.string(forKey: "companyId"), !savedCompanyId.isEmpty {
            companyId = savedCompanyId
        }
    }
    
    private func updateUI() {
        // Update debug mode button
        let debugIcon = isDebugEnabled ? "ant.fill" : "ant"
        let debugTitle = isDebugEnabled ? "Disable Debug Mode" : "Enable Debug Mode"
        debugModeButton.setTitle(" \(debugTitle)", for: .normal)
        debugModeButton.setImage(UIImage(systemName: debugIcon), for: .normal)
        
        // Update status labels
        if let valueLabel = debugModeLabel.viewWithTag(100) as? UILabel {
            valueLabel.text = isDebugEnabled ? "Enabled" : "Disabled"
        }
        
        if let valueLabel = userLabel.viewWithTag(100) as? UILabel {
            valueLabel.text = userName.isEmpty ? "Not set" : userName
        }
        
        // Update status message
        if let message = statusMessage {
            statusMessageLabel.text = message
            statusMessageLabel.isHidden = false
        } else {
            statusMessageLabel.isHidden = true
        }
    }
}
