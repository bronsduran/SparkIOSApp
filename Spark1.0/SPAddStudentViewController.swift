//
//  SPAddStudentViewController.swift
//  Spark1.0
//
//  Created by Nathan Eidelson on 1/26/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SPAddStudentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
                                    UIGestureRecognizerDelegate, UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var imagePicker : UIImagePickerController!
    
    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var backGround: UIImageView!
    override func viewDidLoad() {
        let cellNib: UINib = UINib(nibName: "TextInputTableViewCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: "TextInputTableViewCell")
        backGround.image = UIImage(named: "Login_Background")
        view.sendSubviewToBack(backGround)
        
        self.tableView.backgroundColor = UIColor.clearColor()
        
        self.photoButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        self.photoButton.imageView?.layer.cornerRadius = self.photoButton.frame.width / 2.0
        self.photoButton.imageView?.clipsToBounds = true
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : TextInputTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("TextInputTableViewCell") as! TextInputTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.labelImage.image = UIImage(named: "Dark_Grey_Circle")
            cell.textField.attributedPlaceholder = stringForPlaceholder("First Last")
            cell.labelView.text = "Name"
        case 1:
            cell.labelImage.image = UIImage(named: "Dark_Grey_Circle")
            cell.textField.attributedPlaceholder = stringForPlaceholder("123 456 7890")
            cell.labelView.text = "Parent Phone"
        case 2:
            cell.labelImage.image = UIImage(named: "Dark_Grey_Circle")
            cell.textField.attributedPlaceholder = stringForPlaceholder("example@example.com")
            cell.labelView.text = "Parent Email"
        default:
            return cell
        }
        
        return cell
    }
    
    func stringForPlaceholder(text: String) -> NSAttributedString {
        let placeholderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        return NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName:placeholderColor])
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    

    @IBAction func addMoreButtonPressed(sender: AnyObject) {
        
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func photoButtonPressed(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().boolForKey("isSimulator") {
            return
        }
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        photoButton.setImage(image, forState: UIControlState.Normal)
        self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func viewWasTapped(sender: AnyObject) {
        for cell in self.tableView.visibleCells {
            let cell = cell as! TextInputTableViewCell
            cell.textField.resignFirstResponder()
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        if touch.view != nil && touch.view!.isKindOfClass(UITextField) {
            return false
        }
        return true
    }
    
}