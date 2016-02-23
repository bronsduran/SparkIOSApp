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
    var imageView: UIImageView! = nil
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
    
    @IBOutlet weak var textViewDistanceToBottomOfAudioView: NSLayoutConstraint!
    
    override func viewDidLoad() {
        textViewDistanceToBottomOfAudioView.constant = -self.audioViewContainer.frame.height
        
        setupAudioSession()
        enableDisableSaveTagButtons()
        
        addStatusBarStyle()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let screenRect = UIScreen.mainScreen().bounds;

        MomentSingleton.sharedInstance.notes = nil
        MomentSingleton.sharedInstance.voiceFile = nil
        
        if self.image != nil {
            
            if self.imageView != nil {
                self.imageView.image = self.image
            } else {
                self.imageView = UIImageView(image: self.image)
                self.imageView.frame = screenRect
                self.view.addSubview(self.imageView)
                self.view.sendSubviewToBack(self.imageView)
            }
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
    
    func keyPressed(command: UIKeyCommand) {
        print("hi")
    }
    
    func enableDisableSaveTagButtons() {
        let hasRecording = !audioViewContainer.hidden && !isRecording
        let hasNotes = textView.text != nil && textView.text != ""
        
        let enableButtons = hasNotes || hasRecording || image != nil
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

//        var error: NSError?
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
        self.audioButton.setImage(UIImage(named: "microphoneButtonSelected"), forState: UIControlState.Normal)
        textViewDistanceToBottomOfAudioView.constant = 8
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
        self.audioViewContainer.hidden = false
    }
    
    func hideAudioContainer() {
        self.audioButton.setImage(UIImage(named: "microphoneButton"), forState: UIControlState.Normal)
        self.audioViewContainer.hidden = true
        textViewDistanceToBottomOfAudioView.constant = -self.audioViewContainer.frame.height
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
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
        
        if self.isRecording == false {
            showAudioContainer()
            self.audioPlayButton.hidden = true
            self.audioRecordingLabel.hidden = false
            self.audioImageView.hidden = true
            self.recorder?.record()
            
        } else {
            self.audioButton.setImage(UIImage(named: "microphoneButtonSelected"), forState: UIControlState.Normal)
            self.audioPlayButton.hidden = false
            self.audioRecordingLabel.hidden = true
            self.audioImageView.hidden = false
            self.recorder?.stop()
        }
        
        self.isRecording = !self.isRecording
        enableDisableSaveTagButtons()
    }
    
    @IBAction func audioCloseButtonPressed(sender: AnyObject) {
        hideAudioContainer()
        enableDisableSaveTagButtons()
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        Moment.createMoment(true, students: nil, categories: nil, notes: MomentSingleton.sharedInstance.notes,
            imageFile: MomentSingleton.sharedInstance.image, voiceFile: MomentSingleton.sharedInstance.voiceFile)
        
        self.navigationController?.popViewControllerAnimated(false)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(SPTagStudentViewController) {
            if !self.audioViewContainer.hidden {
                MomentSingleton.sharedInstance.voiceFile = getSoundFile()
            }
            if !self.textViewContainer.hidden && !self.textView.text.isEmpty {
                MomentSingleton.sharedInstance.notes = self.textView.text
            }
        }
    }

}
