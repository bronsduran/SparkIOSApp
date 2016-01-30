//
//  SPCreateAccountViewController.swift
//  Spark1.0
//
//  Created by Nathan Eidelson on 1/19/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SPCreateAccountViewController: UIViewController {
    

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBAction func createAccount(sender: UIButton) {
        let firstName = self.firstNameField.text
        let lastName = self.lastNameField.text
        let password = self.passwordField.text
        let confirmPassword = self.confirmPasswordField.text
        let email = self.emailField.text
        
        if firstName == "" || lastName == "" || email == "" || password == "" {
            UIAlertView(title: "Incomplete Sign-Up", message: "Make sure to fill in all fields.",
                delegate: nil, cancelButtonTitle: "Okay").show()
            return
        }
        
        if (confirmPassword != password) {
            UIAlertView(title: "Passwords Do Not Match", message: "Please re-confirm your password.",
                delegate: nil, cancelButtonTitle: "Okay").show()
            return
        }
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        User.register(email!, password: password!, firstName: firstName!, lastName: lastName!) { (user) -> Void in
            
            if user != nil {
                user.save(nil)
                UIAlertView(title: "Account Successfully Created", message: "Please Login With Your New Username and Password.",
                    delegate: nil, cancelButtonTitle: "Okay").show()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            self.activityIndicator.hidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        activityIndicator.hidden = true
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Login_Background")!)
        self.addBackgroundView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnToLogin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

