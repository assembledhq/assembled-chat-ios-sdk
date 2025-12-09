//
//  FullScreenChatViewController.swift
//  AssembledChatExample
//
//  Full screen chat view controller example
//

import UIKit
import AssembledChat

class FullScreenChatViewController: UIViewController {
    
    // MARK: - Properties
    private let companyId: String
    private var chatViewController: AssembledChatViewController?
    
    // MARK: - Initialization
    init(companyId: String) {
        self.companyId = companyId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupChatViewController()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Customer Support"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
    }
    
    private func setupChatViewController() {
        let config = AssembledChatConfiguration(companyId: companyId)
        chatViewController = AssembledChatViewController(configuration: config)
        
        guard let chatViewController = chatViewController else { return }
        
        // Add as child view controller
        addChild(chatViewController)
        view.addSubview(chatViewController.view)
        chatViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chatViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        chatViewController.didMove(toParent: self)
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

