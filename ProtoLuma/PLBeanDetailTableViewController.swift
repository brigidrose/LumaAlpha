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

        // MARK: ADD NOTIFICATION OBSERVERS
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "vibrate:", name: "notificationToVibrate", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopVibration:", name: "notificationToStopVibration", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "vibrateForNotification:", name: "notificationReceived", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pulseCharmX:", name: "charmX", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pulseCharmY:", name: "charmY", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pulseCharmZ", name: "charmZ", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recallCharmX:", name: "actionAOnCharmX", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recallCharmY:", name: "actionBOnCharmY", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recallCharmZ", name: "actionCOnCharmZ", object: nil)

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
    
    func beanManager(beanManager: PTDBeanManager!, didDiscoverBean bean: PTDBean!, error: NSError!) {
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
        return 6
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
        default: break
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // MARK: Notification SendSerialData Functions
    
    func vibrateForNotification(notification:NSNotification){
        let messageString = "N"
        self.bean.sendSerialData(messageString.dataUsingEncoding(NSUTF8StringEncoding))
        print("Sent \(messageString)")
    }

    func pulseCharmX(notification:NSNotification){
        let messageString = "X"
        self.bean.sendSerialData(messageString.dataUsingEncoding(NSUTF8StringEncoding))
        print("Sent \(messageString)")
    }

    func pulseCharmY(notification:NSNotification){
        let messageString = "Y"
        self.bean.sendSerialData(messageString.dataUsingEncoding(NSUTF8StringEncoding))
        print("Sent \(messageString)")
    }

//    func pulseCharmZ(notification:NSNotification){
//        let messageString = "Z"
//        self.bean.sendSerialData(messageString.dataUsingEncoding(NSUTF8StringEncoding))
//        print("Sent \(messageString)")
//    }

    func recallCharmX(notification:NSNotification){
        let messageString = "A"
        self.bean.sendSerialData(messageString.dataUsingEncoding(NSUTF8StringEncoding))
        print("Sent \(messageString)")
    }

    func recallCharmY(notification:NSNotification){
        let messageString = "B"
        self.bean.sendSerialData(messageString.dataUsingEncoding(NSUTF8StringEncoding))
        print("Sent \(messageString)")
    }

//    func recallCharmZ(notification:NSNotification){
//        let messageString = "C"
//        self.bean.sendSerialData(messageString.dataUsingEncoding(NSUTF8StringEncoding))
//        print("Sent \(messageString)")
//    }

    
//    func vibrate(notification:NSNotification){
//        let messageString = "R"
//        self.bean.sendSerialData(messageString.dataUsingEncoding(NSUTF8StringEncoding))
//        print("RECEIVED NOTIFICATION TO VIBRATE!")
//        let alert = UIAlertView(title: "Notification Received", message: "Command is sent to Arduino to jiggle.", delegate: nil, cancelButtonTitle: "OK")
//        alert.show()
//
//    }
//
//    func stopVibration(notification:NSNotification){
//        let messageString = "G"
//        self.bean.sendSerialData(messageString.dataUsingEncoding(NSUTF8StringEncoding))
//        print("RECEIVED NOTIFICATION TO STOP VIBRATION!")
//        let alert = UIAlertView(title: "Notification Received", message: "Command is sent to Arduino to stop jiggling.", delegate: nil, cancelButtonTitle: "OK")
//        alert.show()
//    }
    
    
    func bean(bean: PTDBean!, serialDataReceived data: NSData!) {
        let feedback = NSString(data: data, encoding: NSUTF8StringEncoding)
        print("feedback is \(feedback)")
        switch feedback as! String{
        case "buttonAPushed":
//            (self.view.window?.rootViewController as! UITabBarController).selectedIndex = 1
            print("Button A Pushed")
        case "buttonBPushed":
//            (self.view.window?.rootViewController as! UITabBarController).selectedIndex = 1
            print("Button B Pushed")
        default:
             break
        }
//        if (feedback == "Vibrating"){
//            let alert = UIAlertView(title: "Arduino Reacted", message: "It's feeling some good vibration.", delegate: nil, cancelButtonTitle: "OK")
//            alert.show()
//        }
//        else if(feedback == "Stopped Vibrating"){
//            let alert = UIAlertView(title: "Arduino Reacted", message: "Vibration is, sadly, no more.", delegate: nil, cancelButtonTitle: "OK")
//            alert.show()
//        }
//        if (feedback == "IT's R"){
//            self.bean.setLedColor(UIColor.redColor())
//        }
//        else if (feedback == "IT's G"){
//            self.bean.setLedColor(UIColor.greenColor())
//        }
//        else if (feedback == "IT's B"){
//            self.bean.setLedColor(UIColor.blueColor())
//        }
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
