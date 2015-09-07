//
//  CharmTitleBlurbHeaderTableViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/20/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class CharmTitleBlurbHeaderTableViewCell: UITableViewCell {

    var charmTitleLabel:UILabel!
    var charmBlurbLabel:UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.charmTitleLabel = UILabel(frame: CGRectZero)
        self.charmTitleLabel.text = "Charm Title"
        self.charmTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.charmTitleLabel.numberOfLines = 0
        self.charmTitleLabel.textAlignment = NSTextAlignment.Center
        self.charmTitleLabel.font = UIFont.systemFontOfSize(18, weight: UIFontWeightSemibold)
        self.contentView.addSubview(self.charmTitleLabel)
        
        self.charmBlurbLabel = UILabel(frame: CGRectZero)
        self.charmBlurbLabel.text = "Charm Blurb"
        self.charmBlurbLabel.translatesAutoresizingMaskIntoConstraints = false
        self.charmBlurbLabel.numberOfLines = 0
        self.charmBlurbLabel.textAlignment = NSTextAlignment.Center
        self.charmBlurbLabel.font = UIFont.systemFontOfSize(13, weight: UIFontWeightRegular)
        self.charmBlurbLabel.textColor = UIColor(white: 0.3, alpha: 1)
        self.contentView.addSubview(self.charmBlurbLabel)
        
        let viewsDictionary = ["charmTitleLabel":self.charmTitleLabel, "charmBlurbLabel":self.charmBlurbLabel]
        let horizontalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[charmTitleLabel]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let verticalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[charmTitleLabel]-2-[charmBlurbLabel]-20-|", options: [NSLayoutFormatOptions.AlignAllRight, NSLayoutFormatOptions.AlignAllLeft], metrics: nil, views: viewsDictionary)
        
        self.contentView.addConstraints(horizontalConstraints)
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

}
