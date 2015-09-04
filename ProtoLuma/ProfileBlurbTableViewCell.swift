//
//  ProfileBlurbTableViewCell.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/3/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class ProfileBlurbTableViewCell: UITableViewCell {

    var profileImageView:UIImageView!
    var nameLabel:UILabel!
    
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
