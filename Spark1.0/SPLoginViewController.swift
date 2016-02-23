//
//  ViewController.swift
//  Spark1.0
//
//  Created by Bronson Duran on 1/16/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import UIKit
import Parse

class SPLoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapper = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper)
        
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        addBackgroundView()
        activityIndicator.hidden = true
        
        emailField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])

    }
    
    func handleSingleTap(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    @IBAction func loginPressed(sender: AnyObject) {
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        // For testing only
        if (emailField.text == nil || passwordField.text == nil ||
            emailField.text == "" || passwordField.text == "") {
            emailField.text = "dev@stanford.edu"
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
            
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
        }

        // For logout: http://stackoverflow.com/questions/19962276/best-practices-for-storyboard-login-screen-handling-clearing-of-data-upon-logou
    }
    
    
    @IBAction func signUpPressed(sender: UIButton) {
    
    }


}

