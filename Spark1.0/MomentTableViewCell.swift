//
//  SPStudentViewCell.swift
//  Spark1.0
//
//  Created by Lucas Throckmorton on 1/26/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

class MomentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var momentImageView: UIImageView!
    
    @IBOutlet weak var audioIndicator: UIImageView!
    @IBOutlet weak var noAudioIndicator: UIView!
    
    @IBOutlet weak var imageToCaptionConstraint: NSLayoutConstraint!
    
    var moment: Moment!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        colorLabels()
        backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        setAudio()
    }
    
    func colorLabels() {
        dateLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        categoryLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        captionLabel.textColor = UIColor.whiteColor()
    }
    
    func setAudio() {
    
        moment.getFileNamed("voiceData") { (data: NSData?) -> Void in
            let hasAudio = data != nil
            self.audioIndicator.hidden = !hasAudio // moment.audio == nil
            self.noAudioIndicator.hidden = hasAudio // moment.audio != nil
        }
    }
    
    func resizeLabel(maxHeight : CGFloat) {
        let rect = captionLabel.attributedText?.boundingRectWithSize(CGSizeMake(100, maxHeight),
            options: .UsesLineFragmentOrigin, context: nil)
        var frame = captionLabel.frame
        frame.size.height = rect!.size.height
        captionLabel.frame = frame
    }
    
    func withMoment(moment: Moment) {
        self.moment = moment
        
        // TODO: add date label text when that exists
        if let date = moment.getDate() {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            dateLabel.text = dateFormatter.stringFromDate(date)
        } else {
            dateLabel.text = ""
        }
        
        
        // categories
        if moment.categoriesTagged().count > 0 {
            let numCategories = moment.categoriesTagged().count
            if numCategories == 0 {
                categoryLabel.text = "No Category Tags"
            } else {
                categoryLabel.text = moment.categoriesTagged()[0]
                
                if numCategories > 1 {
                    categoryLabel.text = categoryLabel.text! + ", ..."
                }
            }
        } else {
            categoryLabel.text = "No Category Tags"
        }
        
        // picture
        moment.image { (image: UIImage?) -> Void in
            if image != nil {
                self.momentImageView.image = image
                self.momentImageView.contentMode = UIViewContentMode.ScaleAspectFill
                self.momentImageView.layer.cornerRadius = 5.0
                self.momentImageView.layer.masksToBounds = true
                self.momentImageView.layer.opaque = false
            } else {
                self.imageToCaptionConstraint.constant = -(self.momentImageView.frame.width)
                
            }
        }

        
        // notes
        if let notes = moment["notes"] as? String {
            captionLabel.text = notes
        } else {
            captionLabel.text = "No notes currently exist for this moment."
        }
        
        // voice indicator
        moment.getFileNamed("voiceData") { (data: NSData?) -> Void in
            self.audioIndicator.hidden = data == nil
        }
        
        
        noAudioIndicator.hidden = !audioIndicator.hidden
        
    }
}
 