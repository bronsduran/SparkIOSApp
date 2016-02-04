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
    @IBOutlet weak var filterOptionsLabel: UILabel!
    @IBOutlet weak var studentInfoViewHeight: NSLayoutConstraint!

    
    @IBAction func filterButtonPressed(sender: UIButton) {
        
        
        
        
        if filterOptionsTableView.hidden == false {
            
                filterOptionsTableView.hidden = true
                categoriesToShow = Moment.momentCategories
                refresh()
                momentTableView.hidden = false
        
        } else {
            
                filterOptionsTableView.hidden = false
                momentTableView.hidden = true
                filterOptionsLabel.hidden = true
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
            count = Moment.momentCategories.count
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
        
        var cell: MomentTableViewCell?
        
        cell = tableView.dequeueReusableCellWithIdentifier("MomentTableViewCell", forIndexPath: indexPath) as! MomentTableViewCell
        return cell!
    }
    
    func configureTableView() {
        momentTableView.backgroundColor = UIColor.clearColor()
        momentTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        momentTableView.separatorColor = UIColor(red: 106/255.0, green: 117/255.0, blue: 128/255.0, alpha: 1.0)
        
        filterOptionsTableView.backgroundColor = UIColor.clearColor()
        filterOptionsTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        filterOptionsTableView.separatorColor = UIColor(red: 106/255.0, green: 117/255.0, blue: 128/255.0, alpha: 1.0)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == momentTableView {
        
        let momentCell = self.momentTableView.cellForRowAtIndexPath(indexPath) as! MomentTableViewCell
        
        let actionController = SpotifyActionController()
        
        actionController.headerData = SpotifyHeaderData(title: momentCell.captionLabel.text! , subtitle: "", image: momentCell.momentImageView.image!)
        
        actionController.addAction(Action(ActionData(title: "Send"), style: .Default, handler: { action in }))
        actionController.addAction(Action(ActionData(title: "Edit"), style: .Default, handler: { action in }))
        actionController.addAction(Action(ActionData(title: "Delete"), style: .Default, handler: { action in }))
        
        
        
        presentViewController(actionController, animated: true, completion: nil)
        }
        
        else if tableView == filterOptionsTableView {
        
        let categoryCell = self.filterOptionsTableView.cellForRowAtIndexPath(indexPath) as! CategoriesTableViewCell
            
        let selected = categoryCell.categoryLabel.text
    
            
            categoriesToShow.removeAll()
            categoriesToShow.append(selected!)
            refresh()
            filterOptionsLabel.hidden = false
            filterOptionsLabel.text = selected
            filterButton.titleLabel?.hidden = true
          
            
            filterOptionsTableView.hidden = true
            momentTableView.hidden = false
            }
            
            
        

    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 115
    }
    
    func applyFilter() {
        momentsToShow = [Moment]()
        
        if let moments = moments {
            for moment in moments {
                for category in moment.categoriesTagged! {
                    if categoriesToShow.indexOf(category) != nil {
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
                
                pictureImageView.contentMode = UIViewContentMode.ScaleAspectFill
                pictureImageView.layer.cornerRadius = pictureImageView.frame.height / 2
                pictureImageView.layer.masksToBounds = true
                pictureImageView.layer.opaque = false
            } else {
                // no picture taken image
                pictureImageView.image = UIImage(named: "Untagged_Icon")
            }
        } else {
            studentInfoViewHeight.constant = 0
            studentInfoView.hidden = true
            nameLabel.title = "Untagged"
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let momentCellNib: UINib = UINib(nibName: "CategoriesTableViewCell", bundle: nil)
        filterOptionsTableView.registerNib(momentCellNib, forCellReuseIdentifier: "CategoryTableViewCell")
        
        
        let cellNib: UINib = UINib(nibName: "MomentTableViewCell", bundle: nil)
        momentTableView.registerNib(cellNib, forCellReuseIdentifier: "MomentTableViewCell")
        
        self.addBackgroundView()
        filterOptionsLabel.hidden = true
        filterOptionsTableView.hidden = true
        
        // Header
        countView.layer.cornerRadius = countView.frame.height / 2
        countView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        
        configureTableView()
        filterButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }

}
