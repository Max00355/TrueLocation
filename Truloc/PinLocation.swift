//
//  PinLocation.swift
//  Truloc
//
//  Created by Frankie Primerano on 3/26/18.
//  Copyright © 2018 Frankie Primerano. All rights reserved.
//

import Foundation
import CoreLocation

class PinLocation: NSObject {
    var location: CLLocationCoordinate2D?
    var altitude: Double?
    
    init(location: CLLocationCoordinate2D, altitude: Double) {
        self.location = location
        self.altitude = altitude
    }
}
