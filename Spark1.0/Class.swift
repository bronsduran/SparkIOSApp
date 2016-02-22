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

class Class: PFObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Class"
    }

    class func createClass(classTeacher: PFUser) {
        let newClass = Class()
        newClass["teacher"] = User.currentUser()

        newClass.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if success {
                User.currentUser()!.addClass(newClass)
                print("Created Class")
            } else {
                print(error)
            }
        }
    }
    
}