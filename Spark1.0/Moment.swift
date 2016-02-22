//
//  Moment.swift
//  Spark1.0
//
//  Created by Kevin Khieu on 1/30/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation
import UIKit
import Parse

class Moment: PFObject, PFSubclassing {
    
    var image : UIImage? = nil
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Moment"
    }
    
    static let momentCategories = ["Self Regulation", "Social & Emotional", "Language & Literacy", "Math & Science", "Motor Skills", "Social Science", "Arts"]

    
    func categoriesTagged() -> [String] {
        if let categoriesTagged = self["categoriesTagged"] as? [String] {
            return categoriesTagged
        } else {
            return []
        }
    }
    
    func image(callback: (UIImage?) -> Void) {
        
        if self.image != nil {
            callback(self.image)
        } else {
            getFileNamed("momentData", callback: { (data: NSData?) -> Void in
                if data != nil {
                    self.image = UIImage(data: data!)
                } else {
                    self.image = nil
                }
                callback(self.image)
            })
        }
    }
    
    // typeOfMoment: True if IMAGE, false if VIDEO. For now always put True
    class func createMoment(typeOfMoment: Bool, students: [Student]?, categories: [String]?, notes: String?, imageFile: UIImage?, voiceFile: NSURL?) {
        
        let moment = Moment()
        
        // Media Type
        if (typeOfMoment == true) {
            moment["mediaType"] = 0
        } else {
            moment["mediaType"] = 1
        }
        
        // Notes
        if let momentNotes = notes {
            moment["notes"] = momentNotes
        }
        
        // Students Tagged
        if let taggedStudents = students {
            
            var studentsTagged = [String]()
            for student in taggedStudents {
                studentsTagged.append(student.objectId! as String)
            }
            moment["studentsTagged"] = studentsTagged
        }
        
        // Categories Tagged
        if let categories = categories {
            moment["categoriesTagged"] = categories
        }
        
        // Image Data
        if let file = imageFile {
            let imageData = UIImageJPEGRepresentation(file, 0.1)
            let parseImageFile = PFFile(data: imageData!)
            moment.setObject(parseImageFile!, forKey: "momentData")
        }
        
        // Voice Data
        if let file = voiceFile {
            let voice = NSData(contentsOfURL: file)
            let parseVoiceFile = PFFile(data: voice!)
            moment.setObject(parseVoiceFile!, forKey: "voiceData")
        }
        
        // Teacher
        moment["teacher"] = User.currentUser()
        
        do {
            try moment.save()
        } catch _ {
            print("ERROR SAVING")
        }
        
        if (students != nil) {
            for student in students! {
                student.addMoment(moment)
            }
        } else {
            User.currentUser()!.addUntaggedMoment(moment)
        }
    }
    
    func addTagging(students: [Student], categories: [String]) {
        self["untagged"] = false
        // Students Tagged
        var studentsTagged = [String]()
        for student in students as [Student] {
            studentsTagged.append(student.objectId! as String)
        }
        self["studentsTagged"] = studentsTagged
        self["categoriesTagged"] = categories
        self["untagged"] = false
        
        do {
            try self.save()
        } catch _ {
            print("ERROR SAVING")
        }
        
        User.currentUser()!.removeUntaggedMoment(self.objectId!)
    }
    
    func updateMomentInfo(firstName: String?, lastName: String?, phoneNumber: String?, parentEmail: String?, photo: UIImage?) {
        
        // TODO: implement this method...
//        
//        if (firstName != nil) {
//            self.parse["firstName"] = firstName
//            self.firstName = firstName
//        }
//        
//        if (lastName != nil) {
//            self.parse["lastName"] = lastName
//            self.lastName = lastName
//        }
//        
//        if (phoneNumber != nil) {
//            self.parse["parentPhone"] = phoneNumber
//            self.parentPhone = phoneNumber
//        }
//        
//        if (parentEmail != nil) {
//            self.parse["parentEmail"] = parentEmail
//            self.parentEmail = parentEmail
//        }
//        
//        if (photo != nil) {
//            if let photo = photo {let imageData = UIImageJPEGRepresentation(photo, 0.1)
//                let parseImageFile = PFFile(data: imageData!)
//                self.parse.setObject(parseImageFile!, forKey: "studentImage")
//            }
//            self.studentImage = photo
//        }
//        
        do {
            try self.save()
        } catch _ {
            print("ERROR SAVING")
        }
    }
    
    func getDate() -> NSDate? {
        return self.createdAt
    }
    
}