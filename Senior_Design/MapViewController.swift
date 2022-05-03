//
//  MapViewController.swift
//  Senior_Design
//
//  Created by MinYoung Yang on 5/2/22.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest   //accuracy
        locationManager.requestWhenInUseAuthorization() //permission
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        
        
    }
}

