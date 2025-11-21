# AssembledChat iOS SDK

The official iOS SDK for integrating Assembled's chat widget into your iOS applications.

## Requirements

- iOS 13.0+
- Xcode 14.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/assembledhq/assembled-chat-ios-sdk.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File > Add Package Dependencies
2. Enter the repository URL: `https://github.com/assembledhq/assembled-chat-ios-sdk.git`
3. Select version 1.0.0 or later

## Usage

### SwiftUI

```swift
import SwiftUI
import AssembledChat

struct ContentView: View {
    var body: some View {
        AssembledChatSwiftUIView(companyId: "your-company-id")
    }
}
```

### UIKit

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
            chat?.open()
        }
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

## Configuration

### Basic Configuration

```swift
let config = AssembledChatConfiguration(
    companyId: "your-company-id",
    profileId: "optional-profile-id"
)
```

### User Authentication

```swift
// Authenticate with JWT token
try await chat.authenticateUser(jwtToken: "your-jwt-token")

// Set user data
let userData = UserData(
    name: "John Doe",
    email: "john@example.com"
)
try await chat.setUserData(userData)
```

### Methods

- `initialize()` - Initialize the chat widget (required before use)
- `open()` - Open the chat interface
- `close()` - Close the chat interface
- `showLauncher()` - Show the chat launcher button
- `hideLauncher()` - Hide the chat launcher button
- `authenticateUser(jwtToken:userData:)` - Authenticate a user with JWT
- `setUserData(_:)` - Update user data
- `setDebug(_:)` - Enable/disable debug mode
- `teardown()` - Clean up and remove the chat widget

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please contact Assembled support or visit [https://www.assembled.com](https://www.assembled.com).

