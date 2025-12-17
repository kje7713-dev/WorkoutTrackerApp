# ChatGPT Block Generator - Quick Start Guide

## Overview

This feature adds AI-powered workout block generation to the Savage By Design app. Users can generate custom training blocks using ChatGPT or import blocks from JSON files.

## How to Use

### First Time Setup

1. Open the app and navigate to **Blocks**
2. Tap **AI BLOCK GENERATOR** (blue button with wand icon)
3. Enter your OpenAI API key in the "OpenAI API Key" section
4. Tap **Save API Key**

### Generating a Block

1. Select your preferred model (GPT-3.5-turbo or GPT-4)
2. Fill in the training parameters:
   - **Available Time**: Session duration in minutes (e.g., 45)
   - **Athlete Level**: Beginner, Intermediate, or Advanced
   - **Focus**: Training focus (e.g., "Full Body Strength", "Upper Body Hypertrophy")
   - **Allowed Equipment**: What equipment is available (e.g., "Barbell, Dumbbells, Rack")
   - **Exclude Exercises**: Any exercises to avoid (e.g., "Overhead Press" or "None")
   - **Primary Constraints**: Any limitations (e.g., "Lower back injury" or "None")
   - **Goal Notes**: Additional context about your goals
3. Tap **Generate Block**
4. Watch the streaming response appear in real-time
5. Review the generated block preview
6. Tap **Save to Blocks** to add it to your library

### Importing from JSON

1. Tap **Choose JSON File** in the "Import from JSON" section
2. Select a JSON file from your device
3. Review the parsed block preview
4. Tap **Save to Blocks**

## JSON File Format

If you're creating blocks with another LLM (Claude, Gemini, etc.), use this JSON format:

```json
{
  "Title": "Full Body Strength",
  "Goal": "Build foundational strength",
  "TargetAthlete": "Intermediate",
  "DurationMinutes": 45,
  "Difficulty": 3,
  "Equipment": "Barbell, Dumbbells",
  "WarmUp": "5 min dynamic stretching",
  "Exercises": [
    {
      "name": "Back Squat",
      "setsReps": "3x8",
      "restSeconds": 180,
      "intensityCue": "RPE 7"
    },
    {
      "name": "Bench Press",
      "setsReps": "3x8",
      "restSeconds": 120,
      "intensityCue": "RPE 7"
    }
  ],
  "Finisher": "10 min cooldown",
  "Notes": "Focus on form over weight",
  "EstimatedTotalTimeMinutes": 45,
  "Progression": "Add 5 lbs per week"
}
```

### Required Fields:
- **Title** (string): Block name
- **Goal** (string): Training objective
- **TargetAthlete** (string): Experience level
- **DurationMinutes** (integer): Session duration
- **Difficulty** (integer): 1-5 scale
- **Equipment** (string): Equipment list
- **WarmUp** (string): Warm-up description
- **Exercises** (array): Exercise list (see below)
- **Finisher** (string): Finisher/cooldown
- **Notes** (string): Additional notes
- **EstimatedTotalTimeMinutes** (integer): Total time estimate
- **Progression** (string): How to progress

### Exercise Format:
- **name** (string): Exercise name
- **setsReps** (string): Format like "3x8", "4x10" (supports 'x' or 'X')
- **restSeconds** (integer): Rest between sets in seconds
- **intensityCue** (string): Intensity guidance (RPE, RIR, %, etc.)

## Getting an OpenAI API Key

1. Go to [platform.openai.com](https://platform.openai.com)
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key
5. Copy and paste it into the app

**Note:** API usage incurs costs. GPT-3.5-turbo is cheaper than GPT-4.

## Features

✅ Direct ChatGPT integration with streaming responses  
✅ Model selection (GPT-3.5-turbo, GPT-4)  
✅ Secure API key storage in iOS Keychain  
✅ Two-stage parsing (JSON primary, HumanReadable fallback)  
✅ JSON file import for any LLM  
✅ Real-time streaming output display  
✅ Automatic session generation  
✅ Integration with existing block system  

## Troubleshooting

### "OpenAI API key not found"
- Make sure you've entered and saved your API key
- Try deleting and re-entering the key

### "Network error"
- Check your internet connection
- Verify your API key is valid
- Check if OpenAI services are operational

### "Failed to parse block"
- The AI's response format was unexpected
- Try generating again with clearer parameters
- Use the JSON import option as a fallback

### JSON Import Failed
- Verify the JSON file follows the correct format
- Check for syntax errors (missing commas, quotes, etc.)
- Validate JSON at [jsonlint.com](https://jsonlint.com)

## Tips for Best Results

1. **Be Specific**: Provide clear, detailed training parameters
2. **Equipment**: List all available equipment to get more variety
3. **Constraints**: Mention any injuries or limitations upfront
4. **Goals**: Clearly state your training objective
5. **Time**: Be realistic about available time
6. **Review**: Always review generated blocks before using them
7. **Adjust**: Feel free to edit blocks after generation (use manual builder)

## Technical Details

- Uses OpenAI Chat Completions API
- Supports streaming for real-time feedback
- Implements secure Keychain storage
- Two-stage parser (JSON + HumanReadable fallback)
- Generates single-day blocks (future: multi-day support)
- Creates sessions automatically via SessionFactory

## Future Enhancements

Planned improvements:
- Multi-day block generation
- Edit and regenerate functionality
- Block generation history
- Custom system messages
- Rate limiting and retry logic
- True incremental streaming

## Support

For issues or questions about this feature, refer to:
- [CHATGPT_INTEGRATION_SUMMARY.md](CHATGPT_INTEGRATION_SUMMARY.md) - Detailed implementation docs
- Code comments in the implementation files
- Test suite in `Tests/BlockGeneratorTests.swift`

---

**Version:** 1.0 (MVP)  
**Last Updated:** December 2025
