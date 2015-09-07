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
    var mediaPreviewImageView:PFImageView!
    var mediaCaptionTextView:UITextView!
    let keyboardAccessoryView = UIToolbar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 44))
    var doneButton = UIBarButtonItem()

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
        
        self.mediaPreviewImageView = PFImageView(frame: CGRectZero)
        self.mediaPreviewImageView.translatesAutoresizingMaskIntoConstraints = false
        self.mediaPreviewImageView.userInteractionEnabled = true
        self.mediaPreviewImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.mediaPreviewImageView.clipsToBounds = true
        self.momentMediaSheet.addSubview(self.mediaPreviewImageView)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        doneButton.title = "Done"
        doneButton.style = UIBarButtonItemStyle.Done
        self.keyboardAccessoryView.setItems([flexSpace,doneButton], animated: true)
        
        self.mediaCaptionTextView = UITextView(frame: CGRectZero)
        self.mediaCaptionTextView.scrollsToTop = false
        self.mediaCaptionTextView.translatesAutoresizingMaskIntoConstraints = false
        self.mediaCaptionTextView.inputAccessoryView = self.keyboardAccessoryView
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

        let verticalConstraintsInsideSheet = NSLayoutConstraint.constraintsWithVisualFormat("V:|[mediaPreviewImageView(squareWidth)]-4-[mediaCaptionTextView(60)]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        self.momentMediaSheet.addConstraints(verticalConstraintsInsideSheet)
        super.updateConstraints()
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
