//
//  CategoriesTableViewCell.swift
//  Spark1.0
//
//  Created by Bronson Duran on 2/3/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//


class CategoriesTableViewCell : UITableViewCell {
    
  
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var checkBox: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Category label
        categoryLabel.textColor = UIColor.darkGrayColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
    
    }
}