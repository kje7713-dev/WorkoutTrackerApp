# Changelog

All notable changes to WorkoutTrackerApp will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial production readiness preparations
- END_USER_README.md - Comprehensive end-user facing documentation explaining app capabilities
- README.md with comprehensive documentation
- CHANGELOG.md for version tracking
- Release configuration for production builds

### Changed
- Improved README.md structure with clear separation between user and developer documentation
- Enhanced documentation organization with quick-start guide for end users
- Improved logging with structured output
- Enhanced error handling in repositories

### Removed
- Horizontal scrolling segment chips from whiteboard view - Removed the "Class Flow Strip" with horizontal scrolling pills to simplify the UI. Segment cards are now displayed directly in a vertical list without the redundant navigation strip

### Security
- Implemented privacy manifest for iOS 17+ compliance
- Reduced production logging of sensitive data

## [1.0.0] - TBD

### Added
- Training block creation and management
- Exercise library with categorization
- Workout session tracking with real-time logging
- Support for strength training (sets/reps/weight)
- Support for conditioning workouts (time/distance/calories)
- Block history and workout review
- Superset and circuit training support
- AI-assisted block generation (draft)
- Week completion tracking
- Progressive overload calculations
- Exercise dropdown for easy selection
- Block JSON import/export functionality

### Features
- SwiftUI-based user interface
- MVVM architecture with Repository pattern
- Local data persistence with JSON
- Backup and recovery system for data integrity
- Multi-week training block support
- Customizable exercise templates
- Real-time workout session logging

### Technical
- iOS 17.0+ support
- XcodeGen project generation
- Fastlane build automation
- GitHub Actions CI/CD
- Codemagic integration
- TestFlight distribution

---

## Version History

### Pre-1.0 Development
- Implemented core features and functionality
- Developed UI components and workflows
- Established CI/CD pipeline
- Created comprehensive test coverage
- Fixed exercise persistence issues
- Added block history tracking
- Implemented week completion modal
- Enhanced exercise picker interface
- Integrated block generator AI
