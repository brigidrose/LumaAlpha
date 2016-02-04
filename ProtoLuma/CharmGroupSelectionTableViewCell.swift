//
//  CharmGroupSelectionTableViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 1/31/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit

class CharmGroupSelectionTableViewCell: UITableViewCell {

    var charmGroupSelectButton:UIButton!
    var charmImagePreviewImageView:UIImageView!
    var charmGroupTitleLabel:UILabel!
    var separatorView:UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.charmGroupSelectButton = UIButton(frame: CGRectZero)
        self.charmGroupSelectButton.translatesAutoresizingMaskIntoConstraints = false
        self.charmGroupSelectButton.backgroundColor = UIColor(white: 1, alpha: 1)
        self.contentView.addSubview(self.charmGroupSelectButton)
        
        self.charmImagePreviewImageView = UIImageView(frame: CGRectZero)
        self.charmImagePreviewImageView.translatesAutoresizingMaskIntoConstraints = false
        self.charmImagePreviewImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.charmImagePreviewImageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        self.charmGroupSelectButton.addSubview(self.charmImagePreviewImageView)
        
        self.charmGroupTitleLabel = UILabel(frame: CGRectZero)
        self.charmGroupTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.charmGroupTitleLabel.text = "Charm Group Title Label"
        self.charmGroupTitleLabel.textAlignment = NSTextAlignment.Left
        self.charmGroupTitleLabel.numberOfLines = 1
        self.charmGroupSelectButton.addSubview(self.charmGroupTitleLabel)
        
        self.separatorView = UIView(frame: CGRectZero)
        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.backgroundColor = UIColor(white: 0.8, alpha: 1)
        self.charmGroupSelectButton.addSubview(self.separatorView)
        
        let viewsDictionary = ["charmGroupSelectButton":self.charmGroupSelectButton, "charmImagePreviewImageView":self.charmImagePreviewImageView, "charmGroupTitleLabel":self.charmGroupTitleLabel, "separatorView":self.separatorView]
        let metricsDictionary = ["topPadding":15, "bottomPadding":20, "sidePadding":7.5]
        
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[charmGroupSelectButton]|", options: NSLayoutFormatOptions(rawValue:0), metrics: metricsDictionary, views: viewsDictionary)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[charmGroupSelectButton]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)

        self.contentView.addConstraints(hConstraints)
        self.contentView.addConstraints(vConstraints)
        
        let buttonHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-sidePadding-[charmImagePreviewImageView(32)]-10-[charmGroupTitleLabel]-sidePadding-|", options: [NSLayoutFormatOptions.AlignAllTop, NSLayoutFormatOptions.AlignAllBottom], metrics: metricsDictionary, views: viewsDictionary)
        self.contentView.addConstraints(buttonHConstraints)
        
        let separatorHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[separatorView]|", options: NSLayoutFormatOptions(rawValue:0), metrics: metricsDictionary, views: viewsDictionary)
        self.contentView.addConstraints(separatorHConstraints)
        
        let buttonVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[charmImagePreviewImageView(32)]-10-[separatorView(1)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        self.contentView.addConstraints(buttonVConstraints)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
    }

}
