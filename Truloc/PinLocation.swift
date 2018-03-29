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
    var floor: Double?
    
    init(location: CLLocationCoordinate2D, altitude: Double, floor: Double) {
        self.location = location
        self.altitude = altitude
        self.floor = floor
    }
    
    func save() {
        let db = UserDefaults.standard
        let latitude: String
        let longitude: String
        let floor: String
        latitude = self.location!.latitude.description
        longitude = self.location!.longitude.description
        floor = self.floor!.description
        db.set(latitude, forKey: "pin_latitude")
        db.set(longitude, forKey: "pin_longitude")
        db.set(self.altitude, forKey: "pin_altitude")
        db.set(floor, forKey: "pin_floor")
    }
    
    static func load() -> PinLocation? {
        let db = UserDefaults.standard
        let latitude: String?
        let longitude: String?
        let altitude: String?
        let floor: String?
        latitude = db.string(forKey: "pin_latitude")
        longitude = db.string(forKey: "pin_longitude")
        altitude = db.string(forKey: "pin_altitude")
        floor = db.string(forKey: "pin_floor")
        if(latitude == nil || longitude == nil || altitude == nil || floor == nil) {
            return nil;
        }
        
        let location = CLLocationCoordinate2D(latitude: Double(latitude!) ?? 0.0 , longitude: Double(longitude!) ?? 0.0)
        let real_altitude = Double(altitude!) ?? 0.0
        let real_floor = Double(floor!) ?? 0.0
        return PinLocation(location: location, altitude: real_altitude, floor: real_floor)
    }
}
