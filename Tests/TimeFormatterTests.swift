//
//  TimeFormatterTests.swift
//  WorkoutTrackerApp Tests
//
//  Tests for HH:MM:SS time formatting functionality
//

import XCTest

class TimeFormatterTests: XCTestCase {
    
    // MARK: - Seconds to Components Tests
    
    func testSecondsToComponents_OneHourThirtyMinutesFifteenSeconds() {
        // 1:30:15 = 1*3600 + 30*60 + 15 = 3600 + 1800 + 15 = 5415 seconds
        let (hours, minutes, seconds) = TimeFormatter.secondsToComponents(5415)
        
        XCTAssertEqual(hours, 1, "Should be 1 hour")
        XCTAssertEqual(minutes, 30, "Should be 30 minutes")
        XCTAssertEqual(seconds, 15, "Should be 15 seconds")
    }
    
    func testSecondsToComponents_TwentySeconds() {
        // 00:00:20 = 20 seconds
        let (hours, minutes, seconds) = TimeFormatter.secondsToComponents(20)
        
        XCTAssertEqual(hours, 0, "Should be 0 hours")
        XCTAssertEqual(minutes, 0, "Should be 0 minutes")
        XCTAssertEqual(seconds, 20, "Should be 20 seconds")
    }
    
    func testSecondsToComponents_TenSeconds() {
        // 00:00:10 = 10 seconds
        let (hours, minutes, seconds) = TimeFormatter.secondsToComponents(10)
        
        XCTAssertEqual(hours, 0, "Should be 0 hours")
        XCTAssertEqual(minutes, 0, "Should be 0 minutes")
        XCTAssertEqual(seconds, 10, "Should be 10 seconds")
    }
    
    func testSecondsToComponents_OneHour() {
        // 1:00:00 = 3600 seconds
        let (hours, minutes, seconds) = TimeFormatter.secondsToComponents(3600)
        
        XCTAssertEqual(hours, 1, "Should be 1 hour")
        XCTAssertEqual(minutes, 0, "Should be 0 minutes")
        XCTAssertEqual(seconds, 0, "Should be 0 seconds")
    }
    
    // MARK: - Components to Seconds Tests
    
    func testComponentsToSeconds_OneHourThirtyMinutesFifteenSeconds() {
        let totalSeconds = TimeFormatter.componentsToSeconds(hours: 1, minutes: 30, seconds: 15)
        
        XCTAssertEqual(totalSeconds, 5415, "1:30:15 should be 5415 seconds")
    }
    
    func testComponentsToSeconds_TwentySeconds() {
        let totalSeconds = TimeFormatter.componentsToSeconds(hours: 0, minutes: 0, seconds: 20)
        
        XCTAssertEqual(totalSeconds, 20, "00:00:20 should be 20 seconds")
    }
    
    func testComponentsToSeconds_TenSeconds() {
        let totalSeconds = TimeFormatter.componentsToSeconds(hours: 0, minutes: 0, seconds: 10)
        
        XCTAssertEqual(totalSeconds, 10, "00:00:10 should be 10 seconds")
    }
    
    // MARK: - Format Time Tests
    
    func testFormatTime_OneHourThirtyMinutesFifteenSeconds() {
        let formatted = TimeFormatter.formatTime(5415)
        
        XCTAssertEqual(formatted, "1:30:15", "5415 seconds should format as 1:30:15")
    }
    
    func testFormatTime_TwentySeconds() {
        let formatted = TimeFormatter.formatTime(20)
        
        XCTAssertEqual(formatted, "00:00:20", "20 seconds should format as 00:00:20")
    }
    
    func testFormatTime_TenSeconds() {
        let formatted = TimeFormatter.formatTime(10)
        
        XCTAssertEqual(formatted, "00:00:10", "10 seconds should format as 00:00:10")
    }
    
    func testFormatTime_OneHour() {
        let formatted = TimeFormatter.formatTime(3600)
        
        XCTAssertEqual(formatted, "1:00:00", "3600 seconds should format as 1:00:00")
    }
    
    func testFormatTime_NinetySeconds() {
        let formatted = TimeFormatter.formatTime(90)
        
        XCTAssertEqual(formatted, "00:01:30", "90 seconds should format as 00:01:30")
    }
    
    // MARK: - Parse Time Tests
    
    func testParseTime_HHMMSSFormat() {
        let seconds = TimeFormatter.parseTime("1:30:15")
        
        XCTAssertEqual(seconds, 5415, "1:30:15 should parse to 5415 seconds")
    }
    
    func testParseTime_MMSSFormat() {
        let seconds = TimeFormatter.parseTime("01:30")
        
        XCTAssertEqual(seconds, 90, "01:30 should parse to 90 seconds")
    }
    
    func testParseTime_SecondsOnly() {
        let seconds = TimeFormatter.parseTime("90")
        
        XCTAssertEqual(seconds, 90, "90 should parse to 90 seconds")
    }
    
    func testParseTime_TwentySeconds() {
        let seconds = TimeFormatter.parseTime("00:00:20")
        
        XCTAssertEqual(seconds, 20, "00:00:20 should parse to 20 seconds")
    }
    
    func testParseTime_InvalidFormat() {
        let seconds = TimeFormatter.parseTime("invalid")
        
        XCTAssertNil(seconds, "Invalid format should return nil")
    }
    
    // MARK: - Round Trip Tests
    
    func testRoundTrip_FormatAndParse() {
        let originalSeconds = 5415 // 1:30:15
        let formatted = TimeFormatter.formatTime(originalSeconds)
        let parsed = TimeFormatter.parseTime(formatted)
        
        XCTAssertEqual(parsed, originalSeconds, "Format then parse should return original value")
    }
    
    func testRoundTrip_ComponentsConversion() {
        let (h, m, s) = (1, 30, 15)
        let seconds = TimeFormatter.componentsToSeconds(hours: h, minutes: m, seconds: s)
        let (h2, m2, s2) = TimeFormatter.secondsToComponents(seconds)
        
        XCTAssertEqual(h, h2, "Hours should match after round trip")
        XCTAssertEqual(m, m2, "Minutes should match after round trip")
        XCTAssertEqual(s, s2, "Seconds should match after round trip")
    }
}
