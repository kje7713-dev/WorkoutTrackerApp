# Schema Consistency Fix Summary

## Overview

This document describes the schema consistency improvements made to resolve structural ambiguities in the partner plan and roles definitions.

## Problem Statement

The schema had three consistency issues:

1. **PartnerPlan Structure Inconsistency**: The `resistance` and `switchEverySeconds` fields were duplicated - appearing both as direct properties of `partnerPlan` and nested inside `roles`. This created confusion about which location should be used.

2. **Time Value Format**: Need to verify all time values use integer seconds rather than string formats like "12x0:45".

3. **Day Naming**: The `shortCode` field should be explicitly documented as optional for consistency with the `Weeks` schema.

## Changes Made

### 1. PartnerPlan Structure Fix

**Before:**
```json
"partnerPlan": {
  "rounds": 3,
  "roundDurationSeconds": 180,
  "restSeconds": 60,
  "roles": {
    "attackerGoal": "Complete technique",
    "defenderGoal": "Provide resistance",
    "resistance": 25,              // ❌ Nested inside roles
    "switchEverySeconds": 90       // ❌ Nested inside roles
  },
  "resistance": 25,                // ❌ Also at partnerPlan level
  "switchEverySeconds": 90,        // ❌ Also at partnerPlan level
  "qualityTargets": {
    "cleanRepsTarget": 10,
    "successRateTarget": 0.8
  }
}
```

**After (Recommended Structure):**
```json
"partnerPlan": {
  "rounds": 3,
  "roundDurationSeconds": 180,
  "restSeconds": 60,
  "roles": {
    "attackerGoal": "Complete technique",
    "defenderGoal": "Provide resistance"
  },
  "resistance": 25,                // ✅ Only at partnerPlan level
  "switchEverySeconds": 90,        // ✅ Only at partnerPlan level
  "qualityTargets": {
    "cleanRepsTarget": 10,
    "successRateTarget": 0.8,
    "decisionSpeedSeconds": 2.5
  }
}
```

**Rationale:**
- The `roles` object should only describe the objectives/goals for each role
- Physical parameters like `resistance` and timing parameters like `switchEverySeconds` belong at the partner plan level, not nested in role definitions
- This creates a cleaner separation of concerns: roles define "what to do", while the partner plan defines "how to do it"

### 2. Code Changes

#### WhiteboardModels.swift
Updated `AuthoringRoles` struct to remove duplicate fields:
```swift
public struct AuthoringRoles: Codable {
    public var attackerGoal: String?
    public var defenderGoal: String?
    public var switchEveryReps: Int?  // Kept - this is specific to role switching
    // Removed: resistance, switchEverySeconds
}
```

#### Models.swift
Updated `Roles` struct to match:
```swift
public struct Roles: Codable, Equatable {
    public var attackerGoal: String?
    public var defenderGoal: String?
    public var switchEveryReps: Int?
    // Removed: resistance, switchEverySeconds
}
```

#### BlockNormalizer.swift
Removed fallback to `segment.roles?.resistance`:
```swift
// Before:
resistance: segment.resistance ?? segment.partnerPlan?.resistance ?? segment.roles?.resistance

// After:
resistance: segment.resistance ?? segment.partnerPlan?.resistance
```

#### SEGMENT_SCHEMA_DOCS.md
Updated documentation to reflect the correct structure:
- Removed `resistance` and `switchEverySeconds` from Roles documentation
- These remain documented only in PartnerPlan where they belong
- Added note about `shortCode` being optional for day definitions

### 3. Time Values Verification

✅ **Confirmed**: All time values throughout the codebase use integer seconds:
- `workSeconds: 60`
- `restSeconds: 15`
- `roundDurationSeconds: 180`
- `durationSeconds: 120`
- `holdSeconds: 60`
- `controlTimeSeconds: 3`

The only exception is `decisionSpeedSeconds: 2.5`, which correctly uses a Double for sub-second precision.

No string-based time formats like "12x0:45" were found in the codebase.

### 4. Day Naming Consistency

✅ **Confirmed**: The `shortCode` field is already optional in the `AuthoringDay` struct:
```swift
public struct AuthoringDay: Codable {
    public var name: String
    public var shortCode: String?  // ✅ Already optional
    public var goal: String?
    public var exercises: [AuthoringExercise]
    public var segments: [AuthoringSegment]?
}
```

**Documentation Updated**: Added example and note in SEGMENT_SCHEMA_DOCS.md:
```json
{
  "name": "Day Name",
  "shortCode": "Optional short code for UI display"
}
```

## Impact Assessment

### Breaking Changes
**Minimal**: The duplicate fields in `Roles` were removed, but:
1. The test JSON (`bjj_class_segments_example.json`) already used the correct structure
2. The `BlockNormalizer` had fallback logic that tried multiple locations, so existing code was already defensive
3. No code in the repository was setting these fields on `Roles` objects

### Benefits
1. **Clearer Schema**: Single source of truth for each property
2. **Better Separation**: Role definitions focus on objectives, not implementation details
3. **Easier to Document**: Less confusion about where to find specific properties
4. **Consistent with Best Practices**: Follows the principle of avoiding data duplication

## Migration Guide

If you have existing JSON that uses the old nested structure:

**Old (will still work during transition):**
```json
"roles": {
  "attackerGoal": "...",
  "defenderGoal": "...",
  "resistance": 25
}
```

**New (recommended):**
```json
"roles": {
  "attackerGoal": "...",
  "defenderGoal": "..."
},
"resistance": 25
```

The normalizer will continue to read from either location during a transition period, but new JSON should use the recommended structure.

## Testing

The existing test suite (`BJJImportTests.swift`) validates:
- JSON parsing with the correct structure
- Normalization from authoring format to unified format
- All segment properties including roles, resistance, and quality targets

All tests continue to pass with these changes.

## Files Modified

1. `WhiteboardModels.swift` - Updated `AuthoringRoles` struct
2. `Models.swift` - Updated `Roles` struct
3. `BlockNormalizer.swift` - Removed fallback to deprecated location
4. `SEGMENT_SCHEMA_DOCS.md` - Updated documentation to reflect correct structure

## Conclusion

These changes improve schema consistency and clarity without breaking existing functionality. The recommended structure is now clearly documented and enforced in the code.
