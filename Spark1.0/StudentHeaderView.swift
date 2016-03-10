//
//  StudentHeaderView.swift
//  Spark1.0
//
//  Created by Nathan Eidelson on 3/7/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation

class StudentHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var countLabel: UILabel!

    override func awakeFromNib() {
        
        photoButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        photoButton.imageView?.layer.cornerRadius = self.photoButton.frame.width / 2.0
        photoButton.imageView?.clipsToBounds = true
        photoButton.imageView?.opaque = true

        countView.layer.cornerRadius = countView.frame.height / 2
        countView.backgroundColor = UIColor(red:100/255.0, green:168/255.0, blue:205/255.0,  alpha:0.7);

    }
    
    func initWithoutStudent() {
        countView.hidden = true
        self.photoButton.setImage(UIImage(named: "addStudentCameraIcon"), forState: UIControlState.Normal)
        self.backgroundView = UIImageView(image: UIImage(named: "noMediaBackground"))

    }
    
    func initWithStudent(student: Student, withMoments: Bool) {
        
        self.backgroundView = UIImageView(image: UIImage(named: "applicationBackground"))

        if withMoments {
            student.moments({ (moments: [Moment]) -> Void in
                self.countView.hidden = false
                self.countLabel.text = String(moments.count)
            })
        } else {
            countView.hidden = true
        }
        
        student.image { (image: UIImage?) -> Void in
            
            if let image = image {
                self.photoButton.setImage(image, forState: UIControlState.Normal)
                self.backgroundView = UIImageView(image: image)
                self.photoButton.enabled = false
            } else {
                self.photoButton.setImage(UIImage(named: "addStudentCameraIcon"), forState: UIControlState.Normal)
                self.backgroundView = UIImageView(image: UIImage(named: "noMediaBackground"))
            }
        }
        
    }

    
}