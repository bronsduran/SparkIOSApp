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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapper = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper)
        
        loginButton.backgroundColor = UIColor(red:255/255.0, green:37/255.0, blue:80/255.0,  alpha:1.0)
        addBackgroundView()

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

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        
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
            
           
        }

        // For logout: http://stackoverflow.com/questions/19962276/best-practices-for-storyboard-login-screen-handling-clearing-of-data-upon-logou
    }
    
    
    @IBAction func signUpPressed(sender: UIButton) {
    
    }


}

