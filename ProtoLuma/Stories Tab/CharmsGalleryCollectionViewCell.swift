//
//  CharmsGalleryCollectionViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/20/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit
import ParseUI

class CharmsGalleryCollectionViewCell: UICollectionViewCell {

    var charmThumbnailImageView:PFImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
        self.layer.cornerRadius = frame.size.width/2
        self.clipsToBounds = true
        
        self.charmThumbnailImageView = PFImageView(frame: CGRectZero)
        self.charmThumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        self.charmThumbnailImageView.image = UIImage(named: "CharmThumbnail")
        self.charmThumbnailImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.contentView.alpha = 0.5
        
        self.contentView.addSubview(self.charmThumbnailImageView)


        let viewsDictionary = ["charmThumbnailImageView":self.charmThumbnailImageView]
        let horizontalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|[charmThumbnailImageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let verticalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|[charmThumbnailImageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(horizontalConstraints)
        self.contentView.addConstraints(verticalConstraints)
    }
}
