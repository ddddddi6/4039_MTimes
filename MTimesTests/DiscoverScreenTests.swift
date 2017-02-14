//
//  DiscoverScreenTest.swift
//  MTimes
//
//  Created by Dee on 7/06/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import XCTest
import MapKit
import SwiftyJSON
@testable import MTimes

class DiscoverScreenTest: XCTestCase {
    var avc: AboutViewController!
    var dvc: DiscoverViewController!
    var stc: SearchTableController!

    override func setUp() {
        super.setUp()
        
        avc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        dvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DiscoverViewController") as! DiscoverViewController
        stc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchTableController") as! SearchTableController
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
    
    // solution from: http://jakubturek.pl/blog/2015/03/07/ios-unit-test-recipes-uiviewcontrollers/
    func testAboutButtonTransitionsToAboutScreen() {
        class ViewControllerMock: DiscoverViewController {
            
            var segueIdentifier: NSString?
            
            override func performSegue(withIdentifier identifier: String?, sender: Any?) {
                segueIdentifier = identifier as NSString?
            }
        }
        
        let controller = ViewControllerMock()
        
        controller.displayAboutScreen(nil)
        
        if let identifier = controller.segueIdentifier {
            XCTAssertEqual("AboutSegue", identifier)
        }
        else {
            XCTFail("AboutSegue should be performed")
        }
    }
    
    func testRecommendationButtonTransitionsToPopularMovie() {
        class ViewControllerMock: DiscoverViewController {
            
            var segueIdentifier: NSString?
            
            override func performSegue(withIdentifier identifier: String?, sender: Any?) {
                segueIdentifier = identifier as NSString?
            }
        }
        
        let controller = ViewControllerMock()
        
        controller.displayPopularMovies(nil)
        
        if let identifier = controller.segueIdentifier {
            XCTAssertEqual("PopularSegue", identifier)
        }
        else {
            XCTFail("PopularSegue should be performed")
        }
    }
    
    func testCinemaButtonTransitionsToMapView() {
        class ViewControllerMock: DiscoverViewController {
            
            var segueIdentifier: NSString?
            
            override func performSegue(withIdentifier identifier: String?, sender: Any?) {
                segueIdentifier = identifier as NSString?
            }
        }
        
        let controller = ViewControllerMock()
        
        controller.showMap(nil)
        
        if let identifier = controller.segueIdentifier {
            XCTAssertEqual("ShowMapSegue", identifier)
        }
        else {
            XCTFail("ShowMapSegue should be performed")
        }
    }
    
    func testBookmarkTransitionsToBookmarkView() {
        class ViewControllerMock: DiscoverViewController {
            
            var segueIdentifier: NSString?
            
            override func performSegue(withIdentifier identifier: String?, sender: Any?) {
                segueIdentifier = identifier as NSString?
            }
        }
        
        let controller = ViewControllerMock()
        
        controller.displayBookmark(nil)
        
        if let identifier = controller.segueIdentifier {
            XCTAssertEqual("ShowBookmarkSegue", identifier)
        }
        else {
            XCTFail("ShowBookmarkSegue should be performed")
        }
    }
    
    // solution from: http://jakubturek.pl/blog/2015/03/07/ios-unit-test-recipes-uiviewcontrollers/
    func testMovieTitleToPassIsPassedOnSearchSegue() {
        dvc.movieTitle = "Movie Title"
        let segue = UIStoryboardSegue(identifier: "SearchSegue",
                                      source: dvc,
                                      destination: stc)
        
        dvc.prepare(for: segue, sender: nil)
        
        if let passedArgument = stc.movieTitle {
            XCTAssertEqual("Movie Title", passedArgument)
        }
        else {
            XCTFail("Argument should be passed")
        }
    }
}
