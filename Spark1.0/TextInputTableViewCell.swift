//
//  TextInputCell.swift
//  Spark1.0
//
//  Created by Nathan Eidelson on 1/26/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import Foundation

class TextInputTableViewCell : UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var labelImage: UIImageView!
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // background
//        self.backgroundColor = UIColor(white: 1.0, alpha: 0.1)

        // name label
        labelView.textColor = UIColor.darkGrayColor()
        textField.textColor = UIColor.lightGrayColor()
        textField.borderStyle = UITextBorderStyle.None
        textField.delegate = self
        textField.returnKeyType = UIReturnKeyType.Default
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}