//
//  SPManageStudentsViewController.swift
//  Spark1.0
//
//  Created by Nathan Eidelson on 1/31/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation

class SPManageStudentsViewController : UICollectionViewController {
    
    var students: [Student]! = []
    
    @IBOutlet weak var backbutton: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (self.collectionView!.frame.width - 4.0)/3.0, height: 148.0)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        self.navigationController?.navigationBar.backgroundColor = UIColor(red:232/255.0, green:232/255.0, blue:232/255.0,  alpha:1.0)

        self.view.backgroundColor = UIColor(red:232/255.0, green:232/255.0, blue:232/255.0,  alpha:1.0)
        self.collectionView?.collectionViewLayout = layout
        
        let cellNib: UINib = UINib(nibName: "StudentCollectionViewCell", bundle: nil)
        self.collectionView!.registerNib(cellNib, forCellWithReuseIdentifier: "StudentCollectionViewCell")
        
        // make collection view transparent
        self.collectionView!.backgroundColor = UIColor.clearColor()
        
        let addStudentButton = UIBarButtonItem(
            image: UIImage(named: "addStudent"),
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "addStudentPressed:"
        )
    
        self.navigationItem.rightBarButtonItem = addStudentButton
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Manage Students"
        
        User.currentUser()?.students( { students in
            self.students = students
            
            self.students.sortInPlace({ $1["firstName"] as? String > $0["firstName"] as? String})
            self.collectionView?.reloadData()
        })
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return students.count
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StudentCollectionViewCell", forIndexPath: indexPath) as! StudentCollectionViewCell
        
        // Contents (Picture / name / count)
        cell.withStudentData(students[indexPath.row])
        cell.countView.hidden = true
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let student = students[indexPath.row]
        let editStudentProfileViewController = storyboard.instantiateViewControllerWithIdentifier("SPStudentProfileViewController") as! SPStudentProfileViewController
        editStudentProfileViewController.tableView = UITableView()
        editStudentProfileViewController.student = student
        editStudentProfileViewController.editMode = true
        editStudentProfileViewController.showCloseButton = false
        self.title = nil

        self.navigationController?.pushViewController(editStudentProfileViewController, animated: true)
    }
    
    func addStudentPressed(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addStudentProfileViewController = storyboard.instantiateViewControllerWithIdentifier("SPStudentProfileViewController") as! SPStudentProfileViewController
        self.presentViewController(addStudentProfileViewController, animated: true, completion: nil)
    }
    
    
}