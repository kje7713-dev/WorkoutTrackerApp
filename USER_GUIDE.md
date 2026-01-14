# Savage By Design – User Guide

**Welcome to Savage By Design!** This guide will help you get the most out of your workout tracking experience. Whether you're a seasoned athlete or just starting structured training, this app is designed to help you plan, execute, and track your fitness journey.

> **"We are what we repeatedly do. Excellence, then, is not an act, but a habit."**

---

## 🚀 Quick Start Guide

New to Savage By Design? Follow these three essential steps to get up and running in minutes:

### Step 1: Unlock Pro Features (Optional but Recommended)

Pro features include **AI Block Import**, **Whiteboard View**, and **Unlimited Blocks**. You have two options:

#### Option A: Development Unlock (For Testing)
1. From the Home Screen, tap **GO PRO**
2. On the subscription screen, look for **"Enter Code"** button
3. Tap **"Enter Code"**
4. Type: **dev** (case-insensitive)
5. Tap **"Unlock"**
6. ✅ You now have full Pro access!

**Note:** The dev unlock is perfect for testing and development. It persists across app restarts and doesn't interfere with StoreKit.

#### Option B: Subscribe to Pro
1. From the Home Screen, tap **GO PRO**
2. Review available plans (Monthly or Annual)
3. Check if you're eligible for a **Free Trial**
4. Tap **Subscribe** to start
5. Complete purchase through Apple App Store
6. ✅ Pro features unlocked!

**Pro Benefits:**
- ✅ **AI Block Import** – Generate workout programs using ChatGPT/Claude and import them
- ✅ **Whiteboard View** – Clean, printable workout display
- ✅ **Unlimited Blocks** – Create as many training programs as you need
- ✅ **Priority Support** – Get help faster

---

### Step 2: Create Your First Block Using AI

The fastest way to get started is by using **AI Block Import** to generate a complete training program:

#### 2.1: Generate JSON with AI Assistant

1. From Home Screen, tap **BLOCKS**
2. Tap **AI BLOCK GENERATOR** button
3. You'll see the **AI Prompt Template** section at the top
4. In the text field, describe your training goals. For example:
   ```
   4-week strength program for intermediate lifter
   3 days per week: Upper Push, Lower Body, Upper Pull
   Focus on compound movements
   ```
5. Tap **COPY COMPLETE PROMPT** 
6. The app copies a comprehensive prompt to your clipboard

#### 2.2: Get JSON from Your AI Assistant

1. Open **ChatGPT**, **Claude**, or your preferred AI assistant
2. Paste the prompt you just copied
3. Send the message
4. The AI will analyze your requirements and generate a structured JSON training block
5. **Copy the JSON output** (just the JSON, starting with `{` and ending with `}`)

#### 2.3: Import the Block

1. Return to the **AI Block Generator** screen in Savage By Design
2. Scroll to the **"Import JSON"** section
3. **Option A - Paste JSON:**
   - Tap in the large text area
   - Paste the JSON from your AI assistant
   - Tap **IMPORT FROM TEXT**
4. **Option B - Import File:**
   - Save the JSON as a `.json` file
   - Tap **IMPORT FROM FILE**
   - Select your JSON file
5. ✅ Your block is imported and ready!

**What the AI Prompt Template Includes:**
- Complete JSON schema specification
- Examples for strength and conditioning exercises
- Segment-based training options (BJJ, yoga, martial arts, learning sessions)
- Hybrid day structures (exercises + segments)
- Progressive overload configuration
- Detailed field descriptions

**Pro Tip:** The AI prompt is designed to produce coach-grade training programs. It includes entropy classification, goal stimulus analysis, and smart defaults to ensure your block is properly structured.

---

### Step 3: Run Your Block

Now that you have a training block, it's time to start your workout:

#### 3.1: Start a Session

1. From **BLOCKS** screen, find your imported block
2. Tap the **RUN** button
3. The app creates workout sessions for all weeks based on your template
4. You're now in **Session Run View** – your workout tracking interface

#### 3.2: Navigate Your Workout

**Week Navigation:**
- **Swipe left/right** to change weeks
- Current week is highlighted at the top
- See your full training block timeline

**Day Navigation:**
- **Tap day tabs** at the top to switch between workout days
- Each day shows all exercises or segments for that session

#### 3.3: Log Your Work

**For Exercise-Based Days:**
1. Each exercise shows **expected values** (sets, reps, weight) from your template
2. **Tap a set** to expand and log actual performance
3. Use **+ / -** buttons to adjust weight, reps, or other metrics
4. Mark RPE (Rate of Perceived Exertion) or RIR (Reps in Reserve) if desired
5. Check the **✓ box** when you complete the set
6. Completed sets turn **green**

**For Segment-Based Days (BJJ, Yoga, Learning, etc.):**
1. Each segment shows its type, duration, and objective
2. **Tap the segment card** to expand and view full details
3. Check the **✓ box** when you complete the segment
4. For timed rounds (sparring, drilling):
   - Use **+ / -** buttons to log rounds completed
   - Track quality metrics (success rate, clean reps) if specified
5. Add notes about technique, feedback, or observations

**Status Indicators:**
- **Gray** – Not started
- **Green with checkmark** – Completed
- **Progress bar** – Shows overall completion percentage

#### 3.4: Use the Whiteboard (Pro Feature)

During your workout, you can view a clean, gym-friendly display:

1. Tap **Whiteboard** in the top-right corner
2. Select the week you want to view
3. See all exercises/segments in an easy-to-read format
4. Perfect for referencing between sets or sharing with coaches
5. Tap any day card for full-screen view

#### 3.5: Complete Your Workout

1. Finish all the sets or segments you plan to do
2. Tap **Close Session** in the top-left
3. The app **auto-saves** all your data
4. Progress is recorded in your block history

**Week Completion:**
- When you finish all days in a week, you'll see a completion modal
- Review your stats (sets completed, exercises done)
- Tap **Continue to Next Week** to advance

**Block Completion:**
- When you finish the final week, you'll see a celebration screen
- The block is automatically archived to **Block History**
- Review it anytime from the History screen

---

## 📊 Quick Start Summary

**In just 3 steps, you've:**
1. ✅ Unlocked Pro features (dev code or subscription)
2. ✅ Generated and imported a complete AI training block
3. ✅ Started tracking your workouts with live logging

