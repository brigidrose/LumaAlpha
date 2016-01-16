//
//  CharmSettingsCharmMemberCell.swift
//  ProtoLuma
//
//  Created by Chris on 1/9/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit

class CharmSettingsCharmMemberCell: UITableViewCell {

    @IBOutlet var memberPhoto: UIImageView!
    @IBOutlet var memberName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
    }

    
    func setup(memberName:String, memberPhoto:UIImage?){
        self.memberName.text = memberName
        self.memberPhoto.image = memberPhoto
    }
    
}
