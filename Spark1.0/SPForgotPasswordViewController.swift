//
//  SPForgotPasswordViewController.swift
//  Spark1.0
//
//  Created by Kevin Khieu on 2/24/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SPForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var forgotPasscodeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapper = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper)
        
        forgotPasscodeButton.backgroundColor = UIColor(red:255/255.0, green:37/255.0, blue:80/255.0,  alpha:1.0)
        activityIndicator.hidden = true
    }
    
    @IBAction func requestPassword(sender: AnyObject) {
        let email = self.emailField.text
        
        if email == "" {
            self.presentAlertWithTitle("Uh oh!", message: "Make sure to enter an e-mail.")
            return
        }
        
        self.resetPassword(email!)
    }
    
    func resetPassword(email : String){
        
        // convert the email string to lower case
        let emailToLowerCase = email.lowercaseString
        // remove any whitespaces before and after the email address
        let emailClean = emailToLowerCase.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        PFUser.requestPasswordResetForEmailInBackground(emailClean) { (success, error) -> Void in
            if (error == nil) {
                let success = UIAlertController(title: "Success", message: "Success! Check your email!", preferredStyle: .Alert)
                success.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(success, animated: false, completion: nil)
                
            }else {
                let error = UIAlertController(title: "Error sending password reset request.", message: "Please verify your e-mail is correct.", preferredStyle: .Alert)

                error.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(error, animated: false, completion: nil)
            }
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
    
    func handleSingleTap(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func returnToLogin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

