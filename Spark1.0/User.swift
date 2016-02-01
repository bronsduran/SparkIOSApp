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
    var students: [String]!
    var untaggedMoments: NSMutableArray!
    var classes: NSMutableArray!
    
    convenience init(_ user: PFUser) {
        self.init()
        self.objectId = user.objectId
        self.userName = user.username
        self.email = user.email
        self.firstName = user["firstName"] as? String
        self.lastName = user["lastName"] as? String
        self.parse = user
        self.students = user["students"] as? [String]
        self.classes = user["classes"] as? NSMutableArray
        self.untaggedMoments = user["untaggedMoments"] as? NSMutableArray
        if let emailVerified = user["emailVerified"] as? Bool {
            self.emailVerified = emailVerified
        }
        User.currentUser = self
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
    
    func addStudent(child: PFObject) {
        // Add Student Parse Object to Array in Parse
        let array = self.parse["students"] as? NSMutableArray
        if (array == nil) {
            let new_array:NSMutableArray = NSMutableArray()
            print(self.objectId)
            new_array.addObject(child.objectId!)
            self.parse["students"] = new_array
        } else {
            array!.addObject(child.objectId!)
            self.parse["students"] = array
        }
        
        // Update number of shares on parse
        self.parse.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print("Student Added")
                
            } else {
                print(error)
            }
        }
        
    }
    
    func addClass(newClass: PFObject) {
        // Add Class to list of classes
        let array = self.parse["classes"] as? NSMutableArray
        if (array == nil) {
            let new_array:NSMutableArray = NSMutableArray()
            print(self.objectId)
            new_array.addObject(newClass.objectId!)
            self.parse["classes"] = new_array
        } else {
            array!.addObject(newClass.objectId!)
            self.parse["classes"] = array
        }
        
        // Update number of shares on parse
        self.parse.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print("Class Added")
            } else {
                print(error)
            }
        }
    }
    
    // Check out SPCaptureView for example of how to use
    func fetchStudents(callback: (foundStudents: [Student]) -> Void) {
        let array = self.students
        var studentArray = [Student]()
        if (array == nil) {
            print(self.objectId)
            callback(foundStudents: studentArray)
        } else {
            for object in array! as [String] {
                print(array)
                let query = PFQuery(className: "Student")
                let contents:PFObject?
                
                do {
                    contents = try query.getObjectWithId(object)
                } catch _ {
                    contents = nil
                }
                studentArray.append(Student(contents!))
            }
            callback(foundStudents: studentArray)
        }
    }
    
    class func logout() {
        PFUser.logOut()
    }
}