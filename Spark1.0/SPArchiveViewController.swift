//
//  SPArchiveViewController.swift
//  Spark1.0
//
//  Created by Lucas Throckmorton on 1/23/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//


class SPArchiveViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // toolbar
    
    
    // Untagged moments
    
    @IBOutlet weak var archiveCollectionView: UICollectionView!
    
    @IBOutlet weak var sortByControl: UISegmentedControl!
    
    var navBlur: UIVisualEffectView!
    
    @IBAction func sortByControl(sender: UISegmentedControl) {
        refresh()
    }
    
    var untaggedMoments: [Moment]?
    
    var students: [Student]! = []

    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        sortByControl.backgroundColor = UIColor.clearColor()
        addStatusBarStyle()
        self.view.backgroundColor = UIColor(red:240/255.0, green:240/255.0, blue:240/255.0,  alpha:0.9)
        let cellNib: UINib = UINib(nibName: "StudentCollectionViewCell", bundle: nil)
        
        self.archiveCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "StudentCollectionViewCell")
        
        archiveCollectionView.backgroundColor = UIColor.clearColor()
        
    
    
   }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (archiveCollectionView.frame.width - 6.0)/3.0, height: 148.0)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        archiveCollectionView.collectionViewLayout = layout
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
            
        // load in all students
        User.currentUser()!.students() { (retrievedStudents) -> Void in
            self.students = retrievedStudents
            self.refresh()
        }
    }
    
    func refresh() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            // sort by name first, so that ties will be broken correctly when you sort by moments
            self.students.sortInPlace({ (student1: Student, student2: Student) -> Bool in
                return (student1["firstName"] as! String) < (student2["firstName"] as! String)
            })
            
            
            if (self.sortByControl.selectedSegmentIndex == 1) {
                
                self.students.sortInPlace({ (student1: Student, student2: Student) -> Bool in
                    return (student1.numberOfMoments()) < (student2.numberOfMoments() as! Int)
                })

            }
            
            self.archiveCollectionView.reloadData()
        })
    
    }
    
    // delegates / datasource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if (!students.isEmpty) {
            print("HI")
            collectionView.backgroundView = nil
            return 1
        } else {
            print("BYE")
            let label = UILabel(frame: CGRectMake(0, 0, collectionView.frame.width - 6.0, collectionView.frame.height - 6.0))
            label.textAlignment = NSTextAlignment.Center
            label.text = "No Students Available!"
            label.sizeToFit()
            collectionView.backgroundView = label
            // archiveCollectionView.
            return 0
        }
    }
    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numItems = 0
        
        if User.currentUser()!.getNumberUntaggedMoments() > 0 {
            numItems++
        }
        
        if let students = students {
            numItems += students.count
        }
        
        return numItems
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StudentCollectionViewCell", forIndexPath: indexPath) as! StudentCollectionViewCell
        
        let offset = User.currentUser()!.getNumberUntaggedMoments() == 0 ? 0 : 1
        
        if offset == 1 && indexPath.row == 0 {
            print("Untagged")
            cell.withUntaggedData()
        } else {
            print("Offset: " + String(offset) + ", Row: " + String(indexPath.row))
            cell.withStudentData(students![indexPath.row - offset])
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! StudentCollectionViewCell
        performSegueWithIdentifier("toStudentViewController", sender: cell)
    }
    
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addStudentButtonPressed(sender: AnyObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryboard.instantiateViewControllerWithIdentifier("SPStudentProfileViewController") as! SPStudentProfileViewController
        
        vc.didDissmiss = { (data: String?) -> Void in
            if let studentName = data {
                self.presentAlertWithTitle("Student Added", message: "Student " + studentName + " successfully added!")
            }
        }
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    func addBlurEffect() {
        if let navBar = navigationController?.navigationBar {
            // Add blur view
            var bounds = self.navigationController?.navigationBar.bounds as CGRect!
            bounds.offsetInPlace(dx: 0.0, dy: 0.0)
            bounds.size.height = bounds.height + 20.0
            
            navBlur = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
            navBlur.frame = bounds
            navBlur.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            self.view.addSubview(navBlur)
        }
        
        
        // Here you can add visual effects to any UIView control.
        // Replace custom view with navigation bar in above code to add effects to custom view.
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toStudentViewController"){
            if let destination = segue.destinationViewController as? SPStudentViewController,
               let cell = sender as? StudentCollectionViewCell,
               let student = cell.student {
                    destination.student = student
                    
            }
        }
    }
    
}
