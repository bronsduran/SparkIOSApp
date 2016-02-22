//
//  SPMomentViewController.swift
//  Spark1.0
//
//  Created by Lucas Throckmorton on 2/8/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import UIKit


class SPMomentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate {
    
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var audioView: UIView!
    
    @IBAction func playButton(sender: UIButton) {
        self.player?.play()
    }
    
    
    var moment: Moment!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib: UINib = UINib(nibName: "MomentDetailTableViewCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: "MomentDetailTableViewCell")
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "applicationBackground")!)
        
        moment.getFileNamed("momentData") { (data: NSData?) -> Void in
            if data != nil {
                self.imageView.image = UIImage(data: data!)
                self.imageView.layer.masksToBounds = true
                self.imageView.layer.cornerRadius = 10
            } else {
                self.imageView.hidden = true
                
            }
        }
    
        if let notes = moment["notes"] as? String {
            captionLabel.text = notes
        } else {
            captionLabel.text = "No notes were taken with this moment."
        }
        captionLabel.textColor = UIColor.whiteColor()
        
        moment.getFileNamed("voiceData", callback: { (data: NSData?) -> Void in
            if data != nil {
                do {
                    self.player = try AVAudioPlayer(data: data!)
                    self.player?.delegate = self
                    self.player?.prepareToPlay()
                } catch let error as NSError {
                    print("ERROR with setting up player", error.localizedDescription)
                }
            } else {
                self.audioView.hidden = true

            }
        })

        addStatusBarStyle()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("MomentDetailTableViewCell") as! MomentDetailTableViewCell
        switch indexPath.row {
        case 0:
            cell.functionLabel.text = "Send"
        case 1:
            cell.functionLabel.text = "Edit"
        case 2:
            cell.functionLabel.text = "Delete"
        default:
            return cell
        }
        cell.backgroundColor = UIColor(white: 1.0, alpha: 0.4)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
