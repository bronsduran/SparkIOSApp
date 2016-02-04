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

class User: Equatable {
    static var currentUser: User!
    var objectId: String!
    var userName: String!
    var email: String!
    var emailVerified: Bool = false
    var firstName: String!
    var lastName: String!
    var parse: PFUser!
    var students: [String]!
    var untaggedMoments: [String]!
    var numberUntaggedMoments: Int!
    var classes: [String]!
    

    convenience init(_ user: PFUser) {
        self.init()
        self.objectId = user.objectId
        self.userName = user.username
        self.email = user.email
        self.firstName = user["firstName"] as? String
        self.lastName = user["lastName"] as? String
        self.parse = user
        self.students = user["students"] as? [String]  // Array of ObjectID's
        self.classes = user["classes"] as? [String]     // Array of ObjectID's
        self.untaggedMoments = user["untaggedMoments"] as? [String] // Array of ObjectID's
        if self.untaggedMoments == nil {
            self.untaggedMoments = [String]()
        }
        self.numberUntaggedMoments = self.untaggedMoments.count
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
        pfuser["students"] = []
        
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

        if self.students != nil {
            self.parse["students"] = self.students
        }
        
        if self.classes != nil {
            self.parse["classes"] = self.classes
        }
        
        if(self.email != nil) {
            self.parse.email = self.email
        }
        
        if(self.untaggedMoments != nil) {
            self.parse["untaggedMoments"] = self.untaggedMoments
        }
        
        do {
            try self.parse.save()
        } catch _ {
            print("ERROR SAVING")
        }
    }
    
    func addStudent(child: PFObject) {
        // Add Student Parse Object to Array in Parse
        var array = self.students
        print("ADD STUDENTS")
        print(array)
        if (array == nil) {
            let new_array:NSMutableArray = NSMutableArray()
            print(self.objectId)
            new_array.addObject(child.objectId!)
            self.parse["students"] = new_array
        } else {
            array.append(child.objectId!)
            self.parse["students"] = array
        }
        
        self.students.append(child.objectId!)
        
        // Update number of shares on parse
        
        do {
            try self.parse.save()
        } catch _ {
            print("ERROR SAVING")
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
        
        self.classes.append(newClass.objectId!)
        
        do {
            try self.parse.save()
        } catch _ {
            print("ERROR SAVING")
        }
    }
    
    // Check out SPCaptureView for example of how to use
    func fetchStudents(callback: (foundStudents: [Student]) -> Void) {
        let array = self.students
        var studentArray = [Student]()
        if (array == nil) {
            callback(foundStudents: studentArray)
        } else {
            // print("fetch students")
            for object in array! as [String] {
                // print(object)
                let query = PFQuery(className: "Student")
                let contents:PFObject?
                
                do {
                    contents = try query.getObjectWithId(object)
                    studentArray.append(Student(contents!))
                } catch _ {
                    contents = nil
                }
            }
            callback(foundStudents: studentArray)
        }
    }
    
    func addUntaggedMoment(moment: PFObject) {
        // Add Student Parse Object to Array in Parse
        var array = self.untaggedMoments
        if (array == nil) {
            let new_array:NSMutableArray = NSMutableArray()
            new_array.addObject(moment.objectId!)
            self.parse["untaggedMoments"] = new_array
        } else {
            array.append(moment.objectId!)
            self.parse["untaggedMoments"] = array
        }
        
        self.untaggedMoments.append(moment.objectId!)
        self.numberUntaggedMoments = self.numberUntaggedMoments + 1
        do {
            try self.parse.save()
        } catch _ {
            print("ERROR SAVING")
        }
    }
    
    func getNumberUntaggedMoments() -> Int {
        return self.numberUntaggedMoments
    }
    
    func fetchUntaggedMoments(callback: (foundMoments: [Moment]) -> Void) {
        let array = self.untaggedMoments
        var momentsArray = [Moment]()
        if (array == nil) {
            callback(foundMoments: momentsArray)
        } else {
            for object in array! as [String] {
                let query = PFQuery(className: "Moment")
                let contents:PFObject?
                do {
                    contents = try query.getObjectWithId(object)
                } catch _ {
                    contents = nil
                }
                momentsArray.append(Moment(contents!))
            }
            callback(foundMoments: momentsArray)
        }
    }
    
    func removeUntaggedMoment(object: String) {
        if self.untaggedMoments.contains(object) {
            let elementIndex = self.untaggedMoments.indexOf(object)
            self.untaggedMoments.removeAtIndex(elementIndex!)
            self.numberUntaggedMoments = self.numberUntaggedMoments - 1
        }
    }
    
    
    class func logout() {
        PFUser.logOut()
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.objectId == rhs.objectId
}

