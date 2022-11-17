//
//  PopUpViewController.swift
//  Senior_Design
//
//  Created by Cynthia Zhao on 2022-11-14.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

class PopUpViewController: UIViewController {
    
    @IBOutlet weak var golfClubNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reportTimeLabel: UILabel!
    @IBOutlet weak var teeTimeLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        getJobInfo()
    }
    
    func getJobInfo() {
        //Retrieve golfClubName, address, date, teeTime, phoneNumber from JobShiftDatabase

        let placemarkName = MyPlacemark.myPlacemark
        print("getJobInfo: \(placemarkName)")
        
        //Get specific document from current golfclub pin
        let docRef = Firestore.firestore()
           .collection("JobShiftDatabase")
           .whereField("golfClubName", isEqualTo: placemarkName)

        //Get user information
        docRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            } else if querySnapshot!.documents.count != 1 {
                print("More than one document or none")
            } else {
                let document = querySnapshot!.documents.first
                let dataDescription = document?.data()
                guard let golfClubName = dataDescription?["golfClubName"] else { return }
                guard let address = dataDescription?["address"] else { return }
                guard let date = dataDescription?["date"] else { return }
                guard let reportTime = dataDescription?["reportTime"] else { return }
                guard let teeTime = dataDescription?["teeTime"] else { return }
                guard let phoneNumber = dataDescription?["phoneNumber"] else { return }
                
                self.golfClubNameLabel.text = golfClubName as? String ?? ""
                self.addressLabel.text = address as? String ?? ""
                self.dateLabel.text = date as? String ?? ""
                self.reportTimeLabel.text = reportTime as? String ?? ""
                self.teeTimeLabel.text = teeTime as? String ?? ""
                self.phoneNumberLabel.text = phoneNumber as? String ?? ""
            }
        }
    }
    
    @IBAction func acceptButton(_ sender: Any) {
        //Get uid of currently logged in user
        let userUID = Auth.auth().currentUser?.uid as String?
        print(userUID!)
        
        let placemarkName = MyPlacemark.myPlacemark
        
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
        
        acceptedJobAlert()
        self.view.removeFromSuperview()
    }
    
    func acceptedJobAlert() {
        let myAlert = UIAlertController(title: "Accepted Job Confirmation", message: "You have successfully signed up for this job.", preferredStyle: UIAlertController.Style.alert)
        
        myAlert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(myAlert, animated:true, completion:nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
}
