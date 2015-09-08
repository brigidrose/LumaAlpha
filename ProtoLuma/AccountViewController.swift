//
//  AccountViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/21/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

// TODO: TableView displays registered bracelet and charms from Parse, then checks and displays ble & bus connection

import UIKit

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var accountTableView:UITableView!
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var metawearManager:MBLMetaWearManager!
    var charms:[PFObject] = []
    var bracelet:MBLMetaWear!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]

        self.metawearManager = MBLMetaWearManager.sharedManager()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneButtonTapped:")
        self.navigationItem.leftBarButtonItem = doneButton
        
        self.navigationItem.title = "Settings"
        let tableViewController = UITableViewController()
        tableViewController.tableView = self.accountTableView
        self.addChildViewController(tableViewController)
        self.accountTableView = UITableView(frame: self.view.frame, style: UITableViewStyle.Plain)
        self.accountTableView.estimatedRowHeight = 50
        self.accountTableView.rowHeight = UITableViewAutomaticDimension
        self.accountTableView.delegate = self
        self.accountTableView.dataSource = self
        self.accountTableView.registerClass(ProfileBlurbTableViewCell.self, forCellReuseIdentifier: "ProfileBlurbTableViewCell")
        self.accountTableView.registerClass(ButtonWithPromptTableViewCell.self, forCellReuseIdentifier:
            "ButtonWithPromptTableViewCell")
        self.accountTableView.registerClass(CharmWithSubtitleTableViewCell.self, forCellReuseIdentifier: "CharmWithSubtitleTableViewCell")
        self.accountTableView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        self.accountTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view = self.accountTableView

        self.retrieveSavedMetaWear()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            // Profile Detail
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileBlurbTableViewCell") as! ProfileBlurbTableViewCell
            let fullName = (PFUser.currentUser()!["firstName"] as! String) + " " + (PFUser.currentUser()!["lastName"] as! String)
            cell.nameLabel.text = fullName
            let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in

            }
            
            let id = PFUser.currentUser()!["facebookId"] as! String
            let url = NSURL(string: "https://graph.facebook.com/\(id)/picture?type=large")
            
            cell.profileImageView.sd_setImageWithURL(url, completed: block)

            return cell
        case 1:
            // Bracelet
            let cell = tableView.dequeueReusableCellWithIdentifier("CharmWithSubtitleTableViewCell") as! CharmWithSubtitleTableViewCell
            let userFirstName = PFUser.currentUser()!["firstName"] as! String
            cell.charmTitle.text = "\(userFirstName)'s Luma Bracelet"
            if (self.bracelet != nil){
                cell.charmSubtitle.text = "\(self.getMBLConnectionStateString(self.bracelet.state))"
            }
            else{
                cell.charmSubtitle.text = "getting connection state..."
            }
            return cell
        case 2:
            // Charms
            if (indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1){
//                let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "commandWithSubtitle")
//                cell.textLabel?.text = "Add a New Charm"
//                cell.detailTextLabel?.text = "tap to begin"
//                cell.backgroundColor = UIColor.clearColor()
//                cell.textLabel?.textColor = UIColor.whiteColor()
//                cell.detailTextLabel?.textColor = UIColor(white: 1, alpha: 0.8)
//                cell.selectionStyle = UITableViewCellSelectionStyle.None
                let addCharmCell = tableView.dequeueReusableCellWithIdentifier("ButtonWithPromptTableViewCell") as! ButtonWithPromptTableViewCell
                addCharmCell.promptLabel.text = "Received a new Charm?"
                addCharmCell.button.setTitle("Add Charm", forState: UIControlState.Normal)
                addCharmCell.button.userInteractionEnabled = false
//                addCharmCell.button.addTarget(self, action: "addCharmButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
                return addCharmCell
            }
            else{
                let cell = tableView.dequeueReusableCellWithIdentifier("CharmWithSubtitleTableViewCell") as! CharmWithSubtitleTableViewCell
                let charm = self.charms[indexPath.row]
                cell.charmTitle.text = charm["name"] as? String
                let charmOwner = charm["owner"] as? PFUser
                if (charmOwner != nil){
                    let charmOwnerFirstName = charmOwner?["firstName"] as? String
                    let charmOwnerLastName = charmOwner?["lastName"] as? String
                    if (charmOwner != PFUser.currentUser()!){
                        cell.charmSubtitle.text = "Gifted to \(charmOwnerFirstName!) \(charmOwnerLastName!)"
                    }
                    else{
                        cell.charmSubtitle.text = "connection state"
                    }
                }
                return cell
            }
        case 3:
            switch indexPath.row{
            // Account Options
            case 0:
                let logoutCell = tableView.dequeueReusableCellWithIdentifier("ButtonWithPromptTableViewCell") as! ButtonWithPromptTableViewCell
                logoutCell.promptLabel.text = "Need some time off?"
                logoutCell.button.setTitle("Logout", forState: UIControlState.Normal)
                logoutCell.button.userInteractionEnabled = false
//                logoutCell.button.addTarget(self, action: "logoutButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
                return logoutCell

            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("ButtonWithPromptTableViewCell") as! ButtonWithPromptTableViewCell
                cell.promptLabel.text = "Want a fresh start? Reset and erase all content."
                cell.button.setTitle("Reset All Charms", forState: UIControlState.Normal)
                cell.button.userInteractionEnabled = false
//                cell.button.addTarget(self, action: "resetButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
                return cell

            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return self.charms.count + 1
        case 3:
            return 2
        default:
            return Int(0)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section{
        case 1:
            let headerView = CharmsTableViewHeader()
            headerView.sectionTitle.text = "My Bracelet"
            return headerView
        case 2:
            let headerView = CharmsTableViewHeader()
            headerView.sectionTitle.text = "My Charms"
            return headerView
        case 3:
            let headerView = CharmsTableViewHeader()
            headerView.sectionTitle.text = "My Account"
            return headerView
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0){
            return 0
        }
        else{
            return 40
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section{
        case 1: break
//            self.bracelets[indexPath.row].led.setLEDOn(false, withOptions: 1)
//            self.bracelets[indexPath.row].disconnectWithHandler({(error) -> Void in
//                print(self.bracelets[indexPath.row])
//                self.bracelets[indexPath.row].forgetDevice()
//                self.retrieveSavedMetaWear()
//            })
        case 2:
            if (indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1){
                // Add a New Charm selected
                
            }
            else{
                // Existing Charm selected
            }
//            self.charms[indexPath.row].connectWithHandler({(error) -> Void in
//                self.charms[indexPath.row].led.flashLEDColor(UIColor.blueColor(), withIntensity: 1.0)
//                print(self.charms[indexPath.row])
//                self.charms[indexPath.row].rememberDevice()
//                self.retrieveSavedMetaWear()
//            })
        default:break
        }
        
        if (indexPath == NSIndexPath(forRow: tableView.numberOfRowsInSection(2) - 1, inSection: 2)){
            self.performSegueWithIdentifier("showAddCharm", sender: self)
        }
        else if (indexPath == NSIndexPath(forRow: 0, inSection: 3)){
            self.performSegueWithIdentifier("loggedOut", sender: self)
        }
        else if (indexPath == NSIndexPath(forRow: 1, inSection: 3)){
            print("reset charms button tapped")
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func doneButtonTapped(sender:UIBarButtonItem){
        (self.parentViewController?.presentingViewController?.childViewControllers[0] as! StoriesTabViewController).loadCharms()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logoutButtonTapped(sender:UIButton){
        print("Logout button tapped")
        self.metawearManager.retrieveSavedMetaWearsWithHandler({(devices:[AnyObject]!)-> Void in
            for device in devices{
                device.forgetDevice()
            }
            PFUser.logOut()
            PFInstallation.currentInstallation()["currentUser"] = nil
            PFInstallation.currentInstallation().saveInBackgroundWithBlock({(success, error) -> Void in
                self.performSegueWithIdentifier("loggedOut", sender: self)
            })
        })
    }
    
    func addCharmButtonTapped(sender:UIButton){
        print("add charm button tapped")
        self.performSegueWithIdentifier("showAddCharm", sender: self)
    }
    
    func resetButtonTapped(sender:UIButton){
        print("reset charms button tapped")
    }
    
    func loadCharms(){
        let queryForCharms = PFQuery(className: "Charm")
        queryForCharms.whereKey("owner", equalTo: PFUser.currentUser()!)
        queryForCharms.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            self.charms = objects as! [PFObject]
            print("charms loaded")
            self.accountTableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: UITableViewRowAnimation.Automatic)
        })
        
    }
    
    // MARK: MetaWear Manager Methods
    
    func retrieveSavedMetaWear(){
        MBLMetaWearManager.sharedManager().retrieveSavedMetaWearsWithHandler({(devices:[AnyObject]!) -> Void in
            if (devices.count > 0){
                self.bracelet = devices[0] as! MBLMetaWear
                self.accountTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            else{
                print("no saved bracelet found")
            }
        })
    }
    
    func updateMetaWearTableViewSections(){
        self.accountTableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(1, 2)), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    
    func getMBLConnectionStateString(state:MBLConnectionState) -> String{
        switch state{
        case MBLConnectionState.Connected:
            return "connected"
        case MBLConnectionState.Connecting:
            return "connecting"
        case MBLConnectionState.Disconnected:
            return "disconnected"
        case MBLConnectionState.Disconnecting:
            return "disconnecting"
        case MBLConnectionState.Discovery:
            return "discovery"
        }
    }

}
