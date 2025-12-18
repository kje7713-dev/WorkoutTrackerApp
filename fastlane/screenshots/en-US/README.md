# App Store Screenshots

Place your App Store screenshots in this directory.

## Requirements

- iPhone screenshots: 
  - 6.7" Display (iPhone 15 Pro Max): 1290 x 2796 pixels
  - 6.5" Display (iPhone 14 Plus): 1284 x 2778 pixels
  
- iPad screenshots:
  - 12.9" Display (iPad Pro): 2048 x 2732 pixels

## Naming Convention

Screenshots should be named in the order they'll appear on the App Store:
- `1_screenshot.png`
- `2_screenshot.png`
- `3_screenshot.png`
- etc.

## Content Suggestions

1. Home screen showing training blocks
2. Block builder interface
3. Live workout session in progress
4. Exercise library view
5. Block history and progress tracking
6. Week completion celebration

## Automation

Consider using Fastlane's snapshot tool to automate screenshot generation:
```bash
bundle exec fastlane snapshot
```
