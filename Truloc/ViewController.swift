//
//  ViewController.swift
//  Truloc
//
//  Created by Frankie Primerano on 3/18/18.
//  Copyright © 2018 Frankie Primerano. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!

    var locationManager: CLLocationManager!
    var altitudeManager: CMAltimeter!
    var relativeAltitude: Float?
    var currentCoordinates: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startGetCoordinates()
        self.startGetRelativeAltitude()
    }
    
    
    func startGetRelativeAltitude() {
        altitudeManager = CMAltimeter()
        if(CMAltimeter.isRelativeAltitudeAvailable()) {
            altitudeManager.startRelativeAltitudeUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
                let relativeAltitude = data?.relativeAltitude.floatValue
                self.relativeAltitude = relativeAltitude
                print(relativeAltitude!)
            })
        }
    }
    
    func startGetCoordinates() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        if(CLLocationManager.locationServicesEnabled()) {
            print("Started Getting Coordinates")
            self.locationManager.startUpdatingLocation()
        } else {
            print("Location Services not enabled")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latitude = locations.last!.coordinate.latitude
        let longitude = locations.last!.coordinate.longitude
        self.currentCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        print("\(latitude) \(longitude)")
    }
    
}

