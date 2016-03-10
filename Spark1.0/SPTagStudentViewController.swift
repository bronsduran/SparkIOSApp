//
//  SPTagStudentViewController.swift
//  Spark1.0
//
//  Created by Nathan Eidelson on 1/22/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SPTagStudentViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var students : [Student]! = []
    var selectedStudents : [Student]! = []
    
    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        addStatusBarStyle()
        let cellNib: UINib = UINib(nibName: "StudentCollectionViewCell", bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "StudentCollectionViewCell")
        self.collectionView.allowsMultipleSelection = true
        
        self.navigationController?.navigationBar.hidden = false
        //self.navigationController?.navigationBar.backgroundColor = UIColor(red:255/255.0, green:37/255.0, blue:80/255.0,  alpha:1.0)
        // make collection view transparent
        self.title = "Tag Student"
        self.navigationController?.navigationBar.tintColor = UIColor(red:255/255.0, green:37/255.0, blue:80/255.0,  alpha:1.0)
        
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (collectionView.frame.width - 6.0)/3.0, height: 151.0)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        collectionView.collectionViewLayout = layout
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        User.currentUser()!.students { (retrievedStudents) -> Void in
            self.students = retrievedStudents
            self.refresh()
        }
        
        MomentSingleton.sharedInstance.students = nil
    }

    func refresh() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.collectionView.reloadData()
        })
        
    }
    
    
    // override methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.students.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StudentCollectionViewCell", forIndexPath: indexPath) as! StudentCollectionViewCell
        
        cell.withStudentData(self.students[indexPath.row])
        cell.countView.hidden = true
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! StudentCollectionViewCell
        if let student = cell.student {
            self.selectedStudents.append(student)
            cell.checkImageView.hidden = false
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! StudentCollectionViewCell
        if let student = cell.student {
            self.selectedStudents.removeObject(student)
            cell.checkImageView.hidden = true
        }
    }
    
//    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
//        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! StudentCollectionViewCell
//        
//        
//        return
//    }
    
//    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
//        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! StudentCollectionViewCell
//        cell.checkImageView.hidden = true
//        return
//    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(SPTagCategoryViewController) {
            if self.selectedStudents.count == 0 {
                MomentSingleton.sharedInstance.students = nil
            } else {
                MomentSingleton.sharedInstance.students = self.selectedStudents
            }
        }
    }



}