# Visual Guide: Segment UI in BlockRunMode

## Overview
This guide shows how segments are displayed in the BlockRunMode UI.

## SegmentRunCard Components

### 1. Header Section
```
┌─────────────────────────────────────────────────┐
│ General Warm-up + Grappling Movement         ◯ │
│ [WARMUP] 8 min                                  │
└─────────────────────────────────────────────────┘
```
- **Segment Name**: Bold headline
- **Type Badge**: Color-coded, uppercase (WARMUP, TECHNIQUE, DRILL, etc.)
- **Duration**: Minutes display if present
- **Completion Checkbox**: Circle (empty) or ◉ (filled green when complete)

**Color Coding:**
- 🟠 WARMUP/MOBILITY - Orange
- 🔵 TECHNIQUE - Blue
- 🟣 DRILL - Purple
- 🔴 POSITIONAL SPAR/ROLLING - Red
- 🟢 COOLDOWN/BREATHWORK - Green
- ⚫ LECTURE - Gray
- ⚪ OTHER - Secondary

### 2. Objective Section
```
┌─────────────────────────────────────────────────┐
│ Objective: Build a clean single-leg entry off  │
│ inside tie with correct head/hand position.    │
└─────────────────────────────────────────────────┘
```
- Displays the learning objective or goal
- Secondary text color
- Only shown if objective is present

### 3. Round Tracking Section
```
┌─────────────────────────────────────────────────┐
│ Rounds: 3 / 6                                   │
│ Round Duration: 2:00                            │
│                                                 │
│   ⊖   ⊕                                        │
└─────────────────────────────────────────────────┘
```
- **Current/Total Rounds**: Bold display
- **Round Duration**: Formatted time (MM:SS)
- **Controls**: Minus and plus buttons to track completed rounds
- Gray background box
- Minus button disabled when at 0
- Plus button disabled when at max rounds

### 4. Quality Tracking Section
```
┌─────────────────────────────────────────────────┐
│ Quality Tracking                                │
│                                                 │
│ Clean Reps          Total Attempts             │
│ ⊖  8  ⊕             ⊖  10  ⊕                  │
│                                                 │
│ Success Rate: 80%                              │
└─────────────────────────────────────────────────┘
```
- **Clean Reps**: Successful repetitions
- **Total Attempts**: All attempts made
- **Controls**: +/- buttons for both metrics
- **Success Rate**: Auto-calculated percentage
- Green text when ≥70%, secondary otherwise
- Gray background box

### 5. Drill Items Section
```
┌─────────────────────────────────────────────────┐
│ Drills                                          │
│                                                 │
│ ◉ Stance-in-motion                             │
│ ◉ Sprawl to hip-heist                          │
│ ◯ Penetration step (no partner)               │
│ ◯ Pummeling to inside tie                     │
└─────────────────────────────────────────────────┘
```
- **List of Drills**: Each drill as a separate line
- **Completion Icons**: 
  - ◉ (filled green) = completed
  - ◯ (empty gray) = not completed
- **Tap to Toggle**: Tap any drill to mark/unmark
- Gray background box

### 6. Notes Section
```
┌─────────────────────────────────────────────────┐
│ Class plan using segments. Ties → entry →      │
│ finish → situational rounds → integration.      │
└─────────────────────────────────────────────────┘
```
- Additional notes or instructions
- Caption size, secondary color
- Only shown if notes are present

## Complete Segment Example

```
┌─────────────────────────────────────────────────┐
│ Technique Progression 1                      ◉ │
│ [TECHNIQUE] 12 min                              │
├─────────────────────────────────────────────────┤
│ Objective: Build a clean single-leg entry off  │
│ inside tie with correct head/hand position.    │
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────┐ │
│ │ Rounds: 3 / 3                               │ │
│ │ Round Duration: 3:00                        │ │
│ │                                             │ │
│ │   ⊖   ⊕                                    │ │
│ └─────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────┐ │
│ │ Quality Tracking                            │ │
│ │                                             │ │
│ │ Clean Reps          Total Attempts         │ │
│ │ ⊖  10  ⊕            ⊖  12  ⊕              │ │
│ │                                             │ │
│ │ Success Rate: 83%                          │ │
│ └─────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────┤
│ Partner drill with light resistance. Defender  │
│ gives realistic frames.                         │
└─────────────────────────────────────────────────┘
```

## Day View with Segments

```
┌─────────────────────────────────────────────────┐
│ BJJ CLASS DAY                                   │
│ Week 1 • BJJ1                                   │
├─────────────────────────────────────────────────┤
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ General Warm-up                          ◉ │ │
│ │ [WARMUP] 8 min                              │ │
│ │ ... (drill items, etc.)                     │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ Technique Progression 1                  ◉ │ │
│ │ [TECHNIQUE] 12 min                          │ │
│ │ ... (rounds, quality tracking)              │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ Constraint Drilling                      ◯ │ │
│ │ [DRILL] 10 min                              │ │
│ │ ... (constraints, rounds)                   │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ Situational Sparring                     ◯ │ │
│ │ [POSITIONAL SPAR] 12 min                   │ │
│ │ ... (scoring, constraints)                  │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ Cooldown + Breath                        ◯ │ │
│ │ [COOLDOWN] 2 min                           │ │
│ │ ... (breathwork pattern)                    │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ ➕ Add Exercise                             │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
└─────────────────────────────────────────────────┘
```

