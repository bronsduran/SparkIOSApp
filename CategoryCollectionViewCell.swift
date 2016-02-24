//
//  CategoryCollectionViewCell.swift
//  Spark1.0
//
//  Created by Bronson Duran on 1/26/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation


class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countView: UIView!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // background
        backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        let selectedColor = UIImage(color: UIColor.blackColor().colorWithAlphaComponent(0.3))
        self.selectedBackgroundView = UIImageView(image: selectedColor)
        
        // count view
        countLabel.textColor = UIColor.darkGrayColor()
        countView.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        countView.layer.cornerRadius = countView.frame.height / 2.0
    }
}