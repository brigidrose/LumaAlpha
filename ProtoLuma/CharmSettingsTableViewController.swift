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
    var deleteGroupMemberIndexPath: NSIndexPath? = nil
    var charmGroupMemberFbIds = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: buttonCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: buttonCellReuseIdentifier)
        tableView.registerNib(UINib(nibName: charmMemberReuseIdentifier, bundle: nil), forCellReuseIdentifier: charmMemberReuseIdentifier)
        
        self.refreshControl?.beginRefreshing()
        
        var missingFbPhotos = Set<String>()
        
        let queryForCharmGroupMembers = PFQuery(className: "Charm")
        queryForCharmGroupMembers.whereKey("charmGroup", equalTo: charm.charmGroup!)
        queryForCharmGroupMembers.whereKey("owner", notEqualTo: PFUser.currentUser()!)
        queryForCharmGroupMembers.includeKey("owner")
        queryForCharmGroupMembers.findObjectsInBackgroundWithBlock { (charms, error) -> Void in
            if error == nil {
                for charm in charms as! [Charm]{
                    self.charmGroupMembers.append(charm.owner!)
                    self.charmGroupMemberFbIds.insert(charm.owner!.facebookId)
                    if(!self.profileImages.keys.contains(charm.owner!.facebookId)){
                        missingFbPhotos.insert(charm.owner!.facebookId)
                    }
                }
                let queryForInvitedCharmGroupMembers = PFQuery(className: "User_Charm_Group")
                queryForInvitedCharmGroupMembers.whereKey("charmGroup", equalTo: self.charm.charmGroup!)
                queryForInvitedCharmGroupMembers.whereKey("user", notEqualTo: PFUser.currentUser()!)
                queryForInvitedCharmGroupMembers.whereKey("user", notContainedIn: self.charmGroupMembers) //dedup
                queryForInvitedCharmGroupMembers.includeKey("user")
                queryForInvitedCharmGroupMembers.findObjectsInBackgroundWithBlock({ (userCharmGroups, error) -> Void in
                    if error == nil {
                        for userCharmGroup in userCharmGroups as! [User_Charm_Group] {
                            self.charmGroupMembers.append(userCharmGroup.user)
                            self.charmGroupMemberFbIds.insert(userCharmGroup.user.facebookId)
                            if(!self.profileImages.keys.contains(userCharmGroup.user.facebookId)){
                                missingFbPhotos.insert(userCharmGroup.user.facebookId)
                            }
                        }
                        self.charmGroupMembersLoaded()
                        self.downloadAndSetProfilePhotos(missingFbPhotos)
                    }else{
                        print(error)
                        ParseErrorHandlingController.handleParseError(error)
                    }
                })
            }else{
                print(error)
                ParseErrorHandlingController.handleParseError(error)
            }
        }
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.backgroundColor = tableSectionHeaderColor()
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
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 && indexPath.row != 0{
            return true
        }
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteGroupMemberIndexPath = indexPath
            let charmGroupMember = charmGroupMembers[indexPath.row - 1]
            confirmDelete(charmGroupMember)
        }
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
                var memberPhoto:UIImage? = nil
                if profileImages.keys.contains(charmGroupMember.facebookId) {
                    memberPhoto = profileImages[charmGroupMember.facebookId]
                }
                cell.setup(charmGroupMember.fullName(), memberPhoto: memberPhoto)
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
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView(frame: CGRectMake(0, 0, view.frame.width, sectionHeaderHeight[section]))
        containerView.backgroundColor = tableSectionHeaderColor()
        return containerView
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 50
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2 {
            let containerView = UIView(frame: CGRectMake(0, 0, view.frame.width, 50))
            containerView.backgroundColor = tableSectionHeaderColor()
            
            let label = UILabel(frame: CGRectMake(0, 10, view.frame.width, 30))
            label.textAlignment = .Center
            label.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            formatter.timeStyle = .NoStyle
            let dateString = formatter.stringFromDate(self.charm.createdAt!)
            label.text = "Created \(dateString)"
            
            containerView.addSubview(label)
        
            return containerView
        }
        return nil
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addFriendsToCharm" {
            let dvc = segue.destinationViewController as! AddFriendsToCharmTableViewController
            dvc.charm = charm
            dvc.existingCharmGroupMemberFbIds = self.charmGroupMemberFbIds
        }
    }
    
    func charmGroupMembersLoaded(){
        self.tableView.reloadData()
    }
    
    func addPeoplePressed(){
        print("addPeoplePressed")
        self.performSegueWithIdentifier("addFriendsToCharm", sender: self)
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
    
    func removeContributor(indexPath: NSIndexPath){
        let charmGroupMember = charmGroupMembers[indexPath.row - 1]
        print("Removing \(charmGroupMember.fullName()) from charm group")
        //find the charm for this user, and remove them from being the owner, and mark the charm as unclaimed
        let removedUserCharmQuery = PFQuery(className: "Charm")
        removedUserCharmQuery.whereKey("charmGroup", equalTo: charm.charmGroup!)
        removedUserCharmQuery.whereKey("owner", equalTo: charmGroupMember)
        removedUserCharmQuery.findObjectsInBackgroundWithBlock { (charms, error) -> Void in
            if error == nil {
                //removing owner if exists
                if charms!.count > 0 {
                    let charm = charms![0] as! Charm
                    charm.owner = nil
                    charm.charmGroup = nil
                    charm.claimed = false
                    charm.saveInBackground()
                }
            }else{
                print(error)
                ParseErrorHandlingController.handleParseError(error)
            }
        }
        //remove from user_charm_group table of group invitations
        let removeFromUserCharmGroupQuery = PFQuery(className: "User_Charm_Group")
        removeFromUserCharmGroupQuery.whereKey("charmGroup", equalTo: charm.charmGroup!)
        removeFromUserCharmGroupQuery.whereKey("user", equalTo: charmGroupMember)
        removeFromUserCharmGroupQuery.findObjectsInBackgroundWithBlock { (userCharmGroups, error) -> Void in
            if error == nil {
                for userCharmGroup in userCharmGroups as! [User_Charm_Group] {
                    userCharmGroup.deleteInBackground()
                }
            }else{
                print(error)
                ParseErrorHandlingController.handleParseError(error)
            }
        }
        
        charmGroupMembers.removeAtIndex(indexPath.row - 1)
    }

    
    func confirmDelete(user: User) {
        let alert = UIAlertController(title: "Remove Contributor", message: "Are you sure you want to remove \(user.fullName())?", preferredStyle: .ActionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: handleDeleteUser)
        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelDeleteUser)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleDeleteUser(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteGroupMemberIndexPath {
            tableView.beginUpdates()
            
            removeContributor(indexPath)
            
            // Note that indexPath is wrapped in an array:  [indexPath]
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            deleteGroupMemberIndexPath = nil
            
            tableView.endUpdates()
        }
    }
    
    func cancelDeleteUser(alertAction: UIAlertAction!) {
        deleteGroupMemberIndexPath = nil
    }
    
    func downloadAndSetProfilePhotos(fbIds: Set<String>){
        print("downloadAndSetProfilePhotos")
        print(fbIds)
        var photosDownloaded = 0
        if fbIds.count > 0 {
            for id in fbIds{
                let imgURL: NSURL = NSURL(string: "https://graph.facebook.com/\(id)/picture?type=large")!
                let request: NSURLRequest = NSURLRequest(URL: imgURL)
                
                let urlSession = NSURLSession.sharedSession()
                urlSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
                    if error == nil {
                        self.profileImages[id] = RBSquareImage(UIImage(data: data!)!).circle
                        photosDownloaded++
                        print("photo downloaded in charm settings.  number \(photosDownloaded) out of \(fbIds.count)")
                        if(photosDownloaded == fbIds.count){
                            self.doneLoading()
                        }
                    }else{
                        print(error)
                        ParseErrorHandlingController.handleParseError(error)
                    }
                }.resume()
                
            }
        }else{
            doneLoading()
        }
    }
    
    func doneLoading(){
        dispatch_async(dispatch_get_main_queue()){
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }

}
