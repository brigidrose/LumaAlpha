//
//  SegmentedControlTableViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/6/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class SegmentedControlTableViewCell: UITableViewCell {

    var segmentedControl:UISegmentedControl!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.segmentedControl = UISegmentedControl(items: ["", ""])
        self.segmentedControl.frame = CGRectZero
        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.segmentedControl)
        
        let viewsDictionary = ["segmentedControl":self.segmentedControl]
        
        let centerXConstraint = NSLayoutConstraint(item: self.segmentedControl, attribute: .CenterX, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterX, multiplier: 1, constant: 0)
        self.contentView.addConstraint(centerXConstraint)
        
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-14-[segmentedControl(28)]-12-|", options: .AlignAllCenterX, metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(verticalConstraints)
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[segmentedControl]-8-|", options: .AlignAllCenterY, metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(horizontalConstraints)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}
