# Example App Features Guide

Complete reference of all features demonstrated in the AssembledChat iOS SDK example app.

## 📱 App Overview

The example app is organized into **3 main tabs**, each showcasing different aspects of the SDK:

### 1️⃣ SwiftUI Tab
Modern, declarative UI examples

### 2️⃣ UIKit Tab
Traditional UIKit integration patterns

### 3️⃣ Settings Tab
Configuration and customization options

---

## SwiftUI Tab Features

### 🎯 Main Features Showcase

#### User Information Panel
- **Name Field**: Set the user's display name
- **Email Field**: Configure user email for support context
- **Company ID Field**: Your Assembled company identifier
- **Save Button**: Persist user information

**Location**: Top section, "User Information" group

#### Chat Actions

##### 1. Open Chat Modal
- **What it does**: Opens chat in a modal sheet presentation
- **Use case**: Quick access without leaving current screen
- **Implementation**: Uses `.sheet()` modifier
- **Code**: `ChatModalView.swift`

##### 2. Open Embedded Chat
- **What it does**: Navigates to a dedicated chat screen
- **Use case**: Full-screen chat experience
- **Implementation**: Navigation link to embedded view
- **Code**: `EmbeddedChatView.swift`

##### 3. Toggle Debug Mode
- **What it does**: Enables/disables SDK debug logging
- **Use case**: Development and troubleshooting
- **Visual indicator**: Button changes state
- **Persists**: Across app sessions

#### Status Panel
Real-time information display:
- **SDK Version**: Current SDK version (1.0.0)
- **Debug Mode**: Current debug state
- **User**: Current user name (if set)
- **Status Messages**: Latest action/event

---

## UIKit Tab Features

### 🎯 Complete SDK Method Showcase

#### Initialization Section

##### Initialize Chat Button
```swift
// Creates and initializes chat instance
let config = AssembledChatConfiguration(companyId: companyId)
chat = AssembledChat(configuration: config)
try await chat?.initialize()
```

**What happens:**
1. Creates SDK configuration
2. Instantiates AssembledChat
3. Sets delegate
4. Asynchronously initializes
5. Enables all other buttons on success

#### Chat Controls Section

##### Open Chat Button
```swift
chat?.open()
```
- Opens the chat interface
- Displays over your app's content
- Triggers `assembledChatDidOpen()` delegate callback

##### Close Chat Button
```swift
chat?.close()
```
- Dismisses the chat interface
- Returns to your app
- Triggers `assembledChatDidClose()` delegate callback

#### Launcher Controls Section

##### Show Launcher Button
```swift
chat?.showLauncher()
```
- Displays floating chat button
- Users can tap to open chat
- Customizable position

##### Hide Launcher Button
```swift
chat?.hideLauncher()
```
- Hides floating chat button
- Use when chat button shouldn't be visible
- Can be shown again anytime

#### Navigation Section

##### Open Full Screen Chat
- Opens dedicated chat view controller
- Full-screen modal presentation
- Includes close button
- Demonstrates child view controller pattern

**Implementation**: `FullScreenChatViewController.swift`

#### Status Display
- Shows current initialization state
- Displays delegate callback events
- Updates in real-time
- Useful for debugging

---

## Settings Tab Features

### 🔧 Configuration Options

#### Company Configuration Section

##### Company ID
- **Required**: Yes
- **Purpose**: Identifies your Assembled workspace
- **Format**: String (alphanumeric)
- **Persistence**: Saved to UserDefaults
- **Used by**: All chat instances

##### Profile ID
- **Required**: No
- **Purpose**: User-specific profile identifier
- **Format**: String (optional)
- **Persistence**: Saved to UserDefaults

#### User Information Section

##### Name
- **Purpose**: Display name in chat
- **Sent to**: Assembled support team
- **Helps**: Personalize support experience

##### Email
- **Purpose**: Contact information
- **Format**: Email address (validated)
- **Used for**: Follow-up communications

##### Phone
- **Required**: No
- **Purpose**: Optional contact method
- **Format**: Phone number

#### Authentication Section

##### Set JWT Token
- **Opens**: Modal sheet for token entry
- **Purpose**: Authenticated user sessions
- **Security**: Should use Keychain in production
- **Format**: Valid JWT token string
- **Status indicator**: Shows if token is configured

**JWT Token Sheet Features:**
- Multi-line text editor
- Monospaced font for readability
- Save/Cancel actions
- Clear token option (if set)

#### Debug Options Section

##### Debug Mode Toggle
- **Enables**: SDK debug logging
- **Output**: Console logs
- **Useful for**: Troubleshooting integration issues
- **Persists**: Saved to UserDefaults

##### Show Console Logs Toggle
- **Enables**: Additional app-level logging
- **Complements**: SDK debug mode
- **Helps**: Track app events

#### About Section

##### SDK Version
- **Displays**: Current SDK version
- **Static**: Read-only information
- **Current**: 1.0.0

##### About Assembled
- **Type**: External link
- **Opens**: Assembled website in Safari
- **URL**: https://www.assembled.com

