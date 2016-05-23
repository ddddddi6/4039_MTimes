//
//  Cinema.swift
//  MTimes
//
//  Created by Dee on 21/05/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class Cinema: NSObject {

    var latitude: Double?
    var longitude: Double?
    var name: String?
    var id: String?
    
    override init()
    {
        self.latitude = 0
        self.longitude = 0
        self.name = "Cinema"
        self.id = "Unknown"
        // Default intialization of each variables
    }
    
    init(latitude: Double, longitude: Double, name: String, id: String)
    {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.id = id
        // Custome initialization of each variables
    }
}
