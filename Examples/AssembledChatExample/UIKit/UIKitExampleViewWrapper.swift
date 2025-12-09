//
//  UIKitExampleViewWrapper.swift
//  AssembledChatExample
//
//  SwiftUI wrapper for UIKit view controller
//

import SwiftUI

struct UIKitExampleViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = UIKitExampleViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Nothing to update
    }
}

