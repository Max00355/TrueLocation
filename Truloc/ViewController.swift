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

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!

    @IBOutlet weak var yLabel: UILabel! // Lat
    @IBOutlet weak var xLabel: UILabel! // Lng
    @IBOutlet weak var zLabel: UILabel! // Altitude
    
    var locationManager: CLLocationManager!
    var currentCoordinates: CLLocationCoordinate2D?
    var altitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startTrackingLocation()
    }
    
    @IBAction func getCurrentLocation(_ sender: Any) {
        print("Alt: \(altitude!)")
        yLabel.text = currentCoordinates?.longitude.description
        xLabel.text = currentCoordinates?.latitude.description
        zLabel.text = altitude?.description
    
    }
    
    func startTrackingLocation() {
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
        let longitude = locations.last!.coordinate.longitude // Latitude
        let altitude = locations.last!.altitude // Height above Sea Level
        self.currentCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.altitude = altitude
        print("\(latitude) \(longitude) \(altitude)")
    }
    
}

