//
//  ViewController.swift
//  Truloc
//
//  Created by Frankie Primerano on 3/18/18.
//  Copyright © 2018 Frankie Primerano. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var distanceFromObject: UILabel!
    @IBOutlet weak var zDirectionOfObject: UILabel! // Up or down
    let altimeter = CMAltimeter()
    var startAltitude : Float?
    var currentAltitude : Float?
    var waited = 0 // Number of tries before recording real values;
    let waitReading = 3 // How many checks to make before recording altitude
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func getAltitude(_ sender: UIButton) {
        self.waited = 0;
        self.startAltitude = 0;
        self.currentAltitude = 0;
        let hasBarometer = CMAltimeter.isRelativeAltitudeAvailable()
        self.distanceFromObject.text = "Getting information..."
        if(hasBarometer) {
            print("Starting Altitude Updates \(hasBarometer)")
            self.altimeter.startRelativeAltitudeUpdates(to: OperationQueue.current!, withHandler: { (altitudeData:CMAltitudeData?, error:Error?) in
                if(self.waited >= self.waitReading) {
                    
                    if(self.startAltitude == nil) {
                        self.startAltitude = altitudeData?.relativeAltitude.floatValue
                    } else {
                        self.currentAltitude = altitudeData?.relativeAltitude.floatValue
                    }
                    if(self.startAltitude != nil && self.currentAltitude != nil) {
                        let sa = self.startAltitude!
                        let ca = self.currentAltitude!
                        let difference = round(sa - ca)
                        print("\(ca) \(sa) \(difference)")
                        if(difference < 0) {
                            self.zDirectionOfObject.text = "Down"
                        } else if(difference > 0){
                            self.zDirectionOfObject.text = "Up"
                        } else {
                            self.zDirectionOfObject.text = "Level"
                        }
                        
                        self.distanceFromObject.text = "\(Int(abs(difference)))m"
                        
                    }
                } else {
                    self.waited = self.waited + 1
                    print("\(self.waited)")
                }
            })
        } else {
            self.distanceFromObject.text = "No Barometer found :/"
        }
    }
    
}

