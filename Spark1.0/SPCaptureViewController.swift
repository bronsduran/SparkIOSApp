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
    var videoURL : NSURL! = nil
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var captureButton: UIBarButtonItem!
    
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let screenRect = UIScreen.mainScreen().bounds
        
        self.camera = LLSimpleCamera(quality: AVCaptureSessionPresetHigh, position: LLCameraPositionRear, videoEnabled: true)
        
        self.camera!.attachToViewController(self, withFrame: CGRectMake(0, 0, screenRect.size.width, screenRect.size.height))
        
        self.view.bringSubviewToFront(self.toolbar)
        self.view.bringSubviewToFront(self.textButton)
        self.view.bringSubviewToFront(self.audioButton)

        self.navigationController?.navigationBar.hidden = false
        
        if let image = UIImage(named: "captureButton") {
            let button = UIButton()
            button.setImage(image, forState: .Normal)
            button.frame = CGRectMake(0, 0, 45, 45)
            button.addGestureRecognizer(longPressGestureRecognizer)
            button.addGestureRecognizer(tapGestureRecognizer)
            captureButton.customView = button
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.camera.start()
        MomentSingleton.sharedInstance.image = nil
        self.image = nil
        self.videoURL = nil
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(captureButton.customView)
    }
    

    @IBAction func captureHeldDown(sender: AnyObject) {
        
        videoURL = (UIApplication.sharedApplication().delegate as! AppDelegate).applicationDocumentsDirectory.URLByAppendingPathComponent("recording").URLByAppendingPathExtension("mov")
        
        if sender.state == UIGestureRecognizerState.Began {
            print("start")
            
            print("before start: " + videoURL.path!)
            self.camera.startRecordingWithOutputUrl(videoURL)
            
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            print("stop")
            camera.stop()
            self.camera.stopRecording {
                (camera: LLSimpleCamera!, outputFileUrl: NSURL!, error: NSError!) -> Void in
                
                print(outputFileUrl)
                
                if error == nil {
                    self.videoURL = outputFileUrl
                    MomentSingleton.sharedInstance.mediaType = 1
                    MomentSingleton.sharedInstance.videoUrl = outputFileUrl
                    self.performSegueWithIdentifier("toMediaViewController", sender: self)
                    
                    print("did it")
                }
            }
        }
    }
    
    @IBAction func captureTapped(sender: AnyObject) {
        captureButtonPressed(sender)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func settingsButtonPressed(sender: AnyObject) {
        NSLog("Settings pressed!")
    }
    
    //target functions
    func buttonDown(sender:UIButton)
    {
        print("hold down")
    }
    
    func buttonUp(sender:UIButton)
    {
        print("hold release")
    }
    
    @IBAction func captureButtonPressed(sender: AnyObject) {

        if NSUserDefaults.standardUserDefaults().boolForKey("isSimulator") {
            self.performSegueWithIdentifier("toMediaViewController", sender: self)
            return
        }
        
        self.captureButton.enabled = false

        self.camera.capture {
            (camera: LLSimpleCamera!, image: UIImage!, metaData: [NSObject : AnyObject]!, error: NSError!) -> Void in
            
            if error == nil {
                camera.stop()
                self.image = image
                MomentSingleton.sharedInstance.mediaType = 0
                MomentSingleton.sharedInstance.image = image
                self.performSegueWithIdentifier("toMediaViewController", sender: self)
            }
            
            self.captureButton.enabled = true
        }
    }
    
    @IBAction func skipButtonPressed(sender: AnyObject) {
        self.captureButton.enabled = false
        self.image = nil
        self.videoURL = nil
        self.performSegueWithIdentifier("toMediaViewController", sender: sender)
        self.captureButton.enabled = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toMediaViewController" {
            let mediaViewController = segue.destinationViewController as! SPMediaViewController

            mediaViewController.initWithRecording = false
            mediaViewController.initWithText = false
            mediaViewController.image = self.image
            mediaViewController.videoURL = self.videoURL
  
            if self.image == nil &&  self.videoURL == nil {
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

