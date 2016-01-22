//
//  NewStoryTabViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/21/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit
import MapKit
import CTAssetsPickerController
import MBProgressHUD

class NewStoryTabViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, CTAssetsPickerControllerDelegate, MKMapViewDelegate {

    var cancelButton:UIBarButtonItem!
    var sendButton:UIBarButtonItem!
    
    var charms:[Charm]! = []
    var forCharm:Charm!
    var storyUnits:[Story_Unit] = []
    var mediaAssets:[PHAsset] = []
    var mediaDescriptions:[String] = []
    var unlockParameterType:String!
    var unlockTime:NSDate!
    var unlockLocation:PFGeoPoint!
    var unlockLocationPlacemark:CLPlacemark!
    var showUnlockParameterPicker = false
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var shouldResetSelectedCharm = true
    var momentTitle:TextFieldTableViewCell? = nil
    var momentDesc:TextViewTableViewCell? = nil
    var activeField: UITextView?
    var oldContentInset:UIEdgeInsets!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonTapped:")
//        self.tabBarController?.navigationItem.leftBarButtonItem = self.cancelButton
        
        self.sendButton = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Done, target: self, action: "sendButtonTapped:")
        self.sendButton.enabled = false
//        self.tabBarController?.navigationItem.rightBarButtonItem = self.sendButton
        
        self.tableView = UITableView(frame: self.view.frame, style: UITableViewStyle.Plain)
        self.tableView.registerClass(CharmWithSubtitleTableViewCell.self, forCellReuseIdentifier: "charmCell")
        self.tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldTableViewCell")
        self.tableView.registerClass(TextViewTableViewCell.self, forCellReuseIdentifier: "TextViewTableViewCell")
        self.tableView.registerClass(SegmentedControlTableViewCell.self, forCellReuseIdentifier: "SegmentedControlTableViewCell")
        self.tableView.registerClass(ButtonWithPromptTableViewCell.self, forCellReuseIdentifier: "ButtonWithPromptTableViewCell")
        self.tableView.registerClass(MomentMediaTableViewCell.self, forCellReuseIdentifier: "MomentMediaTableViewCell")
        self.tableView.registerClass(DateTimePickerTableViewCell.self, forCellReuseIdentifier: "DateTimePickerTableViewCell")
        self.tableView.registerClass(LocationPickerTableViewCell.self, forCellReuseIdentifier: "LocationPickerTableViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundColor = UIColor(white: 1, alpha: 1)
        
        
        registerForKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
        if(shouldResetSelectedCharm){
            resetViewInputs();
        }
        //default to true unless explicitly set for the next time
        self.shouldResetSelectedCharm = true
        self.navigationItem.rightBarButtonItem = sendButton
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.title = "New Moment"
    }
    
    func resetViewInputs(){
        print("resetting selected charm")
        self.forCharm = nil
        self.momentTitle?.textField.text = ""
        self.momentDesc?.textView.text = ""
        self.mediaAssets = []
        self.mediaDescriptions = []
        self.tableView.reloadData()
        self.unlockParameterType = nil
        self.unlockTime = nil
        self.unlockLocation = nil

    }
    


    // MARK: - Navigation

    func cancelButtonTapped(sender:UIBarButtonItem){
        print("cancel button tapped")
//        self.view.endEditing(true)
//        self.dismissViewControllerAnimated(true, completion: nil)
        self.view.endEditing(true)
        resetViewInputs()
        self.shouldResetSelectedCharm = true
    }
    
    func sendButtonTapped(sender:UIBarButtonItem){
        var analyticsDimensions = [
            "attachmentCount": String(self.mediaAssets.count),
            "userId": PFUser.currentUser()!.objectId!,
            "titleLength": String(self.momentTitle?.textField.text?.characters.count),
            "descriptionLength": String(self.momentDesc?.textView.text.characters.count),
            "unlockType": "None"
        ]
        

        print("Send button tapped")
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHUD.labelText = "Sending..."
//        self.navigationItem.leftBarButtonItem?.enabled = false
//        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationItem.rightBarButtonItem?.enabled = false
        let story = PFObject(className: "Story")
        story["title"] = self.momentTitle?.textField.text
        story["description"] = self.momentDesc?.textView.text
        story["sender"] = PFUser.currentUser()
        story["charmGroup"] = self.forCharm["charmGroup"]
        if (self.unlockParameterType != nil){
            analyticsDimensions["unlockType"] = self.unlockParameterType
            print("unlock parameter type is not nil")
            story["unlockType"] = self.unlockParameterType
            if (self.unlockParameterType == "time"){
                story["unlockTime"] = self.unlockTime
            }
            else{
                story["unlockLocation"] = self.unlockLocation
            }
            story["unlocked"] = false
        }
        else{
            story["unlocked"] = true
        }
        story["readStatus"] = false
        PFAnalytics.trackEvent("sentNewMoment", dimensions:analyticsDimensions)
        print("Creating image manager")
        let manager = PHImageManager.defaultManager()
        let storyUnitsRelation:PFRelation = story.relationForKey("storyUnits")
        var savedCount = 0
        if (self.mediaAssets.count > 0){
            for mediaAsset in self.mediaAssets{
                print("Finding media asset")
                print(mediaAsset)
                let options = PHImageRequestOptions()
                options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
                options.synchronous = false
                options.networkAccessAllowed = true
                options.progressHandler = {(progress, error, stop, info) -> Void in
                    print(progress)
                }
                manager.requestImageForAsset(mediaAsset, targetSize: CGSizeMake(1200, 1200), contentMode: PHImageContentMode.Default, options: options, resultHandler:{(image:UIImage?, info:[NSObject:AnyObject]?) -> Void in
                    let storyUnit = PFObject(className: "Story_Unit")
                    let sizedImage = self.RBResizeImage(image!, targetSize: CGSizeMake(1200, 1200))
                    storyUnit["file"] = PFFile(data: UIImagePNGRepresentation(sizedImage)!)
                    storyUnit["description"] = self.mediaDescriptions[self.mediaAssets.indexOf(mediaAsset)!]
                    storyUnit.saveInBackgroundWithBlock({(success, error) -> Void in
                        if (error == nil){
                            print("\(storyUnit) saved!")
                            savedCount++
                            storyUnitsRelation.addObject(storyUnit)
                            if (savedCount == self.mediaAssets.count){
                                story.saveInBackgroundWithBlock({(success, error) -> Void in
                                    if (error == nil){
                                        // load charms into the new story controller
//                                        let barViewControllers = self.tabBarController?.viewControllers
//                                        let stvc = barViewControllers![0].childViewControllers[0] as! StoriesTabViewController
//                                        stvc.indexOfCharmViewed = self.charms.indexOf(self.forCharm)
//                                        stvc.loadStoriesForCharmViewed()
                                        self.tabBarController?.selectedIndex = 0
                                        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
                                        self.appDelegate.collectionController.navigationController?.popToRootViewControllerAnimated(true)
                                    }
                                    else{
                                        print(error)
                                        self.navigationItem.rightBarButtonItem?.enabled = true
                                        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
                                        ParseErrorHandlingController.handleParseError(error)
                                    }
                                })
                            }
                        }
                        else{
                            print(error)
                            self.tabBarController?.navigationItem.rightBarButtonItem?.enabled = true
                            MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
                            ParseErrorHandlingController.handleParseError(error)
                        }
                    })
                })
            }
        }else{
            story.saveInBackgroundWithBlock({(success, error) -> Void in
                if (error == nil){
//                    (self.parentViewController?.presentingViewController?.childViewControllers[0] as! StoriesTabViewController).indexOfCharmViewed = self.charms.indexOf(self.forCharm)
//                    (self.parentViewController?.presentingViewController?.childViewControllers[0] as! StoriesTabViewController).loadStoriesForCharmViewed()
//                    self.dismissViewControllerAnimated(true, completion: nil)
//                    let barViewControllers = self.tabBarController?.viewControllers
//                    let stvc = barViewControllers![0] as! StoriesTabViewController
//                    stvc.indexOfCharmViewed = self.charms.indexOf(self.forCharm)
//                    stvc.loadStoriesForCharmViewed()
                    progressHUD.progress = 1
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
                    self.tabBarController?.selectedIndex = 0
                    self.appDelegate.collectionController.navigationController?.popToRootViewControllerAnimated(true)
                }
                else{
                    print(error)
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
                    self.tabBarController?.navigationItem.rightBarButtonItem?.enabled = true
                    ParseErrorHandlingController.handleParseError(error)
                }
                
            })

        }
    }
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 3){
            return 400
        }
        else{
            return 60
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
            case 2:
                if (self.unlockParameterType == nil){
                    return 1
                }
                else{
//                    if (self.showUnlockParameterPicker == true){
                        return 3
//                    }
//                    else{
//                        return 2
//                    }
                }
            case 3: return self.mediaAssets.count + 1
            default: return 0
            }
            
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (self.forCharm == nil){
            let cell = tableView.dequeueReusableCellWithIdentifier("charmCell") as! CharmWithSubtitleTableViewCell
            let charm = self.charms[indexPath.row]
            cell.charmTitle.text = charm.charmGroup!.name
            cell.charmTitle.textColor = UIColor.blackColor()
            cell.charmSubtitle.textColor = UIColor(white: 0, alpha: 0.8)
            cell.charmSubtitle.text = ""
            cell.backgroundColor = UIColor.whiteColor()
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            return cell
        }
        else{
            switch indexPath.section{
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("charmCell") as! CharmWithSubtitleTableViewCell
                let charm = self.forCharm

//                cell.charmSubtitle.text = "Gifted charm"
//                cell.charmSubtitle.textColor = UIColor(white: 0, alpha: 0.8)

                cell.charmTitle.text = charm.charmGroup!.name
                cell.charmTitle.textColor = UIColor.blackColor()
                cell.backgroundColor = UIColor.whiteColor()
                cell.accessoryType = UITableViewCellAccessoryType.None
                return cell
            case 1:
                switch indexPath.row{
                case 0:
                    let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldTableViewCell") as! TextFieldTableViewCell
                    cell.textField.placeholder = "Name"
                    cell.textField.delegate = self
                    cell.textField.returnKeyType = UIReturnKeyType.Default
                    (((cell.textField.inputAccessoryView as! UIToolbar).items!)[1].target = self)
                    (((cell.textField.inputAccessoryView as! UIToolbar).items!)[1].action = "textViewDoneButtonTapped:")
                    self.momentTitle = cell
                    return cell
                case 1:
                    let cell = tableView.dequeueReusableCellWithIdentifier("TextViewTableViewCell") as! TextViewTableViewCell
                    cell.textView.placeholder = "Description (Optional)"
                    cell.textView.returnKeyType = UIReturnKeyType.Default
                    cell.textView.delegate = self
                    (((cell.textView.inputAccessoryView as! UIToolbar).items!)[1].target = self)
                    (((cell.textView.inputAccessoryView as! UIToolbar).items!)[1].action = "textViewDoneButtonTapped:")
                    self.momentDesc = cell
                    return cell
                default: return UITableViewCell()
                }
            case 2:
                switch indexPath.row{
                case 0:
                    let cell = tableView.dequeueReusableCellWithIdentifier("SegmentedControlTableViewCell") as! SegmentedControlTableViewCell
                    cell.segmentedControl.setTitle("Time", forSegmentAtIndex: 0)
                    cell.segmentedControl.setTitle("Location", forSegmentAtIndex: 1)
                    if (self.unlockParameterType != nil){
                        if (self.unlockParameterType == "time"){
                            cell.segmentedControl.selectedSegmentIndex = 0
                        }
                        else{
                            cell.segmentedControl.selectedSegmentIndex = 1
                        }
                    }else{
                        cell.segmentedControl.selectedSegmentIndex = -1
                    }
                    cell.segmentedControl.addTarget(self, action: "unlockParameterPicked:", forControlEvents: UIControlEvents.ValueChanged)
                    return cell
                case 1:
                    let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "value1")
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    if (self.unlockParameterType == "time"){
                        // show date & time picker
                        cell.textLabel?.text = "Time"
                        if (self.unlockTime == nil){
                            cell.detailTextLabel?.text = "Tap Here to Set"
                        }
                        else{
                            cell.textLabel?.text = "Unlocks on"
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
                            cell.detailTextLabel?.text = dateFormatter.stringFromDate(self.unlockTime)
                        }
                        return cell
                    }
                    else{
                        // show location picker
                        cell.textLabel?.text = "Location"
                        if (self.unlockLocation == nil){
                            cell.detailTextLabel?.text = "Press & Hold on Map to Set"
                        }
                        else{
                            cell.textLabel?.text = "Unlocks near"
                            if (self.unlockLocationPlacemark == nil || self.unlockLocationPlacemark.locality == nil || self.unlockLocationPlacemark.administrativeArea == nil){
                                cell.detailTextLabel?.text = "\(self.unlockLocation.latitude), \(self.unlockLocation.longitude)"
                            }
                            else{
                                cell.detailTextLabel?.text = "\(self.unlockLocationPlacemark.locality!), \(self.unlockLocationPlacemark.administrativeArea!)"
                            }
                        }
                        return cell
                    }
                case 2:
                    // hidden picker row
                    if (self.unlockParameterType == "time"){
                        // present date & time picker
                        let cell = tableView.dequeueReusableCellWithIdentifier("DateTimePickerTableViewCell") as! DateTimePickerTableViewCell
                        if (self.unlockTime != nil){
                            cell.dateTimePicker.date = self.unlockTime
                        }
                        cell.dateTimePicker.addTarget(self, action: "dateTimePickerPicked:", forControlEvents: UIControlEvents.ValueChanged)
                        return cell
                    }
                    else{
                        // present location picker
                        let cell = tableView.dequeueReusableCellWithIdentifier("LocationPickerTableViewCell") as! LocationPickerTableViewCell
                        cell.mapView.delegate = self
                        cell.mapView.showsUserLocation = true
                        cell.longPressGestureRecognizer.addTarget(self, action: "mapViewLongPressed:")
                        if(self.unlockLocation == nil){
                            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                            let location = CLLocationCoordinate2D(latitude: (self.appDelegate.locationManager.location?.coordinate.latitude)!, longitude: (self.appDelegate.locationManager.location?.coordinate.longitude)!)
                            let region = MKCoordinateRegion(center: location, span: span)
                            cell.mapView.setRegion(region, animated: true)
                        }
                        else{
                            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                            let location = CLLocationCoordinate2D(latitude: self.unlockLocation.latitude, longitude: self.unlockLocation.longitude)
                            print(location)
                            let region = MKCoordinateRegion(center: location, span: span)
                            cell.mapView.removeAnnotations(cell.mapView.annotations)
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = CLLocationCoordinate2D(latitude: self.unlockLocation.latitude, longitude: self.unlockLocation.longitude)
                            cell.mapView.addAnnotation(annotation)
                            cell.mapView.setRegion(region, animated: true)
                        }
                        return cell
                    }
                default:
                    print("default case")
                    return UITableViewCell()
                }
            case 3:
                if (indexPath.row == self.tableView.numberOfRowsInSection(3) - 1){
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
//                    cell.mediaCaptionTextView.placeholder = "Description (Optional)"
                    cell.mediaCaptionTextView.text = self.mediaDescriptions[indexPath.row]
                    cell.mediaCaptionTextView.delegate = self
                    cell.mediaPreviewImageView.backgroundColor = nil
                    
                    let manager = PHImageManager.defaultManager()
                    
                    if cell.tag != 0 {
                        manager.cancelImageRequest(PHImageRequestID(cell.tag))
                    }

                    let asset = self.mediaAssets[indexPath.row]
                    let options = PHImageRequestOptions()
                    options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
                    options.synchronous = false
                    options.networkAccessAllowed = true
                    options.progressHandler = {(progress, error, stop, info) -> Void in
                        print(progress)
                    }
                    manager.requestImageForAsset(asset, targetSize: CGSizeMake(1200, 1200), contentMode: PHImageContentMode.Default, options: options, resultHandler:{(image:UIImage?, info:[NSObject:AnyObject]?) -> Void in
                        // this result handler is called on the main thread for asynchronous requests
                            cell.mediaPreviewImageView?.image = image
//                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
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
            return 40
//        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section{
        case 0:
            let headerView = CharmsTableViewHeader()
            headerView.sectionTitle.text = "1. Select Charm"
            return headerView
        case 1:
            let headerView = CharmsTableViewHeader()
            headerView.sectionTitle.text = "2. About the Moment"
            return headerView
        case 2:
            let headerView = CharmsTableViewHeader()
            headerView.sectionTitle.text = "3. Set Unlock Parameter"
            return headerView
        case 3:
            let headerView = CharmsTableViewHeader()
            headerView.sectionTitle.text = "4. Add Media"
            return headerView
        default:
            return nil
        }
    }

    
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section{
//        case 0:
//            if (self.forCharm != nil){
//                return "Selected Charm"
//            }
//            else{
//                return "Select Charm"
//            }
//        case 1: return "About Moment"
//        case 2: return "Unlock Parameter"
//        case 3: return "Add Media"
//        default: return ""
//        }
//    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (self.forCharm == nil){
            // If charm not selected, show forCharm section
            return 1
        }
        else{
            // If charm is selected, show additional input fields for About Charm and Add Media section
            return 4
        }

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("did select row in section \(indexPath.section)")
        switch indexPath.section{
        case 0:
            if (self.forCharm == nil){
                self.forCharm = self.charms[indexPath.row]
                print("setting to \(self.forCharm)")
                self.tableView.reloadData()
            }
            else{
                print("did select selected charm")
                self.forCharm = nil
                self.tableView.reloadData()
            }
        case 1: print("did select row in section 1")
        case 2:
            print("did select row in section 2")
            if (indexPath.row == 1){
                if (self.showUnlockParameterPicker){
                    if (self.unlockParameterType == "time"){
                        self.unlockTime = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 2)) as! DateTimePickerTableViewCell).dateTimePicker.date
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
                    else{
                        
                    }
                }
//                self.showUnlockParameterPicker = !self.showUnlockParameterPicker
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        case 3:
            print("did select row in section 3")
            print("indexPath.row for selected row in section 3: \(indexPath.row)")
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
//        (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 1)) as! TextViewTableViewCell).textView.becomeFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text != ""){
            self.sendButton.enabled = true
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
        if (indexPathForTextView.section == 3){
            self.mediaDescriptions[indexPathForTextView.row] = textView.text
        }
        else{
            // == 1
            // This would be the moment desc
        }
        self.activeField = nil
    }
    

    
    func indexPathForCellContainingView(view: UIView, inTableView tableView:UITableView) -> NSIndexPath? {
        let viewCenterRelativeToTableview = tableView.convertPoint(CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds)), fromView:view)
        return tableView.indexPathForRowAtPoint(viewCenterRelativeToTableview)
    }

    
    func textViewDoneButtonTapped(sender:UIBarButtonItem){
        print("done button tapped")
        self.view.endEditing(true)
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        let indexPathForTextView:NSIndexPath = self.indexPathForCellContainingView(textView, inTableView: self.tableView)!
        print(indexPathForTextView)
        if (indexPathForTextView.section == 3){
            self.activeField = textView //only set activeField for section 3
        }
        
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    
    func keyboardWasShown(aNotification: NSNotification) {
        oldContentInset = self.tableView.contentInset
        if activeField != nil {
            let info = aNotification.userInfo as! [String: AnyObject],
            kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().size,
            contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
            
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
            
            // If active text field is hidden by keyboard, scroll it so it's visible
            // Your app might not need or want this behavior.
            var aRect = self.view.frame
            aRect.size.height -= kbSize.height
            
            print("keyboard was shown!")
            if !CGRectContainsPoint(aRect, activeField!.frame.origin) {
                let indexPathForTextView:NSIndexPath = self.indexPathForCellContainingView(activeField!, inTableView: self.tableView)!
                let myRect = tableView.rectForRowAtIndexPath(NSIndexPath(forItem: indexPathForTextView.row, inSection: 3)) //get offset for first the row in section
    //            print("scrolling rect to visible.  activeField.frame is \(activeField!.frame) and parent is \(myRect)")
                let scrollToRect = CGRectMake(0, myRect.origin.y + activeField!.frame.origin.y, activeField!.frame.size.width, activeField!.frame.size.height) //add the offsets of the text field and the
                self.tableView.scrollRectToVisible(scrollToRect, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(aNotification: NSNotification) {
//        let contentInsets = UIEdgeInsetsZero
        self.tableView.contentInset = oldContentInset
        self.tableView.scrollIndicatorInsets = oldContentInset
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
                picker.view.tintColor = UIColor(red:0.95, green:0.09, blue:0.25, alpha:1)
                
                // to present picker as a form sheet in iPad
                picker.modalPresentationStyle = UIModalPresentationStyle.FormSheet

                picker.delegate = self
                self.presentViewController(picker, animated: true, completion: nil)
            })
        })
    }
    
    func unlockParameterPicked(sender:UISegmentedControl){
        if (sender.selectedSegmentIndex == 0){
            self.unlockParameterType = "time"
            self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(2, 1)), withRowAnimation: UITableViewRowAnimation.Automatic)
            self.unlockTime = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 2)) as! DateTimePickerTableViewCell).dateTimePicker.date
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        else{
            self.unlockParameterType = "location"
            self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(2, 1)), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func mapViewLongPressed(sender:UILongPressGestureRecognizer){
        let mapView = sender.view as! MKMapView
        // Here we get the CGPoint for the touch and convert it to latitude and longitude coordinates to display on the map
        let point:CGPoint = sender.locationInView(mapView)
        let locationCoordinate:CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: mapView)

        // Then all you have to do is create the annotation and add it to the map
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = locationCoordinate
        print(locationCoordinate)
        dropPin.title = "Selected Location"
        dropPin.subtitle = "\(locationCoordinate)"
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(dropPin)
        self.unlockLocation = PFGeoPoint(location: CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude))
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude), completionHandler: {(placemarks, error) -> Void in
            guard let placemarks = placemarks as [CLPlacemark]! else { return }
            if placemarks.count > 0{
                let placemark = (placemarks as [CLPlacemark]!)[0]
                self.unlockLocationPlacemark = placemark
                if (self.unlockParameterType == "location"){
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }
        })
    }
    
    func assetsPickerController(picker: CTAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        print(assets)
        let presentingVC = self //(picker.presentingViewController?.childViewControllers[0] as! NewStoryTabViewController)
        presentingVC.mediaAssets.appendContentsOf(assets as! [PHAsset])
        presentingVC.mediaDescriptions.appendContentsOf(Array(count: assets.count, repeatedValue: ""))
        presentingVC.tableView.reloadData()
        self.shouldResetSelectedCharm = false
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dateTimePickerPicked(sender:UIDatePicker){
        self.unlockTime = sender.date
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    override func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        print("tests")
        if (scrollView == self.tableView){
            return true
        }
        else{
            return false
        }
    }
    
    // Code by @hcatlin
    func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    // end code by @hcatlin

}
