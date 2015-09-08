//
//  StoriesTableViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/20/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class StoriesTableViewCell: UITableViewCell {

    var cardContainer:UIView!
    var storyUnits:[PFObject]!
    var storyHeroImageImageView:UIImageView!
    var storyImagePreviewCollectionView:UICollectionView!
    var storyTitleLabel:UILabel!
    var storySummaryLabel:UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.cardContainer = UIView(frame: CGRectZero)
        self.cardContainer.translatesAutoresizingMaskIntoConstraints = false
        self.cardContainer.layer.borderColor = UIColor(white: 0.85, alpha: 1).CGColor
        self.cardContainer.layer.borderWidth = 0.75
        self.cardContainer.layer.cornerRadius = 6
        self.cardContainer.clipsToBounds = true
        
        self.storyImagePreviewCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: RACollectionViewTripletLayout())
        self.storyImagePreviewCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.storyImagePreviewCollectionView.backgroundColor = UIColor(white: 0.7, alpha: 1)
        self.storyImagePreviewCollectionView.userInteractionEnabled = false
        self.storyImagePreviewCollectionView.registerClass(ImagePreviewCollectionViewCell.self, forCellWithReuseIdentifier: "ImagePreviewCollectionViewCell")

        self.cardContainer.addSubview(self.storyImagePreviewCollectionView)
        
//        self.storyHeroImageImageView = UIImageView(frame: CGRectZero)
//        self.storyHeroImageImageView.translatesAutoresizingMaskIntoConstraints = false
//        self.storyHeroImageImageView.backgroundColor = UIColor(white: 0.85, alpha: 1)
//        self.storyHeroImageImageView.contentMode = UIViewContentMode.ScaleAspectFill
//        self.storyHeroImageImageView.image = UIImage(named: "OnTopOfTheWorld")
//        self.cardContainer.addSubview(self.storyHeroImageImageView)
        
        self.storyTitleLabel = UILabel(frame: CGRectZero)
        self.storyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.storyTitleLabel.numberOfLines = 0
        self.storyTitleLabel.text = "Story Title"
        self.storyTitleLabel.textColor = UIColor(white: 0, alpha: 1)
        self.storyTitleLabel.font = UIFont.systemFontOfSize(15, weight: UIFontWeightSemibold)
        self.cardContainer.addSubview(self.storyTitleLabel)
        
        self.storySummaryLabel = UILabel(frame: CGRectZero)
        self.storySummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        self.storySummaryLabel.text = "Story Summary Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi fermentum scelerisque lectus non volutpat. Aenean vel euismod mauris, in pretium."
        self.storySummaryLabel.textColor = UIColor(white: 0.3, alpha: 1)
        self.storySummaryLabel.font = UIFont.systemFontOfSize(13, weight: UIFontWeightRegular)
        self.storySummaryLabel.numberOfLines = 0
        self.cardContainer.addSubview(self.storySummaryLabel)
        
        let cardContainerViewViewsDictionary = ["storyTitleLabel":self.storyTitleLabel, "storySummaryLabel":self.storySummaryLabel, "storyImagePreviewCollectionView":self.storyImagePreviewCollectionView]
        let cardContainerHorizontalConstraintsHeroImage = NSLayoutConstraint.constraintsWithVisualFormat("H:|[storyImagePreviewCollectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: cardContainerViewViewsDictionary)
        self.cardContainer.addConstraints(cardContainerHorizontalConstraintsHeroImage)
        
        let cardContainerHorizontalConstraintsStoryTitle = NSLayoutConstraint.constraintsWithVisualFormat("H:|-12-[storyTitleLabel]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: cardContainerViewViewsDictionary)
        self.cardContainer.addConstraints(cardContainerHorizontalConstraintsStoryTitle)
        
        let cardContainerVerticalConstraintsStoryHeroImage = NSLayoutConstraint.constraintsWithVisualFormat("V:|[storyImagePreviewCollectionView(250)]-10-[storyTitleLabel]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: cardContainerViewViewsDictionary)
        self.cardContainer.addConstraints(cardContainerVerticalConstraintsStoryHeroImage)
        
        let cardContainerVerticalConstraintsStoryTitleSummary = NSLayoutConstraint.constraintsWithVisualFormat("V:[storyTitleLabel]-4-[storySummaryLabel]-14-|", options: [NSLayoutFormatOptions.AlignAllLeft, NSLayoutFormatOptions.AlignAllRight], metrics: nil, views: cardContainerViewViewsDictionary)
        self.cardContainer.addConstraints(cardContainerVerticalConstraintsStoryTitleSummary)
        self.contentView.addSubview(self.cardContainer)
        
        let contentViewViewsDictionary = ["cardContainer":self.cardContainer]
        let contentViewHorizontalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[cardContainer]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: contentViewViewsDictionary)
        let contentViewVerticalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[cardContainer]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: contentViewViewsDictionary)
        
        self.contentView.addConstraints(contentViewHorizontalConstraints)
        self.contentView.addConstraints(contentViewVerticalConstraints)
        

        
    }
}
