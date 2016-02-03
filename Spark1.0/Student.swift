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
    var moments: [String]!
    var parse: PFObject!
    var parentPhone: String!
    var parentEmail: String!
    var studentImage: UIImage?
    
    
    convenience init(_ object: PFObject) {
        self.init()
        self.firstName = object["firstName"] as? String
        self.lastName = object["lastName"] as? String
        self.numberOfMoments = object["numberOfMoments"] as? Int
        self.parse = object
        self.moments = object["moments"] as? [String]
        self.objectId = object.objectId
        self.parentPhone = object["parentPhone"] as? String
        self.parentEmail = object["parentEmail"] as? String
        if let userPicture = PFUser.currentUser()?["studentImage"] as? PFFile {
            userPicture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    self.studentImage = UIImage(data:imageData!)
                } else {
                    self.studentImage = nil
                }
            }
        }
    }
    
    //class func addStudent(name: String,
    class func addStudent(firstName: String, lastName: String, phoneNumber: String, parentEmail: String, photo: UIImage?) {
        
        let student = PFObject(className: "Student")
        student["firstName"] = firstName
        student["lastName"] = lastName
        student["parentPhone"] = phoneNumber
        student["parentEmail"] = parentEmail
        student["numberOfMoments"] = 0
        
        if let photo = photo {let imageData = UIImageJPEGRepresentation(photo, 0.1)
            let parseImageFile = PFFile(data: imageData!)
            student.setObject(parseImageFile!, forKey: "studentImage")
        }
        
        do {
            try student.save()
        } catch _ {
            print("ERROR SAVING")
        }
 
        User.current().addStudent(student)
    }
    
    func updateStudentInfo(firstName: String?, lastName: String?, phoneNumber: String?, parentEmail: String?, photo: UIImage?) {
        
        if (firstName != nil) {
            self.parse["firstName"] = firstName
            self.firstName = firstName
        }
        
        if (lastName != nil) {
            self.parse["lastName"] = lastName
            self.lastName = lastName
        }
        
        if (phoneNumber != nil) {
            self.parse["parentPhone"] = phoneNumber
            self.parentPhone = phoneNumber
        }
        
        if (parentEmail != nil) {
            self.parse["parentEmail"] = parentEmail
            self.parentEmail = parentEmail
        }
        
        if (photo != nil) {
            if let photo = photo {let imageData = UIImageJPEGRepresentation(photo, 0.1)
                let parseImageFile = PFFile(data: imageData!)
                self.parse.setObject(parseImageFile!, forKey: "studentImage")
            }
            self.studentImage = photo
        }
        
        do {
            try self.parse.save()
        } catch _ {
            print("ERROR SAVING")
        }
    }
    
    func save(callback: (() -> Void)!) {
        if self.firstName != nil {
            self.parse["firstName"] = self.firstName
        }
        
        if self.lastName != nil {
            self.parse["lastName"] = self.lastName
        }
        
        if(self.parentEmail != nil) {
            self.parse["parentEmail"] = self.parentEmail
        }
        
        if(self.parentPhone != nil) {
            self.parse["parentPhone"] = self.parentPhone
        }
        
        if(self.numberOfMoments != nil) {
            self.parse["numberOfMoments"] = self.numberOfMoments
        }
        
        self.parse.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                callback?()
            } else {
                
            }
        }
    }
    
    func addMoment(newMoment: PFObject) {
        var array = self.moments
        if (array == nil) {
            let new_array:NSMutableArray = NSMutableArray()
            new_array.addObject(newMoment.objectId!)
            self.parse["moments"] = new_array
        } else {
            array.append(newMoment.objectId!)
            self.parse["moments"] = array
        }
        
        self.moments.append(newMoment.objectId!)
        
        do {
            try self.parse.save()
        } catch _ {
            print("ERROR SAVING")
        }
    }
    
    func fetchMoments(callback: (foundStudents: [Moment]) -> Void) {
        let array = self.moments
        var momentsArray = [Moment]()
        if (array == nil) {
            callback(foundStudents: momentsArray)
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
            callback(foundStudents: momentsArray)
        }
    }

}