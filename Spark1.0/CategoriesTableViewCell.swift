//
//  CategoriesTableViewCell.swift
//  Spark1.0
//
//  Created by Bronson Duran on 2/3/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//


class CategoriesTableViewCell : UITableViewCell {
    
  
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // background
        backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        
        // Category label
       categoryLabel.textColor = UIColor.whiteColor()
       categoryLabel.textColor = UIColor.whiteColor()
    
    }
}