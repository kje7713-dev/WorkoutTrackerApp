# ChatGPT Block Generation Feature Guide

## Overview

This guide demonstrates how to use the new ChatGPT integration feature to generate workout blocks using AI.

## Prerequisites

1. **OpenAI API Key**: You need an API key from OpenAI
   - Sign up at [platform.openai.com](https://platform.openai.com)
   - Create an API key in your account settings
   - You'll be charged by OpenAI based on usage (typically $0.01-0.30 per block)

2. **iOS Device or Simulator**: Running iOS 17.0+

## Step-by-Step Guide

### 1. Configure API Key

**First Time Setup:**

1. Launch the app
2. Tap the **Settings** icon (⚙️) in the top-right corner of the Home screen
3. Enter your OpenAI API key in the secure field
4. Select your preferred model (GPT-3.5 Turbo recommended for cost)
5. Tap **"Test Connection"** to verify it works
6. Tap **"Save API Key"**
7. Tap **"Done"**

**Your API key is:**
- Stored securely in iOS Keychain
- Encrypted automatically by the OS
- Never transmitted except to OpenAI's API
- Only accessible by this app
- Deletable at any time

### 2. Generate a Workout Block

**Navigation:**
1. From Home screen, tap **"BLOCKS"**
2. Tap the **"+"** button to create a new block
3. In Block Builder, find the **"AI Generation"** section
4. Tap **"Generate with ChatGPT"**

**Enter Your Prompt:**

Think about what you want and describe it naturally. Examples:

**Beginner Example:**
```
Create a 4-week beginner strength training block with 3 days per week. 
Focus on compound movements: squat, bench press, deadlift, and overhead press. 
Start with 3 sets of 8 reps and add 5 lbs per week.
```

**Advanced Example:**
```
Create an 8-week powerlifting peaking block with 4 days per week. 
Day 1: Squat focus (heavy triples)
Day 2: Bench focus (volume)
Day 3: Deadlift focus (speed work)
Day 4: Accessories (isolation work)
Progressive overload leading to max attempts in week 8.
```

**Conditioning Example:**
```
Create a 6-week conditioning block for a CrossFit athlete. 
Include rowing intervals, bike sprints, and mixed modal workouts. 
Build from 20-minute sessions to 40-minute sessions.
Moderate to high intensity throughout.
```

**Hybrid Example:**
```
Create a 4-week hybrid block combining strength and conditioning.
Day 1: Upper body strength (bench, rows, accessories)
Day 2: Lower body strength (squats, deadlifts)
Day 3: Conditioning (30 min mixed cardio)
Day 4: Full body accessory work
Progressive overload on strength days, maintain conditioning.
```

### 3. Watch the Magic Happen

**Streaming Generation:**
- Tap **"Generate"** button
- The AI preview screen opens
- Watch as ChatGPT writes your block in real-time
- Text appears incrementally as it's generated
- Usually takes 10-30 seconds depending on complexity

**What You'll See:**
```
BLOCK: 4-Week Beginner Strength Block
DESCRIPTION: Progressive strength training for beginners
WEEKS: 4
GOAL: strength

DAY 1: Lower Body
SHORT: D1
---
Exercise: Back Squat
Type: strength
Category: squat
Sets: 3
Reps: 8
Weight: 135
Progression: +5
...
```

### 4. Review and Accept

**Options:**
- **Accept & Use**: Loads the block into the builder for editing
- **Regenerate**: Starts over with a new generation using the same prompt
- **Cancel**: Closes preview without loading anything

**After Accepting:**
- All block data populates the form
- You can see:
  - Block name and description
  - Number of weeks
  - All days with their exercises
  - Sets, reps, weights for each exercise
  - Progression rules
- Make any edits you want
- Tap **"Save"** to persist the block

### 5. Edit Before Saving (Optional)

**You can modify:**
- Block name and description
- Number of weeks
- Progression settings
- Add/remove days
- Add/remove exercises
- Change exercise parameters (sets, reps, weight)
- Add notes to exercises

**The AI-generated block is a starting point - customize it to your needs!**

### 6. Save and Use

- Tap **"Save"** when ready
- Sessions are automatically generated for all weeks
- The block appears in your Blocks list
- Start logging workouts immediately

## Tips for Better Results

### Be Specific
❌ Bad: "Make me a workout"
✅ Good: "Create a 6-week upper/lower split for muscle gain with 4 days per week"

### Include Key Details
- Duration (weeks)
- Frequency (days per week)
- Goal (strength, hypertrophy, conditioning, etc.)
- Exercise preferences
- Progression scheme

### Use Training Terminology
The AI understands:
- RPE (Rate of Perceived Exertion)
- RIR (Reps in Reserve)
- Tempo (e.g., "3010")
- Percentages (e.g., "75% of max")
- Conditioning terms (EMOM, AMRAP, intervals, etc.)

### Iterate if Needed
- If you don't like the result, tap "Regenerate"
- Or tap "Cancel" and try a different prompt
- The AI can generate infinite variations

## Example Prompts for Different Goals

### Strength Building
```
Create a 12-week strength block using 5/3/1 methodology.
Main lifts: squat, bench, deadlift, overhead press.
Include assistance work.
Progressive overload with deload in week 4, 8, and 12.
```

### Muscle Growth
```
Create a 6-week bodybuilding split:
Day 1: Chest and triceps
Day 2: Back and biceps  
Day 3: Rest
Day 4: Shoulders and abs
Day 5: Legs
Day 6-7: Rest
Focus on volume with 3-4 sets of 8-12 reps.
Progressive overload by adding weight or reps.
```

### Fat Loss
```
Create a 4-week fat loss block:
3 strength training days (full body, compound movements)
2 conditioning days (30-40 min moderate cardio)
High rep ranges (12-15) with short rest periods.
Include metabolic finishers.
```

### Athletic Performance
```
Create an 8-week block for a soccer player:
Day 1: Lower body power (squats, lunges, jumps)
Day 2: Upper body strength
Day 3: Conditioning (intervals, sprints)
Day 4: Rest
Day 5: Lower body strength
Day 6: Sport-specific conditioning
Day 7: Recovery
```

### Home Workouts
```
Create a 4-week bodyweight and dumbbell block for home training.
Equipment: dumbbells up to 50 lbs, resistance bands, pull-up bar.
Full body workouts 4 days per week.
Progressive overload by adding sets or reps.
```

## Model Selection Guide

### GPT-3.5 Turbo (Recommended for Most Users)
- **Cost**: ~$0.01-0.05 per block
- **Speed**: Fast (10-20 seconds)
- **Quality**: Excellent for standard workout blocks
- **Best for**: Standard strength/conditioning programs

### GPT-4
- **Cost**: ~$0.10-0.30 per block
- **Speed**: Moderate (20-40 seconds)
- **Quality**: Superior reasoning and complexity
- **Best for**: Complex periodization, specialized athletes, detailed programming

### GPT-4 Turbo
- **Cost**: ~$0.05-0.15 per block
- **Speed**: Fast (15-25 seconds)
- **Quality**: Latest model, improved performance
- **Best for**: Balance of cost and quality

**Recommendation**: Start with GPT-3.5 Turbo. Upgrade to GPT-4 if you need more sophisticated programming.

## Troubleshooting

### "No API key found"
- Go to Settings and enter your OpenAI API key
- Make sure you tapped "Save API Key"
- Try restarting the app

### "Invalid API key"
- Double-check your key from OpenAI dashboard
- Make sure you copied the entire key (starts with "sk-")
- Regenerate a new key if needed

### "Network error"
- Check your internet connection
- Try again in a few seconds
- OpenAI API might be temporarily down

### Generated block doesn't make sense
- Try regenerating with a more specific prompt
- Check that your prompt is clear and includes key details
- Switch to GPT-4 for better quality

### Can't find Settings
- Look for the gear icon (⚙️) in the top-right of the Home screen
- If not visible, make sure you're on the latest version

## Cost Management

### Typical Costs
- **Simple block** (3-4 days, basic exercises): $0.01-0.02
- **Standard block** (4-5 days, detailed programming): $0.03-0.08
- **Complex block** (6+ days, extensive detail): $0.10-0.20
- **GPT-4 blocks**: 10-20x more expensive than GPT-3.5

### Usage Tips to Save Money
1. Start with GPT-3.5 Turbo
2. Be concise in prompts (but still specific)
3. Edit generated blocks instead of regenerating repeatedly
4. Generate base block with AI, then clone and modify for variations

### Monitor Your Usage
- Check your OpenAI dashboard for API usage
- Set spending limits in OpenAI account settings
- Delete API key from app when not actively using

## Privacy & Security

### What's Stored
- ✅ API key (encrypted in iOS Keychain)
- ✅ Selected model preference (UserDefaults)
- ❌ Not stored: Your prompts, generated blocks (until you save)

### What's Transmitted
- ✅ To OpenAI: Your prompt, API key (over HTTPS)
- ❌ Not transmitted: Anything else

### Data Retention
- OpenAI may temporarily log requests (per their policy)
- No data sent to any server except OpenAI
- App developer cannot see your API key or prompts

### Best Practices
- Don't share your API key
- Delete API key if device is lost/stolen
- Use a separate OpenAI account for this app if desired
- Review OpenAI's data policy at openai.com

## Advanced Usage

### Refining Blocks
After accepting a generated block:
1. Edit exercise order
2. Adjust sets/reps/weights to your level
3. Add accessory exercises
4. Modify progression schemes
5. Add detailed notes
6. Save and start training

### Creating Variations
1. Generate a base block
2. Save it
3. Clone it (Edit → Clone)
4. Modify for next training phase
5. Repeat for periodization

### Combining AI and Manual
1. Use AI for structure and main lifts
2. Manually add favorite accessory exercises
3. Adjust to your equipment and preferences
4. Best of both worlds!

## Support

### Getting Help
- Check README.md for setup instructions
- Review this guide for usage tips
- Check CHATGPT_INTEGRATION_SUMMARY.md for technical details

### Known Limitations
- Requires internet connection
- Costs money (you pay OpenAI directly)
- AI sometimes makes mistakes (review before accepting)
- Complex workout schemes (drop sets, pyramids) may need manual editing
- No conversation history (each generation is independent)

### Feedback
- Report issues on GitHub
- Suggest improvements for system prompt
- Share successful prompts with community

## Conclusion

The ChatGPT integration makes it incredibly easy to generate professional workout blocks in seconds. Combined with the app's tracking features, you have a complete training solution from planning to execution to analysis.

**Happy Training! 💪**
