//
//  SegmentVideoUrlsDecoderTests.swift
//  Savage By Design
//
//  Tests to verify that both videoUrl (String) and videoUrls ([String]) are properly decoded
//

import XCTest
@testable import Savage_By_Design

final class SegmentVideoUrlsDecoderTests: XCTestCase {
    
    /// Test that the segment_video_urls_decoder_test.json parses correctly
    /// and validates that both videoUrl and videoUrls formats are normalized to array
    func testSegmentVideoUrlsDecoding() throws {
        let url = Bundle.main.url(forResource: "segment_video_urls_decoder_test", withExtension: "json")!
        let data = try Data(contentsOf: url)
        
        let block = try BlockGenerator.importBlock(from: data)
        
        XCTAssertEqual(block.days.count, 1, "Should have 1 day")
        
        guard let day = block.days.first else {
            XCTFail("No day found")
            return
        }
        
        XCTAssertEqual(day.segments?.count, 4, "Should have 4 segments")
        
        guard let segments = day.segments, segments.count == 4 else {
            XCTFail("Expected 4 segments")
            return
        }
        
        // Segment 1: singular videoUrl should be decoded as array with 1 element
        let segment1 = segments[0]
        XCTAssertEqual(segment1.name, "Segment with singular videoUrl (legacy format)")
        XCTAssertNotNil(segment1.media)
        XCTAssertNotNil(segment1.media?.videoUrls)
        XCTAssertEqual(segment1.media?.videoUrls?.count, 1)
        XCTAssertEqual(segment1.media?.videoUrls?.first, "https://youtube.com/watch?v=legacy-single-video")
        
        // Segment 2: plural videoUrls should be decoded as array with multiple elements
        let segment2 = segments[1]
        XCTAssertEqual(segment2.name, "Segment with plural videoUrls (correct format)")
        XCTAssertNotNil(segment2.media)
        XCTAssertNotNil(segment2.media?.videoUrls)
        XCTAssertEqual(segment2.media?.videoUrls?.count, 3)
        XCTAssertEqual(segment2.media?.videoUrls?[0], "https://youtube.com/watch?v=video1")
        XCTAssertEqual(segment2.media?.videoUrls?[1], "https://youtube.com/watch?v=video2")
        XCTAssertEqual(segment2.media?.videoUrls?[2], "https://youtube.com/watch?v=video3")
        
        // Segment 3: no media should result in nil
        let segment3 = segments[2]
        XCTAssertEqual(segment3.name, "Segment with no video URLs")
        XCTAssertNil(segment3.media)
        
        // Segment 4: empty videoUrl string should result in nil
        let segment4 = segments[3]
        XCTAssertEqual(segment4.name, "Segment with empty videoUrl")
        XCTAssertNotNil(segment4.media)
        XCTAssertNil(segment4.media?.videoUrls)
    }
    
    /// Test UnifiedSegment normalization from Model.Segment
    func testUnifiedSegmentVideoUrlsNormalization() throws {
        // Create a segment with media containing video URLs
        let media = Media(
            videoUrls: ["https://youtube.com/watch?v=test1", "https://youtube.com/watch?v=test2"],
            imageUrl: nil,
            diagramAssetId: nil,
            coachNotesMarkdown: nil
        )
        
        let segment = Segment(
            name: "Test Segment",
            segmentType: .technique,
            media: media
        )
        
        let block = Block(
            name: "Test Block",
            numberOfWeeks: 1,
            days: [
                DayTemplate(
                    name: "Test Day",
                    segments: [segment]
                )
            ]
        )
        
        let unifiedBlock = BlockNormalizer.normalizeBlock(block)
        
        XCTAssertEqual(unifiedBlock.weeks.count, 1)
        XCTAssertEqual(unifiedBlock.weeks[0].count, 1)
        
        let unifiedDay = unifiedBlock.weeks[0][0]
        XCTAssertEqual(unifiedDay.segments.count, 1)
        
        let unifiedSegment = unifiedDay.segments[0]
        XCTAssertNotNil(unifiedSegment.mediaVideoUrls)
        XCTAssertEqual(unifiedSegment.mediaVideoUrls?.count, 2)
        XCTAssertEqual(unifiedSegment.mediaVideoUrls?[0], "https://youtube.com/watch?v=test1")
        XCTAssertEqual(unifiedSegment.mediaVideoUrls?[1], "https://youtube.com/watch?v=test2")
    }
    
    /// Test that existing test file with singular videoUrl still works
    func testBackwardsCompatibilityWithSingularVideoUrl() throws {
        let url = Bundle.main.url(forResource: "segment_all_fields_test", withExtension: "json")!
        let data = try Data(contentsOf: url)
        
        let block = try BlockGenerator.importBlock(from: data)
        
        XCTAssertEqual(block.days.count, 1, "Should have 1 day")
        
        guard let day = block.days.first,
              let segments = day.segments else {
            XCTFail("No segments found")
            return
        }
        
        // Find segments with media.videoUrl
        let segmentsWithVideo = segments.filter { $0.media?.videoUrls != nil }
        
        XCTAssertGreaterThan(segmentsWithVideo.count, 0, "Should have at least one segment with video")
        
        // Verify each video URL was converted to array format
        for segment in segmentsWithVideo {
            XCTAssertNotNil(segment.media?.videoUrls)
            XCTAssertGreaterThan(segment.media?.videoUrls?.count ?? 0, 0)
        }
    }
}
