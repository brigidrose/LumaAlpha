//
//  PLBeanDetailTableViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/15/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class PLBeanDetailTableViewController: UITableViewController, PTDBeanManagerDelegate, PTDBeanDelegate {

    var bean:PTDBean!
    var beanManager:PTDBeanManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.bean)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func update(){
        let connectButton = self.navigationItem.rightBarButtonItem!
        if (self.bean.state == BeanState.Discovered) {
            connectButton.title = "Connect"
            connectButton.enabled = true
        }
        else if (self.bean.state == BeanState.ConnectedAndValidated) {
            connectButton.title = "Disconnect"
            connectButton.enabled = true
        }
        self.tableView.reloadData()
    }
    
    func BeanManager(beanManager: PTDBeanManager!, didConnectToBean bean: PTDBean!, error: NSError!) {
        self.update()
    }
    
    func BeanManager(beanManager: PTDBeanManager!, didDisconnectBean bean: PTDBean!, error: NSError!) {
        self.update()
    }


    @IBAction func connectBarButtonItemTapped(sender: UIBarButtonItem) {
        print("Connect Bar Button Item Tapped")
        if (self.bean.state == BeanState.Discovered) {
            self.bean.delegate = self
            self.beanManager.connectToBean(self.bean, error: nil)
            self.beanManager.delegate = self;
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        else {
            self.bean.delegate = self;
            self.beanManager.disconnectBean(self.bean, error: nil)
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "BeanDetail")
        switch indexPath.row{
        case 0:
            cell.textLabel?.text = "State"
            var beanStateString:String!
            if self.bean.state == BeanState.ConnectedAndValidated{
                beanStateString = "Connected"
            }
            else{
                beanStateString = "Disconnected"
            }
            cell.detailTextLabel!.text = beanStateString
        case 1:
            cell.textLabel?.text = "Action"
            cell.detailTextLabel?.text = "Description"
        default: break
        }
        return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
