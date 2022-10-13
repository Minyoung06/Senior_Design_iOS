//
//  UserProfileViewController.swift
//  Senior_Design
//
//  Created by Cynthia Zhao on 2022-10-09.
//

import UIKit

class UserProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CircularImage.layer.masksToBounds = true
        CircularImage.layer.cornerRadius = CircularImage.bounds.width / 2
    }
    
    
    @IBOutlet weak var CircularImage: UIImageView!
    
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

