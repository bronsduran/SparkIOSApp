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
    var mediaType: Int!
    var mediaFile: PFFile!
    var notes: String!
    var voiceFile: PFFile!
    var teacher: User!
    var parse: PFObject!
    var studentsTagged: NSArray!
    
    convenience init(_ object: PFObject) {
        self.init()
        self.mediaType = object["mediaType"] as? Int
        self.mediaFile = object["mediaFile"] as? PFFile
        self.notes = object["notes"] as? String
        self.voiceFile = object["voiceData"] as? PFFile
        self.teacher = object["teacher"] as? User
        self.parse = object
        self.studentsTagged = object["studentsTagged"] as? NSArray
        self.objectId = object.objectId
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