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
    
    var student : Student!
    
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
        backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        let selectedColor = UIImage(color: UIColor.blackColor().colorWithAlphaComponent(0.3))
        self.selectedBackgroundView = UIImageView(image: selectedColor)
        
        // name label
        nameLabel.textColor = UIColor.whiteColor()
        
        // count view
        countLabel.textColor = UIColor.whiteColor()
        countView.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        countView.layer.cornerRadius = countView.frame.height / 2.0
    }
    
    func withStudentData(student: Student) {
        self.student = student
        nameLabel.text = student.firstName + " " + String(student.lastName[student.lastName.startIndex]) + "."
        countLabel.text = String(student.numberOfMoments)
        
        if let image = student.studentImage {
            pictureImageView.image = image
        } else {
            pictureImageView.image = UIImage(named: "nameIcon")
        }
    }
    
    func withUntaggedData() {
        numUntaggedMoments = User.current().getNumberUntaggedMoments()
        
        nameLabel.text = "Untagged"
        countLabel.text = String(numUntaggedMoments)
        pictureImageView.image = UIImage(named: "nameIcon")
    }
    
    
}
