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
}
 