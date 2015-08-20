//
//  StoriesCollectionViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/19/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class StoriesCollectionViewCell: UICollectionViewCell {

    var cardContainerView:UIView!
    var keyImageView:UIImageView!
    var storySummaryLabel:UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.cardContainerView = UIView(frame: CGRectZero)
        self.cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.cardContainerView)
        
        let storiesCollectionViewViewsDictionary = ["cardContainerView":self.cardContainerView]
        let storiesCollectionViewMetricsDictionary = ["sideMargin":8]

        let storiesCollectionViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-sideMargin-[cardContainerView]-sideMargin-|", options: NSLayoutFormatOptions(rawValue:0), metrics: storiesCollectionViewMetricsDictionary, views: storiesCollectionViewViewsDictionary)
        
        let storiesCollectionViewVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[cardContainerView]|", options: NSLayoutFormatOptions(rawValue:0), metrics: storiesCollectionViewMetricsDictionary, views: storiesCollectionViewViewsDictionary)
        
        self.addConstraints(storiesCollectionViewHorizontalConstraints)
        self.addConstraints(storiesCollectionViewVerticalConstraints)
        
        self.keyImageView = UIImageView(frame: CGRectZero)
        self.keyImageView.translatesAutoresizingMaskIntoConstraints = false
        self.keyImageView.backgroundColor = UIColor.blueColor()
        self.cardContainerView.addSubview(self.keyImageView)
        
        self.storySummaryLabel = UILabel(frame: CGRectZero)
        self.storySummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        self.storySummaryLabel.text = "Story Summary"
        self.cardContainerView.addSubview(self.storySummaryLabel)
        
        let cardContainerViewViewsDictionary = ["keyImageView":self.keyImageView, "storySummaryLabel":self.storySummaryLabel]
        let cardContainerViewMetricsDictionary = ["sideMargin":4]
        
        let cardContainerViewViewHorizontalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-sideMargin-[keyImageView]-sideMargin-|", options: NSLayoutFormatOptions(rawValue:0), metrics: cardContainerViewMetricsDictionary, views: cardContainerViewViewsDictionary)
        
        let cardContainerViewViewVerticalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[keyImageView(200)]-sideMargin-[storySummaryLabel]-12-|", options: [.AlignAllLeft, .AlignAllRight], metrics: cardContainerViewMetricsDictionary, views: cardContainerViewViewsDictionary)
        
        self.cardContainerView.addConstraints(cardContainerViewViewHorizontalConstraints)
        self.cardContainerView.addConstraints(cardContainerViewViewVerticalConstraints)
        
        
    }
}
