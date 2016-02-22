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
        let hasAudio = moment.voiceData != nil
        
        audioIndicator.hidden = !hasAudio // moment.audio == nil
        noAudioIndicator.hidden = hasAudio // moment.audio != nil
    }
    
    func resizeLabel(maxHeight : CGFloat) {
        let rect = captionLabel.attributedText?.boundingRectWithSize(CGSizeMake(100, maxHeight),
            options: .UsesLineFragmentOrigin, context: nil)
        var frame = captionLabel.frame
        frame.size.height = rect!.size.height
        captionLabel.frame = frame
    }
    
    func withMoment(moment: Moment) {
        
        captionLabel.text = nil
        momentImageView.image = nil
        audioIndicator.hidden = true
        noAudioIndicator.hidden = false
        
        self.moment = moment
        
        if let date = moment.getDate() {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            dateLabel.text = dateFormatter.stringFromDate(date)
        } else {
            dateLabel.text = ""
        }
        
        
        // categories
        if let categoriesTagged = moment.categoriesTagged {
            let numCategories = categoriesTagged.count
            if numCategories == 0 {
                categoryLabel.text = "No Category Tags"
            } else {
                categoryLabel.text = categoriesTagged[0]
                
                if numCategories > 1 {
                    categoryLabel.text = categoryLabel.text! + ", ..."
                }
            }
        } else {
            categoryLabel.text = "No Category Tags"
        }
        
        var mediaType = 0
        if let mType = moment.mediaType where mType == 1 {
            mediaType = 1
        }
        
        var image: UIImage?
        // picture
        if mediaType == 0 {
            image = moment.image
        // video
        } else {
            if let videoUrl = moment.videoUrl {
                let asset = AVAsset(URL: videoUrl)
                
                let assetImgGenerate = AVAssetImageGenerator(asset: asset)
                assetImgGenerate.appliesPreferredTrackTransform = true
                assetImgGenerate.requestedTimeToleranceAfter = kCMTimeZero
                assetImgGenerate.requestedTimeToleranceBefore = kCMTimeZero
                
                let time = CMTimeMakeWithSeconds(0, 600)
                do {
                    let img = try assetImgGenerate.copyCGImageAtTime(time, actualTime: nil)
                    image = UIImage(CGImage: img)
                } catch {
                    let fetchError = error as NSError
                    print("problem getting thumbnail")
                    image = nil
                }
            }
        }
        
        if let image = image {
            momentImageView.image = image
            momentImageView.contentMode = UIViewContentMode.ScaleAspectFill
            momentImageView.layer.cornerRadius = 5.0
            momentImageView.layer.masksToBounds = true
            momentImageView.layer.opaque = false
        } else {
            imageToCaptionConstraint.constant = -(momentImageView.frame.width)
        }
        
        // notes
        if let notes = moment.notes {
            captionLabel.text = notes
        } else {
            captionLabel.text = "No notes currently exist for this moment."
        }
        
        // voice indicator
        audioIndicator.hidden = moment.voiceData == nil
        noAudioIndicator.hidden = !audioIndicator.hidden
        
    }
}
 