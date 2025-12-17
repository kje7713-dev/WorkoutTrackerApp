# Block JSON Import - Quick Start Guide

## Overview

This feature allows you to import custom training blocks from JSON files into the Savage By Design app. Generate blocks using any AI assistant (ChatGPT, Claude, Gemini, etc.) and import them directly into your training library.

## How to Use

### Importing a Block

1. Open the app and navigate to **Blocks**
2. Tap **IMPORT FROM JSON** (blue button)
3. Tap **Choose JSON File**
4. Select a JSON file from your device
5. Review the block preview
6. Tap **Save Block to Library**

The block will be added to your library with automatically generated workout sessions.

## JSON File Format

Your JSON file must follow this structure:

```json
{
  "Title": "Full Body Strength",
  "Goal": "Build foundational strength",
  "TargetAthlete": "Intermediate",
  "DurationMinutes": 45,
  "Difficulty": 3,
  "Equipment": "Barbell, Dumbbells, Rack",
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
    },
    {
      "name": "Barbell Row",
      "setsReps": "3x8",
      "restSeconds": 120,
      "intensityCue": "RPE 7"
    }
  ],
  "Finisher": "10 min cooldown stretch",
  "Notes": "Focus on form over weight",
  "EstimatedTotalTimeMinutes": 45,
  "Progression": "Add 5 lbs per week"
}
```

### Required Fields

All fields are required:

- **Title** (string): Block name
- **Goal** (string): Training objective
- **TargetAthlete** (string): Experience level (Beginner, Intermediate, Advanced)
- **DurationMinutes** (integer): Session duration in minutes
- **Difficulty** (integer): 1-5 scale
- **Equipment** (string): Equipment list
- **WarmUp** (string): Warm-up description
- **Exercises** (array): Exercise list (see below)
- **Finisher** (string): Finisher/cooldown description
- **Notes** (string): Additional notes or instructions
- **EstimatedTotalTimeMinutes** (integer): Total time estimate including warm-up and finisher
- **Progression** (string): How to progress week-to-week

### Exercise Format

Each exercise in the `Exercises` array must have:

- **name** (string): Exercise name
- **setsReps** (string): Format like "3x8", "4x10", "5x5" (supports 'x' or 'X')
- **restSeconds** (integer): Rest between sets in seconds
- **intensityCue** (string): Intensity guidance (RPE, RIR, percentage, tempo, etc.)

## Generating JSON with AI

You can use any AI assistant to generate blocks. Here's a sample prompt:

```
Create a workout block in JSON format with the following structure:
{
  "Title": "Block name",
  "Goal": "Training goal",
  "TargetAthlete": "Experience level",
  "DurationMinutes": 45,
  "Difficulty": 3,
  "Equipment": "Available equipment",
  "WarmUp": "Warm-up description",
  "Exercises": [
    {
      "name": "Exercise name",
      "setsReps": "3x8",
      "restSeconds": 180,
      "intensityCue": "RPE 7"
    }
  ],
  "Finisher": "Finisher description",
  "Notes": "Additional notes",
  "EstimatedTotalTimeMinutes": 45,
  "Progression": "Progression strategy"
}

Please create a [your specific requirements] workout block.
```

### Example Prompts:

**Strength Focus:**
```
Create a 4-day upper/lower split strength block for an intermediate lifter with access to a full gym. Target 60 minutes per session.
```

**Conditioning Focus:**
```
Create a 30-minute conditioning workout for advanced athletes using only bodyweight and dumbbells.
```

**Specific Goal:**
```
Create a bench press focused block for improving 1RM, including accessory work. 45 minutes, 3 days per week.
```

## Troubleshooting

### "Invalid JSON format"
- Verify your JSON syntax at [jsonlint.com](https://jsonlint.com)
- Check for missing commas, quotes, or brackets
- Ensure all required fields are present
- Make sure field names match exactly (case-sensitive)

### "Missing required field: [field name]"
- Add the missing field to your JSON
- Refer to the format example above

### "Type mismatch"
- Check that numbers are not in quotes (e.g., use `45` not `"45"`)
- Check that strings are in quotes (e.g., use `"Title"` not `Title`)
- Verify array format for Exercises

### File Won't Import
- Make sure the file has a `.json` extension
- Try re-saving the file with UTF-8 encoding
- Check that the file isn't corrupted

## Features

✅ Import blocks from any LLM (ChatGPT, Claude, Gemini, etc.)  
✅ Automatic session generation  
✅ Preview before saving  
✅ Detailed error messages  
✅ Support for custom exercises  
✅ Integration with existing block system  
✅ Dark/light mode support  

## Tips for Best Results

1. **Be Specific**: Provide clear requirements to your AI assistant
2. **Validate JSON**: Always check JSON syntax before importing
3. **Review Preview**: Check the block preview before saving
4. **Test Small**: Start with a simple 1-2 exercise block to test
5. **Save Files**: Keep your JSON files for future reference
6. **Iterate**: If import fails, ask the AI to fix the JSON format

## Technical Details

- Parses JSON using Swift's JSONDecoder
- Supports both 'x' and 'X' in sets/reps notation
- Automatically creates ExerciseTemplates with StrengthSetTemplates
- Generates sessions via SessionFactory
- Sets block source to `.ai` for tracking
- Creates progression rules based on block parameters

## Example Use Cases

### Powerlifting Block
Generate a 12-week powerlifting peaking block with progressive overload.

### CrossFit-style WODs
Create varied daily workouts with different time domains and movements.

### Bodybuilding Split
Design a 5-day bodybuilding split with volume progression.

### Rehabilitation
Create conservative blocks for injury recovery with specific constraints.

### Sport-Specific
Build blocks tailored to specific sports (e.g., football, basketball, MMA).

## Future Enhancements

Planned improvements:
- Multi-day block support (currently single day)
- Conditioning exercise templates
- Superset/circuit grouping in JSON
- Block library sharing
- Template marketplace

---

**Version:** 1.0  
**Last Updated:** December 2025
