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

class SPMediaViewController: UIViewController {

    var image: UIImage! = nil
    
    @IBOutlet weak var audioViewContainer: UIView!
    @IBOutlet weak var audioCloseButton: UIButton!

    @IBOutlet weak var textViewContainer: UIView!
    @IBOutlet weak var textCloseButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let screenRect = UIScreen.mainScreen().bounds;
        
        let imageView = UIImageView(image: self.image)
        imageView.frame = screenRect
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    func showAudioContainer() {
        self.audioViewContainer.hidden = false
//        self.textViewContainer.addConstraint()
    }
    
    @IBAction func textButtonPressed(sender: AnyObject) {
        self.textViewContainer.hidden = false
        self.textView.becomeFirstResponder()
        
    }
    @IBAction func textCloseButtonPressed(sender: AnyObject) {
        self.textView.text = ""
        self.textView.endEditing(true)
        self.textViewContainer.hidden = true
    }
    
    @IBAction func viewWasTapped(sender: AnyObject) {
        self.textView.endEditing(true)
    }
    
    @IBAction func recordButtonPressed(sender: AnyObject) {
        self.audioViewContainer.hidden = !self.audioViewContainer.hidden
    }
    
    @IBAction func audioCloseButtonPressed(sender: AnyObject) {
        self.audioViewContainer.hidden = true
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func tagButtonPressed(sender: AnyObject) {
        
    }
    

}
