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

class Moment {
    var objectId: String!
    var mediaType: Int!     // 0 = video, 1 = image
    var momentPicture: UIImage!
    var notes: String!
    var voiceData: NSData!
    var teacher: User!
    var parse: PFObject!
    var studentsTagged: [String]!
    var categoriesTagged: [String]!
    var untagged: Bool!
    
    convenience init(_ object: PFObject) {
        self.init()
        self.mediaType = object["mediaType"] as? Int
        self.notes = object["notes"] as? String
        self.teacher = object["teacher"] as? User
        self.parse = object
        self.categoriesTagged = object["categoriesTagged"] as? [String]
        self.studentsTagged = object["studentsTagged"] as? [String]
        self.objectId = object.objectId
        self.untagged = object["untagged"] as? Bool
        if let momentData = self.parse?["momentData"] as? PFFile {
            momentData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    if (self.mediaType == 1) {
                        self.momentPicture = UIImage(data:imageData!)
                    } else {
                        // Video Implementation Not Implemented Yet
                    }
                } else {
                    self.momentPicture = nil
                }
            }
        }
        
        if let voice = self.parse?["voiceData"] as? PFFile {
            voice.getDataInBackgroundWithBlock { (voiceData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    self.voiceData = voiceData
                } else {
                    self.voiceData = nil
                }
            }

        }
    }
    
    // typeOfMoment: True if IMAGE, false if VIDEO. For now always put True
    class func createMoment(typeOfMoment: Bool, untagged: Bool, students: [Student], categories: [String], notes: String, imageFile: UIImage, voiceFile: NSURL) {
        
        let moment = PFObject(className: "Moment")
        
        // Media Type
        if (typeOfMoment == true) {
            moment["mediaType"] = 0
        } else {
            moment["mediaType"] = 1
        }
        
        // Notes
        moment["notes"] = notes
        if (untagged) {
            moment["untagged"] = true
        } else {
            moment["untagged"] = false
            // Students Tagged
            var studentsTagged = [String]()
            for student in students as [Student] {
                studentsTagged.append(student.objectId as String)
            }
            moment["studentsTagged"] = studentsTagged
        
            // Categories Tagged
            moment["categoriesTagged"] = categories
        }
        
        // Image Data
        let imageData = UIImageJPEGRepresentation(imageFile, 0.1)
        let parseImageFile = PFFile(data: imageData!)
        moment.setObject(parseImageFile!, forKey: "momentData")
        
        // Teacher
        moment["teacher"] = User.current().parse
        
        // Voice Data
        let voice = NSData(contentsOfURL: voiceFile)
        let parseVoiceFile = PFFile(data: voice!)
        moment.setObject(parseVoiceFile!, forKey: "voiceData")
        
        do {
            try moment.save()
        } catch _ {
            print("ERROR SAVING")
        }
        
        if (!untagged) {
            for student in students as [Student] {
                student.addMoment(moment)
            }
        } else {
            User.current().addUntaggedMoment(moment)
        }
    }
    
    func addTagging(students: [Student], categories: [String]) {
        self.parse["untagged"] = false
        // Students Tagged
        var studentsTagged = [String]()
        for student in students as [Student] {
            studentsTagged.append(student.objectId as String)
        }
        self.studentsTagged = studentsTagged
        self.categoriesTagged = categories
        self.untagged = false
        self.parse["studentsTagged"] = studentsTagged
        self.parse["categoriesTagged"] = categories
        
        do {
            try self.parse.save()
        } catch _ {
            print("ERROR SAVING")
        }
        
        User.current().removeUntaggedMoment(self.objectId)
    }
    
    func save() {
        if self.parse == nil {
            self.parse = PFObject(className: "Moment")
        }
        
        self.parse["mediaType"] = self.mediaType
        // self.parse["mediaFile"] = self.mediaFile
        self.parse["notes"] = self.notes
        // self.parse["voiceFile"] = self.voiceFile
        self.parse["teacher"] = self.teacher.parse
        self.parse["studentsTagged"] = self.studentsTagged
        self.parse.saveInBackground()
    }
    
}