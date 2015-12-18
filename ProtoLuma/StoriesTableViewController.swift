//
//  StoriesTableViewController.swift
//  ProtoLuma
//
//  Created by Chris on 12/18/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit
import ParseUI

class StoryTableViewCell : UITableViewCell {
    
    @IBOutlet var creatorPhoto: UIImageView!
    @IBOutlet var HImageStack: UIStackView!
    @IBOutlet var title: UILabel!
    @IBOutlet var storyDesc: UILabel!
    
    func loadItem(title title: String, description: String, creatorPhoto: UIImage, storyUnits: [PFObject]) {
        self.title.text = title
        self.storyDesc.text = description
        
        self.creatorPhoto.image = creatorPhoto
        
        for sv in self.HImageStack.arrangedSubviews{
            self.HImageStack.removeArrangedSubview(sv)
            sv.removeFromSuperview()
        }
        
        for unit in storyUnits{
            let imageView = PFImageView(frame: CGRectZero)
            imageView.contentMode = .ScaleAspectFit
            imageView.file = unit["file"] as? PFFile
            imageView.loadInBackground({ (image, error) -> Void in
                self.HImageStack.addArrangedSubview(imageView)
                self.HImageStack.layoutIfNeeded()
            })
        }

    }
}

class StoriesTableViewController: UITableViewController {

    var charm:PFObject!
    var stories:[PFObject] = []
    var storiesStoryUnits:[[PFObject]] = []
    var profileImages = [String: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "StoryTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "StoryCell")
        
        loadStoriesForCharmViewed()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return stories.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 175
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StoryCell") as! StoryTableViewCell
        if indexPath.row < self.stories.count && indexPath.row < self.storiesStoryUnits.count{
            let story = self.stories[indexPath.row]
            let sender = story["sender"] as! PFObject
            cell.loadItem(title: story["title"] as! String, description:  story["description"] as! String, creatorPhoto: self.profileImages[sender["facebookId"] as! String]!, storyUnits: self.storiesStoryUnits[indexPath.row])
        }
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

    
    func loadStoriesForCharmViewed(){
        self.refreshControl?.beginRefreshing()
        let queryForStoriesForCharmViewed = PFQuery(className: "Story")
        queryForStoriesForCharmViewed.whereKey("forCharm", equalTo: self.charm)
        queryForStoriesForCharmViewed.whereKey("unlocked", equalTo: true)
//        queryForStoriesForCharmViewed.includeKey("sender")
        queryForStoriesForCharmViewed.orderByDescending("createdAt")
        queryForStoriesForCharmViewed.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            if (error == nil){
                self.stories = objects!
                self.storiesStoryUnits = Array(count: self.stories.count, repeatedValue: [])
                // load storiesStoryUnits
                var storiesStoryUnitsFoundCount = 0
                for story in self.stories{
                    let storyRelation = story.relationForKey("storyUnits")
                    let queryForStoryStoryUnits:PFQuery = storyRelation.query()!
                    queryForStoryStoryUnits.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
                        self.storiesStoryUnits[self.stories.indexOf(story)!] = objects!
                        storiesStoryUnitsFoundCount++
                        if (storiesStoryUnitsFoundCount == self.stories.count){
                            //done loading story units
                            self.refreshControl?.endRefreshing()
                            self.tableView.reloadData()
                        }
                    })
                }
            }
            else{
                print(error)
            }
        })
        
    }

}
