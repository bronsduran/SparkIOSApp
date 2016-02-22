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
        
        self.addBackgroundView()
        
        let cellNib: UINib = UINib(nibName: "StudentCollectionViewCell", bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "StudentCollectionViewCell")
        
        self.collectionView.allowsMultipleSelection = true
        
        // make collection view transparent
        collectionView.backgroundColor = UIColor.clearColor()
        self.title = "Tag Student"
        
    }
    
    override func viewWillLayoutSubviews() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: (collectionView.frame.width - 4.0)/3.0, height: 148.0)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        collectionView.collectionViewLayout = layout
    }
    
    override func viewWillAppear(animated: Bool) {
        
        User.currentUser()!.students() { (retrievedStudents) -> Void in
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
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! StudentCollectionViewCell
        if let student = cell.student {
            self.selectedStudents.append(student)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! StudentCollectionViewCell
        if let student = cell.student {
            self.selectedStudents.removeObject(student)
        }
    }
    
    
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