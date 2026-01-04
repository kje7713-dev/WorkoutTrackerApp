# WorkoutTrackerApp (Savage By Design)

An iOS workout tracking application built with SwiftUI for structured training through block periodization.

---

## 👥 **For App Users**

> **📱 New to Savage By Design?** Start here:
> 
> ### **[→ END USER README - Learn What This App Can Do](END_USER_README.md)** ⭐
> 
> Quick, easy-to-read overview of all app capabilities, features, and how to get started in 60 seconds.
>
> ### **[→ Complete User Guide - Detailed How-To Guide](USER_GUIDE.md)** 📚
> 
> Comprehensive 600+ line guide with step-by-step instructions, tips, and troubleshooting.

---

## 👨‍💻 **For Developers**

This README below is for developers who want to build, modify, or contribute to the app.

## Overview

WorkoutTrackerApp helps athletes, coaches, and fitness enthusiasts create, manage, and track strength training and conditioning workouts through a structured block periodization model.

### Key Features

- **Training Block Management**: Create multi-week training blocks with progressive overload
- **Exercise Library**: Comprehensive exercise database with categorization
- **Workout Session Tracking**: Real-time logging with sets, reps, weight, and conditioning metrics
- **AI-Assisted Block Generation**: Draft model for automated program design
- **Superset & Circuit Support**: Complex training structure support
- **Block History**: Track completed workouts and review past performance
- **Conditioning Workouts**: Support for time, distance, and calorie-based cardio

## Tech Stack

- **Platform**: iOS 17.0+
- **Language**: Swift
- **Framework**: SwiftUI
- **Architecture**: MVVM with Repository pattern
- **Project Generation**: XcodeGen
- **Build Automation**: Fastlane
- **CI/CD**: GitHub Actions, Codemagic

## Getting Started

### Prerequisites

- macOS with Xcode 16.0 or later
- Ruby 3.2 or later
- Homebrew (for installing dependencies)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/kje7713-dev/WorkoutTrackerApp.git
cd WorkoutTrackerApp
```

2. Install XcodeGen:
```bash
brew install xcodegen
```

3. Install Ruby dependencies:
```bash
bundle install
```

4. Generate the Xcode project:
```bash
xcodegen generate
```

5. Open the project in Xcode:
```bash
open WorkoutTrackerApp.xcodeproj
```

### Building for Development

1. Select your target device or simulator in Xcode
2. Build and run: `⌘R`

### Building for Release

Using Fastlane:
```bash
bundle exec fastlane beta
```

This will:
- Generate the Xcode project
- Build the app in Release configuration
- Upload to TestFlight

## Project Structure

```
/
├── Models.swift              # Core domain models
├── Repositories.swift        # Data persistence layer
├── SessionFactory.swift      # Workout session creation logic
├── SavageByDesignApp.swift  # App entry point
├── *View.swift               # SwiftUI views
├── Theme.swift               # App styling
├── Assets.xcassets/          # Images and app icons
├── Tests/                    # Unit tests
├── fastlane/                 # Build automation
├── .github/workflows/        # CI/CD pipelines
└── project.yml               # XcodeGen configuration
```

## Configuration

### Environment Variables

For CI/CD builds, configure the following secrets in GitHub:

- `ASC_KEY_ID`: App Store Connect API Key ID
- `ASC_ISSUER_ID`: App Store Connect Issuer ID
- `ASC_KEY`: App Store Connect API Key (base64 encoded)
- `APPLE_ID`: Apple Developer Account Email
- `APPLE_TEAM_ID`: Apple Team ID
- `APP_IDENTIFIER`: App Bundle ID (com.kje7713.WorkoutTrackerApp)
- `MATCH_GIT_URL`: Git repository URL for code signing certificates
- `MATCH_GIT_TOKEN`: GitHub token for certificate repository access
- `MATCH_PASSWORD`: Password for encrypting certificates
- `IOS_SCHEME`: Xcode scheme name (WorkoutTrackerApp)

### Version Management

Version numbers are configured in `project.yml`:
- `MARKETING_VERSION`: User-facing version (e.g., "1.0")
- `CURRENT_PROJECT_VERSION`: Build number (auto-incremented by CI)

Build numbers use timestamp format (`YYYYMMDDHHMMSS`) to ensure uniqueness.

## Testing

### Running Tests

Run tests in Xcode: `⌘U`

Test files are located in the `Tests/` directory and follow the naming pattern `*Tests.swift`.

### Subscription Testing

The app includes in-app subscriptions using StoreKit 2. To test subscription functionality:

1. Generate the Xcode project: `xcodegen generate`
2. The project is configured to use `Configuration.storekit` for local testing
3. See the **[StoreKit Testing Guide](docs/STOREKIT_TESTING_GUIDE.md)** for comprehensive setup and troubleshooting

Key points:
- Use iOS Simulator for quick testing (no sandbox account needed)
- StoreKit configuration includes a monthly subscription with 15-day free trial
- Xcode scheme is pre-configured to use the StoreKit configuration file
- For device testing, you can use Apple's sandbox environment

## Architecture

### Data Flow

```
Views → Repositories → FileManager (JSON persistence)
  ↓
