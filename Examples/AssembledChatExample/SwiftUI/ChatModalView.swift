//
//  ChatModalView.swift
//  AssembledChatExample
//
//  Modal presentation of AssembledChat
//

import SwiftUI
import AssembledChat

struct ChatModalView: View {
    @Environment(\.dismiss) private var dismiss
    let companyId: String
    var userData: UserData? = nil

    var body: some View {
        NavigationView {
            AssembledChatSwiftUIView(
                configuration: AssembledChatConfiguration(
                    companyId: companyId,
                    userData: userData
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ChatModalView(companyId: "demo-company-id")
}

