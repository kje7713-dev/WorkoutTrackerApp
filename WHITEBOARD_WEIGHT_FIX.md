# Whiteboard Weight Display Fix

## Issue
Planned working weights were not being displayed in the whiteboard view when viewing workout blocks.

## Root Cause
The whiteboard system uses a separate set of "Unified" models to normalize data from different sources (authoring JSON, app blocks, export JSON). The `UnifiedStrengthSet` model was missing the `weight` field, so when exercises were normalized from `StrengthSetTemplate` (which has a `weight` field), the weight data was being dropped.

## Solution

### 1. Model Update (WhiteboardModels.swift)
Added `weight: Double?` field to `UnifiedStrengthSet`:

```swift
public struct UnifiedStrengthSet: Codable, Equatable {
    public var reps: Int?
    public var weight: Double?  // ← Added
    public var restSeconds: Int?
    public var rpe: Double?
    public var notes: String?
}
```

### 2. Normalization Update (BlockNormalizer.swift)
Updated the exercise normalization to map the weight field:

```swift
let strengthSets = (exercise.strengthSets ?? []).map { set in
    UnifiedStrengthSet(
        reps: set.reps,
        weight: set.weight,  // ← Added mapping
        restSeconds: set.restSeconds,
        rpe: set.rpe,
        notes: set.notes
    )
}
```

### 3. Formatter Enhancement (WhiteboardFormatter.swift)
Enhanced `formatStrengthPrescription()` to include weight in the display:

**Display Formats:**
- Same weight across all sets: `"5 × 5 @ 225 lbs"`
- Varying weights (pyramid): `"3 × 5 @ 135/185/225 lbs"`
- Weight with RPE notes: `"3 × 3 @ 315 lbs @ RPE 8"`
- No weight (backward compatible): `"5 × 5 @ RPE 8"`

**Implementation:**
```swift
// Extract and format weights
let weightValues = sets.compactMap { $0.weight }
if !weightValues.isEmpty {
    let uniqueWeights = Set(weightValues)
    if uniqueWeights.count == 1, let weight = weightValues.first {
        result += " @ \(formatWeight(weight)) lbs"
    } else if weightValues.count == sets.count {
        let weightsString = weightValues.map { formatWeight($0) }.joined(separator: "/")
        result += " @ \(weightsString) lbs"
    }
}

// Helper function to format weights
private static func formatWeight(_ weight: Double) -> String {
    return weight.truncatingRemainder(dividingBy: 1) == 0 
        ? String(format: "%.0f", weight)
        : String(format: "%.1f", weight)
}
```

### 4. Test Coverage (WhiteboardTests.swift)
Added comprehensive test cases:

1. **testFormatStrengthPrescriptionWithWeight**: Verifies exercises with consistent weights display correctly
2. **testFormatStrengthPrescriptionWithWeightAndRPE**: Verifies weight and RPE notes combine properly
3. **testFormatStrengthPrescriptionWithVaryingWeights**: Verifies pyramid-style weight progressions display correctly

### 5. Preview Update (WhiteboardPreview.swift)
Updated the sample data with realistic weights so the preview actually demonstrates the feature:
- Back Squat: 225 lbs
- Romanian Deadlift: 185 lbs
- Front Squat: 185 lbs
- etc.

## Testing

### Unit Tests
All existing tests pass, and new tests verify:
- ✓ Weight display with consistent weights
- ✓ Weight display with varying weights
- ✓ Weight display combined with RPE notes
- ✓ Backward compatibility (no weights specified)

### Edge Cases Handled
- Exercises with no weights specified (displays reps/sets only)
- Exercises where only some sets have weights (only displays if all sets have weights)
- Decimal weights (displays with 1 decimal place)
- Whole number weights (displays without decimal)

## Backward Compatibility
The implementation is fully backward compatible:
- Exercises without weights continue to display correctly
- All existing whiteboard functionality remains unchanged
- Optional `weight` field means old data structures still work

## Visual Examples

### Before Fix
```
Back Squat
5 × 5 @ RPE 8-9
Rest: 3:00
```

### After Fix
```
Back Squat
5 × 5 @ 225 lbs @ RPE 8-9
Rest: 3:00
```

### Pyramid Example
```
Bench Press
3 × 5 @ 135/185/225 lbs
```

## Files Changed
1. `WhiteboardModels.swift` - Added weight field to UnifiedStrengthSet
2. `BlockNormalizer.swift` - Map weight during normalization
3. `WhiteboardFormatter.swift` - Display weight in prescription
4. `WhiteboardTests.swift` - Added test coverage
5. `WhiteboardPreview.swift` - Updated sample data

## Impact
- **User Experience**: Users can now see planned working weights in the whiteboard view
- **Data Fidelity**: Weight information is preserved through the normalization pipeline
- **Code Quality**: Improved with extracted helper function and comprehensive tests
- **Performance**: Negligible impact (simple field mapping and formatting)
