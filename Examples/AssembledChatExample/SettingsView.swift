//
//  SettingsView.swift
//  AssembledChatExample
//
//  Settings and configuration
//

import SwiftUI
import AssembledChat

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showAuthSheet = false
    
    var body: some View {
        NavigationView {
            Form {
                // Company Configuration
                Section {
                    TextField("Company ID", text: $viewModel.companyId)
                        .autocapitalization(.none)
                    
                    TextField("Profile ID (Optional)", text: $viewModel.profileId)
                        .autocapitalization(.none)
                } header: {
                    Text("Company Configuration")
                } footer: {
                    Text("Enter your Assembled company ID. Profile ID is optional.")
                }
                
                // User Information
                Section {
                    TextField("Name", text: $viewModel.userName)
                    
                    TextField("Email", text: $viewModel.userEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Phone (Optional)", text: $viewModel.userPhone)
                        .keyboardType(.phonePad)
                } header: {
                    Text("User Information")
                }
                
                // Authentication
                Section {
                    Button(action: { showAuthSheet = true }) {
                        HStack {
                            Text("Set JWT Token")
                            Spacer()
                            Image(systemName: "key.fill")
                        }
                    }
                    
                    if viewModel.hasJWTToken {
                        HStack {
                            Text("JWT Status")
                            Spacer()
                            Text("Configured")
                                .foregroundColor(.green)
                        }
                    }
                } header: {
                    Text("Authentication")
                } footer: {
                    Text("Optional: Add a JWT token for authenticated user sessions.")
                }
                
                // Debug Options
                Section {
                    Toggle("Debug Mode", isOn: $viewModel.debugMode)
                    
                    Toggle("Show Console Logs", isOn: $viewModel.showConsoleLogs)
                } header: {
                    Text("Debug Options")
                }
                
                // About
                Section {
                    HStack {
                        Text("SDK Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://www.assembled.com")!) {
                        HStack {
                            Text("About Assembled")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                    }
                    
                    Link(destination: URL(string: "https://github.com/assembledhq/assembled-chat-ios-sdk")!) {
                        HStack {
                            Text("GitHub Repository")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                    }
                } header: {
                    Text("About")
                }
                
                // Actions
                Section {
                    Button(action: viewModel.saveSettings) {
                        HStack {
                            Spacer()
                            Text("Save Settings")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .foregroundColor(.blue)
                    
                    Button(role: .destructive, action: viewModel.resetSettings) {
                        HStack {
                            Spacer()
                            Text("Reset to Defaults")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showAuthSheet) {
                JWTTokenSheet(viewModel: viewModel)
            }
            .alert("Settings Saved", isPresented: $viewModel.showSuccessAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}

// MARK: - JWT Token Sheet
struct JWTTokenSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SettingsViewModel
    @State private var jwtToken = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextEditor(text: $jwtToken)
                        .frame(minHeight: 150)
                        .font(.system(.body, design: .monospaced))
                } header: {
                    Text("JWT Token")
                } footer: {
                    Text("Enter your JWT token for authenticated sessions. This will be stored securely.")
                }
                
                Section {
                    Button("Save Token") {
                        viewModel.jwtToken = jwtToken
                        dismiss()
                    }
                    .disabled(jwtToken.isEmpty)
                    
                    if viewModel.hasJWTToken {
                        Button("Clear Token", role: .destructive) {
                            viewModel.jwtToken = ""
                            jwtToken = ""
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("JWT Authentication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            jwtToken = viewModel.jwtToken
        }
    }
}

// MARK: - View Model
@MainActor
class SettingsViewModel: ObservableObject {
    @Published var companyId: String = "your-company-id"
    @Published var profileId: String = ""
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userPhone: String = ""
    @Published var jwtToken: String = ""
    @Published var debugMode: Bool = false
    @Published var showConsoleLogs: Bool = false
    @Published var showSuccessAlert: Bool = false
    
    var hasJWTToken: Bool {
        !jwtToken.isEmpty
    }
    
    init() {
        loadSettings()
    }
    
    func saveSettings() {
        UserDefaults.standard.set(companyId, forKey: "companyId")
        UserDefaults.standard.set(profileId, forKey: "profileId")
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        UserDefaults.standard.set(userPhone, forKey: "userPhone")
        UserDefaults.standard.set(debugMode, forKey: "debugMode")
        UserDefaults.standard.set(showConsoleLogs, forKey: "showConsoleLogs")
        
        // Store JWT token securely (in a real app, use Keychain)
        if !jwtToken.isEmpty {
            UserDefaults.standard.set(jwtToken, forKey: "jwtToken")
        }
        
        showSuccessAlert = true
    }
    
    func resetSettings() {
        companyId = "your-company-id"
        profileId = ""
        userName = ""
        userEmail = ""
        userPhone = ""
        jwtToken = ""
        debugMode = false
        showConsoleLogs = false
        
        // Clear UserDefaults
        let keys = ["companyId", "profileId", "userName", "userEmail", "userPhone", "jwtToken", "debugMode", "showConsoleLogs"]
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }
    
    private func loadSettings() {
        companyId = UserDefaults.standard.string(forKey: "companyId") ?? "your-company-id"
        profileId = UserDefaults.standard.string(forKey: "profileId") ?? ""
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        userPhone = UserDefaults.standard.string(forKey: "userPhone") ?? ""
        jwtToken = UserDefaults.standard.string(forKey: "jwtToken") ?? ""
        debugMode = UserDefaults.standard.bool(forKey: "debugMode")
        showConsoleLogs = UserDefaults.standard.bool(forKey: "showConsoleLogs")
    }
}

#Preview {
    SettingsView()
}

