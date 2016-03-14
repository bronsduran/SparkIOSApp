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

    
    let screenRect = UIScreen.mainScreen().bounds;
    
    var image: UIImage! = nil
    var imageView: UIImageView? = nil
    var videoView: UIView? = nil
    var videoUrl: NSURL! = nil
    var videoData: NSData! = nil
    var videoPlayer: AVPlayer! = nil
    var videoPlayerLayer: AVPlayerLayer! = nil
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    var isRecording: Bool! = false
    var initWithRecording = false
    var initWithText = false
    var navBlur: UIVisualEffectView!
    
    @IBOutlet weak var audioViewContainer: UIView!
    @IBOutlet weak var audioCloseButton: UIButton!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var audioPlayButton: UIButton!
    @IBOutlet weak var audioRecordingLabel: UILabel!
    
    @IBOutlet weak var textViewContainer: UIView!
    @IBOutlet weak var textCloseButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var textButtonContainer: UIVisualEffectView!
    @IBOutlet weak var audioButtonContainer: UIVisualEffectView!
    @IBOutlet weak var tagButtonContainer: UIVisualEffectView!
    @IBOutlet weak var saveButtonContainer: UIVisualEffectView!
    
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var tagButton: UIButton!
    
    @IBOutlet weak var textViewDistanceToBottomOfAudioView: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        MomentSingleton.sharedInstance.clearData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)

        textView.returnKeyType = UIReturnKeyType.Done
        textViewDistanceToBottomOfAudioView.constant = -self.audioViewContainer.frame.height
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.title = ""
        if player == nil {
            setupAudioSession()
        }
        addStatusBarStyle()
        setUpButtons()
        addBlurEffect()
        
    }
    
    override func viewWillAppear(animated: Bool) {

        // . self.navigationController?.navigationBar.backgroundColor = UIColor(red:255/255.0, green:37/255.0, blue:80/255.0,  alpha:1.0)
        // . self.navigationController?.navigationBar.translucent = true
        
        if let mediaType = MomentSingleton.sharedInstance.mediaType where mediaType == 0 {
            updateWithImage()
        } else {
            updateWithVideoData()
        }

    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func addBackgroundImageView() {
        if let imageView = self.imageView {
            imageView.removeFromSuperview()
        }
        
        self.imageView = UIImageView(image: self.image)
        self.imageView!.frame = self.view.frame
        self.view.addSubview(self.imageView!)
        self.view.sendSubviewToBack(self.imageView!)
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    }

    func addBackgroundVideoView() {
        if let videoView = self.videoView {
            videoView.removeFromSuperview()
        }
        
        self.videoView = UIView(frame: self.view.frame)
        self.videoView!.layer.addSublayer(videoPlayerLayer)
        self.view.addSubview(self.videoView!)
        self.view.sendSubviewToBack(self.videoView!)
    }
    
    func setUpButtons() {
        maskAndSetCornerRadius(self.saveButtonContainer, radius: 8)
        maskAndSetCornerRadius(self.audioButtonContainer, radius: 2)
        maskAndSetCornerRadius(self.tagButtonContainer, radius: 8)
        maskAndSetCornerRadius(self.textButtonContainer, radius: 2)

    }
    
    func maskAndSetCornerRadius (view: UIView, radius: CGFloat) {
        view.layer.cornerRadius = view.frame.height / radius
        view.layer.masksToBounds = true
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
        } else if initWithText || MomentSingleton.sharedInstance.notes != nil {
            textButtonPressed(self)
            if let notes = MomentSingleton.sharedInstance.notes {
                textView.text = notes
            }
        }
    }
    
    // MARK: - callback methods for loading in a pre-existing moment
    func updateWithVideoData() {
        if let mediaType = MomentSingleton.sharedInstance.mediaType, let videoUrl = MomentSingleton.sharedInstance.videoUrl where mediaType == 1 {
            imageView?.hidden = true
            videoPlayerLayer?.hidden = false
            
            self.videoUrl = videoUrl
            
            videoPlayer = AVPlayer(URL: videoUrl)
            
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
        enableDisableSaveTagButtons()
    }
    
    func updateWithVoiceData() {
        if let data = MomentSingleton.sharedInstance.voiceData {
            do {
                player = try AVAudioPlayer(data: data)
                player?.delegate = self
                player?.prepareToPlay()
                
                
                showAudioContainer()
                audioRecordingLabel.hidden = true
                self.audioButton.setImage(UIImage(named: "microphoneButtonSelected"), forState: UIControlState.Normal)
                
            } catch let error as NSError {
                print("ERROR with setting up player", error.localizedDescription)
            }
        }
        enableDisableSaveTagButtons()
    }
    
    func updateWithImage() {
        if let mediaType = MomentSingleton.sharedInstance.mediaType where mediaType == 0 {
            addBackgroundImageView()
            if  let image = MomentSingleton.sharedInstance.image {
                
                videoPlayerLayer?.hidden = true
                imageView?.hidden = false
                
                self.image = image
                
                if let view = self.videoView {
                    self.view.sendSubviewToBack(view)
                }
                
                if let backgroundImage = self.image, let imageView = self.imageView {
                    imageView.image = backgroundImage
                }
            } else {
                self.imageView!.image = UIImage(named: "applicationBackground")
            }
        }
        enableDisableSaveTagButtons()
    }
    
    func enableDisableSaveTagButtons() {
        var hasRecording = false
        if let audioContainer = audioViewContainer where !audioContainer.hidden && !isRecording {
            hasRecording = true
        } else if MomentSingleton.sharedInstance.voiceData != nil {
            hasRecording = true
        }
        
        var hasNotes = false
        if let textView = textView where textView.text != nil && textView.text != "" {
            hasNotes = true
        } else if MomentSingleton.sharedInstance.notes != nil {
            hasNotes = true
        }
        
        let hasImage = (image != nil && MomentSingleton.sharedInstance.image != nil)
        let hasVideo = (videoUrl != nil && MomentSingleton.sharedInstance.videoUrl != nil)
        
        let enableButtons = hasNotes || hasRecording || hasImage || hasVideo
        
        if let saveButton = saveButton, let tagButton = tagButton {
            saveButton.enabled = enableButtons
            tagButton.enabled = enableButtons
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
    
    func showAudioContainerInRecordState() {
        self.audioButton.setImage(UIImage(named: "recordStopButton"), forState: UIControlState.Normal)
        showAudioContainer()
    }
    
    func showAudioContainer() {
        textViewDistanceToBottomOfAudioView.constant = 4
        self.audioViewContainer.hidden = false
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideAudioContainer() {
        self.audioButton.setImage(UIImage(named: "microphoneButton"), forState: UIControlState.Normal)
        self.audioButton.hidden = false
        self.audioViewContainer.hidden = true
        textViewDistanceToBottomOfAudioView.constant = -self.audioViewContainer.frame.height
        
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
        self.audioButton.hidden = false
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
        self.textButton.hidden = false
        self.textButtonContainer.hidden = false
        returnToCaptureIfNeeded()
    }
    
    func returnToCaptureIfNeeded() {
        if image == nil && audioViewContainer.hidden && textViewContainer.hidden {
            self.navigationController?.popViewControllerAnimated(false)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: - Button interactions
    
    
    @IBAction func textButtonPressed(sender: AnyObject) {
        showTextContainer()
        textButton.hidden = true
        textButtonContainer.hidden = true
    }
    
    @IBAction func textCloseButtonPressed(sender: AnyObject) {
        hideTextContainer()
        textButton.hidden = false
    }
    
    @IBAction func viewWasTapped(sender: AnyObject) {
        self.textView.endEditing(true)
        if self.textView.text == nil || self.textView.text == "" {
            hideTextContainer()
        }
    }
    
    @IBAction func recordButtonPressed(sender: AnyObject) {
        
        if isRecording == false {
            showAudioContainerInRecordState()
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
            audioButton.hidden = true
            audioButtonContainer.hidden = true
        }
        
        isRecording = !isRecording
        enableDisableSaveTagButtons()
    }
    
    @IBAction func audioCloseButtonPressed(sender: AnyObject) {
        hideAudioContainer()
        enableDisableSaveTagButtons()
        audioButtonContainer.hidden = false
        audioButton.hidden = false
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        
        updateMomentSingleton()
        
        if let oldMoment = MomentSingleton.sharedInstance.moment {
            oldMoment.updateMomentInfo(MomentSingleton.sharedInstance.mediaType == 0, students: nil,
                categories: nil, notes: MomentSingleton.sharedInstance.notes,
                imageFile: MomentSingleton.sharedInstance.image, videoURL: MomentSingleton.sharedInstance.videoUrl,
                voiceFile: MomentSingleton.sharedInstance.voiceFile)
        } else {
            Moment.createMoment(MomentSingleton.sharedInstance.mediaType == 0, students: nil,
                categories: nil, notes: MomentSingleton.sharedInstance.notes,
                imageFile: MomentSingleton.sharedInstance.image, videoURL: MomentSingleton.sharedInstance.videoUrl,
                voiceFile: MomentSingleton.sharedInstance.voiceFile)
        }
        
        User.currentUser()!.refreshUntaggedMoments(nil)
        
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
        
    }
    
    func updateMomentSingleton() {
        if !self.audioViewContainer.hidden {
            MomentSingleton.sharedInstance.voiceFile = getSoundFile()
        }
        if !self.textViewContainer.hidden && !self.textView.text.isEmpty {
            MomentSingleton.sharedInstance.notes = self.textView.text
        } else {
            MomentSingleton.sharedInstance.notes = nil
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
    
    func addBlurEffect() {
        if let navBar = navigationController?.navigationBar {
            // Add blur view
            var bounds = self.navigationController?.navigationBar.bounds as CGRect!
            bounds.offsetInPlace(dx: 0.0, dy: 0.0)
            bounds.size.height = bounds.height + 20.0
            
            navBlur = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
            navBlur.frame = bounds
            navBlur.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            self.view.addSubview(navBlur)
        }
        
        
        // Here you can add visual effects to any UIView control.
        // Replace custom view with navigation bar in above code to add effects to custom view.
    }

}
