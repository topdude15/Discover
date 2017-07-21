//
//  SignUpVC.swift
//  Discover
//
//  Created by Trevor Rose on 7/20/17.
//  Copyright © 2017 Trevor Rose. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {

    @IBOutlet weak var usernameBox: UITextField!
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var repeatPasswordBox: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func signUpTapped(_ sender: Any) {
        if let username = usernameBox.text, let email = emailBox.text, let password = passwordBox.text, let repeatPassword = repeatPasswordBox.text {
            if (password != repeatPassword) {
                print("Password is not the same")
            } else {
                Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                    if (error != nil) {
                        print("Error creating user")
                    } else {
                        let uid = Auth.auth().currentUser?.uid
                        let userData: Dictionary<String, AnyObject> = [
                            "username": username as AnyObject,
                            "email": email as AnyObject
                        ]
                        Database.database().reference().child(uid!).updateChildValues(userData)
                        
                        print("User created and updated with correct data")
                        
                        self.performSegue(withIdentifier: "main", sender: nil)
                    }
                })
            }
        }
    }
}
