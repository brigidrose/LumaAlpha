//
//  DateTimePickerTableViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/6/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class DateTimePickerTableViewCell: UITableViewCell {

    var dateTimePicker:UIDatePicker!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.dateTimePicker = UIDatePicker(frame: CGRectZero)
        self.dateTimePicker.translatesAutoresizingMaskIntoConstraints = false
        self.dateTimePicker.datePickerMode = UIDatePickerMode.DateAndTime
        self.contentView.addSubview(self.dateTimePicker)
        
        let viewsDictionary = ["dateTimePicker":self.dateTimePicker]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[dateTimePicker]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(horizontalConstraints)
        
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[dateTimePicker]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
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
