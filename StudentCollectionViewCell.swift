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
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
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
        setBackground()
        
        //nameBackground
        nameBackground.backgroundColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 0.55)
        
        //photoBackground
        pictureImageView.backgroundColor = UIColor.clearColor()
        
        // name label
        nameLabel.textColor = UIColor.blackColor()
        
        // count view
        countLabel.textColor = UIColor.whiteColor()
        countView.layer.cornerRadius = countView.frame.height / 2.0
        
        // check view
        checkImageView.hidden = true
    }
    
    func setBackground() {
        backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 0.77)
//        let selectedColor = UIImage(color: UIColor.blackColor().colorWithAlphaComponent(0.3))
//        self.selectedBackgroundView = UIImageView(image: selectedColor)
        self.layer.cornerRadius = 4
    }
    
    func withStudentData(student: Student!) {
        self.student = student
        
        nameLabel.text = student.displayName()
        initialsLabel.text = student.initials()
        countLabel.text = String(student.numberOfMoments())
        countView.backgroundColor = UIColor(red:100/255.0, green:168/255.0, blue:205/255.0,  alpha:0.7);

        student.image { (image: UIImage?) -> Void in
            if image != nil {
                self.pictureImageView.image = image
                self.pictureImageView.contentMode = UIViewContentMode.ScaleAspectFill
                self.pictureImageView.layer.cornerRadius = self.pictureImageView.frame.height / 2
                self.pictureImageView.layer.masksToBounds = true
                self.pictureImageView.layer.opaque = false
                self.initialsLabel.hidden = true
                self.pictureImageView.hidden = false
            } else {
                self.initialsLabel.layer.cornerRadius = self.initialsLabel.frame.height / 2
                self.initialsLabel.layer.masksToBounds = true
                self.initialsLabel.layer.opaque = false
                self.initialsLabel.hidden = false
                self.pictureImageView.hidden = true
                self.initialsLabel.frame.origin.y = self.pictureImageView.frame.origin.y
                self.initialsLabel.backgroundColor = UIColor(red:224/255.0, green:224/255.0, blue:224/255.0,  alpha:1.0)
            }

        }
    }
    
    func withUntaggedData() {
        numUntaggedMoments = User.currentUser()!.getNumberUntaggedMoments()
        student = nil
        countView.backgroundColor = UIColor(red:255/255.0, green:37/255.0, blue:80/255.0,  alpha:0.7)
        nameLabel.text = "Untagged"
        countLabel.text = String(numUntaggedMoments)
        pictureImageView.image = UIImage(named: "untaggedIcon")
    }
    
    
}
