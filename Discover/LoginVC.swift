//
//  LoginVC.swift
//  Discover
//
//  Created by Trevor Rose on 7/20/17.
//  Copyright © 2017 Trevor Rose. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailBox.delegate = self
        self.passwordBox.delegate = self
    }
    @IBAction func signInTapped(_ sender: Any) {
        if let email = emailBox.text, let password = passwordBox.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    print("You were unable to sign in")
                } else {
                    print("You were able to sign in")
                    self.performSegue(withIdentifier: "main", sender: nil)
                }
            })
        }
    }
    @IBAction func signUp(_ sender: Any) {
        self.performSegue(withIdentifier: "register", sender: nil)
    }
}
