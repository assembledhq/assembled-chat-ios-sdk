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
    
    var body: some View {
        NavigationView {
            AssembledChatSwiftUIView(companyId: companyId)
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

