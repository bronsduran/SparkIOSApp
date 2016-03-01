//
//  SPMediaViewController.swift
//  Spark1.0
//
//  Created by Nathan Eidelson on 1/22/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//


import Foundation
import UIKit
import Parse
import AVFoundation


// for videos: http://stackoverflow.com/questions/1266750/iphone-sdkhow-do-you-play-video-inside-a-view-rather-than-fullscreen

public extension UIImage {
    convenience init(color: UIColor, size: CGSize = CGSizeMake(1, 1)) {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(CGImage: image.CGImage!)
    }
}

class SPMediaViewController: UIViewController, UITextViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    var image: UIImage! = nil
    var imageView: UIImageView? = nil
    var videoView: UIView? = nil
    var videoURL: NSURL! = nil
    var videoPlayer: AVPlayer! = nil
    var videoPlayerLayer: AVPlayerLayer! = nil
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    var isRecording: Bool! = false
    var initWithRecording = false
    var initWithText = false
    
    @IBOutlet weak var audioViewContainer: UIView!
    @IBOutlet weak var audioCloseButton: UIButton!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var audioPlayButton: UIButton!
    @IBOutlet weak var audioRecordingLabel: UILabel!
    
    @IBOutlet weak var textViewContainer: UIView!
    @IBOutlet weak var textCloseButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tagButton: UIBarButtonItem!
    
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var textViewDistanceToBottomOfAudioView: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)

        textView.returnKeyType = UIReturnKeyType.Done
        textViewDistanceToBottomOfAudioView.constant = -self.audioViewContainer.frame.height
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.title = "Moment"
        setupAudioSession()
        enableDisableSaveTagButtons()
        addStatusBarStyle()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let screenRect = UIScreen.mainScreen().bounds;

        self.navigationController?.navigationBar.backgroundColor = UIColor(red:255/255.0, green:37/255.0, blue:80/255.0,  alpha:1.0)
        self.navigationController?.navigationBar.translucent = true

        MomentSingleton.sharedInstance.notes = nil
        MomentSingleton.sharedInstance.voiceFile = nil
        
        if self.videoURL == nil {
            
            if self.imageView == nil {
                addBackgroundImageView()
            }
            
            if let view = self.videoView {
                self.view.sendSubviewToBack(view)
            }
            
            if let backgroundImage = self.image {
                self.imageView!.image = backgroundImage
            } else {
                self.imageView!.image = UIImage(named: "applicationBackground")
            }
            
        } else {
            
            videoPlayer = AVPlayer(URL: videoURL)
            videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.None
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: videoPlayer.currentItem)
            
            videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
            videoPlayerLayer.frame = screenRect
            
            if self.videoView == nil {
                addBackgroundVideoView()
            }
            if let view = self.imageView {
                self.view.sendSubviewToBack(view)
            }
            videoPlayer.play()
        }

    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func addBackgroundImageView() {
        self.imageView = UIImageView(image: self.image)
        self.imageView!.frame = self.view.frame
        self.view.addSubview(self.imageView!)
        self.view.sendSubviewToBack(self.visualEffectView)
        self.view.sendSubviewToBack(self.imageView!)
    }

    func addBackgroundVideoView() {
        self.videoView = UIView(frame: self.view.frame)
        self.videoView!.layer.addSublayer(videoPlayerLayer)
        self.view.addSubview(self.videoView!)
        self.view.sendSubviewToBack(self.visualEffectView)
        self.view.sendSubviewToBack(self.videoView!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let videoPlayer = videoPlayer {
            videoPlayer.pause()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if initWithRecording {
            recordButtonPressed(self)
        } else if initWithText {
            textButtonPressed(self)
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        if let p = notification.object as? AVPlayerItem {
            p.seekToTime(kCMTimeZero)
        }
    }
    
    func enableDisableSaveTagButtons() {
        let hasRecording = !audioViewContainer.hidden && !isRecording
        let hasNotes = textView.text != nil && textView.text != ""
        let enableButtons = hasNotes || hasRecording || image != nil || videoURL != nil
        
        saveButton.enabled = enableButtons
        tagButton.enabled = enableButtons
    }
    
    func getSoundFile() -> NSURL {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0]
        
        let soundFilePath = docsDir.stringByAppendingString("/sound.caf")
        
        return NSURL(fileURLWithPath: soundFilePath)
    }
    
    func setupAudioSession() {
        
        let soundFileURL = getSoundFile()

        let session : AVAudioSession = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            let recordSettings : [String : AnyObject] =
            [AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
                AVEncoderBitRateKey: 16,
                AVNumberOfChannelsKey: 2,
                AVSampleRateKey: 44100.0]
            
            
            self.recorder = try AVAudioRecorder(URL:soundFileURL, settings: recordSettings)
            self.recorder?.delegate = self
            self.recorder?.prepareToRecord()
            
            
        } catch let error as NSError {
            print("ERROR with setting up audio", error.localizedDescription)
            
        }
    }
    
    func setupAudioPlayer() {
        let soundFileURL = getSoundFile()

        do {
            self.player = try AVAudioPlayer(contentsOfURL: soundFileURL)
            self.player?.delegate = self
            self.player?.prepareToPlay()
        } catch let error as NSError {
            print("ERROR with setting up player", error.localizedDescription)
            
        }
    }
    
    func showAudioContainer() {
        self.audioButton.setImage(UIImage(named: "recordStopButton"), forState: UIControlState.Normal)
        textViewDistanceToBottomOfAudioView.constant = 4
        self.audioViewContainer.hidden = false
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideAudioContainer() {
        self.audioButton.setImage(UIImage(named: "microphoneButton"), forState: UIControlState.Normal)
        self.audioViewContainer.hidden = true
        textViewDistanceToBottomOfAudioView.constant = -self.audioViewContainer.frame.height
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
        returnToCaptureIfNeeded()
    }
    
    func showTextContainer() {
        self.textButton.setImage(UIImage(named: "textButtonSelected"), forState: UIControlState.Normal)
        self.textViewContainer.hidden = false
        self.textView.becomeFirstResponder()
    }
    
    func hideTextContainer() {
        self.textButton.setImage(UIImage(named: "textButton"), forState: UIControlState.Normal)
        self.textView.text = ""
        self.textView.endEditing(true)
        self.textViewContainer.hidden = true
        returnToCaptureIfNeeded()
    }
    
    func returnToCaptureIfNeeded() {
        if image == nil && audioViewContainer.hidden && textViewContainer.hidden {
            self.navigationController?.popViewControllerAnimated(false)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("FIRST")
        return true
    }
    

    
    @IBAction func textButtonPressed(sender: AnyObject) {
        showTextContainer()
    }
    
    @IBAction func textCloseButtonPressed(sender: AnyObject) {
        hideTextContainer()
        enableDisableSaveTagButtons()
    }
    
    @IBAction func viewWasTapped(sender: AnyObject) {
        self.textView.endEditing(true)
    }
    
    @IBAction func recordButtonPressed(sender: AnyObject) {
        
        if isRecording == false {
            showAudioContainer()
            audioPlayButton.hidden = true
            audioRecordingLabel.hidden = false
            audioImageView.hidden = true
            recorder?.record()
            
        } else {
            audioButton.setImage(UIImage(named: "microphoneButtonSelected"), forState: UIControlState.Normal)
            audioPlayButton.hidden = false
            audioRecordingLabel.hidden = true
            audioImageView.hidden = false
            recorder?.stop()
        }
        
        isRecording = !isRecording
        enableDisableSaveTagButtons()
    }
    
    @IBAction func audioCloseButtonPressed(sender: AnyObject) {
        hideAudioContainer()
        enableDisableSaveTagButtons()
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        
        updateMomentSingleton()
        
        Moment.createMoment(MomentSingleton.sharedInstance.mediaType == 0, students: nil, categories: nil, notes: MomentSingleton.sharedInstance.notes,
            imageFile: MomentSingleton.sharedInstance.image, videoURL: MomentSingleton.sharedInstance.videoUrl, voiceFile: MomentSingleton.sharedInstance.voiceFile)
        
        User.currentUser()?.refreshUntaggedMoments(nil)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            if let view = self.imageView {
                view.frame = CGRect(x: 0.0, y: self.view.frame.height, width: 50.0, height: 50.0)
            } else if let view = self.videoPlayerLayer {
                view.frame = CGRect(x: 0.0, y: self.view.frame.height, width: 50.0, height: 50.0)
            }
        }) { (success) -> Void in
            self.navigationController?.popViewControllerAnimated(false)
        }
        
    }
    
    @IBAction func tagButtonPressed(sender: AnyObject) {
        
    }
    
    @IBAction func audioPlayButtonPressed(sender: AnyObject) {
        if self.player == nil {
            setupAudioPlayer()
        }
        
        self.player?.play()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            self.textViewContainer.hidden = true
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        enableDisableSaveTagButtons()
    }
    
    func updateMomentSingleton() {
        if !self.audioViewContainer.hidden {
            MomentSingleton.sharedInstance.voiceFile = getSoundFile()
        }
        if !self.textViewContainer.hidden && !self.textView.text.isEmpty {
            MomentSingleton.sharedInstance.notes = self.textView.text
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(SPTagStudentViewController) {
            updateMomentSingleton()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            if (textView.text == "") {
                self.textButton.setImage(UIImage(named: "textButton"), forState: UIControlState.Normal)
            }
            textView.resignFirstResponder()
        }
        return true
    }

}
