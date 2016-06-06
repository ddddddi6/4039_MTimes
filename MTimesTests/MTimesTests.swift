//
//  MTimesTests.swift
//  MTimesTests
//
//  Created by Dee on 27/04/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import XCTest
@testable import MTimes

class MTimesTests: XCTestCase {
    
    var mvc: MovieViewController!
    var ptc: PlayingTableController!
    var mapvc: MapViewController!
    
    override func setUp() {
        super.setUp()
        
        mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MovieViewController") as! MovieViewController
        ptc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlayingTableController") as! PlayingTableController
        mapvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testDownloadPosterFunction() {
        let p = mvc.downloadMovieData("https://api.themoviedb.org/3/movie/1/images?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4", flag: 0)
        XCTAssertTrue(p == true)
    }
    
    func testDownloadSimilarFunction() {
        let p = mvc.downloadMovieData("https://api.themoviedb.org/3/movie/1/similar?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4", flag: 1)
        XCTAssertTrue(p == true)
    }
    
    func testDownloadPlayingFunction() {
        let p = ptc.downloadMovieData()
        XCTAssertTrue(p == true)
    }
    
}
