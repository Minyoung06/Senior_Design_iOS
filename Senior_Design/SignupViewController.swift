//
//  SignupViewController.swift
//  Senior_Design
//
//  Created by MinYoung Yang on 4/29/22.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        addressTextField.delegate = self
        phoneNumberTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        errorLabel.isHidden = true
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    func isPasswordValid(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
        return passwordTest.evaluate(with: password)
    }
    
    //Check if all data in fields are correct. If correct, return nil. Else, return error message
    func areEntriesValid() -> String?
    {
        if (nameTextField.text == "" || addressTextField.text == "" || phoneNumberTextField.text == "" || emailTextField.text == "" || passwordTextField.text == "")
        {
            return "Please fill in all the fields."
        }
        
        let password = passwordTextField.text!
        
        //check if password is secure
        if isPasswordValid(password) == false {
            //the password isn't secure
            return "Please make sure that your password is at least 6 characters, contains a special character, and a number."
        }
        return nil
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        
        //validate the fields
        let error = areEntriesValid()
        
        if error != nil {
            showError(error!)
        }
        else {
            
            //get clean versions of the data
            let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let address = addressTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let phoneNumber = phoneNumberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //create the user
            Auth.auth().createUser(withEmail: email, password: password) {result, err in
                //Check for errors
                if err != nil {
                    self.showError("Error creating user")
                }
                else {
                    //User was created successfully, now store the user in database
                    let db = Firestore.firestore()
                    
                    db.collection("CaddieDatabase").addDocument(data: ["caddieName": name, "caddieAddress": address, "caddieEmail": email, "caddiePhone": phoneNumber, "caddiePassword": password, "uid": result!.user.uid]) { (error) in
                        
                        if error != nil {
                            //show error message
                            self.showError("Error in saving user data")
                        }
                        //transition to home screen
                        //self.performSegue(withIdentifier: "signUpSegue", sender: self)
                        //make the tab bar controller the main view controller
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                        
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                        }
                }
            }
        }
    }
    
    func showError(_ message: String) {
        errorLabel.isHidden = false
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    //UITextFieldDelegate
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        addressTextField.resignFirstResponder()
        phoneNumberTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
}

