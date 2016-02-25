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



class User: PFUser {
    
//    static var current: User!
    
//    var userName: String!
//    var email: String!
//    var emailVerified: Bool = false
//    var firstName: String!
//    var lastName: String!
//    var parse: PFUser!
//    var students: [String]!
//    var untaggedMoments: [String]!
//    var numberUntaggedMoments: Int!
//    var classes: [String]!
//

    class func register(email: String, password: String, firstName: String, lastName: String, callback: (success: Bool) -> Void) {
        
        let newUser = User()
        
        newUser.email = email
        newUser.username = email
        newUser.password = password
        
        newUser["firstName"] = firstName
        newUser["lastName"] = lastName
        newUser["students"] = []
        
        newUser.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if error == nil {
                callback(success: true)
            } else {
                print("error signing up:", error)
                callback(success: false)
            }
        }
    }
    
    
    class func login(email: String, password: String, callback: (success: Bool, user: User?) -> Void) {
        
        User.logInWithUsernameInBackground(email, password: password) { (pfuser: PFUser?, error: NSError?) -> Void in
            if error == nil {
                callback(success: true, user: pfuser as? User)
            } else {
                callback(success: false, user: nil)
            }
        }
    }
    
    class func forgotPassword(email: String) {
        PFUser.requestPasswordResetForEmailInBackground(email)
    }
    
    func addStudent(student: PFObject) {
        // Add Student Parse Object to Array in Parse
        let array = self["students"] as? NSMutableArray
        
        print("ADD STUDENTS")
        print(array)
        
        if let students = self["students"] {
            students.addObject(student.objectId!)
            self["students"] = students
        } else {
            self["students"] = [student.objectId!]
        }
        
        // Update number of shares on parse
        
        do {
            try self.save()
        } catch _ {
            print("ERROR SAVING")
        }
    }
    
    func addClass(newClass: PFObject) {
        // Add Class to list of classes
        if let classes = self["classes"] {
            classes.addObject(newClass.objectId!)
            self["classes"] = classes
        } else {
            self["classes"] = [newClass.objectId!]
        }
        
        do {
            try self.save()
        } catch _ {
            print("ERROR SAVING")
        }
    }
    
    func addUntaggedMoment(moment: PFObject) {
        // Add Student Parse Object to Array in Parse
        
        if let untaggedMomentsArray = self["untaggedMoments"] {
            untaggedMomentsArray.addObject(moment.objectId!)
            self["untaggedMoments"] = untaggedMomentsArray
        } else {
            self["untaggedMoments"] = [moment.objectId!]
        }
        
        do {
            try self.save()
        } catch _ {
            print("Error saving after adding untagged moment")
        }
    }
    
    func getNumberUntaggedMoments() -> Int {
        if let untaggedMoments = self["untaggedMoments"] {
            return untaggedMoments.count
        } else {
            return 0
        }
    }
    
    func removeUntaggedMoment(objectId: String) {
        if let untaggedMoments = self["untaggedMoments"] as? NSMutableArray {
            if untaggedMoments.containsObject(objectId) {
                let elementIndex = untaggedMoments.indexOfObject(objectId)
                untaggedMoments.removeObjectAtIndex(elementIndex)
                self["untaggedMoments"] = untaggedMoments
                
                do {
                    try self.save()
                } catch _ {
                    print("Error saving after removing untagged moment")
                }
            }
        }
    }
    
    func students(callback: [Student] -> Void) {
        self.loadObjectIds("students", classname: "Student") { (foundObjects) -> Void in
            callback(foundObjects as! [Student])
        }
    }

    func untaggedMoments(callback: [Moment] -> Void) {
        self.loadObjectIds("untaggedMoments", classname: "Moment") { (foundObjects) -> Void in
            callback(foundObjects as! [Moment])
        }
    }
    
    func refreshUntaggedMoments(callback: ((Bool) -> Void)?) {
        self.fetchObjectIds("untaggedMoments", classname: "Moment") { (foundObjects) -> Void in
            callback?(foundObjects != nil)
        }
    }
    
    func refreshStudents(callback: ((Bool) -> Void)?) {
        self.fetchObjectIds("students", classname: "Student") { (foundObjects) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("studentRefresh", object: nil)
            callback?(foundObjects != nil)
        }
    }
    
    func deleteStudent(student: Student, callback: ((Bool) -> Void)?) {
        let query = PFQuery(className: "Student")
        
        print("@@@@@@@\(student["objectId"])")
        
        query.whereKey("objectId", equalTo: student["objectId"] as! String)
//        query.whereKey("columnName", equalTo)
        query.findObjectsInBackgroundWithBlock({ results in
            if let students = results.0 {
                for student in students {
                    student.deleteInBackgroundWithBlock({ success in
                        callback?(results.1 == nil)
                    })
                }
            }
        })
    }
    
    class func logout() {
        PFUser.logOut()
    }
}


