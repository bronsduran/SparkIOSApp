//
//  Extensions.swift
//  Spark1.0
//
//  Created by Nathan Eidelson on 2/18/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation


extension PFObject {
    
    // GENERAL FUNCTIONS
    func loadObjectIds(objectArrayName: String, classname: String, callback: (foundObjects: [PFObject]?) -> Void) {
        if let objectIds = self[objectArrayName] as? [String] {
            print("Loading ", objectArrayName, " : ", objectIds)
            
            let query = PFQuery(className: classname)
            query.whereKey("objectId", containedIn: objectIds)
            query.fromLocalDatastore()
            query.findObjectsInBackgroundWithBlock({ (foundObjects : [PFObject]?, error: NSError?) -> Void in
                
                if error == nil && foundObjects != nil {
                    callback(foundObjects: foundObjects!)
                } else {
                    print("Error fetching students:", error)
                    callback(foundObjects: nil)
                }
            })
            
        } else {
            callback(foundObjects: nil)
        }
    }
    
    func fetchObjectIds(objectArrayName: String, classname: String, callback: (foundObjects: [PFObject]?) -> Void) {
        
        if let objectIds = self[objectArrayName] as? [String] {
            print("Fetching ", objectArrayName, " : ", objectIds)
            
            let query = PFQuery(className: classname)
            query.whereKey("objectId", containedIn: objectIds)
            
            query.findObjectsInBackgroundWithBlock({ (foundObjects : [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    PFObject.pinAllInBackground(foundObjects, block: { (success: Bool, error: NSError?) -> Void in
                        
                        if error == nil && foundObjects != nil {
                            callback(foundObjects: foundObjects!)
                        } else {
                            print("Error pinning ", objectArrayName, " : ", error)
                            callback(foundObjects: nil)
                        }
                    })
                    
                } else {
                    print("Error fetching ", objectArrayName, " : ", error)
                    callback(foundObjects: nil)
                }
            })
            
        } else {
            callback(foundObjects: nil)
        }
    }
    
    
    func getFileNamed(fileName: String, callback: (NSData?) -> Void) {
        
        if let file = self[fileName] as? PFFile {
            
            file.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                if error == nil && data != nil {
                    callback(data)
                } else {
                    print("error getting ", fileName, ": ", error)
                    callback(nil)
                }
                
            })
        } else {
            callback(nil)
        }
    }
    
}