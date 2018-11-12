//
//  SignUpViewController.swift
//  Line Version 1
//
//  Created by Mauricio Figueiredo Mattos Costa on 08/11/18.
//  Copyright © 2018 Mauricio Figueiredo. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        continueButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        // Image picker initial setup
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        // Profile image tap setup
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
    
    }

    func openImagePicker() {
        // Opens image picker.
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func handleSignUp() {
        // Handles signing up authentication when 'continueButton' is clicked.
        
        // Takes care of the continue button and activity indicator.
        self.enableButton(false)
    
        guard let username = usernameTextField.text else {
            print("Invalid username")
            return
        }
        
        guard let email = emailTextField.text else {
            print("Invalid email address")
            return
        }
        
        guard let password = passwordTextField.text else {
            print("Invalid password address")
            return
        }
        
        guard let profileImage = profileImageView.image else {
            print("Invalid image")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil && user != nil {
                print("Default user created!")
                
                // 1.Uploading the profile image to the Firebase Storage.
                self.uploadProfileImage(profileImage) { url in
                    
                    if url != nil {
                        // Changing the adding request in order to add the username and image url to user profile.
                        print("Successful Step 1: Media uploaded to Firebase Storage")
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = username   // Not really necessary, but okay.
                        changeRequest?.photoURL = url           // Not really necessary, but okay.
                        changeRequest?.commitChanges { error in
                            if error == nil {
                            
                                // 2.Saving the profile data to Firebase database.
                                self.saveProfile(username: username, profileImageURL: url!) { success in
                                    if success {
                                        print("Successful Step 2: User information saved to Firebase Database")
                                        // 3.Dismissing the view.
                                        self.dismiss(animated: true, completion: nil)
                                    }else {
                                        // Error. It could not save new data (username, imageurl) to Firebase Database.
                                        print("Failure Step 2")
                                    }
                                }
                            }
                        }
                    }else {
                        // Error. It could not upload profile image to the Firebase storage.
                        print("Failure Step 1")
                        self.resetForm()
                    }
                }
            }else {
                print("Error creating user: \(error!.localizedDescription)")
                self.resetForm()
            }
        }
    }
    
    func uploadProfileImage(_ image: UIImage, completion: @escaping (_ url: URL?)->()) {
        // Uploads profile image to Firebase Storage.
        
        // Dealing with getting the current user id and creating the reference to the place we will save his/her profile picture.
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("users/\(uid)")
        
        // Transforming our image to the JPEG format.
        guard let imageData = UIImageJPEGRepresentation(image, 0.75) else { return }
        
        // Setting up some metadata
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        // Saving image to the Firebase Storage.
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil {
                // Success.
                storageRef.downloadURL { url, error in
                    if error == nil {
                        completion(url)
                    }else {
                        completion(nil)
                        print("Error 1")
                    }
                }
            }else {
                // Failure.
                completion(nil)
                print("Error 2: \(error?.localizedDescription)")
            }
        }
    }
    
    func saveProfile(username: String, profileImageURL: URL, completion: @escaping (_ success: Bool)->()) {
        // Finally saves data to database.
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/profile/\(uid)")
        
        let userObject = [
                "username": username,
                "photoURL": profileImageURL.absoluteString
        ] as [String:Any]
        
        databaseRef.setValue(userObject) { error, dbRef in
            completion(error==nil)
        }
    }
    
    func resetForm() {
        // Resets logging in form.
        // Showing alert in case of logging error.
        let alert = UIAlertController(title: "Error logging in", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        // Handling the state of the continue button and the activity indicator.
        self.enableButton(true)
    }
    
    func enableButton(_ enable: Bool){
        // Takes care of enabling the button and adjacent actions.
        if enable {
            // Enables button.
            continueButton.alpha = 1
            continueButton.isEnabled = true
            continueButton.setTitle("Continue", for: .normal)
            activityIndicator.stopAnimating()
            
        }else{
            // Disables button.
            continueButton.alpha = 0.5
            continueButton.isEnabled = false
            continueButton.setTitle("", for: .normal)
            activityIndicator.startAnimating()
        }
    }
    
    @IBAction func cancelButtonPushed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // User clicks the 'cancel' button.
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // User chooses an image.
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profileImageView.image = pickedImage
        }else {
            print("There's something wrong with the selected image!")
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
