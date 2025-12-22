# UI Changes - Active Block Selection & Summary Metrics

## Before and After Comparison

### BEFORE (Original Block Card Layout)
```
┌────────────────────────────────────────┐
│ Block Name                             │
│ Description text here...               │
│                                        │
│ 📅 4 weeks  🎯 Strength  ✨ AI        │
│                                        │
│ [    RUN    ] [EDIT] [NEXT BLOCK]     │
│                                        │
│ ARCHIVE                                │
│ DELETE                                 │
└────────────────────────────────────────┘
```

### AFTER (Enhanced Block Card with Active Selection & Metrics)
```
┌────────────────────────────────────────┐
│ ⭐ ACTIVE BLOCK                    ⭐  │ ← New: Active badge & toggle
│ Block Name                             │
│ Description text here...               │
│                                        │
│ 📅 4 weeks  🎯 Strength  ✨ AI        │
│                                        │
│ ┌──────────────────────────────────┐  │ ← New: Summary Card
│ │ PROGRESS              75%        │  │
│ │ ▰▰▰▰▰▰▰▱▱▱                       │  │ ← Color-coded progress bar
│ │                                  │  │
│ │ ✓ Sets      📅 Workouts  📊 Vol │  │
│ │ 75/100      9/12          12.5k │  │
│ └──────────────────────────────────┘  │
│                                        │
│ [    RUN    ] [EDIT] [NEXT BLOCK]     │
│                                        │
│ ARCHIVE                                │
│ DELETE                                 │
└────────────────────────────────────────┘
   ↑ Yellow border for active blocks
```

## Detailed UI Components

### 1. Active Block Indicator
**Location:** Top of block card
**Components:**
- Yellow star icon (⭐) + "ACTIVE BLOCK" text (left side)
- Star toggle button (right side)
  - Filled star (⭐) when active
  - Outline star (☆) when inactive
- Yellow color theme (#FFD700)

**Behavior:**
- Tap star to toggle active status
- If another block is active, it gets deactivated automatically
- Tap active block's star again to deactivate it

### 2. Active Block Border
**Styling:**
- 2pt yellow stroke around the entire card
- Only visible when block is active
- Uses same yellow color as star indicator

### 3. Summary Metrics Card
**Location:** Between metadata and action buttons
**Layout:** Nested card with tertiary system background

#### Progress Section (Top)
```
PROGRESS                                75%
▰▰▰▰▰▰▰▱▱▱
```
- "PROGRESS" label (caption, bold, secondary color)
- Percentage (right-aligned, caption, bold, progress color)
- Progress bar (8pt height, rounded)
  - Background: Gray 20% opacity
  - Fill: Color-coded based on completion
    - 0%: Gray
    - 1-49%: Yellow
    - 50-74%: Orange
    - 75-100%: Green

#### Metrics Grid (Bottom)
Three columns with dividers:

**Column 1: Sets**
```
✓
75/100
Sets
```
- Icon: checkmark.circle.fill
- Value: completed/planned
- Label: "Sets"

**Column 2: Workouts**
```
📅
9/12
Workouts
```
- Icon: calendar.circle.fill
- Value: completed/planned
- Label: "Workouts"

**Column 3: Volume** (only shown if volume > 0)
```
📊
12.5k
Volume
```
- Icon: chart.bar.fill
- Value: completed volume (formatted)
  - < 1000: Show as integer
  - >= 1000: Show as "X.Xk"
- Label: "Volume"

### 4. Typography & Spacing
- All text uses system fonts
- Icon size: caption
- Metric values: caption, semibold
- Metric labels: caption2, secondary color
- Card padding: 12pt
- Card corner radius: 12pt
- Progress bar corner radius: 4pt

### 5. Color Scheme
The UI adapts to light and dark modes:

**Light Mode:**
- Active border: Yellow (#FFD700)
- Card background: Secondary system background
- Summary card: Tertiary system background
- Text: Primary system text
- Secondary text: Secondary system text

**Dark Mode:**
- Active border: Yellow (#FFD700)
- Card background: Secondary system background (darker)
- Summary card: Tertiary system background (darker)
- Text: Primary system text (lighter)
- Secondary text: Secondary system text (lighter)

## User Interaction Flow

### Setting a Block as Active
1. User taps the star icon on a block card
2. Star fills with yellow color
3. "ACTIVE BLOCK" badge appears at top left
4. Yellow border appears around the entire card
5. If another block was active, it automatically deactivates
6. Change persists across app restarts

### Viewing Metrics
1. Metrics automatically calculate when sessions exist
2. Progress bar updates as user completes sets
3. Colors change based on completion percentage
4. Volume shows total weight lifted (reps × weight)
5. All metrics update in real-time

### Visual States

**No Sessions Yet (Empty Block)**
```
PROGRESS                                 0%
▱▱▱▱▱▱▱▱▱▱

✓           📅           📊
0/0         0/0          0
Sets        Workouts     Volume
```

**Partially Complete**
```
PROGRESS                                45%
▰▰▰▰▰▱▱▱▱▱

✓           📅           📊
45/100      5/12         8.2k
Sets        Workouts     Volume
```

**Highly Complete**
```
PROGRESS                                85%
▰▰▰▰▰▰▰▰▱▱

✓           📅           📊
85/100      10/12        15.7k
Sets        Workouts     Volume
```

## Accessibility Features
- All interactive elements have appropriate tap targets
- Star button includes accessibility label: "Set as active block"
- Color is not the only indicator (text + icons + borders)
- Progress percentages provide numeric feedback
- Supports VoiceOver screen reader
- All text scales with dynamic type settings

## Performance Considerations
- Metrics calculated on-demand in view
- Lightweight computation for typical block sizes
- No caching needed for <100 blocks
- Minimal memory footprint
- Smooth 60fps animations for star toggle
