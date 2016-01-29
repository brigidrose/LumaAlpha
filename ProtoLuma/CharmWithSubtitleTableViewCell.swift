//
//  CharmWithSubtitleTableViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/21/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class CharmWithSubtitleTableViewCell: UITableViewCell {

    var charmImageView:UIImageView!
    var charmTitle:UILabel!
    var charmSubtitle:UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = UIColor(white: 1, alpha: 1)
        
        self.charmImageView = UIImageView(frame: CGRectZero)
        self.charmImageView.translatesAutoresizingMaskIntoConstraints = false
        self.charmImageView.image = UIImage(named: "CharmThumbnail")
        self.contentView.addSubview(self.charmImageView)
        
        self.charmTitle = UILabel(frame: CGRectZero)
        self.charmTitle.translatesAutoresizingMaskIntoConstraints = false
        self.charmTitle.text = "Charm Title"
        self.charmTitle.textColor = UIColor.blackColor()
        self.charmTitle.font = UIFont.systemFontOfSize(15, weight: UIFontWeightRegular)
        self.charmTitle.textAlignment = NSTextAlignment.Left
        self.charmTitle.numberOfLines = 1
        self.contentView.addSubview(self.charmTitle)
        
        self.charmSubtitle = UILabel(frame: CGRectZero)
        self.charmSubtitle.translatesAutoresizingMaskIntoConstraints = false
        self.charmSubtitle.text = "Charm Subtitle"
        self.charmSubtitle.textColor = UIColor(white: 0, alpha: 0.8)
        self.charmSubtitle.font = UIFont.systemFontOfSize(13, weight: UIFontWeightLight)
        self.charmSubtitle.textAlignment = NSTextAlignment.Left
        self.charmSubtitle.numberOfLines = 1
        self.contentView.addSubview(self.charmSubtitle)
        
        self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        let viewsDicitonary = ["charmImageView":self.charmImageView, "charmTitle":self.charmTitle, "charmSubtitle":self.charmSubtitle]
        let horizontalConstraintsCharmTitle = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[charmImageView(50)]-10-[charmTitle]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDicitonary)
        self.contentView.addConstraints(horizontalConstraintsCharmTitle)
        
        let verticalConstraintsCharmImageView = NSLayoutConstraint.constraintsWithVisualFormat("V:|-16-[charmImageView(50)]-16-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDicitonary)
        self.contentView.addConstraints(verticalConstraintsCharmImageView)
        
        let verticalConstraintsCharmTitleSubtitleViews = NSLayoutConstraint.constraintsWithVisualFormat("V:|-24-[charmTitle]-2-[charmSubtitle]", options: NSLayoutFormatOptions.AlignAllLeft, metrics: nil, views: viewsDicitonary)
        self.contentView.addConstraints(verticalConstraintsCharmTitleSubtitleViews)
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
