import UIKit

public class AssembledChatViewController: UIViewController {
    
    private let chat: AssembledChat
    private var chatView: AssembledChatView?
    
    public var chatInstance: AssembledChat {
        chat
    }
    
    public init(chat: AssembledChat) {
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init(configuration: AssembledChatConfiguration) {
        let chat = AssembledChat(configuration: configuration)
        self.init(chat: chat)
    }
    
    public convenience init(companyId: String) {
        let configuration = AssembledChatConfiguration(companyId: companyId)
        self.init(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        if presentingViewController != nil {
            setupCloseButton()
        }
        
        setupChatView()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !chat.isReady {
            Task {
                try? await chat.initialize()
                chat.open()
            }
        }
    }
    
    /// Sets up a close button in the navigation bar when the view controller
    /// is presented modally. This provides a standard iOS pattern for dismissing
    /// modal presentations. The chat widget itself may also have its own close
    /// button, but this ensures users can always dismiss the modal presentation.
    private func setupCloseButton() {
        // Only add close button if presented modally
        guard presentingViewController != nil else { return }
        
        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setupChatView() {
        let configuration = chat.configuration
        let chatView = AssembledChatView(configuration: configuration, delegate: chat.delegate)
        chatView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(chatView)
        
        NSLayoutConstraint.activate([
            chatView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        self.chatView = chatView
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

