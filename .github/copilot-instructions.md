# Copilot Instructions for WorkoutTrackerApp (Savage By Design)

## Project Overview

This is an iOS workout tracking application built with SwiftUI. The app helps users create, manage, and track strength training and conditioning workouts through a structured block periodization model.

**Key Features:**
- Create training blocks with multiple weeks and day templates
- Support for strength training (sets/reps/weight) and conditioning workouts (time/distance/calories)
- Exercise library management with categorization
- Live workout session tracking with logging capabilities
- AI-assisted block generation (draft model)
- Support for supersets, circuits, and complex training structures

**Target Audience:** Athletes, coaches, and fitness enthusiasts who follow structured training programs.

## Tech Stack & Dependencies

**Primary Technologies:**
- **Language:** Swift (iOS 17.0+)
- **Framework:** SwiftUI for UI
- **Architecture:** MVVM with Repository pattern
- **Build System:** XcodeGen for project generation (project.yml)
- **CI/CD:** GitHub Actions, Codemagic, Fastlane
- **Deployment:** TestFlight via App Store Connect

**Project Structure:**
- XcodeGen-based project (no .xcodeproj checked in)
- Fastlane for build automation
- Ruby gems for Fastlane dependencies

**Data Management:**
- Repository pattern for data access (BlocksRepository, SessionsRepository, ExerciseLibraryRepository)
- Models use Codable for serialization
- UUID-based identifiers for all entities

## Coding Guidelines

### Swift Style
- Follow Swift API Design Guidelines
- Use clear, descriptive naming (no abbreviations unless standard)
- Prefer `let` over `var` when values don't change
- Use type inference where appropriate but be explicit when it improves clarity
- Group related code with `// MARK: -` comments

### Architecture Patterns
- **MVVM:** Views observe StateObjects (repositories act as view models)
- **Repository Pattern:** Centralize data access in repository classes
- Use `@StateObject` for owned objects, `@EnvironmentObject` for shared dependencies
- Keep views focused on presentation logic; move business logic to repositories or separate classes

### Error Handling
- Use Swift's error handling (throw/try/catch) for recoverable errors
- Use optional types for values that may be absent
- Avoid force unwrapping (`!`) unless absolutely certain the value exists
- Provide meaningful error messages

### Documentation
- Add doc comments for public APIs and complex logic
- Use `///` for documentation comments
- Document complex domain models with inline comments
- Keep comments up-to-date with code changes

### SwiftUI Best Practices
- Extract complex views into separate components
- Use `@ViewBuilder` for composable view APIs
- Minimize state and lift it up when shared
- Use `.environmentObject()` for dependency injection
- Follow SwiftUI naming conventions (e.g., "View" suffix for views)

### Domain Model Guidelines
- Models should be `Identifiable`, `Codable`, and `Equatable`
- Use type aliases for ID types (e.g., `BlockID`, `ExerciseTemplateID`)
- Include sensible default values in initializers
- Keep models immutable where possible (use struct with `let`)
- Separate templates (planning) from session data (logging)

### Security & Privacy
- Never commit secrets or API keys to source control
- Use environment variables for sensitive configuration
- Store credentials in GitHub Secrets for CI/CD
- Follow Apple's data privacy guidelines for user data

## Project Structure

```
/
├── .github/
│   ├── workflows/           # GitHub Actions workflows
│   └── copilot-instructions.md
├── fastlane/                # Fastlane configuration
├── Assets.xcassets/         # App assets and images
├── LaunchScreen.storyboard  # Launch screen
├── Info.plist              # App configuration
├── project.yml             # XcodeGen project definition
├── codemagic.yaml          # Codemagic CI configuration
├── Gemfile                 # Ruby dependencies
│
├── SavageByDesignApp.swift # App entry point with environment setup
├── Models.swift            # Domain models (Block, Exercise, Session, etc.)
├── Repositories.swift      # Data access layer
├── SessionFactory.swift    # Factory for creating workout sessions
│
├── HomeView.swift          # Main navigation view
├── BlocksListView.swift    # List of training blocks
├── BlockBuilderView.swift  # UI for creating/editing blocks
├── SessionRunView.swift    # Live workout tracking interface
├── SetControls.swift       # UI controls for set logging
├── Theme.swift             # App-wide styling and colors
└── blockrunmode.swift      # Additional session/run logic
```

### Important Files
- **Models.swift:** Core domain models - modify carefully as changes affect the entire app
- **Repositories.swift:** Centralized data access - ensure thread safety
- **project.yml:** XcodeGen configuration - regenerate .xcodeproj after changes
- **SessionFactory.swift:** Logic for instantiating sessions from templates

### Development Workflow
1. Make code changes in Swift files
2. Run `xcodegen generate` if project.yml was modified
3. Build and test in Xcode
4. Test on iOS simulator or device
5. Commit changes (exclude generated .xcodeproj)

### Testing
- Test files follow pattern `*Spec.swift` or `*Tests.swift`
- Test on iOS 17.0+ simulators
- Validate both strength and conditioning workout flows
- Test session creation from templates with progression rules

## Build & Development Commands

**Generate Xcode project:**
```bash
xcodegen generate
```

**Install Ruby dependencies:**
```bash
bundle install
```

**Build via Fastlane:**
```bash
bundle exec fastlane beta
```

**Run linter (if available):**
```bash
# SwiftLint integration can be added to project
swiftlint
```

## Additional Resources

- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [XcodeGen Documentation](https://github.com/yonaskolb/XcodeGen)
- [Fastlane Documentation](https://docs.fastlane.tools/)

## Working with Copilot

When making changes:
1. **Understand the domain:** This app uses training block periodization concepts
2. **Preserve model relationships:** BlockID → Block → DayTemplate → ExerciseTemplate → SessionSet
3. **Consider both use cases:** Planning (templates) vs. Execution (live sessions)
4. **Ask clarifying questions** about training terminology if unsure
5. **Test changes** with both strength and conditioning exercise types
6. **Validate serialization:** Ensure Codable compliance for all models

## Notes for AI Assistants

- The app uses a dual model system: templates for planning and sessions for tracking
- Exercise types (strength vs. conditioning) have different data structures
- Week-based progression is applied to templates when creating sessions
- The `SetGroupID` is used for supersets/circuits grouping
- Template IDs link sessions back to their originating templates
- Always maintain backwards compatibility with Codable when modifying models
