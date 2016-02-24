//
//  SPStudentViewController.swift
//  Spark1.0
//
//  Created by Lucas Throckmorton on 1/25/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//



class SPStudentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AKPickerViewDataSource, AKPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var studentInfoView: UIView!
    @IBOutlet weak var momentTableView: UITableView!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var backGround: UIImageView!
    @IBOutlet weak var nameLabel: UINavigationItem!
    @IBOutlet weak var studentInfoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var pickerView: AKPickerView!

    var imagePicker : UIImagePickerController!
    var image : UIImage?
    
    var student: Student?
    var moments: [Moment] = []
    var momentsToShow: [Moment] = []
    var categoriesToShow = Moment.momentCategories

        
    @IBAction func cameraButtonPressed(sender: UIButton) {
        if pictureImageView.image == UIImage(named: "addStudentCameraIcon") {
            
            if NSUserDefaults.standardUserDefaults().boolForKey("isSimulator") {
                return
            }
            image = nil
            imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            presentViewController(imagePicker, animated: true, completion: nil)
        }
        
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.image = image
        if let student = student {
            student.updateStudentInfo(student["firstName"] as? String, lastName: student["lastName"] as? String, phoneNumber: student["parentPhone"] as? String, parentEmail: student["parentEmail"] as? String, photo: image)
        }
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    
    }
    
    func updateStudentImageView() {
        if self.image != nil {
            self.pictureImageView.image = self.image
        } else {
            self.pictureImageView.image = UIImage(named: "addStudentCameraIcon")
        }
        self.pictureImageView.setNeedsDisplay() 
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return momentsToShow.count
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
        momentTableView.separatorColor = UIColor(red: 106/255.0, green: 117/255.0, blue: 128/255.0, alpha: 1.0)

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MomentTableViewCell
        performSegueWithIdentifier("toMomentViewController", sender: cell)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toMomentViewController"){
            if let destination = segue.destinationViewController as? SPMomentViewController,
                let cell = sender as? MomentTableViewCell,
                let moment = cell.moment {
                    destination.moment = moment
                    destination.student = student
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
        
        self.pickerView.reloadData()
        self.applyFilter(self.pickerView.selectedItem.description)
        
        
        if categoriesToShow.count == 7 {
            categoriesToShow.insert("All", atIndex: 3)
        }
        updateStudentImageView()

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
                // no picture taken image
                self.pictureImageView.image = UIImage(named: "addStudentCameraIcon")
            }
        }
        
    }
    
    func prepareUntaggedTableView() {
        studentInfoViewHeight.constant = 0
        studentInfoView.hidden = true
        nameLabel.title = "Untagged"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.pickerView.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
        self.pickerView.highlightedFont = UIFont(name: "HelveticaNeue-Bold", size: 20)!
        self.pickerView.pickerViewStyle = .Wheel
        self.pickerView.maskDisabled = false
        self.pickerView.layer.shadowColor = UIColor.lightGrayColor().CGColor
        self.pickerView.reloadData()
        addStatusBarStyle()
     
        let cellNib: UINib = UINib(nibName: "MomentTableViewCell", bundle: nil)
        momentTableView.registerNib(cellNib, forCellReuseIdentifier: "MomentTableViewCell")
              
        
        // Header
        countView.layer.cornerRadius = countView.frame.height / 2
        countView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        
        configureTableView()
      
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
        applyFilter(categoriesToShow[item])
        self.momentTableView.reloadData()
    }

}
