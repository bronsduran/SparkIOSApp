//
//  SPStudentViewController.swift
//  Spark1.0
//
//  Created by Lucas Throckmorton on 1/25/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

class SPStudentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var studentInfoView: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var momentTableView: UITableView!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SPStudentViewCell", forIndexPath: indexPath) as! SPStudentViewCell
        
        let image = UIImage(named: "Untagged_Icon")
        cell.momentImageView.image = image
        
        return cell
    }
    
    func configureTableView() {
        momentTableView.backgroundColor = UIColor.clearColor()
        momentTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        momentTableView.separatorColor = UIColor(red: 106/255.0, green: 117/255.0, blue: 128/255.0, alpha: 1.0)
    }
    
    override func viewDidLoad() {
        
        // set view's background color
        view.backgroundColor = UIColor(patternImage: UIImage(named: "General_Background")!)
        
        // Header
        countView.layer.cornerRadius = countView.frame.height / 2
        countView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        // use real data...
        pictureImageView.image = UIImage(named: "Untagged_Icon")
        countLabel.text = "\(6)"
        
        configureTableView()
        filterButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        
    }
}
