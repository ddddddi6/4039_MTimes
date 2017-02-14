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
        
        mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        cvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CinemaViewController") as! CinemaViewController
        
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
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // Solution from: http://nshipster.com/xctestcase/
    func testDownloadNearbyCinemas() {
        let URL = Foundation.URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-37.8754877,145.0397223&radius=50000&types=movie_theater&sensor=true&key=AIzaSyBp1FhLFQV2NCcXkMSO4p4lm3vuFD5g8f8")!
        let expectation = self.expectation(description: "GET \(URL)")
        
        let session = URLSession.shared
        let task = session.dataTask(with: URL, completionHandler: { data, response, error in
            XCTAssertNotNil(data, "data should not be nil")
            XCTAssertNil(error, "error should be nil")
            
            if let HTTPResponse = response as? HTTPURLResponse,
                let responseURL = HTTPResponse.url
            {
                XCTAssertEqual(responseURL.absoluteString, URL.absoluteString, "HTTP response URL should be equal to original URL")
                XCTAssertEqual(HTTPResponse.statusCode, 200, "HTTP response status code should be 200")
            } else {
                XCTFail("Response was not NSHTTPURLResponse")
            }
            expectation.fulfill()
        }) 
        
        task.resume()
        
        waitForExpectations(timeout: task.originalRequest!.timeoutInterval) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            task.cancel()
        }
    }
    
    func testParseNearbyCinema() {
        let filePath = Bundle.main.path(forResource: "nearby_cinema",ofType:"json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        XCTAssertNotNil(mvc.parseCinemaJSON(data!))
        XCTAssertNotEqual(mvc.nearbyCinema.count, 0, "Result should be stored in Cinema object")
    }
    
    // solution from: http://jakubturek.pl/blog/2015/03/07/ios-unit-test-recipes-uiviewcontrollers/
    func testCinemaToPassIsPassedOnCinemaDetailSegue() {
        mvc.cinemaID = "ChIJiz5UY85d1moR7LZreJts8fo"
        let segue = UIStoryboardSegue(identifier: "CinemaDetailSegue",
                                      source: mvc,
                                      destination: cvc)
        
        mvc.prepare(for: segue, sender: nil)
        
        if let passedArgument = cvc.currentCinemaID {
            XCTAssertEqual("ChIJiz5UY85d1moR7LZreJts8fo", passedArgument)
        }
        else {
            XCTFail("Argument should be passed")
        }
    }

}
