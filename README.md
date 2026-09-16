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

- `initialize()` - Create the chat overlay (required before use). The overlay starts hidden
- `open()` - Show and open the chat interface
- `close()` - Close the chat interface
- `showLauncher()` - Show the widget's launcher button
- `hideLauncher()` - Hide the widget's launcher button
- `authenticateUser(jwtToken:userData:)` - Authenticate a user with JWT
- `setUserData(_:)` - Update user data
- `setDebug(_:)` - Enable/disable debug mode
- `teardown()` - Clean up and remove the chat widget

### Overlay Visibility

`initialize()` builds the overlay but draws nothing. The chat appears when you call `open()`, and
the widget's launcher appears when you call `showLauncher()`. `close()` hides the chat while
keeping the launcher, if you asked for one.

While hidden, the overlay draws nothing and intercepts no touches, so `initialize()` is safe to
call early — during launch, or behind a screen you have already presented — without affecting the
rest of your UI.

While the chat or the launcher is visible, the overlay covers your app's safe area and intercepts
touches across it. A `WKWebView` hit-tests its entire frame regardless of what the page paints, so
this applies even when only the small launcher bubble is drawn. If your app needs to stay
interactive alongside a launcher, pass `disableLauncher: true` and present your own button that
calls `open()`.

> **Changed in 1.3.0:** `initialize()` previously made the overlay visible immediately, which
> showed the widget's default launcher but also blocked touches across your app's safe area from
> that moment on. Visibility is now explicit. If you relied on the launcher appearing without
> calling `showLauncher()`, add that call after `initialize()`.

### Attachment Permissions

- **Files:** No permission key is required.
- **Photo Library:** iOS 14 and later use `PHPicker` and require no permission key. On iOS 13, add `NSPhotoLibraryUsageDescription`.
- **Camera:** Add `NSCameraUsageDescription`. If it is missing, iOS terminates the app when the user selects camera capture.
- **Video capture:** Also add `NSMicrophoneUsageDescription`.

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

