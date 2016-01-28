//
//  SPTagCategoryViewController.swift
//  Spark1.0
//
//  Created by Nathan Eidelson on 1/22/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SPTagCategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var CategoryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib: UINib = UINib(nibName: "CategoryCollectionViewCell", bundle: nil)
        
        self.CategoryCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        
        // set view's background color
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "General_Background")!)
        
        // make collection view transparent
        CategoryCollectionView.backgroundColor = UIColor.clearColor()
        
    }
    
    override func viewWillLayoutSubviews() {
        
        // collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: (CategoryCollectionView.frame.width - 2.0)/2.0, height: 148.0)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        CategoryCollectionView.collectionViewLayout = layout
        //        archiveCollectionView.scrol
    }
    
    // override methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCollectionViewCell", forIndexPath: indexPath) as! CategoryCollectionViewCell
        
        // Contents (Picture / name / count)
        
        cell.categoryLabel.text = "Bronson"
        
        return cell
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
    
}

