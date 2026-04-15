![ClickNBack banner](/docs/clicknback-bannerbg-white.png)

[![Xcode](https://img.shields.io/badge/Xcode-26.4%2B-blue?logo=xcode)](https://developer.apple.com/xcode/)
[![Swift](https://img.shields.io/badge/Swift-6.0%2B-orange?logo=swift)](https://swift.org)

This repository contains the companion iOS client app for the [ClickNBack cashback platform](https://github.com/jerosanchez/clicknback). It provides a native mobile experience for users to access cashback offers, manage their profile, and interact with the ClickNBack backend services.

---

## 🚀 Getting Started

Follow these steps to set up and run the project locally:

### 1. Prerequisites
- **Xcode 26.4+** (install from the [Mac App Store](https://apps.apple.com/app/xcode/id497799835?mt=12))
- **Homebrew** (https://brew.sh)
- **Tuist** (for project generation)
- **SwiftFormat** and **SwiftLint** (for code style)

### 2. Install Dependencies

Open a terminal in the project root and run:

```sh
make install
```
This will:
- Install SwiftFormat and SwiftLint (if missing)
- Generate the Xcode project using Tuist

### 3. Open the Project

```sh
make open
```
This opens the workspace in Xcode.

### 4. Build & Run
- Select the `ClickNBack-Dev` scheme (or `ClickNBack` if not present)
- Choose a simulator (default: iPhone 17)
- Press **Run** (▶️) in Xcode

---

## 🧹 Code Quality

- **Format code:** `make format`
- **Lint code:** `make lint`
- **Run tests:** `make test`

---

## 🛠️ Project Maintenance

- **Regenerate project:** `make regenerate`
- **Clean artifacts:** `make clean-artifacts`
- **Full cleanup:** `make clean-all`
