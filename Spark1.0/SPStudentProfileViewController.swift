//
//  SPStudentProfileViewController.swift
//  Spark1.0
//
//  Created by Nathan Eidelson on 1/26/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SPStudentProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
                                    UIGestureRecognizerDelegate, UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var imagePicker : UIImagePickerController!
    
    @IBOutlet weak var addAnotherDeleteButton: UIBarButtonItem!
    @IBOutlet weak var doneSaveButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var titleItem: UINavigationItem!
    
    var image : UIImage?
    var input = [String?](count: 4, repeatedValue: nil)
    var didDissmiss : ((String?) -> Void)? = nil
    var editMode = false // defaults to addMode
    var student: Student? = nil
    var showCloseButton = true;
    var header: StudentHeaderView? = nil
    
    
    @IBOutlet weak var localNavigationItem: UINavigationItem!
    
    override func viewDidLoad() {
        self.title = "Add Student"
        let cellNib: UINib = UINib(nibName: "TextInputTableViewCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "TextInputTableViewCell")
        
    
        let headerNib: UINib = UINib(nibName: "StudentHeaderView", bundle: nil)
        tableView.registerNib(headerNib, forHeaderFooterViewReuseIdentifier: "StudentHeaderView")

        
        tableView.backgroundColor = UIColor.clearColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)

        UIToolbar.appearance().tintColor = UIColor.blackColor()
        
        
        if editMode {
            if let student = student {
                input[0] = student["firstName"] as? String
                input[1] = student["lastName"] as? String
                input[2] = student["parentPhone"] as? String
                input[3] = student["parentEmail"] as? String
            }
            
            addAnotherDeleteButton.title = "Delete"
            doneSaveButton.title = "Save"
        } else {
            addAnotherDeleteButton.enabled = false
        }
        doneSaveButton.enabled = false
        
        activityIndicator.hidesWhenStopped = true
        view.bringSubviewToFront(activityIndicator)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if showCloseButton {
            let closeButton = UIBarButtonItem(
                image: UIImage(named: "deleteIcon"),
                style: UIBarButtonItemStyle.Plain,
                target: self,
                action: "closeButtonPressed:"
            )
            self.navBar.topItem?.rightBarButtonItem = closeButton
        } else {
            self.navBar.topItem?.rightBarButtonItem = nil
        }
        
        self.titleItem.title = student?.displayName()
        self.navigationController
    }
    

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : TextInputTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("TextInputTableViewCell") as! TextInputTableViewCell
        
        cell.textField.delegate = self
        cell.textField.tag = indexPath.row
        
        switch indexPath.row {
        case 0:
            cell.labelImage.image = UIImage(named: "nameIcon")
            cell.textField.attributedPlaceholder = stringForPlaceholder("First Name")
            cell.labelView.text = "First Name"
        case 1:
            cell.labelImage.image = UIImage(named: "nameIcon")
            cell.textField.attributedPlaceholder = stringForPlaceholder("Last Name")
            cell.labelView.text = "Last Name"

        case 2:
            cell.labelImage.image = UIImage(named: "phoneIcon")
            cell.textField.attributedPlaceholder = stringForPlaceholder("123 456 7890")
            cell.labelView.text = "Parent Phone"
        case 3:
            cell.labelImage.image = UIImage(named: "emailIcon")
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("StudentHeaderView")
        header = cell as! StudentHeaderView
        
        updateStudentHeader(student)
        
        return header
    }
    
    func updateStudentHeader(student: Student?) {
        
        if let student = student, header = header {
            header.initWithStudent(student, withMoments: false)
        } else if let header = header {
            header.initWithoutStudent()
        }
        
        header?.photoButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        if editMode {
            header?.photoButton.enabled = true
        }
        
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? TextInputTableViewCell {
            if (indexPath.row < input.count) {
                input[indexPath.row] = cell.textField.text!
            }
        }
    }
    
    func stringForPlaceholder(text: String) -> NSAttributedString {
        let placeholderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        return NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName:placeholderColor])
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    @IBAction func addAnotherDeleteButtonPressed(sender: AnyObject) {
        if editMode {
            let studentID = student!.objectId;
            if let student = student {
                do {
                    activityIndicator.hidden = false
                    activityIndicator.startAnimating()
                    try student.delete()
                    activityIndicator.stopAnimating()
                    self.navigationController?.popViewControllerAnimated(true)
                } catch {
                    activityIndicator.stopAnimating()
                    self.presentAlertWithTitle("Delete failed.", message: "There was an error connecting to the server, and and the student could not be deleted. To delete student, try again.")
                }
                let studentsArray = User.currentUser()!["students"] as! NSMutableArray
                studentsArray.removeObject(studentID!);
                User.currentUser()!["students"] = studentsArray;
                
                User.currentUser()!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    if success {
                        print("success")
                    } else {
                        print(error)
                    }
                }
            }
        } else {
            createStudent()
            resetFields()
        }
    }
    
    @IBAction func doneSaveButtonPressed(sender: AnyObject) {
        if editMode {
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            updateInputCache()
            if let student = student {
                
                student.updateStudentInfo(input[0]!, lastName: input[1]!, phoneNumber: input[2]!, parentEmail: input[3]!, photo: image, callback: { (success) -> Void in
                    if success {
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        self.presentAlertWithTitle("Save failed.", message: "There was an error connecting to the server, and changes couldn't be saved. To save changes, try again.")
                    }
                })
                
            }
        } else {
            let created : Bool = createStudent()
            
            if created {
                User.currentUser()?.refreshStudents({ (success) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                    let studentName = self.input[0]! + " " + self.input[1]!
                    self.didDissmiss?(studentName)
                })
            }
        }
        
    }
    
    func updateInputCache() {
        // try to replace cached fields with more up to date info
        for i in 0..<tableView.numberOfRowsInSection(0) {
            
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TextInputTableViewCell {
                input[i] = cell.textField.text
            }
        }
    }
    
    func createStudent() -> Bool {
        
        updateInputCache()
        
        for field in input {
            if field == nil {
                return false
            }
        }
        
        Student.addStudent(input[0]!, lastName: input[1]!, phoneNumber: input[2], parentEmail: input[3], photo: self.image)
        return true
    }
    
    func resetFields() {
        
        image = nil
        updatePhotoButtonImage()
        
        for i in 0..<tableView.numberOfRowsInSection(0) {
            
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! TextInputTableViewCell
            
            cell.textField.text = ""
            input[i] = nil
        }

    }
    
    func updatePhotoButtonImage() {

        if image != nil {
            header?.photoButton.setImage(image, forState: UIControlState.Normal)
        } else {
            header?.photoButton.imageView?.image = UIImage(named: "addStudentCameraIcon")
        }
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        User.currentUser()?.refreshStudents({ (success) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    @IBAction func photoButtonPressed(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().boolForKey("isSimulator") {
            return
        }
        image = nil
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.image = image
        updatePhotoButtonImage()
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        considerEnablingButtons()
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
    
    func keyboardWillBeShown(notification: NSNotification) {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            if let userInfo = notification.userInfo {
                if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                    let contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
                    self.tableView.contentInset = contentInset
                }
            }
        })
    }
    
    func keyboardWillBeHidden (notification: NSNotification) {
        let contentInset = UIEdgeInsetsZero
        tableView.contentInset = contentInset
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        updateInputCache()
        considerEnablingButtons()
    }
    
    func considerEnablingButtons() {
        var enableButtons = true
        for str in input {
            if str == nil || str! == ""{
                enableButtons = false
            }
        }
        
        if !editMode {
            addAnotherDeleteButton.enabled = enableButtons
        }
        doneSaveButton.enabled = enableButtons
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.superview;
        
        let nextRow: NSInteger = textField.tag + 1;

        if let nextCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: nextRow, inSection: 0)) {
            let nextCellAsTextInput = nextCell as! TextInputTableViewCell
            nextCellAsTextInput.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false // We do not want UITextField to insert line-breaks.
    }
    
}