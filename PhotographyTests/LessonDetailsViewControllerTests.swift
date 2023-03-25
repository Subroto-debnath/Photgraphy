//
//  LessonDetailsViewControllerTests.swift
//  PhotographyTests
//
//  Created by Subroto Debnath on 2023-03-25.
//

import XCTest
@testable import Photography

class LessonDetailsViewControllerTests: XCTestCase {

    var sut: LessonDetailsViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = LessonDetailsViewController()
        sut.lesson = Lesson(id: 1, name: "Test Lesson", description: "A lesson for testing",thumbnail: "Simple_thumbnail", video_url: "https://photography.com/test.mp4")
        sut.lessons = [sut.lesson!]
        sut.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testHasTitleLabel() {
        XCTAssertNotNil(sut.view.subviews.first(where: { $0 is UILabel }))
    }

    func testHasDescriptionLabel() {
        XCTAssertNotNil(sut.view.subviews.last(where: { $0 is UILabel }))
    }

    func testHasDownloadButton() {
        XCTAssertNotNil(sut.navigationItem.rightBarButtonItem)
    }

    func testDownloadButtonTappedStartsDownloadTask() {
        sut.downloadButtonTapped()
        XCTAssertNotNil(sut.downloadTask)
    }

    func testLocalVideoFileURLReturnsNilWhenVideoFileNotDownloaded() {
        let videoURLString = "https://embed-ssl.wistia.com/deliveries/f2cd208ce7fddf0c0ea886a8f1d0eabf26271816/2rya8a2tcw.mp4"
        let videoFileName = (videoURLString as NSString).lastPathComponent
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videoFileURL = documentDirectory.appendingPathComponent(videoFileName)
        XCTAssertFalse(fileManager.fileExists(atPath: videoFileURL.path))
        XCTAssertNil(sut.localVideoFileURL())
    }

    func testLocalVideoFileURLReturnsValidURLWhenVideoFileDownloaded() {
        let videoURLString = "https://example.com/test.mp4"
        let videoFileName = (videoURLString as NSString).lastPathComponent
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videoFileURL = documentDirectory.appendingPathComponent(videoFileName)
        try! "Test data".write(to: videoFileURL, atomically: true, encoding: .utf8)
        XCTAssertTrue(fileManager.fileExists(atPath: videoFileURL.path))
        XCTAssertEqual(sut.localVideoFileURL(), videoFileURL)
        try! fileManager.removeItem(at: videoFileURL)
    }
    func testIsVideoFileDownloadedReturnsFalseWhenVideoFileNotDownloaded() {
            let videoURLString = "https://example.com/test.mp4"
            let videoFileName = (videoURLString as NSString).lastPathComponent
            XCTAssertFalse(sut.isVideoFileDownloaded(videoFileName: videoFileName))
        }

}


