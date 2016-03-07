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
            
            print(classname)
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
    
    func getUrlWithName(fileName: String, callback: (NSURL?) -> Void) {
        if let file = self[fileName] as? PFFile {
            if let url = file.url {
                callback(NSURL(string: url))
            } else {
                callback(nil)
            }
        } else {
            callback(nil)
        }
    }
}

extension UIViewController {
    func addBackgroundView() -> UIImageView {
        
        let backgroundView = UIImageView(image: UIImage(named: "applicationBackground"))
        backgroundView.frame.size.height = self.view.frame.size.height
        backgroundView.frame.size.width = self.view.frame.size.height
        self.view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
        return backgroundView
    }
    
    func addStatusBarStyle()
    {
        let view: UIView = UIView.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 20))
        view.backgroundColor = UIColor(red:255/255.0, green:37/255.0, blue:80/255.0,  alpha:1.0) //The colour you want to set
        self.view.addSubview(view)
        view.sendSubviewToBack(view)
        
    }
    func presentAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 1.5)
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.addAnimation(rotateAnimation, forKey: nil)
    }
    
    func removeAllConstraints() {
        var superview = self.superview
        while superview != nil {
            for constraint in (superview?.constraints)! {
                if constraint.firstItem as? UILabel == self || constraint.secondItem as? UILabel == self {
                    superview?.removeConstraint(constraint)
                }
            }
            superview = superview?.superview
        }
        removeConstraints(constraints)
        translatesAutoresizingMaskIntoConstraints = false
    }
}

extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}