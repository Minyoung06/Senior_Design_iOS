//
//  UserProfileViewController.swift
//  Senior_Design
//
//  Created by Cynthia Zhao on 2022-10-09.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.isHidden = true
        emailLabel.isHidden = true
        addressLabel.isHidden = true
        phoneLabel.isHidden = true
        getCurrentUserData()
    }
    
    func getCurrentUserData() {
         //Get specific document from current user
         let docRef = Firestore.firestore()
            .collection("CaddieDatabase")
            .whereField("uid", isEqualTo: Auth.auth().currentUser?.uid ?? "")

         //Get user information
         docRef.getDocuments { (querySnapshot, err) in
             if let err = err {
                 print(err.localizedDescription)
             } else if querySnapshot!.documents.count != 1 {
                 print("More than one document or none")
             } else {
                 let document = querySnapshot!.documents.first
                 let dataDescription = document?.data()
                 guard let name = dataDescription?["caddieName"] else { return }
                 guard let email = dataDescription?["caddieEmail"] else { return }
                 guard let address = dataDescription?["caddieAddress"] else { return }
                 guard let phone = dataDescription?["caddiePhone"] else { return }
                 
                 self.nameLabel.text = name as? String ?? ""
                 self.emailLabel.text = email as? String ?? ""
                 self.addressLabel.text = address as? String ?? ""
                 self.phoneLabel.text = phone as? String ?? ""
                 
                 self.nameLabel.isHidden = false
                 self.emailLabel.isHidden = false
                 self.addressLabel.isHidden = false
                 self.phoneLabel.isHidden = false
             }
         }
     }

    @IBAction func SignOutBtn(_ sender: Any) {
        
        let myAlert = UIAlertController(title: "Sign Out", message: "Are you sure you would like to sign out?", preferredStyle: UIAlertController.Style.alert)
        
        myAlert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler:
        { (action: UIAlertAction!) in
            //change root view controller to login
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")
                                            
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        }))
        
        myAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(myAlert, animated:true, completion:nil)
    }
    
}
