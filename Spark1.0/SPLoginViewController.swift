//
//  ViewController.swift
//  Spark1.0
//
//  Created by Bronson Duran on 1/16/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import UIKit
import Parse

class SPLoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    var keyboardOn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailField.delegate = self
        self.passwordField.delegate = self
        let tapper = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper)
        
        loginButton.backgroundColor = UIColor(red:255/255.0, green:37/255.0, blue:80/255.0,  alpha:1.0)
       
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
    
    func handleSingleTap(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    /* func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }*/
    
    
    
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        // For testing only
        if (emailField.text == nil || passwordField.text == nil ||
            emailField.text == "" || passwordField.text == "") {
            emailField.text = "sparkdev@stanford.edu"
            passwordField.text = "dev"
        }
    
        logo.rotate360Degrees()

        User.login(self.emailField.text!, password: self.passwordField.text!) { (success, user) -> Void in
            
            if success {
                let appDelegate: UIApplicationDelegate! = UIApplication.sharedApplication().delegate
                appDelegate!.window!!.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                
                user?.refreshStudents(nil)
                user?.refreshUntaggedMoments(nil)
                
            } else {
                self.presentAlertWithTitle("Incorrect E-Mail or Password", message: "Please try again.")
            }
        }

        // For logout: http://stackoverflow.com/questions/19962276/best-practices-for-storyboard-login-screen-handling-clearing-of-data-upon-logou
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.emailField {
            self.passwordField.becomeFirstResponder()
            
        } else {
            textField.resignFirstResponder()
            loginPressed(self)
        }

        return true
    }
    
    @IBAction func signUpPressed(sender: UIButton) {
    
    }

    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if (!keyboardOn) {
                self.view.frame.origin.y -= keyboardSize.height
                keyboardOn = true
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
            keyboardOn = false
        }
    }

}

