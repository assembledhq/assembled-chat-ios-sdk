# 📚 Example App Documentation Index

Welcome to the AssembledChat iOS SDK example app documentation! This index will help you navigate all available resources.

## 🚀 Getting Started

**New to the SDK?** Start here:

1. 📖 [Quick Start Guide](QUICKSTART.md) - Get up and running in 5 minutes
2. 📱 [Example App README](README.md) - Comprehensive overview and installation
3. 🎯 [Features Guide](FEATURES.md) - Detailed feature documentation

## 📖 Documentation Files

### Essential Reading

| Document | Purpose | Best For |
|----------|---------|----------|
| [README.md](README.md) | Complete app overview, installation, usage | Everyone |
| [QUICKSTART.md](QUICKSTART.md) | Fast setup and basic integration | Beginners |
| [FEATURES.md](FEATURES.md) | Detailed feature documentation | Learning all capabilities |

### Advanced Topics

| Document | Purpose | Best For |
|----------|---------|----------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | App structure, design patterns, best practices | Understanding implementation |
| [SCREENSHOTS.md](SCREENSHOTS.md) | Visual guide and UI overview | Visual learners |
| [INDEX.md](INDEX.md) | This file - documentation navigation | Finding specific info |

## 🎯 Quick Navigation by Goal

### "I want to..."

#### ...get started quickly
→ Read [QUICKSTART.md](QUICKSTART.md)  
→ Copy the basic SwiftUI or UIKit example  
→ Replace `"your-company-id"` with your actual ID  
→ Build and run!

#### ...understand all features
→ Read [FEATURES.md](FEATURES.md)  
→ Run the example app  
→ Explore each tab  
→ Try all the demonstrated features

#### ...learn the architecture
→ Read [ARCHITECTURE.md](ARCHITECTURE.md)  
→ Study the design patterns  
→ Review the code structure  
→ Understand data flow

#### ...see what the app looks like
→ Read [SCREENSHOTS.md](SCREENSHOTS.md)  
→ Build and run the app  
→ Navigate through all screens  
→ Compare with the visual guide

