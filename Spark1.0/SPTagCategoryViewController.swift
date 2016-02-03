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
    
    @IBOutlet weak var collectionView: UICollectionView!
        
    var selectedCategories: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib: UINib = UINib(nibName: "CategoryCollectionViewCell", bundle: nil)
        
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        self.collectionView.allowsMultipleSelection = true
        
        // set view's background image
        self.addBackgroundView()
        
        
        // make collection view transparent
        collectionView.backgroundColor = UIColor.clearColor()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        MomentSingleton.sharedInstance.categories = nil
    }

    override func viewWillLayoutSubviews() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: (collectionView.frame.width - 4.0)/3.0, height: (collectionView.frame.height - 4.0) / 4.0)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        collectionView.collectionViewLayout = layout
    }
    
    // override methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCollectionViewCell", forIndexPath: indexPath) as! CategoryCollectionViewCell
        
        // Contents (Picture / name / count)
        
        cell.categoryLabel.text = categoryForIndexPath(indexPath)
        cell.countView.hidden = true
        
        return cell
    }
    
    func categoryForIndexPath(indexPath: NSIndexPath) -> String {
        switch indexPath.row {
            
        case 0:
            return "Self Regulation"
        case 1:
            return "Social & Emotional"
        case 2:
            return "Language & Literacy"
        case 3:
            return "Math & Science"
        case 4:
            return "Motor Skills"
        case 5:
            return "Social Science"
        case 6:
            return "Arts"
        default:
            return ""
        }
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        if self.selectedCategories.count == 0 {
            MomentSingleton.sharedInstance.categories = nil
        } else {
            MomentSingleton.sharedInstance.categories = self.selectedCategories
        }
        
        Moment.createMoment(true, students: MomentSingleton.sharedInstance.students,
            categories: MomentSingleton.sharedInstance.categories, notes: MomentSingleton.sharedInstance.notes,
            imageFile: MomentSingleton.sharedInstance.image, voiceFile: MomentSingleton.sharedInstance.voiceFile)
        
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! CategoryCollectionViewCell
        self.selectedCategories.append(cell.categoryLabel.text!)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! CategoryCollectionViewCell
        self.selectedCategories.removeObject(cell.categoryLabel.text!)
    }
    

    
}

