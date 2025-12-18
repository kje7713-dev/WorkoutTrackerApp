# WorkoutTrackerApp (Savage By Design)

An iOS workout tracking application built with SwiftUI for structured training through block periodization.

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

Run tests in Xcode: `⌘U`

Test files are located in the `Tests/` directory and follow the naming pattern `*Tests.swift`.

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

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:
- How to submit issues and pull requests
- Code style guidelines
- Development workflow
- Testing requirements

Also review our [Code of Conduct](CODE_OF_CONDUCT.md).

## Documentation

- **[README](README.md)** - This file, project overview
- **[CHANGELOG](CHANGELOG.md)** - Version history and release notes
- **[CONTRIBUTING](CONTRIBUTING.md)** - Contribution guidelines
- **[SECURITY](SECURITY.md)** - Security policy and reporting
- **[CODE_OF_CONDUCT](CODE_OF_CONDUCT.md)** - Community guidelines
- **[LICENSE](LICENSE)** - MIT License

### Additional Docs

- **[Deployment Guide](docs/DEPLOYMENT.md)** - How to deploy to TestFlight and App Store
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

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Privacy

All workout data is stored locally on your device. We don't collect, transmit, or have access to your data. See our [Privacy Policy Template](docs/PRIVACY_POLICY_TEMPLATE.md) for details.

## Acknowledgments

Built with ❤️ for the fitness community.
