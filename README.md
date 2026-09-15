# AssembledChat iOS SDK

The official iOS SDK for integrating Assembled's chat widget into your iOS applications.

## Requirements

- iOS 13.0+
- Xcode 14.3+ (the SDK builds against the iOS 16.4 SDK)
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

### Customization Options

You can pass additional configuration options to the chat widget using the `options` dictionary. These are forwarded as URL query parameters and support any option the chat widget accepts, without requiring an SDK update.

```swift
let config = AssembledChatConfiguration(
    companyId: "your-company-id",
    options: [
        "disable_header": "true",
        "launcher_size": "large",
        "message_border_radius": "6px"
    ]
)
```

Keys use `snake_case` matching the widget's `data-*` attributes (strip `data-`, replace hyphens with underscores). For the full list of supported keys, see the [advanced setup guide](https://support.assembled.com/hc/en-us/articles/33739515754637).

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

### File Attachments

The attachment button in the chat composer is a web `<input type="file">`. WebKit presents the
system picker from the view controller that owns the web view. Chat embedded in your own screen
(`AssembledChatViewController` or the SwiftUI views) already has one; the window-level overlay
created by `initialize()` hosts the chat in its own window with a root view controller so the
picker has a presenter there too.

Declare the usage descriptions your attachment flow needs in **your app's** `Info.plist`. iOS
terminates the app when a capture device is accessed without one, so a missing key shows up as a
crash when the user taps the option, not as a disabled feature:

| Key | When it is required |
| --- | --- |
| `NSCameraUsageDescription` | Required if the picker offers "Take Photo or Video". |
| `NSMicrophoneUsageDescription` | Required if video capture is allowed. |
| `NSPhotoLibraryUsageDescription` | Only needed on iOS 13. iOS 14+ uses the out-of-process photo picker, which requires no key. |

Choosing an existing file from Files needs no usage description on any supported version.

With `debug: true` in your configuration, the chat web view is inspectable from Safari's Develop
menu on iOS 16.4+, which is the quickest way to confirm a tap reached the page.

## 📱 Example App

A comprehensive example app demonstrating all SDK features is available in the [`Examples/`](Examples/) directory.

### What's Included

The example app showcases:
- ✅ **SwiftUI integration** - Modal and embedded presentations
- ✅ **UIKit integration** - Full delegate pattern and view controller examples
- ✅ **User authentication** - JWT token and user data configuration
- ✅ **All SDK methods** - Complete API demonstration
- ✅ **Best practices** - Production-ready patterns and architecture

### Quick Start with Examples

```bash
# Clone the repository
git clone https://github.com/assembledhq/assembled-chat-ios-sdk.git

# Navigate to examples and open in Xcode
cd assembled-chat-ios-sdk/Examples
open AssembledChatExample.xcodeproj
```

Then in Xcode:
1. **Wait** for Xcode to finish resolving packages (check the status bar)
2. **Select simulator**: Click the device dropdown (top center) → choose **iPhone 16** (or any iPhone)
3. **Run**: Press `Cmd + R` (or click ▶️) to build, install, and launch the app

> **Note:** Xcode will automatically open the iOS Simulator when you run the app.

### Documentation

- **[Quick Start Guide](Examples/QUICKSTART.md)** - Get running in 5 minutes
- **[Complete README](Examples/README.md)** - Full documentation
- **[Features Guide](Examples/FEATURES.md)** - Detailed feature reference
- **[Architecture Guide](Examples/ARCHITECTURE.md)** - Design patterns and structure

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please contact Assembled support or visit [https://www.assembled.com](https://www.assembled.com).

