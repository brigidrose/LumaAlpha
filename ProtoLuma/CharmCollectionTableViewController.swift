//
//  CharmCollectionTableViewController.swift
//  ProtoLuma
//
//  Created by Chris on 12/16/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

extension UIImage {
    var rounded: UIImage {
        let imageView = UIImageView(image: self)
        imageView.layer.cornerRadius = size.height < size.width ? size.height/2 : size.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    var circle: UIImage {
        let square = CGSize(width: 39, height: 39)//size.width < size.height ? CGSize(width: size.width, height: size.width) : CGSize(width: size.height, height: size.height)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

class CharmTableViewCell : UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var charmIconImage: UIImageView!
    var addedProfileImages = Set<String>()
    @IBOutlet var profileImages: UIStackView!
    
    func loadItem(title title: String, charmIconImage: UIImage, profilePhotos: Dictionary<String, UIImage>) {
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
        
    }
}

class CharmCollectionTableViewController: UITableViewController{
    
    var userInfo:AnyObject!
    var bracelet:MBLMetaWear!
    var charms:[PFObject] = []
    var relatedUsersOfCharms = [String: Set<String>]()
    var profileImages = [String: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "CharmTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "CharmCell")
        
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
        let cell = tableView.dequeueReusableCellWithIdentifier("CharmCell") as! CharmTableViewCell
        let charmName = self.charms[indexPath.row]["name"] as! String
        
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
        
        cell.loadItem(title: charmName, charmIconImage: UIImage(named: "CharmsBarButtonIcon")!, profilePhotos: profilePhotos)
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    
    func loadCharms(){
        let queryForCharmsOwned = PFQuery(className: "Charm")
        queryForCharmsOwned.whereKey("owners", equalTo: PFUser.currentUser()!)
        let queryForCharmsGifted = PFQuery(className: "Charm")
        queryForCharmsGifted.whereKey("gifter", equalTo: PFUser.currentUser()!)
        let queryForCharms = PFQuery.orQueryWithSubqueries([queryForCharmsOwned, queryForCharmsGifted])
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
                
                //load all profile photos in the background
                self.loadProfilePhotos()
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
        for id in fbIds{
            let imgURL: NSURL = NSURL(string: "https://graph.facebook.com/\(id)/picture?type=large")!
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(
                request, queue: NSOperationQueue.mainQueue(),
                completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        self.profileImages[id] = self.RBSquareImage(UIImage(data: data!)!).circle
                        photosDownloaded++
                        if(photosDownloaded == fbIds.count){
                            self.tableView.reloadData()
                        }
                    }else{
                        print(error)
                    }
            })
        }
    }
    
    func loadProfilePhotos(){
        var uniqueFacebookIds = Set<String>()
        var retrievedCount = 0
        for charm in self.charms{
            var idsForCharm = Set<String>()
            uniqueFacebookIds.insert(charm["gifter"]["facebookId"] as! String)
            idsForCharm.insert(charm["gifter"]["facebookId"] as! String)
            let ownersQuery = charm.relationForKey("owners").query()!
            ownersQuery.findObjectsInBackgroundWithBlock({ (owners, error) -> Void in
                for user in owners!{
                    uniqueFacebookIds.insert(user["facebookId"] as! String)
                    idsForCharm.insert(user["facebookId"] as! String)
                }
                self.relatedUsersOfCharms[charm.objectId!] = idsForCharm
                retrievedCount++
                if(retrievedCount == self.charms.count){
                    self.downloadAndSetProfilePhotos(uniqueFacebookIds)
                }
            })
        }
        
    }

}
