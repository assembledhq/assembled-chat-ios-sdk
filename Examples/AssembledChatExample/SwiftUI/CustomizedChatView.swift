//
//  CustomizedChatView.swift
//  AssembledChatExample
//
//  Demonstrates UI customization options
//

import SwiftUI
import AssembledChat

struct CustomizedChatView: View {
    let companyId: String

    var body: some View {
        VStack(spacing: 0) {
            // Info banner showing what customizations are applied
            customizationInfoBanner

            // Customized chat with all new UI options
            AssembledChatSwiftUIView(configuration: customizedConfiguration)
        }
        .navigationTitle("Customized Chat")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var customizationInfoBanner: some View {
        VStack(spacing: 12) {
            Text("🎨 UI Customization Demo")
                .font(.headline)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 6) {
                CustomizationBadge(icon: "xmark.circle", text: "Header Disabled", color: .red)
                CustomizationBadge(icon: "xmark.circle", text: "Close Button Disabled", color: .orange)
                CustomizationBadge(icon: "paintpalette", text: "Custom Button Color (#FF6B6B)", color: .pink)
                CustomizationBadge(icon: "circle", text: "16px Border Radius", color: .purple)
                CustomizationBadge(icon: "paperclip", text: "Paperclip Attachment Icon", color: .blue)
                CustomizationBadge(icon: "paintbrush.fill", text: "Beige Background (#F5F5DC)", color: .brown)
                CustomizationBadge(icon: "bubble.right.fill", text: "Orange User Bubble (#FF9800)", color: .orange)
                CustomizationBadge(icon: "bubble.left.fill", text: "Green AI Bubble (#4CAF50)", color: .green)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private var customizedConfiguration: AssembledChatConfiguration {
        AssembledChatConfiguration(
            companyId: companyId,
            buttonColor: "#FF6B6B",  // Custom red color
            disableCloseButton: true,  // Hide close button
            disableHeader: true,  // Hide header for embedded look
            attachmentIconVariant: .paperclip,  // Use paperclip icon
            inputBorderRadius: "16px",  // Rounded input field
            messageBorderRadius: "16px",  // Rounded message bubbles
            backgroundColor: "#F5F5DC",  // Beige background
            userBubbleColor: "#FF9800",  // Orange user message bubbles
            assistantBubbleColor: "#4CAF50"  // Green AI message bubbles
        )
    }
}

struct CustomizationBadge: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 20, height: 20)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())

            Text(text)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    NavigationView {
        CustomizedChatView(companyId: "demo-company-id")
    }
}
