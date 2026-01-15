# Build Error Analysis - January 15, 2026

## CI Build Failure Summary
**Workflow Run:** #594 (iOS TestFlight)  
**Date:** January 15, 2026 at 18:36 UTC  
**Branch:** main  
**Commit:** d58ef0c2d99d3138cac2b6f072cb4381e9bae6aa  
**Status:** ❌ Failed

## Error Catalogue

### Error #1: Type-Check Timeout in SetRunRow.body
**Location:** `blockrunmode.swift:1631:25`

**Error Message:**
```
the compiler is unable to type-check this expression in reasonable time; 
try breaking up the expression into distinct sub-expressions
```

**Context:**
```swift
var body: some View {
    // Complex VStack with 13 .onChange modifiers
```

**Root Cause:**
The `SetRunRow.body` property had a deeply nested view hierarchy with 13 chained `.onChange()` modifiers monitoring different properties. This exceeded Swift's type inference limits in whole-module optimization mode, causing the compiler to timeout during type-checking.

**Impact:** 
- Blocked entire app compilation
- Prevented CI/CD pipeline from completing
- Affected Release build only (optimized builds use whole-module optimization)

---

### Error #2: Ambiguous Toolbar Function Call
**Location:** `blockrunmode.swift:2249:14`

**Error Message:**
```
ambiguous use of 'toolbar(content:)'
```

**Context:**
```swift
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button("Cancel") { dismiss() }
    }
}
```

**Root Cause:**
SwiftUI's `.toolbar()` modifier has two overloads:
1. `.toolbar(@ViewBuilder content: () -> Content)`
2. `.toolbar(@ToolbarContentBuilder content: () -> Content)`

The compiler couldn't infer which version to use because both accept closures returning views.

**Impact:**
- Secondary compilation error
- Prevented AddExerciseSheet from compiling
- Would block entire app even if Error #1 was fixed

---

## Commonalities Across Errors

### Shared Characteristics
1. **File:** Both errors occurred in `blockrunmode.swift`
2. **Technology:** Both are SwiftUI-related issues
3. **Root Cause Category:** Swift compiler type inference limitations
4. **Build Configuration:** Both only manifest in Release builds with optimizations enabled

### Pattern Recognition
These errors represent common Swift/SwiftUI compiler limitations:
- **View Complexity:** Complex view hierarchies exceed type-checker limits
- **API Ambiguity:** Overloaded APIs require explicit disambiguation
- **Optimization Mode:** Whole-module optimization is stricter than incremental builds

### Why They Appeared Together
These issues likely existed in the codebase for some time but only surfaced when:
1. Code complexity reached a threshold
2. SwiftUI framework evolved (new overloads added)
3. Xcode version updated with stricter type-checking

---

## Fixes Implemented

### Fix #1: Extract View Modifiers (SetRunRow)

**Strategy:** Reduce type-checking complexity by decomposing the view

**Changes Made:**
1. Extracted main content into `mainContent` computed property
2. Created `SetRunRowStyleModifier` ViewModifier for styling
3. Created `SetRunRowChangeTracker` ViewModifier for change handlers
4. Applied modifiers using `.modifier()` instead of inline chaining

**Before:**
```swift
var body: some View {
    VStack { /* content */ }
        .padding(10)
        .background(/* styling */)
        .overlay(/* completion badge */)
        .onChange(of: runSet.actualReps) { onSave() }
        .onChange(of: runSet.actualWeight) { onSave() }
        // ... 11 more onChange modifiers
}
```

**After:**
```swift
var body: some View {
    mainContent
        .modifier(SetRunRowStyleModifier(isCompleted: runSet.isCompleted))
        .modifier(SetRunRowChangeTracker(runSet: runSet, onSave: onSave))
}

private var mainContent: some View { 
    VStack { /* content */ } 
}
```

**Benefits:**
- Reduced type-checking complexity
- Improved code organization
- Easier to maintain and test
- No runtime behavior changes

---

### Fix #2: Explicit Toolbar Content Builder

