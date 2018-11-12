//
//  LogInViewController.swift
//  Line Version 1
//
//  Created by Mauricio Figueiredo Mattos Costa on 08/11/18.
//  Copyright © 2018 Mauricio Figueiredo. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {

        print("Logging in...")
        
        // Handling the state of the continue button and the activity indicator.
        self.enableButton(false)
        
        guard let email = emailTextField.text else {
            print("Error logging in: There's something wrong with the email.")
            return
        }
        guard let password = passwordTextField.text else {
            print("Error logging in: There's something wrong with the password.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if error == nil && user != nil {
                // Success!
                _ = self.navigationController?.popViewController(animated: false)
            }else {
                print("Error logging in: \(error!.localizedDescription).")
                self.resetForm()
            }
        }
        print("Finishing logging in...")
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
