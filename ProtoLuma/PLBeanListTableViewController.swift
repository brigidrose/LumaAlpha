//
//  PLBeanListTableViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/14/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class PLBeanListTableViewController: UITableViewController, PTDBeanManagerDelegate {

    let beanManager = PTDBeanManager()
    var beans:NSMutableDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.beanManager.delegate = self
        self.beans = NSMutableDictionary(dictionary: NSMutableDictionary())
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // MARK: PTDBeanManager Delegates
    
    func beanManagerDidUpdateState(beanManager: PTDBeanManager!) {
        if beanManager.state == BeanManagerState.PoweredOn {
            beanManager.startScanningForBeans_error(nil)
        }
        else{
            let alert = UIAlertView(title: "Bluetooth Unavailable", message: "Turn on Bluetooth to scan for beans.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func BeanManager(beanManager: PTDBeanManager!, didDiscoverBean bean: PTDBean!, error: NSError!) {
        let key = bean.identifier
        NSLog("%@", key)
        if(self.beans.objectForKey(key) == nil){
            // New Bean
            print("A New Bean")
            self.beans.setObject(bean, forKey: key)
        }
        print(self.beans)
        self.tableView.reloadData()
    }
    
    func BeanManager(beanManager: PTDBeanManager!, didConnectToBean bean: PTDBean!, error: NSError!) {
        
    }
    
    func BeanManager(beanManager: PTDBeanManager!, didDisconnectBean bean: PTDBean!, error: NSError!) {
        self.tableView.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Beans"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(self.beans.count)
        return self.beans.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "BeanTableViewCell")
        let bean:PTDBean = self.beans.allValues[indexPath.row] as! PTDBean
        print("bean is \(bean)")
        cell.textLabel?.text = "\(bean.name)"
        let beanState:String!
        if (bean.state == BeanState.ConnectedAndValidated){
            beanState = "Connected"
        }
        else{
            beanState = "Disconnected"
        }
        cell.detailTextLabel?.text = beanState
        // Configure the cell...

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
