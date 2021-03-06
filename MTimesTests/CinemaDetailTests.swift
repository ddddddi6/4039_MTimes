//
//  CinemaDetailTests.swift
//  MTimes
//
//  Created by Dee on 8/06/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import XCTest
import MapKit
import SwiftyJSON
@testable import MTimes

class CinemaDetailTests: XCTestCase {
    
    var cvc: CinemaViewController!
    var wvc: WebViewController!

    override func setUp() {
        super.setUp()
        
        cvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CinemaViewController") as! CinemaViewController
        wvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        

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
    func testDownloadCinemaInfo() {
        let URL = Foundation.URL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=ChIJiz5UY85d1moR7LZreJts8fo&key=AIzaSyBpHKu9KGpv-VacWvQOhrI7OVjGVdHQY9Y")!
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
    
    func testParseCinemaInfo() {
        let filePath = Bundle.main.path(forResource: "cinema_response",ofType:"json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        XCTAssertNotNil(cvc.parseCinemaJSON(data!))
        XCTAssertNotNil(cvc.cinemaAddress)
        XCTAssertNotNil(cvc.cinemaWeb)
        XCTAssertNotNil(cvc.cinemaPhone)
    }
    
    // solution from: http://jakubturek.pl/blog/2015/03/07/ios-unit-test-recipes-uiviewcontrollers/
    func testMovieToPassIsPassedOnMovieDetailSegue() {
        cvc.link = "http://www.hoyts.com.au/cinemas/locations/highpoint.aspx"
        let segue = UIStoryboardSegue(identifier: "CinemaWebSegue",
                                      source: cvc,
                                      destination: wvc)
        
        cvc.prepare(for: segue, sender: nil)
        
        if let passedArgument = wvc.weblink {
            XCTAssertEqual(cvc.link, passedArgument)
        }
        else {
            XCTFail("Argument should be passed")
        }
    }

}
