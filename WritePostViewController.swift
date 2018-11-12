//
//  WritePostViewController.swift
//  Line Version 1
//
//  Created by Mauricio Figueiredo Mattos Costa on 10/11/18.
//  Copyright © 2018 Mauricio Figueiredo. All rights reserved.
//

import UIKit
import Firebase

class WritePostViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func handleCancelButton(_ sender: Any) {
        // Handles the cancel button.
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func handlePostButton(_ sender: Any) {
        // Handles the post button.
        
        guard let userProfile = UserService.currentUserProfile else { return }
        
        let postRef = Database.database().reference().child("posts").childByAutoId()
        
        let postObject = [
            "author": [
                "uid": userProfile.uid,
                "username": userProfile.username,
                "photoURL": userProfile.photoURL.absoluteString
            ],
            "text": textView.text,
            "timestamp": [".sv":"timestamp"] // Firebase Unix timecode value.
            ] as [String:Any]
        
        postRef.setValue(postObject) { (error, dbRef) in
            if error == nil {
                self.dismiss(animated: true, completion: nil)
            }else {
                // Handle the error.
                print("Error posting.")
            }
        }
    }
}
