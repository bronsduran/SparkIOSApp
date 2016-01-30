//
//  User.swift
//  Spark1.0
//
//  Created by Kevin Khieu on 1/30/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation
import UIKit
import Parse

class User {
    static var currentUser: User!
    var objectId: String!
    var userName: String!
    var email: String!
    var emailVerified: Bool = false
    var firstName: String!
    var lastName: String!
    var parse: PFUser!
    var students: NSArray!
    
    convenience init(_ user: PFUser) {
        self.init()
        self.objectId = user.objectId
        self.userName = user.username
        self.email = user.email
        self.firstName = user["firstName"] as? String
        self.lastName = user["lastName"] as? String
        self.parse = user
        self.students = user["students"] as? NSArray
        if let emailVerified = user["emailVerified"] as? Bool {
            self.emailVerified = emailVerified
        }
        User.currentUser = self
        
        // self.updateTracking()
        // self.startup()
    }
    
    class func register(email: String, password: String, firstName: String, lastName: String, callback: (user: User!) -> Void) {
        
        let pfuser = PFUser()
        
        pfuser.email = email
        pfuser.username = email
        pfuser.password = password
        
        pfuser["firstName"] = firstName
        pfuser["lastName"] = lastName
        
        pfuser.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                callback(user: User(pfuser))
            } else {
                callback(user: nil)
            }
        }
    }
    
    
    class func login(email: String, password: String, callback: (user: User!) -> Void) {
        PFUser.logInWithUsernameInBackground(email, password: password) { (pfuser: PFUser?, error: NSError?) -> Void in
            if let user = pfuser {

                callback(user: User(user))
            } else {
                callback(user: nil)
            }
        }
    }
    
    class func forgotPassword(email: String) {
        PFUser.requestPasswordResetForEmailInBackground(email)
    }
    
    class func current() -> User! {
        if let user = User.currentUser {
            return user
        }  else if let pfuser = PFUser.currentUser() {
            do {
                return try User(pfuser.fetch())
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func save(callback: (() -> Void)!) {
        if self.firstName != nil {
            self.parse["firstName"] = self.firstName
        }
        
        if self.lastName != nil {
            self.parse["lastName"] = self.lastName
        }

        if(self.email != nil) {
            self.parse.email = self.email
        }
        
        self.parse.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                callback?()
            } else {
            }
        }
    }
    
    class func logout() {
        PFUser.logOut()
    }
}