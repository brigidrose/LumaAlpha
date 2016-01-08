//
//  CharmCollectionTableViewController.swift
//  ProtoLuma
//
//  Created by Chris on 12/16/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit



class CharmTableViewCell : UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var charmIconImage: UIImageView!
    var addedProfileImages = Set<String>()
    @IBOutlet var profileImages: UIStackView!
    @IBOutlet var scheduledMomentsIcon: UIImageView!
    
    
    func loadItem(title title: String, charmIconImage: UIImage, profilePhotos: Dictionary<String, UIImage>, hasScheduledMoments: Bool) {
        self.charmIconImage.image = charmIconImage
        titleLabel.text = title
        
        //add user photos to stackview
        for (fbId, userImage) in profilePhotos {
            if !addedProfileImages.contains(fbId){
                let imageView = UIImageView(image: userImage)
                imageView.contentMode = .ScaleAspectFit
                profileImages.addArrangedSubview(imageView)
                print("added profile photo to charm \(title) for user \(fbId)")
                addedProfileImages.insert(fbId)
            }
        }
        UIView.animateWithDuration(0.25) { () -> Void in
            self.profileImages.layoutIfNeeded()
        }
        
        scheduledMomentsIcon.hidden = !hasScheduledMoments
        
    }
}

class CharmCollectionTableViewController: UITableViewController{
    
    var userInfo:AnyObject!
    var bracelet:MBLMetaWear!
    var charms:[PFObject]! = []
    var relatedUsersOfCharms = [String: Set<String>]()
    var profileImages = [String: UIImage]()
    var indexPathOfCharmViewed:NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "CharmTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "CharmCell")
        
        self.tabBarController?.tabBar.items![1].enabled = false
        self.tabBarController?.tabBar.items![2].enabled = false
        