#### ...integrate into my SwiftUI app
→ [QUICKSTART.md - SwiftUI Section](QUICKSTART.md#option-a-swiftui-recommended-for-new-projects)  
→ [README.md - SwiftUI Examples](README.md#swiftui-integration)  
→ Code: `SwiftUI/SwiftUIExampleView.swift`

#### ...integrate into my UIKit app
→ [QUICKSTART.md - UIKit Section](QUICKSTART.md#option-b-uikit-for-existing-uikit-projects)  
→ [README.md - UIKit Examples](README.md#uikit-integration)  
→ Code: `UIKit/UIKitExampleViewController.swift`

#### ...implement authentication
→ [README.md - User Authentication](README.md#user-authentication)  
→ [FEATURES.md - Authentication Flow](FEATURES.md#authentication-flow)  
→ Code: `SettingsView.swift` (JWT token section)

#### ...customize the chat experience
→ [README.md - Configuration](README.md#configuration)  
→ [FEATURES.md - Settings Tab](FEATURES.md#settings-tab-features)  
→ Code: `AssembledChatConfiguration`

## 📂 Code Structure Reference

### SwiftUI Examples

```
SwiftUI/
├── SwiftUIExampleView.swift      # Main demo screen
│   └── SwiftUIExampleViewModel   # MVVM pattern
├── ChatModalView.swift            # Modal presentation
└── EmbeddedChatView.swift         # Navigation integration
```

**Learn:** SwiftUI integration, modal presentations, MVVM pattern

### UIKit Examples

```
UIKit/
├── UIKitExampleViewController.swift   # Main UIKit demo
├── FullScreenChatViewController.swift # Full-screen pattern
└── UIKitExampleViewWrapper.swift      # SwiftUI bridge
```

**Learn:** UIKit integration, delegate pattern, view controller lifecycle

### Supporting Files

```
AssembledChatExample/
├── AssembledChatExampleApp.swift  # App entry point
├── MainTabView.swift              # Navigation container
└── SettingsView.swift             # Configuration UI
```

**Learn:** App structure, navigation, settings persistence

## 🎓 Learning Paths

### Beginner Path

1. **Week 1: Basics**
   - Read [QUICKSTART.md](QUICKSTART.md)
   - Build and run the example app
   - Try opening chat in different ways
   - Configure basic settings

2. **Week 2: SwiftUI or UIKit**
   - Choose your platform (SwiftUI or UIKit)
   - Study the relevant example code
   - Implement in a test project
   - Configure user information

3. **Week 3: Advanced Features**
   - Read [FEATURES.md](FEATURES.md) completely
   - Implement user authentication
   - Try all SDK methods
   - Enable debug mode and observe logs

### Intermediate Path

1. **Deep Dive into Architecture**
   - Read [ARCHITECTURE.md](ARCHITECTURE.md)
   - Understand design patterns used
   - Study state management
   - Review memory management

2. **Customize the Examples**
   - Modify the example app
   - Add custom features
   - Integrate with your backend
   - Implement custom UI

3. **Production Preparation**
   - Review security considerations
   - Implement Keychain storage
   - Add error handling
   - Set up analytics

### Advanced Path

1. **Mastery**
   - Understand all code paths
   - Implement all patterns
   - Create custom components
   - Optimize performance

2. **Contribution**
   - Improve examples
   - Add new features
   - Write additional docs
   - Share knowledge

## 🔍 Quick Reference

### Common Code Snippets

#### SwiftUI - Basic Chat
```swift
AssembledChatSwiftUIView(companyId: "your-company-id")
```
📄 See: [QUICKSTART.md](QUICKSTART.md)

#### UIKit - Initialize
```swift
let config = AssembledChatConfiguration(companyId: "your-company-id")
chat = AssembledChat(configuration: config)
try await chat?.initialize()
```
📄 See: [README.md](README.md#uikit-integration)

#### Set User Data
```swift
let userData = UserData(name: "John", email: "john@example.com")
try await chat.setUserData(userData)
```
📄 See: [README.md](README.md#user-authentication)

#### Authenticate with JWT
```swift
try await chat.authenticateUser(jwtToken: "your-jwt-token")
```
📄 See: [FEATURES.md](FEATURES.md#authentication-section)

### File Locations

| What You Want | File Path |
|---------------|-----------|
| SwiftUI modal example | `SwiftUI/ChatModalView.swift` |
| UIKit delegate example | `UIKit/UIKitExampleViewController.swift` |
| Settings UI | `SettingsView.swift` |
| Configuration model | SDK: `Models/AssembledChatConfiguration.swift` |
| App entry point | `AssembledChatExampleApp.swift` |

## 🆘 Troubleshooting

### Documentation Not Helping?

1. **Check the SDK README**: [../README.md](../README.md)
2. **Review GitHub Issues**: [GitHub Repository](https://github.com/assembledhq/assembled-chat-ios-sdk/issues)
3. **Contact Support**: Assembled support team
4. **Debug Mode**: Enable in Settings tab

### Can't Find Something?

- Use your editor's search function
- Check the table of contents in each document
- Refer to this index
- Look at the code comments

## 📱 Running the Example App

```bash
# Clone the repository
git clone https://github.com/assembledhq/assembled-chat-ios-sdk.git

# Navigate to examples
cd assembled-chat-ios-sdk/Examples

# Open in Xcode
open AssembledChatExample.xcodeproj
```

## 🔗 External Resources

- **SDK Repository**: https://github.com/assembledhq/assembled-chat-ios-sdk
- **Assembled Website**: https://www.assembled.com
- **Swift Documentation**: https://swift.org/documentation/
- **iOS Guidelines**: https://developer.apple.com/design/human-interface-guidelines/

## 📋 Documentation Checklist

Use this to track your learning progress:

- [ ] Read QUICKSTART.md
- [ ] Read README.md
- [ ] Built and ran the example app
- [ ] Explored SwiftUI tab
- [ ] Explored UIKit tab
- [ ] Configured settings
- [ ] Read FEATURES.md
- [ ] Read ARCHITECTURE.md
- [ ] Implemented basic integration
- [ ] Set up user authentication
- [ ] Customized configuration
- [ ] Enabled debug mode
- [ ] Tested all features
- [ ] Reviewed all code files
- [ ] Ready for production!

## 🎯 Next Steps

After reviewing the documentation:

1. **Run the Example App**
   - Build and explore
   - Try all features
   - Modify and experiment

2. **Integrate into Your App**
   - Choose SwiftUI or UIKit
   - Follow the quick start
   - Configure for your needs

3. **Go to Production**
   - Review security considerations
   - Implement proper storage
   - Test thoroughly
   - Deploy with confidence

## 💬 Feedback

Found an issue with the documentation? Want to contribute?

- Open an issue on GitHub
- Submit a pull request
- Contact Assembled support

---

**Happy Learning!** 🚀

*Last Updated: December 2025*

