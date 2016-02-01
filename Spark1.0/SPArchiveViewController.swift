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
    @IBOutlet weak var untaggedMomentsButton: UIButton!
    
    @IBOutlet weak var archiveCollectionView: UICollectionView!
    
    @IBOutlet weak var sortByControl: UISegmentedControl!
    
    @IBAction func sortByControl(sender: UISegmentedControl) {
        refresh()
    }
    
    var students: [Student]?
    
    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib: UINib = UINib(nibName: "StudentCollectionViewCell", bundle: nil)
        
        self.archiveCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "StudentCollectionViewCell")
        
        self.addBackgroundView()
        
        
        // make collection view transparent
        archiveCollectionView.backgroundColor = UIColor.clearColor()
        
        // update "Untagged Moments" button
//        untaggedMomentsButton.backgroundColor = UIColor(red: 233/255.0, green: 63/255.0, blue: 63/255.0, alpha: 0.45)
//        untaggedMomentsButton.setTitle("xx Untagged Moments", forState: UIControlState.Normal)
//        untaggedMomentsButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
   }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (archiveCollectionView.frame.width - 4.0)/3.0, height: 148.0)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        archiveCollectionView.collectionViewLayout = layout
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // load in all students
        User.current().fetchStudents() { (retrievedStudents) -> Void in
            self.students = retrievedStudents
            self.refresh()
        }
    }
    
    func refresh() {
        if let students = students {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                // sort by name first, so that ties will be broken correctly when you sort by moments
                self.students = students.sort({ $0.firstName < $1.firstName })
                
                if (self.sortByControl.selectedSegmentIndex == 1) {
                    self.students = students.sort({ $0.firstName > $1.firstName })
                    // TODO: swap out for correct sort criteria
                    //      self.students = students.sort({ $0.numberOfMoments > $1.numberOfMoments })
                }
                
                self.archiveCollectionView.reloadData()
            })
        }
    }
    
    // delegates / datasource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let students = students {
            return students.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StudentCollectionViewCell", forIndexPath: indexPath) as! StudentCollectionViewCell
        
        cell.withStudentData(students![indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("toStudentViewController", sender: self)
    }
    
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addStudentButtonPressed(sender: AnyObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryboard.instantiateViewControllerWithIdentifier("SPAddStudentViewController") as! SPAddStudentViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
}
