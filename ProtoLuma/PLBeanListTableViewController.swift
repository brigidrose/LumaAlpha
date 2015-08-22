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

        let closeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Plain, target: self, action: "closeButtonTapped:")
        self.navigationItem.leftBarButtonItem = closeButton
        
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showBeanDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController as! PLBeanDetailTableViewController
        destinationViewController.bean = self.beans.allValues[(self.tableView.indexPathForSelectedRow?.row)!] as! PTDBean
        destinationViewController.beanManager = self.beanManager
        destinationViewController.navigationItem.title = destinationViewController.bean.name
    }
    

    func closeButtonTapped(sender:UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
