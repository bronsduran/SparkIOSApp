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

    @IBOutlet weak var archiveCollectionView: UICollectionView!
    
    @IBOutlet weak var categoryButton: UIBarButtonItem!
    
    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addBackgroundView()
        
        let cellNib: UINib = UINib(nibName: "StudentCollectionViewCell", bundle: nil)
        self.archiveCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "StudentCollectionViewCell")
        
        self.archiveCollectionView.allowsMultipleSelection = true
        
        // make collection view transparent
        archiveCollectionView.backgroundColor = UIColor.clearColor()
        self.title = "Tag Student"
        
    }
    
    override func viewWillLayoutSubviews() {
        
        // collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: (archiveCollectionView.frame.width - 4.0)/3.0, height: 148.0)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        archiveCollectionView.collectionViewLayout = layout
        //        archiveCollectionView.scrol
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
        cell.countView.hidden = true
        cell.nameLabel.text = "Lucas"

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
         self.categoryButton.enabled = true
        
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        if collectionView.indexPathsForSelectedItems()?.count == 0 {
            self.categoryButton.enabled = false

        }

    }
    



}