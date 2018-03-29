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
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var elevationLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    
    var locationManager: CLLocationManager!
    var currentCoordinates: CLLocationCoordinate2D?
    var altitude: Double?
    var elevation: Double?
    var floor: Double?
    var savedLocation: PinLocation?
    var pinAnnotation: MKPointAnnotation?
    var currentLocationAnnotation: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pinloc: PinLocation? = PinLocation.load()
        if pinloc != nil {
            let location = pinloc?.location
            let subtitle = pinloc?.floor?.rounded().description
            self.pinAnnotation = self.buildAnnotation(location: location!, title: "Pin Drop", subtitle: subtitle)
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
        
        let annotation = self.buildAnnotation(location: self.currentCoordinates!, title: "Pin Drop", subtitle: self.floor?.rounded().description)
        self.pinAnnotation = annotation
        self.mapView.setRegion(region, animated: true)
        self.mapView.addAnnotation(annotation)
        self.saveLocation(location: self.currentCoordinates!, altitude: self.altitude!, floor: self.floor!)
    }
    
    func buildAnnotation(location: CLLocationCoordinate2D, title: String?, subtitle: String?) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location;
        annotation.title = title
        annotation.subtitle = subtitle
        return annotation
    }
    
    func saveLocation(location: CLLocationCoordinate2D, altitude: Double, floor: Double) {
        self.savedLocation = PinLocation(location: location, altitude: altitude, floor: floor)
        self.savedLocation!.save()
    }
    
    func startTrackingLocation() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            print("Started Getting Coordinates")
            self.locationManager.startUpdatingLocation()
        } else {
            print("Location Services not enabled")
        }
    }

    func getElevation() {
        let latitude = self.currentCoordinates?.latitude.description
        let longitude = self.currentCoordinates?.longitude.description
        if latitude != nil && longitude != nil  {
            let url = "https://api.open-elevation.com/api/v1/lookup?locations=" + latitude! + "," + longitude!
            Alamofire.request(url).responseJSON { response in
                print("ELEVATION")
                if let data = response.result.value {
                    let json = JSON(data)
                    self.elevation = json["results"][0]["elevation"].double
                    self.getFloor()
                }
            }
        }
    }
    
    func getFloor() {
        print("FLOOR")
        if self.altitude != nil && self.elevation != nil {
            print("ALTITUDE: " + self.altitude!.description)
            print("ELEVATION: " + self.elevation!.description)
            self.floor = (self.altitude! - self.elevation!) / 3
            print("Floor: " + self.floor!.description)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latitude = locations.last!.coordinate.latitude
        let longitude = locations.last!.coordinate.longitude // Latitude
        let altitude = locations.last!.altitude // Height above Sea Level
        self.currentCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.altitude = altitude
        self.getElevation()
        if let floor = self.floor {
            self.mapView.userLocation.title = "Floor " + floor.rounded().description
            self.floorLabel.text = "Floor: " + floor.description
        }
        self.altitudeLabel.text = "Altitude: " + altitude.description
        if let elevation = self.elevation {
            self.elevationLabel.text = "Elevation: " + elevation.description
        }
        print("\(latitude) \(longitude) \(altitude)")
    }
    
}

