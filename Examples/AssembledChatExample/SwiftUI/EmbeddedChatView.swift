//
//  EmbeddedChatView.swift
//  AssembledChatExample
//
//  Embedded chat view example
//

import SwiftUI
import AssembledChat

struct EmbeddedChatView: View {
    let companyId: String
    @State private var profileId: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header
            VStack(spacing: 8) {
                Text("Customer Support")
                    .font(.headline)
                
                if !profileId.isEmpty {
                    TextField("Profile ID (optional)", text: $profileId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(radius: 2)
            
            // Embedded chat
            AssembledChatSwiftUIView(
                companyId: companyId,
                profileId: profileId.isEmpty ? nil : profileId
            )
        }
        .navigationTitle("Embedded Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        EmbeddedChatView(companyId: "demo-company-id")
    }
}

