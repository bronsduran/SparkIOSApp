//
//  ButtonTableViewCell.swift
//  Spark1.0
//
//  Created by Nathan Eidelson on 1/31/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation

class ButtonTableViewCell : UITableViewCell {
    
    @IBOutlet weak var labelImage: UIImageView!
    @IBOutlet weak var labelView: UILabel!
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // background
        backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        
        // name label
        labelView.textColor = UIColor.whiteColor()
        
    }
    
}