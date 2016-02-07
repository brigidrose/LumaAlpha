//
//  SegmentedHeaderView.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 2/7/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit

class SegmentedHeaderView: UITableViewHeaderFooterView {

    var segmentedControl:UISegmentedControl!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.segmentedControl = UISegmentedControl(items: ["Time", "Location"])
        self.segmentedControl.frame = CGRectZero
        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.segmentedControl)
        
        let viewsDictionary = ["segmentedControl":self.segmentedControl]
        let metricsDictionary = ["sidePadding":7.5, "verticalPadding":8]
        
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-sidePadding-[segmentedControl]-sidePadding-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-verticalPadding-[segmentedControl(28)]-verticalPadding-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        
        self.contentView.addConstraints(hConstraints)
        self.contentView.addConstraints(vConstraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
