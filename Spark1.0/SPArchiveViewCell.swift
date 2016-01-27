//
//  SPArchiveViewCell.swift
//  Spark1.0
//
//  Created by Lucas Throckmorton on 1/23/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//


class SPArchiveViewCell: UICollectionViewCell {
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
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
        nameLabel.textColor = UIColor.whiteColor()
        
        // count view
        countLabel.textColor = UIColor.whiteColor()
        countView.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        countView.layer.cornerRadius = countView.frame.height / 2.0
    }
}
