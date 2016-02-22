//
//  SPMomentViewController.swift
//  Spark1.0
//
//  Created by Lucas Throckmorton on 2/8/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import UIKit

class SPMomentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate {
    
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var audioView: UIView!
    
    @IBAction func playButton(sender: UIButton) {
        self.player?.play()
    }
    
    var videoPlayer: AVPlayer! = nil
    var videoPlayerLayer: AVPlayerLayer! = nil
    
    
    var moment: Moment!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib: UINib = UINib(nibName: "MomentDetailTableViewCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: "MomentDetailTableViewCell")
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "applicationBackground")!)
        
        
        if moment.mediaType! == 0 {
            if let image = moment.image {
                imageView.image = image
                imageView.layer.masksToBounds = true
                imageView.layer.cornerRadius = 10
            } else {
                imageView.hidden = true
            }
        } else {
            if let videoURL = moment.videoUrl {
                videoPlayer = AVPlayer(URL: videoURL)
                videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: videoPlayer.currentItem)
                
                videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
            }
        }
        
        

        
        
        if let caption = moment.notes {
            captionLabel.text = caption
        } else {
            captionLabel.text = "No notes were taken with this moment."
        }
        captionLabel.textColor = UIColor.whiteColor()
        
        if let audio = moment.voiceData {
            do {
                player = try AVAudioPlayer(data: audio)
                player?.delegate = self
                self.player?.prepareToPlay()
            } catch let error as NSError {
                print("ERROR with setting up player", error.localizedDescription)
            }
        } else {
            audioView.hidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        imageView.hidden = true
        
        videoPlayerLayer.frame = imageView.frame
        videoPlayerLayer.cornerRadius = 10
        videoPlayerLayer.masksToBounds = true
        
        videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(videoPlayerLayer)
        
        videoPlayer.play()
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        if let p = notification.object as? AVPlayerItem {
            p.seekToTime(kCMTimeZero)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("MomentDetailTableViewCell") as! MomentDetailTableViewCell
        switch indexPath.row {
        case 0:
            cell.functionLabel.text = "Send"
        case 1:
            cell.functionLabel.text = "Edit"
        case 2:
            cell.functionLabel.text = "Delete"
        default:
            return cell
        }
        cell.backgroundColor = UIColor(white: 1.0, alpha: 0.4)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
