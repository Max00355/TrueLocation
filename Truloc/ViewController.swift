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

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var altitudeOffsetLabel: UILabel!
    
    let altimeter = CMAltimeter()
    let locationManager = CLLocationManager()

    var currentCoordinates: CLLocationCoordinate2D?
    var altitude: Double? = 0.0
    var altitudeOffset: Double? = 0.0 // Used for when app is closed and restarted
    var savedLocation: PinLocation?
    
    var pinAnnotation: MKPointAnnotation?
    var currentLocationAnnotation: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pinloc: PinLocation? = PinLocation.load()
        if pinloc != nil {
            let location = pinloc?.location
            self.altitudeOffset = pinloc?.altitudeOffset
            
            self.pinAnnotation = self.buildAnnotation(location: location!, title: "Pin Drop", subtitle: "")
            self.mapView.addAnnotation(self.pinAnnotation!)
        }
        self.mapView.showsUserLocation = true
        self.startTrackingLocation()
    }
    
    @IBAction func dropPinAtCurrentLocation(_ sender: Any) {
        let thisLocation = CLLocation(latitude: self.currentCoordinates!.latitude, longitude: self.currentCoordinates!.longitude)
        let radius: CLLocationDistance = 100
        let region = MKCoordinateRegionMakeWithDistance(thisLocation.coordinate, radius , radius)
 
        if self.pinAnnotation != nil {
            self.mapView.removeAnnotation(self.pinAnnotation!)
        }
        
        let annotation = self.buildAnnotation(location: self.currentCoordinates!, title: "Pin Drop", subtitle: "")
        self.pinAnnotation = annotation
        self.mapView.setRegion(region, animated: true)
        self.mapView.addAnnotation(annotation)
        self.altitudeOffset = 0.0
        self.saveLocation()
    }
    
    func buildAnnotation(location: CLLocationCoordinate2D, title: String?, subtitle: String?) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location;
        annotation.title = title
        annotation.subtitle = subtitle
        return annotation
    }
    
    func saveLocation() {
        if let coordinates = self.currentCoordinates {
            self.savedLocation = PinLocation(location: coordinates, altitudeOffset: 0.0)
            self.savedLocation!.save()
        }
    }
    
    func updateAltitudeOffset() { // This is needed because altitude starts from zero after restart
        if let altitude = self.altitude {
            let pinLocObj = PinLocation(altitudeOffset: altitude)
            pinLocObj.save()
        }
    }
    
    func startTrackingLocation() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.relativeAltitudeManager()
        if CLLocationManager.locationServicesEnabled() {
            print("Started Getting Coordinates")
            self.locationManager.startUpdatingLocation()
        } else {
            print("Location Services not enabled")
        }
    }

    func updateFloorDifference() {
        if let relativeAltitude = self.altitude, let altitudeOffset = self.altitudeOffset {
            let floorDifference = ((relativeAltitude + altitudeOffset) / 3).rounded()
            if floorDifference > 0 {
                self.floorLabel.text = floorDifference.description + " Floors Down"
            } else if floorDifference < 0 {
                self.floorLabel.text = abs(floorDifference).description + " Floors Up"
            } else {
                self.floorLabel.text = "This Floor"
            }
            self.altitudeOffsetLabel.text = self.altitudeOffset?.description
        }
    }
    
    func relativeAltitudeManager() { // For getting relative altitude updates
        if CMAltimeter.isRelativeAltitudeAvailable() {
            self.altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler: {
                (data, error) in
                if let altitudeData = data {
                    self.altitude = altitudeData.relativeAltitude.doubleValue
                    self.updateAltitudeOffset()
                    self.updateFloorDifference()
                }
            })
        } else {
            self.altitude = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { // For getting coordinate updates
        let latitude = locations.last!.coordinate.latitude // Longitude
        let longitude = locations.last!.coordinate.longitude // Latitude
        self.currentCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}