## Whiteboard View with Segments

```
┌─────────────────────────────────────────────────┐
│ BJJ CLASS SEGMENTS EXAMPLE                      │
│                                                 │
│ ┌─ Week 1 ─┐                                   │
│                                                 │
│ ━━━ Day 1: Inside Tie → Single (BJJ Class) ━━━ │
│ Goal: mixed                                     │
│                                                 │
│ ▓▓ WARM-UP / MOBILITY ▓▓                       │
│                                                 │
│ General Warm-up + Grappling Movement            │
│ 8 min                                           │
│                                                 │
│ Objective: Raise temp, prep hips/shoulders     │
│ • Stance-in-motion: 1:00 / 0:15 rest          │
│ • Sprawl to hip-heist: 1:00 / 0:15 rest       │
│ • Penetration step: 1:00 / 0:15 rest          │
│ • Pummeling to inside tie: 2:00                │
│ Cues:                                           │
│   - Stance: hips under you, eyes up            │
│   - Hands active, elbows in                    │
│   - Move your feet before you reach            │
│ ⚠️ Safety:                                      │
│   - No slamming                                 │
│   - No neck cranks during warm-up              │
│                                                 │
│ ▓▓ TECHNIQUE DEVELOPMENT ▓▓                    │
│                                                 │
│ Technique Progression 1                         │
│ 12 min • 3 rounds × 3:00                       │
│ Rest: 1:00                                      │
│                                                 │
│ Objective: Build clean single entry            │
│ Positions: standing, inside_tie                 │
│ • Inside tie to single entry (inside tie...)   │
│   - Head to outside with strong posture        │
│   - Inside hand controls elbow/bicep           │
│   - Level change from hips, not waist          │
│ Attacker: Hit clean entry without finishing    │
│ Defender: Give realistic frames, no resistance │
│ Resistance: 25%                                 │
│ Target success rate: 80%                        │
│                                                 │
│ ▓▓ LIVE TRAINING ▓▓                            │
│                                                 │
│ Situational Sparring: Tie-up to Score          │
│ 12 min • 6 rounds × 2:00                       │
│ Rest: 0:30                                      │
│                                                 │
│ Objective: Live application of inside tie      │
│ Constraints:                                    │
│   - Must start from inside tie                 │
│   - Attacker must attempt single in 15s        │
│   - No guard pulling for attacker              │
│ Scoring:                                        │
│   - Attacker: Clean single + 3s top control    │
│   - Defender: Stuff + front headlock 3s        │
│ Target success rate: 50%                        │
│                                                 │
│ ▓▓ COOL DOWN ▓▓                                │
│                                                 │
│ Cooldown + Breath                               │
│ 2 min                                           │
│                                                 │
│ Objective: Downshift and recover               │
│ Notes: nasal breathing, 4s inhale / 6s exhale  │
│                                                 │
└─────────────────────────────────────────────────┘
```

## Interaction Flow

### Starting a Segment Session
1. User opens block in BlockRunMode
2. Navigates to segment-based day using day tabs
3. Sees list of segments ordered by sequence
4. Each segment shows in its own card with appropriate controls

### Completing a Drill Segment
1. Tap first drill item → checkmark appears
2. Tap second drill item → checkmark appears
3. Continue through all drill items
4. Tap completion checkbox when done
5. Auto-saves progress

### Tracking Rounds
1. View segment card shows "Rounds: 0 / 6"
2. Complete first round → tap ⊕
3. Display updates to "Rounds: 1 / 6"
4. Continue tapping ⊕ after each round
5. When 6/6, ⊕ button disables
6. Can tap ⊖ to decrement if needed

### Tracking Quality
1. Attempt a technique → increment Total Attempts
2. If successful → increment Clean Reps
3. Success rate auto-calculates and displays
4. Green text when ≥70%

### Completing the Session
1. Mark all segments complete with checkbox
2. System saves automatically
3. Week completion modal may appear if all week done

## Design Principles

1. **Minimalist**: Only show controls relevant to segment type
2. **Clear Hierarchy**: Name → Type → Details → Controls
3. **Color Coding**: Instant visual recognition of segment type
4. **Progressive Disclosure**: Optional elements only show when present
5. **Touch-Friendly**: Large tap targets for controls
6. **Auto-Save**: Save on every interaction
7. **Non-Destructive**: Easy to correct mistakes (⊖ buttons)

## Accessibility

- All interactive elements are tappable
- Clear visual feedback for completed items (green checkmarks)
- Disabled states clearly indicated (grayed out)
- Text labels for all controls
- Sufficient contrast ratios

## Future Enhancements

- Live countdown timers for rounds
- Sound/vibration alerts for round transitions
- Video player integration for technique reference
- Voice commands for hands-free tracking
- Partner assignment and rotation
- Session analytics and progress charts
