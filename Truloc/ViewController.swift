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

    var locationManager: CLLocationManager!
    var currentCoordinates: CLLocationCoordinate2D?
    var altitude: Double?
    var savedLocation: PinLocation?
    var pinAnnotation: MKPointAnnotation?
    var currentLocationAnnotation: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pinloc: PinLocation? = PinLocation.load()
        if(pinloc != nil) {
            let location = pinloc?.location
            let subtitle = pinloc?.altitude?.description
            self.pinAnnotation = self.buildAnnotation(location: location!, title: "Pin Drop", subtitle: subtitle)
            self.map.addAnnotation(self.pinAnnotation!)
        }
        self.startTrackingLocation()
    }
    
    @IBAction func dropPinAtCurrentLocation(_ sender: Any) {
        let thisLocation = CLLocation(latitude: self.currentCoordinates!.latitude, longitude: self.currentCoordinates!.longitude)
        let radius: CLLocationDistance = 100
        let region = MKCoordinateRegionMakeWithDistance(thisLocation.coordinate, radius , radius)
 
        if(self.pinAnnotation != nil) {
            self.map.removeAnnotation(self.pinAnnotation!)
        }
        let annotation = self.buildAnnotation(location: self.currentCoordinates!, title: "Pin Drop", subtitle: altitude?.description)
        self.pinAnnotation = annotation
        self.map.setRegion(region, animated: true)
        self.map.addAnnotation(annotation)
        self.saveLocation(location: self.currentCoordinates!, altitude: self.altitude!)
    }
    
    func buildAnnotation(location: CLLocationCoordinate2D, title: String?, subtitle: String?) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location;
        annotation.title = title
        annotation.subtitle = subtitle
        return annotation
    }
    
    func saveLocation(location: CLLocationCoordinate2D, altitude: Double) {
        self.savedLocation = PinLocation(location: location, altitude: altitude)
        self.savedLocation!.save()
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
        if(self.currentLocationAnnotation != nil) {
            self.map.removeAnnotation(self.currentLocationAnnotation!)
        }
        let annotation = self.buildAnnotation(location: self.currentCoordinates!, title: "Current Location", subtitle: self.altitude?.description)
        self.currentLocationAnnotation = annotation;
        self.map.addAnnotation(annotation)
        print("\(latitude) \(longitude) \(altitude)")
    }
    
}

