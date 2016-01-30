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
    
    @IBOutlet weak var backGround: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        backGround.image = UIImage(named: "Login_Background")
        view.sendSubviewToBack(backGround)
        activityIndicator.hidden = true
        
        // Do not include the below code until we have a way to log out
        /*if let _ = User.current() {
            let appDelegate: UIApplicationDelegate! = UIApplication.sharedApplication().delegate
            
            appDelegate!.window!!.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        } */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    

    @IBAction func loginPressed(sender: AnyObject) {
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        User.login(self.emailField.text!, password: self.passwordField.text!) { (user) -> Void in
            
            if user != nil {
                let appDelegate: UIApplicationDelegate! = UIApplication.sharedApplication().delegate
                
                appDelegate!.window!!.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            } else {
                UIAlertView(title: "Incorrect E-Mail or Password", message: "Please try again.",
                    delegate: nil, cancelButtonTitle: "Okay").show()
            }
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
        }

        // For logout: http://stackoverflow.com/questions/19962276/best-practices-for-storyboard-login-screen-handling-clearing-of-data-upon-logou
    }
    
    
    @IBAction func signUpPressed(sender: UIButton) {
    
    }


}

