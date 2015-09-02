//
//  AccountViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/21/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var accountTableView:UITableView!
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var connectedBeansArray:[PTDBean] = []
    var disconnectedBeansArray:[PTDBean] = []
    var discoveredBeansArray:[PTDBean] = []
    var metawearManager:MBLMetaWearManager!
    var devices:[MBLMetaWear] = []
    var savedDevices:[MBLMetaWear] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateDataSourceArray()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]

        self.metawearManager = MBLMetaWearManager.sharedManager()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "beanManagerDidDiscoverBean", name: "beanManagerDidDiscoverBean", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "beanManagerDidConnectBean", name: "beanManagerDidConnectBean", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "beanManagerDidDisconnectBean", name: "beanManagerDidDisconnectBean", object: nil)

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "doneButtonTapped:")
        self.navigationItem.leftBarButtonItem = doneButton
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Done, target: self, action: "logoutButtonTapped:")
        self.navigationItem.rightBarButtonItem = logoutButton

        self.navigationItem.title = "Account"
        
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
            let cell = tableView.dequeueReusableCellWithIdentifier("ButtonWithPromptTableViewCell") as! ButtonWithPromptTableViewCell
            cell.promptLabel.text = "Have a new Luma Bracelet or Charm?"
            cell.button.setTitle("Begin Setup", forState: UIControlState.Normal)
            cell.button.addTarget(self, action: "setupButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("CharmWithSubtitleTableViewCell") as! CharmWithSubtitleTableViewCell
            let metaWearForCell = self.savedDevices[indexPath.row]
            cell.charmTitle.text = "\(metaWearForCell.name)"
            cell.charmSubtitle.text = "\(metaWearForCell.deviceInfo.serialNumber)"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("CharmWithSubtitleTableViewCell") as! CharmWithSubtitleTableViewCell
            let metaWearForCell = self.devices[indexPath.row]
            cell.charmTitle.text = "\(metaWearForCell.name)"
            cell.charmSubtitle.text = "\(metaWearForCell.deviceInfo.serialNumber)"
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("ButtonWithPromptTableViewCell") as! ButtonWithPromptTableViewCell
            cell.promptLabel.text = "Want a fresh start? Reset and erase all content."
            cell.button.setTitle("Reset All Charms", forState: UIControlState.Normal)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            return self.savedDevices.count
        case 2:
            return self.devices.count
        case 3:
            return 1
        default:
            return Int(0)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var charmStringOnCount = "Charms"
        switch section{
        case 1:
            let headerView = CharmsTableViewHeader()
            if (self.savedDevices.count == 0){
                charmStringOnCount = "No Charms"
            }
            else if (self.savedDevices.count == 1){
                charmStringOnCount = "Charm"
            }
            headerView.sectionTitle.text = "\(self.savedDevices.count) \(charmStringOnCount) Connected"
            return headerView
        case 2:
            let headerView = CharmsTableViewHeader()
            if (self.devices.count == 0){
                charmStringOnCount = "No Charms"
            }
            else if (self.devices.count == 1){
                charmStringOnCount = "Charm"
            }
            headerView.sectionTitle.text = "\(self.devices.count) \(charmStringOnCount) Discovered"
            return headerView
        default:
            return UIView()
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 || section == 3){
            return 0
        }
        else{
            return 40
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section{
        case 1:
            self.savedDevices[indexPath.row].led.setLEDOn(false, withOptions: 1)
            self.savedDevices[indexPath.row].disconnectWithHandler({(error) -> Void in
                print(self.savedDevices[indexPath.row])
                self.savedDevices[indexPath.row].forgetDevice()
                self.retrieveSavedMetaWear()
            })
        case 2:
            self.devices[indexPath.row].connectWithHandler({(error) -> Void in
                self.devices[indexPath.row].led.flashLEDColor(UIColor.blueColor(), withIntensity: 1.0)
                print(self.devices[indexPath.row])
                self.devices[indexPath.row].rememberDevice()
                self.retrieveSavedMetaWear()
            })
        default:break
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func doneButtonTapped(sender:UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logoutButtonTapped(sender:UIBarButtonItem){
        print("Logout button tapped")
        PFUser.logOut()
        self.performSegueWithIdentifier("loggedOut", sender: self)
    }
    
    func setupButtonTapped(){
        print("Setup button tapped")
    }
    
    // Bean methods
    
    func beanManagerDidDiscoverBean(){
        self.updateDataSourceArray()
        self.accountTableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(1, 2)), withRowAnimation: UITableViewRowAnimation.Automatic)
        print("did discovered bean")
    }
    
    func beanManagerDidConnectBean(){
        self.updateDataSourceArray()
        self.accountTableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(1, 2)), withRowAnimation: UITableViewRowAnimation.Automatic)
        print("did connect to bean")
    }
    
    func beanManagerDidDisconnectBean(){
        self.updateDataSourceArray()
        self.accountTableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(1, 2)), withRowAnimation: UITableViewRowAnimation.Automatic)
        print("did disconnect bean")
    }
    
    // Refresh data source array with updated bean dictionaries
    func updateDataSourceArray(){
        
        let keysOfConnectedBeans = self.appDelegate.connectedBeans.allKeys
        let keysOfDisconnectedBeans = self.appDelegate.disconnectedBeans.allKeys
        let keysOfDiscoveredBeans = self.appDelegate.beans.allKeys
        
//        for key in keysOfConnectedBeans{
//            if (keysOfDiscoveredBeans.contains(key)){
//                let indexToRemove = keysOfDiscoveredBeans.indexOf(key)
//                keysOfDiscoveredBeans.removeAtIndex(indexToRemove!)
//            }
//        }
        
        
        
        self.connectedBeansArray = self.appDelegate.connectedBeans.objectsForKeys(keysOfConnectedBeans, notFoundMarker: NSNull()) as! [PTDBean]
        self.disconnectedBeansArray = self.appDelegate.disconnectedBeans.objectsForKeys(keysOfDisconnectedBeans, notFoundMarker: NSNull()) as! [PTDBean]
        self.discoveredBeansArray = self.appDelegate.beans.objectsForKeys(keysOfDiscoveredBeans, notFoundMarker: NSNull()) as! [PTDBean]
        
    }
    
    // MARK: MetaWear Manager Methods
    
    func startScanning(){
        self.metawearManager.startScanForMetaWearsAllowDuplicates(false, handler: {(devices:[AnyObject]!) -> Void in
            for device in devices{
                if !self.savedDevices.contains(device as! MBLMetaWear){
                    self.devices.append(device as! MBLMetaWear)
                }
                else{
                   self.devices.removeAtIndex(self.devices.indexOf(device as! MBLMetaWear)!)
                }
            }
            self.updateMetaWearTableViewSections()
        })
    }
    func retrieveSavedMetaWear(){
        MBLMetaWearManager.sharedManager().retrieveSavedMetaWearsWithHandler({(devices:[AnyObject]!) -> Void in
            self.savedDevices = devices as! [MBLMetaWear]
            self.startScanning()
        })
    }
    
    func updateMetaWearTableViewSections(){
        self.accountTableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(1, 2)), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    

}
