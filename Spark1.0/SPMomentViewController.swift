//
//  SPMomentViewController.swift
//  Spark1.0
//
//  Created by Lucas Throckmorton on 2/8/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import UIKit
import MessageUI
import Foundation
import AVFoundation


class SPMomentViewController: UIViewController, AVAudioPlayerDelegate, MFMailComposeViewControllerDelegate {
    
    
    var player: AVAudioPlayer?
    


    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var audioView: UIView!

    @IBOutlet weak var bottomBar: UIVisualEffectView!
    var videoFrameView: UIView!
   
    
    @IBAction func sendMomentPressed(sender: AnyObject) {
        if (student != nil && student["parentEmail"] != nil) {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
            print("DONE")
        } else {
            let noEmailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "No email assigned to current student's parents.", delegate: self, cancelButtonTitle: "OK")
            noEmailErrorAlert.show()
        }
    }
    @IBOutlet weak var audioBlur: UIVisualEffectView!
    @IBOutlet weak var textBlur: UIVisualEffectView!
    
    
    @IBAction func playButton(sender: UIButton) {
        self.player?.play()
    }
    
    var videoPlayer: AVPlayer! = nil
    var videoPlayerLayer: AVPlayerLayer! = nil
    
    
    var moment: Moment!
    var student: Student!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        // notes
        if let caption = moment["notes"] as? String {
            captionLabel.text = caption
            captionLabel.hidden = false
            textBlur.hidden = false
        } else {
            captionLabel.text = "No notes were taken with this moment."
            captionLabel.hidden = true
            textBlur.hidden = true
        }
        
        
        // image
        if !moment.isVideo() {
            moment.image({ image in
                if let image = image {
                    self.imageView.image = image
                } else {
                    self.imageView.hidden = true
                }
            })
        // video
        } else {
            moment.video({ video in
                if let video = video, let videoUrl = video.url {
                    self.videoPlayer = AVPlayer(URL: NSURL(string: videoUrl)!)
                    self.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                    
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.videoPlayer.currentItem)
                    
                    self.videoPlayerLayer = AVPlayerLayer(player: self.videoPlayer)
                
                    self.videoPlayer.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
            
                }
            })
        }
        
        moment.getFileNamed("voiceData", callback: { (data: NSData?) -> Void in
            if data != nil {
                do {
                    self.player = try AVAudioPlayer(data: data!)
                    self.player?.delegate = self
                    self.player?.prepareToPlay()
                } catch let error as NSError {
                    print("ERROR with setting up player", error.localizedDescription)
                }
            } else {
                self.audioView.hidden = true
                self.audioBlur.hidden = true
            }
        })

        addStatusBarStyle()
        
      
    }
   
   
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let object = object as? AVPlayer where object == videoPlayer && keyPath == "status" {
            if (videoPlayer.status == AVPlayerStatus.ReadyToPlay) {
                print("last")
                videoPlayer.play()
            } else if (videoPlayer.status == AVPlayerStatus.Failed) {
                // something went wrong. player.error should contain some information
            }
        }
    }
    

    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if (videoPlayer != nil) {
            videoPlayer.removeObserver(self, forKeyPath: "status")
        }
        if let videoPlayer = videoPlayer {
            videoPlayer.pause()
        }
    }
 
    
    override func viewDidLayoutSubviews() {
        let screenRect = UIScreen.mainScreen().bounds;
        
        if moment.isVideo() {
            imageView.hidden = true
            
            videoPlayerLayer.frame = screenRect
            view.layer.addSublayer(videoPlayerLayer)
            
            self.view.bringSubviewToFront(self.audioBlur)
            self.view.bringSubviewToFront(self.audioView)
            self.view.bringSubviewToFront(self.textBlur)
            self.view.bringSubviewToFront(self.captionLabel)
            self.view.bringSubviewToFront(self.bottomBar)
            
            
//            videoPlayer.play()
            print("first")
        }
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        if let p = notification.object as? AVPlayerItem {
            p.seekToTime(kCMTimeZero)
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        var notes: String!
        
        mailComposerVC.setToRecipients([student["parentEmail"] as! String])
        mailComposerVC.setSubject("Spark Moment For Your Child")
        if (moment["notes"] != nil) {
            notes = moment["notes"] as? String
        } else {
            notes = "Check out what your child did in class!"
        }
        moment.getFileNamed("momentData") { (data: NSData?) -> Void in
            if data != nil {
                mailComposerVC.addAttachmentData(data!, mimeType: "image/png", fileName: "moment.png")
            }
        }
        
        moment.getFileNamed("voiceData", callback: { (data: NSData?) -> Void in
            if data != nil {
                mailComposerVC.addAttachmentData(data!, mimeType: "audio/mp3", fileName: "momentRecording.mp3")
            }
        })
        
        mailComposerVC.setMessageBody(notes, isHTML: false)
        print("bye")
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
}