**Next Steps:**
- Explore [Understanding Training Blocks](#understanding-training-blocks) to learn program design
- Check out [Segment Use Cases](#segment-use-cases) for non-traditional training (BJJ, yoga, learning)
- Review [Tips & Best Practices](#tips--best-practices) for optimal results
- Set up [Data Management](#data-management) backups to protect your progress

**Need Help?**
- Jump to [Troubleshooting](#troubleshooting) for common issues
- Email: savagesbydesignhq@gmail.com
- Check [GitHub Discussions](https://github.com/kje7713-dev/WorkoutTrackerApp/discussions)

---

## Table of Contents

1. [🚀 Quick Start Guide](#-quick-start-guide) ⬅️ **Start here!**
2. [Getting Started](#getting-started)
3. [Understanding Training Blocks](#understanding-training-blocks)
4. [Creating Your First Block](#creating-your-first-block)
5. [Understanding Exercises](#understanding-exercises)
6. [Understanding Segments](#understanding-segments)
7. [Segment Use Cases](#segment-use-cases)
8. [Creating Segment-Based Days](#creating-segment-based-days)
9. [Running Workout Sessions](#running-workout-sessions)
10. [Using the Whiteboard](#using-the-whiteboard)
11. [Tracking Your Progress](#tracking-your-progress)
12. [AI Block Generation](#ai-block-generation)
13. [Pro Features](#pro-features)
14. [Data Management](#data-management)
15. [Tips & Best Practices](#tips--best-practices)
16. [Troubleshooting](#troubleshooting)

---

## Getting Started

### First Launch

When you open Savage By Design for the first time, you'll see the **Home Screen** with four main options:

- **BLOCKS** – Create and manage your training blocks
- **BLOCK HISTORY** – Review archived and completed blocks
- **DATA MANAGEMENT** – Backup, restore, and manage your workout data
- **GO PRO** – Unlock premium features with a subscription

### Navigation

The app uses a simple, intuitive navigation structure:
- Tap any button to navigate to that section
- Use the back button (top-left) to return to the previous screen
- Swipe gestures work for navigating between weeks during workouts

---

## Understanding Training Blocks

### What is a Training Block?

A **training block** is a structured workout program that spans multiple weeks. Think of it as a complete training cycle designed to help you achieve specific fitness goals.

**Key Components:**
- **Block Name** – What you call your program (e.g., "Summer Strength Program")
- **Number of Weeks** – How long the block runs (typically 4-12 weeks)
- **Days** – Individual workout days that repeat each week
- **Exercises** – The specific movements you'll perform

### Block Periodization

The app uses **block periodization**, a proven training method where:
- You plan workouts in advance
- Exercises progress week-over-week (progressive overload)
- You can program deload weeks for recovery
- Each week builds on the previous one

**Example Block Structure:**
```
Block: "Spring Strength Cycle"
├── Week 1-3: Build phase
├── Week 4: Deload
└── Weeks 5-6: Peak phase

Days per week:
├── Day 1: Upper Body Push
├── Day 2: Lower Body
├── Day 3: Upper Body Pull
└── Day 4: Conditioning
```

### Training Goals

Blocks can target different goals:
- **Strength** – Build maximum force production
- **Hypertrophy** – Muscle size and growth
- **Power** – Explosive strength
- **Conditioning** – Cardiovascular fitness
- **Mixed** – Combination of goals
- **Peaking** – Preparing for competition
- **Deload** – Recovery and adaptation
- **Rehab** – Injury recovery

---

## Creating Your First Block

### Step 1: Access Block Builder

1. From the Home Screen, tap **BLOCKS**
2. Tap **CREATE NEW BLOCK** at the bottom
3. You'll enter the Block Builder interface

### Step 2: Set Block Details

**Block Information:**
- **Name** – Give your block a memorable name (e.g., "12-Week Strength Builder")
- **Description** (optional) – Add notes about the program
- **Number of Weeks** – Choose how many weeks (1-52)
- **Progression Type** – How exercises will progress:
  - **Weight** – Add weight each week
  - **Volume** – Add sets/reps each week
  - **Custom** – Manual progression

**Progression Settings:**
- **Delta Weight** – How much weight to add per week (e.g., 5 lbs)
- **Delta Sets** – How many additional sets per week (e.g., 1 set)

### Step 3: Create Day Templates

Each block contains **day templates** that define your workouts:

1. **Select a Day Tab** at the top (Day 1, Day 2, etc.)
2. **Name Your Day** – E.g., "Upper Body Push", "Legs", "Conditioning"
3. **Add Exercises** by tapping the **+ ADD EXERCISE** button

### Step 4: Add Exercises to Days

For each exercise, specify:

**Exercise Details:**
- **Name** – What exercise you're doing (e.g., "Bench Press", "Back Squat")
- **Type** – Strength or Conditioning
- **Notes** (optional) – Coaching cues or reminders

**For Strength Exercises:**
- **Number of Sets** – How many sets (e.g., 4)
- **Reps** – Repetitions per set (e.g., 6)
- **Weight** – Starting weight in pounds or kg
- **RPE** (Rating of Perceived Exertion) – Scale of 1-10
- **RIR** (Reps in Reserve) – How many reps left in the tank
- **Tempo** – Movement speed (e.g., "3-1-1-0")
- **Rest** – Seconds between sets (e.g., 180)

**For Conditioning Exercises:**
- **Duration** – Time in seconds
- **Distance** – Meters or miles
- **Rounds** – Number of rounds to complete
- **Calories** – Target calorie burn
- **Target Pace** – Desired pace (e.g., "2:00/500m")
- **Effort Descriptor** – Intensity level (e.g., "Easy", "Moderate", "Hard")
- **Rest** – Recovery time between intervals

### Step 5: Save Your Block

1. Review all days and exercises
2. Tap **SAVE** in the top-right corner
3. Your block is now ready to run!

**Pro Tip:** Start with 3-4 days per week and 4-6 exercises per day for your first block.

---

## Understanding Exercises

### Exercise Types

The app supports two main exercise types:

#### 1. Strength Training
**Characteristics:**
- Uses sets, reps, and weight
- Focuses on resistance training
- Examples: Squats, bench press, deadlifts, rows, curls

**How to Log:**
- Enter the weight you lifted
- Record actual reps performed
- Mark RPE/RIR if tracking intensity
- Check off each set as completed

#### 2. Conditioning
**Characteristics:**
- Uses time, distance, or calories
- Focuses on cardiovascular fitness
- Examples: Running, rowing, cycling, swimming, jump rope

**How to Log:**
- Record time or distance covered
- Note calories burned (if tracked)
- Mark rounds completed for intervals
- Set effort level or pace

### Exercise Categories

Exercises are organized by movement pattern:
- **Squat** – Squat variations
- **Hinge** – Deadlift, Romanian deadlift, hip thrusts
- **Press Horizontal** – Bench press, push-ups, dips
- **Press Vertical** – Overhead press, push press
- **Pull Horizontal** – Rows, inverted rows
- **Pull Vertical** – Pull-ups, lat pulldowns
- **Carry** – Farmer's carries, suitcase carries
- **Core** – Planks, ab exercises
- **Olympic** – Cleans, snatches, jerks
- **Conditioning** – Cardio and metabolic work
- **Mobility** – Stretching and movement prep
- **Other** – Miscellaneous exercises

---

## Understanding Segments

### What are Segments?

**Segments** are an alternative way to structure training days, designed for activities that don't fit the traditional sets/reps/weight model. While exercises focus on strength and conditioning with quantifiable metrics, segments represent distinct phases or modules within a training session.

**Key Differences:**

| **Exercises** | **Segments** |
|---------------|--------------|
| Sets, reps, weight | Time-based modules |
| Strength & conditioning focused | Skill-based activities |
| Progressive overload via weight/volume | Progressive via complexity/resistance |
| Examples: Squats, bench press | Examples: Technique work, sparring rounds |

### When to Use Segments vs. Exercises

**Use Exercises for:**
- Weightlifting and strength training
- Conditioning with measurable outputs (distance, calories, time)
- Activities with clear set/rep structures
- Progressive overload through weight or volume

**Use Segments for:**
- Martial arts training (BJJ, wrestling, judo, MMA)
- Yoga and mobility work
- Skill-based practice sessions
- Class-style training with distinct phases
- Activities focused on technique over load

**Hybrid Approach:**
You can mix both in a single day! For example:
- Strength training (exercises) followed by mobility work (segments)
- BJJ class (segments) with conditioning finisher (exercises)

### Segment Types

The app supports various segment types to match your training structure:

#### 1. Warmup
**Purpose:** Prepare the body and mind for training
**Typical Duration:** 5-10 minutes
**Examples:**
- Dynamic stretching sequences
- Movement preparation drills
- Sport-specific warm-up patterns
- General cardiovascular warm-up

**What to Include:**
- Light movement to raise body temperature
- Joint mobility work
- Movement patterns used in the session
- Mental preparation and focus

#### 2. Mobility
**Purpose:** Flexibility, range of motion, and movement quality
**Typical Duration:** 10-20 minutes
**Examples:**
- Yoga flows
- Dynamic stretching routines
- Joint mobility sequences
- Foam rolling protocols

**Tracking Options:**
- Hold duration (seconds)
- Breath count
- Intensity scale (restorative to peak)
- Props used (blocks, straps, rollers)

#### 3. Technique
**Purpose:** Learn and refine specific skills or movements
**Typical Duration:** 10-20 minutes
**Examples:**
- Martial arts technique instruction
- Movement pattern practice
- Skill progressions
- Form work

**What to Track:**
- Techniques covered
- Key coaching cues
- Common errors to avoid
- Success rate and clean reps

#### 4. Drill
**Purpose:** Repetitive practice with specific constraints
**Typical Duration:** 5-15 minutes
**Examples:**
- Timed drill circuits
- Partner drilling sequences
- Positional repetitions
- Skill isolation work

**Structure Options:**
- Work/rest intervals
- Rep-based progressions
- Partner rotation schedules
- Constraint progressions

#### 5. Positional Sparring
**Purpose:** Live practice from specific positions with defined rules
**Typical Duration:** 10-20 minutes
**Examples:**
- Grappling from specific positions
- Scenario-based sparring
- Flow rolling with constraints
- Positional battles

**Key Features:**
- Starting positions defined
- Win conditions specified
- Resistance levels (0-100%)
- Role definitions (attacker/defender)

#### 6. Rolling / Live Training
**Purpose:** Free practice or sparring
**Typical Duration:** 15-30 minutes
**Examples:**
- Free rolling (BJJ)
- Live wrestling
- Open sparring rounds
- Competition simulation

**Typical Format:**
- Round-based (e.g., 5 rounds × 5 minutes)
- Rest intervals between rounds
- Partner rotation
- Intensity management

#### 7. Cooldown
**Purpose:** Recovery and transition out of training
**Typical Duration:** 5-10 minutes
**Examples:**
- Static stretching
- Breathwork
- Gentle movement
- Reflection and notes

**Recovery Focus:**
- Lower heart rate gradually
- Address tight areas
- Mental recovery
- Session review

#### 8. Lecture / Review
**Purpose:** Instructional content and conceptual learning
**Typical Duration:** 5-15 minutes
**Examples:**
- Video review
- Strategy discussion
- Conceptual instruction
- Q&A sessions

#### 9. Breathwork
**Purpose:** Respiratory training and nervous system regulation
**Typical Duration:** 5-15 minutes
**Examples:**
- Box breathing
- Diaphragmatic breathing
- Wim Hof method
- Pranayama techniques

**Tracking:**
- Breathing pattern (e.g., "4s inhale / 6s exhale")
- Duration
- Breath count
- Style/method used

#### 10. Other
**Purpose:** Custom segment types not covered above
**Use for:** Any activity that doesn't fit standard categories

---

## Segment Use Cases

Segments are incredibly versatile and can be used for **far more than just athletic training**. This section showcases how segments can structure any time-based learning or skill development activity.

### Traditional Athletic Training
- Brazilian Jiu-Jitsu (BJJ) classes
- Yoga and mobility work
- Wrestling practice
- MMA striking classes
- Hybrid athlete programs (strength + mobility)
- Open mat / free training sessions

### Non-Traditional Learning & Skill Development
- **Technology & AI Learning:** Coding bootcamps, AI/ML classes, software development
- **Language Learning:** Conversation practice, grammar drills, vocabulary building
- **Music Practice:** Instrument technique, improvisation, composition
- **Professional Development:** Public speaking, leadership training, presentation skills
- **Academic Study:** Research sessions, exam preparation, concept mastery
- **Creative Skills:** Writing workshops, design critique sessions, art practice

The examples below demonstrate how segments provide structure for both athletic and non-athletic pursuits. **The key is recognizing that any activity with distinct time-based phases can benefit from segment structure.**

### Use Case 1: Brazilian Jiu-Jitsu (BJJ) Class

**Structure:** Segment-based day representing a typical BJJ class

**Example Day Structure:**
```
BJJ Class: Inside Tie to Single Leg (60 minutes)

1. Warmup (8 min)
   - General movement and grappling prep
   - Stance work and sprawls
   - Partner pummeling

2. Technique 1 (12 min)
   - Inside tie to single leg entry
   - Partner drilling with light resistance
   - Focus: Clean entry and head position

3. Technique 2 (12 min)
   - Single leg finishing options
   - Run-the-pipe and shelf finishes
   - Partner drilling with progression

4. Drill (10 min)
   - Constrained drilling with specific rules
   - Timed rounds with quality focus
   - Partner rotation

5. Positional Sparring (10 min)
   - From standing, must attempt single within 10s
   - Win conditions: Takedown + 3s control
   - Moderate resistance (50%)

6. Live Rolling (6 min)
   - 2 rounds × 3 minutes
   - Free rolling to integrate techniques
   - Rest 30s between rounds

7. Cooldown (2 min)
   - Light stretching
   - Breathwork
```

**Why Segments Work Better Than Exercises:**
- Class structure is time-based, not set-based
- Focus on skill acquisition, not weight progression
- Roles (attacker/defender) and resistance levels matter
- Quality metrics (success rate, clean reps) more relevant than total volume

**Tracking During Session:**
- Check off completed segments
- Log rounds completed
- Note success rate for positional work
- Record coach feedback and personal observations

### Use Case 2: Yoga Practice

**Structure:** Segment-based yoga session

**Example Day Structure:**
```
Restorative Yoga (45 minutes)

1. Breathwork (5 min)
   - Diaphragmatic breathing
   - Pattern: 4s inhale / 6s exhale
   - Seated meditation posture

2. Gentle Flow (15 min)
   - Sun salutations modified
   - Intensity: Easy
   - Props: Block, strap
   - Flow sequence:
     • Child's Pose (60s)
     • Cat-Cow (20s, move with breath)
     • Downward Dog (60s)
     • Forward fold variations

3. Deep Stretch (20 min)
   - Hold-based poses
   - Intensity: Restorative
   - Props: Blocks, bolster
   - Poses:
     • Pigeon pose (2 min each side)
     • Supine twist (90s each side)
     • Forward fold (3 min)

4. Savasana (5 min)
   - Final relaxation
   - Body scan meditation
```

**Why Segments Work:**
- Time-based holds rather than reps
- Flow sequences with transitions
- Intensity scale (restorative to peak)
- Props tracking
- Breath awareness integration

### Use Case 3: Wrestling Practice

**Structure:** Segment-based wrestling training

**Example Day Structure:**
```
Folkstyle Wrestling: Neutral Position (90 minutes)

1. Warmup (10 min)
   - Stance and motion
   - Penetration steps
   - Sprawl drills
   
2. Technique (20 min)
   - Double leg variations
   - Head position and hand placement
   - Finishing sequences
   
3. Drill (15 min)
   - Shot + sprawl + reshot
   - Timed intervals: 1 min work / 30s rest
   - Partner rotation every 3 rounds
   
4. Positional Sparring (20 min)
   - Standing neutral only
   - Reset after takedown
   - 4 rounds × 3 min / 1 min rest
   
5. Live Wrestling (20 min)
   - Full match situation
   - 6 rounds × 2 min / 1 min rest
   - Competition intensity
   
6. Cooldown (5 min)
   - Static stretching
   - Hip and shoulder mobility
```

### Use Case 4: MMA Striking Class

**Structure:** Segment-based striking session

**Example Day Structure:**
```
Boxing Fundamentals (60 minutes)

1. Warmup (8 min)
   - Jump rope
   - Shadow boxing
   - Dynamic stretching
   
2. Technique (15 min)
   - Jab-cross-hook combinations
   - Footwork patterns
   - Head movement drills
   
3. Drill (12 min)
   - Pad work with partner
   - 2 min rounds / 30s rest
   - Focus on form and snap
   
4. Positional Sparring (15 min)
   - Jab and circle only
   - Light contact (30% power)
   - Work distance management
   
5. Conditioning (8 min)
   - Heavy bag intervals
   - 30s max output / 30s rest
   - 8 rounds total
   
6. Cooldown (2 min)
   - Light stretching
   - Breathing exercises
```

### Use Case 5: Hybrid Day (Strength + Mobility)

**Structure:** Mix exercises and segments in one day

**Example Day Structure:**
```
Lower Body Strength + Mobility (75 minutes)

EXERCISES (Traditional format):
1. Back Squat: 4 sets × 5 reps @ 225 lbs
2. Romanian Deadlift: 3 sets × 8 reps @ 185 lbs
3. Bulgarian Split Squat: 3 sets × 10 reps @ 60 lbs

SEGMENTS (Time-based format):
4. Hip Mobility (10 min)
   - 90/90 hip stretches
   - Hip flexor work
   - Adductor stretching
   
5. Yoga Flow (15 min)
   - Warrior sequences
   - Deep lunges
   - Pigeon pose variations
   
6. Breathwork (5 min)
   - Recovery breathing
   - Parasympathetic activation
```

**Benefits of Hybrid Approach:**
- Use appropriate structure for each activity type
- Track strength metrics for lifting
- Track quality and time for mobility
- Single cohesive training day

### Use Case 6: Open Mat / Free Training

**Structure:** Simple segment structure for unstructured training

**Example Day Structure:**
```
Open Mat Session (60 minutes)

1. Warmup (5 min)
   - Self-directed movement prep
   
2. Technique Review (15 min)
   - Work on personal weaknesses
   - Notes: Reviewed guard retention concepts
   
3. Positional Work (20 min)
   - Various starting positions
   - Partner: Advanced blue belt
   - Notes: Focused on maintaining frames
   
4. Live Rolling (15 min)
   - 3 rounds × 4 min
   - Mixed intensity
   - Notes: Worked on staying calm
   
5. Cooldown (5 min)
   - Stretching and reflection
```

**Flexibility:**
- Less structured than formal class
- Still captures time allocation
- Notes field for personalization
- Tracks training volume

### Use Case 7: AI/Tech Class Learning

**Structure:** Segment-based learning session for technology training

**Example Day Structure:**
```
Machine Learning Fundamentals (90 minutes)

1. Review / Lecture (15 min)
   - Review previous week's concepts
   - Introduction to neural networks
   - Key concepts: Forward propagation, backpropagation
   
2. Technique (30 min)
   - Live coding demonstration
   - Building a simple neural network in Python
   - Key details: Layer architecture, activation functions
   - Common errors: Dimension mismatches, learning rate issues
   
3. Drill (30 min)
   - Hands-on coding exercises
   - Work: Implement network layer (10 min)
   - Rest: Review solution and debug (5 min)
   - Repeat 2x with different architectures
   
4. Other - Project Work (10 min)
   - Apply concepts to personal project
   - Notes: Tested model on custom dataset
   
5. Review (5 min)
   - Key takeaways and next steps
   - Questions for further study
```

**Why Segments Work:**
- Time-based learning modules
- Lecture, demonstration, and practice phases
- Quality metrics: Concept understanding, code completion
- Notes field for capturing insights and questions

**Tracking During Session:**
- Check off completed segments
- Log understanding level or completion rate
- Note challenging concepts for review
- Record resources or documentation references

### Use Case 8: Language Learning Session

**Structure:** Segment-based language practice

**Example Day Structure:**
```
Spanish Conversation Practice (60 minutes)

1. Warmup (10 min)
   - Vocabulary flashcard review
   - Quick pronunciation drills
   - Present tense conjugation practice
   
2. Technique (15 min)
   - New grammar concept: Subjunctive mood
   - Key details: Trigger phrases, conjugation patterns
   - Common errors: Indicative vs. subjunctive confusion
   - Examples with translations
   
3. Drill (20 min)
   - Sentence construction exercises
   - Work: Create 5 sentences using subjunctive (5 min)
   - Review: Check with answer key (2 min)
   - Repeat 3x with different contexts
   
4. Positional - Conversation Practice (10 min)
   - Partner conversation or language exchange
   - Scenario: Restaurant ordering
   - Role: Customer, then switch to server
   - Intensity: Moderate (some English allowed for clarification)
   
5. Other - Listening Comprehension (3 min)
   - Podcast or video in target language
   - Notes: Understood main points, struggled with idioms
   
6. Review (2 min)
   - Reflection on progress
   - Note new vocabulary learned
```

**Benefits of Segment Structure:**
- Captures varied learning activities
- Time allocation for each skill (reading, writing, listening, speaking)
- Quality tracking: Vocabulary retained, grammar accuracy
- Notes for challenging concepts

### Use Case 9: Music Practice Session

**Structure:** Segment-based music skill development

**Example Day Structure:**
```
Guitar Practice: Blues Improvisation (75 minutes)

1. Warmup (10 min)
   - Finger exercises and scales
   - Chromatic warm-up
   - Major and minor pentatonic scales
   
2. Technique (20 min)
   - New concept: Blues turnaround phrases
   - Key details: Rhythm, bending technique, phrasing
   - Common errors: Rushing the turnaround, poor intonation
   - Video reference: Blues masters demonstration
   
3. Drill (20 min)
   - Repetitive practice of turnaround licks
   - Work: Play phrase 10x slow (5 min)
   - Work: Play phrase 10x medium tempo (5 min)
   - Work: Play phrase to backing track (5 min)
   - Rest: Listen back to recording (5 min)
   
4. Other - Improvisation (20 min)
   - Free improvisation over 12-bar blues backing track
   - Goal: Incorporate new turnaround phrases
   - Rounds: 4 rounds × 3 minutes / 2 min rest
   - Notes: Successfully used turnaround in rounds 2 and 4
   
5. Review (5 min)
   - Record best take for progress tracking
   - Note areas for improvement
   - Plan next session focus
```

**Why Segments Work Better:**
- Time-based practice modules
- Technique isolation before integration
- Quality over quantity metrics
- Recording and reflection components

### Use Case 10: Professional Skill Development

**Structure:** Segment-based professional training

**Example Day Structure:**
```
Public Speaking Workshop (120 minutes)

1. Lecture / Review (20 min)
   - Theory: Vocal variety and pacing
   - Video examples: TED Talk analysis
   - Key concepts: Pausing for emphasis, tone modulation
   
2. Warmup (10 min)
   - Vocal warm-up exercises
   - Breathing and projection drills
   - Tongue twisters for articulation
   
3. Technique (25 min)
   - Demonstration: Effective speech opening techniques
   - Key details: Hook attention, establish credibility, preview content
   - Common errors: Starting with apology, monotone delivery
   - Practice: Each participant delivers 2-minute opener
   
4. Drill (30 min)
   - Timed practice rounds with specific constraints
   - Round 1 (5 min): Focus on vocal variety only
   - Rest (2 min): Receive peer feedback
   - Round 2 (5 min): Focus on pacing and pauses
   - Rest (2 min): Receive peer feedback
   - Round 3 (5 min): Integrate all elements
   
5. Other - Full Presentation (25 min)
   - Each participant: 5-minute presentation
   - Video recorded for self-review
   - Notes: Audience questions, feedback points
   
6. Review (10 min)
   - Group discussion
   - Personal reflection on strengths and areas to improve
   - Action items for next session
```

**Tracking Options:**
- Completion of each segment
- Quality metrics: Confidence level, audience engagement
- Feedback notes from instructor or peers
- Self-assessment scores

### Use Case 11: Study/Research Session

**Structure:** Segment-based academic or research work

**Example Day Structure:**
```
Research Methods Study Block (90 minutes)

1. Lecture / Review (20 min)
   - Reading: Chapter on experimental design
   - Key concepts: Control variables, randomization, blinding
   - Notes: Definitions and examples
   
2. Technique (25 min)
   - Learn: How to identify confounding variables
   - Practice examples from textbook
   - Common errors: Missing interaction effects
   
3. Drill (20 min)
   - Problem set exercises
   - Work: Complete 5 practice problems (15 min)
   - Review: Check answers and understand mistakes (5 min)
   
4. Other - Application (20 min)
   - Apply concepts to thesis research design
   - Draft experimental protocol
   - Notes: Identified 3 potential confounds to control
   
5. Review (5 min)
   - Summarize key learnings
   - Create flashcards for important terms
   - Plan next study session topics
```

**Benefits:**
- Structured study time with clear phases
- Active learning through application
- Self-testing and review built in
- Progress tracking across study sessions

---

## Creating Segment-Based Days

Segment-based days are ideal for skill-based training like martial arts, yoga, or learning sessions. The recommended way to create them is through **AI Block Import**.

**🚀 Quick Start:** Follow [Step 2: Create Your First Block Using AI](#step-2-create-your-first-block-using-ai) for the fastest way to create segment-based blocks.

### Method 1: AI Block Generation (Recommended - Pro Feature)

The easiest and fastest way to create segment-based days:

1. From **BLOCKS** screen, tap **AI BLOCK GENERATOR**
2. In the **"Your Training Requirements"** field, describe your segment-based training
3. **Example prompts:**
   ```
   4-week BJJ training block with warmup, technique, drilling, 
   and live rolling segments. Focus on guard retention concepts.
   ```
   ```
   6-week yoga program with breathwork, flow sequences, 
   deep stretches, and savasana. Mix power and restorative sessions.
   ```
   ```
   8-week language learning plan with vocabulary warmup, 
   grammar technique sessions, conversation drills, and review.
   ```
4. Tap **COPY COMPLETE PROMPT**
5. Use ChatGPT, Claude, or another AI to generate the JSON
6. Import the JSON back into the app

The AI prompt template includes complete segment field documentation, ensuring proper structure automatically.

### Method 2: JSON Import (Manual - Pro Feature)

For more control or when working with pre-made templates:

**Basic JSON Structure:**
```json
{
  "Title": "BJJ Class Template",
  "NumberOfWeeks": 4,
  "Days": [
    {
      "name": "BJJ Fundamentals",
      "segments": [
        {
          "name": "General Warmup",
          "segmentType": "warmup",
          "domain": "grappling",
          "durationMinutes": 8,
          "objective": "Prepare body for grappling",
          "drillPlan": {
            "items": [
              {
                "name": "Stance and motion",
                "workSeconds": 60,
                "restSeconds": 15
              }
            ]
          }
        },
        {
          "name": "Technique Work",
          "segmentType": "technique",
          "domain": "grappling",
          "durationMinutes": 15,
          "objective": "Learn single leg entry",
          "techniques": [
            {
              "name": "Single leg takedown",
              "keyDetails": [
                "Level change first",
                "Head position outside"
              ],
              "commonErrors": [
                "Reaching with arms",
                "Head down"
              ]
            }
          ],
          "partnerPlan": {
            "rounds": 3,
            "roundDurationSeconds": 180,
            "restSeconds": 60,
            "resistance": 30
          }
        }
      ]
    }
  ]
}
```

**Import Options:**
- **Paste JSON:** Copy JSON and paste directly in the app
- **Import File:** Save as `.json` file and import from Files app

See [AI Block Generation](#ai-block-generation) for complete JSON format documentation.

### Method 2: Hybrid Days (Exercises + Segments)

You can combine traditional exercises with segments in the same day:

**Use Cases:**
- Strength work followed by mobility (exercises → segments)
- Wrestling technique followed by conditioning (segments → exercises)
- Lifting with yoga cooldown (exercises → segments)

**In JSON:**
```json
{
  "name": "Hybrid Day",
  "exercises": [
    {
      "name": "Back Squat",
      "sets": 4,
      "reps": 5,
      "weight": 225
    }
  ],
  "segments": [
    {
      "name": "Hip Mobility",
      "segmentType": "mobility",
      "durationMinutes": 10
    }
  ]
}
```

### Segment Field Reference

#### Essential Fields (Minimum Required)
- **name** – Segment name
- **segmentType** – Type (warmup, technique, drill, etc.)
- **durationMinutes** – Planned duration

#### Common Optional Fields

**For All Segment Types:**
- **objective** – Learning goal or purpose
- **notes** – Additional information
- **coachingCues** – Key teaching points
- **constraints** – Rules or limitations

**For Skill Work (Technique, Drill):**
- **techniques** – Array of techniques covered
  - name, keyDetails, commonErrors, counters, followUps
- **positions** – Starting positions
- **qualityTargets** – Success metrics
  - successRateTarget, cleanRepsTarget, decisionSpeedSeconds

**For Drilling:**
- **drillPlan** – Timed drill sequence
  - items array with workSeconds, restSeconds
- **partnerPlan** – Partner drilling structure
  - rounds, roundDurationSeconds, resistance
  - roles (attackerGoal, defenderGoal)

**For Live Training (Sparring, Rolling):**
- **roundPlan** – Round structure
  - rounds, roundDurationSeconds, restSeconds
  - winConditions, resetRule, intensityCue
- **startPosition** – Where to begin
- **scoring** – Win conditions for attacker/defender

**For Yoga/Mobility:**
- **flowSequence** – Array of poses with hold times
- **holdSeconds** – Static hold duration
- **breathCount** – Number of breaths
- **intensityScale** – restorative, easy, moderate, strong, peak
- **props** – Equipment needed

**For Breathwork:**
- **breathwork** – Breathing pattern
  - style, pattern, durationSeconds

**For Safety:**
- **safety** – Safety information
  - contraindications, stopIf, intensityCeiling

**For Media/Reference:**
- **media** – Instructional content
  - videoUrl, imageUrl, diagramAssetId

### Complete Example: BJJ Class JSON

See the file `Tests/bjj_class_segments_example.json` in the repository for a fully-detailed example with all segment types and fields demonstrated.

### Tips for Creating Segment-Based Blocks

1. **Start Simple**
   - Begin with basic segments (warmup, technique, cooldown)
   - Add complexity as needed
   - Not every field needs to be populated

2. **Be Clear with Objectives**
   - Each segment should have a clear learning goal
   - Help athletes understand the "why"

3. **Use Appropriate Segment Types**
   - Match segment type to the activity
   - Use "other" for anything that doesn't fit

4. **Plan Realistic Durations**
   - Account for transitions between segments
   - Leave buffer time for instruction

5. **Include Safety Notes**
   - Especially important for high-intensity or contact segments
   - Document contraindications and stop conditions

6. **Track What Matters**
   - Use quality targets for skill-based work
   - Don't worry about tracking every metric
   - Focus on meaningful progression

7. **Consider Hybrid Approaches**
   - Mix exercises and segments when appropriate
   - Use the right tool for each activity

---

## Running Workout Sessions

### Starting a Workout

1. Go to **BLOCKS** from the Home Screen
2. Find the block you want to run
3. Tap the **RUN** button
4. The app creates sessions for all weeks based on your templates

### During Your Workout

**Week & Day Navigation:**
- **Swipe left/right** to change weeks
- **Tap day tabs** at the top to switch between workout days
- The current week is highlighted at the top

**Logging Sets (Exercise-Based Days):**
- Each exercise shows **expected values** from your template
- Tap a set to expand and log your actual performance
- Use **+ / -** buttons to adjust weight, reps, time, distance, etc.
- Check the **✓** box when you complete the set
- The set turns green when marked complete

**Logging Segments (Segment-Based Days):**
- Each segment shows its type, duration, and objective
- Tap the segment card to expand and view details
- Check the **✓** box when you complete the segment
- For segments with rounds (sparring, drilling):
  - Use **+ / -** buttons to log rounds completed
  - Track quality metrics if specified (success rate, clean reps)
- Add notes about technique, partner feedback, or observations

**Status Indicators:**
- **Gray** – Not started
- **Green with checkmark** – Completed
- **Progress bar** – Shows completion percentage

**Auto-Save:**
- The app automatically saves your progress as you go
- You never lose data, even if you close the app mid-workout

### Viewing the Workout Plan

**Whiteboard Mode (Pro Feature):**
- Tap **Whiteboard** in the top-right during a workout
- See a clean, printable view of your entire week
- Great for referencing between sets or for coaches
- Shows all exercises, sets, reps, and weights in an easy-to-read format

### Finishing a Workout

1. Complete all the sets you plan to do
2. Tap **Close Session** in the top-left
3. The app saves all your logged data
4. Progress is recorded in your block history

**Week Completion:**
- When you finish all days in a week, you'll see a completion modal
- Review your stats: sets completed, exercises done
- Tap **Continue to Next Week** or **Review Week**

**Block Completion:**
- When you finish the final week, you'll see a block completion celebration
- The block is automatically archived to Block History
- You can review it anytime from the History screen

---

## Using the Whiteboard

### What is the Whiteboard?

The **Whiteboard** is a clean, minimal view of your training block that shows:
- All exercises for each day (for exercise-based days)
- All segments for each day (for segment-based days)
- Sets, reps, and weights (exercises)
- Objectives, techniques, and round plans (segments)
- Week-by-week progression
- A format similar to what you'd see on a gym whiteboard

### Accessing the Whiteboard (Pro Feature)

**During a Workout:**
1. Tap **Whiteboard** in the top-right corner while running a block
2. Select the week you want to view
3. Scroll through all your days

**From Block History:**
1. Go to **BLOCK HISTORY**
2. Tap **REVIEW** on any archived block
3. The whiteboard view opens automatically

### Whiteboard Features

- **Week Selector** – Switch between weeks if your block has multiple weeks
- **Day Cards** – Each day shows as a card with all exercises
- **Full-Screen View** – Tap a day card to see it in full-screen
- **No Distractions** – Clean, focused layout perfect for gyms

**Use Cases:**
- Screenshot your week and send it to your coach
- Print it out and bring it to the gym
- Share programs with training partners
- Review past blocks to plan future training
- View segment-based training plans (BJJ classes, yoga sessions)
- See technique progressions and drilling structures at a glance

---

## Tracking Your Progress

### Block History

**Accessing History:**
1. From Home Screen, tap **BLOCK HISTORY**
2. See all your archived blocks
3. Tap **REVIEW** to see any block's details

**What's Stored:**
- Every set you logged (weight, reps, time, distance)
- Completion dates
- Notes you added during workouts
- Full progression across all weeks

### Session Data

Each workout session records:
- **Expected vs. Actual** – What you planned vs. what you did
- **Completion Status** – Which sets you finished
- **Timestamps** – When sets were completed
- **RPE/RIR** – Intensity metrics (if you track them)
- **Notes** – Any comments you added

### Analyzing Your Training

**Use Block History to:**
- See how you progressed over a training cycle
- Identify exercises where you improved most
- Notice patterns (missed workouts, struggled weeks)
- Plan your next block based on past performance
- Compare different training approaches

**Pro Tip:** Take progress photos and body measurements outside the app, then reference specific weeks from Block History to correlate with training.

---

## AI Block Generation

### What is AI Block Generation? (Pro Feature)

**AI Block Generation** allows you to create sophisticated training blocks by using AI assistants like ChatGPT or Claude. The app provides a comprehensive **AI Prompt Template** that guides AI assistants to generate properly formatted training programs in JSON format, which you can then import directly into the app.

**🚀 Quick Start:** Already covered in the [Quick Start Guide](#step-2-create-your-first-block-using-ai) – jump there for step-by-step instructions!

### The AI Prompt Template

The app includes a built-in prompt template that ensures AI assistants generate training blocks with:
- **Coach-grade structure** – Entropy classification and goal stimulus analysis
- **Proper JSON format** – All required fields and valid data types
- **Smart defaults** – Sensible progression, rest periods, and intensity
- **Comprehensive options** – Support for exercises, segments, and hybrid days

**How the Prompt Works:**
1. You describe your training requirements in natural language
2. The app combines your requirements with its technical prompt template
3. You copy the complete prompt and send it to an AI assistant
4. The AI analyzes your needs and generates valid JSON
5. You import the JSON back into the app

### Using AI Block Generator - Detailed Steps

#### Step 1: Access the Generator

1. From **BLOCKS** screen, tap **AI BLOCK GENERATOR**
2. You'll see two main sections:
   - **AI Prompt Template** (top) – Generate JSON with AI
   - **Import JSON** (bottom) – Import generated blocks

#### Step 2: Describe Your Training Needs

In the **"Your Training Requirements"** text field, describe what you want. Be specific!

**Good Examples:**
```
8-week powerlifting peaking program
4 days per week focusing on squat, bench, deadlift
Include accessory work and a deload on week 7
```

```
4-week BJJ training block
3 classes per week focusing on guard retention
Include warmup, technique, drilling, and live rolling segments
```

```
6-week conditioning program
Mix of running, rowing, and bodyweight circuits
Progressive volume increase with HIIT and steady-state work
```

**What to Include:**
- Duration (number of weeks)
- Frequency (days per week)
- Training goals (strength, hypertrophy, conditioning, skills)
- Specific exercises or movements
- Any constraints (equipment, time, injuries)

#### Step 3: Copy the Complete Prompt

1. Review your requirements
2. Tap **COPY COMPLETE PROMPT**
3. The app generates a full prompt combining:
   - Your specific requirements
   - Complete JSON schema documentation
   - AI coaching instructions for proper program design
   - Examples and formatting rules

#### Step 4: Generate JSON with AI

1. Open **ChatGPT**, **Claude**, or another AI assistant
2. Paste the copied prompt
3. Send the message
4. The AI will:
   - Analyze your training requirements
   - Apply exercise science principles
   - Generate a complete JSON block
   - Include progression, exercises/segments, and scheduling
5. **Copy the JSON response** (just the JSON code, not explanatory text)

**Pro Tip:** The AI will often explain its reasoning before providing JSON. Look for the code block and copy only that part.

#### Step 5: Import the JSON

Back in the **AI Block Generator** screen:

**Option A: Paste JSON Directly**
1. Scroll to **"Import JSON"** section
2. Tap in the large text input area
3. Paste your JSON
4. Tap **IMPORT FROM TEXT**
5. If valid, you'll see a block preview
6. Review the block details
7. The block is automatically saved to your blocks list

**Option B: Import from File**
1. Save your JSON as a `.json` file (e.g., from email or cloud storage)
2. Tap **IMPORT FROM FILE**
3. Select your JSON file from Files app
4. The block is parsed and imported

### What the AI Generates

The AI assistant creates a complete training block with:

**For Exercise-Based Training:**
- Exercise names, types, and categories
- Sets, reps, and starting weights
- Progression rules (Delta Weight, Delta Sets)
- RPE/RIR targets
- Rest periods
- Tempo specifications
- Notes and coaching cues

**For Segment-Based Training:**
- Segment types (warmup, technique, drill, sparring, etc.)
- Duration and objectives
- Round plans with work/rest intervals
- Technique details and key coaching points
- Partner plans and resistance levels
- Quality targets (success rate, clean reps)
- Safety notes and contraindications

**For Hybrid Days:**
- Mix of traditional exercises and segment modules
- Proper sequencing (e.g., strength work before skill work)
- Appropriate rest and recovery

### JSON Format Requirements

The JSON must follow the Block structure specified in the prompt template:
- **Block metadata:** Name, description, number of weeks, goals
- **Day templates:** Individual workout days with exercises and/or segments
- **Exercise details:** Sets, reps, weight, progression for strength/conditioning
- **Segment details:** Type, duration, techniques, round plans for skill-based training
- **Progression settings:** How exercises advance week-over-week

**The prompt template includes complete schema documentation**, so AI assistants generate valid JSON automatically.

### Advanced Use Cases

**Beyond AI Generation:**
- **Coach-Created Programs:** Coaches can write JSON manually and share with athletes
- **Team Sharing:** Share blocks between training partners via JSON files
- **Program Libraries:** Build a collection of proven training blocks
- **Backup/Restore:** Export individual blocks for safekeeping
- **Cross-Platform:** Generate blocks on desktop, import on mobile
- **Custom Templates:** Create your own JSON templates for recurring programs

**Content Types:**
- Traditional strength training programs
- Conditioning and cardio blocks
- Sport-specific training (BJJ, wrestling, martial arts)
- Yoga and mobility programs
- Hybrid athlete training (strength + skills)
- Learning and skill development (coding, language, music)
- Professional development sessions

### Error Handling

If import fails, check:
- ✅ JSON syntax is valid (no missing braces, commas, quotes)
- ✅ All required fields are present (name, weeks, days)
- ✅ Data types match (numbers for sets/reps, strings for names)
- ✅ Exercise types are "strength" or "conditioning"
- ✅ Segment types are valid (warmup, technique, drill, etc.)

**Pro Tip:** The AI prompt template is designed to minimize errors. If you get an error, try regenerating with the AI or ask it to validate the JSON.

### Why Use AI Generation?

**Benefits:**
- ⚡ **Fast:** Generate a complete 12-week program in seconds
- 🧠 **Smart:** AI applies periodization and exercise science principles
- 🎯 **Customized:** Tailored to your exact requirements
- 📚 **Educational:** See how programs are structured
- 🔄 **Iterative:** Easily regenerate and refine

**Note:** This feature is for **importing** blocks. The app doesn't connect to AI services directly—you use external AI assistants and import their output.

---

## Pro Features

### Subscription Benefits

**Go Pro** unlocks premium features that enhance your training experience:

- ✅ **AI Block Import** – Use ChatGPT, Claude, or other AI assistants to generate complete training programs in JSON format, then import them instantly
- ✅ **AI Prompt Template** – Built-in comprehensive prompt that guides AI to create coach-grade programs
- ✅ **Whiteboard View** – Clean, printable workout display perfect for gyms, coaches, and athletes
- ✅ **Unlimited Blocks** – Create as many training programs as you need
- ✅ **Priority Support** – Get help faster when you need it
- ✅ **Future Features** – Early access to new capabilities as they're released

### Free Version Includes

You can do a lot without Pro! The free version includes:

- ✅ Create and run training blocks
- ✅ Track all workouts with full logging (exercises and segments)
- ✅ Block history and progress tracking
- ✅ Exercise library management
- ✅ Data backup and restore
- ✅ All core workout tracking features
- ✅ Manual block building with full customization

### Getting Pro Access

**🚀 Quick Start:** See [Step 1: Unlock Pro Features](#step-1-unlock-pro-features-optional-but-recommended) for detailed instructions.

#### Option 1: Development Unlock (Testing)

For development, testing, or evaluation:

1. From Home Screen, tap **GO PRO**
2. Tap **"Enter Code"** button
3. Type: **dev** (case-insensitive)
4. Tap **"Unlock"**
5. ✅ Full Pro access activated!

**Development Unlock Details:**
- Code: **dev** (works with Dev, DEV, dev)
- Persists across app restarts
- No expiration
- Does not interfere with StoreKit or real subscriptions
- Perfect for testing Pro features
- Can be removed anytime for testing subscription flows

#### Option 2: Subscribe via App Store

For production use:

1. From Home Screen, tap **GO PRO**
2. View your current subscription status
3. **If not subscribed:**
   - View available plans (Monthly or Annual)
   - Check for free trial eligibility
   - Select your preferred plan
   - Complete purchase through Apple App Store
4. **If subscribed:**
   - See renewal date and plan details
   - Manage subscription via Apple settings
   - Cancel anytime (access continues until period ends)

**Subscription Details:**
- Billed through Apple App Store
- Supports Family Sharing (where applicable)
- Cancel anytime with no fees or penalties
- Free trial available (check current offer)
- Auto-renews unless cancelled before period ends
- Manage via Apple ID Settings > Subscriptions

### Managing Your Subscription

**View Subscription Status:**
- Tap **GO PRO** from Home Screen
- See active status, renewal date, and plan type
- Check trial eligibility

**Change or Cancel:**
1. Open iOS **Settings** app
2. Tap your **Apple ID** at the top
3. Select **Subscriptions**
4. Find **Savage By Design**
5. Modify or cancel as needed

**Access After Cancellation:**
- Pro features remain active until the end of your paid period
- Block history and data are preserved
- You can resubscribe anytime to restore Pro access

### Pro Feature Details

#### AI Block Import

- Generate training programs using AI assistants (ChatGPT, Claude, etc.)
- Built-in prompt template ensures proper JSON format
- Supports exercises, segments, and hybrid days
- Import from text or file
- See [AI Block Generation](#ai-block-generation) for full details
- Quick reference: [Quick Start Step 2](#step-2-create-your-first-block-using-ai)

#### Whiteboard View

- Clean, gym-friendly display of workout plans
- View any week from current or archived blocks
- Full-screen mode for individual days
- Perfect for screenshots, printing, or sharing with coaches
- No clutter, just your workout data
- See [Using the Whiteboard](#using-the-whiteboard) for details

#### Unlimited Blocks

- Create as many training programs as needed
- No artificial limits on block creation
- Archive completed blocks without counting against limit
- Build libraries of specialized programs (strength, conditioning, skills)

### Why Upgrade to Pro?

**Perfect if you:**
- Want the fastest way to create training programs (AI generation)
- Work with a coach who shares JSON programs
- Need clean workout displays for gym reference
- Plan multiple training cycles in advance
- Value time saved in program creation
- Want to experiment with different training approaches

**Consider staying free if:**
- You prefer manually building every block
- You only train one program at a time
- You don't need printable workout views
- You're comfortable with the free tier features

---

## Data Management

### Backing Up Your Data

**Why Backup?**
Your workout data is stored locally on your device. Back it up to:
- Protect against data loss
- Transfer to a new device
- Keep an external copy for safety

**How to Backup:**
1. Go to **DATA MANAGEMENT** from Home Screen
2. Tap **EXPORT ALL DATA**
3. Choose where to save the file (iCloud, Files app, etc.)
4. A JSON file is created with all your blocks and sessions

**Backup Contents:**
- All training blocks (active and archived)
- All workout sessions and logged sets
- Exercise library
- Settings and preferences

### Restoring Data

**How to Restore:**
1. Go to **DATA MANAGEMENT**
2. Tap **IMPORT DATA**
3. Select your backup JSON file
4. Confirm the import
5. All data is restored

**Important Notes:**
- Importing **replaces** existing data
- Always export current data before importing
- Restore files must be valid JSON in the correct format

### Starting Fresh

**Clear All Data:**
1. Go to **DATA MANAGEMENT**
2. Tap **CLEAR ALL DATA**
3. Confirm the action (THIS CANNOT BE UNDONE)
4. Recommended: Export backup first

**When to Clear Data:**
- Starting a new training phase completely fresh
- Troubleshooting issues
- Handing device to someone else

---

## Tips & Best Practices

### For Beginners

1. **Start Simple**
   - Create a 4-week block with 3 days per week
   - Focus on basic compound exercises
   - Use 3-4 sets of 5-8 reps for strength

2. **Learn the Interface**
   - Run through a test workout to understand logging
   - Explore the Whiteboard view
   - Practice saving and editing blocks

3. **Be Consistent**
   - Stick to your schedule
   - Log every set, even if you don't hit targets
   - Review your history weekly

### For Advanced Users

1. **Progressive Overload**
   - Use the Delta Weight/Sets features
   - Plan deload weeks (week 4, 8, 12)
   - Track RPE/RIR for intensity management

2. **Block Programming**
   - Create specialized blocks (strength, hypertrophy, peaking)
   - Use week templates for varied programming
   - Clone successful blocks and adjust for next cycle

3. **Superset & Circuits**
   - Group exercises by assigning Set Group IDs (in advanced mode)
   - Plan rest periods strategically
   - Use conditioning blocks for metabolic work

### General Tips

✅ **DO:**
- Log every workout, even if incomplete
- Review previous weeks before planning the next block
- Use notes fields for coaching cues
- Export data backups monthly
- Screenshot your whiteboard for quick reference
- Use segments for skill-based training (BJJ, yoga, martial arts)
- **Use segments for learning activities** (AI/tech classes, language learning, music practice)
- **Use segments for professional development** (public speaking, skill workshops)
- **Use segments for study sessions** (structured academic work, research time)
- Mix exercises and segments when appropriate (hybrid days)
- Track quality over quantity for segment-based work
- Adapt segment types creatively (e.g., "Drill" for coding exercises, "Technique" for learning concepts)

❌ **DON'T:**
- Skip logging—you lose valuable data
- Delete blocks immediately after completion (archive first)
- Forget to progress weight/volume across weeks
- Ignore deload weeks—recovery is training
- Use exercises for activities better suited to segments (e.g., yoga, BJJ classes, learning sessions)
- Force non-quantifiable activities into sets/reps/weight structure

### Sample Programs to Try

**Beginner Strength (4 weeks, 3 days/week):**
- Day 1: Squat, Bench, Rows
- Day 2: Deadlift, Overhead Press, Pull-ups
- Day 3: Conditioning + Accessories

**Intermediate Hypertrophy (6 weeks, 4 days/week):**
- Day 1: Upper Push (8-12 reps)
- Day 2: Lower (8-12 reps)
- Day 3: Upper Pull (8-12 reps)
- Day 4: Full Body or Conditioning

**Advanced Strength (12 weeks, 5 days/week):**
- Linear periodization from 5x5 to 3x3 to 1x1
- Deloads on weeks 4, 8, 12
- Accessory work at 3x10-15

**BJJ Training Block (4 weeks, 3 days/week) - Segments:**
- Day 1: Guard Retention Fundamentals
  - Warmup → Technique → Drilling → Positional Sparring → Cooldown
- Day 2: Passing Concepts
  - Warmup → Technique → Drilling → Live Rolling → Cooldown
- Day 3: Takedowns and Top Control
  - Warmup → Technique → Situational Sparring → Integration → Cooldown

**Yoga & Mobility Program (4 weeks, 4 days/week) - Segments:**
- Day 1: Power Vinyasa (45 min)
- Day 2: Restorative & Yin (60 min)
- Day 3: Core & Balance Focus (30 min)
- Day 4: Breathwork & Meditation (20 min)

**Hybrid Athlete Program (6 weeks, 5 days/week) - Mixed:**
- Day 1: Lower Body Strength (exercises) + Hip Mobility (segments)
- Day 2: BJJ Class (segments)
- Day 3: Upper Body Strength (exercises) + Shoulder Mobility (segments)
- Day 4: Wrestling Conditioning (segments)
- Day 5: Full Body Lift (exercises) + Yoga Flow (segments)

**Machine Learning Bootcamp (8 weeks, 3 days/week) - Segments:**
- Day 1: Theory & Coding Practice
  - Review/Lecture → Technique (live coding) → Drill (exercises) → Project Work
- Day 2: Advanced Concepts
  - Review → Technique → Drill → Application → Review
- Day 3: Project Development
  - Planning → Coding Session → Testing & Debugging → Documentation

**Language Learning Program (12 weeks, 4 days/week) - Segments:**
- Day 1: Grammar & Structure (Lecture → Technique → Drill → Review)
- Day 2: Conversation Practice (Warmup → Drill → Positional/Role-play → Review)
- Day 3: Listening & Reading (Warmup → Technique → Other/Comprehension → Review)
- Day 4: Writing & Composition (Review → Technique → Drill → Other/Free writing)

**Professional Development (4 weeks, 2 days/week) - Segments:**
- Day 1: Public Speaking Skills
  - Warmup → Lecture → Technique → Drill → Full Presentation → Review
- Day 2: Leadership & Communication
  - Review → Technique → Role-play scenarios → Group discussion → Action planning

---

## Troubleshooting

### Common Issues

**Q: My workout isn't saving**
- Check that you tapped the checkmark to complete sets
- Ensure you have storage space on your device
- Try closing and reopening the session
- The app auto-saves—your data should be there

**Q: I can't see my completed block**
- Check **BLOCK HISTORY** (not BLOCKS)
- Archived blocks move automatically after completion
- Use the search function if you have many blocks

**Q: Progression isn't working**
- Verify Delta Weight/Sets in block settings
- Check that progression type is set correctly
- Some exercises may need manual adjustment

**Q: I lost my data**
- Data is stored locally—if you deleted the app, it's gone
- Restore from a backup if you exported data
- In the future, export backups regularly

**Q: Whiteboard/AI Generator says "Pro Only"**
- These are subscription features
- Tap **GO PRO** to unlock
- Free trial may be available

**Q: Exercise won't save**
- Make sure name field isn't empty
- Check that sets/reps have valid numbers
- Type must be either Strength or Conditioning

### Getting Help

**Contact & Support:**
- Email: savagesbydesignhq@gmail.com
- Website: savagesbydesign.com
- Tap **GO PRO** → **Contact Support** (Pro users)

**Community & Development:**
- GitHub Issues for bugs: [github.com/kje7713-dev/WorkoutTrackerApp/issues](https://github.com/kje7713-dev/WorkoutTrackerApp/issues)
- GitHub Discussions: [github.com/kje7713-dev/WorkoutTrackerApp/discussions](https://github.com/kje7713-dev/WorkoutTrackerApp/discussions)
- Share your programs and get feedback

---

## Glossary

**Block** – A complete training program spanning multiple weeks

**Day Template** – A workout day design that repeats each week

**Session** – A single workout instance with logged data

**Exercise** – A traditional strength or conditioning movement with sets, reps, and weight

**Segment** – A time-based training module for skill work, technique, or non-traditional activities

**Set** – One round of an exercise (e.g., 5 reps at 185 lbs)

**Progressive Overload** – Gradually increasing training stress (weight, volume, intensity)

**Deload** – Reduced training volume for recovery

**RPE (Rating of Perceived Exertion)** – Scale of 1-10, how hard the set felt

**RIR (Reps in Reserve)** – How many more reps you could have done

**Tempo** – Movement speed (eccentric-pause-concentric-pause in seconds)

**Superset** – Two exercises performed back-to-back with no rest

**Circuit** – Multiple exercises performed sequentially

**AMRAP** – As Many Reps/Rounds As Possible

**EMOM** – Every Minute On the Minute

**Periodization** – Systematic planning of training variables over time

**Segment Types:**

- **Warmup Segment** – Preparation phase with movement and mobility
- **Technique Segment** – Skill instruction and practice with coaching cues
- **Drill Segment** – Repetitive practice with timed work/rest intervals
- **Positional Sparring** – Live practice from specific positions with constraints
- **Rolling/Live Training** – Free sparring or competition simulation
- **Cooldown Segment** – Recovery and transition out of training
- **Breathwork Segment** – Respiratory training and nervous system work
- **Mobility Segment** – Flexibility and range of motion work

**Quality Targets** – Skill-based metrics (success rate, clean reps, decision speed) for segment tracking

**Resistance Level** – Intensity of opposition in partner drills (0-100%), where 0% is no resistance and 100% is full competition intensity

**Round Plan** – Structure for timed rounds in sparring or drilling (rounds, duration, rest)

**Partner Plan** – Framework for partner drilling with role definitions and resistance levels

**Hybrid Day** – Training day combining both exercises and segments

---

## Final Thoughts

**Savage By Design** is built to help you structure your training, track your progress, and achieve your goals. Whether you're working with a coach, following an online program, or designing your own training, this app gives you the tools to be consistent and deliberate.

> "Excellence is not an act, but a habit."

**Your success comes from showing up, logging the work, and progressing systematically.**

💪 Now get out there and train!

---

### Quick Start Checklist

**Essential (Follow the Quick Start Guide):**
- [ ] Unlock Pro features (dev code or subscription) – [Step 1](#step-1-unlock-pro-features-optional-but-recommended)
- [ ] Generate your first block with AI – [Step 2](#step-2-create-your-first-block-using-ai)
- [ ] Import the JSON block into the app
- [ ] Run your block and log your first workout – [Step 3](#step-3-run-your-block)
- [ ] Explore the Whiteboard view

**Recommended Next Steps:**
- [ ] Review your session in Block History
- [ ] Export a data backup (DATA MANAGEMENT → EXPORT ALL DATA)
- [ ] Try creating a manual block to understand the builder interface
- [ ] Experiment with segment-based days (BJJ, yoga, learning)
- [ ] Set up recurring backups to iCloud or Files app

**Advanced:**
- [ ] Create a hybrid day (exercises + segments)
- [ ] Import a segment-based block for skill training
- [ ] Build a multi-phase periodized program (12+ weeks)
- [ ] Share a block with training partners via JSON export

---

**Need more help?** 

- 📧 Email: savagesbydesignhq@gmail.com
- 🌐 Website: savagesbydesign.com
- 📖 Full Guide: You're reading it! Use the [Table of Contents](#table-of-contents)
- 💻 Technical Info: Check the [Technical README](README.md) for developers
- 🐛 Report Issues: [GitHub Issues](https://github.com/kje7713-dev/WorkoutTrackerApp/issues)
- 💬 Community: [GitHub Discussions](https://github.com/kje7713-dev/WorkoutTrackerApp/discussions)
