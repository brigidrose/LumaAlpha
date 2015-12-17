//
//  CharmCollectionTableViewController.swift
//  ProtoLuma
//
//  Created by Chris on 12/16/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class CharmCollectionTableViewController: UITableViewController{
    
    var userInfo:AnyObject!
    var bracelet:MBLMetaWear!
    var charms:[PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.items![1].enabled = false
        self.tabBarController?.tabBar.items![2].enabled = false
     
        // currentUser exists
        if (PFUser.currentUser() != nil){
            MBLMetaWearManager.sharedManager().retrieveSavedMetaWearsWithHandler({(devices) -> Void in
                if ((devices as! [MBLMetaWear]).count > 0){
                    self.loadCharms()
                }
                else{
                    if (PFUser.currentUser()!["bracelet"] != nil){
                        self.loadCharms()
                    }
                    else{
                        self.performSegueWithIdentifier("showLoggedInWithoutBracelet", sender: self)
                    }
                }
            })
        }
        else{
            self.performSegueWithIdentifier("showLogin", sender: self)
        }
        
    }

    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.title = "Collection"
    }
    
    // MARK: Table View delegate methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.charms.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CharmTableViewCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.charms[indexPath.row]["name"] as? String
        let facebookId = self.charms[indexPath.row]["gifter"]["facebookId"]
        cell.detailTextLabel?.text = "Gifted by \(facebookId)"
        let imgURL: NSURL = NSURL(string: "https://graph.facebook.com/\(facebookId)/picture?type=large")!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(
            request, queue: NSOperationQueue.mainQueue(),
            completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if error == nil {
                    cell.imageView?.image = UIImage(data: data!)
                    tableView.reloadData()
                }
        })
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    
    func loadCharms(){
        let queryForCharmsOwned = PFQuery(className: "Charm")
        queryForCharmsOwned.whereKey("owners", equalTo: PFUser.currentUser()!)
        let queryForCharmsGifted = PFQuery(className: "Charm")
        queryForCharmsGifted.whereKey("gifter", equalTo: PFUser.currentUser()!)
        let queryForCharms = PFQuery.orQueryWithSubqueries([queryForCharmsOwned, queryForCharmsGifted])
        //        queryForCharms.includeKey("owners")
        queryForCharms.includeKey("gifter")
        queryForCharms.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            self.charms = objects!
            self.tableView.reloadData()
            if (self.charms.count > 0){
                //load charms into the new story controller
                let barViewControllers = self.tabBarController?.viewControllers
                let nstvc = barViewControllers![1].childViewControllers[0] as! NewStoryTabViewController
                nstvc.charms = self.charms  //shared model
                
                //load charms into the account view
                let avc = barViewControllers![2].childViewControllers[0] as! AccountViewController
                avc.charms = self.charms  //shared model
                
                self.tabBarController?.tabBar.items![1].enabled = true
                self.tabBarController?.tabBar.items![2].enabled = true
            }
        })
        
    }

}
