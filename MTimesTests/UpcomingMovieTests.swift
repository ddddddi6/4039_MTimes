//
//  UpcomingMovieTests.swift
//  MTimes
//
//  Created by Dee on 7/06/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import XCTest
import MapKit
import SwiftyJSON
@testable import MTimes

class UpcomingMovieTests: XCTestCase {

    var mvc: MovieViewController!
    var utc: UpcomingTableController!
    
    override func setUp() {
        super.setUp()
        
        utc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("UpcomingTableController") as! UpcomingTableController
        mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MovieViewController") as! MovieViewController
        

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
    
    // Solution from: http://nshipster.com/xctestcase/
    func testDownloadUpcomingMovie() {
        let URL = NSURL(string: utc.url)!
        let expectation = expectationWithDescription("GET \(URL)")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(URL) { data, response, error in
            XCTAssertNotNil(data, "data should not be nil")
            XCTAssertNil(error, "error should be nil")
            
            if let HTTPResponse = response as? NSHTTPURLResponse,
                responseURL = HTTPResponse.URL
            {
                XCTAssertEqual(responseURL.absoluteString, URL.absoluteString, "HTTP response URL should be equal to original URL")
                XCTAssertEqual(HTTPResponse.statusCode, 200, "HTTP response status code should be 200")
            } else {
                XCTFail("Response was not NSHTTPURLResponse")
            }
            expectation.fulfill()
        }
        
        task.resume()
        
        waitForExpectationsWithTimeout(task.originalRequest!.timeoutInterval) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            task.cancel()
        }
    }
    
    func testParseUpcomingMovie() {
        let filePath = NSBundle.mainBundle().pathForResource("playing_response",ofType:"json")
        let data = NSData(contentsOfFile:filePath!)
        XCTAssertNotNil(utc.parseMovieJSON(data!))
        XCTAssertNotEqual(utc.currentMovie.count, 0, "Result should be stored in Movie object")
    }
    
    // solution from: http://jakubturek.pl/blog/2015/03/07/ios-unit-test-recipes-uiviewcontrollers/
    func testMovieToPassIsPassedOnMovieDetailSegue() {
        utc.m = Movie(id: 1, title: "title", poster: "poster", overview: "overview", popularity: 1, rate: 1, date: NSDate(), count: 1, backdrop: "backdrop")
        let segue = UIStoryboardSegue(identifier: "U_ViewMovieSegue",
                                      source: utc,
                                      destination: mvc)
        
        utc.prepareForSegue(segue, sender: nil)
        
        if let passedArgument = mvc.currentMovie {
            XCTAssertEqual(utc.m, passedArgument)
        }
        else {
            XCTFail("Argument should be passed")
        }
    }

}