##### GitHub Repository
- **Type**: External link
- **Opens**: SDK repository on GitHub
- **URL**: https://github.com/assembledhq/assembled-chat-ios-sdk

#### Actions Section

##### Save Settings Button
- **Action**: Persists all settings to UserDefaults
- **Feedback**: Shows success alert
- **Validation**: Ensures required fields present

##### Reset to Defaults Button
- **Style**: Destructive (red)
- **Action**: Clears all saved settings
- **Returns**: All fields to default values
- **Immediate**: No confirmation dialog

---

## 🎬 User Flows

### First-Time Setup Flow

1. **Launch App** → MainTabView appears
2. **Navigate to Settings** → Tap Settings tab
3. **Enter Company ID** → Required for chat to work
4. **Enter User Info** → Name and email (optional)
5. **Tap Save Settings** → Success alert appears
6. **Navigate to SwiftUI or UIKit** → Ready to test chat!

### SwiftUI Chat Flow

1. **Enter User Info** (if not done)
2. **Tap "Open Chat Modal"**
3. **Chat loads** in modal sheet
4. **Interact** with chat
5. **Swipe down** or tap Close to dismiss
6. **Status updates** show chat state

### UIKit Chat Flow

1. **Tap "Initialize Chat"**
2. **Wait** for initialization
3. **Buttons enable** when ready
4. **Tap "Open Chat"**
5. **Chat appears** as overlay
6. **Use "Close Chat"** to dismiss
7. **Delegate callbacks** log to status

### Authentication Flow

1. **Settings Tab** → Tap "Set JWT Token"
2. **Modal opens** → Enter JWT token
3. **Tap Save** → Token stored
4. **Return to chat** → Authenticated session
5. **JWT indicator** shows "Configured"

---

## 🎨 UI Components Used

### SwiftUI Components
- `NavigationView` - Main navigation container
- `TabView` - Tab-based navigation
- `Form` / `GroupBox` - Settings layout
- `TextField` - User input
- `Button` - Actions
- `Sheet` - Modal presentations
- `NavigationLink` - Push navigation
- `TextEditor` - Multi-line input

### UIKit Components
- `UIViewController` - Base view controllers
- `UINavigationController` - Navigation management
- `UITabBarController` - Tab interface
- `UIScrollView` - Scrollable content
- `UIStackView` - Layout management
- `UIButton` - Actions
- `UILabel` - Text display
- `UITextField` - Single-line input

---

## 🔔 Delegate Events

### Demonstrated in UIKit Tab

```swift
protocol AssembledChatDelegate {
    func assembledChat(didReceiveError error: Error)
    func assembledChatDidOpen()
    func assembledChatDidClose()
}
```

#### didReceiveError
- **When**: SDK encounters an error
- **Parameter**: Error object with details
- **Example**: Network failure, invalid config
- **Response**: Display error, log to console

#### assembledChatDidOpen
- **When**: Chat interface opens
- **Example Use**: Track analytics, update UI
- **Demonstrated**: Updates status label

#### assembledChatDidClose
- **When**: Chat interface closes
- **Example Use**: Restore app state, analytics
- **Demonstrated**: Updates status label

---

## 💾 Data Persistence

### What's Saved

| Key | Type | Purpose |
|-----|------|---------|
| `companyId` | String | Assembled workspace ID |
| `profileId` | String | Optional profile ID |
| `userName` | String | User display name |
| `userEmail` | String | User email address |
| `userPhone` | String | User phone number |
| `jwtToken` | String | Authentication token |
| `debugMode` | Bool | Debug logging state |
| `showConsoleLogs` | Bool | App logging state |

### Storage Mechanism

**Current**: UserDefaults (for demo)

**Production Recommendation**:
- UserDefaults: Non-sensitive preferences
- Keychain: JWT tokens, sensitive data

---

## 🎓 Learning Resources

Each feature in the app teaches specific SDK concepts:

| Feature | SDK Concept | File Reference |
|---------|-------------|----------------|
| Modal Chat | SwiftUI Integration | `ChatModalView.swift` |
| Embedded Chat | Navigation Integration | `EmbeddedChatView.swift` |
| Initialize | Async Setup | `UIKitExampleViewController.swift` |
| Delegates | Event Handling | `UIKitExampleViewController.swift` |
| Full Screen | Child VCs | `FullScreenChatViewController.swift` |
| Settings | Configuration | `SettingsView.swift` |

---

## 🚀 Try These Scenarios

### Beginner
1. ✅ Open chat in modal (SwiftUI)
2. ✅ Enter user information
3. ✅ Save settings
4. ✅ Toggle debug mode

### Intermediate
1. ✅ Initialize chat (UIKit)
2. ✅ Use all chat controls
3. ✅ Watch delegate callbacks
4. ✅ Configure JWT token

### Advanced
1. ✅ Study view controller embedding
2. ✅ Examine async/await patterns
3. ✅ Review MVVM implementation
4. ✅ Modify and extend features

---

Explore the code, experiment with features, and build amazing chat experiences! 🎉

