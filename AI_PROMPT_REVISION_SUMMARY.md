# AI Prompt Revision Summary - v3 Coach-Grade System

## What Changed

### Files Modified:
1. **BlockGeneratorView.swift** - `aiPromptTemplate()` function completely revised
2. **AI_PROMPT_SCOPE_CONTRACT.md** - Updated to document v3 system
3. **AI_PROMPT_EXAMPLES_V3.md** - NEW: Comprehensive examples of v3 behavior

### Core Philosophy Change

**Before (v2):**
- Focus on asking user questions to gather requirements
- Generate based on user answers or defaults
- Schema could be bent to express training concepts

**After (v3):**
- Focus on training correctness analysis first
- Schema compliance is non-negotiable
- Reduce scope or ask questions when conflicts arise
- MEU/MRU analysis prevents over/under-programming

## New Prompt Structure

### 1. ENTROPY DETECTION
Classifies request as LOW (simple) or HIGH (complex)

### 2. SCOPE SUMMARY (INITIAL)
For HIGH entropy:
- contentType: workout | seminar | course | curriculum | protocol | other
- primaryItem: exercise | technique | drill | concept | task | skill
- mediaImpact: low | medium | high

### 3. GOAL STIMULUS
Identifies:
- Primary Stimulus (e.g., strength, hypertrophy, skill)
- Secondary Stimulus
- Tertiary Stimulus (optional)
- Stops if unclear or contradictory

### 4. PRE-SCOPE SUFFICIENCY ANALYSIS
Analyzes:
1. Minimum Effective Units (MEU)
2. Maximum Recoverable Units (MRU)
3. Time Constraint Check
4. Interference Check

### 5. UNIT JUSTIFICATION
Before JSON generation:
- Primary Stimulus
- MEU per Session
- MRU per Session
- Chosen Units per Session
- Rejected Alternatives
- Final Justification

### 6. QUESTION GATE
For HIGH entropy (unless "use defaults"):
1. Session duration
2. Unit density
3. Detail depth
4. Structure consistency
5. Video policy (if mediaImpact = high)

### 7. SMART DEFAULTS
Training-aware defaults:
- Strength: 2 units (1 main + 1 secondary), MRU = 3
- Conditioning after strength to avoid interference
- Medium detail, moderate duration by default

### 8. SCOPE SUMMARY (FINAL)
After analysis:
- All parameters locked
- No further scope changes
- No unit additions
- No schema reshaping

### 9. SCHEMA PRIORITY RULES
Absolute rules:
- Never alter schema shape
- Never add filler units
- Reduce scope or ask instead
- Schema compliance mandatory

### 10. HARD FAILURE CONDITIONS
AI must STOP if:
- MEU > MRU
- Duration can't support MEU
- Primary stimulus undermined
- Unit count unjustified
- Schema can't be maintained

## Key Improvements

### 1. Training Correctness
- MEU/MRU prevents over/under-programming
- Interference check catches conflicting goals
- Unit justification makes decisions explicit

### 2. Schema Compliance
- Non-negotiable schema adherence
- No more format violations
- Consistent parsing in app

### 3. Intelligent Failures
- Hard failures catch impossible requests
- AI asks for clarification instead of guessing
- Suggests viable alternatives

### 4. Coach-Like Behavior
- Analyzes training stimulus
- Considers recovery capacity
- Identifies goal conflicts
- Makes evidence-based decisions

## Backward Compatibility

✅ **100% Backward Compatible**

- JSON schema unchanged
- Parser (BlockGenerator.swift) unchanged
- All existing blocks remain valid
- All existing tests should pass
- Only prompt template changed

## Testing Recommendations

### Test Case 1: Simple Workout (LOW-ENTROPY)
```
Input: "Create a single upper body workout"
Expected: Direct generation with smart defaults
```

### Test Case 2: Multi-Week Block (HIGH-ENTROPY)
```
Input: "Create a 4-week strength block"
Expected: Full analysis with MEU/MRU, questions, justification
```

### Test Case 3: Impossible Request (HARD FAILURE)
```
Input: "30-minute workout with 8 heavy compound lifts"
Expected: AI stops, identifies MEU > MRU, suggests alternatives
```

### Test Case 4: Conflicting Goals (INTERFERENCE)
```
Input: "Heavy squats AND high-volume running"
Expected: Interference check flags conflict, asks for primary goal
```

### Test Case 5: Skill-Based (BJJ/Yoga)
```
Input: "8-week BJJ curriculum with videos"
Expected: Uses segments, identifies skill-based MEU/MRU (cognitive load)
```

## Migration Path

No migration needed! This is a prompt-only change.

**For Users:**
1. No action required
2. Existing blocks continue to work
3. New blocks will show improved analysis
4. Can continue using old-style prompts if desired

**For Developers:**
1. No code changes needed
2. Parser remains unchanged
3. Tests remain valid
4. JSON schema unchanged

## Documentation

### Updated Files:
- `AI_PROMPT_SCOPE_CONTRACT.md` - Full v3 documentation
- `AI_PROMPT_EXAMPLES_V3.md` - Comprehensive examples

### Preserved Files:
- `docs/AI_PROMPT_EXAMPLES.md` - Original examples (still valid)
- All other documentation unchanged

## Future Enhancements

Potential v4 improvements:
- Auto-calculate MEU/MRU based on experience level
- Built-in interference matrices for common combinations
- Historical tracking to refine recommendations
- Preset stimulus profiles (powerlifting, CrossFit, etc.)
- Recovery capacity estimation

## Summary

The v3 prompt transforms AI from a "JSON generator" into a "coach-grade program designer" that:
- Analyzes training correctness before generating
- Enforces schema compliance absolutely
- Prevents invalid programs through hard failures
- Justifies all programming decisions
- Handles complex requests intelligently

This creates better training programs while maintaining 100% backward compatibility.