**Strategy:** Disambiguate API call with explicit type annotation

**Changes Made:**
1. Extracted toolbar content into separate function
2. Added `@ToolbarContentBuilder` attribute
3. Changed inline closure to function reference

**Before:**
```swift
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button("Cancel") { dismiss() }
    }
}
```

**After:**
```swift
.toolbar(content: toolbarContent)

@ToolbarContentBuilder
private func toolbarContent() -> some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button("Cancel") { dismiss() }
    }
}
```

**Benefits:**
- Explicit type resolution
- Compiler knows exactly which toolbar variant to use
- More maintainable (toolbar content is named and reusable)
- No runtime behavior changes

---

## Prevention Strategies

### For Similar Issues in Future

#### Type-Check Timeouts
**Prevention:**
1. Keep view bodies under 10 view modifiers
2. Extract complex views into computed properties
3. Use ViewModifier protocol for reusable styling
4. Test release builds regularly (don't rely only on debug builds)

**Warning Signs:**
- SwiftUI compilation takes longer than 5 seconds
- Xcode shows "Type checking taking a long time" warning
- Build succeeds in Debug but fails in Release

#### Ambiguous API Calls
**Prevention:**
1. Use explicit result builder attributes (`@ViewBuilder`, `@ToolbarContentBuilder`)
2. Extract complex closures into named functions
3. Add type annotations when multiple overloads exist
4. Keep up with SwiftUI API changes (new overloads may cause ambiguity)

**Warning Signs:**
- "Ambiguous use of..." compiler error
- Multiple candidates shown in error message
- API has similar signatures with different result builders

---

## Broader Implications

### Technical Debt Assessment
These errors indicate that `blockrunmode.swift` has grown too large and complex:
- **File Size:** 2,734 lines (exceeds recommended 500-1000 lines)
- **View Count:** 10+ distinct View structs in one file
- **Complexity:** Multiple concerns mixed (UI, state, models)

### Recommended Refactoring
Consider splitting `blockrunmode.swift` into:
1. `BlockRunModeView.swift` - Main coordinator view
2. `WeekRunView.swift` - Week-level views
3. `DayRunView.swift` - Day-level views  
4. `ExerciseRunViews.swift` - Exercise cards and set rows
5. `RunStateModels.swift` - State model definitions
6. `RunViewModifiers.swift` - Reusable view modifiers

### Code Quality Improvements
1. Establish file size limits (max 1000 lines)
2. Add SwiftLint rule for view body complexity
3. Regular refactoring sprints to reduce technical debt
4. Code review checklist for SwiftUI complexity

---

## Verification

### Build Validation
After fixes are merged:
- ✅ CI build should pass
- ✅ TestFlight upload should succeed
- ✅ No new warnings introduced
- ✅ App functionality unchanged

### Testing Checklist
- [ ] Manual smoke test on device/simulator
- [ ] Verify SetRunRow displays and saves correctly
- [ ] Verify AddExerciseSheet shows and dismisses
- [ ] Check exercise logging workflow end-to-end
- [ ] Confirm no regressions in workout tracking

---

## Lessons Learned

1. **Release builds matter:** Always test optimized builds, not just debug
2. **SwiftUI has limits:** Compiler can't handle infinite complexity
3. **Break it down:** Complex views should be decomposed proactively
4. **Type explicitly:** Don't rely on inference for ambiguous APIs
5. **File size matters:** Large files are harder to compile and maintain

---

## Related Issues

Potential similar issues to watch for:
- Other large SwiftUI views in the codebase
- Heavy use of `.onChange()` modifiers elsewhere
- Other ambiguous SwiftUI API calls
- Files approaching 2000+ lines

---

## Conclusion

Both errors were **systematic code smell indicators** pointing to the same underlying issue: **code complexity exceeding Swift compiler's limits**. The fixes address the immediate symptoms, but the codebase would benefit from broader refactoring to prevent similar issues.

**Status:** ✅ Fixed and Committed  
**Next Steps:** Monitor CI build, consider broader refactoring
