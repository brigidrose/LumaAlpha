//
//  ImagePreviewCollectionViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/7/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class ImagePreviewCollectionViewCell: UICollectionViewCell {

    var imagePreviewImageView:PFImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
        self.imagePreviewImageView = PFImageView(frame: CGRectZero)
        self.imagePreviewImageView.translatesAutoresizingMaskIntoConstraints = false
        self.imagePreviewImageView.image = UIImage(named: "CharmThumbnail")
        self.imagePreviewImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.imagePreviewImageView.clipsToBounds = true
        self.contentView.alpha = 1
        
        self.contentView.addSubview(self.imagePreviewImageView)
        
        
        let viewsDictionary = ["imagePreviewImageView":self.imagePreviewImageView]
        let horizontalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imagePreviewImageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let verticalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imagePreviewImageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(horizontalConstraints)
        self.contentView.addConstraints(verticalConstraints)
    }
}
