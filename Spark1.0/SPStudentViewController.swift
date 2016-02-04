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
    @IBOutlet weak var nameLabel: UINavigationItem!
    @IBOutlet weak var filterOptionsTableView: UITableView!
    
    @IBAction func filterButtonPressed(sender: UIButton) {
        
        if filterOptionsTableView.hidden == false {
            filterOptionsTableView.hidden = true
        } else {
            filterOptionsTableView.hidden = false
        }
    }
  
    
    var student: Student?
    var moments: [Moment]?
    var momentsToShow: [Moment]?
    var categoriesToShow = Moment.momentCategories
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count:Int?
        
        if tableView == self.filterOptionsTableView {
            count = categoriesToShow.count
        }
        
        if tableView == self.momentTableView {
            if momentsToShow == nil {
                momentsToShow = moments
            }
            count = momentsToShow?.count
        }
        
        return count!
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        if tableView == self.filterOptionsTableView {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryTableViewCell", forIndexPath: indexPath) as! CategoriesTableViewCell
            
            let categoryLabel = categoriesToShow[indexPath.row]
            cell.categoryLabel.text = categoryLabel
            
            return cell
            
        }
        
        if tableView == self.momentTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("MomentTableViewCell", forIndexPath: indexPath) as! MomentTableViewCell
            
            if let momentsToShow = momentsToShow {
                cell.withMoment(momentsToShow[indexPath.row])
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
        }
        
        var cell:MomentTableViewCell?
        
        cell = tableView.dequeueReusableCellWithIdentifier("MomentTableViewCell", forIndexPath: indexPath) as! MomentTableViewCell
        
        return cell!
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
    
    func applyFilter() {
        momentsToShow = [Moment]()
        
        if let moments = moments {
            for moment in moments {
                for category in categoriesToShow {
                    if Moment.momentCategories.indexOf(category) != nil {
                        momentsToShow?.append(moment)
                        break
                    }
                }
            }
        }
    }
    
    func refresh() {
        populateStudentInfo()
        applyFilter()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.momentTableView.reloadData()
        })
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // if this is a student table
        if let student = student {
            student.fetchMoments() { (foundMoments) -> Void in
                self.moments = foundMoments
                self.refresh()
            }
            
        // if this is an untagged moments table
        } else {
            User.current().fetchUntaggedMoments() { (foundMoments) -> Void in
                self.moments = foundMoments
                self.refresh()
            }
        }
    }
    
    func populateStudentInfo() {
        let numberOfMoments = moments == nil ? 0 : moments!.count
        countLabel.text = String(numberOfMoments)
        
        if let student = student {
            nameLabel.title = student.firstName
            if let picture = student.studentImage {
                pictureImageView.image = picture
            } else {
                // no picture taken image
                pictureImageView.image = UIImage(named: "Untagged_Icon")
            }
        } else {
            // untagged moment image
            pictureImageView.image = UIImage(named: "Untagged_Icon")
            nameLabel.title = "Untagged"
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib: UINib = UINib(nibName: "MomentTableViewCell", bundle: nil)
        momentTableView.registerNib(cellNib, forCellReuseIdentifier: "MomentTableViewCell")
        
        self.addBackgroundView()
        filterOptionsTableView.hidden = true
        
        // Header
        countView.layer.cornerRadius = countView.frame.height / 2
        countView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        
        configureTableView()
        filterButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }

}
