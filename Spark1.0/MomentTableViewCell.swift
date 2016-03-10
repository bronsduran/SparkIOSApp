//
//  SPStudentViewCell.swift
//  Spark1.0
//
//  Created by Lucas Throckmorton on 1/26/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

class MomentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var momentImageView: UIImageView!

    @IBOutlet weak var photoOrVideoIndicator: UIVisualEffectView!
    @IBOutlet weak var voiceIndicator: UIVisualEffectView!
    @IBOutlet weak var imageToCaptionConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var videoIndicatorToCaptionConstraint: NSLayoutConstraint!
    var moment: Moment!
    
    override func layoutSubviews() {
        super.layoutSubviews()

        colorLabels()
        backgroundColor = UIColor(white: 1.0, alpha: 0.1)
     
        photoOrVideoIndicator.layer.cornerRadius = 3.0 //photoOrVideoIndicator.frame.height / 2.0
        photoOrVideoIndicator.layer.masksToBounds = true
        
        voiceIndicator.layer.cornerRadius = 3.0 //voiceIndicator.frame.height / 2.0
        voiceIndicator.layer.masksToBounds = true
        
    }
    
    func colorLabels() {
        dateLabel.textColor = UIColor.lightGrayColor()
        captionLabel.textColor = UIColor.darkGrayColor()
    }
    
//    func setAudio() {
//    
//        moment.getFileNamed("voiceData") { (data: NSData?) -> Void in
//            let hasAudio = data != nil
//            self.audioIndicator.hidden = !hasAudio // moment.audio == nil
//            self.noAudioIndicator.hidden = hasAudio // moment.audio != nil
//        }
//    }
    
    func resizeLabel(maxHeight : CGFloat) {
        let rect = captionLabel.attributedText?.boundingRectWithSize(CGSizeMake(100, maxHeight),
            options: .UsesLineFragmentOrigin, context: nil)
        var frame = captionLabel.frame
        frame.size.height = rect!.size.height
        captionLabel.frame = frame
    }
    
    func withMoment(moment: Moment) {
        
        photoOrVideoIndicator.hidden = true
        voiceIndicator.hidden = true
        
        captionLabel.text = nil
        momentImageView.image = nil
        
        self.moment = moment
        
        if let date = moment.getDate() {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            dateLabel.text = dateFormatter.stringFromDate(date)
        } else {
            dateLabel.text = ""
        }
        
        
//        // categories
//        if moment.categoriesTagged().count > 0 {
//            let numCategories = moment.categoriesTagged().count
//            if numCategories == 0 {
//                categoryLabel.text = "No Category Tags"
//            } else {
//                categoryLabel.text = moment.categoriesTagged()[0]
//                
//                if numCategories > 1 {
//                    categoryLabel.text = categoryLabel.text! + ", ..."
//                }
//            }
//        } else {
//            categoryLabel.text = "No Category Tags"
//        }
        

        // notes
        if let notes = moment["notes"] as? String where notes != "" {
            self.captionLabel.text = notes
        } else {
            self.captionLabel.text = "No notes currently exist for this moment."
        }
        

        self.imageToCaptionConstraint.constant = -(self.momentImageView.frame.width)
        
         //  voice indicator
        moment.getFileNamed("voiceData") { (data: NSData?) -> Void in
            self.voiceIndicator.hidden = data == nil
            
            // layoutThumbnailIcons
            if self.voiceIndicator.hidden {
                self.videoIndicatorToCaptionConstraint.constant = 10
                
            } else {
                self.videoIndicatorToCaptionConstraint.constant = 34
            }
        }
        
        
        // picture / video
        moment.image({ image in
            if let image = image {
                self.momentImageView.image = image
                self.momentImageView.contentMode = UIViewContentMode.ScaleAspectFill
                self.momentImageView.layer.cornerRadius = 3.0
                self.momentImageView.layer.masksToBounds = true
                self.momentImageView.layer.opaque = false
                self.imageToCaptionConstraint.constant = 8
                if moment.isVideo() {
                    self.photoOrVideoIndicator.hidden = false
                }
            } else {
                self.momentImageView.image = UIImage(named: "placeHolder")
                self.momentImageView.contentMode = UIViewContentMode.ScaleAspectFit
                self.momentImageView.layer.cornerRadius = 3.0
                self.momentImageView.layer.masksToBounds = true
                self.momentImageView.layer.opaque = false
                self.imageToCaptionConstraint.constant = 8
            }
        })
        
        
        
        
    }
}
 