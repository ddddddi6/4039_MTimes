//
//  MovieDetailTests.swift
//  MTimes
//
//  Created by Dee on 7/06/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import XCTest
import MapKit
import SwiftyJSON
import Foundation
@testable import MTimes

class MovieDetailTests: XCTestCase {

    var mvc: MovieViewController!
    
    override func setUp() {
        super.setUp()
        
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
    
    func testDownloadMovieDetail() {
        let parameters = ["images", "similar", "videos", "reviews"]
        for parameter in parameters {
        let URL = Foundation.URL(string: "https://api.themoviedb.org/3/movie/246655/" + parameter + "?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4")!
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
    }
    
    func testParseMovieImages() {
        let filePath = Bundle.main.path(forResource: "images_response",ofType:"json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        XCTAssertNotNil(mvc.parsePosterJSON(data!))
        XCTAssertNotEqual(mvc.imageSet.count, 0, "Result should be stored")
    }
    
    func testParseSimilarMovies() {
        let filePath = Bundle.main.path(forResource: "similar_response",ofType:"json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        XCTAssertNotNil(mvc.parseSimilarMovieJSON(data!))
        XCTAssertNotEqual(mvc.movieSet.count, 0, "Result should be stored")
    }
    
    func testParseVideo() {
        let filePath = Bundle.main.path(forResource: "video_response",ofType:"json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        XCTAssertNotNil(mvc.parseVideoJSON(data!))
        XCTAssertNotNil(mvc.videoKey)
    }
    
    func testParseMovieReview() {
        let filePath = Bundle.main.path(forResource: "reviews_response",ofType:"json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        XCTAssertNotNil(mvc.parseReviewJSON(data!))
        XCTAssertNotEqual(mvc.reviews.count, 0, "Result should be stored")
    }
    
    // solution from: https://www.raywenderlich.com/101306/unit-testing-tutorial-mocking-objects
    func testMarkMovie() {
        class MockUserDefaults: UserDefaults {
            
            var movieWasChanged = false
            typealias FakeDefaults = Dictionary<String, AnyObject?>
            var data : FakeDefaults?
            
            override func set(_ value: Any?, forKey defaultName: String) {
                if defaultName == "savedMovie" {
                    movieWasChanged = true
                }
            }
        }
        mvc.currentMovie = Movie(id: 1, title: "title", poster: "poster", overview: "overview", popularity: 1, rate: 1, date: Date(), count: 1, backdrop: "backdrop")
        let mockUserDefaults = MockUserDefaults(suiteName: "testing")!
        mvc.myDefaults = mockUserDefaults
        let button = UIButton()
        mvc.button = button
        button.addTarget(mvc, action: #selector(mvc.markMovie(_:)), for: .touchUpInside)
        button.sendActions(for: .touchUpInside)
        
        XCTAssertTrue(mockUserDefaults.movieWasChanged, "Movie value in user defaults should be altered")
    }
}


