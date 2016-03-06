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
    
    var navBlur: UIVisualEffectView!
    var viewsAreHidden: Bool = false
    var audioExists: Bool = false
    var textExists: Bool = false
    var videoFrameView: UIView!

    @IBAction func sendMomentPressed(sender: AnyObject) {
        if (student != nil && student["parentEmail"] != nil) {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
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
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("screenTapped:"))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // notes
        if let caption = moment["notes"] as? String where caption != "" {
            captionLabel.text = caption
            captionLabel.hidden = false
            textBlur.hidden = false
            textExists = true
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
                self.audioExists = true
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
        addBlurEffect()
        
      
    }
    func screenTapped(sender: AnyObject)
    {
        if viewsAreHidden {
            showViews()
        } else {
            hideViews()
        }
    }
    
    func showViews() {
        self.bottomBar.hidden = false
        self.navigationController?.navigationBar.hidden = false
        self.navBlur.hidden = false
        
        if textExists {
            self.textBlur.hidden = false
            self.captionLabel.hidden = false
        }
        if audioExists {
            self.audioView.hidden = false
            self.audioBlur.hidden = false
        }
        viewsAreHidden = false
        
    }
    func hideViews() {
        self.bottomBar.hidden = true
        self.navigationController?.navigationBar.hidden = true
        self.captionLabel.hidden = true
        self.textBlur.hidden = true
        self.audioBlur.hidden = true
        self.audioView.hidden = true
        self.navBlur.hidden = true
        viewsAreHidden = true
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
            self.view.bringSubviewToFront(self.navBlur)
            
            
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
        if moment["notes"] != nil && moment["notes"] as! String != "" {
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
    
    func addBlurEffect() {
        // Add blur view
        var bounds = self.navigationController?.navigationBar.bounds as CGRect!
        bounds.offsetInPlace(dx: 0.0, dy: 0.0)
        bounds.size.height = bounds.height + 20.0
        
        navBlur = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        navBlur.frame = bounds
        navBlur.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.view.addSubview(navBlur)
    
        
        // Here you can add visual effects to any UIView control.
        // Replace custom view with navigation bar in above code to add effects to custom view.
    }
}
