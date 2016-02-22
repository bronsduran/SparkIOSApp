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
    var mediaType: Int?     // 0 = video, 1 = image ......... i think this is wrong?
    var image: UIImage?
    var videoUrl: NSURL?
    var notes: String?
    var voiceData: NSData?
    var teacher: User!
    var parse: PFObject!
    var studentsTagged: [String]?
    var categoriesTagged: [String]?
    var untagged: Bool!
    
    static let momentCategories = ["Self Regulation", "Social & Emotional", "Language & Literacy", "Math & Science", "Motor Skills", "Social Science", "Arts"]
    
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
        var imageData: NSData!
        var voiceData: NSData!
        
        
        do {
            if let momentData = self.parse?["momentData"] as? PFFile {
                if self.mediaType == 0 {
                    imageData = try momentData.getData()
                    self.image = UIImage(data: imageData!)
                } else {
                    self.videoUrl = NSURL(string: momentData.url!)
//                    try imageVideoData.writeToURL(<#T##url: NSURL##NSURL#>, options: <#T##NSDataWritingOptions#>)
//                    self.video =
                }
            }
            
            if let voice = self.parse?["voiceData"] as? PFFile {
                try voiceData = voice.getData()
                self.voiceData = voiceData
            }
            
        } catch _ {
            self.image = nil
            self.voiceData = nil
        }
    }
    
    // typeOfMoment: True if IMAGE, false if VIDEO. For now always put True
    class func createMoment(typeOfMoment: Bool, students: [Student]?, categories: [String]?, notes: String?, imageFile: UIImage?, videoURL: NSURL?, voiceFile: NSURL?) {
        
        let moment = PFObject(className: "Moment")
        
        // Media Type
        moment["mediaType"] = typeOfMoment ? 0 : 1
        
        // Notes
        if let momentNotes = notes {
            moment["notes"] = momentNotes
        }
        
        // Students Tagged
        if let taggedStudents = students {
            
            var studentsTagged = [String]()
            for student in taggedStudents {
                studentsTagged.append(student.objectId as String)
            }
            moment["studentsTagged"] = studentsTagged
        }
        
        // Categories Tagged
        if let categories = categories {
            moment["categoriesTagged"] = categories
        }
        
        // Voice Data
        if let file = voiceFile {
            let voice = NSData(contentsOfURL: file)
            let parseVoiceFile = PFFile(data: voice!)
            moment.setObject(parseVoiceFile!, forKey: "voiceData")
        }
        
        // Teacher
        moment["teacher"] = User.current().parse
        
        
        // Image Data
        if let file = imageFile {
            let imageData = UIImageJPEGRepresentation(file, 0.1)
            let parseImageFile = PFFile(data: imageData!)
            moment.setObject(parseImageFile!, forKey: "momentData")
        } else if let url = videoURL {
            let tempUrl = (UIApplication.sharedApplication().delegate as! AppDelegate).applicationDocumentsDirectory.URLByAppendingPathComponent("tempVideo").URLByAppendingPathExtension("mov")
            do {
                try NSFileManager.defaultManager().removeItemAtURL(tempUrl)
            } catch {}
            
            let asset = AVURLAsset(URL: url)
            if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetLowQuality) {
                exportSession.outputURL = tempUrl
                exportSession.outputFileType = AVFileTypeQuickTimeMovie
                exportSession.exportAsynchronouslyWithCompletionHandler { () -> Void in
                    if exportSession.status == AVAssetExportSessionStatus.Completed {
                        let videoData = NSFileManager.defaultManager().contentsAtPath(tempUrl.path!)
                        let parseVideoFile = PFFile(name: "blah.mov", data: videoData!)
                        moment.setObject(parseVideoFile!, forKey: "momentData")
                        saveMoment(moment, students: students)
                    }
                }
            }
            return
        }
        
        saveMoment(moment, students: students)
    }
    
    class func saveMoment(moment: PFObject, students: [Student]?) {
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
    
    func updateMomentInfo(firstName: String?, lastName: String?, phoneNumber: String?, parentEmail: String?, photo: UIImage?) {
        
        // TODO: implement this method...
        
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
        
        do {
            try self.parse.save()
        } catch _ {
            print("ERROR SAVING")
        }
    }
    
    func getDate() -> NSDate? {
        let date = self.parse.createdAt
        return date
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