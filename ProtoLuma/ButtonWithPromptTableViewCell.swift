//
//  ButtonWithPromptTableViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/21/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class ButtonWithPromptTableViewCell: UITableViewCell {

    var promptLabel:UILabel!
    var button:UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.contentView.backgroundColor = UIColor(white: 1, alpha: 1)
        
        self.promptLabel = UILabel(frame: CGRectZero)
        self.promptLabel.translatesAutoresizingMaskIntoConstraints = false
        self.promptLabel.font = UIFont.systemFontOfSize(13, weight: UIFontWeightRegular)
        self.promptLabel.textColor = UIColor.blackColor()
        self.promptLabel.textAlignment = NSTextAlignment.Center
        self.promptLabel.numberOfLines = 1
        self.contentView.addSubview(self.promptLabel)
        
        self.button = UIButton(frame: CGRectZero)
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.button.layer.borderWidth = 1
        self.button.layer.borderColor = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.tintColor.CGColor
        self.button.layer.cornerRadius = 6
        self.button.setTitle("Button", forState: UIControlState.Normal)
        self.button.setTitleColor((UIApplication.sharedApplication().delegate as! AppDelegate).window?.tintColor, forState: UIControlState.Normal)
        self.button.clipsToBounds = true
        self.button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        self.button.titleLabel?.textColor = UIColor.whiteColor()
        self.button.titleLabel?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightLight)
        self.button.setBackgroundImage(self.imageWithColor(((UIApplication.sharedApplication().delegate as! AppDelegate).window?.tintColor)!), forState: UIControlState.Highlighted)
        self.button.showsTouchWhenHighlighted = false
        self.contentView.addSubview(self.button)
        
        let viewsDictionary = ["promptLabel":self.promptLabel, "button":self.button]
        let horizontalConstraintsPromptLabel = NSLayoutConstraint.constraintsWithVisualFormat("H:|->=20-[promptLabel(>=200)]->=20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(horizontalConstraintsPromptLabel)

        let horizontalConstraintPromptLabel = NSLayoutConstraint(item: self.promptLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.contentView.addConstraint(horizontalConstraintPromptLabel)
        
        let horizontalConstraintsButton = NSLayoutConstraint.constraintsWithVisualFormat("H:|->=20-[button(>=280)]->=20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(horizontalConstraintsButton)
        
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-18-[promptLabel]-12-[button(40)]-16-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(verticalConstraints)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func imageWithColor(color:UIColor) -> UIImage{
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
