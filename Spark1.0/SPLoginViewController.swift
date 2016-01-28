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
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Login_Background")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    
    @IBAction func loginPressed(sender: AnyObject) {
        
        // DO PARSE STUFF
        
        let appDelegate: UIApplicationDelegate! = UIApplication.sharedApplication().delegate
        
        appDelegate!.window!!.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        // For logout: http://stackoverflow.com/questions/19962276/best-practices-for-storyboard-login-screen-handling-clearing-of-data-upon-logou
    }
    
    
    @IBAction func signUpPressed(sender: UIButton) {
    }


}

