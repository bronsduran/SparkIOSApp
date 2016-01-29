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

class SPMediaViewController: UIViewController, UITextViewDelegate {

    var image: UIImage! = nil
    var imageView: UIImageView! = nil
    
    @IBOutlet weak var audioViewContainer: UIView!
    @IBOutlet weak var audioCloseButton: UIButton!

    @IBOutlet weak var textViewContainer: UIView!
    @IBOutlet weak var textCloseButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var backGround: UIImageView!
    
    @IBOutlet weak var textViewDistanceToBottomOfAudioView: NSLayoutConstraint!
    
    override func viewDidLoad() {
        textViewDistanceToBottomOfAudioView.constant = -self.audioViewContainer.frame.height
        backGround.image = UIImage(named: "Login_Background")
        view.sendSubviewToBack(backGround)

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
        if self.audioViewContainer.hidden {
            showAudioContainer()
        } else {
            hideAudioContainer()
        }
    }
    
    @IBAction func audioCloseButtonPressed(sender: AnyObject) {
        hideAudioContainer()
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func tagButtonPressed(sender: AnyObject) {
        
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            self.textViewContainer.hidden = true
        }
    }

}
