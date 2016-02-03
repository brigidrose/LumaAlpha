//
//  MomentMediaTableViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/5/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit
import SZTextView
import ParseUI

class MomentMediaTableViewCell: UITableViewCell, UITextViewDelegate {

    var momentMediaSheet:UIView!
    var mediaPreviewImageView:PFImageView!
    var mediaCaptionTextView:SZTextView!
    let keyboardAccessoryView = UIToolbar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 44))
    var separatorView:UIView!
    var doneButton = UIBarButtonItem()
    var momentImage:UIImage!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = nil
        self.momentMediaSheet = UIView(frame: CGRectZero)
        self.momentMediaSheet.translatesAutoresizingMaskIntoConstraints = false
//        self.momentMediaSheet.layer.borderWidth = 1
//        self.momentMediaSheet.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
//        self.momentMediaSheet.layer.cornerRadius = 6
        self.momentMediaSheet.backgroundColor = nil
//        self.momentMediaSheet.clipsToBounds = true
        self.contentView.addSubview(self.momentMediaSheet)
        
        self.mediaPreviewImageView = PFImageView(frame: CGRectZero)
        self.mediaPreviewImageView.translatesAutoresizingMaskIntoConstraints = false
        self.mediaPreviewImageView.userInteractionEnabled = true
        self.mediaPreviewImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.momentMediaSheet.addSubview(self.mediaPreviewImageView)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        doneButton.title = "Done"
        doneButton.style = UIBarButtonItemStyle.Done
        self.keyboardAccessoryView.setItems([flexSpace,doneButton], animated: true)
        
        self.mediaCaptionTextView = SZTextView(frame: CGRectZero)
        self.mediaCaptionTextView.placeholder = "Description (Optional)"
        self.mediaCaptionTextView.scrollsToTop = false
        self.mediaCaptionTextView.translatesAutoresizingMaskIntoConstraints = false
        self.mediaCaptionTextView.inputAccessoryView = self.keyboardAccessoryView
        self.mediaCaptionTextView.font = UIFont.systemFontOfSize(17)
        self.mediaCaptionTextView.contentInset = UIEdgeInsetsMake(-2,-4,0,0)
        self.mediaCaptionTextView.backgroundColor = nil
        self.momentMediaSheet.addSubview(self.mediaCaptionTextView)
        
        self.separatorView = UIView(frame: CGRectZero)
        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.backgroundColor = UIColor.blackColor()
        self.momentMediaSheet.addSubview(self.separatorView)
        
        


    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getScaledSizeOfImage(image: UIImage, toSize: CGSize) -> CGSize {
        let widthRatio = toSize.width/image.size.width
        let heightRatio = toSize.height/image.size.height
        let scale = min(widthRatio, heightRatio)
        let imageWidth = scale*image.size.width
        let imageHeight = scale*image.size.height
        return CGSizeMake(imageWidth, imageHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.momentMediaSheet.removeConstraints(self.momentMediaSheet.constraints)
        
        let height:CGFloat!
        
        if self.mediaPreviewImageView.image != nil{
            let scale = self.mediaPreviewImageView.image!.size.width / UIScreen.mainScreen().bounds.width
            height = self.mediaPreviewImageView.image!.size.height / scale
        }
        else{
            height = 0
        }

        let viewsDictionary = ["mediaPreviewImageView":self.mediaPreviewImageView, "mediaCaptionTextView":self.mediaCaptionTextView, "momentMediaSheet":self.momentMediaSheet, "separatorView":self.separatorView]
        let metricsDictionary = ["height":height]
        
        let horizontalConstraintsOutsideSheet = NSLayoutConstraint.constraintsWithVisualFormat("H:|[momentMediaSheet]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        self.contentView.addConstraints(horizontalConstraintsOutsideSheet)
        
        let verticalConstraintsOutsideSheet = NSLayoutConstraint.constraintsWithVisualFormat("V:|[momentMediaSheet]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        self.contentView.addConstraints(verticalConstraintsOutsideSheet)
        
        let horizontalConstraintsInsideSheet = NSLayoutConstraint.constraintsWithVisualFormat("H:|[mediaPreviewImageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        self.momentMediaSheet.addConstraints(horizontalConstraintsInsideSheet)
        
        let horizontalConstraintsSeparator = NSLayoutConstraint.constraintsWithVisualFormat("H:|[separatorView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        self.momentMediaSheet.addConstraints(horizontalConstraintsSeparator)
        
        let horizontalConstraintsInsideSheetForCaption = NSLayoutConstraint.constraintsWithVisualFormat("H:|[mediaCaptionTextView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        self.momentMediaSheet.addConstraints(horizontalConstraintsInsideSheetForCaption)
        
        let verticalConstraintsInsideSheet = NSLayoutConstraint.constraintsWithVisualFormat("V:|[mediaPreviewImageView(height)]-8-[mediaCaptionTextView(60)]-8-[separatorView(1)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary, views: viewsDictionary)
        self.momentMediaSheet.addConstraints(verticalConstraintsInsideSheet)

    }
}
