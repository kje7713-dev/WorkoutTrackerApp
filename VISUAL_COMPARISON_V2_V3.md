# Visual Comparison: v2 vs v3 AI Prompt

## Before (v2): Question-Driven Approach

```
┌─────────────────────────────────────────┐
│ User: "Create 4-week BJJ curriculum"   │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ AI: Detects HIGH-ENTROPY                │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ AI: Shows INITIAL SCOPE SUMMARY         │
│ - contentType: curriculum               │
│ - primaryItem: technique                │
│ - mediaImpact: medium                   │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ AI: Asks 5 Questions                    │
│ 1. Session duration?                    │
│ 2. How many items per session?          │
│ 3. Detail depth?                        │
│ 4. Structure consistency?               │
│ 5. Video policy? (if high media)        │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ User: Answers questions OR              │
│       Says "use defaults"               │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ AI: Shows FINAL SCOPE SUMMARY           │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ AI: Generates JSON                      │
└─────────────────────────────────────────┘
```

## After (v3): Analysis-Driven Approach

```
┌─────────────────────────────────────────┐
│ User: "Create 4-week BJJ curriculum"   │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ AI: Detects HIGH-ENTROPY                │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ AI: SCOPE SUMMARY (INITIAL)             │
│ - contentType: curriculum               │
│ - primaryItem: technique                │
│ - mediaImpact: high                     │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ AI: GOAL STIMULUS Analysis              │
│ - Primary: Skill acquisition (guard)    │
│ - Secondary: Drilling proficiency       │
│ - Tertiary: Live application            │
│ ❌ If unclear → STOP and ask            │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ AI: PRE-SCOPE SUFFICIENCY ANALYSIS      │
│ 1. MEU: 2-3 techniques (depth)          │
│ 2. MRU: 4-5 techniques (cognitive)      │
│ 3. Time: 60-90 min supports MEU ✓       │
│ 4. Interference: None ✓                 │
│ ❌ If MEU > MRU → HARD FAILURE          │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ AI: UNIT JUSTIFICATION                  │
│ - MEU: 2 techniques                     │
│ - MRU: 4 techniques                     │
│ - Chosen: 3 techniques                  │
│ - Rejected: 5+ (poor retention)         │
│ - Justification: Optimal for learning   │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ AI: QUESTION GATE (if needed)           │
│ OR use SMART DEFAULTS                   │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ AI: SCOPE SUMMARY (FINAL)               │
│ - All parameters LOCKED                 │
│ - No further scope changes              │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ AI: Generates VALID JSON                │
│ Schema compliance: MANDATORY            │
└─────────────────────────────────────────┘
```

## Key Difference: HARD FAILURE Example

### v2 Behavior (Would Try Anyway):
```
User: "30-minute workout with 8 heavy compounds"
  ↓
AI: Asks questions
  ↓
AI: Generates JSON (might be invalid or unsafe)
```

### v3 Behavior (Fails Gracefully):
```
User: "30-minute workout with 8 heavy compounds"
  ↓
AI: Detects HIGH-ENTROPY
  ↓
AI: Analyzes MEU/MRU
  - MEU: 8 exercises (requested)
  - MRU: 3-4 (heavy compounds)
  - Time: 30 min = 3.75 min per exercise
  ↓
AI: HARD FAILURE DETECTED ❌
  - MEU (8) > MRU (4)
  - Time insufficient
  ↓
AI: STOPS and suggests alternatives:
  A) Reduce to 3 exercises in 30 min
  B) Keep 8 exercises but extend to 75 min
  C) Split into 2 sessions
```

## Feature Comparison Table

| Feature | v2 | v3 |
|---------|----|----|
| **Entropy Detection** | ✅ HIGH/LOW | ✅ HIGH/LOW |
| **Scope Summary** | ✅ Initial + Final | ✅ Initial + Final |
| **Goal Stimulus** | ❌ Not analyzed | ✅ Primary/Secondary/Tertiary |
| **MEU/MRU Analysis** | ❌ Not present | ✅ Required for HIGH entropy |
| **Interference Check** | ❌ Not present | ✅ Catches conflicts |
| **Unit Justification** | ❌ Not present | ✅ Required before JSON |
| **Hard Failures** | ❌ Tries anyway | ✅ Stops and suggests alternatives |
| **Schema Priority** | ⚠️ Can be bent | ✅ NON-NEGOTIABLE |
| **Training Analysis** | ⚠️ Minimal | ✅ Comprehensive |
| **Question Asking** | ✅ Always (5 questions) | ✅ Smart (if needed) |
| **Smart Defaults** | ✅ Basic | ✅ Training-aware |
| **Schema Compliance** | ⚠️ Best effort | ✅ Mandatory |

## Real-World Impact

### Scenario 1: Beginner Overreach
**Request:** "Create 6-week program with squats, deadlifts, bench, overhead press, rows, pull-ups, dips, AND sprinting"

**v2 Behavior:**
- Asks questions
- Generates all exercises
- User might overtrain ⚠️

**v3 Behavior:**
- Analyzes MEU (8 items) vs MRU (4 items)
- Detects HARD FAILURE
- Suggests: Focus on 4 main lifts OR split into separate blocks ✅

### Scenario 2: Conflicting Goals
**Request:** "Heavy powerlifting AND marathon training"

**v2 Behavior:**
- Asks questions
- Generates both
- Doesn't flag interference ⚠️

**v3 Behavior:**
- Analyzes goal stimulus: PRIMARY unclear
- Runs INTERFERENCE CHECK: Severe conflict detected
- STOPS and asks: "Which is primary goal? Heavy lifting undermines marathon, marathon undermines strength" ✅

### Scenario 3: Schema Violation
**Request:** "Generate JSON with custom fields for my tracking app"

**v2 Behavior:**
- Might try to accommodate
- Could break schema ⚠️

**v3 Behavior:**
- SCHEMA PRIORITY RULE enforced
- Cannot add custom fields
- Suggests: Use 'notes' field or reduce scope ✅

## Bottom Line

### v2: "I'll generate what you ask for"
- User-driven decisions
- Best-effort schema compliance
- Can generate unsafe programs
- Minimal training analysis

### v3: "I'll analyze if this makes sense first"
- AI analyzes training correctness
- Absolute schema compliance
- Prevents unsafe programs
- Comprehensive training analysis
- Coach-like decision making

## Migration Impact

**For End Users:**
- ✅ No changes to existing blocks
- ✅ No app updates needed
- ✅ Better quality from new generations
- ✅ More transparent decision-making

**For Developers:**
- ✅ No code changes needed
- ✅ No schema changes
- ✅ No parser updates
- ✅ Tests still pass

**For AI Assistants:**
- ✅ Clearer guidelines
- ✅ Built-in validation
- ✅ Better training logic
- ✅ Fewer parsing errors
