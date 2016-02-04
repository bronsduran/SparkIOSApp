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
    
    var untaggedMoments: [Moment]?
    
    var students: [Student]! = []

    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib: UINib = UINib(nibName: "StudentCollectionViewCell", bundle: nil)
        
        self.archiveCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "StudentCollectionViewCell")
        
        self.addBackgroundView()
        
        // make collection view transparent
        archiveCollectionView.backgroundColor = UIColor.clearColor()
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

        }
    }
    
    func refresh() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            // sort by name first, so that ties will be broken correctly when you sort by moments
            self.students = self.students.sort({ $0.firstName < $1.firstName })
            
            if (self.sortByControl.selectedSegmentIndex == 1) {
                self.students = self.students.sort({ $0.firstName > $1.firstName })
                // TODO: swap out for correct sort criteria
                //      self.students = students.sort({ $0.numberOfMoments > $1.numberOfMoments })
            }
            
            self.archiveCollectionView.reloadData()
        })
    
    }
    
    // delegates / datasource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numItems = 0
        
        if User.current().getNumberUntaggedMoments() > 0 {
            numItems++
        }
        
        if let students = students {
            numItems += students.count
        }
        
        return numItems
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        print("Here")
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StudentCollectionViewCell", forIndexPath: indexPath) as! StudentCollectionViewCell
        
        let offset = User.current().getNumberUntaggedMoments() == 0 ? 0 : 1
        if offset == 1 && indexPath.row == 0 {
            cell.withUntaggedData()
        } else {
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
        let vc = mainStoryboard.instantiateViewControllerWithIdentifier("SPAddStudentViewController") as! SPAddStudentViewController
        self.presentViewController(vc, animated: true, completion: nil)
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
