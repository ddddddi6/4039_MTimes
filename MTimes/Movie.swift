//
//  Movie.swift
//  MTimes
//
//  Created by Dee on 27/04/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class Movie: NSObject {
    var id: Int?
    var title: String?
    var poster: String?
    var overview: String?
    var popularity: Double?
    var rate: Double?
    var date: NSDate?
    var count: Int?
    var backdrop: String?
    var mark: Bool?
    
    override init()
    {
        self.id = -1
        self.title = "Unknown"
        self.poster = "No Poster"
        self.overview = "Unknown"
        self.popularity = 0
        self.rate = 0
        self.date = nil
        self.count = 0
        self.backdrop = "No Image"
        self.mark = false
        // Default intialization of each variables
    }
    
    init(id: Int, title: String, poster: String, overview: String, popularity: Double, rate: Double, date: NSDate, count: Int, backdrop: String, mark: Bool)
    {
        self.id = id
        self.title = title
        self.poster = poster
        self.overview = overview
        self.popularity = popularity
        self.rate = rate
        self.date = date
        self.count = count
        self.backdrop = backdrop
        self.mark = mark
        // Custome initialization of each variables
    }

}
