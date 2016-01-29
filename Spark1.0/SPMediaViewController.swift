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
    
    @IBOutlet weak var audioViewContainer: UIView!
    @IBOutlet weak var audioCloseButton: UIButton!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var audioPlayButton: UIButton!
    @IBOutlet weak var audioRecordButton: UIBarButtonItem!
    
    @IBOutlet weak var textViewContainer: UIView!
    @IBOutlet weak var textCloseButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var backGround: UIImageView!
    
    @IBOutlet weak var textViewDistanceToBottomOfAudioView: NSLayoutConstraint!
    
    override func viewDidLoad() {
        textViewDistanceToBottomOfAudioView.constant = -self.audioViewContainer.frame.height
        backGround.image = UIImage(named: "Login_Background")
        view.sendSubviewToBack(backGround)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "General_Background")!)
        setupAudioSession()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let screenRect = UIScreen.mainScreen().bounds;
//        self.audioViewContainer.hidden = true
//        self.textViewContainer.hidden = true

        if self.image != nil {
            
            if self.imageView != nil {
                self.imageView.image = self.image
            } else {
                self.imageView = UIImageView(image: self.image)
                self.imageView.frame = screenRect
                self.view.addSubview( self.imageView)
                self.view.sendSubviewToBack( self.imageView)
            }
            
        }
        
    }
    
//    NSURL *url = [NSURL URLWithString:@"http://a825.phobos.apple.com/us/r2000/005/Music/d8/a8/d2/mzi.jelhjoev.aac.p.m4p"];
//    NSData *soundData = [NSData dataWithContentsOfURL:url];
//    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//    NSUserDomainMask, YES) objectAtIndex:0]
//    stringByAppendingPathComponent:@"sound.caf"];
//    [soundData writeToFile:filePath atomically:YES];
//    player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL
//				fileURLWithPath:filePath] error:NULL];
//    NSLog(@"error %@", error);
    
    func getSoundFile() -> NSURL {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        
        let soundFilePath = docsDir.stringByAppendingString("/sound.caf")
        
        return NSURL(fileURLWithPath: soundFilePath)
    }
    
    func setupAudioSession() {
        
        let soundFileURL = getSoundFile()

        var error: NSError?
        var session : AVAudioSession = AVAudioSession.sharedInstance()
        
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
    
//    func getFileURL() -> NSURL {
//        let path = getCacheDirectory().stringByAppendingPathComponent(fileName)
//        let filePath = NSURL(fileURLWithPath: path)
//        return filePath!
//    }
//    
    
    func showAudioContainer() {
        textViewDistanceToBottomOfAudioView.constant = 8
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
        self.audioViewContainer.hidden = false
    }
    
    func hideAudioContainer() {
        self.audioViewContainer.hidden = true
        textViewDistanceToBottomOfAudioView.constant = -self.audioViewContainer.frame.height
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showTextContainer() {
        self.textViewContainer.hidden = false
        self.textView.becomeFirstResponder()
    }
    
    func hideTextContainer() {
        self.textView.text = ""
        self.textView.endEditing(true)
        self.textViewContainer.hidden = true
    }
    
    @IBAction func textButtonPressed(sender: AnyObject) {
        showTextContainer()
    }
    
    @IBAction func textCloseButtonPressed(sender: AnyObject) {
        hideTextContainer()
    }
    
    @IBAction func viewWasTapped(sender: AnyObject) {
        self.textView.endEditing(true)
    }
    
    @IBAction func recordButtonPressed(sender: AnyObject) {
        
        if self.isRecording == false {
            self.audioRecordButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.redColor()], forState: UIControlState.Normal)
            showAudioContainer()
            self.audioPlayButton.hidden = true
            self.recorder?.record()
            
        } else {
            self.audioRecordButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
            self.audioPlayButton.hidden = false
            self.recorder?.stop()
            
        }
        
        self.isRecording = !self.isRecording

        
//        self.audioRecordButton.setBackgroundImage(UIImage(color: UIColor.redColor()), forState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)
//
//        
//        if self.audioViewContainer.hidden {
//            showAudioContainer()
//        } else {
//            hideAudioContainer()
//        }
    }
    
    @IBAction func audioCloseButtonPressed(sender: AnyObject) {
        hideAudioContainer()
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
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

}
