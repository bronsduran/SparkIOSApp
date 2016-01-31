//
//  Class.swift
//  Spark1.0
//
//  Created by Kevin Khieu on 1/30/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation
import UIKit
import Parse

class Class {
    
    var objectId: String!
    var teacher: PFUser!
    var parse: PFObject!

    convenience init(_ object: PFObject) {
        self.init()
        self.objectId = object.objectId
        self.parse = object
        self.teacher = User.current().parse
    }

    class func createClass(classTeacher: PFUser) {
        let newClass = PFObject(className: "Class")
        newClass["teacher"] = User.current().parse
        
        newClass.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if success {
                User.current().addClass(newClass)
                print("Created Class")
            } else {
                print(error)
            }
        }
    }
}