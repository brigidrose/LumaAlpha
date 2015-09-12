//
//  TextFieldTableViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/5/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {

    var textField:UITextField!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.textField = UITextField(frame: CGRectZero)
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.leftView = UIView(frame: CGRectMake(0, 0, 8, self.contentView.frame.height))
        self.textField.leftViewMode = UITextFieldViewMode.Always
        self.textField.rightView = UIView(frame: CGRectMake(0, 0, 8, self.contentView.frame.height))
        self.textField.rightViewMode = UITextFieldViewMode.Always
        self.contentView.addSubview(self.textField)
        
        
        let viewsDictionary = ["textField":self.textField]
        let centerXConstraint = NSLayoutConstraint(item: self.textField, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.contentView.addConstraint(centerXConstraint)
        
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[textField]-8-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(verticalConstraints)
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[textField]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(horizontalConstraints)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
