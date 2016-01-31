//
//  Student.swift
//  Spark1.0
//
//  Created by Kevin Khieu on 1/30/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation
import UIKit
import Parse

class Student {
    var objectId: String!
    var firstName: String!
    var lastName: String!
    var numberOfMoments: Int!
    var moments: NSArray!
    var parse: PFObject!
    var parentPhone: String!
    var parentEmail: String!
    
    convenience init(_ object: PFObject) {
        self.init()
        self.firstName = object["firstName"] as? String
        self.lastName = object["lastName"] as? String
        self.numberOfMoments = object["numberOfMoments"] as? Int
        self.parse = object
        self.moments = object["moments"] as? NSArray
        self.objectId = object.objectId
        self.parentPhone = object["parentPhone"] as? String
        self.parentEmail = object["parentEmail"] as? String
    }
    
    //class func addStudent(name: String,
    class func addStudent(firstName: String, lastName: String, phoneNumber: String, parentEmail: String) {
        
        let student = PFObject(className: "Student")
        student["firstName"] = firstName
        student["lastName"] = lastName
        student["parentPhone"] = phoneNumber
        student["parentEmail"] = parentEmail
        student["numberOfMoments"] = 0
        
        student.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if success {
                print("Created Student")
            } else {
                print(error)
            }
        }
    }
}