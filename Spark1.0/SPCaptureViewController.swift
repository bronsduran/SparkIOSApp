//
//  SPCaptureViewController.swift
//  Spark1.0
//
//  Created by Nathan Eidelson on 1/19/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SPCaptureViewController: UIViewController {
    
    var camera : LLSimpleCamera! = nil
    var image : UIImage! = nil
    var videoUrl : NSURL! = nil
    var isVideoRecording: Bool = false
    var isCamera: Bool = true
    var waitingForVideoFile = false
    var mediaType = 0
    

    @IBOutlet weak var toggleWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var toggleHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var visualVoiceBlur: UIVisualEffectView!
    @IBOutlet weak var captureBlur: UIVisualEffectView!
    @IBOutlet weak var visualArchiveBlur: UIVisualEffectView!
    @IBOutlet weak var visualTextBlur: UIVisualEffectView!
    @IBOutlet weak var cameraToggle: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
                
        let screenRect = UIScreen.mainScreen().bounds
        self.visualVoiceBlur.layer.cornerRadius = self.visualVoiceBlur.frame.height / 2
        self.visualVoiceBlur.layer.masksToBounds = true
        self.visualTextBlur.layer.cornerRadius = self.visualTextBlur.frame.height / 2
        self.visualTextBlur.layer.masksToBounds = true
        self.visualArchiveBlur.layer.cornerRadius = self.visualArchiveBlur.frame.height / 8
        self.visualArchiveBlur.layer.masksToBounds = true
        self.captureBlur.layer.cornerRadius = self.captureBlur.frame.height / 2
        self.captureBlur.layer.masksToBounds = true
      
        self.camera = LLSimpleCamera(quality: AVCaptureSessionPresetHigh, position: LLCameraPositionRear, videoEnabled: true)
        self.camera!.attachToViewController(self, withFrame: CGRectMake(0, 0, screenRect.size.width, screenRect.size.height))

        self.view.bringSubviewToFront(self.visualArchiveBlur)
        self.view.bringSubviewToFront(self.visualVoiceBlur)
        self.view.bringSubviewToFront(self.visualTextBlur)
        self.view.bringSubviewToFront(self.captureBlur)
        self.view.bringSubviewToFront(self.cameraToggle)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.camera.start()
        MomentSingleton.sharedInstance.image = nil
        self.image = nil
        self.videoUrl = nil
        self.isVideoRecording = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        cameraToggle.hidden = false
        
    }

    
    @IBAction func cameraToggle(sender: AnyObject) {
        setCaptureButton()
    }
    
    func setCaptureButton() {
        
        if !isCamera {
            self.toggleWidthConstraint.constant = 40
            self.toggleHeightConstraint.constant = 23
            self.captureButton.setBackgroundImage(UIImage(named: "captureButton.png"), forState: UIControlState.Normal)
            self.cameraToggle.setBackgroundImage(UIImage(named: "videoIcon.png"), forState: UIControlState.Normal)
            isCamera = true
            
        } else {
            self.toggleWidthConstraint.constant = 30
            self.toggleHeightConstraint.constant = 30
            self.captureButton.setBackgroundImage(UIImage(named: "videoCaptureButton.png"), forState: UIControlState.Normal)
            self.cameraToggle.setBackgroundImage(UIImage(named: "cameraButton.png"), forState: UIControlState.Normal)
            isCamera = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func settingsButtonPressed(sender: AnyObject) {
        NSLog("Settings pressed!")
    }
    
    func takePhoto() {
        self.captureButton.enabled = false
        
        self.camera.capture {
            (camera: LLSimpleCamera!, image: UIImage!, metaData: [NSObject : AnyObject]!, error: NSError!) -> Void in
            
            if error == nil {
                camera.stop()
                self.image = image
//                MomentSingleton.sharedInstance.mediaType = 0
//                MomentSingleton.sharedInstance.image = image
                self.mediaType = 0
                self.performSegueWithIdentifier("toMediaViewController", sender: self)
            }
            
            self.captureButton.enabled = true
        }
    }
    
    func startVideoRecord() {
        isVideoRecording = true
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let videoURL = delegate.applicationDocumentsDirectory.URLByAppendingPathComponent("recording").URLByAppendingPathExtension("mov")
        camera.startRecordingWithOutputUrl(videoURL)
        self.captureButton.setBackgroundImage(UIImage(named: "videoStopButton.png"), forState: UIControlState.Normal)

    }
    
    func endVideoRecord() {
        camera.stop()
        
        self.camera.stopRecording {
            (camera: LLSimpleCamera!, outputFileUrl: NSURL!, error: NSError!) -> Void in
            
            if error == nil {
                self.isVideoRecording = false
                self.videoUrl = outputFileUrl
                self.mediaType = 1
                self.waitingForVideoFile = false
//                MomentSingleton.sharedInstance.mediaType = 1
//                MomentSingleton.sharedInstance.videoUrl = outputFileUrl
                self.performSegueWithIdentifier("toMediaViewController", sender: self)
            }
        }
        self.captureButton.setBackgroundImage(UIImage(named: "videoCaptureButton.png"), forState: UIControlState.Normal)
    }
    
    @IBAction func captureButtonPressed(sender: AnyObject) {
        

        if NSUserDefaults.standardUserDefaults().boolForKey("isSimulator") {
            self.image = UIImage(named: "applicationBackground")
            self.performSegueWithIdentifier("toMediaViewController", sender: self)
            return
        }
        
        if isCamera {
            takePhoto()
        } else {
            if isVideoRecording {
                endVideoRecord()
            } else {
                startVideoRecord()
                cameraToggle.hidden = true
            }
        }
        

    }
    
    @IBAction func skipButtonPressed(sender: AnyObject) {
//        MomentSingleton.sharedInstance.mediaType = 0
        self.mediaType = 0
        self.captureButton.enabled = false
        self.image = nil
        self.videoUrl = nil
        self.performSegueWithIdentifier("toMediaViewController", sender: sender)
        self.captureButton.enabled = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toMediaViewController" {
            let mediaViewController = segue.destinationViewController as! SPMediaViewController

            mediaViewController.initWithRecording = false
            mediaViewController.initWithText = false
            mediaViewController.image = self.image
//            mediaViewController.videoURL = self.videoURL
            
            MomentSingleton.sharedInstance.mediaType = self.mediaType
            MomentSingleton.sharedInstance.image = self.image
            MomentSingleton.sharedInstance.videoUrl = self.videoUrl
            
            if self.image == nil &&  self.videoUrl == nil {
                let button = sender as! UIButton
                if button.tag == 0 {
                    mediaViewController.initWithRecording = true
                } else if button.tag == 1 {
                    mediaViewController.initWithText = true
                }
            }
        }
        
    }

}

