//
//  AddFriendsToCharmTableViewController.swift
//  ProtoLuma
//
//  Created by Chris on 1/9/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

class AddFriendsToCharmTableViewController: UITableViewController {

    let charmMemberReuseIdentifier = "CharmSettingsCharmMemberCell"
    
    var charm:Charm!
    var profileImages = [String:UIImage]()
    var appDelegate:AppDelegate!
    var friends = [User]()
    var fbFriends = [[String:String]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: charmMemberReuseIdentifier, bundle: nil), forCellReuseIdentifier: charmMemberReuseIdentifier)

        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        getFBFriends(nil)
    }
    
    func getFBFriends(nextCursor : String?){
        var params = ["fields":"name"]
        if nextCursor != nil {
            params["after"] = nextCursor
        }
        let fbReq = FBSDKGraphRequest(graphPath: "me/friends", parameters: params)
        fbReq.startWithCompletionHandler { (connection, result, error) -> Void in
            if error == nil {
//                print("raw result: ")
//                print(result)
                let resultdict = result as! NSDictionary
                let data : NSArray = resultdict.objectForKey("data") as! NSArray
//                print("---------------------------------\nFriends found:")
//                print(data)
                for friend in data {
                    self.fbFriends.append(friend as! [String : String])
                    
                }
                if let after = ((resultdict["paging"] as? NSDictionary)?.objectForKey("cursors") as? NSDictionary)?.objectForKey("after") as? String {
                    self.getFBFriends(after)
                }else{
                    print(self.fbFriends)
                    //set user objects from parse
                    let fbIds = self.fbFriends.map({ (friend) -> String in
                        return friend["id"]!
                    })
                    self.getParseUsersForFbIds(fbIds)
                    self.downloadAndSetProfilePhotos()
                }
            }else{
                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(charmMemberReuseIdentifier, forIndexPath: indexPath) as! CharmSettingsCharmMemberCell
        let friend = friends[indexPath.row]
        var memberPhoto:UIImage? = nil
        if profileImages.keys.contains(friend.facebookId) {
            memberPhoto = profileImages[friend.facebookId]
        }
        cell.setup(friend.fullName(), memberPhoto: memberPhoto)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let friend = friends[indexPath.row]
        print("adding \(friend.fullName()) to charm group")
        let checkIfAlreadyInGroupQuery = PFQuery(className: "User_Charm_Group")
        checkIfAlreadyInGroupQuery.whereKey("charmGroup", equalTo: charm.charmGroup)
        checkIfAlreadyInGroupQuery.whereKey("user", equalTo: friend)
        checkIfAlreadyInGroupQuery.findObjectsInBackgroundWithBlock { (userCharmGroups, error) -> Void in
            if error == nil {
                if userCharmGroups!.count == 0 {
                    //create new user charm group
                    let newUserCharmGroup = User_Charm_Group()
                    newUserCharmGroup.charmGroup = self.charm.charmGroup
                    newUserCharmGroup.user = friend
                    newUserCharmGroup.saveInBackgroundWithBlock({ (saved, error) -> Void in
                        if error == nil {
                            print("new user charm group saved")
                            if self.navigationController != nil {
                                self.navigationController?.popToRootViewControllerAnimated(true)
                            }
                            self.appDelegate.tabBarController.selectedIndex = 0
                        }else{
                            print(error)
                        }
                    })
                }
            }else{
                print(error)
            }
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView(frame: CGRectMake(0, 0, view.frame.width, 55))
        containerView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        let headerTitle = UILabel(frame: CGRectMake(20, 10, view.frame.width, 32))
        headerTitle.text = "Add: "
        containerView.addSubview(headerTitle)
        
        return containerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func getParseUsersForFbIds(fbIds:[String]){
        let userQuery = PFQuery(className: "_User")
        userQuery.whereKey("facebookId", containedIn: fbIds)
        userQuery.findObjectsInBackgroundWithBlock { (users, error) -> Void in
            if error == nil {
                for user in (users as! [User]) {
                    self.friends.append(user)
                }
                self.tableView.reloadData()
            }else{
                print(error)
            }
        }
    }
    
    func downloadAndSetProfilePhotos(){
        print("downloadAndSetProfilePhotos for adding friend to charm")
        var photosDownloaded = 0
        var photosLoadedFromCharmCollectionCache = false
        if self.fbFriends.count > 0 {
            for friend in self.fbFriends{
                let id = friend["id"]!
                //first, check if we can load it from the collection controller, meaning the user is already in a charm group with this user do we already downloaded their pic on the collections tab
                if self.appDelegate.collectionController.profileImages.keys.contains(id) {
                    print("photo for \(id) is already downloaded from cache")
                    profileImages[id] = self.appDelegate.collectionController.profileImages[id]
                    photosLoadedFromCharmCollectionCache = true
                    photosDownloaded++
                }else{
                    print("photo for \(id) is being downloaded")
                    let imgURL: NSURL = NSURL(string: "https://graph.facebook.com/\(id)/picture?type=large")!
                    let request: NSURLRequest = NSURLRequest(URL: imgURL)
                    
                    let urlSession = NSURLSession.sharedSession()
                    urlSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
                        if error == nil {
                            let circleImage = self.appDelegate.RBSquareImage(UIImage(data: data!)!).circle
                            self.profileImages[id] = circleImage
                            //load pics into the collection controller so we don't have to redownload them after
                            self.appDelegate.collectionController.profileImages[id] = circleImage
                            photosDownloaded++
                            print("adding friends: photo downloaded.  number \(photosDownloaded) out of \(self.fbFriends.count)")
                            if(photosDownloaded == self.fbFriends.count){
                                //done
                                self.tableView.reloadData()
                            }
                        }else{
                            print(error)
                            self.appDelegate.displayNoInternetErrorMessage()
                        }
                    }.resume()
                }
            }
            if photosLoadedFromCharmCollectionCache {
                self.tableView.reloadData()
            }
        }else{
            self.tableView.reloadData()
        }
    }


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
