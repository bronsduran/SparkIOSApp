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
    @IBOutlet weak var skipButton: UIBarButtonItem!
    @IBOutlet weak var captureButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenRect = UIScreen.mainScreen().bounds
        self.addBackgroundView()
        
        self.camera = LLSimpleCamera(quality: AVCaptureSessionPresetHigh, position: LLCameraPositionRear, videoEnabled: true)
        
        self.camera!.attachToViewController(self, withFrame: CGRectMake(0, 0, screenRect.size.width, screenRect.size.height))
        
//        self.captureButton = UIButton(frame: CGRectMake(0, 0, 70.0, 70.0))
//        self.captureButton?.setBackgroundImage(UIImage(named:"Camera_Button"), forState: UIControlState.Normal)
//        self.captureButton?.addTarget(self, action: "captureButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
//        self.view.addSubview(self.captureButton!)
//        
        
        self.view.bringSubviewToFront(self.toolbar)

        self.navigationController?.navigationBar.hidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        self.camera.start()
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
                self.performSegueWithIdentifier("toMediaViewController", sender: self)
            }
            
            self.captureButton.enabled = true
        }
    }
    
    @IBAction func skipButtonPressed(sender: AnyObject) {
        self.captureButton.enabled = false
        self.image = nil
        self.performSegueWithIdentifier("toMediaViewController", sender: self)
        self.captureButton.enabled = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toMediaViewController" {
            let mediaViewController = segue.destinationViewController as! SPMediaViewController
            mediaViewController.image = self.image
        }
        
    }
    
    
    
}

// snap button to capture image
//self.snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
//self.snapButton.frame = CGRectMake(0, 0, 70.0f, 70.0f);
//self.snapButton.clipsToBounds = YES;
//self.snapButton.layer.cornerRadius = self.snapButton.width / 2.0f;
//self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
//self.snapButton.layer.borderWidth = 2.0f;
//self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
//self.snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
//self.snapButton.layer.shouldRasterize = YES;
//[self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//[self.view addSubview:self.snapButton];