EnvironmentObjects (Shared State)
```

### Repository Pattern

Three main repositories handle data:
- `BlocksRepository`: Training blocks and templates
- `SessionsRepository`: Live workout sessions
- `ExerciseLibraryRepository`: Exercise definitions

### Models

- **Template Models**: Used for planning (Block, DayTemplate, ExerciseTemplate)
- **Session Models**: Used for tracking (WorkoutSession, SessionSet)
- **Progression**: Week-based progression applied when creating sessions

## Contributing

**Note:** As of version v0.9-open (the final MIT-licensed release), this project has transitioned to proprietary development. The open-source contribution phase has concluded.

For versions ≤ v0.9-open, the original [Contributing Guide](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md) remain applicable to those historical versions.

## Documentation

### For Users
- **[End User README](END_USER_README.md)** - ⭐ **Quick overview of app capabilities** (Start here!)
- **[User Guide](USER_GUIDE.md)** - 📖 **Complete guide on how to use the app effectively** (Detailed how-to)

### For Developers
- **[README](README.md)** - This file, development setup and technical overview
- **[CHANGELOG](CHANGELOG.md)** - Version history and release notes
- **[CONTRIBUTING](CONTRIBUTING.md)** - Contribution guidelines
- **[SECURITY](SECURITY.md)** - Security policy and reporting
- **[CODE_OF_CONDUCT](CODE_OF_CONDUCT.md)** - Community guidelines
- **[LICENSE](LICENSE)** - Proprietary License (versions > v0.9-open)

### Additional Developer Docs

- **[Deployment Guide](docs/DEPLOYMENT.md)** - How to deploy to TestFlight and App Store
- **[StoreKit Testing Guide](docs/STOREKIT_TESTING_GUIDE.md)** - How to test in-app subscriptions
- **[Testing Guide](docs/TESTING.md)** - Testing practices and guidelines
- **[Privacy Policy Template](docs/PRIVACY_POLICY_TEMPLATE.md)** - Privacy policy template
- **[Implementation Docs](docs/implementation/)** - Historical feature documentation

## Code Style

- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Maintain MVVM architecture
- Add documentation for complex logic
- Use type-safe models with Codable
- Run SwiftLint before committing

## Deployment

### TestFlight

Automatic deployment to TestFlight occurs via:
- **GitHub Actions**: Manual workflow dispatch
- **Codemagic**: Automated on branch triggers

See the [Deployment Guide](docs/DEPLOYMENT.md) for detailed instructions.

### App Store

Manual submission through App Store Connect after TestFlight validation. See deployment guide for checklist.

## Support

- **Issues**: [GitHub Issues](https://github.com/kje7713-dev/WorkoutTrackerApp/issues)
- **Security**: See [Security Policy](SECURITY.md)
- **Discussions**: [GitHub Discussions](https://github.com/kje7713-dev/WorkoutTrackerApp/discussions)

## License

**IMPORTANT: Licensing Change Notice**

### Current Version (> v0.9-open)
This project is now **proprietary software**. All rights reserved. No use, modification, or distribution is permitted without explicit written permission. Commercial use requires a paid license. See the [LICENSE](LICENSE) file for full terms.

**Development of this project continues privately as we transition to commercial production.**

### Historical Versions (≤ v0.9-open)
Versions tagged **v0.9-open and earlier** remain available under the **MIT License**. You can access the final open-source version by checking out the `v0.9-open` tag:

```bash
git checkout v0.9-open
```

Those historical versions retain their original MIT licensing terms and can be used according to those terms.

## Privacy

All workout data is stored locally on your device. We don't collect, transmit, or have access to your data. See our [Privacy Policy Template](docs/PRIVACY_POLICY_TEMPLATE.md) for details.

## Acknowledgments

Built with ❤️ for the fitness community.
