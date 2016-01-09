//
//  CharmSettingsTableViewController.swift
//  ProtoLuma
//
//  Created by Chris on 1/9/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit

class CharmSettingsTableViewController: UITableViewController {
    
    let sectionHeaderHeight:[CGFloat] = [60, 40, 40]
    var charmGroupMembers:[User]! = []
    let buttonCellReuseIdentifier = "CharmSettingsButtonCell"
    let charmMemberReuseIdentifier = "CharmSettingsCharmMemberCell"
    var charm:Charm!
    var profileImages = [String: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: buttonCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: buttonCellReuseIdentifier)
        tableView.registerNib(UINib(nibName: charmMemberReuseIdentifier, bundle: nil), forCellReuseIdentifier: charmMemberReuseIdentifier)
        
        let queryForCharmGroupMembers = PFQuery(className: "Charm")
        queryForCharmGroupMembers.whereKey("charmGroup", equalTo: charm.charmGroup)
        queryForCharmGroupMembers.whereKey("owner", notEqualTo: PFUser.currentUser()!)
        queryForCharmGroupMembers.includeKey("owner")
        queryForCharmGroupMembers.findObjectsInBackgroundWithBlock { (charms, error) -> Void in
            if error == nil {
                for charm in charms as! [Charm]{
                    self.charmGroupMembers.append(charm.owner)
                }
                self.tableView.reloadData()
            }else{
                print(error)
            }
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 + charmGroupMembers.count
        }else if section == 1{
            return 2
        }else if section == 2{
            return 1
        }
        return 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if indexPath.section == 0 {
            if indexPath.row == 0{
//                let cell = tableView.dequeueReusableCellWithIdentifier(buttonCellReuseIdentifer, forIndexPath: indexPath) as! CharmSettingsButtonCell
//                cell.setup("+ Add People", buttonAction: addPeoplePressed)
//                return cell
                cell.textLabel!.text = "+ Add People"
                cell.textLabel!.textColor = UIColor.redColor()
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier(charmMemberReuseIdentifier, forIndexPath: indexPath) as! CharmSettingsCharmMemberCell
                let charmGroupMember = charmGroupMembers[indexPath.row - 1]
                cell.setup(charmGroupMember.fullName(), memberPhoto: profileImages[charmGroupMember.facebookId]!)
                return cell
            }
        }else if indexPath.section == 1 {
            cell.accessoryType = .DisclosureIndicator
            if indexPath.row == 0 {
                cell.textLabel!.text = "Edit Name"
                
            }else if indexPath.row == 1 {
                cell.textLabel!.text = "Report A Problem"
            }
        }else if indexPath.section == 2 {
//            let cell = tableView.dequeueReusableCellWithIdentifier(buttonCellReuseIdentifer, forIndexPath: indexPath) as! CharmSettingsButtonCell
//            cell.accessoryType = .DisclosureIndicator
//            cell.setup("Disconnect", buttonAction: disconnectPressed)
//            return cell
            cell.textLabel!.text = "Disconnect"
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel!.textColor = UIColor.redColor()
        }
        
        

        return cell
    }
    
    func addPeoplePressed(){
        print("addPeoplePressed")
    }
    
    func disconnectPressed(){
        print("disconnectPressed")
    }
    
    func editNamePressed(){
        print("editNamePressed")
    }
    
    func reportAProblemPressed(){
        print("reportAProblemPressed")
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView(frame: CGRectMake(0, 0, view.frame.width, sectionHeaderHeight[section]))
        containerView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        return containerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight[section]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                //add people
                addPeoplePressed()
            }
        }else if indexPath.section == 1 {
            if indexPath.row == 0 {
                //edit name
                editNamePressed()
            }else if indexPath.row == 1 {
                //report a problem
                reportAProblemPressed()
            }
        }else if indexPath.section == 2 {
            //disconnect
            disconnectPressed()
        }
    }

}