        self.refreshControl?.beginRefreshing()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)

     
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
        
        //store a reference in the app delegate
        (UIApplication.sharedApplication().delegate as! AppDelegate).collectionController = self
        
    }

    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.title = "Collection"
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        loadCharms()
    }
    
    // MARK: Table View delegate methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.charms.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CharmCell") as! CharmTableViewCell
        let charmName = self.charms[indexPath.row]["name"] as! String
        var hasScheduledMoments = false
        if(self.charms[indexPath.row]["hasScheduledMoments"] != nil){
            hasScheduledMoments = self.charms[indexPath.row]["hasScheduledMoments"] as! Bool
        }
        
        //load profile photos
        var profilePhotos = Dictionary<String, UIImage>()
        let charmId = self.charms[indexPath.row].objectId!
        if relatedUsersOfCharms.keys.contains(charmId){
            for user in relatedUsersOfCharms[charmId]!{
                if(self.profileImages.keys.contains(user)){
                    profilePhotos[user] = self.profileImages[user]!
                }
            }
        }
        
        cell.loadItem(title: charmName, charmIconImage: UIImage(named: "CharmsBarButtonIcon")!, profilePhotos: profilePhotos, hasScheduledMoments: hasScheduledMoments)
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.indexPathOfCharmViewed = indexPath
        self.performSegueWithIdentifier("showStoryTable", sender: self)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showStoryTable"){
            let destinationVC = segue.destinationViewController as! StoriesTableViewController
            destinationVC.charm = self.charms[self.indexPathOfCharmViewed.row]
            destinationVC.profileImages = self.profileImages
        }
    }
    
    
    
    func populateCharmsAndEnableBarItems(){
        //load charms into the new story controller
        let barViewControllers = self.tabBarController?.viewControllers
        let nstvc = barViewControllers![1].childViewControllers[0] as! NewStoryTabViewController
        nstvc.charms = self.charms  //shared model
        
        print("loading charms into account page")
        //load charms into the account view
        let avc = barViewControllers![2].childViewControllers[0] as! AccountViewController
        avc.charms = self.charms  //shared model
        
        print("enabling tab buttons")
        
        self.tabBarController?.tabBar.items![1].enabled = true
        self.tabBarController?.tabBar.items![2].enabled = true
    }
    
    func loadCharms(){
        print("loading charms")
        let queryForCharms = PFQuery(className: "Charm")
        queryForCharms.whereKey("owner", equalTo: PFUser.currentUser()!)
        queryForCharms.includeKey("charmGroup")
        
        queryForCharms.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            if error == nil{
                self.charms = objects!
                print("\(self.charms.count) charms retrieved")
    //            self.tableView.reloadData()
                if (self.charms.count > 0){
                    print("loading charms into new page")
                    
                    
                    print("loading profile photos...")
                    self.populateCharmsAndEnableBarItems();
                    //load all profile photos in the background
                    self.loadProfilePhotos()
                }else{
                    self.populateCharmsAndEnableBarItems();
                    self.refreshControl?.endRefreshing()
                }
            }else{
                print(error)
                (UIApplication.sharedApplication().delegate as! AppDelegate).displayNoInternetErrorMessage()
            }
        })
        
    }
    
    //borrowed from here: https://gist.github.com/licvido/55d12a8eb76a8103c753
    func RBSquareImage(image: UIImage) -> UIImage {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var edge: CGFloat = 0.0
        
        if (originalWidth > originalHeight) {
            // landscape
            edge = originalHeight
            x = (originalWidth - edge) / 2.0
            y = 0.0
            
        } else if (originalHeight > originalWidth) {
            // portrait
            edge = originalWidth
            x = 0.0
            y = (originalHeight - originalWidth) / 2.0
        } else {
            // square
            edge = originalWidth
        }
        
        let cropSquare = CGRectMake(x, y, edge, edge)
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
        
        return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
    }

    

    
    func downloadAndSetProfilePhotos(fbIds: Set<String>){
        print(fbIds)
        var photosDownloaded = 0
        if fbIds.count > 0 {
            for id in fbIds{
                let imgURL: NSURL = NSURL(string: "https://graph.facebook.com/\(id)/picture?type=large")!
                let request: NSURLRequest = NSURLRequest(URL: imgURL)
                NSURLConnection.sendAsynchronousRequest(
                    request, queue: NSOperationQueue.mainQueue(),
                    completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            self.profileImages[id] = self.RBSquareImage(UIImage(data: data!)!).circle
                            photosDownloaded++
                            print("photo downloaded.  number \(photosDownloaded) out of \(fbIds.count)")
                            if(photosDownloaded == fbIds.count){
                                self.refreshControl?.endRefreshing()
                                self.tableView.reloadData()
                                
                                // New UI design mandates that if a user has any stories, they are pushed into the newest one
    //                            var mostRecent:PFObject?
                                var mostRecentLatestStory = NSDate(timeIntervalSince1970: 0.0)
                                var indexOfMostRecentCharm:Int?
                                for (index, charm) in self.charms.enumerate(){
                                    if(charm["latestStory"] != nil){
                                        let charmDate = charm["latestStory"] as! NSDate
                                        
                                        if charmDate.compare(mostRecentLatestStory) == NSComparisonResult.OrderedDescending {
    //                                        mostRecent = charm
                                            indexOfMostRecentCharm = index
                                            mostRecentLatestStory = charm["latestStory"] as! NSDate
                                        }
                                    }
                                }
                                if indexOfMostRecentCharm != nil{
                                    print("Most recent charm is \(indexOfMostRecentCharm!)")
                                    self.indexPathOfCharmViewed = NSIndexPath(forRow: indexOfMostRecentCharm!, inSection: 0)
                                    self.performSegueWithIdentifier("showStoryTable", sender: self)
                                }
                            }
                        }else{
                            print(error)
                            (UIApplication.sharedApplication().delegate as! AppDelegate).displayNoInternetErrorMessage()
                        }
                })
            }
        }else{
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func loadProfilePhotos(){
        print("loading profile photos")
        var uniqueFacebookIds = Set<String>()
        var retrievedCount = 0
        for charm in self.charms{
            let otherCharmGroupUsersQuery = PFQuery(className: "Charm")
            if charm["charmGroup"] != nil {
                otherCharmGroupUsersQuery.whereKey("charmGroup", equalTo: charm["charmGroup"])
                otherCharmGroupUsersQuery.includeKey("owner")
                otherCharmGroupUsersQuery.findObjectsInBackgroundWithBlock({ (charms, error) -> Void in
                    if error == nil {
                        print("got \((charms ?? []).count) related users");
                        var idsForCharm = Set<String>()
                        for charm in charms ?? []{
                            let fbId = charm["owner"]["facebookId"] as! String
                            //don't download a pic if we already have it from earlier.
                            if !self.profileImages.keys.contains(fbId){
                                uniqueFacebookIds.insert(fbId)
                            }
                            idsForCharm.insert(fbId)
                        }
                        self.relatedUsersOfCharms[charm.objectId!] = idsForCharm
                        retrievedCount++
                        if(retrievedCount == self.charms.count){
                            self.downloadAndSetProfilePhotos(uniqueFacebookIds)
                        }
                    }else{
                        print(error)
                    }
                })
            }else{
                //this charm has no charm group.  
                print("charm with id \(charm["id"]) has no group")
            }
        }
        
    }

}
