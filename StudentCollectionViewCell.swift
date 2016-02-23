//
//  StudentCollectionViewCell.swift
//  Spark1.0
//
//  Created by Bronson Duran on 1/26/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation


class StudentCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var pictureImageView : UIImageView!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var countLabel : UILabel!
    @IBOutlet weak var countView : UIView!
    
    var student : Student?
    
    // only one of these will ever be populated
    var numUntaggedMoments: Int!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // required
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // background
        backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        let selectedColor = UIImage(color: UIColor.blackColor().colorWithAlphaComponent(0.3))
        self.selectedBackgroundView = UIImageView(image: selectedColor)
        
        // name label
        nameLabel.textColor = UIColor.darkGrayColor()
        
        // count view
        countLabel.textColor = UIColor.darkGrayColor()
        countView.backgroundColor = UIColor.lightGrayColor()
        countView.layer.cornerRadius = countView.frame.height / 2.0
    }
    
    func withStudentData(student: Student!) {
        self.student = student
        
        nameLabel.text = student.displayName()
        countLabel.text = String(student.numberOfMoments())
        
        student.image { (image: UIImage?) -> Void in
            if image != nil {
                self.pictureImageView.image = image
                self.pictureImageView.contentMode = UIViewContentMode.ScaleAspectFill
                self.pictureImageView.layer.cornerRadius = self.pictureImageView.frame.height / 2
                self.pictureImageView.layer.masksToBounds = true
                self.pictureImageView.layer.opaque = false
            } else {
                self.pictureImageView.image = UIImage(named: "addStudentCameraIcon")
                self.pictureImageView.contentMode = UIViewContentMode.ScaleAspectFill
                self.pictureImageView.layer.cornerRadius = self.pictureImageView.frame.height / 2
                self.pictureImageView.layer.masksToBounds = true
                self.pictureImageView.layer.opaque = false
                self.pictureImageView.backgroundColor = UIColor.lightGrayColor()
            }

        }
    }
    
    func withUntaggedData() {
        numUntaggedMoments = User.currentUser()!.getNumberUntaggedMoments()
        student = nil
        
        nameLabel.text = "Untagged"
        countLabel.text = String(numUntaggedMoments)
        pictureImageView.image = UIImage(named: "nameIcon")
    }
    
    
}
