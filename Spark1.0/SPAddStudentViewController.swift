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

class SPAddStudentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        let cellNib: UINib = UINib(nibName: "TextInputCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: "TextInputCell")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : TextInputCell = self.tableView.dequeueReusableCellWithIdentifier("TextInputCell") as! TextInputCell
        
        switch indexPath.row {
        case 0:
            cell.labelImage = UIImageView(image: UIImage(named: "Red_Button"))
            cell.textField.placeholder = "First Last"
            cell.labelView.text = "Name"
        case 1:
            cell.labelImage = UIImageView(image: UIImage(named: "Red_Button"))
            cell.textField.placeholder = "123 456 7890"
            cell.labelView.text = "Parent Phone"
        case 2:
            cell.labelImage = UIImageView(image: UIImage(named: "Red_Button"))
            cell.textField.placeholder = "example@example.com"
            cell.labelView.text = "Parent Email"
        default:
            return cell
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    

    @IBAction func addMoreButtonPressed(sender: AnyObject) {
        
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}