//
//  MapViewController.swift
//  Senior_Design
//
//  Created by MinYoung Yang on 5/2/22.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

struct MyPlacemark {
    static var myPlacemark = ""
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var resultSearchController: UISearchController? = nil
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
    var selectedPin:MKPlacemark? = nil  //cache any incoming placemarks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.hidesBackButton = true   //remove back button at nav bar
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest   //accuracy
        locationManager.requestWhenInUseAuthorization() //permission
        locationManager.startUpdatingLocation() //update user's current location
        mapView.showsUserLocation = true
        
        //For locationSearchTable
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search location"
        searchBar.backgroundColor = UIColor.white
        navigationItem.titleView = resultSearchController?.searchBar

        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
        statusBar.backgroundColor = UIColor.white
        UIApplication.shared.keyWindow?.addSubview(statusBar)
        
        self.tabBarController?.tabBar.backgroundColor = UIColor.white
        
        locationSearchTable.mapView = mapView
        
        locationSearchTable.handleMapSearchDelegate = self
        
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()
        }
    }

    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }
    
    @objc func showPopUp() {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUpID") as! PopUpViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
    }
    
    @objc func passPlacemarkName() {
        let selectedPin = selectedPin!
        let placemarkName = getPlacemarkName(placemark: selectedPin)
        MyPlacemark.myPlacemark = placemarkName
        print("passPlacemarkName: \(placemarkName)")
    }
    
    func getPlacemarkName(placemark:MKPlacemark) -> String {
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name //Eisenhower Park Golf Course
        let placemarkName = placemark.name
        return placemarkName!
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint(x: 0,y :0), size: smallSquare))
        button.setBackgroundImage(UIImage(named: "ChecklistIcon"), for: .normal)
        //button.addTarget(self, action: #selector(getJobAlert), for:.touchUpInside)
        button.addTarget(self, action: #selector(passPlacemarkName), for:.touchUpInside)
        button.addTarget(self, action: #selector(showPopUp), for:.touchUpInside)
        print("mapView: \(MyPlacemark.myPlacemark)")
        pinView?.leftCalloutAccessoryView = button

        return pinView
    }

}
extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name //Eisenhower Park Golf Course
        if let city = placemark.locality,
        let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

