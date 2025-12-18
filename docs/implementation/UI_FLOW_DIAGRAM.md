# UI Flow Diagram: Conditioning Exercise Type Selection

## User Flow for Adding New Exercise

```
┌─────────────────────────────────────────────────────────────┐
│                     BlockRunMode View                       │
│                                                             │
│  Week 1 • Push Day                                         │
│  ─────────────────                                         │
│                                                             │
│  ┌───────────────────────────────────────────────────┐    │
│  │  Exercise 1: Bench Press (Strength)               │    │
│  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │    │
│  │  Set 1: 5 reps @ 225 lb        [Complete]        │    │
│  │  Set 2: 5 reps @ 225 lb        [Complete]        │    │
│  └───────────────────────────────────────────────────┘    │
│                                                             │
│  ┌───────────────────────────────────────────────────┐    │
│  │         [+] Add Exercise                          │    │ ← User taps
│  └───────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│               Confirmation Dialog                           │
│                                                             │
│            Select Exercise Type                             │
│            ══════════════════════                           │
│                                                             │
│         ┌──────────────────────────────┐                   │
│         │       🏋️ Strength           │ ← Option 1        │
│         └──────────────────────────────┘                   │
│                                                             │
│         ┌──────────────────────────────┐                   │
│         │       🏃 Conditioning        │ ← Option 2 (NEW!) │
│         └──────────────────────────────┘                   │
│                                                             │
│         ┌──────────────────────────────┐                   │
│         │          Cancel              │                   │
│         └──────────────────────────────┘                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                              │
                    User selects "Conditioning"
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     BlockRunMode View                       │
│                                                             │
│  Week 1 • Push Day                                         │
│  ─────────────────                                         │
│                                                             │
│  ┌───────────────────────────────────────────────────┐    │
│  │  Exercise 1: Bench Press (Strength)               │    │
│  │  Set 1: 5 reps @ 225 lb        [Complete]        │    │
│  └───────────────────────────────────────────────────┘    │
│                                                             │
│  ┌───────────────────────────────────────────────────┐    │
│  │  Exercise 2: New Exercise 2                       │    │ ← NEW!
│  │  ─────────────────────────────────────────────    │    │
│  │  [Strength] [Conditioning] ← Segmented Picker     │    │
│  │             ^^^^^^^^^^^^^^                        │    │
│  │                 Selected                           │    │
│  │                                                    │    │
│  │  Set 1                                            │    │
│  │  Planned: Conditioning                            │    │
│  │  ┌──────────────────────────────────────────┐    │    │
│  │  │ TIME     [-] 0  [+]  min                 │    │    │
│  │  │ CALORIES [-] 0  [+]  cal                 │    │    │
│  │  │ ROUNDS   [-] 0  [+]  rounds              │    │    │
│  │  └──────────────────────────────────────────┘    │    │
│  │                            [Complete]        │    │    │
│  └───────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## User Flow for Changing Exercise Type

```
┌─────────────────────────────────────────────────────────────┐
│           Exercise Card (with logged data)                  │
│                                                             │
│  Exercise: Row 500m                                        │
│  ───────────────────                                       │
│  [Strength] [Conditioning] ← User taps "Strength"          │
│             ^^^^^^^^^^^^^^                                  │
│              Currently selected                             │
│                                                             │
│  Set 1                                                     │
│  Planned: 20 min • 200 cal • 1 round                      │
│  TIME: 18 min  CALORIES: 180 cal  ROUNDS: 1               │
│  [COMPLETED] ✅                                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                              │
              User attempts to change to "Strength"
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Confirmation Alert                         │
│                                                             │
│         ⚠️  Change Exercise Type?                          │
│         ═════════════════════════                          │
│                                                             │
│  Changing the exercise type will reset all                 │
│  sets and lose logged values. This cannot                  │
│  be undone.                                                │
│                                                             │
│         ┌──────────────────────────────┐                   │
│         │        Cancel                │ ← Safe option     │
│         └──────────────────────────────┘                   │
│                                                             │
│         ┌──────────────────────────────┐                   │
│         │     Change Type              │ ← Destructive     │
│         └──────────────────────────────┘                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Before vs After Comparison

