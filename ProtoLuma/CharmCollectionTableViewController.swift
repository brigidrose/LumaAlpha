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
    var addedProfileImageViews = Dictionary<String, UIImageView>()
    @IBOutlet var profileImages: UIStackView!
    @IBOutlet var scheduledMomentsIcon: UIImageView!
    
    
    
    
    func loadItem(title title: String, charmIconImage: UIImage, profilePhotos: Dictionary<String, UIImage>, hasScheduledMoments: Bool) {
        self.charmIconImage.image = charmIconImage
        titleLabel.text = title
        
        
        //add user photos to stackview
        for (fbId, userImage) in profilePhotos {
            if !addedProfileImageViews.keys.contains(fbId){
                let imageView = UIImageView(image: userImage)
                imageView.contentMode = .ScaleAspectFit
                profileImages.addArrangedSubview(imageView)
                print("added profile photo to charm \(title) for user \(fbId)")
                addedProfileImageViews[fbId] = imageView
            }
        }
        
        var removeTheseIdsFromAddedProfileImages = Set<String>()
        
        //find users that are in addedProfileImages but NOT in profileImages
        for (fbId, imageView) in addedProfileImageViews {
            if !profilePhotos.keys.contains(fbId){
                //oh crap, we have an image in the profileImages view that is not in the profilePhotos array.  This user was probably deleted.  Remove them.
                print("removed profile photo from charm \(title) for user \(fbId)")
                profileImages.removeArrangedSubview(imageView)
                imageView.removeFromSuperview()
                removeTheseIdsFromAddedProfileImages.insert(fbId)
            }
        }
        
        for fbIdToRemove in removeTheseIdsFromAddedProfileImages {
            addedProfileImageViews.removeValueForKey(fbIdToRemove)
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
    var charms:[Charm]! = []
    var relatedUsersOfCharms = [String: Set<String>]()
    var profileImages = [String: UIImage]()
    var indexPathOfCharmViewed:NSIndexPath!
    var appDelegate:AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "CharmTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "CharmCell")
        
        self.tabBarController?.tabBar.items![1].enabled = false
        self.tabBarController?.tabBar.items![2].enabled = false
        
        self.refreshControl?.beginRefreshing()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)

        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        
        //store a reference in the app delegate
        appDelegate.collectionController = self
        appDelegate.tabBarController = self.tabBarController!
    }

    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.title = "Collection"
        
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
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        loadCharms()
        appDelegate.checkForUnlockedItems()
    }
    
    // MARK: Table View delegate methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.charms.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CharmCell") as! CharmTableViewCell
        let charmName = self.charms[indexPath.row].charmGroup!.name
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
        print("selected charm row \(indexPath.row)")
        self.indexPathOfCharmViewed = indexPath
        self.performSegueWithIdentifier("showStoryTable", sender: self)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showStoryTable"){
            print("seguing into StoriesTableViewController")
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
        
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()

    }
    
    func loadCharms(){
        print("loading charms")

        
        let queryForCharms = PFQuery(className: "Charm")
        queryForCharms.whereKey("owner", equalTo: PFUser.currentUser()!)
        queryForCharms.includeKey("charmGroup")
        queryForCharms.whereKeyExists("charmGroup")
        
        queryForCharms.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            if error == nil{
                self.charms = objects as! [Charm]
                print("\(self.charms.count) charms retrieved")
                
                //reset scheduled moments flags
                for charm in self.charms {
                    charm.hasScheduledMoments = false
                }
                
                PFCloud.callFunctionInBackground("getCharmGroupsWithScheduledMomentInfo", withParameters: nil) { (response, error) -> Void in
                    if error == nil{
                        print("charmGroupsWithLockedStories moments response: \(response)")
                        if response!["charms"] != nil {
                            let charmGroupsWithScheduledMoments = response!["charmGroupsWithLockedStories"] as! [Charm_Group]
                            for charmGroup in charmGroupsWithScheduledMoments {
                                for charm in self.charms {
                                    if charm.charmGroup!.objectId == charmGroup.objectId {
                                        charm.hasScheduledMoments = true
                                    }
                                }
                            }
                            self.tableView.reloadData()
                        }
                    }else{
                        print(error)
                        ParseErrorHandlingController.handleParseError(error)
                    }
                    
                }
                
                self.populateCharmsAndEnableBarItems();
                
                //load all profile photos in the background
                self.loadProfilePhotos()
                
                
            }else{
                print(error)
                ParseErrorHandlingController.handleParseError(error)
            }
        })
        
        
        
    }
    

    
    func downloadAndSetProfilePhotos(fbIds: Set<String>){
        print("downloadAndSetProfilePhotos")
        print(fbIds)
        print("related users of charms: \(self.relatedUsersOfCharms)")
        var photosDownloaded = 0
        if fbIds.count > 0 {
            for id in fbIds{
                let imgURL: NSURL = NSURL(string: "https://graph.facebook.com/\(id)/picture?type=large")!
                let request: NSURLRequest = NSURLRequest(URL: imgURL)
                
                let urlSession = NSURLSession.sharedSession()
                urlSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
                    if error == nil {
                        self.profileImages[id] = RBSquareImage(UIImage(data: data!)!).circle
                        photosDownloaded++
                        print("photo downloaded.  number \(photosDownloaded) out of \(fbIds.count)")
                        if(photosDownloaded == fbIds.count){
                            let barViewControllers = self.tabBarController?.viewControllers
                            let avc = barViewControllers![2].childViewControllers[0] as! AccountViewController
                            avc.profileImages = self.profileImages  //shared model
                         
                            print("all photos downloaded.  reloading table view")
                            dispatch_async(dispatch_get_main_queue()){
                                print("actually reloading it now")
                                self.tableView.reloadData()
                            }
                        
                            
                            
                            // too buggy, commented out for now
//                            // New UI design mandates that if a user has any stories, they are pushed into the newest one
//                            //                            var mostRecent:PFObject?
//                            var mostRecentLatestStory = NSDate(timeIntervalSince1970: 0.0)
//                            var indexOfMostRecentCharm:Int?
//                            for (index, charm) in self.charms.enumerate(){
//                                if(charm["latestStory"] != nil){
//                                    let charmDate = charm["latestStory"] as! NSDate
//                                    
//                                    if charmDate.compare(mostRecentLatestStory) == NSComparisonResult.OrderedDescending {
//                                        //                                        mostRecent = charm
//                                        indexOfMostRecentCharm = index
//                                        mostRecentLatestStory = charm["latestStory"] as! NSDate
//                                    }
//                                }
//                            }
//                            if indexOfMostRecentCharm != nil{
//                                print("Most recent charm is \(indexOfMostRecentCharm!)")
//                                self.indexPathOfCharmViewed = NSIndexPath(forRow: indexOfMostRecentCharm!, inSection: 0)
//                                self.performSegueWithIdentifier("showStoryTable", sender: self)
//                            }
                        }
                    }else{
                        print(error)
                        ParseErrorHandlingController.handleParseError(error)
                    }
                }.resume()

            }
        }else{
            self.tableView.reloadData()
        }
    }
    
    func loadProfilePhotos(){
        print("loading profile photos")
        var uniqueFacebookIds = Set<String>()
        var retrievedCount = 0
        
        //reset related users array in case one was deleted
        self.relatedUsersOfCharms = [String: Set<String>]()
        
        for charm in self.charms{
            let otherCharmGroupUsersQuery = PFQuery(className: "Charm")
            otherCharmGroupUsersQuery.whereKey("charmGroup", equalTo: charm.charmGroup!)
            otherCharmGroupUsersQuery.includeKey("owner")
            otherCharmGroupUsersQuery.findObjectsInBackgroundWithBlock({ (charms, error) -> Void in
                if error == nil {
                    print("got \((charms ?? []).count) related users");
                    var idsForCharm = Set<String>()
                    for charm in charms as! [Charm]{
                        let fbId = charm.owner!.facebookId
                        //don't download a pic if we already have it from earlier.
                        if !self.profileImages.keys.contains(fbId){
                            uniqueFacebookIds.insert(fbId)
                        }
                        idsForCharm.insert(fbId)
                    }
                    //threadsafe lock on the datastructure
                    sync(self.relatedUsersOfCharms){
                        if self.relatedUsersOfCharms.keys.contains(charm.objectId!) {
                            self.relatedUsersOfCharms[charm.objectId!] = self.relatedUsersOfCharms[charm.objectId!]!.union(idsForCharm)
                        }else{
                            self.relatedUsersOfCharms[charm.objectId!] = idsForCharm
                        }
                    }
                    retrievedCount++
                    if(retrievedCount == self.charms.count*2){
                        self.downloadAndSetProfilePhotos(uniqueFacebookIds)
                    }
                }else{
                    print(error)
                    ParseErrorHandlingController.handleParseError(error)
                }
            })
            
            let queryForInvitedCharmGroupMembers = PFQuery(className: "User_Charm_Group")
            queryForInvitedCharmGroupMembers.whereKey("charmGroup", equalTo: charm.charmGroup!)
            queryForInvitedCharmGroupMembers.whereKey("user", notEqualTo: PFUser.currentUser()!)
            queryForInvitedCharmGroupMembers.includeKey("user")
            queryForInvitedCharmGroupMembers.findObjectsInBackgroundWithBlock({ (userCharmGroups, error) -> Void in
                if error == nil {
                    print("got \((userCharmGroups ?? []).count) invited users");
                    var idsForCharm = Set<String>()
                    for userCharmGroup in userCharmGroups as! [User_Charm_Group] {
                        let fbId = userCharmGroup.user.facebookId
                        //don't download a pic if we already have it from earlier.
                        if !self.profileImages.keys.contains(fbId){
                            uniqueFacebookIds.insert(fbId)
                        }
                        idsForCharm.insert(fbId)
                    }
                    //threadsafe lock on the datastructure
                    sync(self.relatedUsersOfCharms){
                        if self.relatedUsersOfCharms.keys.contains(charm.objectId!) {
                            self.relatedUsersOfCharms[charm.objectId!] = self.relatedUsersOfCharms[charm.objectId!]!.union(idsForCharm)
                        }else{
                            self.relatedUsersOfCharms[charm.objectId!] = idsForCharm
                        }
                    }
                    retrievedCount++
                    if(retrievedCount == self.charms.count*2){
                        self.downloadAndSetProfilePhotos(uniqueFacebookIds)
                    }
                }else{
                    print(error)
                    ParseErrorHandlingController.handleParseError(error)
                }
            })
            
        }
        
    }

}
