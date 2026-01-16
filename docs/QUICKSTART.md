# Quick Start Guide

Get up and running with WorkoutTrackerApp development in 10 minutes.

## Prerequisites

Before you start, ensure you have:

- ✅ macOS (required for iOS development)
- ✅ Xcode 26.0 or later
- ✅ Homebrew (for installing dependencies)
- ✅ Ruby 3.2+ (usually pre-installed on macOS)

## Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone https://github.com/kje7713-dev/WorkoutTrackerApp.git
cd WorkoutTrackerApp
```

### 2. Install Dependencies

```bash
# Install XcodeGen (generates Xcode project from project.yml)
brew install xcodegen

# Install Ruby dependencies (Fastlane)
bundle install
```

### 3. Generate Xcode Project

```bash
xcodegen generate
```

This creates `WorkoutTrackerApp.xcodeproj` from `project.yml`.

### 4. Open in Xcode

```bash
open WorkoutTrackerApp.xcodeproj
```

Or double-click `WorkoutTrackerApp.xcodeproj` in Finder.

### 5. Build and Run

1. Select a simulator (e.g., iPhone 15) from the device menu
2. Press `⌘R` or click the Play button
3. The app will build and launch in the simulator

🎉 **You're done!** The app should now be running.

## First Time Using the App?

When you first run the app:

1. **Home Screen**: Shows an empty list of training blocks
2. **Create a Block**: Tap the "+" button to create your first training block
3. **Add Exercises**: Browse or add exercises to your workout
4. **Start Tracking**: Begin logging your workouts!

## Making Your First Change

### Example: Update the App Name Display

1. Open `SavageByDesignApp.swift`
2. Find the `HomeView()` line
3. The app uses "SBD" as the display name (set in Info.plist)
4. Make a change, press `⌘R` to rebuild

### Example: Add a New View

1. Create a new Swift file: File → New → File → Swift File
2. Add your SwiftUI view:
   ```swift
   import SwiftUI
   
   struct MyNewView: View {
       var body: some View {
           Text("Hello, World!")
       }
   }
   ```
3. Use it in another view with `NavigationLink` or `.sheet()`

## Running Tests

Run all tests: `⌘U`

Or run specific test files through Xcode's test navigator (`⌘6`).

## Common Tasks

### Regenerate Xcode Project

If you modify `project.yml`:

```bash
xcodegen generate
```

Then reopen the project in Xcode.

### Run SwiftLint

```bash
# Install SwiftLint
brew install swiftlint

# Run linter
swiftlint
```

Fix warnings before committing.

### Clean Build

If you encounter build issues:

1. In Xcode: Product → Clean Build Folder (`⌘⇧K`)
2. Or manually: `rm -rf ~/Library/Developer/Xcode/DerivedData/`

## Project Structure at a Glance

```
WorkoutTrackerApp/
├── Models.swift              # Data models (Block, Exercise, Session)
├── Repositories.swift        # Data persistence layer
├── *View.swift               # SwiftUI views
├── Logger.swift              # Logging utility
├── Theme.swift               # App styling
├── Assets.xcassets/          # Images and icons
├── Tests/                    # Unit tests
├── project.yml               # XcodeGen config (generates .xcodeproj)
└── fastlane/                 # Build automation
```

## Understanding the Architecture

**MVVM + Repository Pattern:**

```
User Interaction → View → Repository → JSON Files
                     ↑         ↓
                  @Published  Data
```

- **Views**: SwiftUI views (UI only)
- **Repositories**: Business logic + state management (ObservableObject)
- **Models**: Data structures (Codable for JSON)
- **Persistence**: JSON files in Documents directory

## Key Concepts

### Training Blocks

A **Block** is a multi-week training program with:
- Weeks (e.g., 4 weeks)
- Day Templates (e.g., Monday: Upper Body)
- Exercise Templates (e.g., Bench Press: 3x5)

### Workout Sessions

When you start a workout, a **WorkoutSession** is created from templates with:
- SessionSets (actual logged sets with weight/reps)
- Real-time tracking
- Completion status

### Exercise Types

- **Strength**: Sets, reps, weight
- **Conditioning**: Time, distance, calories

## Common Gotchas

1. **Project regeneration**: After changing `project.yml`, run `xcodegen generate`
2. **EnvironmentObjects**: Views need `.environmentObject()` for repositories
3. **Codable models**: Changes to models may break existing saved data during development
4. **Simulator data**: Each simulator has separate data; physical device is different too

## Getting Help

- **Documentation**: Check `docs/` folder
- **Issues**: Search [GitHub Issues](https://github.com/kje7713-dev/WorkoutTrackerApp/issues)
- **Code Questions**: Open a discussion on GitHub
- **Contributing**: Read [CONTRIBUTING.md](../CONTRIBUTING.md)

## Next Steps

Now that you're set up:

1. ✅ Explore the app's features
2. ✅ Read [CONTRIBUTING.md](../CONTRIBUTING.md) for workflow
3. ✅ Check [open issues](https://github.com/kje7713-dev/WorkoutTrackerApp/issues) for tasks
4. ✅ Review [Architecture section in README](../README.md#architecture)
5. ✅ Make your first contribution!

## Useful Commands

```bash
# Generate project
xcodegen generate

# Install dependencies
bundle install

# Run linter
swiftlint

# Build via command line
xcodebuild -project WorkoutTrackerApp.xcodeproj \
           -scheme WorkoutTrackerApp \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           build

# Run tests via command line
xcodebuild test -project WorkoutTrackerApp.xcodeproj \
                -scheme WorkoutTrackerApp \
                -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Tips for Productive Development

1. **Use Xcode shortcuts**: Learn `⌘B` (build), `⌘R` (run), `⌘U` (test)
2. **Live Preview**: Use SwiftUI previews for faster iteration
3. **Breakpoints**: Use Xcode debugger with breakpoints
4. **Simulator**: Use `⌘D` to toggle device frame
5. **Dark Mode**: Test both light and dark modes
6. **Accessibility**: Test with accessibility inspector

## Troubleshooting

### "No such module" error

```bash
xcodegen generate
# Clean build folder in Xcode (⌘⇧K)
# Rebuild (⌘B)
```

### "Command Line Tools not found"

```bash
xcode-select --install
```

### Simulator not loading

1. Restart simulator: Device → Erase All Content and Settings
2. Or create a new simulator in Xcode preferences

### Build taking too long

- Close unnecessary apps
- Increase Xcode build threads: Preferences → Build
- Clean derived data occasionally

---

**Ready to contribute?** Check out [good first issues](https://github.com/kje7713-dev/WorkoutTrackerApp/labels/good%20first%20issue)!
