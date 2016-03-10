

//  Student.swift
//  Spark1.0
//
//  Created by Kevin Khieu on 1/30/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation
import UIKit
import Parse

class Student: PFObject, PFSubclassing {
    
    var image : UIImage? = nil
    var hasFetchedMoments : Bool = false
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Student"
    }
    
    //class func addStudent(name: String,
    class func addStudent(firstName: String!, lastName: String!, phoneNumber: String?, parentEmail: String?, photo: UIImage?) {
        
        let student = Student()
        student["firstName"] = firstName
        student["lastName"] = lastName
        student["parentPhone"] = phoneNumber
        student["parentEmail"] = parentEmail
        student["numberOfMoments"] = 0
        
        if let photo = photo {
            let imageData = UIImageJPEGRepresentation(photo, 0.1)
            let parseImageFile = PFFile(data: imageData!)
            student["studentImage"] = parseImageFile
        }
        
        do {
            try student.save()
        } catch _ {
            print("ERROR SAVING")
        }
 
        User.currentUser()!.addStudent(student)
    }
    
    func updateStudentInfo(firstName: String?, lastName: String?, phoneNumber: String?, parentEmail: String?, photo: UIImage?, callback: ((Bool) -> Void)?) {
        
        if (firstName != nil) {
            self["firstName"] = firstName
        }
        
        if (lastName != nil) {
            self["lastName"] = lastName
        }
        
        if (phoneNumber != nil) {
            self["parentPhone"] = phoneNumber
        }
        
        if (parentEmail != nil) {
            self["parentEmail"] = parentEmail
        }
        
        if let photo = photo {
            self.image = nil // deletes the cached image
            let imageData = UIImageJPEGRepresentation(photo, 0.1)
            let parseImageFile = PFFile(data: imageData!)
            self["studentImage"] = parseImageFile
        }
        
        self.saveInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                print("ERROR in updateStudentInfo: ", error?.localizedDescription)
                
                callback?(false)
            } else {
                callback?(true)
            }
        }

    }
    
    func displayName() -> String {

        if let firstName = self["firstName"] as? String {
            return firstName
        } else {
            return ""
        }
    }
    
    func initials() -> String {
        
        
        let firstInitial =  displayName()[displayName().startIndex]
        
        if let lastName = self["lastName"] as? String {
            let lastInitial = lastName[lastName.startIndex]
            return String(firstInitial) + String(lastInitial)
        }
        
       return String(firstInitial)
        
        
    }
    
    func numberOfMoments() -> Int {
        if let moments = self["moments"] {
            return moments.count
        } else {
            return 0
        }
    }
    
    func addMoment(newMoment: PFObject) {
        
        if let moments = self["moments"] {
            moments.addObject(newMoment.objectId!)
            self["moments"] = moments
        } else {
            self["moments"] = [newMoment.objectId!]
        }
        self.saveEventually { (success: Bool, error: NSError?) -> Void in
            print("DONE saveEventually: ", success)
            self.refreshMoments(nil)
        }

    }
    
    func image(callback: (UIImage?) -> Void) {
        
        if self.image != nil {
            callback(self.image)
        } else {
            getFileNamed("studentImage", callback: { (data: NSData?) -> Void in
                if data != nil {
                    self.image = UIImage(data: data!)
                } else {
                    self.image = nil
                }
                callback(self.image)
            })
        }
    }
    
    func refreshMoments(callback: ((Bool) -> Void)?) {
        self.fetchObjectIds("moments", classname: "Moment") { (foundObjects) -> Void in
            callback?(foundObjects != nil)
        }
    }
    
    func moments(callback: [Moment] -> Void) {
        
        if !self.hasFetchedMoments {
            self.refreshMoments({ (success) -> Void in
                if success {
                    self.loadObjectIds("moments", classname: "Moment") { (foundObjects) -> Void in
                        callback(foundObjects as! [Moment])
                    }
                }
            })
        } else {
            self.loadObjectIds("moments", classname: "Moment") { (foundObjects) -> Void in
                callback(foundObjects as! [Moment])
            }
        }
        
    }
    
 
    
}
