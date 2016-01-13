//
//  CharmGroupSettingTableViewController.swift
//  ProtoLuma
//
//  Created by Chris on 1/8/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit

class CharmGroupSettingTableViewController: UITableViewController {
    var charmGroups:[Charm_Group]!
    let tableHeaders = ["", "Invited to join"]
    var charm:Charm!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerNib(UINib(nibName: "CharmGroupSettingTableViewCell", bundle: nil), forCellReuseIdentifier: "CharmGroupSettingTableViewCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1{
            return charmGroups.count
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CharmGroupSettingTableViewCell", forIndexPath: indexPath) as! CharmGroupSettingTableViewCell
        cell.parentViewController = self
        if indexPath.section == 0 {
            cell.setupAsNewConversationButton()
        }else if indexPath.section == 1{
            cell.setupAsCharmChoice(charmGroups[indexPath.row])
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 40
        }else if indexPath.section == 1{
            return 60
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView(frame: CGRectMake(0, 0, view.frame.width, 55))
        containerView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        let headerTitle = UILabel(frame: CGRectMake(20, 20, view.frame.width, 32))
        headerTitle.text = tableHeaders[section]
        containerView.addSubview(headerTitle)
        
        return containerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1{
            self.charm.charmGroup = self.charmGroups[indexPath.row]
            self.charm.saveInBackgroundWithBlock({ (saved, error) -> Void in
                if error == nil {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    self.tabBarController?.selectedIndex = 0
                }else{
                    print(error)
                    ParseErrorHandlingController.handleParseError(error)
                }
            })
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showNewCharmGroupName" {
            let dvc = segue.destinationViewController as! SetCharmGroupViewController
            dvc.charm = self.charm
        }
    }


}
