//
//  AccountViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/21/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

// TODO: TableView displays registered bracelet and charms from Parse, then checks and displays ble & bus connection

import UIKit

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var accountTableView:UITableView!
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var metawearManager:MBLMetaWearManager!
    var charms:[MBLMetaWear]!
    var bracelet:MBLMetaWear!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]

        self.metawearManager = MBLMetaWearManager.sharedManager()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneButtonTapped:")
        self.navigationItem.rightBarButtonItem = doneButton
        
        self.navigationItem.title = "Settings"
        
        self.accountTableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        self.accountTableView.translatesAutoresizingMaskIntoConstraints = false
        self.accountTableView.estimatedRowHeight = 50
        self.accountTableView.rowHeight = UITableViewAutomaticDimension
        self.accountTableView.delegate = self
        self.accountTableView.dataSource = self
        self.accountTableView.registerClass(ButtonWithPromptTableViewCell.self, forCellReuseIdentifier:
            "ButtonWithPromptTableViewCell")
        self.accountTableView.registerClass(CharmWithSubtitleTableViewCell.self, forCellReuseIdentifier: "CharmWithSubtitleTableViewCell")
        self.accountTableView.contentInset.top = 64
        self.accountTableView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        self.accountTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(self.accountTableView)

        
        let viewsDictionary = ["accountTableView":self.accountTableView]
        let horizontalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|[accountTableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let verticalConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|[accountTableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalConstraints)
        
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
            let cell = tableView.dequeueReusableCellWithIdentifier("ButtonWithPromptTableViewCell") as! ButtonWithPromptTableViewCell
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
            let cell = tableView.dequeueReusableCellWithIdentifier("CharmWithSubtitleTableViewCell") as! CharmWithSubtitleTableViewCell
            cell.charmTitle.text = "Charm Title"
            cell.charmSubtitle.text = "connection state"
            return cell
        case 3:
            switch indexPath.row{
            // Account Options
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("ButtonWithPromptTableViewCell") as! ButtonWithPromptTableViewCell
                cell.promptLabel.text = "Need some time off?"
                cell.button.setTitle("Logout", forState: UIControlState.Normal)
                cell.button.addTarget(self, action: "logoutButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("ButtonWithPromptTableViewCell") as! ButtonWithPromptTableViewCell
                cell.promptLabel.text = "Want a fresh start? Reset and erase all content."
                cell.button.setTitle("Reset All Charms", forState: UIControlState.Normal)
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
            return 0
        case 1:
            return 1
        case 2:
            return 3
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
            headerView.sectionTitle.text = "Bracelet"
            return headerView
        case 2:
            let headerView = CharmsTableViewHeader()
            headerView.sectionTitle.text = "Charms"
            return headerView
        case 3:
            let headerView = CharmsTableViewHeader()
            headerView.sectionTitle.text = "Account"
            return headerView
        default:
            return UIView()
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
        case 2: break
//            self.charms[indexPath.row].connectWithHandler({(error) -> Void in
//                self.charms[indexPath.row].led.flashLEDColor(UIColor.blueColor(), withIntensity: 1.0)
//                print(self.charms[indexPath.row])
//                self.charms[indexPath.row].rememberDevice()
//                self.retrieveSavedMetaWear()
//            })
        default:break
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func doneButtonTapped(sender:UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logoutButtonTapped(sender:UIButton){
        print("Logout button tapped")
        self.metawearManager.retrieveSavedMetaWearsWithHandler({(devices:[AnyObject]!)-> Void in
            for device in devices{
                device.forgetDevice()
            }
            PFUser.logOut()
            self.performSegueWithIdentifier("loggedOut", sender: self)
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
