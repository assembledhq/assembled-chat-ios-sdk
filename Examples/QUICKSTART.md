# Quick Start Guide

Get started with the AssembledChat iOS SDK in 5 minutes!

## 🚀 Quick Setup

### 1. Add the SDK to Your Project

#### Using Swift Package Manager (Recommended)

In Xcode:
1. Go to **File → Add Package Dependencies**
2. Enter: `https://github.com/assembledhq/assembled-chat-ios-sdk.git`
3. Select version `1.0.0` or later
4. Click **Add Package**

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/assembledhq/assembled-chat-ios-sdk.git", from: "1.0.0")
]
```

### 2. Choose Your Integration Style

Pick the approach that fits your app architecture:

<details>
<summary><b>Option A: SwiftUI (Recommended for new projects)</b></summary>

```swift
import SwiftUI
import AssembledChat

struct ContentView: View {
    var body: some View {
        AssembledChatSwiftUIView(companyId: "your-company-id")
    }
}
```

**That's it!** The chat widget will load automatically.

#### Show as Modal

```swift
struct MyView: View {
    @State private var showChat = false
    
    var body: some View {
        VStack {
            Button("Contact Support") {
                showChat = true
            }
        }
        .sheet(isPresented: $showChat) {
            AssembledChatSwiftUIView(companyId: "your-company-id")
        }
    }
}
```

</details>

<details>
<summary><b>Option B: UIKit (For existing UIKit projects)</b></summary>

```swift
import UIKit
import AssembledChat

class ViewController: UIViewController {
    private var chat: AssembledChat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = AssembledChatConfiguration(companyId: "your-company-id")
        chat = AssembledChat(configuration: config)
        chat?.delegate = self
        
        Task {
            try await chat?.initialize()
        }
    }
    
    @IBAction func openChatTapped() {
        chat?.open()
    }
}

extension ViewController: AssembledChatDelegate {
    func assembledChat(didReceiveError error: Error) {
        print("Error: \(error)")
    }
    
    func assembledChatDidOpen() {
        print("Chat opened")
    }
    
    func assembledChatDidClose() {
        print("Chat closed")
    }
}
```

</details>

### 3. Get Your Company ID

1. Visit [assembled.com](https://www.assembled.com)
2. Sign in to your account
3. Navigate to Settings → Integrations
4. Copy your **Company ID**
5. Replace `"your-company-id"` in the code above

### 4. Run Your App

Press `Cmd + R` and test the chat!

## 🎯 Next Steps

### Add User Information

Help your support team by identifying users:

```swift
let userData = UserData(
    name: "Jane Doe",
    email: "jane@example.com"
)
try await chat.setUserData(userData)
```

### Authenticate Users with JWT

For secure, authenticated sessions:

```swift
try await chat.authenticateUser(jwtToken: "your-jwt-token")
```

### Enable Debug Mode

For troubleshooting during development:

```swift
chat.setDebug(true)
```

## 📱 Common Use Cases

### Floating Chat Button

```swift
// Show the launcher button
chat?.showLauncher()

// Hide it when needed
chat?.hideLauncher()
```

### Open Chat Programmatically

```swift
// In response to a button tap or notification
chat?.open()
```

### Close Chat

```swift
chat?.close()
```

### Clean Up

```swift
// Call when you're done with the chat instance
chat?.teardown()
```

## 🔍 Explore the Examples

This repository includes a complete example app with:

- ✅ SwiftUI and UIKit implementations
- ✅ Modal and embedded presentations
- ✅ User authentication flows
- ✅ Settings and configuration UI
- ✅ Best practices and patterns

**Run the example app:**

```bash
cd Examples
open AssembledChatExample.xcodeproj
```

Then explore the code in the `SwiftUI/` and `UIKit/` folders!

## ❓ Need Help?

- **Examples:** Check out the full example app in this directory
- **Documentation:** Read the [main README](README.md)
- **SDK Docs:** Visit the [GitHub repository](https://github.com/assembledhq/assembled-chat-ios-sdk)
- **Support:** Contact Assembled support

## 🎉 You're All Set!

You now have Assembled's AI-powered chat integrated into your iOS app. Your customers can get instant support right from your app!

---

**Pro Tips:**
- Use the example app as a reference for advanced features
- Enable debug mode during development
- Test with different user scenarios
- Check the delegate methods for real-time chat events

