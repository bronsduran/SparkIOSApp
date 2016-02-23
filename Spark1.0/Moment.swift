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
    
    private var image : UIImage? = nil
//    private var videoUrl : NSURL? = nil
    private var videoFile : PFFile? = nil
    
    static let momentCategories = ["Self Regulation", "Social & Emotional", "Language & Literacy", "Math & Science", "Motor Skills", "Social Science", "Arts"]
    
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
        } else if self.isVideo() {
            video({ video in
                callback(self.image)
            })
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
    
    func video(callback: (PFFile?) -> Void) {
        
        if self.videoFile == nil {
            if let file = self["momentData"] as? PFFile, let url = file.url {
                videoFile = file
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    // set image as thumbnail
                    let videoUrl = NSURL(string: url)!
                    let asset = AVAsset(URL: videoUrl)
                    
                    let assetImgGenerate = AVAssetImageGenerator(asset: asset)
                    assetImgGenerate.appliesPreferredTrackTransform = true
                    assetImgGenerate.requestedTimeToleranceAfter = kCMTimeZero
                    assetImgGenerate.requestedTimeToleranceBefore = kCMTimeZero
                    
                    let time = CMTimeMakeWithSeconds(0, 600)
                    
                    do {
                        let img = try assetImgGenerate.copyCGImageAtTime(time, actualTime: nil)
                        self.image = UIImage(CGImage: img)
                    } catch {
                        self.image = nil
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        callback(self.videoFile)
                    }
                }
            } else {
                callback(self.videoFile)
            }
        } else {
            callback(self.videoFile)
        }
        
    }
    
    func isVideo() -> Bool {
        return (self["mediaType"] as! Int) == 1
    }
    
    // typeOfMoment: True if IMAGE, false if VIDEO. For now always put True
    class func createMoment(typeOfMoment: Bool, students: [Student]?, categories: [String]?, notes: String?, imageFile: UIImage?, videoURL: NSURL?, voiceFile: NSURL?) {
        
        let moment = Moment()
        
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
                studentsTagged.append(student.objectId! as String)
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
        moment["teacher"] = User.currentUser()
        
        
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