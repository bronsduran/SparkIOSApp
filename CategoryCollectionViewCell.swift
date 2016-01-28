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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.whiteColor()
    }
    
    // required
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.greenColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // background
        backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        
        // name label
        categoryLabel.textColor = UIColor.whiteColor()
        
        // count view
        countLabel.textColor = UIColor.whiteColor()
        countView.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        countView.layer.cornerRadius = countView.frame.height / 2.0
    }
}