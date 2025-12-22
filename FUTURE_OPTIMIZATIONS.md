# Future Optimization Opportunities

This document tracks potential optimizations identified during code review that could be implemented if performance or maintainability becomes an issue.

## Performance Optimizations

### 1. Metrics Calculation Caching
**File:** `BlockMetrics.swift`, line 42
**Issue:** Metrics are calculated on-demand for every block in the view.
**Impact:** Minimal for <100 blocks with typical session datasets
**Optimization:** 
- Add computed property caching in BlocksRepository
- Use `@State` or `@ObservedObject` to cache calculated metrics
- Invalidate cache when sessions are updated
**Priority:** Low (implement only if users report performance issues)

### 2. Active Block Toggle Optimization
**File:** `Repositories.swift`, lines 103-105
**Issue:** Loops through all blocks to deactivate when setting active block.
**Impact:** Minimal for <100 blocks
**Optimization:**
- Track currently active block ID in repository
- Only deactivate the specific active block
- Update tracked ID when new block is activated
**Priority:** Low (O(n) is acceptable for expected block counts)

## Code Quality Improvements

### 3. Extract Toggle Logic to Method
**File:** `BlocksListView.swift`, lines 158-162
**Issue:** Toggle logic inline in view body
**Suggested Refactor:**
```swift
private func toggleBlockActive(_ block: Block) {
    if block.isActive {
        blocksRepository.clearActiveBlock()
    } else {
        blocksRepository.setActive(block)
    }
}
```
**Priority:** Low (current implementation is clear and maintainable)

### 4. Volume Display Logic Extraction
**File:** `BlockSummaryCard.swift`, line 70
**Issue:** Inline condition for showing volume metric
**Suggested Refactor:**
```swift
private var shouldShowVolume: Bool {
    metrics.plannedVolume > 0
}
```
**Priority:** Very Low (condition is simple and clear)

## Implementation Guidelines

When implementing these optimizations:

1. **Measure First:** Only optimize if there's actual performance degradation
2. **Maintain Tests:** Ensure all existing tests pass after optimization
3. **Preserve API:** Keep public interfaces unchanged
4. **Document Changes:** Update relevant documentation
5. **Benchmark:** Compare before/after performance metrics

## Performance Thresholds

Consider implementing optimizations when:
- User has > 100 blocks in their library
- Metrics calculation takes > 100ms
- UI frame rate drops below 60fps
- User feedback indicates performance issues

## Current Performance Profile

Based on current implementation:
- **Block count:** Expected < 100 (typical user has 5-20 active blocks)
- **Sessions per block:** Expected < 100 (4-12 weeks × 3-6 days/week)
- **Metrics calculation:** O(n) where n = total sets across all sessions
- **Active toggle:** O(n) where n = total blocks
- **Expected overhead:** < 10ms on modern iOS devices

## Recommendation

**Do not implement these optimizations immediately.** The current implementation is:
- Clear and maintainable
- Performant for expected usage patterns
- Easy to optimize later if needed
- Following SwiftUI best practices for view updates

Monitor performance in production and implement optimizations only when data shows they're necessary.
