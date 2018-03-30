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
    var altitudeOffset: Double?
    
    init(location: CLLocationCoordinate2D) {
        self.location = location
    }
    
    init(altitudeOffset: Double) {
        self.altitudeOffset = altitudeOffset
    }
    
    init(location: CLLocationCoordinate2D, altitudeOffset: Double) {
        self.location = location
        self.altitudeOffset = altitudeOffset
    }
    
    func save() {
        let db = UserDefaults.standard
        if let location = self.location, let altitudeOffset = self.altitudeOffset {
            db.set(location.latitude.description, forKey: "pin_latitude")
            db.set(location.longitude.description, forKey: "pin_longitude")
            db.set(altitudeOffset.description, forKey: "pin_altitude_offset")
        } else if let location = self.location {
            db.set(location.latitude.description, forKey: "pin_latitude")
            db.set(location.longitude.description, forKey: "pin_longitude")
        } else if let altitudeOffset = self.altitudeOffset {
            if db.string(forKey: "pin_altitude_offset") == "0.0" {
                db.set(altitudeOffset.description, forKey: "pin_altitude_offset")
            }
        }
        
        
    }
    
    static func load() -> PinLocation? {
        let db = UserDefaults.standard
        let latitude: String?
        let longitude: String?
        var altitudeOffset: String?
        
        latitude = db.string(forKey: "pin_latitude")
        longitude = db.string(forKey: "pin_longitude")
        altitudeOffset = db.string(forKey: "pin_altitude_offset")
        
        if latitude == nil || longitude == nil {
            return nil;
        }
        
        if altitudeOffset == nil {
            altitudeOffset = "0.0"
        }
        
        let location = CLLocationCoordinate2D(latitude: Double(latitude!) ?? 0.0 , longitude: Double(longitude!) ?? 0.0)
        let realAltitudeOffset = Double(altitudeOffset!) ?? 0.0
        return PinLocation(location: location, altitudeOffset: realAltitudeOffset)
    }
}
