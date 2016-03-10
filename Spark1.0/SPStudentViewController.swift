//
//  SPStudentViewController.swift
//  Spark1.0
//
//  Created by Lucas Throckmorton on 1/25/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

class SPStudentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AKPickerViewDataSource, AKPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var momentTableView: UITableView!

    @IBOutlet weak var nameLabel: UINavigationItem!
    
    var pickerView: AKPickerView!

    var imagePicker : UIImagePickerController!
    var image : UIImage?
    
    var student: Student?
    var moments: [Moment] = []
    var momentsToShow: [Moment] = []
    var categoriesToShow = Moment.momentCategories

    var header: StudentHeaderView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.pickerView.delegate = self
//        self.pickerView.dataSource = self
//        
//        self.pickerView.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
//        self.pickerView.highlightedFont = UIFont(name: "HelveticaNeue-Bold", size: 20)!
//        self.pickerView.pickerViewStyle = .Wheel
//        self.pickerView.maskDisabled = false
//        self.pickerView.layer.shadowColor = UIColor.lightGrayColor().CGColor
//        self.pickerView.reloadData()
        addStatusBarStyle()
        
        let cellNib: UINib = UINib(nibName: "MomentTableViewCell", bundle: nil)
        momentTableView.registerNib(cellNib, forCellReuseIdentifier: "MomentTableViewCell")
        
        let headerNib: UINib = UINib(nibName: "StudentHeaderView", bundle: nil)
        momentTableView.registerNib(headerNib, forHeaderFooterViewReuseIdentifier: "StudentHeaderView")
        
        configureTableView()
    
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let pickerView = self.pickerView {
            pickerView.reloadData()
            applyFilter(self.pickerView.selectedItem.description)
        }
        
        
        if categoriesToShow.count == 7 {
            categoriesToShow.insert("All", atIndex: 3)
        }
        
        // student table

        if let student = student {
            nameLabel.title = student["firstName"] as? String

            student.moments({ (moments: [Moment]) -> Void in
                self.moments = moments
                self.applyFilter("All")
                self.momentTableView.reloadData()
                self.updateStudentHeader()
            })
        // untagged moments table
        } else {
            nameLabel.title = "Untagged"

            User.currentUser()!.untaggedMoments() { (foundMoments) -> Void in
                self.moments = foundMoments
                self.applyFilter("All")
                self.momentTableView.reloadData()
                self.updateStudentHeader()
            }
        }
    }
    

    
    @IBAction func cameraButtonPressed(sender: UIButton) {
        
        
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
        if let student = student {
            student.updateStudentInfo(nil, lastName: nil, phoneNumber: nil, parentEmail: nil, photo: image, callback: nil)
        }
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)

    
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if student != nil && section == 0 {
            let cell = self.momentTableView.dequeueReusableHeaderFooterViewWithIdentifier("StudentHeaderView")
            header = cell as? StudentHeaderView
            header?.photoButton.addTarget(self, action: "cameraButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            self.updateStudentHeader()
            return header
        } else {
            if self.pickerView == nil {
                self.pickerView = AKPickerView(frame: CGRectMake(0, 0, tableView.frame.width, 50))
                
                self.pickerView.delegate = self
                self.pickerView.dataSource = self
                
                self.pickerView.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
                self.pickerView.backgroundColor = UIColor.whiteColor()
                self.pickerView.highlightedFont = UIFont(name: "HelveticaNeue-Bold", size: 20)!
                self.pickerView.pickerViewStyle = .Wheel
                self.pickerView.maskDisabled = false
                self.pickerView.layer.shadowColor = UIColor.lightGrayColor().CGColor
                self.pickerView.reloadData()
            }
            
            return self.pickerView
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if student != nil && section == 0 {
            return 150.0
        } else {
            return 50.0
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if student == nil {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if student != nil && section == 0 {
            return 0
        } else {
            return momentsToShow.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MomentTableViewCell", forIndexPath: indexPath) as! MomentTableViewCell
        cell.withMoment(momentsToShow[indexPath.row])
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func configureTableView() {
        momentTableView.backgroundColor = UIColor.clearColor()
        momentTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        momentTableView.separatorColor = UIColor(red: 106/255.0, green: 117/255.0, blue: 128/255.0, alpha: 0.5)

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MomentTableViewCell
        if student == nil {
            performSegueWithIdentifier("Edit Moment", sender: cell)
        } else {
            performSegueWithIdentifier("toMomentViewController", sender: cell)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toMomentViewController"){
            if let destination = segue.destinationViewController as? SPMomentViewController,
                let cell = sender as? MomentTableViewCell,
                let moment = cell.moment {
                    destination.moment = moment
                    destination.student = student
            }
        } else if segue.identifier == "Edit Moment" {
            if let destination = segue.destinationViewController as? SPMediaViewController,
                let cell = sender as? MomentTableViewCell,
                let moment = cell.moment {
                    
                    MomentSingleton.sharedInstance.populateWithMoment(moment,
                        imageCB: { destination.updateWithImage() },
                        videoCB: { destination.updateWithVideoData() },
                        voiceCB: { destination.updateWithVoiceData() }
                    )
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

    
    func updateStudentHeader() {
        
        if let student = student, header = header {
            header.initWithStudent(student, withMoments: true)
        }
        
    }
    
    // MARK: - AKPickerViewDataSource
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        return self.categoriesToShow.count
    }
    
    /*
    
    Image Support
    -------------
    Please comment '-pickerView:titleForItem:' entirely and
    uncomment '-pickerView:imageForItem:' to see how it works.
    
    */
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        return self.categoriesToShow[item]
    }
    
    func pickerView(pickerView: AKPickerView, imageForItem item: Int) -> UIImage {
        return UIImage(named: self.categoriesToShow[item])!
    }
    
    // MARK: - AKPickerViewDelegate
    
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        // animations, in case we want them
        /*
        var row = 0
        if student != nil || momentsToShow.isEmpty {
            row = NSNotFound
        }
        let indexPath = NSIndexPath(forRow: row, inSection: student == nil ? 0 : 1)
        
        self.momentTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        
        let duration = Double(momentsToShow.count) * 0.04
        */
        
        /*
        UIView.animateWithDuration(0.6, animations: {
            self.momentTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
            }, completion: {
                (value: Bool) in
                self.applyFilter(self.categoriesToShow[item])
                self.momentTableView.reloadData()
        })
        */
        
        
        self.applyFilter(self.categoriesToShow[item])
        self.momentTableView.reloadData()
    }

}
