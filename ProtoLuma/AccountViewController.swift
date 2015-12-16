//
//  AccountViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/21/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

// TODO: TableView displays registered bracelet and charms from Parse, then checks and displays ble & bus connection

import UIKit
import SDWebImage
class AccountViewController: UITableViewController {
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var metawearManager:MBLMetaWearManager!
    var charms:[PFObject] = []
    var bracelet:MBLMetaWear!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]

        
        
        self.metawearManager = MBLMetaWearManager.sharedManager()
        
//        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneButtonTapped:")
//        self.navigationItem.leftBarButtonItem = doneButton
        
        self.tableView = UITableView(frame: self.view.frame, style: UITableViewStyle.Plain)
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(ProfileBlurbTableViewCell.self, forCellReuseIdentifier: "ProfileBlurbTableViewCell")
        self.tableView.registerClass(ButtonWithPromptTableViewCell.self, forCellReuseIdentifier:
            "ButtonWithPromptTableViewCell")
        self.tableView.registerClass(CharmWithSubtitleTableViewCell.self, forCellReuseIdentifier: "CharmWithSubtitleTableViewCell")
        self.tableView.backgroundColor = UIColor(white: 1, alpha: 1)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
//        let queryForBracelets = PFQuery(className: "Bracelet")
//        let braceletId:String! = PFUser.currentUser()!["bracelet"].objectId
//        print("Looking for bracelet id "+braceletId)
//        queryForBracelets.whereKey("objectId", equalTo: braceletId)
//        do{
//            let bracelets:[PFObject] = try queryForBracelets.findObjects()
//            print("bracelets found.  count: \(bracelets.count)")
//            for bracelet in bracelets{
//                print("Bracelet serialNumber for user is: "+String(bracelet["serialNumber"]))
//            }
//            
//        }catch{
//            print("Querying for bracelets failed")
//        }
        
        self.retrieveSavedMetaWear()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.title = "Settings"
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showAddCharm") {
//            let svc = segue.destinationViewController.childViewControllers[0] as! AddCharmViewController
//            var numCharms = 0;
//            let userId = PFUser.currentUser()!.objectId
//            for(var i = 0; i < self.charms.count; i++){
//                let owner = self.charms[i]["owner"].objectId
//                print("Charm owner: "+String(owner))
//                print("Current user id: "+String(userId))
//                if(owner == userId){
//                    numCharms++;
//                }
//            }
//            svc.numCharms = numCharms;
        }
    }
    
    // MARK: Table View methods
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            // Profile Detail
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileBlurbTableViewCell") as! ProfileBlurbTableViewCell
            var fullName:String = "No Name"
            if (PFUser.currentUser()!["firstName"] != nil && PFUser.currentUser()!["lastName"] != nil){
                fullName = (PFUser.currentUser()!["firstName"] as! String) + " " + (PFUser.currentUser()!["lastName"] as! String)
            }
            cell.nameLabel.text = fullName
            let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in

            }
            if (PFUser.currentUser()!["facebookId"] != nil){
                let id = PFUser.currentUser()!["facebookId"] as! String
                let url = NSURL(string: "https://graph.facebook.com/\(id)/picture?type=large")
                cell.profileImageView.sd_setImageWithURL(url, completed: block)
            }
            
            return cell
        case 1:
            // Bracelet
            let cell = tableView.dequeueReusableCellWithIdentifier("CharmWithSubtitleTableViewCell") as! CharmWithSubtitleTableViewCell
            var userFirstName = "No Name"
            if (PFUser.currentUser()!["firstName"] != nil){
                userFirstName = PFUser.currentUser()!["firstName"] as! String
            }
            cell.charmTitle.text = "\(userFirstName)'s Luma Bracelet"
            if (self.bracelet != nil){
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                if(appDelegate.latestBatteryLife != nil){
                    let batteryLife:Int! = appDelegate.latestBatteryLife
                    cell.charmSubtitle.text = "\(self.getMBLConnectionStateString(self.bracelet.state)) - \(batteryLife)%"
                }else{
                    cell.charmSubtitle.text = "\(self.getMBLConnectionStateString(self.bracelet.state))"
                }
            }
            else{
                cell.charmSubtitle.text = "not connected"
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
//                addCharmCell.button.userInteractionEnabled = false
                addCharmCell.button.addTarget(self, action: "checkButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
                return addCharmCell
            }
            else{
                let cell = tableView.dequeueReusableCellWithIdentifier("CharmWithSubtitleTableViewCell") as! CharmWithSubtitleTableViewCell
                let charm = self.charms[indexPath.row]
                cell.charmTitle.text = charm["name"] as? String
//                let charmOwner = charm["owner"] as? PFUser
//                if (charmOwner != nil){
//                    let charmOwnerFirstName = charmOwner?["firstName"] as? String
//                    let charmOwnerLastName = charmOwner?["lastName"] as? String
//                    if (charmOwner != PFUser.currentUser()!){
//                        cell.charmSubtitle.text = "Gifted to \(charmOwnerFirstName!) \(charmOwnerLastName!)"
//                    }
//                    else{
//                        cell.charmSubtitle.text = "connection state"
//                    }
//                }
                if(charm["gifter"] as? PFUser == PFUser.currentUser()!){
                    cell.charmSubtitle.text = "Gifted"
                }else{
                    cell.charmSubtitle.text = "Owned"
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
//                logoutCell.button.userInteractionEnabled = false
                logoutCell.button.addTarget(self, action: "checkButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
                return logoutCell

            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("ButtonWithPromptTableViewCell") as! ButtonWithPromptTableViewCell
                cell.promptLabel.text = "Want a fresh start? Reset and erase all content."
                cell.button.setTitle("Reset All Charms", forState: UIControlState.Normal)
//                cell.button.userInteractionEnabled = false
                cell.button.addTarget(self, action: "checkButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
                return cell

            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0){
            return 0
        }
        else{
            return 40
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section{
        case 1:
//            self.bracelets[indexPath.row].led.setLEDOn(false, withOptions: 1)
//            self.bracelets[indexPath.row].disconnectWithHandler({(error) -> Void in
//                print(self.bracelets[indexPath.row])
//                self.bracelets[indexPath.row].forgetDevice()
//                self.retrieveSavedMetaWear()
//            })
            self.performSegueWithIdentifier("loggedInWithoutBracelet", sender: self)
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
        
//        if (indexPath == NSIndexPath(forRow: tableView.numberOfRowsInSection(2) - 1, inSection: 2)){
//            self.performSegueWithIdentifier("showAddCharm", sender: self)
//        }
//        else if (indexPath == NSIndexPath(forRow: 0, inSection: 3)){
//            self.performSegueWithIdentifier("loggedOut", sender: self)
//        }
//        else if (indexPath == NSIndexPath(forRow: 1, inSection: 3)){
//            print("reset charms button tapped")
//        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        switch indexPath.section{
        case 1:
            
            self.metawearManager.retrieveSavedMetaWearsWithHandler({(devices:[AnyObject]!) -> Void in
                if (devices.count > 0){
                    let bracelet = devices[0] as! MBLMetaWear
                    if (bracelet.state != MBLConnectionState.Connected){
                        bracelet.connectWithHandler({(error) -> Void in
                            print("reconnected with \(bracelet.deviceInfo.serialNumber)")
                            //get battery life and upload
                            self.showBraceletInfoAlert(bracelet)
                        })
                    }
                    else{
                        print("\(bracelet) already connected")
                        self.showBraceletInfoAlert(bracelet)
                    }
                }
                else{
                    print("no saved bracelet found in appdelegate")
                }
            })
        default: break
        }
    }
    
    func showBraceletInfoAlert(device: MBLMetaWear){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        device.readBatteryLifeWithHandler({ (num, err) -> Void in
            let batteryLife:Int! = Int(num)
            appDelegate.latestBatteryLife = batteryLife
            let alert = UIAlertController(title: "Bracelet Info", message: "Battery Life: \(batteryLife)%\nBracelet ID: \(device.deviceInfo.serialNumber)", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } as MBLNumberHandler)
        
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
//    func doneButtonTapped(sender:UIBarButtonItem){
//        (self.parentViewController?.presentingViewController?.childViewControllers[0] as! StoriesTabViewController).loadCharms()
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    func checkButtonTapped(sender:AnyObject){
        print("check button tapped")
        print((sender as! UIButton).center)
        let buttonPosition:CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)
        if (indexPath == NSIndexPath(forRow: self.tableView.numberOfRowsInSection(2) - 1, inSection: 2)){
            // Add Charm
            self.addCharmButtonTapped()
        }
        else if (indexPath == NSIndexPath(forRow: 0, inSection: 3)){
            // Logout
            self.logoutButtonTapped()
        }
        else if (indexPath == NSIndexPath(forRow: 1, inSection: 3)){
            // Reset
            self.resetButtonTapped()
        }
    }
    
    func logoutButtonTapped(){
        print("Logout button tapped")
        self.metawearManager.retrieveSavedMetaWearsWithHandler({(devices:[AnyObject]!)-> Void in
            if devices.count > 0{
                for device in devices{
                    device.forgetDevice()
                }
            }
            FBSDKAccessToken.setCurrentAccessToken(nil)
            PFUser.logOut()
            PFInstallation.currentInstallation().removeObjectForKey("currentUser")
            PFInstallation.currentInstallation().saveInBackgroundWithBlock({(success, error) -> Void in
                self.performSegueWithIdentifier("loggedOut", sender: self)
            })
        })
    }
    
    func addCharmButtonTapped(){
        print("add charm button tapped")
        self.performSegueWithIdentifier("showAddCharm", sender: self)
    }
    
    func resetButtonTapped(){
        print("reset charms button tapped")
    }
    
    func loadCharms(){
        let queryForCharms = PFQuery(className: "Charm")
        queryForCharms.whereKey("owner", equalTo: PFUser.currentUser()!)
        queryForCharms.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            self.charms = objects!
            print("charms loaded")
            self.tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: UITableViewRowAnimation.Automatic)
        })
        
    }
    
    // MARK: MetaWear Manager Methods
    
    func retrieveSavedMetaWear(){
        MBLMetaWearManager.sharedManager().retrieveSavedMetaWearsWithHandler({(devices:[AnyObject]!) -> Void in
            if (devices.count > 0){
                self.bracelet = devices[0] as! MBLMetaWear
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            else{
                print("no saved bracelet found")
//                self.metawearManager.startScanForMetaWearsAllowDuplicates(false, handler: {(devices:[AnyObject]!) -> Void in
//                    print("scanned for metawear")
//                    for device in devices as! [MBLMetaWear]{
//                        // Loop connect to all devices and drop connection until matches bracelet on file, needs solution where ble advertises serialNumber
//                        print(device)
//                        if (device.state == MBLConnectionState.Connected){
//                            print("already connected to new bracelet")
//                        }
//                        else{
//                            self.bracelet = device
//                            //pair and remember
//                            print(self.bracelet.state.rawValue)
//                            
//                            self.bracelet.connectWithHandler({(error) -> Void in
//                                if (error == nil){
//                                    print("bracelet name: ")
//                                    print(self.bracelet.deviceInfo.serialNumber)
//                                    self.bracelet.setConfiguration(BraceletSettings(), handler: {(error) -> Void in
//                                        print("bracelet configured")
//                                        self.bracelet.rememberDevice()
//                                        //self.performSegueWithIdentifier("RegisteredAndPaired", sender: self)
//                                        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Automatic)
//                                    })
//                                }
//                                else{
//                                    print(error)
//                                }
//                            })
//
//                     
//                        }
//                    }
//                })

            }
        })
    }
    
    func updateMetaWearTableViewSections(){
        self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(1, 2)), withRowAnimation: UITableViewRowAnimation.Automatic)
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
