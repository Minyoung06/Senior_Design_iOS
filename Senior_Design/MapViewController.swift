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

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var resultSearchController: UISearchController? = nil
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
    var selectedPin:MKPlacemark? = nil  //cache any incoming placemarks
    
    //var JobItems =  [String]()
    
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
        }
    }

    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }
    
    @objc func getJobAlert() {
        
        let userUID = Auth.auth().currentUser?.uid
        print(userUID ?? String.self) //rJXVDO8azbTd1x1bDszSDBiMFy83
        
        let selectedPin = selectedPin!
        let placemarkName = getPlacemarkName(placemark: selectedPin)
        
//        let jobInfo = getJobInfo()
//        let address = jobInfo.1
//        print(address)

        let myAlert = UIAlertController(title: placemarkName, message: "Address: " + placemarkName, preferredStyle: UIAlertController.Style.alert)
        
        let accept = UIAlertAction(title: "Accept", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
            self.jobAlertAccept()
        })

        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }
        
        myAlert.addAction(accept)
        myAlert.addAction(cancel)
        
        self.present(myAlert, animated:true, completion:nil)
    }
    
//    func getJobInfo() -> [String] {
//        //Retrieve golfClubName, address, date, teeTime, phoneNumber from JobShiftDatabase
//
//        let selectedPin = selectedPin!
//        let placemarkName = getPlacemarkName(placemark: selectedPin)
//
//        //Get specific document from current golfclub pin
//        let docRef = Firestore.firestore()
//           .collection("JobShiftDatabase")
//           .whereField("golfClubName", isEqualTo: placemarkName)
//
//        //Get user information
//        docRef.getDocuments { (querySnapshot, err) in
//            if let err = err {
//                print(err.localizedDescription)
//            } else if querySnapshot!.documents.count != 1 {
//                print("More than one document or none")
//            } else {
//                let document = querySnapshot!.documents.first
//                let dataDescription = document?.data()
//                guard let golfClubName = dataDescription?["golfClubName"] else { return }
//                guard let address = dataDescription?["address"] else { return }
//                guard let date = dataDescription?["date"] else { return }
//                guard let reportTime = dataDescription?["reportTime"] else { return }
//                guard let teeTime = dataDescription?["teeTime"] else { return }
//                guard let phoneNumber = dataDescription?["phoneNumber"] else { return }
//
//                let golfClubAlert = golfClubName as? String ?? ""
//                let addressAlert = address as? String ?? ""
//                let dateAlert = date as? String ?? ""
//                let reportTimeAlert = reportTime as? String ?? ""
//                let teeTimeAlert = teeTime as? String ?? ""
//                let phoneNumberAlert = phoneNumber as? String ?? ""
//
//                self.JobItems.append(contentsOf:[golfClubAlert, addressAlert, dateAlert, reportTimeAlert, teeTimeAlert, phoneNumberAlert])
//                //print(JobItems)
//            }
//        }
//        print(self.JobItems)
//        return(self.JobItems)
//    }
    
    func jobAlertAccept() {
        //Get uid of currently logged in user
        let userUID = Auth.auth().currentUser?.uid as String?
        print(userUID!)
        
        let selectedPin = selectedPin!
        let placemarkName = getPlacemarkName(placemark: selectedPin)
        
        //Write this uid into the "caddie" field of the correct golf club name in JobShiftDatabase
        let docRef = Firestore.firestore()
           .collection("JobShiftDatabase")
           .whereField("golfClubName", isEqualTo: placemarkName)

        docRef.getDocuments { snapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else if snapshot?.documents.count != 1{
                print("More than one document or none")
            }
            else {
                for document in snapshot!.documents {
                    document.reference.updateData(["caddie": userUID!])
                    print("Document successfully written!")
                }
            }
        }
    }
    
    func getPlacemarkName(placemark:MKPlacemark) -> String{
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name //Eisenhower Park Golf Course
        let placemarkName = placemark.name
        print(placemarkName!)
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
        button.addTarget(self, action: #selector(getJobAlert), for:.touchUpInside)
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
