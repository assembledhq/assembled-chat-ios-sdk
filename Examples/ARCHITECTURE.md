# Example App Architecture

This document explains the architecture and design decisions behind the AssembledChat iOS SDK example app.

## 🏗️ Architecture Overview

The example app is built using a **modular, tab-based architecture** that demonstrates different integration approaches:

```
┌─────────────────────────────────────┐
│         MainTabView                 │
│  (Root TabView Container)           │
└────────┬──────────┬─────────────────┘
         │          │          │
    ┌────▼───┐  ┌──▼────┐  ┌─▼──────┐
    │SwiftUI │  │ UIKit │  │Settings│
    │Examples│  │Example│  │        │
    └────────┘  └───────┘  └────────┘
```

## 📂 File Structure

### `/AssembledChatExample/`
Main app entry point and navigation

- **AssembledChatExampleApp.swift**: App lifecycle, entry point using `@main`
- **MainTabView.swift**: Root tab-based navigation container

### `/SwiftUI/`
SwiftUI integration examples

- **SwiftUIExampleView.swift**: Main demo screen with features showcase
  - View model pattern for state management
  - User configuration
  - Multiple chat presentation options
  
- **ChatModalView.swift**: Modal chat presentation
  - Sheet-based modal display
  - Navigation integration
  
- **EmbeddedChatView.swift**: Embedded chat in navigation flow
  - Full-screen embedded view
  - Custom header integration

### `/UIKit/`
UIKit integration examples

- **UIKitExampleViewController.swift**: Comprehensive UIKit demo
  - Programmatic UI setup
  - All SDK methods demonstrated
  - Delegate pattern implementation
  
- **FullScreenChatViewController.swift**: Full-screen chat container
  - Child view controller pattern
  - Proper lifecycle management
  
- **UIKitExampleViewWrapper.swift**: Bridge to SwiftUI
  - `UIViewControllerRepresentable` wrapper
  - Enables UIKit in SwiftUI context

### Root Level

- **SettingsView.swift**: Configuration and settings
  - UserDefaults persistence
  - JWT token management
  - User information storage

## 🎨 Design Patterns

### 1. MVVM (Model-View-ViewModel)

Used in SwiftUI components:

```swift
@MainActor
class SwiftUIExampleViewModel: ObservableObject {
    @Published var userName: String
    @Published var companyId: String
    
    func saveUserInfo() { ... }
}
```

**Benefits:**
- Separation of concerns
- Testable business logic
- Reactive state management

### 2. Delegate Pattern

Used in UIKit components:

```swift
extension UIKitExampleViewController: AssembledChatDelegate {
    func assembledChat(didReceiveError error: Error) { }
    func assembledChatDidOpen() { }
    func assembledChatDidClose() { }
}
```

**Benefits:**
- Event-driven architecture
- Loose coupling
- Standard iOS pattern

### 3. Child View Controller Pattern

Used for embedding chat:

```swift
addChild(chatViewController)
view.addSubview(chatViewController.view)
chatViewController.didMove(toParent: self)
```

**Benefits:**
- Proper view lifecycle
- Memory management
- Event forwarding

### 4. Repository Pattern (UserDefaults)

Simple persistence layer:

```swift
// Save
UserDefaults.standard.set(value, forKey: "key")

// Load
UserDefaults.standard.string(forKey: "key")
```

**Benefits:**
- Simple API
- Type-safe access
- Centralized storage

## 🔄 Data Flow

### SwiftUI Flow

```
User Interaction
      ↓
  ViewModel
      ↓
@Published Property
      ↓
  View Update
      ↓
  SDK Method Call
```

### UIKit Flow

```
User Interaction
      ↓
@objc Action
      ↓
  SDK Method Call
      ↓
Delegate Callback
      ↓
   UI Update
```

## 🧩 Component Responsibilities

