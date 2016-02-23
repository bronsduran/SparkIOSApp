//
//  SPManageStudentsViewController.swift
//  Spark1.0
//
//  Created by Nathan Eidelson on 1/31/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation

class SPManageStudentsViewController : UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (self.collectionView!.frame.width - 4.0)/3.0, height: 148.0)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        self.collectionView?.collectionViewLayout = layout
        
        let cellNib: UINib = UINib(nibName: "StudentCollectionViewCell", bundle: nil)
        self.collectionView!.registerNib(cellNib, forCellWithReuseIdentifier: "StudentCollectionViewCell")
        
        // make collection view transparent
        self.collectionView!.backgroundColor = UIColor.clearColor()
        self.title = "Manage Students"
        
    
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StudentCollectionViewCell", forIndexPath: indexPath) as! StudentCollectionViewCell
        
        // Contents (Picture / name / count)
        cell.pictureImageView.image = UIImage(named: "Untagged_Icon")
        cell.nameLabel.text = "Lucas"
        cell.countView.hidden = true
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        performSegueWithIdentifier("toStudentViewController", sender: self)
    }
    

    
    
}