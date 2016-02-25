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
    @IBOutlet weak var nameBackground: UIView!
    
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
        backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 0.77)
        let selectedColor = UIImage(color: UIColor.blackColor().colorWithAlphaComponent(0.3))
        self.selectedBackgroundView = UIImageView(image: selectedColor)
        self.layer.cornerRadius = 4
        
        //nameBackground
        nameBackground.backgroundColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 0.55)
        
        //photoBackground
        pictureImageView.backgroundColor = UIColor.clearColor()
        
        // name label
        nameLabel.textColor = UIColor.blackColor()
        ()
        
        // count view
        countView.backgroundColor = UIColor(red: 209.0/255, green: 209.0/255, blue: 209.0/255, alpha: 1.0)
        countLabel.textColor = UIColor.darkGrayColor()
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
                self.pictureImageView.backgroundColor = UIColor(red:224/255.0, green:224/255.0, blue:224/255.0,  alpha:1.0)
            }

        }
    }
    
    func withUntaggedData() {
        numUntaggedMoments = User.currentUser()!.getNumberUntaggedMoments()
        student = nil
        
        nameLabel.text = "Untagged"
        countLabel.text = String(numUntaggedMoments)
        pictureImageView.image = UIImage(named: "untaggedIcon")
    }
    
    
}
