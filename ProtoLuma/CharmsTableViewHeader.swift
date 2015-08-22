//
//  CharmsTableViewHeader.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/21/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class CharmsTableViewHeader: UIView {

    var sectionTitle:UILabel!
    var sectionSeparator:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 0.1, alpha: 1)
        
        self.sectionTitle = UILabel(frame: CGRectZero)
        self.sectionTitle.translatesAutoresizingMaskIntoConstraints = false
        self.sectionTitle.text = "Section Title"
        self.sectionTitle.textColor = UIColor.whiteColor()
        self.sectionTitle.font = UIFont.systemFontOfSize(16, weight: UIFontWeightRegular)
        self.addSubview(self.sectionTitle)
        
        self.sectionSeparator = UIView(frame: CGRectZero)
        self.sectionSeparator.translatesAutoresizingMaskIntoConstraints = false
        self.sectionSeparator.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.sectionSeparator)
        
        let viewsDictionary = ["sectionTitle":self.sectionTitle, "sectionSeparator":self.sectionSeparator]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[sectionTitle]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-4-[sectionTitle][sectionSeparator(2)]|", options: [NSLayoutFormatOptions.AlignAllLeft, NSLayoutFormatOptions.AlignAllRight], metrics: nil, views: viewsDictionary)
        self.addConstraints(horizontalConstraints)
        self.addConstraints(verticalConstraints)
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
