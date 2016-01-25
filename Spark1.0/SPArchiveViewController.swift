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
    }
    
    // override methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 13
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SPArchiveViewCell", forIndexPath: indexPath) as! SPArchiveViewCell
        
        // Contents (Picture / name / count)
        cell.pictureImageView.image = UIImage(named: "Untagged_Icon")
        cell.nameLabel.text = "Lucas"
        
        // Colors
        cell.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        cell.nameLabel.textColor = UIColor.whiteColor()
        cell.countLabel.textColor = UIColor.whiteColor()
        
        return cell
    }
    
    
    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set view's background color
        view.backgroundColor = UIColor(patternImage: UIImage(named: "General_Background")!)
        
        // Nav Bar
        navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController!.navigationBar.shadowImage = UIImage()
        navigationController!.navigationBar.translucent = true
        
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
//        navigationController!.navigationBar.titleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor().])
        
        // make collection view transparent
        archiveCollectionView.backgroundColor = UIColor.clearColor()
        
        // update "Untagged Moments" button
        untaggedMomentsButton.backgroundColor = UIColor(red: 233/255.0, green: 63/255.0, blue: 63/255.0, alpha: 0.45)
        untaggedMomentsButton.setTitle("xx Untagged Moments", forState: UIControlState.Normal)
        untaggedMomentsButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
    }

}