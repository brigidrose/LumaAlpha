//
//  ProfileBlurbTableViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/3/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class ProfileBlurbTableViewCell: UITableViewCell {

    var profileImageView:UIImageView!
    var nameLabel:UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = UIColor(white: 1, alpha: 1)
        
        self.profileImageView = UIImageView(frame: CGRectZero)
        self.profileImageView.translatesAutoresizingMaskIntoConstraints = false
        self.profileImageView.layer.cornerRadius = 50
        self.profileImageView.clipsToBounds = true
        self.profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
//        self.profileImageView.layer.borderWidth = 1
//        self.profileImageView.layer.borderColor = UIColor(white: 1, alpha: 1).CGColor
        self.profileImageView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(self.profileImageView)
        
        self.nameLabel = UILabel(frame: CGRectZero)
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.text = "firstName LastName"
        self.nameLabel.font = UIFont.systemFontOfSize(20, weight: UIFontWeightRegular)
        self.nameLabel.textAlignment = NSTextAlignment.Center
        self.nameLabel.textColor = UIColor.blackColor()
        self.contentView.addSubview(self.nameLabel)
        
        let viewsDictionary = ["profileImageView":self.profileImageView, "nameLabel":self.nameLabel]
        let verticalConstraint = NSLayoutConstraint(item: self.profileImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
        self.contentView.addConstraint(verticalConstraint)
        
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-40-[profileImageView(100)]-18-[nameLabel]-30-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(verticalConstraints)
        
        let imageViewHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|->=0-[profileImageView(100)]->=0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(imageViewHConstraints)
        
        let nameLabelHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|->=0-[nameLabel]->=0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(nameLabelHConstraints)
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
