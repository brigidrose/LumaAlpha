//
//  NewStoryTabViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/21/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class NewStoryTabViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, CTAssetsPickerControllerDelegate {

    var cancelButton:UIBarButtonItem!
    var sendButton:UIBarButtonItem!
    
    var charms:[PFObject]!
    var forCharm:PFObject!
    var storyUnits:[PFObject] = []
    var mediaAssets:[PHAsset] = []
    var mediaDescriptions:[String] = []
    var momentTitle = ""
    var momentDescription = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonTapped:")
        self.navigationItem.leftBarButtonItem = self.cancelButton
        
        self.sendButton = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Done, target: self, action: "sendButtonTapped:")
        self.sendButton.enabled = false
        self.navigationItem.rightBarButtonItem = self.sendButton
        
        self.navigationItem.title = "New Moment"
        
        self.tableView = UITableView(frame: self.view.frame, style: UITableViewStyle.Plain)
        self.tableView.registerClass(CharmWithSubtitleTableViewCell.self, forCellReuseIdentifier: "charmCell")
        self.tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldTableViewCell")
        self.tableView.registerClass(TextViewTableViewCell.self, forCellReuseIdentifier: "TextViewTableViewCell")
        self.tableView.registerClass(ButtonWithPromptTableViewCell.self, forCellReuseIdentifier: "ButtonWithPromptTableViewCell")
        self.tableView.registerClass(MomentMediaTableViewCell.self, forCellReuseIdentifier: "MomentMediaTableViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    func cancelButtonTapped(sender:UIBarButtonItem){
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendButtonTapped(sender:UIBarButtonItem){
        print("Send button tapped")
        
        let story = PFObject(className: "Story")
        story["title"] = self.momentTitle
        story["description"] = self.momentDescription
        story["sender"] = PFUser.currentUser()
        story["forCharm"] = self.forCharm
        let manager = PHImageManager.defaultManager()
        let storyUnitsRelation:PFRelation = story.relationForKey("storyUnits")
        for mediaAsset in self.mediaAssets{
            print(mediaAsset)
            manager.requestImageDataForAsset(mediaAsset, options: nil, resultHandler:{(data:NSData?,dataUTI:String?,orientation:UIImageOrientation, info:[NSObject:AnyObject]? ) -> Void in
                let storyUnit = PFObject(className: "Story_Unit")
                storyUnit["file"] = PFFile(data: data!)
                storyUnit["description"] = self.mediaDescriptions[self.mediaAssets.indexOf(mediaAsset)!]
                storyUnit.saveInBackgroundWithBlock({(success, error) -> Void in
                    if (error == nil){
                        print("\(storyUnit) saved!")
                        storyUnitsRelation.addObject(storyUnit)
                        if (self.mediaAssets.indexOf(mediaAsset) == self.mediaAssets.count - 1){
                            story.saveInBackgroundWithBlock({(success, error) -> Void in
                                if (error == nil){
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }
                                else{
                                    print(error)
                                }

                            })
                        }
                    }
                    else{
                        print(error)
                    }
                })
            })
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.forCharm == nil){
            // If charm not selected, show forCharm section
            return self.charms.count
        }
        else{
            // If charm is selected, show additional input fields for About Charm and Add Media section
            switch section{
            case 0: return 1
            case 1: return 2
            case 2: return self.mediaAssets.count + 1
            default: return 0
            }
            
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (self.forCharm == nil){
            let cell = tableView.dequeueReusableCellWithIdentifier("charmCell") as! CharmWithSubtitleTableViewCell
            let charm = self.charms[indexPath.row]
            let charmGifter = charm["gifter"] as! PFUser
            let gifterFirstName = charmGifter["firstName"] as! String
            let gifterLastName = charmGifter["lastName"] as! String
            cell.charmTitle.text = charm["name"] as? String
            cell.charmTitle.textColor = UIColor.blackColor()
            cell.charmSubtitle.text = "\(gifterFirstName) \(gifterLastName)"
            cell.charmSubtitle.textColor = UIColor(white: 0, alpha: 0.8)
            cell.backgroundColor = UIColor.whiteColor()
            cell.accessoryType = UITableViewCellAccessoryType.None
            return cell
        }
        else{
            switch indexPath.section{
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("charmCell") as! CharmWithSubtitleTableViewCell
                let charm = self.charms[indexPath.row]
                let charmGifter = charm["gifter"] as! PFUser
                let gifterFirstName = charmGifter["firstName"] as! String
                let gifterLastName = charmGifter["lastName"] as! String
                cell.charmTitle.text = self.forCharm["name"] as? String
                cell.charmTitle.textColor = UIColor.blackColor()
                cell.charmSubtitle.text = "\(gifterFirstName) \(gifterLastName)"
                cell.charmSubtitle.textColor = UIColor(white: 0, alpha: 0.8)
                cell.backgroundColor = UIColor.whiteColor()
                cell.accessoryType = UITableViewCellAccessoryType.None
                return cell
            case 1:
                switch indexPath.row{
                case 0:
                    let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldTableViewCell") as! TextFieldTableViewCell
                    cell.textField.placeholder = "Title"
                    cell.textField.delegate = self
                    cell.textField.returnKeyType = UIReturnKeyType.Next
                    return cell
                case 1:
                    let cell = tableView.dequeueReusableCellWithIdentifier("TextViewTableViewCell") as! TextViewTableViewCell
                    cell.textView.placeholder = "Description (Optional)"
                    cell.textView.returnKeyType = UIReturnKeyType.Default
                    cell.textView.delegate = self
                    (((cell.textView.inputAccessoryView as! UIToolbar).items!)[1].target = self)
                    (((cell.textView.inputAccessoryView as! UIToolbar).items!)[1].action = "textViewDoneButtonTapped:")
                    return cell
                default: return UITableViewCell()
                }
            case 2:
                if (indexPath.row == self.tableView.numberOfRowsInSection(2) - 1){
                    let cell = tableView.dequeueReusableCellWithIdentifier("ButtonWithPromptTableViewCell") as! ButtonWithPromptTableViewCell
                    cell.promptLabel.text = "Upload pictures and videos to complete the moment."
                    cell.button.setTitle("Add Media", forState: UIControlState.Normal)
                    cell.button.addTarget(self, action: "addMediaButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
                    return cell
                }
                else{
                    let cell = tableView.dequeueReusableCellWithIdentifier("MomentMediaTableViewCell") as! MomentMediaTableViewCell
                    cell.mediaCaptionTextView.delegate = self
                    (((cell.mediaCaptionTextView.inputAccessoryView as! UIToolbar).items!)[1].target = self)
                    (((cell.mediaCaptionTextView.inputAccessoryView as! UIToolbar).items!)[1].action = "textViewDoneButtonTapped:")
                    cell.mediaCaptionTextView.text = self.mediaDescriptions[indexPath.row]
                    cell.mediaPreviewImageView.backgroundColor = UIColor(white: 0.85, alpha: 1)
                    let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "storyUnitLongPressed:")
                    cell.momentMediaSheet.addGestureRecognizer(longPressGestureRecognizer)
                    
                    let manager = PHImageManager.defaultManager()
                    
                    if cell.tag != 0 {
                        manager.cancelImageRequest(PHImageRequestID(cell.tag))
                    }

                    let asset = self.mediaAssets[indexPath.row]
                    
                    cell.tag = Int(manager.requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result, _) in
                        // this result handler is called on the main thread for asynchronous requests
                            cell.mediaPreviewImageView?.image = result
                        })
                    return cell
                }
            default:return UITableViewCell()
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if (section == 0){
//            return 0
//        }
//        else{
            return 24
//        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            if (self.forCharm != nil){
                return "Selected Charm"
            }
            else{
                return "Select Charm"
            }
        case 1: return "About Moment"
        case 2: return "Add Media"
        default: return ""
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (self.forCharm == nil){
            // If charm not selected, show forCharm section
            return 1
        }
        else{
            // If charm is selected, show additional input fields for About Charm and Add Media section
            return 3
        }

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("did select row in section \(indexPath.section)")
        switch indexPath.section{
        case 0:
            if (self.forCharm == nil){
                self.forCharm = self.charms[indexPath.row]
                self.tableView.reloadData()
            }
            else{
                print("did select selected charm")
            }
        case 1: print("did select row in section 1")
        case 2: print("did select row in section 2")
        default: print("didSelectSomeRow")
        }
    }
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return UIView()
//    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.text != ""){
            self.sendButton.enabled = true
        }
        else{
            self.sendButton.enabled = false
        }
        (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 1)) as! TextViewTableViewCell).textView.becomeFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text != ""){
            self.sendButton.enabled = true
            self.momentTitle = textField.text!
        }
        else{
            self.sendButton.enabled = false
        }
        
        // Handle text entry and save
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        print("textview did end editing")
        // Handle text entry and save on didfinishediting
        let indexPathForTextView:NSIndexPath = self.indexPathForCellContainingView(textView, inTableView: self.tableView)!
        print(indexPathForTextView)
        if (indexPathForTextView.section == 2){
            self.mediaDescriptions[indexPathForTextView.row] = textView.text
        }
        else{
            // == 1
            self.momentDescription = textView.text
        }
    }
    
    func indexPathForCellContainingView(view: UIView, inTableView tableView:UITableView) -> NSIndexPath? {
        let viewCenterRelativeToTableview = tableView.convertPoint(CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds)), fromView:view)
        return tableView.indexPathForRowAtPoint(viewCenterRelativeToTableview)
    }

    
    func textViewDoneButtonTapped(sender:UIBarButtonItem){
        print("done button tapped")

        self.view.endEditing(true)
        
//        let indexPathForTextView = self.tableView.indexPathForCell(textView.superview as! TextViewTableViewCell)!
//        print(indexPathForTextView)
//        if (indexPathForTextView.section == 2){
//            self.mediaDescriptions[indexPathForTextView.row] = textView.text
//        }
    }

    func addMediaButtonTapped(sender:UIButton){
        print("addMediaButtonTapped")
        PHPhotoLibrary.requestAuthorization({(status) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                // code here
                let picker:CTAssetsPickerController = CTAssetsPickerController()
                picker.defaultAssetCollection = PHAssetCollectionSubtype.SmartAlbumUserLibrary
                // create options for fetching photo only
                let fetchOptions:PHFetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Image.rawValue)
                // assign options
                picker.assetsFetchOptions = fetchOptions;
                picker.view.tintColor = UIColor(red:0.83, green:0.75, blue:0.63, alpha:1)
                
                // to present picker as a form sheet in iPad
                picker.modalPresentationStyle = UIModalPresentationStyle.FormSheet

                picker.delegate = self
                self.presentViewController(picker, animated: true, completion: nil)
            })
        })
    }
    
    func storyUnitLongPressed(sender:UILongPressGestureRecognizer){
        print("long pressed")
    }
    
    func assetsPickerController(picker: CTAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        print(assets)
        let presentingVC = (picker.presentingViewController?.childViewControllers[0] as! NewStoryTabViewController)
        presentingVC.mediaAssets.appendContentsOf(assets as! [PHAsset])
        presentingVC.mediaDescriptions.appendContentsOf(Array(count: assets.count, repeatedValue: ""))
        presentingVC.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(2, 1)), withRowAnimation: UITableViewRowAnimation.Automatic)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
