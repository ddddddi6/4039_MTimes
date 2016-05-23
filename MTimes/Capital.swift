//
//  Capital.swift
//  MTimes
//
//  Created by Dee on 23/05/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import MapKit
import UIKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}