# Contributing to WorkoutTrackerApp

Thank you for your interest in contributing to WorkoutTrackerApp! This document provides guidelines for contributing to the project.

## Getting Started

1. **Fork the repository** and clone your fork locally
2. **Set up the development environment** following the README.md instructions
3. **Create a new branch** for your feature or bugfix
4. **Make your changes** following our coding guidelines
5. **Test your changes** thoroughly
6. **Submit a pull request** with a clear description

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/WorkoutTrackerApp.git
cd WorkoutTrackerApp

# Install dependencies
brew install xcodegen
bundle install

# Generate Xcode project
xcodegen generate

# Open in Xcode
open WorkoutTrackerApp.xcodeproj
```

## Coding Guidelines

### Swift Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use clear, descriptive naming
- Prefer `let` over `var` when values don't change
- Use SwiftUI best practices
- Add documentation comments for public APIs using `///`

### Architecture

- Follow MVVM pattern with Repository layer
- Keep views focused on presentation
- Move business logic to repositories or dedicated classes
- Use `@StateObject` for owned objects, `@EnvironmentObject` for shared dependencies

### Code Quality

- Run SwiftLint before committing: `swiftlint`
- Ensure all tests pass before submitting PR
- Add tests for new features when applicable
- Keep functions focused and single-purpose
- Avoid force unwrapping (`!`) unless absolutely certain

### Commit Messages

Use clear, descriptive commit messages:

```
[Component] Brief description

Detailed explanation of what changed and why (if needed)

Fixes #123 (if applicable)
```

Examples:
- `[BlockBuilder] Add validation for exercise selection`
- `[SessionRun] Fix timer reset bug after workout completion`
- `[Repository] Improve error handling in persistence layer`

## Pull Request Process

1. **Update documentation** if you've changed functionality
2. **Add or update tests** for your changes
3. **Run all tests** and ensure they pass
4. **Run SwiftLint** and fix any issues
5. **Update CHANGELOG.md** with your changes (under Unreleased)
6. **Create a PR** with:
   - Clear title describing the change
   - Detailed description of what and why
   - Screenshots for UI changes
   - Reference to related issues

### PR Title Format

```
[Type] Brief description

Types:
- Feature: New functionality
- Bugfix: Bug fixes
- Refactor: Code improvements without behavior change
- Docs: Documentation changes
- Test: Test additions or fixes
- Chore: Maintenance tasks
```

Examples:
- `[Feature] Add exercise category filtering`
- `[Bugfix] Fix crash when deleting completed block`
- `[Refactor] Improve session factory performance`

## Testing

- Write unit tests for new features
- Test on both iPhone and iPad simulators
- Test on iOS 17.0+ devices
- Verify both strength and conditioning workout flows
- Test data persistence and recovery

## Areas to Contribute

### High Priority

- Bug fixes
- Performance improvements
- Test coverage improvements
- Documentation improvements
- Accessibility enhancements

### Feature Ideas

- Exercise video demonstrations
- Workout analytics and charts
- Export/import workout data
- Social features (sharing workouts)
- Apple Watch companion app
- HealthKit integration
- Siri shortcuts

### Technical Improvements

- Improved error handling
- Better offline support
- Performance optimization
- Code documentation
- Additional unit tests

## Code Review

All submissions require review before merging. Reviewers will check:

- Code quality and style
- Test coverage
- Documentation
- Performance impact
- Security considerations
- iOS compatibility

## Questions or Issues?

- Open a GitHub issue for bugs or feature requests
- Include clear steps to reproduce for bugs
- Provide context and use cases for feature requests

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

## Thank You!

Your contributions help make WorkoutTrackerApp better for everyone. We appreciate your time and effort! 🎉
