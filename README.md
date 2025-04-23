# SOP Hub (project-relay)

SOP Hub is a SwiftUI-based SaaS application designed to help small businesses with limited technical infrastructure manage daily operations more efficiently. It provides a simple, modern interface for tracking inventory, sales, maintenance, and analytics.

This app is ideal for businesses with high task volumes but low digital adoption, enabling them to stay organized and streamline workflows.

---

## 🧩 Features

- ✅ Simple, user-friendly interface built with SwiftUI
- 📦 Inventory tracking
- 💰 Sales and register section
- 🧹 Maintenance & cleaning tasks
- 📈 Business analytics overview (coming soon)

---

## 🚀 Getting Started (Mac Setup From Scratch)

If you're using a **brand new Mac** with no developer tools installed, follow these steps:

### 1. **Install Xcode**
- Go to the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12)
- Install **Xcode**
- Once installed, run this in Terminal to accept the license:
  ```bash
  sudo xcodebuild -license

### 2. **Install Git**
- Run this command on your terminal
```bash
xcode-select --install

### 3. Cloning and running the project
```Run these commands on your terminal in the current directory where you'd like to have the project located
```bash
git clone https://github.com/martinlizarraga/project-relay.git
cd project-relay
open SOPHub/SOPHub.xcodeproj

In XCode select an iOS simulator and click the Run button or press Cmd + R
