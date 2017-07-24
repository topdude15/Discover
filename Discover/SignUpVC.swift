//
//  SignUpVC.swift
//  Discover
//
//  Created by Trevor Rose on 7/20/17.
//  Copyright © 2017 Trevor Rose. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var usernameBox: UITextField!
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var repeatPasswordBox: UITextField!
    @IBOutlet weak var nameBox: UITextField!
    @IBOutlet weak var phoneBox: UITextField!
    @IBOutlet weak var profileImage: CircleImage!
    
    var imageSelected = false
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set delegates on text boxes so Return key will close boxes
        self.usernameBox.delegate = self
        self.emailBox.delegate = self
        self.passwordBox.delegate = self
        self.repeatPasswordBox.delegate = self
        self.nameBox.delegate = self
        self.phoneBox.delegate = self
        
        //Set up image picker for adding a user's profile picture
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        // Do any additional setup after loading the view.
    }
    @IBAction func signUpTapped(_ sender: Any) {
        if (imageSelected == false) {
            print("No image selected")
        } else {
            //Check to make sure all of the data is in the boxes
            if let username = usernameBox.text, let email = emailBox.text, let password = passwordBox.text, let repeatPassword = repeatPasswordBox.text, let name = nameBox.text, let phone = phoneBox.text {
                if (password != repeatPassword) {
                    //Password and Repeat Password boxes are not the same
                    print("Password is not the same")
                } else {
                    //Create the user in the database with the email and password from the boxes
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                        if (error != nil) {
                            //Undefined error creating the account
                            print("Error creating user")
                        } else {
                            //No error creating the account
                            //Set the image to the value of the user image
                            if let image = self.profileImage.image {
                                if let imgData = UIImageJPEGRepresentation(image, 0.2) {
                                    let imgUid = NSUUID().uuidString
                                    let metadata = StorageMetadata()
                                    metadata.contentType = "image/jpeg"
                                    
                                    
                                    //Check if the user exists and that the user is logged in
                                    if let _ = Auth.auth().currentUser {
                                        let uid = Auth.auth().currentUser?.uid
                                        //Upload image to Firebase Storage
                                        Storage.storage().reference().child("profilePics").child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                                            let downloadUrl = metadata?.downloadURL()?.absoluteString
                                            if let link = downloadUrl {
                                                
                                                //Set up user data for uploading to Firebase database
                                                let userData: Dictionary<String, AnyObject> = [
                                                    "username": username as AnyObject,
                                                    "email": email as AnyObject,
                                                    "phone": phone as AnyObject,
                                                    "name": name as AnyObject,
                                                    "profileImage": link as AnyObject
                                                ]
                                                
                                                //Put the user information into the database
                                                Database.database().reference().child("users").child(uid!).updateChildValues(userData)
                                            }
                                            
                                        }
                                    } else {
                                        print("An unknown error has occured.")
                                    }
                                }
                            }
                            //Once the user is created, go to the MapVC
                            self.performSegue(withIdentifier: "main", sender: nil)
                        }
                    })
                }
            }
        }


    }
    @IBAction func profilePicTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImage.image = image
            imageSelected = true
        } else {
            print("Invalid image selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    @IBAction func returnTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "login", sender: nil)
    }
}
