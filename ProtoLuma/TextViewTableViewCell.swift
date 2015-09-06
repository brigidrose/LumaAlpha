//
//  TextViewTableViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/5/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {

    var textView:JVFloatLabeledTextView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.textView = JVFloatLabeledTextView(frame: CGRectZero)
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.textView)
        
        let viewsDictionary = ["textView":self.textView]
        
        let centerXConstraint = NSLayoutConstraint(item: self.textView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.contentView.addConstraint(centerXConstraint)
        
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[textView(100)]-8-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(verticalConstraints)
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[textView]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
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
