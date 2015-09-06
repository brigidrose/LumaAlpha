//
//  MomentMediaTableViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/5/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class MomentMediaTableViewCell: UITableViewCell {

    var momentMediaSheet:UIView!
    var mediaPreviewImageView:UIImageView!
    var mediaCaptionTextView:JVFloatLabeledTextView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.momentMediaSheet = UIView(frame: CGRectZero)
        self.momentMediaSheet.translatesAutoresizingMaskIntoConstraints = false
        self.momentMediaSheet.layer.borderWidth = 1
        self.momentMediaSheet.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
        self.momentMediaSheet.layer.cornerRadius = 6
        self.momentMediaSheet.backgroundColor = UIColor.whiteColor()
        self.momentMediaSheet.clipsToBounds = true
        self.contentView.addSubview(self.momentMediaSheet)
        
        self.mediaPreviewImageView = UIImageView(frame: CGRectZero)
        self.mediaPreviewImageView.translatesAutoresizingMaskIntoConstraints = false
        self.mediaPreviewImageView.userInteractionEnabled = true
        self.mediaPreviewImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.mediaPreviewImageView.clipsToBounds = true
        self.momentMediaSheet.addSubview(self.mediaPreviewImageView)
        
        self.mediaCaptionTextView = JVFloatLabeledTextView(frame: CGRectZero)
        self.mediaCaptionTextView.translatesAutoresizingMaskIntoConstraints = false
        self.momentMediaSheet.addSubview(self.mediaCaptionTextView)
        
        let viewsDictionary = ["mediaPreviewImageView":self.mediaPreviewImageView, "mediaCaptionTextView":self.mediaCaptionTextView, "momentMediaSheet":self.momentMediaSheet]
        
        let metricsDictionary = ["squareWidth":UIScreen.mainScreen().bounds.width - 18]
        
        let horizontalConstraintsOutsideSheet = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[momentMediaSheet]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        self.contentView.addConstraints(horizontalConstraintsOutsideSheet)

        let verticalConstraintsOutsideSheet = NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[momentMediaSheet]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        self.contentView.addConstraints(verticalConstraintsOutsideSheet)
        
        let horizontalConstraintsInsideSheet = NSLayoutConstraint.constraintsWithVisualFormat("H:|[mediaPreviewImageView]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: metricsDictionary, views: viewsDictionary)
        self.momentMediaSheet.addConstraints(horizontalConstraintsInsideSheet)
        
        let horizontalConstraintsInsideSheetForCaption = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[mediaCaptionTextView]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        self.momentMediaSheet.addConstraints(horizontalConstraintsInsideSheetForCaption)

        let verticalConstraintsInsideSheet = NSLayoutConstraint.constraintsWithVisualFormat("V:|[mediaPreviewImageView(squareWidth)]-4-[mediaCaptionTextView(>=60)]-8-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: metricsDictionary, views: viewsDictionary)
        self.momentMediaSheet.addConstraints(verticalConstraintsInsideSheet)
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
