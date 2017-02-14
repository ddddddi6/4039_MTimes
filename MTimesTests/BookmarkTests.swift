//
//  BookmarkTests.swift
//  MTimes
//
//  Created by Dee on 8/06/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import XCTest
import MapKit
import SwiftyJSON
@testable import MTimes

class BookmarkTests: XCTestCase {
    
    var mvc: MovieViewController!
    var bvc: BookmarkViewController!

    override func setUp() {
        super.setUp()
        
        bvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BookmarkViewController") as! BookmarkViewController
        mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MovieViewController") as! MovieViewController
        
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
    func testDownloadMarkedMovie() {
        let URL = Foundation.URL(string: "http://api.themoviedb.org/3/movie/246655?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4")!
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
    
    func testParseMarkedMovie() {
        let filePath = Bundle.main.path(forResource: "bookmark_response",ofType:"json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        XCTAssertNotNil(bvc.parseMovieJSON(data!))
        XCTAssertNotEqual(bvc.currentMovie!.count, 0, "Result should be stored in Movie object")
    }
    
    // solution from: http://jakubturek.pl/blog/2015/03/07/ios-unit-test-recipes-uiviewcontrollers/
    func testMovieToPassIsPassedOnMovieDetailSegue() {
        bvc.currentMovie = Movie(id: 1, title: "title", poster: "poster", overview: "overview", popularity: 1, rate: 1, date: Date(), count: 1, backdrop: "backdrop")
        let segue = UIStoryboardSegue(identifier: "B_ViewMovieSegue",
                                      source: bvc,
                                      destination: mvc)
        
        bvc.prepare(for: segue, sender: nil)
        
        if let passedArgument = mvc.currentMovie {
            XCTAssertEqual(bvc.currentMovie, passedArgument)
        }
        else {
            XCTFail("Argument should be passed")
        }
    }

}
