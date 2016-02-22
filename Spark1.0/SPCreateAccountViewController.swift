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
            self.presentAlertWithTitle("Incomplete Sign-Up", message: "Make sure to fill in all fields.")
            return
        }
        
        if (confirmPassword != password) {
            self.presentAlertWithTitle("Passwords Do Not Match", message: "Please re-confirm your password.")
            return
        }
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        User.register(email!, password: password!, firstName: firstName!, lastName: lastName!) { (success) -> Void in
            
            if success {
                self.presentAlertWithTitle("Account Successfully Created", message: "Please Login With Your New Username and Password.")
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            self.activityIndicator.hidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTag: NSInteger = textField.tag + 1;
        
        // Try to find next responder
        if let nextResponder: UIResponder! = textField.superview!.viewWithTag(nextTag){
            nextResponder.becomeFirstResponder()
        }
        else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapper = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper)
        
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        activityIndicator.hidden = true
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Login_Background")!)
        self.addBackgroundView()
        
        
    }
    
    func handleSingleTap(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnToLogin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

