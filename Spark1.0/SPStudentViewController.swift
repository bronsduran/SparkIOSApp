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
    @IBOutlet weak var backGround: UIImageView!
    @IBOutlet weak var nameLabel: UINavigationItem!
    @IBOutlet weak var filterOptionsTableView: UITableView!
    @IBOutlet weak var studentInfoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var filterButtonHeight: NSLayoutConstraint!
    
    var student: Student?
    var moments: [Moment] = []
    var momentsToShow: [Moment] = []
    var categoriesToShow = Moment.momentCategories
    
    
    @IBAction func filterButtonPressed(sender: UIButton) {
        
        if filterOptionsTableView.hidden == false {
            hideFilterOptions()
            applyFilter("All")
            self.momentTableView.reloadData()
        } else {
            showFilterOptions()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func showFilterOptions() {
        self.filterButton.setTitle("All", forState: UIControlState.Normal)
        filterOptionsTableView.hidden = false
        momentTableView.hidden = true
    }
    
    func hideFilterOptions() {
        filterOptionsTableView.hidden = true
        momentTableView.hidden = false
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == filterOptionsTableView {
            return Moment.momentCategories.count
            
        } else if tableView == momentTableView {
            return momentsToShow.count
        
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == self.filterOptionsTableView {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryTableViewCell", forIndexPath: indexPath) as! CategoriesTableViewCell
            let categoryLabel = Moment.momentCategories[indexPath.row]
            cell.categoryLabel.text = categoryLabel
            
            return cell
            
        } else if tableView == self.momentTableView {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("MomentTableViewCell", forIndexPath: indexPath) as! MomentTableViewCell
            cell.withMoment(momentsToShow[indexPath.row])
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
            
        } else {
            return tableView.dequeueReusableCellWithIdentifier("MomentTableViewCell", forIndexPath: indexPath) as! MomentTableViewCell
        }

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
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! MomentTableViewCell
            performSegueWithIdentifier("toMomentViewController", sender: cell)
        
        } else if tableView == filterOptionsTableView {
            
            let categoryCell = self.filterOptionsTableView.cellForRowAtIndexPath(indexPath) as! CategoriesTableViewCell
            let selected = categoryCell.categoryLabel.text
            applyFilter(selected!)
            self.momentTableView.reloadData()
            
            filterButton.setTitle(selected, forState: UIControlState.Normal)
            hideFilterOptions()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toMomentViewController"){
            if let destination = segue.destinationViewController as? SPMomentViewController,
                let cell = sender as? MomentTableViewCell,
                let moment = cell.moment {
                    destination.moment = moment
            }
        }
    }
    
    func applyFilter(filter: String) {
        momentsToShow = [Moment]()
        
        for moment in moments {
            if moment.categoriesTagged().indexOf(filter) != nil || filter == "All" {
                momentsToShow.append(moment)
            }
        }

        momentsToShow.sortInPlace { (moment1: Moment, moment2: Moment) -> Bool in
            return moment1.createdAt!.compare(moment2.createdAt!) == NSComparisonResult.OrderedDescending
        }
    }
    
    func dateFromString(string: String?) -> NSDate? {
        if string != nil {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
            return dateFormatter.dateFromString(string!)
        } else {
            return nil
        }
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // if this is a student table
        if let student = student {
            populateStudentInfo(student)
            
            if !student.hasFetchedMoments {
                student.refreshMoments({ (success) -> Void in
                    if success {
                        student.hasFetchedMoments = true
                        student.moments({ (moments: [Moment]) -> Void in
                            self.moments = moments
                            self.applyFilter("All")
                            self.momentTableView.reloadData()
                        })
                    }
                })
            } else {
                student.moments({ (moments: [Moment]) -> Void in
                    self.moments = moments
                    self.applyFilter("All")
                    self.momentTableView.reloadData()
                })
            }
            
        // if this is an untagged moments table
        } else {
            prepareUntaggedTableView()
            User.currentUser()!.untaggedMoments() { (foundMoments) -> Void in
                self.moments = foundMoments
                self.applyFilter("All")
                self.momentTableView.reloadData()
            }
        }
    }
    
    func populateStudentInfo(student: Student) {
        let numberOfMoments = moments.count
        countLabel.text = String(numberOfMoments)
        
        nameLabel.title = student["firstName"] as? String
        
        student.image { (image: UIImage?) -> Void in
            if image != nil {
                self.pictureImageView.image = image
                self.pictureImageView.contentMode = UIViewContentMode.ScaleAspectFill
                self.pictureImageView.layer.cornerRadius = self.pictureImageView.frame.height / 2
                self.pictureImageView.layer.masksToBounds = true
                self.pictureImageView.layer.opaque = false
            } else {
                self.pictureImageView.image = UIImage(named: "Untagged_Icon")
            }
        }
        
    }
    
    func prepareUntaggedTableView() {
        studentInfoViewHeight.constant = 0
        studentInfoView.hidden = true
        nameLabel.title = "Untagged"
        filterButtonHeight.constant = 0
        filterButton.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let momentCellNib: UINib = UINib(nibName: "CategoriesTableViewCell", bundle: nil)
        filterOptionsTableView.registerNib(momentCellNib, forCellReuseIdentifier: "CategoryTableViewCell")
        
        
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
