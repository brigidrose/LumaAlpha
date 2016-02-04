//
//  CharmGroupPickerTableViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 2/2/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit

class CharmGroupPickerTableViewController: UITableViewController {

    var momentComposerVC:NewMomentViewController!
    var charms:[Charm]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Select Charm"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonTapped")
        
        self.tableView.registerClass(CharmGroupSelectionTableViewCell.self, forCellReuseIdentifier: "CharmGroupSelectionTableViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.charms.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CharmGroupSelectionTableViewCell") as! CharmGroupSelectionTableViewCell
        cell.charmGroupTitleLabel.text = (self.charms[indexPath.row]["charmGroup"] as! Charm_Group)["name"] as? String
        cell.charmGroupSelectButton.addTarget(self, action: "charmGroupSelectButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    func charmGroupSelectButtonTapped(sender:UIButton){
        let indexPath = self.indexPathForCellContainingView(sender, inTableView: self.tableView)!
        self.momentComposerVC.forCharm = self.charms[indexPath.row]
        self.momentComposerVC.charmGroupTitleLabel.text = (self.momentComposerVC.forCharm["charmGroup"] as! Charm_Group)["name"] as? String
        if self.momentComposerVC.momentTitle != "" && self.momentComposerVC.forCharm != nil{
            self.momentComposerVC.navigationItem.rightBarButtonItem!.enabled = true
        }
        else{
            self.momentComposerVC.navigationItem.rightBarButtonItem!.enabled = false
        }
        self.dismissViewControllerAnimated(true, completion: {
        })
    }
    
    func indexPathForCellContainingView(view: UIView, inTableView tableView:UITableView) -> NSIndexPath? {
        let viewCenterRelativeToTableview = tableView.convertPoint(CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds)), fromView:view)
        return tableView.indexPathForRowAtPoint(viewCenterRelativeToTableview)
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelButtonTapped(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