### BEFORE (Issue #46)
```
❌ Add Exercise button → Always creates Strength exercise
❌ No way to select Conditioning type
❌ No way to change type after creation
❌ New exercises lost on save (RunStateMapper bug)
```

### AFTER (This PR)
```
✅ Add Exercise button → Shows type selection dialog
✅ Can select Strength OR Conditioning upfront
✅ Can change type using segmented picker
✅ Safety warning before type change with data
✅ All exercises persist correctly (bug fixed)
✅ All conditioning data (time/cal/rounds) saves
```

## Data Flow

```
User Action                      Data Layer                    Persistence
───────────                      ──────────                    ───────────

Select "Conditioning"
       │
       ├───► RunExerciseState
       │     type: .conditioning ───► RunStateMapper
       │     sets: [RunSetState]      │
       │                               ├───► SessionExercise
       │                               │     loggedSets: [SessionSet]
       │                               │
       │                               └───► SessionsRepository
       │                                     │
       │                                     └───► sessions.json
       │                                           {
       │                                             "loggedTime": 1200,
Complete Set                                          "loggedCalories": 200,
       │                                              "loggedRounds": 1
       ├───► RunSetState                             "isCompleted": true
       │     actualTimeSeconds: 1200                }
       │     actualCalories: 200
       │     actualRounds: 1
       │     isCompleted: true
       │
       └───► (same path as above)

Close Session
       │
       └───► RunStateMapper.runWeeksToSessions()
             │
             ├───► Handles NEW exercises
             ├───► Handles NEW sets
             ├───► Updates existing data
             │
             └───► SessionsRepository.replaceSessions()
                   │
                   └───► Persisted to sessions.json ✅
```

## Key UI Components

### 1. Exercise Type Selection Dialog
- **Type:** `.confirmationDialog` (iOS native)
- **Trigger:** Tap "Add Exercise" button
- **Options:** Strength, Conditioning, Cancel
- **Location:** `DayRunView`

### 2. Exercise Type Picker
- **Type:** `Picker` with `.segmented` style
- **Location:** `ExerciseRunCard` (below exercise name)
- **Options:** Strength, Conditioning
- **Behavior:** Shows confirmation if data would be lost

### 3. Type Change Warning Dialog
- **Type:** `.alert` (iOS native)
- **Trigger:** Type change with logged data detected
- **Options:** Cancel, Change Type
- **Message:** Clear warning about data loss

### 4. Conditioning Controls
- **TIME:** Minutes (increment by 1)
- **CALORIES:** Calories (increment by 5)
- **ROUNDS:** Rounds (increment by 1)
- All use `SetControlView` component

## Edge Cases Handled

✅ **Cancel dialog** → No exercise added
✅ **Type change with no data** → Immediate change, no warning
✅ **Type change with data** → Warning dialog shown
✅ **Add multiple exercises** → Each can have different type
✅ **Mix strength & conditioning** → Both work in same day
✅ **Close & reopen session** → All data persists
✅ **Add sets during workout** → All sets persist
✅ **Remove sets during workout** → Remaining sets persist

## User Experience Improvements

1. **Clear Options:** Type selection dialog presents clear choices
2. **Flexibility:** Can change type after creation if needed
3. **Safety:** Warning prevents accidental data loss
4. **Consistency:** Follows iOS platform conventions
5. **Feedback:** Clear visual indicators (segmented control)
6. **Persistence:** All data saves automatically

## Testing Checklist

- [ ] Add strength exercise → Works as before
- [ ] Add conditioning exercise → New dialog appears
- [ ] Select conditioning → Creates conditioning exercise
- [ ] See conditioning controls → Time/Cal/Rounds visible
- [ ] Complete conditioning set → Marks as complete
- [ ] Close and reopen → Conditioning data persists
- [ ] Change type with no data → Changes immediately
- [ ] Change type with data → Warning appears
- [ ] Cancel type change → Keeps original type
- [ ] Confirm type change → Resets sets with new type
- [ ] Mix both types → Both work in same workout

---

**Status:** ✅ All UI flows implemented and ready for testing
