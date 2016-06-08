//
//  MapViewTests.swift
//  MTimes
//
//  Created by Dee on 8/06/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import XCTest
import MapKit
import SwiftyJSON
@testable import MTimes

class MapViewTests: XCTestCase {
    
    var mvc: MapViewController!
    var cvc: CinemaViewController!

    override func setUp() {
        super.setUp()
        
        mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
        cvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CinemaViewController") as! CinemaViewController
        
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
    func testDownloadNearbyCinemas() {
        let URL = NSURL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-37.8754877,145.0397223&radius=50000&types=movie_theater&sensor=true&key=AIzaSyBp1FhLFQV2NCcXkMSO4p4lm3vuFD5g8f8")!
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
    
    func testParseNearbyCinema() {
        let filePath = NSBundle.mainBundle().pathForResource("nearby_cinema",ofType:"json")
        let data = NSData(contentsOfFile:filePath!)
        XCTAssertNotNil(mvc.parseCinemaJSON(data!))
    }
    
    // solution from: http://jakubturek.pl/blog/2015/03/07/ios-unit-test-recipes-uiviewcontrollers/
    func testCinemaToPassIsPassedOnCinemaDetailSegue() {
        mvc.cinemaID = "ChIJiz5UY85d1moR7LZreJts8fo"
        let segue = UIStoryboardSegue(identifier: "CinemaDetailSegue",
                                      source: mvc,
                                      destination: cvc)
        
        mvc.prepareForSegue(segue, sender: nil)
        
        if let passedArgument = cvc.currentCinemaID {
            XCTAssertEqual("ChIJiz5UY85d1moR7LZreJts8fo", passedArgument)
        }
        else {
            XCTFail("Argument should be passed")
        }
    }

}
