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
    
    var input = [String?](count: 4, repeatedValue: nil)
    
    
    override func viewDidLoad() {
        let cellNib: UINib = UINib(nibName: "TextInputTableViewCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: "TextInputTableViewCell")
        
        self.addBackgroundView()
        
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
            cell.textField.attributedPlaceholder = stringForPlaceholder("First Name")
            cell.labelView.text = "First Name"
            
        case 1:
            cell.labelImage.image = UIImage(named: "Dark_Grey_Circle")
            cell.textField.attributedPlaceholder = stringForPlaceholder("Last Name")
            cell.labelView.text = "Last Name"

        case 2:
            cell.labelImage.image = UIImage(named: "Dark_Grey_Circle")
            cell.textField.attributedPlaceholder = stringForPlaceholder("123 456 7890")
            cell.labelView.text = "Parent Phone"
        case 3:
            cell.labelImage.image = UIImage(named: "Dark_Grey_Circle")
            cell.textField.attributedPlaceholder = stringForPlaceholder("example@example.com")
            cell.labelView.text = "Parent Email"
        default:
            return cell
        }
        
        if (indexPath.row < input.count) {
            if let input = input[indexPath.row] {
                cell.textField.text = input
            }
        }
        
        return cell
    }
    
    func getCellText() {
        
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? TextInputTableViewCell {
            if (indexPath.row < input.count) {
                input[indexPath.row] = cell.textField.text!
            }
        }
    }
    
    func stringForPlaceholder(text: String) -> NSAttributedString {
        let placeholderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        return NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName:placeholderColor])
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    

    @IBAction func addMoreButtonPressed(sender: AnyObject) {
        createStudent()
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        // let firstNameCell = tableView.cellForRowAtIndexPath(0) as TextInputTableViewCell
        createStudent()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func createStudent() -> Bool {
        
        // try to replace cached fields with more up to date info
        for i in 0..<tableView.visibleCells.count {
            
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! TextInputTableViewCell

            input[i] = cell.textField.text
        }
        
        for field in input {
            if field == nil {
                return false
            }
        }
        
        Student.addStudent(input[0]!, lastName: input[1]!, phoneNumber: input[2], parentEmail: input[3], photo: photoButton.imageView!.image)
        
        return true
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