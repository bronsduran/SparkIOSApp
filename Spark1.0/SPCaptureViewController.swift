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
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var captureButton: UIBarButtonItem!
    
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
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.camera.start()
        MomentSingleton.sharedInstance.image = nil
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        UIToolbar.appearance().tintColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func settingsButtonPressed(sender: AnyObject) {
        NSLog("Settings pressed!")
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
                MomentSingleton.sharedInstance.image = image
                self.performSegueWithIdentifier("toMediaViewController", sender: self)
            }
            
            self.captureButton.enabled = true
        }
    }
    
    @IBAction func skipButtonPressed(sender: AnyObject) {
        self.captureButton.enabled = false
        self.image = nil
        self.performSegueWithIdentifier("toMediaViewController", sender: sender)
        self.captureButton.enabled = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toMediaViewController" {
            let mediaViewController = segue.destinationViewController as! SPMediaViewController

            mediaViewController.initWithRecording = false
            mediaViewController.initWithText = false
            mediaViewController.image = self.image
            
            if self.image == nil {
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

