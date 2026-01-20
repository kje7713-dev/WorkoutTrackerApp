# Manual Verification Checklist

This document provides a checklist for manually verifying the conditioning fields fix on an iOS device.

## Prerequisites
- iOS device or simulator with Xcode
- Build the app with the latest changes
- Access to the Whiteboard view feature

## Test Scenarios

### 1. AMRAP with Distance Meters

**Setup:**
Create or import a block with:
```json
{
  "name": "Row AMRAP",
  "type": "conditioning",
  "conditioningType": "amrap",
  "conditioningSets": [{
    "durationSeconds": 1200,
    "distanceMeters": 5000
  }]
}
```

**Expected Result:**
Whiteboard should display: `20 min AMRAP — 5000m`

**Verification:**
- [ ] Distance meters (5000m) is visible in the secondary line
- [ ] Format is correct with " — " separator
- [ ] No fields are cut off or truncated

---

### 2. AMRAP with Calories

**Setup:**
Create a conditioning exercise:
```json
{
  "name": "Bike AMRAP",
  "type": "conditioning",
  "conditioningType": "amrap",
  "conditioningSets": [{
    "durationSeconds": 600,
    "calories": 150
  }]
}
```

**Expected Result:**
Whiteboard should display: `10 min AMRAP — 150 cal`

**Verification:**
- [ ] Calories (150 cal) is visible
- [ ] Format uses " — " separator
- [ ] Duration and calories both display correctly

---

### 3. EMOM with Distance Meters

**Setup:**
```json
{
  "name": "Row EMOM",
  "type": "conditioning",
  "conditioningType": "emom",
  "conditioningSets": [{
    "durationSeconds": 600,
    "distanceMeters": 100
  }]
}
```

**Expected Result:**
Whiteboard should display: `EMOM 10 min — 100m`

**Verification:**
- [ ] Distance (100m) is visible
- [ ] EMOM duration displays correctly
- [ ] Both fields are on the same line

---

### 4. EMOM with Calories

**Setup:**
```json
{
  "name": "Bike EMOM",
  "type": "conditioning",
  "conditioningType": "emom",
  "conditioningSets": [{
    "durationSeconds": 900,
    "calories": 15
  }]
}
```

**Expected Result:**
Whiteboard should display: `EMOM 15 min — 15 cal`

**Verification:**
- [ ] Calories (15 cal) is visible
- [ ] Format is consistent with other EMOM displays

---

### 5. Intervals with Distance Meters

**Setup:**
```json
{
  "name": "Running Intervals",
  "type": "conditioning",
  "conditioningType": "intervals",
  "conditioningSets": [{
    "durationSeconds": 120,
    "distanceMeters": 400,
    "rounds": 8,
    "restSeconds": 60
  }]
}
```

**Expected Result:**
Whiteboard should display:
- Secondary: `8 rounds — 400m`
- Bullets: `:2:00 hard`, `:1:00 rest`

**Verification:**
- [ ] Distance (400m) is visible in secondary line
- [ ] Rounds display correctly
- [ ] Bullets show work/rest times

---

### 6. Intervals with Calories

**Setup:**
```json
{
  "name": "Bike Intervals",
  "type": "conditioning",
  "conditioningType": "intervals",
  "conditioningSets": [{
    "durationSeconds": 90,
    "calories": 20,
    "rounds": 10,
    "restSeconds": 30
  }]
}
```

**Expected Result:**
Whiteboard should display:
- Secondary: `10 rounds — 20 cal`
- Bullets: `:1:30 hard`, `:0:30 rest`

**Verification:**
- [ ] Calories (20 cal) is visible
- [ ] All fields display without overlap

---

### 7. Rounds For Time with Distance

**Setup:**
```json
{
  "name": "Hero WOD",
  "type": "conditioning",
  "conditioningType": "roundsfortime",
  "notes": "400m run, 50 squats, 400m run",
  "conditioningSets": [{
    "distanceMeters": 800,
    "rounds": 5
  }]
}
```

**Expected Result:**
Whiteboard should display:
- Secondary: `5 Rounds For Time — 800m`
- Bullets: `400m run`, `50 squats`, `400m run`

