//
//  SwiftUIExampleView.swift
//  AssembledChatExample
//
//  SwiftUI implementation example
//

import SwiftUI
import AssembledChat

struct SwiftUIExampleView: View {
    @StateObject private var viewModel = SwiftUIExampleViewModel()
    @State private var showChat = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // User Info Section
                    userInfoSection
                    
                    // Actions Section
                    actionsSection
                    
                    // Status Section
                    statusSection
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("SwiftUI Example")
            .sheet(isPresented: $showChat) {
                ChatModalView(companyId: viewModel.companyId)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Assembled Chat SDK")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("SwiftUI Integration Example")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var userInfoSection: some View {
        GroupBox(label: Label("User Information", systemImage: "person.circle")) {
            VStack(spacing: 16) {
                TextField("Name", text: $viewModel.userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Email", text: $viewModel.userEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                TextField("Company ID", text: $viewModel.companyId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                Button(action: viewModel.saveUserInfo) {
                    Label("Save User Info", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.userName.isEmpty || viewModel.userEmail.isEmpty)
            }
            .padding(.vertical, 8)
        }
    }
    
    private var actionsSection: some View {
        GroupBox(label: Label("Chat Actions", systemImage: "bubble.left")) {
            VStack(spacing: 12) {
                Button(action: { showChat = true }) {
                    Label("Open Chat Modal", systemImage: "arrow.up.right.square")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                NavigationLink(destination: EmbeddedChatView(companyId: viewModel.companyId)) {
                    Label("Open Embedded Chat", systemImage: "rectangle.portrait")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: viewModel.toggleDebugMode) {
                    Label(
                        viewModel.isDebugEnabled ? "Disable Debug Mode" : "Enable Debug Mode",
                        systemImage: viewModel.isDebugEnabled ? "ant.fill" : "ant"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 8)
        }
    }
    
    private var statusSection: some View {
        GroupBox(label: Label("Status", systemImage: "info.circle")) {
            VStack(alignment: .leading, spacing: 8) {
                StatusRow(title: "SDK Version", value: "1.0.0")
                StatusRow(title: "Debug Mode", value: viewModel.isDebugEnabled ? "Enabled" : "Disabled")
                StatusRow(title: "User", value: viewModel.userName.isEmpty ? "Not set" : viewModel.userName)
                
                if let lastMessage = viewModel.statusMessage {
                    Divider()
                    Text(lastMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
        }
    }
}

struct StatusRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - View Model
@MainActor
class SwiftUIExampleViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var companyId: String = "your-company-id"
    @Published var isDebugEnabled: Bool = false
    @Published var statusMessage: String?
    
    init() {
        loadUserDefaults()
    }
    
    func saveUserInfo() {
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        UserDefaults.standard.set(companyId, forKey: "companyId")
        statusMessage = "User info saved successfully"
    }
    
    func toggleDebugMode() {
        isDebugEnabled.toggle()
        statusMessage = "Debug mode \(isDebugEnabled ? "enabled" : "disabled")"
    }
    
    private func loadUserDefaults() {
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        if let savedCompanyId = UserDefaults.standard.string(forKey: "companyId"), !savedCompanyId.isEmpty {
            companyId = savedCompanyId
        }
    }
}

#Preview {
    SwiftUIExampleView()
}

