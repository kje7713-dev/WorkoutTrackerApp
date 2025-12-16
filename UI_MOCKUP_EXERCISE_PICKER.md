# Exercise Picker UI Mockup

## Visual Flow of the Exercise Picker Feature

### Screen 1: Dropdown Mode (Default)
```
┌─────────────────────────────────────────┐
│  Day 1 Editor                           │
├─────────────────────────────────────────┤
│                                         │
│  ┌────────────────────────────┐  ┌──┐  │
│  │ Select exercise         ▾  │  │✎ │  │  ← Exercise Name Picker
│  └────────────────────────────┘  └──┘  │
│                                         │
│  ┌────────────┬────────────┐           │
│  │  Strength  │Conditioning│           │  ← Type Picker
│  └────────────┴────────────┘           │
│                                         │
│  Sets: 3                                │
│  Reps: 5                                │
│  Weight (optional): _____               │
│                                         │
└─────────────────────────────────────────┘
```

**Elements:**
- Main area shows dropdown button with "Select exercise" placeholder
- Pencil icon button (✎) on the right to switch to custom entry
- Dropdown button styled with border and chevron icon

---

### Screen 2: Dropdown Expanded (Strength)
```
┌─────────────────────────────────────────┐
│  Day 1 Editor                           │
├─────────────────────────────────────────┤
│                                         │
│  ┌────────────────────────────┐  ┌──┐  │
│  │ Select exercise         ▾  │  │✎ │  │
│  └────────────────────────────┘  └──┘  │
│  ┌─────────────────────────────────┐   │
│  │ Back Squat                      │   │
│  │ Front Squat                     │   │
│  │ Goblet Squat                    │   │
│  │ Bulgarian Split Squat           │   │
│  │ Leg Press                       │   │
│  │ Deadlift                        │   │
│  │ Romanian Deadlift               │   │
│  │ ... (more exercises)            │   │
│  ├─────────────────────────────────┤   │
│  │ ✎ Custom Exercise               │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

**Elements:**
- Menu drops down showing all strength exercises
- Divider separates standard exercises from custom option
- "Custom Exercise" option at bottom with pencil icon

---

### Screen 3: Exercise Selected
```
┌─────────────────────────────────────────┐
│  Day 1 Editor                           │
├─────────────────────────────────────────┤
│                                         │
│  ┌────────────────────────────┐  ┌──┐  │
│  │ Bench Press             ▾  │  │✎ │  │  ← Selected exercise shown
│  └────────────────────────────┘  └──┘  │
│                                         │
│  ┌────────────┬────────────┐           │
│  │  Strength  │Conditioning│           │
│  └────────────┴────────────┘           │
│                                         │
│  Sets: 3                                │
│  Reps: 5                                │
│  Weight (optional): _____               │
│                                         │
└─────────────────────────────────────────┘
```

**Elements:**
- Selected exercise name replaces placeholder
- Exercise name shown in primary text color
- Can tap to change or use pencil icon for custom entry

---

### Screen 4: Custom Entry Mode
```
┌─────────────────────────────────────────┐
│  Day 1 Editor                           │
├─────────────────────────────────────────┤
│                                         │
│  ┌────────────────────────────┐  ┌──┐  │
│  │ Exercise name              │  │☰ │  │  ← Free-form text field
│  └────────────────────────────┘  └──┘  │
│                                         │
│  ┌────────────┬────────────┐           │
│  │  Strength  │Conditioning│           │
│  └────────────┴────────────┘           │
│                                         │
│  Sets: 3                                │
│  Reps: 5                                │
│  Weight (optional): _____               │
│                                         │
└─────────────────────────────────────────┘
```

**Elements:**
- Standard iOS text field with rounded border style
- List icon button (☰) on the right to switch back to dropdown
- User can type any custom exercise name

---

### Screen 5: Dropdown Expanded (Conditioning)
```
┌─────────────────────────────────────────┐
│  Day 1 Editor                           │
├─────────────────────────────────────────┤
│                                         │
│  ┌────────────────────────────┐  ┌──┐  │
│  │ Select exercise         ▾  │  │✎ │  │
│  └────────────────────────────┘  └──┘  │
│  ┌─────────────────────────────────┐   │
│  │ Assault Bike                    │   │
│  │ Row Erg                         │   │
│  │ Ski Erg                         │   │
│  │ BikeErg                         │   │
│  │ Run                             │   │
│  │ Swimming                        │   │
│  │ Burpee                          │   │
│  │ Box Jump                        │   │
│  │ ... (more conditioning)         │   │
│  ├─────────────────────────────────┤   │
│  │ ✎ Custom Exercise               │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌────────────┬────────────┐           │
│  │  Strength  │Conditioning│           │  ← Type changed
│  └────────────┴────────────┘           │
│                                         │
│  Duration (minutes): _____              │
│  Calories: _____                        │
│  Rounds: _____                          │
│                                         │
└─────────────────────────────────────────┘
```

**Elements:**
- Different exercise list based on conditioning type
- Shows conditioning-specific exercises only
- Same UI pattern as strength dropdown

---

## Interaction Details

### Toggle Behavior
1. **Pencil Icon (✎)**: Tap to switch from dropdown to custom text entry
2. **List Icon (☰)**: Tap to switch from custom text entry back to dropdown

### Mode Preservation
- When switching modes, the current exercise name is preserved
- Users can edit existing selections when switching to custom mode
- When switching back to dropdown, custom names remain visible

### Type Filtering
- Strength exercises only show when type is "Strength"
- Conditioning exercises only show when type is "Conditioning"
- Picker automatically refreshes when type changes
- Exercise name is preserved when switching types

### Empty State
- If exercise library is empty, automatically shows text field
- No toggle button shown when library is empty

---

## Exercise Library Contents

### Strength (40+ exercises)
**Squats**: Back Squat, Front Squat, Goblet Squat, Bulgarian Split Squat, Leg Press

**Hinges**: Deadlift, Romanian Deadlift, Sumo Deadlift, Trap Bar Deadlift, Good Morning

**Horizontal Press**: Bench Press, Incline Bench Press, Decline Bench Press, Dumbbell Bench Press, Push-Up

**Vertical Press**: Overhead Press, Push Press, Dumbbell Shoulder Press, Handstand Push-Up

**Horizontal Pull**: Barbell Row, Dumbbell Row, Cable Row, Pendlay Row

**Vertical Pull**: Pull-Up, Chin-Up, Lat Pulldown, Ring Muscle-Up

**Olympic**: Clean, Snatch, Clean & Jerk, Power Clean, Power Snatch

**Core**: Plank, Sit-Up, Hanging Knee Raise, Toes to Bar

### Conditioning (12+ exercises)
**Monostructural**: Assault Bike, Row Erg, Ski Erg, BikeErg, Run, Swimming

**Mixed Modal**: Burpee, Box Jump, Double-Under, Wall Ball, Thruster, Kettlebell Swing

---

## Color Scheme
- **Primary Text**: Standard iOS label color (adapts to light/dark mode)
- **Secondary Text**: Gray/muted for placeholders
- **Blue Accent**: Toggle buttons
- **Border**: Light gray separator color
- **Background**: System background (white in light, dark in dark mode)
