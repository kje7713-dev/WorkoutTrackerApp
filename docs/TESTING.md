# Testing Guide

This document outlines testing practices and guidelines for WorkoutTrackerApp.

## Test Structure

Tests are located in the `Tests/` directory and follow these patterns:

- `*Tests.swift` - Unit tests
- `*Spec.swift` - Specification-style tests

## Running Tests

### In Xcode

1. Open the project: `open WorkoutTrackerApp.xcodeproj`
2. Press `⌘U` to run all tests
3. Or use Product → Test

### From Command Line

```bash
# Generate project first
xcodegen generate

# Run tests
xcodebuild test \
  -project WorkoutTrackerApp.xcodeproj \
  -scheme WorkoutTrackerApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'
```

## Current Test Coverage

### Existing Tests

- **BlockRunModeCompletionTests** - Tests for week/block completion modals
- **BlockHistoryTests** - Tests for block history functionality
- **ExercisePersistenceTests** - Tests for exercise data persistence
- **BlockGeneratorTests** - Tests for AI block generation
- **SetPrefillTests** - Tests for set prefill logic

## Testing Best Practices

### Unit Testing

```swift
import XCTest
@testable import WorkoutTrackerApp

final class MyFeatureTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Set up test fixtures
    }
    
    override func tearDown() {
        // Clean up
        super.tearDown()
    }
    
    func testFeatureBehavior() {
        // Arrange
        let input = createTestInput()
        
        // Act
        let result = performAction(input)
        
        // Assert
        XCTAssertEqual(result.expected, result.actual)
    }
}
```

### Testing Repositories

When testing repositories:
- Use dependency injection
- Mock file system operations
- Test both success and failure paths
- Verify data persistence and retrieval

```swift
func testBlocksRepositorySave() {
    let repo = BlocksRepository(blocks: [])
    let testBlock = createTestBlock()
    
    repo.saveBlock(testBlock)
    
    XCTAssertTrue(repo.blocks.contains { $0.id == testBlock.id })
}
```

### Testing SwiftUI Views

For view testing:
- Focus on view model logic
- Test state changes
- Verify computed properties
- Test user interactions through view models

```swift
func testViewModelStateChange() {
    let viewModel = MyViewModel()
    
    viewModel.performAction()
    
    XCTAssertEqual(viewModel.state, .expected)
}
```

## Test Data

### Creating Test Fixtures

Use helper functions for creating test data:

```swift
func createTestBlock(
    name: String = "Test Block",
    weeks: Int = 4
) -> Block {
    Block(
        id: UUID(),
        name: name,
        weeks: (1...weeks).map { createTestWeek($0) },
        // ...
    )
}
```

### Test Data Location

- Keep test data in test files
- Use `TestData` directory for complex fixtures (if needed)
- Don't commit test data to production code

## Manual Testing

### Device Testing

Test on:
- ✅ iPhone SE (small screen)
- ✅ iPhone 15 (standard)
- ✅ iPhone 15 Pro Max (large)
- ✅ iPad (tablet interface)

### iOS Version Testing

- Minimum: iOS 17.0
- Recommended: Test on latest iOS version

### Feature Testing Checklist

Before release, manually test:

- [ ] **Block Creation**
  - Create new block
  - Add weeks
  - Add day templates
  - Add exercises (strength and conditioning)
  
- [ ] **Workout Session**
  - Start workout
  - Log sets with weight/reps
  - Log conditioning (time/distance/calories)
  - Complete workout
  - Verify data persists
  
- [ ] **Block History**
  - View completed blocks
  - Review past workouts
  - Verify completion badges
  
- [ ] **Exercise Library**
  - Add custom exercise
  - Edit exercise
  - Delete exercise
  - Select from dropdown
  
- [ ] **Data Persistence**
  - Create data
  - Force quit app
  - Reopen app
  - Verify data restored

### Edge Cases

Test these scenarios:
- Empty states (no blocks, no exercises)
- Maximum data (many blocks, large workouts)
- Rapid interactions (double-tap, quick navigation)
- App backgrounding during workout
- Low memory conditions

## Performance Testing

### Areas to Monitor

- App launch time
- Block list scrolling
- Session logging responsiveness
- Data save/load times

### Acceptable Thresholds

- Launch time: < 2 seconds
- List scrolling: 60 FPS
- Data operations: < 500ms

## Integration Testing

Test integration points:
- Repository ↔ File System
- View ↔ Repository
- SessionFactory ↔ Models

## Regression Testing

Before each release:
1. Run full test suite
2. Perform manual feature testing
3. Test critical user paths
4. Verify no existing features broke

## CI Testing

Tests run automatically on:
- Pull requests
- Merge to main branch
- Manual workflow dispatch

See `.github/workflows/ios-testflight.yml` for CI configuration.

## Test Coverage Goals

Target coverage levels:
- **Critical paths**: 90%+
- **Business logic**: 80%+
- **UI code**: 50%+
- **Overall**: 70%+

## Adding New Tests

When adding a new feature:

1. **Write tests first** (TDD approach) or alongside feature
2. **Test happy path** and error cases
3. **Document test purpose** with clear descriptions
4. **Keep tests isolated** and independent
5. **Use descriptive names**: `test_featureName_condition_expectedOutcome`

Example:
```swift
func test_sessionCompletion_whenAllSetsLogged_marksSessionComplete() {
    // Test implementation
}
```

## Debugging Tests

### Xcode Test Navigator

1. Open Test Navigator (⌘6)
2. View all tests
3. Click diamond to run individual test
4. Right-click for more options

### Test Output

- Use `print()` for debugging (only in debug builds)
- Use `XCTAssert` with custom messages
- Check console for `AppLogger` output

### Common Issues

**Test fails intermittently**
- Check for timing issues
- Use expectations for async operations
- Avoid depending on external state

**Test fails in CI but passes locally**
- Check for hardcoded paths
- Verify simulator version matches
- Look for time/date dependencies

## Future Testing Enhancements

Consider adding:
- [ ] UI testing with XCTest UI
- [ ] Snapshot testing for views
- [ ] Performance benchmark tests
- [ ] Accessibility testing
- [ ] Localization testing
- [ ] Network mocking (if API added)

## Resources

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Swift Testing Best Practices](https://developer.apple.com/videos/play/wwdc2018/417/)
- [Testing SwiftUI Apps](https://developer.apple.com/documentation/swiftui/testing-swiftui-apps)

---

Last updated: December 2024
