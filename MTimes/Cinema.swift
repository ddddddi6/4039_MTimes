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
    
    override init()
    {
        self.latitude = 0
        self.longitude = 0
        self.name = "Cinema"
        // Default intialization of each variables
    }
    
    init(latitude: Double, longitude: Double, name: String)
    {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        // Custome initialization of each variables
    }
}
