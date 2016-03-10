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
    
    func studentsTagged() -> [Student] {
        if let studentsTagged = self["studentsTagged"] as? [Student] {
            return studentsTagged
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
        if self["momentData"] != nil {
            return (self["mediaType"] as! Int) == 1
        } else {
            return false
        }
    }
    
    // typeOfMoment: True if IMAGE, false if VIDEO. For now always put True
    class func createMoment(typeOfMoment: Bool, students: [Student]?, categories: [String]?,
        notes: String?, imageFile: UIImage?, videoURL: NSURL?, voiceFile: NSURL?) {
            let moment = Moment()
            
            moment.updateMomentInfo(typeOfMoment,
                students: students,
                categories: categories,
                notes: notes,
                imageFile: imageFile,
                videoURL: videoURL,
                voiceFile: voiceFile)
    }

    
    class func saveMomentAndUpdateStudents(moment: PFObject, students: [Student]?) {
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
    
    class func saveMoment(moment: PFObject) {
        do {
            try moment.save()
        } catch _ {
            print("ERROR SAVING")
        }
    }
    
    
    func updateMomentInfo(typeOfMoment: Bool, students: [Student]?, categories: [String]?, notes: String?, imageFile: UIImage?, videoURL: NSURL?, voiceFile: NSURL?) {
        
        // Media Type
        self["mediaType"] = typeOfMoment ? 0 : 1
        
        // Notes
        if let momentNotes = notes {
            self["notes"] = momentNotes
        } else {
            self["notes"] = ""
        }
        
        // Students Tagged
        if let taggedStudents = students {
            
            var studentsTagged = [String]()
            for student in taggedStudents {
                studentsTagged.append(student.objectId! as String)
            }
            self["studentsTagged"] = studentsTagged
        }
        
        // Categories Tagged
        if let categories = categories {
            self["categoriesTagged"] = categories
        }
        
        // Voice Data
        if let file = voiceFile {
            let voice = NSData(contentsOfURL: file)
            let parseVoiceFile = PFFile(name: "voice.caf", data: voice!)
            self.setObject(parseVoiceFile!, forKey: "voiceData")
        }
        
        // Teacher
        self["teacher"] = User.currentUser()
        
        // if the object already exists, remove from untagged moments before retagging models.
        if let objectId = self.objectId {
            User.currentUser()!.removeUntaggedMoment(objectId)
        }
        
        // Image Data
        if let file = imageFile {
            let imageData = UIImageJPEGRepresentation(file, 0.1)
            let parseImageFile = PFFile(data: imageData!)
            self.setObject(parseImageFile!, forKey: "momentData")
        } else if let url = videoURL {
            compressVideo(url, completion: { (videoData, success) -> Void in
                if let videoData = videoData {
                    let parseVideoFile = PFFile(name: "video.mov", data: videoData)
                    print("video bytes:", videoData.length)
                    self.setObject(parseVideoFile!, forKey: "momentData")
                    Moment.saveMoment(self)
                }
            })
        }
        
        Moment.saveMomentAndUpdateStudents(self, students: students)
    }
    
    func compressVideo(url: NSURL, completion: (videoData: NSData?, success: Bool) -> Void)  {
        let tempUrl = (UIApplication.sharedApplication().delegate as! AppDelegate).applicationDocumentsDirectory.URLByAppendingPathComponent("tempVideo").URLByAppendingPathExtension("mov")
        do {
            try NSFileManager.defaultManager().removeItemAtURL(tempUrl)
        } catch {
            return completion(videoData: nil, success: false)
        }
        
        let asset = AVURLAsset(URL: url)
        if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) {
            exportSession.outputURL = tempUrl
            exportSession.outputFileType = AVFileTypeQuickTimeMovie
            exportSession.exportAsynchronouslyWithCompletionHandler { () -> Void in
                if exportSession.status == AVAssetExportSessionStatus.Completed {
                    if let videoData = NSFileManager.defaultManager().contentsAtPath(tempUrl.path!) {
                        return completion(videoData: videoData, success: true)
                    }
                    
                }
            }
        }
        completion(videoData: nil, success: false)
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
    
    func getDate() -> NSDate? {
        return self.createdAt
    }
    
}