//
//  SPSettingsViewController.swift
//  Spark1.0
//
//  Created by Nathan Eidelson on 1/28/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation

class SPSettingsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleBar: UINavigationItem!
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    let NUM_INPUT_CELLS = 3
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        closeButton.tintColor = UIColor.blackColor()
        var cellNib: UINib = UINib(nibName: "TextInputTableViewCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: "TextInputTableViewCell")
        
        cellNib = UINib(nibName: "ButtonTableViewCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: "ButtonTableViewCell")

        self.tableView.delegate = self
        self.tableView.dataSource = self

        addStatusBarStyle()

        self.tableView.backgroundColor = UIColor.clearColor()
        
        self.tableView.tableFooterView = UIView()

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        var cell: TextInputTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("TextInputTableViewCell") as! TextInputTableViewCell
        
        if indexPath.row < NUM_INPUT_CELLS {
            
            var cell = self.tableView.dequeueReusableCellWithIdentifier("TextInputTableViewCell") as! TextInputTableViewCell
            switch indexPath.row {
            case 0:
                cell.labelImage.image = UIImage(named: "nameIcon")
                cell.textField.attributedPlaceholder = stringForPlaceholder("First Last")
                cell.labelView.text = "Name"
            case 1:
                cell.labelImage.image = UIImage(named: "phoneIcon")
                cell.textField.attributedPlaceholder = stringForPlaceholder("123 456 7890")
                cell.labelView.text = "Email"
            case 2:
                cell.labelImage.image = UIImage(named: "passwordIcon")
                cell.textField.attributedPlaceholder = stringForPlaceholder("example@example.com")
                cell.labelView.text = "Password"
            default:
                return cell
            }
            
            return cell
            
        } else {
            var cell = self.tableView.dequeueReusableCellWithIdentifier("ButtonTableViewCell") as! ButtonTableViewCell
            switch indexPath.row {
            case 3:
                cell.labelImage.image = UIImage(named: "addStudentDark")
                cell.labelView.text = "Manage Students"
                
                cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "manageStudentsButtonPressed"))
                
            case 4:
                cell.labelImage.image = UIImage(named: "logoutIcon")
                cell.labelView.text = "Logout"
                cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "logoutButtonPressed"))

            default:
                return cell
            }
            return cell

        }
        
    }
    
    func stringForPlaceholder(text: String) -> NSAttributedString {
        let placeholderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        return NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName:placeholderColor])
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func manageStudentsButtonPressed() {
    
        let manageStudentsViewController = SPManageStudentsViewController(collectionViewLayout: UICollectionViewLayout())
        
        self.navigationController?.pushViewController(manageStudentsViewController, animated: true)
    }
    
    func logoutButtonPressed() {
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "is_logged_in")
        
        let appDelegate = UIApplication.sharedApplication().delegate
        
        let rootController : UIViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("SPLoginViewController")
        
        let navigationController : UINavigationController = UINavigationController(rootViewController: rootController)
        
        appDelegate?.window??.rootViewController = navigationController
        
    }

    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        // TODO: CALL TO PARSE
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func viewWasTapped(sender: AnyObject) {
        for cell in self.tableView.visibleCells {
            if self.tableView.indexPathForCell(cell)!.row < NUM_INPUT_CELLS {
                let cell = cell as! TextInputTableViewCell
                cell.textField.resignFirstResponder()
            }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {

        if touch.view != nil && touch.view!.isKindOfClass(UITextField) {
            return false
        }
        return true
    }
    
    func keyboardWasShown(notification: NSNotification) {
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
    
    
}