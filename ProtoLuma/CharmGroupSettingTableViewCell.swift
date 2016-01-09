//
//  CharmGroupSettingTableViewCell.swift
//  ProtoLuma
//
//  Created by Chris on 1/8/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit

class CharmGroupSettingTableViewCell: UITableViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var detail: UILabel!
    @IBOutlet var newConversationButton: UIButton!
    
    var parentViewController: CharmGroupSettingTableViewController!
    
    
    @IBAction func newConversationPressed(sender: AnyObject) {
        parentViewController.performSegueWithIdentifier("showNewCharmGroupName", sender: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupAsNewConversationButton() {
        title.hidden = true
        detail.hidden = true
    }
    
    func setupAsCharmChoice(charmGroup: Charm_Group) {
        newConversationButton.hidden = true
        
        title.text = charmGroup.name
        print("Charm group named \(charmGroup.name) has \(charmGroup.members.count) other members")
        var memberNames:[String] = []
        for user in charmGroup.members {
            memberNames.append(user.fullName())
        }
        detail.text = memberNames.joinWithSeparator(", ")
    }
}
