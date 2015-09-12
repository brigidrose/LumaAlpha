//
//  LocationPickerTableViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/6/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit
import MapKit

class LocationPickerTableViewCell: UITableViewCell {

    var mapView:MKMapView!
    var longPressGestureRecognizer:UILongPressGestureRecognizer!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.mapView = MKMapView(frame: CGRectZero)
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.mapView)
        
        self.longPressGestureRecognizer = UILongPressGestureRecognizer()
        self.mapView.addGestureRecognizer(self.longPressGestureRecognizer)
        
        let viewsDictionary = ["mapView":self.mapView]
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[mapView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(horizontalConstraints)

        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[mapView(300)]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
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
