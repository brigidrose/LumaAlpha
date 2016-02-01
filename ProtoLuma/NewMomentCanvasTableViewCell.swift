//
//  NewMomentCanvasTableViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 1/31/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import JVFloatLabeledTextField

class NewMomentCanvasTableViewCell: UITableViewCell {

    var metaLabel:TTTAttributedLabel!
    var momentTitleTextField:UITextField!
    var momentDescriptionTextView:JVFloatLabeledTextView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
