//
//  SPStudentViewController.swift
//  Spark1.0
//
//  Created by Lucas Throckmorton on 1/25/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import XLActionController

class SPStudentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var studentInfoView: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var momentTableView: UITableView!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var backGround: UIImageView!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MomentTableViewCell", forIndexPath: indexPath) as! MomentTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        let image = UIImage(named: "Untagged_Icon")
        cell.momentImageView.image = image
        
        return cell
    }
    
    func configureTableView() {
        momentTableView.backgroundColor = UIColor.clearColor()
        momentTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        momentTableView.separatorColor = UIColor(red: 106/255.0, green: 117/255.0, blue: 128/255.0, alpha: 1.0)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let momentCell = self.momentTableView.cellForRowAtIndexPath(indexPath) as! MomentTableViewCell
        
        let actionController = SpotifyActionController()
        
        actionController.headerData = SpotifyHeaderData(title: momentCell.captionLabel.text! , subtitle: "", image: momentCell.momentImageView.image!)
        
        actionController.addAction(Action(ActionData(title: "Send"), style: .Default, handler: { action in }))
        actionController.addAction(Action(ActionData(title: "Edit"), style: .Default, handler: { action in }))
        actionController.addAction(Action(ActionData(title: "Delete"), style: .Default, handler: { action in }))
        
        
        
        presentViewController(actionController, animated: true, completion: nil)

    }
    
    
    
    
    
    
    override func viewDidLoad() {
        
        
        
        let cellNib: UINib = UINib(nibName: "MomentTableViewCell", bundle: nil)
        momentTableView.registerNib(cellNib, forCellReuseIdentifier: "MomentTableViewCell")
        
        self.addBackgroundView()

     
        
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
