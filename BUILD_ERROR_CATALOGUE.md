# CI Build Error Catalogue

## Build Information
- **Workflow Run ID:** 20697388157
- **Build Date:** 2026-01-04 18:38:39 UTC
- **Commit SHA:** cf1bac3552d6fbfa1fbb289d8d69e427b7716b5e
- **Branch:** main
- **Xcode Version:** 16.4 (Xcode_16.4.app)
- **SDK:** iPhoneOS18.5.sdk
- **Exit Status:** 65 (Build Failed)

## Summary
The CI build failed with 3 failures during the "Build & Upload to TestFlight" step. The primary issue is a compilation error in `BlockNormalizer.swift` where code attempts to access a non-existent property on the `AuthoringTechnique` struct.

---

## Error 1: Missing `videoUrls` Property on AuthoringTechnique

### Error Details
```
/Users/runner/work/WorkoutTrackerApp/WorkoutTrackerApp/BlockNormalizer.swift:274:33: error: value of type 'AuthoringTechnique' has no member 'videoUrls'
                videoUrls: tech.videoUrls
                           ~~~~ ^~~~~~~~~
```

### Location
- **File:** `BlockNormalizer.swift`
- **Line:** 274
- **Column:** 33

### Root Cause
The code is attempting to map an `AuthoringTechnique` to a `UnifiedTechnique` by accessing the `videoUrls` property. However, `AuthoringTechnique` does not have this field.

**Current AuthoringTechnique Definition (WhiteboardModels.swift):**
```swift
public struct AuthoringTechnique: Codable {
    public var name: String
    public var variant: String?
    public var keyDetails: [String]?
    public var commonErrors: [String]?
    public var counters: [String]?
    public var followUps: [String]?
    // Missing: videoUrls
}
```

**Target UnifiedTechnique Definition (WhiteboardModels.swift):**
```swift
public struct UnifiedTechnique: Codable, Equatable {
    public var name: String
    public var variant: String?
    public var keyDetails: [String]
    public var commonErrors: [String]
    public var counters: [String]
    public var followUps: [String]
    public var videoUrls: [String]?  // This field is required
}
```

**Problematic Code (BlockNormalizer.swift:266-276):**
```swift
let techniques = segment.techniques?.map { tech in
    UnifiedTechnique(
        name: tech.name,
        variant: tech.variant,
        keyDetails: tech.keyDetails ?? [],
        commonErrors: tech.commonErrors ?? [],
        counters: tech.counters ?? [],
        followUps: tech.followUps ?? [],
        videoUrls: tech.videoUrls  // ERROR: AuthoringTechnique has no member 'videoUrls'
    )
} ?? []
```

### Fix
**Option 1: Add videoUrls to AuthoringTechnique (Recommended)**

Add the `videoUrls` field to the `AuthoringTechnique` struct to match the `UnifiedTechnique` structure:

```swift
public struct AuthoringTechnique: Codable {
    public var name: String
    public var variant: String?
    public var keyDetails: [String]?
    public var commonErrors: [String]?
    public var counters: [String]?
    public var followUps: [String]?
    public var videoUrls: [String]?  // ADD THIS FIELD
}
```

**Rationale:** This aligns the data model with the feature that was recently added to display video URLs in the UI. The merge of PR #154 added video URL rendering capabilities, and this field should be part of the authoring schema.

**Option 2: Default to Empty Array**

Alternatively, if `videoUrls` should not be part of the authoring schema, provide a default empty array:

```swift
let techniques = segment.techniques?.map { tech in
    UnifiedTechnique(
        name: tech.name,
        variant: tech.variant,
        keyDetails: tech.keyDetails ?? [],
        commonErrors: tech.commonErrors ?? [],
        counters: tech.counters ?? [],
        followUps: tech.followUps ?? [],
        videoUrls: nil  // or [] for empty array
    )
} ?? []
```

**Rationale:** This would work if video URLs are only added at a different stage of the data flow and not during authoring.

### Impact
- **Severity:** HIGH - Blocks all builds
- **Affected Components:**
  - Block normalization and import functionality
  - Whiteboard data transformations
  - Any code path that converts `AuthoringTechnique` to `UnifiedTechnique`

---

## Warning 1: Build Phase Output Dependencies

### Warning Details
```
warning: Run script build phase 'Embed Git Branch' will be run during every build because it does not specify any outputs. To address this issue, either add output dependencies to the script phase, or configure it to run in every build by unchecking "Based on dependency analysis" in the script phase. (in target 'WorkoutTrackerApp' from project 'WorkoutTrackerApp')
```

### Location
- **Build Phase:** "Embed Git Branch"
- **Target:** WorkoutTrackerApp

### Root Cause
The build script phase does not declare output dependencies, causing Xcode to re-run it on every build even when not necessary. This impacts build performance.

### Fix
**Option 1: Add Output Files to the Build Phase**

In the Xcode project configuration for the "Embed Git Branch" script phase, add output files that the script generates. This allows Xcode to use dependency analysis.

**Option 2: Disable Dependency Analysis**

If the script should run on every build, uncheck "Based on dependency analysis" in the script phase settings.

**Option 3: Remove or Modify the Script**

Since the project is using XcodeGen (project.yml), check the project.yml configuration:

```yaml
# In project.yml, look for:
scripts:
  - name: Embed Git Branch
    script: |
      # script content
    outputFiles:  # Add this if script generates files
      - "$(DERIVED_FILE_DIR)/GitInfo.swift"
```

### Impact
- **Severity:** LOW - Performance warning, does not block builds
- **Affected Components:**
  - Build performance
  - CI/CD pipeline execution time

---

## Additional Context

### Related Merge
The build failure occurred immediately after merging PR #154 (`copilot/render-video-urls-ui`), which added video URL rendering capabilities to the UI. The PR likely:
1. Added `videoUrls` field to `UnifiedTechnique`
2. Added UI components to display video URLs
3. Updated existing code to use the new field

However, the PR did not update the `AuthoringTechnique` struct, creating an inconsistency in the data model.

### Build Environment
- **Platform:** macOS (GitHub Actions macos-latest)
- **Swift Version:** 5
- **Build Tool:** xcodebuild via Fastlane gym
- **Optimization:** -O (whole-module-optimization)

---

## Recommended Actions

1. **Immediate:** Add `videoUrls: [String]?` field to `AuthoringTechnique` struct in `WhiteboardModels.swift`
2. **Follow-up:** Review all usages of `AuthoringTechnique` to ensure proper handling of the new field
3. **Testing:** Verify that whiteboard import/export functionality works with the updated schema
4. **Documentation:** Update any schema documentation to reflect the new field
5. **Optional:** Address the build phase warning for improved build performance

---

## Verification Steps

After applying fixes:

1. Generate Xcode project: `xcodegen generate`
2. Build locally: `xcodebuild -scheme WorkoutTrackerApp -configuration Release archive`
3. Or use Fastlane: `bundle exec fastlane beta`
4. Verify CI pipeline passes on the next push
5. Test whiteboard functionality with technique video URLs

---

## Files Requiring Changes

### Primary Fix
- `WhiteboardModels.swift` - Add `videoUrls` field to `AuthoringTechnique` struct

### Optional
- `project.yml` - Add output files to "Embed Git Branch" script phase (if it exists there)
