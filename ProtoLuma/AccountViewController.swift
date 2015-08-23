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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateDataSourceArray()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]

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
            let beanForCell = self.connectedBeansArray[indexPath.row]
            cell.charmTitle.text = "\(beanForCell.name)"
            cell.charmSubtitle.text = "\(beanForCell.identifier.UUIDString)"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("CharmWithSubtitleTableViewCell") as! CharmWithSubtitleTableViewCell
            let beanForCell = self.discoveredBeansArray[indexPath.row]
            cell.charmTitle.text = "\(beanForCell.name)"
            cell.charmSubtitle.text = "\(beanForCell.identifier.UUIDString)"
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
            return self.appDelegate.connectedBeans.count
        case 2:
            return self.appDelegate.beans.count
        case 3:
            return 1
        default:
            return Int(0)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section{
        case 1:
            let headerView = CharmsTableViewHeader()
            headerView.sectionTitle.text = "\(self.appDelegate.connectedBeans.count) Charms Connected"
            return headerView
        case 2:
            let headerView = CharmsTableViewHeader()
            headerView.sectionTitle.text = "\(self.appDelegate.beans.count) Charms Discovered"
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
            self.appDelegate.beanManager.disconnectBean(self.connectedBeansArray[indexPath.row], error: nil)
        case 2:
            self.appDelegate.beanManager.connectToBean(self.discoveredBeansArray[indexPath.row], error: nil)
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
    }
    
    func setupButtonTapped(){
        self.performSegueWithIdentifier("showBeans", sender: self)
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
}
