//
//  LockMomentViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 2/4/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit
import MapKit

class LockMomentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {

    var tableViewController:UITableViewController!
    var selectedParameter:String?
    var newMomentVC:NewMomentViewController!
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var tempUnlockParameterType:String?
    var tempUnlockTime:NSDate!
    var tempUnlockLocation:PFGeoPoint!
    var tempUnlockLocationPlacemark:CLPlacemark!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Unlock Setting"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Remove", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonTapped")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneButtonTapped")
        self.navigationItem.rightBarButtonItem?.enabled = false

        self.view.backgroundColor = UIColor.whiteColor()
        
        self.tableViewController = UITableViewController()
        self.addChildViewController(self.tableViewController)
        
        self.tableViewController.tableView = UITableView(frame: CGRectZero)
        self.tableViewController.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableViewController.tableView.delegate = self
        self.tableViewController.tableView.dataSource = self
        self.tableViewController.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableViewController.tableView.estimatedRowHeight = 64
        self.tableViewController.tableView.estimatedSectionHeaderHeight = 44
        self.tableViewController.tableView.registerClass(SegmentedHeaderView.self, forHeaderFooterViewReuseIdentifier: "SegmentedHeaderView")
        self.tableViewController.tableView.registerClass(DateTimePickerTableViewCell.self, forCellReuseIdentifier: "DateTimePickerTableViewCell")
        self.tableViewController.tableView.registerClass(LocationPickerTableViewCell.self, forCellReuseIdentifier: "LocationPickerTableViewCell")
        self.view.addSubview(self.tableViewController.tableView)
        
        let viewsDictionary = ["tableView":self.tableViewController.tableView]
        let tbvHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let tbvVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)

        self.view.addConstraints(tbvHConstraints)
        self.view.addConstraints(tbvVConstraints)
        
        if self.newMomentVC.unlockParameterType != nil{
            self.tempUnlockParameterType = self.newMomentVC.unlockParameterType
            if self.newMomentVC.unlockParameterType == "time"{
                self.tempUnlockTime = self.newMomentVC.unlockTime
                self.selectedParameter = "Time"
            }
            else{
                self.tempUnlockLocation = self.newMomentVC.unlockLocation
                self.tempUnlockLocationPlacemark = self.newMomentVC.unlockLocationPlacemark
                self.selectedParameter = "Location"
            }
        }
        self.checkForDoneButtonState()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0:
                if self.selectedParameter == "Time"{
                    let cell = UITableViewCell()
                    cell.textLabel?.text = "Set Moment to unlock when:"
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    return cell
                }
                else if self.selectedParameter == "Location"{
                    let cell = UITableViewCell()
                    cell.textLabel?.text = "Set Moment to unlock where:"
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    return cell
                }
                else{
                    let cell = UITableViewCell()
                    cell.textLabel?.text = "Select an Unlock Type to Begin"
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    return cell
                }
            case 1:
                let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "value1")
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                if (self.selectedParameter == "Time"){
                    // show date & time picker
                    cell.textLabel?.text = "Time"
                    if (self.newMomentVC.unlockTime == nil && self.tempUnlockTime == nil){
                        cell.detailTextLabel?.text = "Use Picker to Set"
                    }
                    else{
                        cell.textLabel?.text = "Unlocks on"
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
                        if self.tempUnlockTime == nil{
                            cell.detailTextLabel?.text = dateFormatter.stringFromDate(self.newMomentVC.unlockTime)
                        }
                        else{
                            cell.detailTextLabel?.text = dateFormatter.stringFromDate(self.tempUnlockTime)
                        }
                    }
                    return cell
                }
                else{
                    // show location picker
                    cell.textLabel?.text = "Location"
                    if (self.newMomentVC.unlockLocation == nil && self.tempUnlockLocation == nil){
                        cell.detailTextLabel?.text = "Press & Hold on Map to Set"
                    }
                    else{
                        cell.textLabel?.text = "Unlocks near"
                        if self.tempUnlockLocation != nil{
                            if (self.tempUnlockLocationPlacemark == nil || self.tempUnlockLocationPlacemark.locality == nil || self.tempUnlockLocationPlacemark.administrativeArea == nil){
                                cell.detailTextLabel?.text = "\(self.tempUnlockLocation.latitude), \(self.tempUnlockLocation.longitude)"
                            }
                            else{
                                cell.detailTextLabel?.text = "\(self.tempUnlockLocationPlacemark.locality!), \(self.tempUnlockLocationPlacemark.administrativeArea!)"
                            }
                        }
                        else{
                            if (self.newMomentVC.unlockLocationPlacemark == nil || self.newMomentVC.unlockLocationPlacemark.locality == nil || self.newMomentVC.unlockLocationPlacemark.administrativeArea == nil){
                                cell.detailTextLabel?.text = "\(self.newMomentVC.unlockLocation.latitude), \(self.newMomentVC.unlockLocation.longitude)"
                            }
                            else{
                                cell.detailTextLabel?.text = "\(self.newMomentVC.unlockLocationPlacemark.locality!), \(self.newMomentVC.unlockLocationPlacemark.administrativeArea!)"
                            }
                        }
                    }
                    return cell
                }
            case 2:
                if self.selectedParameter == "Time"{
                    let cell = tableView.dequeueReusableCellWithIdentifier("DateTimePickerTableViewCell") as! DateTimePickerTableViewCell
                    if (self.newMomentVC.unlockTime != nil){
                        cell.dateTimePicker.date = self.newMomentVC.unlockTime
                    }
                    cell.dateTimePicker.addTarget(self, action: "dateTimePickerPicked:", forControlEvents: UIControlEvents.ValueChanged)
                    return cell
                }
                else if self.selectedParameter == "Location"{
                    // present location picker
                    let cell = tableView.dequeueReusableCellWithIdentifier("LocationPickerTableViewCell") as! LocationPickerTableViewCell
                    cell.mapView.delegate = self
                    cell.mapView.showsUserLocation = true
                    cell.longPressGestureRecognizer.addTarget(self, action: "mapViewLongPressed:")
                    if(self.newMomentVC.unlockLocation == nil){
                        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                        print(self.appDelegate.locationManager)
                        let location = CLLocationCoordinate2D(latitude: self.appDelegate.latestLocation[0], longitude: self.appDelegate.latestLocation[1])
                        let region = MKCoordinateRegion(center: location, span: span)
                        cell.mapView.setRegion(region, animated: true)
                    }
                    else{
                        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                        let location = CLLocationCoordinate2D(latitude: self.newMomentVC.unlockLocation.latitude, longitude: self.newMomentVC.unlockLocation.longitude)
                        print(location)
                        let region = MKCoordinateRegion(center: location, span: span)
                        cell.mapView.removeAnnotations(cell.mapView.annotations)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2D(latitude: self.newMomentVC.unlockLocation.latitude, longitude: self.newMomentVC.unlockLocation.longitude)
                        cell.mapView.addAnnotation(annotation)
                        cell.mapView.setRegion(region, animated: true)
                    }
                    return cell
                }
                else{
                    return UITableViewCell()
                }
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            // if time lock
            if self.selectedParameter == "Time"{
                return 3
            }
            // if location lock
            else if self.selectedParameter == "Location"{
                return 3
            }
            // if unselected
            else{
                return 1
            }
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("SegmentedHeaderView") as! SegmentedHeaderView
            header.segmentedControl.addTarget(self, action: "parameterSegmentedControlChanged:", forControlEvents: UIControlEvents.ValueChanged)
            if self.selectedParameter == "Time"{
                header.segmentedControl.selectedSegmentIndex = 0
            }
            else if self.selectedParameter == "Location"{
                header.segmentedControl.selectedSegmentIndex = 1
            }
            return header
        }
        else{
            return nil
        }
    }
    
    func parameterSegmentedControlChanged(sender:UISegmentedControl){
        
        let numRowToDelete:Int = self.tableViewController.tableView.numberOfRowsInSection(0)
        let numRowToInsert:Int!
        if sender.selectedSegmentIndex == 0{
            self.selectedParameter = "Time"
            self.tempUnlockParameterType = "time"
            numRowToInsert = 3
        }
        else if sender.selectedSegmentIndex == 1{
            self.selectedParameter = "Location"
            self.tempUnlockParameterType = "location"
            numRowToInsert = 3
        }
        else{
            self.selectedParameter = nil
            numRowToInsert = 1
        }
        print("selectedParameter is \(self.selectedParameter)")

        
        var indexPathsToInsert:[NSIndexPath] = []
        for (var i = 0; i < numRowToInsert; i++) {
            indexPathsToInsert.append(NSIndexPath(forRow: i, inSection: 0))
        }
        
        var indexPathsToDelete:[NSIndexPath] = []
        for (var i = 0; i < numRowToDelete; i++) {
            indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: 0))
        }
        
        self.tableViewController.tableView.beginUpdates()
        self.tableViewController.tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableViewController.tableView.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableViewController.tableView.endUpdates()
        self.tableViewController.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        self.checkForDoneButtonState()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return UITableViewAutomaticDimension
        }
        else{
            return 0
        }
    }
    
    func dateTimePickerPicked(sender:UIDatePicker){
        self.tempUnlockTime = sender.date
        self.tableViewController.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.checkForDoneButtonState()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelButtonTapped(){
        if self.selectedParameter != nil{
            let alertVC = UIAlertController(title: "Are You Sure?", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let sureAction = UIAlertAction(title: "Remove Unlock Setting", style: UIAlertActionStyle.Default, handler: {(alert:UIAlertAction) in
                self.newMomentVC.unlockParameterType = nil
                self.newMomentVC.unlockTime = nil
                self.newMomentVC.unlockLocation = nil
                self.newMomentVC.unlockLocationPlacemark = nil
                self.dismissViewControllerAnimated(true, completion: {
                    let numRowToDelete:Int = self.newMomentVC.tableViewController.tableView.numberOfRowsInSection(0)
                    let numRowToInsert:Int!
                    if self.newMomentVC.unlockParameterType != nil{
                        numRowToInsert = 3
                    }
                    else{
                        numRowToInsert = 2
                    }
                    
                    var indexPathsToInsert:[NSIndexPath] = []
                    for (var i = 0; i < numRowToInsert; i++) {
                        indexPathsToInsert.append(NSIndexPath(forRow: i, inSection: 0))
                    }
                    
                    var indexPathsToDelete:[NSIndexPath] = []
                    for (var i = 0; i < numRowToDelete; i++) {
                        indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: 0))
                    }
                    
                    self.newMomentVC.tableViewController.tableView.beginUpdates()
                    self.newMomentVC.tableViewController.tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: UITableViewRowAnimation.Fade)
                    self.newMomentVC.tableViewController.tableView.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: UITableViewRowAnimation.Fade)
                    self.newMomentVC.tableViewController.tableView.endUpdates()
                    self.newMomentVC.tableViewController.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                    self.checkForDoneButtonState()
                })
            })
            let notSureAction = UIAlertAction(title: "Not Now", style: UIAlertActionStyle.Cancel, handler: {(alert:UIAlertAction) in
                
            })
            alertVC.addAction(sureAction)
            alertVC.addAction(notSureAction)
            self.presentViewController(alertVC, animated: true, completion: nil)
        }
        else{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func doneButtonTapped(){
        self.newMomentVC.unlockParameterType = self.tempUnlockParameterType
        self.newMomentVC.unlockTime = self.tempUnlockTime
        self.newMomentVC.unlockLocation = self.tempUnlockLocation
        self.newMomentVC.unlockLocationPlacemark = self.tempUnlockLocationPlacemark

        self.dismissViewControllerAnimated(true, completion: {
            let numRowToDelete:Int = self.newMomentVC.tableViewController.tableView.numberOfRowsInSection(0)
            let numRowToInsert:Int!
            if self.newMomentVC.unlockParameterType != nil{
                numRowToInsert = 3
            }
            else{
                numRowToInsert = 2
            }
            
            var indexPathsToInsert:[NSIndexPath] = []
            for (var i = 0; i < numRowToInsert; i++) {
                indexPathsToInsert.append(NSIndexPath(forRow: i, inSection: 0))
            }
            
            var indexPathsToDelete:[NSIndexPath] = []
            for (var i = 0; i < numRowToDelete; i++) {
                indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: 0))
            }
            
            self.newMomentVC.tableViewController.tableView.beginUpdates()
            self.newMomentVC.tableViewController.tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: UITableViewRowAnimation.Fade)
            self.newMomentVC.tableViewController.tableView.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: UITableViewRowAnimation.Fade)
            self.newMomentVC.tableViewController.tableView.endUpdates()
            self.newMomentVC.tableViewController.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            self.checkForDoneButtonState()
        })
    }
    
    func checkForDoneButtonState(){
        if self.tempUnlockParameterType == "time"{
            if self.tempUnlockTime != nil{
                self.navigationItem.rightBarButtonItem?.enabled = true
            }
            else{
                self.navigationItem.rightBarButtonItem?.enabled = false
            }
        }
        else if self.tempUnlockParameterType == "location"{
            if self.tempUnlockLocation != nil && self.tempUnlockLocationPlacemark != nil{
                self.navigationItem.rightBarButtonItem?.enabled = true
            }
            else{
                self.navigationItem.rightBarButtonItem?.enabled = false
            }
        }
        else{
            self.navigationItem.rightBarButtonItem?.enabled = false
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
        dropPin.title = "Selected Location"
        dropPin.subtitle = "\(locationCoordinate)"
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(dropPin)
        self.tempUnlockLocation = PFGeoPoint(location: CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude))
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude), completionHandler: {(placemarks, error) -> Void in
            guard let placemarks = placemarks as [CLPlacemark]! else { return }
            if placemarks.count > 0{
                let placemark = (placemarks as [CLPlacemark]!)[0]
                self.tempUnlockLocationPlacemark = placemark
                print(placemark)
                self.tableViewController.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                self.checkForDoneButtonState()
            }
        })
    }



}