**Verification:**
- [ ] Distance (800m) is visible
- [ ] Rounds count displays
- [ ] Notes are parsed into bullets

---

### 8. Rounds For Time with Calories

**Setup:**
```json
{
  "name": "Bike WOD",
  "type": "conditioning",
  "conditioningType": "roundsfortime",
  "conditioningSets": [{
    "calories": 50,
    "rounds": 3
  }]
}
```

**Expected Result:**
Whiteboard should display: `3 Rounds For Time — 50 cal`

**Verification:**
- [ ] Calories (50 cal) is visible
- [ ] Rounds display correctly

---

### 9. For Calories with Distance

**Setup:**
```json
{
  "name": "Row",
  "type": "conditioning",
  "conditioningType": "forcalories",
  "conditioningSets": [{
    "distanceMeters": 2000,
    "calories": 100
  }]
}
```

**Expected Result:**
Whiteboard should display: `For Calories — 100 cal • 2000m`

**Verification:**
- [ ] Calories (100 cal) is visible after "For Calories —"
- [ ] Distance (2000m) is visible after " • " separator
- [ ] Both fields display on same line

---

### 10. AMRAP with Both Distance and Calories

**Setup:**
```json
{
  "name": "Mixed AMRAP",
  "type": "conditioning",
  "conditioningType": "amrap",
  "conditioningSets": [{
    "durationSeconds": 1200,
    "distanceMeters": 5000,
    "calories": 200
  }]
}
```

**Expected Result:**
Whiteboard should display: `20 min AMRAP — 5000m — 200 cal`

**Verification:**
- [ ] All three fields are visible (duration, distance, calories)
- [ ] Fields are separated by " — "
- [ ] No truncation or overlap

---

### 11. Existing Functionality (Regression Test)

**For Time:**
```json
{
  "name": "Row",
  "type": "conditioning",
  "conditioningType": "fortime",
  "conditioningSets": [{
    "distanceMeters": 2000
  }]
}
```

**Expected Result:**
Whiteboard should display: `For Time — 2000m`

**Verification:**
- [ ] Existing functionality still works
- [ ] No regression in previously working types

---

**For Distance:**
```json
{
  "name": "Run",
  "type": "conditioning",
  "conditioningType": "fordistance",
  "conditioningSets": [{
    "distanceMeters": 5000
  }]
}
```

**Expected Result:**
Whiteboard should display: `For Distance — 5000m`

**Verification:**
- [ ] Existing functionality still works
- [ ] Format is consistent

---

## UI/UX Checks

### Visual Consistency
- [ ] All conditioning types use consistent font and styling
- [ ] Separators (" — " and " • ") are clearly visible
- [ ] No text overlap or truncation on various screen sizes
- [ ] Monospace font renders correctly for all fields

### Layout Verification
- [ ] Fields align properly on iPhone SE (small screen)
- [ ] Fields align properly on iPhone 14 Pro Max (large screen)
- [ ] Fields align properly on iPad (if supported)
- [ ] Dark mode displays correctly
- [ ] Light mode displays correctly

### Data Integrity
- [ ] Fields only appear when data is present
- [ ] Missing fields don't leave empty separators
- [ ] Nil/null values are handled gracefully
- [ ] Zero values display appropriately

## Screenshot Checklist

Take screenshots for documentation:
- [ ] AMRAP with distance
- [ ] AMRAP with calories
- [ ] EMOM with distance
- [ ] Intervals with distance
- [ ] Rounds For Time with distance
- [ ] For Calories with distance
- [ ] Side-by-side before/after (if possible)

## Performance Checks
- [ ] Whiteboard loads without delay
- [ ] No lag when scrolling through exercises
- [ ] No memory issues with large blocks

## Edge Cases
- [ ] Very large distance values (e.g., 50000m)
- [ ] Very large calorie values (e.g., 1000 cal)
- [ ] Fractional values (should round to integers)
- [ ] Missing/null values handled gracefully

## Sign-Off

Tester: ________________
Date: ________________
iOS Version: ________________
Device: ________________

All tests passed: [ ] Yes [ ] No

Issues found: ________________
________________
________________
