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
        let hasAudio = arc4random_uniform(2) == 0 ? true: false // just because we don't have real moments yet
        
        audioIndicator.hidden = !hasAudio // moment.audio == nil
        noAudioIndicator.hidden = hasAudio // moment.audio != nil
    }
    
    func withMoment(moment: Moment) {
        self.moment = moment
        
        // TODO: add date label text when that exists
        //      dateLabel.text = moment.
        
        
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
        
        // picture
        if let image = moment.image {
            momentImageView.image = image
        } else {
            momentImageView.image = nil
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
 