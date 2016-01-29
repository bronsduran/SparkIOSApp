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
    
    @IBOutlet weak var backGround: UIImageView!
    @IBOutlet weak var archiveCollectionView: UICollectionView!
    
    @IBOutlet weak var sortByControl: UISegmentedControl!
    
    @IBAction func sortByControl(sender: UISegmentedControl) {
    }
    
    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib: UINib = UINib(nibName: "StudentCollectionViewCell", bundle: nil)
        
        self.archiveCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "StudentCollectionViewCell")
        
        // set view's background imag and send to back
        backGround.image = UIImage(named: "Login_Background")
        view.sendSubviewToBack(backGround)
        
        
        
        
        
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
    
    
    // override methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 13
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StudentCollectionViewCell", forIndexPath: indexPath) as! StudentCollectionViewCell
        
        // Contents (Picture / name / count)
        cell.pictureImageView.image = UIImage(named: "Untagged_Icon")
        cell.nameLabel.text = "Lucas"
      
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("toStudentViewController", sender: self)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "studentViewController" {
//            let studentViewController: SPStudentViewController = segue.destinationViewController as
//        }
//    }
    
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