### MainTabView
- **Responsibility**: Root navigation and tab management
- **Dependencies**: SwiftUI framework
- **Pattern**: Container view

### SwiftUIExampleView
- **Responsibility**: Demonstrate SwiftUI SDK integration
- **Dependencies**: AssembledChat SDK, SwiftUIExampleViewModel
- **Pattern**: MVVM, View composition

### UIKitExampleViewController
- **Responsibility**: Demonstrate UIKit SDK integration
- **Dependencies**: AssembledChat SDK
- **Pattern**: MVC, Delegate pattern

### SettingsView
- **Responsibility**: App configuration and persistence
- **Dependencies**: UserDefaults, SettingsViewModel
- **Pattern**: MVVM, Repository pattern

## 🔐 Security Considerations

### JWT Token Storage

⚠️ **Current Implementation** (for demo purposes):
```swift
UserDefaults.standard.set(jwtToken, forKey: "jwtToken")
```

✅ **Production Recommendation**:
```swift
// Use Keychain for secure storage
KeychainWrapper.standard.set(jwtToken, forKey: "jwtToken")
```

**Why?**
- UserDefaults is not encrypted
- Keychain provides secure, encrypted storage
- Better for sensitive authentication tokens

### User Data

Current storage is appropriate for:
- Non-sensitive user preferences
- Demo/development purposes

For production:
- Use Keychain for tokens
- Implement proper authentication flow
- Consider data encryption

## 🎯 Best Practices Demonstrated

### 1. Async/Await Usage

```swift
Task {
    try await chat?.initialize()
    await MainActor.run {
        updateUI()
    }
}
```

### 2. Memory Management

```swift
// Cleanup when done
chat?.teardown()
```

### 3. Error Handling

```swift
do {
    try await chat?.initialize()
} catch {
    updateStatus("Error: \(error.localizedDescription)")
}
```

### 4. State Management

```swift
@Published var isDebugEnabled: Bool = false {
    didSet {
        chat?.setDebug(isDebugEnabled)
    }
}
```

### 5. View Lifecycle

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupChat()
}
```

## 🧪 Testing Strategy

While the example app doesn't include tests, here's the recommended approach:

### Unit Tests
- View model logic
- Data persistence
- Configuration management

### Integration Tests
- SDK initialization
- User authentication flow
- Delegate callbacks

### UI Tests
- Navigation flows
- Chat opening/closing
- Settings persistence

## 🔄 State Management

### App-Wide State
- UserDefaults for persistence
- Published properties for reactivity

### Component State
- `@State` for local UI state
- `@StateObject` for view models
- Delegate callbacks for UIKit

## 📱 Platform Considerations

### iOS Version Support
- Minimum: iOS 15.0
- Target: Latest iOS version
- Deployment target set in project settings

### Device Support
- iPhone: Portrait and landscape
- iPad: All orientations
- Catalyst: Not explicitly supported (but should work)

### Accessibility
- System fonts for dynamic type
- Standard controls for VoiceOver
- High contrast support via system colors

## 🚀 Performance Considerations

### Lazy Loading
- Chat only initializes when needed
- Views load on-demand via tabs

### Memory Management
- Proper cleanup with `teardown()`
- Weak references in closures when needed
- ARC handles most memory management

### Main Thread Usage
- UI updates on main thread
- Async operations properly dispatched
- No blocking operations on main thread

## 🔮 Future Enhancements

Potential additions for the example app:

1. **Advanced Features**
   - Push notifications integration
   - File attachment handling
   - Custom theming examples

2. **Additional Patterns**
   - Coordinator pattern for navigation
   - Combine framework integration
   - SwiftUI previews for all components

3. **Testing**
   - Unit test examples
   - UI test automation
   - Snapshot testing

4. **Documentation**
   - Inline code documentation
   - Architecture decision records
   - Performance profiling guides

---

This architecture provides a solid foundation for understanding and implementing the AssembledChat SDK in various iOS app contexts.

