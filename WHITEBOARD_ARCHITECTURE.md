# Whiteboard View Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         INPUT SOURCES                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌───────────────┐  ┌──────────────┐  ┌─────────────────────┐      │
│  │ Block Model   │  │ Authoring    │  │ App Export JSON      │      │
│  │ (Internal)    │  │ JSON (AI)    │  │ (Export Schema)      │      │
│  │               │  │              │  │                      │      │
│  │ • days        │  │ • Exercises  │  │ • blocks[]           │      │
│  │ • weekTemplates│ │ • Days       │  │ • weekTemplates      │      │
│  │               │  │ • Weeks      │  │ • days               │      │
│  └───────┬───────┘  └──────┬───────┘  └──────────┬──────────┘      │
│          │                 │                      │                  │
└──────────┼─────────────────┼──────────────────────┼──────────────────┘
           │                 │                      │
           ▼                 ▼                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    NORMALIZATION LAYER                               │
│                    (BlockNormalizer)                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  normalize(block: Block) -> UnifiedBlock                   │    │
│  │  normalize(authoringBlock: AuthoringBlock) -> UnifiedBlock │    │
│  │  normalize(exportData: AppDataExport) -> UnifiedBlock?     │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                       │
│  Rules:                                                               │
│  • If Weeks: numberOfWeeks = Weeks.count; weeks = Weeks             │
│  • If Days: repeat Days for numberOfWeeks                            │
│  • If Exercises: create "Day 1" with exercises                       │
│                                                                       │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      UNIFIED MODELS                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  UnifiedBlock {                                                      │
│    title: String                                                     │
│    numberOfWeeks: Int                                                │
│    weeks: [[UnifiedDay]]  ← Always normalized                       │
│  }                                                                   │
│                                                                       │
│  UnifiedDay {                                                        │
│    name: String                                                      │
│    goal: String?                                                     │
│    exercises: [UnifiedExercise]                                      │
│  }                                                                   │
│                                                                       │
│  UnifiedExercise {                                                   │
│    name, type, category, notes                                       │
│    strengthSets: [UnifiedStrengthSet]                                │
│    conditioningSets: [UnifiedConditioningSet]                        │
│  }                                                                   │
│                                                                       │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    FORMATTING LAYER                                  │
│                    (WhiteboardFormatter)                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  formatDay(UnifiedDay) -> [WhiteboardSection]                       │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ 1. Partition Exercises                                        │  │
│  │    • Strength vs Conditioning                                 │  │
│  │    • Main Lifts vs Accessories                                │  │
│  │                                                                │  │
│  │ 2. Format Strength                                            │  │
│  │    • Primary: Exercise name                                   │  │
│  │    • Secondary: "5 × 5 @ RPE 8"                               │  │
│  │    • Tertiary: "Rest: 3:00"                                   │  │
│  │                                                                │  │
│  │ 3. Format Conditioning                                        │  │
│  │    • AMRAP: "20 min AMRAP" + bullets                          │  │
│  │    • EMOM: "EMOM 15 min" + bullets                            │  │
│  │    • Intervals: "8 rounds" + work/rest bullets                │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                       │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    VIEW MODELS                                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  WhiteboardSection {                                                 │
│    title: String  ← "STRENGTH", "ACCESSORY", "CONDITIONING"        │
│    items: [WhiteboardItem]                                          │
│  }                                                                   │
│                                                                       │
│  WhiteboardItem {                                                    │
│    primary: String     ← Exercise name                              │
│    secondary: String?  ← Prescription (5×5, 20 min AMRAP)          │
│    tertiary: String?   ← Rest time (Rest: 3:00)                    │
│    bullets: [String]   ← Details (movements, notes)                 │
│  }                                                                   │
│                                                                       │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         UI LAYER                                     │
│                      (WhiteboardViews)                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  WhiteboardWeekView                                                  │
│  ├── Header (Block Title)                                           │
│  ├── Week Selector (if multiple weeks)                              │
│  └── ScrollView                                                      │
│      └── WhiteboardDayCardView (for each day)                       │
│          ├── Day Title + Number                                      │
│          ├── Goal (optional)                                         │
│          └── WhiteboardSectionView (for each section)               │
│              ├── Section Header (STRENGTH/ACCESSORY/CONDITIONING)   │
│              └── WhiteboardItemView (for each exercise)             │
│                  ├── Primary (bold, monospaced)                     │
│                  ├── Secondary (monospaced, secondary color)        │
│                  ├── Tertiary (caption, monospaced)                 │
│                  └── Bullets (caption, monospaced)                  │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    USER INTERFACE                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  BlockRunModeView                                                    │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  [Close Session]           BLOCK NAME    [Whiteboard]      │    │
│  ├────────────────────────────────────────────────────────────┤    │
│  │                                                             │    │
│  │  ┌──────────────────────────────────────────────────┐     │    │
│  │  │  If showWhiteboard:                              │     │    │
│  │  │    WhiteboardWeekView(...)  ← Clean display      │     │    │
│  │  │  Else:                                           │     │    │
│  │  │    WeekRunView(...)  ← Detailed tracking         │     │    │
│  │  └──────────────────────────────────────────────────┘     │    │
│  │                                                             │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                       │
│  Toggle Button:                                                      │
│  • Icon: rectangle.and.text.magnifyingglass (whiteboard)            │
│  • Icon: list.bullet.rectangle (tracking)                           │
│  • Animated transition                                               │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                      EXAMPLE OUTPUT                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  POWERLIFTING DUP BLOCK                                              │
│  Week 1 • Day 1                                                      │
│                                                                       │
│  Heavy Squat Day                                            Day 1    │
│  Goal: strength                                                      │
│  ─────────────────────────────────────────────────────────────      │
│                                                                       │
│  STRENGTH                                                            │
│  Back Squat                                                          │
│  5 × 5 @ RPE 8-9                                                     │
│  Rest: 3:00                                                          │
│                                                                       │
│  ACCESSORY                                                           │
│  Romanian Deadlift                                                   │
│  3 × 8                                                               │
│  Rest: 1:30                                                          │
│                                                                       │
│  Leg Curls                                                           │
│  3 × 12                                                              │
│  Rest: 1:00                                                          │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

## Data Flow

1. **Input** → User opens workout session in BlockRunMode
2. **Toggle** → User taps "Whiteboard" button
3. **Normalize** → Block is converted to UnifiedBlock
4. **Format** → Each UnifiedDay is formatted into sections
5. **Display** → UI renders whiteboard view with monospace font
6. **Toggle Back** → User taps "Tracking" to return to detailed view

## Key Design Decisions

### Separation of Concerns
- **Models**: Pure data structures (no logic)
- **Normalizer**: Converts various inputs to unified format
- **Formatter**: Transforms unified format to display format
- **Views**: Pure presentation (no business logic)

### Extensibility
- Easy to add new conditioning types
- Easy to add new input schemas
- Easy to customize formatting rules
- UI components are reusable

### Performance
- Normalization happens once on toggle
- Formatting is lazy (per day)
- Views use SwiftUI's efficient rendering
- No data persistence overhead (toggle doesn't save state)

### User Experience
- Monospace font ensures alignment
- Compact spacing reduces clutter
- Section headers provide clear organization
- Toggle preserves workout state
- No data loss on view switch
