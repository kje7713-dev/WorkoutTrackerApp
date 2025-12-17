# Workout Tracker App (Savage By Design)

An iOS workout tracking application built with SwiftUI for creating, managing, and tracking strength training and conditioning workouts through a structured block periodization model.

## Features

- Create training blocks with multiple weeks and day templates
- Support for strength training (sets/reps/weight) and conditioning workouts (time/distance/calories)
- Exercise library management with categorization
- Live workout session tracking with logging capabilities
- **AI-assisted block generation with ChatGPT integration**
- Support for supersets, circuits, and complex training structures

## ChatGPT Integration Setup (DEV Mode)

The app now supports AI-powered workout block generation using OpenAI's ChatGPT API. Follow these steps to set up:

### 1. Get an OpenAI API Key

1. Go to [platform.openai.com](https://platform.openai.com)
2. Sign in or create an account
3. Navigate to the **API Keys** section in your account settings
4. Click **"Create new secret key"**
5. Copy the generated API key (you won't be able to see it again)

### 2. Configure API Key in the App

1. Build and run the app in Xcode
2. Navigate to the Block Builder screen
3. Look for the **"AI Generation"** section
4. Tap **"Generate with ChatGPT"**
5. If no API key is configured, you'll be prompted to enter it
6. The API key is securely stored in the iOS Keychain and never leaves your device

Alternatively, you can access ChatGPT settings through the app's settings menu (when implemented).

### 3. Generate Workout Blocks

1. In the Block Builder, tap **"Generate with ChatGPT"**
2. Enter your workout request (e.g., "Create a 4-week hypertrophy block with 4 days per week")
3. Select your preferred model (GPT-3.5 Turbo, GPT-4, etc.)
4. Tap **"Generate"**
5. Watch as the AI streams the workout block in real-time
6. Review the generated block and tap **"Accept & Use"** to load it into the builder
7. Make any manual adjustments as needed
8. Save the block

### Model Selection

- **GPT-3.5 Turbo**: Fast and cost-effective, good for standard workout blocks
- **GPT-4**: More advanced reasoning, better for complex programming
- **GPT-4 Turbo**: Latest model with improved performance

### API Key Security

- Your API key is stored securely in the iOS Keychain
- The key never leaves your device or is transmitted to any server except OpenAI's API
- API calls are made directly from your device to OpenAI
- You can delete your API key at any time from the settings

### Costs

OpenAI API usage is billed by token. Typical workout block generation costs:
- GPT-3.5 Turbo: ~$0.01-0.05 per block
- GPT-4: ~$0.10-0.30 per block

Check [OpenAI Pricing](https://openai.com/pricing) for current rates.

## Development Setup

### Requirements

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+
- XcodeGen (for project generation)
- Ruby (for Fastlane)

### Build Instructions

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   ```
3. Generate Xcode project:
   ```bash
   xcodegen generate
   ```
4. Open `WorkoutTrackerApp.xcodeproj` in Xcode
5. Build and run on simulator or device

### Project Structure

```
/
├── ChatGPTClient.swift         # OpenAI API client with streaming
├── KeychainHelper.swift        # Secure API key storage
├── ChatGPTBlockParser.swift    # Parser for AI-generated blocks
├── ChatGPTSettingsView.swift   # Settings UI for API key
├── BlockBuilderView.swift      # Block builder with AI integration
├── Models.swift                # Domain models
├── Repositories.swift          # Data access layer
├── SessionFactory.swift        # Session creation logic
└── ...
```

## Testing

Run tests in Xcode or via command line:
```bash
xcodebuild test -scheme WorkoutTrackerApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

## CI/CD

The project uses:
- GitHub Actions for CI
- Codemagic for iOS builds
- Fastlane for deployment automation
- TestFlight for beta distribution

## License

[Add your license here]

## Support

For issues or questions, please open an issue on GitHub.
