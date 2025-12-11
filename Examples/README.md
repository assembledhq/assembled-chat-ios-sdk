# AssembledChat iOS SDK - Example App

This example app demonstrates how to integrate and use the [AssembledChat iOS SDK](https://github.com/assembledhq/assembled-chat-ios-sdk) in your iOS applications.

## 📱 What's Included

The example app showcases both **SwiftUI** and **UIKit** implementations with the following features:

### SwiftUI Examples
- ✅ Basic chat integration with `AssembledChatSwiftUIView`
- ✅ Modal presentation of chat
- ✅ Embedded chat view in navigation flow
- ✅ User data configuration
- ✅ Debug mode toggle
- ✅ Custom UI integration

### UIKit Examples
- ✅ Programmatic chat initialization
- ✅ Full delegate pattern implementation
- ✅ Chat lifecycle management (open, close, show/hide launcher)
- ✅ Full-screen chat view controller
- ✅ Child view controller embedding
- ✅ Custom navigation integration

### Settings & Configuration
- ✅ Company ID configuration
- ✅ User information management
- ✅ JWT authentication setup
- ✅ Debug options
- ✅ Persistent settings storage

## 🚀 Getting Started

### Prerequisites

- **iOS 15.0+**
- **Xcode 14.0+**
- **Swift 5.9+**
- An Assembled company ID (get one at [assembled.com](https://www.assembled.com))

### Installation

1. **Clone the repository:**

```bash
git clone https://github.com/assembledhq/assembled-chat-ios-sdk.git
cd assembled-chat-ios-sdk/Examples
```

2. **Open in Xcode:**

```bash
open AssembledChatExample.xcodeproj
```

3. **Build and run in Xcode:**
   - **Wait** for Xcode to finish resolving packages (check the status bar)
   - **Select simulator**: Click the device dropdown (top center) → choose **iPhone 16** (or any iPhone)
   - **Run**: Press `Cmd + R` (or click ▶️) to build, install, and launch the app

> **Note:** Xcode will automatically open the iOS Simulator when you run the app.

### Configuration

1. **Set your Company ID:**
   - Launch the app
   - Go to the **Settings** tab
   - Enter your Assembled company ID
   - Tap "Save Settings"

2. **Configure User Information (Optional):**
   - Enter user name and email in Settings
   - This will be used to identify users in chat sessions

3. **JWT Authentication (Optional):**
   - For authenticated sessions, tap "Set JWT Token" in Settings
   - Enter your JWT token
   - The token will be used for secure user authentication

## 📖 Usage Examples

### SwiftUI Integration

#### Basic Usage

```swift
import SwiftUI
import AssembledChat

struct ContentView: View {
    var body: some View {
        AssembledChatSwiftUIView(companyId: "your-company-id")
    }
}
```

#### Modal Presentation

```swift
struct MyView: View {
    @State private var showChat = false
    
    var body: some View {
        Button("Open Chat") {
            showChat = true
        }
        .sheet(isPresented: $showChat) {
            AssembledChatSwiftUIView(companyId: "your-company-id")
        }
    }
}
```

#### With Profile ID

```swift
AssembledChatSwiftUIView(
    companyId: "your-company-id",
    profileId: "user-profile-id"
)
```

### UIKit Integration

#### Basic Setup

```swift
import UIKit
import AssembledChat

class ViewController: UIViewController {
    private var chat: AssembledChat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChat()
    }
    
    private func setupChat() {
        let config = AssembledChatConfiguration(companyId: "your-company-id")
        chat = AssembledChat(configuration: config)
        chat?.delegate = self
        
        Task {
            try await chat?.initialize()
        }
    }
    
    @objc private func openChat() {
        chat?.open()
    }
}

extension ViewController: AssembledChatDelegate {
    func assembledChat(didReceiveError error: Error) {
        print("Chat error: \(error)")
    }
    
    func assembledChatDidOpen() {
        print("Chat opened")
    }
    
    func assembledChatDidClose() {
        print("Chat closed")
    }
}
```

#### Full-Screen View Controller

```swift
import UIKit
import AssembledChat

class ChatViewController: UIViewController {
    private var chatViewController: AssembledChatViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = AssembledChatConfiguration(companyId: "your-company-id")
        chatViewController = AssembledChatViewController(configuration: config)
        
        guard let chatVC = chatViewController else { return }
        
        // Add as child view controller
        addChild(chatVC)
        view.addSubview(chatVC.view)
        chatVC.view.frame = view.bounds
        chatVC.didMove(toParent: self)
    }
}
```

#### User Authentication

```swift
// Set user data
let userData = UserData(
    name: "John Doe",
    email: "john@example.com"
)
try await chat.setUserData(userData)

// Authenticate with JWT
try await chat.authenticateUser(jwtToken: "your-jwt-token")
```

## 🎯 Key Features Demonstrated

### 1. Initialization
- How to create and configure `AssembledChat` instances
- Proper async/await initialization patterns
- Configuration options

### 2. Lifecycle Management
- Opening and closing chat
- Showing/hiding launcher
- Proper cleanup with `teardown()`

### 3. User Management
- Setting user data
- JWT authentication
- Custom user profiles

### 4. UI Integration
- Modal presentations
- Embedded views
- Child view controllers
- Navigation flows

### 5. Delegate Pattern
- Error handling
- State change notifications
- Event callbacks

### 6. Debug Mode
- Enabling debug logging
- Console output
- Troubleshooting

## 🏗️ Project Structure

```
Examples/
├── AssembledChatExample/
│   ├── AssembledChatExampleApp.swift    # App entry point
│   ├── MainTabView.swift                # Main navigation
│   ├── SettingsView.swift               # Configuration UI
│   ├── SwiftUI/
│   │   ├── SwiftUIExampleView.swift     # SwiftUI examples
│   │   ├── ChatModalView.swift          # Modal presentation
│   │   └── EmbeddedChatView.swift       # Embedded view
│   └── UIKit/
│       ├── UIKitExampleViewController.swift      # UIKit examples
│       ├── FullScreenChatViewController.swift    # Full-screen chat
│       └── UIKitExampleViewWrapper.swift         # SwiftUI wrapper
├── Package.swift                        # SPM configuration
└── README.md                           # This file
```

## 🔧 Advanced Configuration

### Custom Configuration

```swift
let config = AssembledChatConfiguration(
    companyId: "your-company-id",
    profileId: "optional-profile-id"
)

// Additional configuration
chat.setDebug(true)  // Enable debug mode
```

### Environment-Specific Setup

```swift
#if DEBUG
let companyId = "debug-company-id"
#else
let companyId = "production-company-id"
#endif

let config = AssembledChatConfiguration(companyId: companyId)
```

## 🐛 Troubleshooting

### Chat not loading?
1. Verify your company ID is correct
2. Check network connectivity
3. Enable debug mode to see console logs
4. Review the delegate methods for error callbacks

### Authentication issues?
1. Verify JWT token is valid and not expired
2. Check that user data is properly formatted
3. Review server-side authentication setup

### UI not appearing?
1. Ensure `initialize()` is called before `open()`
2. Check view hierarchy in Debug View Hierarchy
3. Verify constraints are properly set

## 📚 Additional Resources

- **SDK Documentation:** [GitHub Repository](https://github.com/assembledhq/assembled-chat-ios-sdk)
- **Assembled Website:** [assembled.com](https://www.assembled.com)
- **Support:** Contact Assembled support for assistance

## 🤝 Contributing

Found a bug or want to improve the examples? Feel free to:
1. Open an issue
2. Submit a pull request
3. Contact Assembled support

## 📄 License

This example app is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 💬 Support

For questions or issues:
- Check the main SDK [README](../README.md)
- Review the code examples in this app
- Contact Assembled support at [assembled.com](https://www.assembled.com)

---

**Happy Chatting!** 🎉

