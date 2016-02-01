//
//  SPSettingsViewController.swift
//  Spark1.0
//
//  Created by Nathan Eidelson on 1/28/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation

class SPSettingsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        let cellNib: UINib = UINib(nibName: "TextInputTableViewCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: "TextInputTableViewCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.addBackgroundView()
        
        self.tableView.backgroundColor = UIColor.clearColor()
        
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
            cell.labelView.text = "Email"
        case 2:
            cell.labelImage.image = UIImage(named: "Dark_Grey_Circle")
            cell.textField.attributedPlaceholder = stringForPlaceholder("example@example.com")
            cell.labelView.text = "Password"
        case 3:
            cell.labelImage.image = UIImage(named: "Dark_Grey_Circle")
            cell.labelView.text = "Manage Students"
            cell.textField.hidden = true
        case 4:
            cell.labelImage.image = UIImage(named: "Dark_Grey_Circle")
            cell.labelView.text = "Logout"
            cell.textField.hidden = true
        default:
            return cell
        }
        return cell
    }
    
    func stringForPlaceholder(text: String) -> NSAttributedString {
        let placeholderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        return NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName:placeholderColor])
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        // TODO: CALL TO PARSE
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    
}