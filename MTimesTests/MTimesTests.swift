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
    
    var mvc: PlayingTableController!
    
    override func setUp() {
        super.setUp()
        
        mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlayingTableController") as! PlayingTableController
    

        //let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        //mvc = storyboard.instantiateInitialViewController() as! MovieViewController
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
    
    func testSearchFunction() {
        let p = mvc.downloadMovieData()
        XCTAssertTrue(p == true, "f")
    }
}
