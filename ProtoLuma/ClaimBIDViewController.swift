//
//  ClaimBIDViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/1/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit
class ClaimBIDViewController: UIViewController {
    
    var scrollView:TPKeyboardAvoidingScrollView!
    var enterBIDInstructionLabel:UILabel!
    var enterBIDTextField:UITextField!
    var submitButton:UIButton!
    var bracelet:PFObject!
    var braceletSerialNumber:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView = TPKeyboardAvoidingScrollView(frame: self.view.frame)
        self.scrollView.backgroundColor = UIColor.whiteColor()
        self.view = self.scrollView
        
        self.enterBIDInstructionLabel = UILabel(frame: CGRectZero)
        self.enterBIDInstructionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.enterBIDInstructionLabel.text = "Enter Bracelet ID"
        self.enterBIDInstructionLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(self.enterBIDInstructionLabel)
        
        self.enterBIDTextField = UITextField(frame: CGRectZero)
        self.enterBIDTextField.translatesAutoresizingMaskIntoConstraints = false
        self.enterBIDTextField.borderStyle = UITextBorderStyle.RoundedRect
        self.view.addSubview(self.enterBIDTextField)
        
        self.submitButton = UIButton(frame: CGRectZero)
        self.submitButton.translatesAutoresizingMaskIntoConstraints = false
        self.submitButton.setTitle("Submit", forState: UIControlState.Normal)
        self.submitButton.setTitleColor(UIColor(red: 181/255, green: 164/255, blue: 140/255, alpha: 1), forState: UIControlState.Normal)
        self.submitButton.addTarget(self, action: "submitButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.submitButton)
        
        
        let xCenterConstraint = NSLayoutConstraint(item: self.enterBIDInstructionLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.view.addConstraint(xCenterConstraint)
        
        let viewsDictionary = ["instructionLabel":self.enterBIDInstructionLabel, "BIDTextField":self.enterBIDTextField, "submitButton":self.submitButton]
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|->=0-[instructionLabel(200)]->=0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|->=60-[instructionLabel(30)]-12-[BIDTextField(50)]-30-[submitButton(40)]->=0-|", options: [NSLayoutFormatOptions.AlignAllLeft, NSLayoutFormatOptions.AlignAllRight], metrics: nil, views: viewsDictionary)
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalConstraints)
        self.enterBIDTextField.becomeFirstResponder()

        print(PFUser.currentUser()!["bracelet"])
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func submitButtonTapped(sender: UIButton) {
        
        if (PFUser.currentUser()!["bracelet"] == nil){
            
        }
        else{
            print("helo")
            PFUser.currentUser()!["bracelet"].fetchIfNeededInBackgroundWithBlock({(result, error) -> Void in
                print(result)
                self.braceletSerialNumber = result!.objectForKey("serialNumber") as! String
                self.performSegueWithIdentifier("showPairBracelet", sender: self)
            })
        }

        
        // Get BID from user input
        let BID = self.enterBIDTextField.text
        
        // Check if BID submitted is found in purchased inventory
        let queryCheckBIDExistsAndOrphaned = PFQuery(className: "Bracelet")
        queryCheckBIDExistsAndOrphaned.whereKey("serialNumber", equalTo: BID!)
        queryCheckBIDExistsAndOrphaned.includeKey("gifter")
        queryCheckBIDExistsAndOrphaned.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            if (error == nil){
                if (objects!.count == 0){
                    // BID doesn't exist, display alert and focus on textfield if not found
                    let alert = UIAlertController(title: "Bracelet Not Found", message: "Please confirm the Bracelet ID entered is correct.", preferredStyle: UIAlertControllerStyle.Alert)
                    let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: {(alertAction:UIAlertAction) -> Void in
                        self.enterBIDTextField.becomeFirstResponder()
                    })
                    alert.addAction(alertAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else{
                    // BID Exists
                    let bracelet = objects![0] as PFObject
                    // BID Claimed
                    if (bracelet["claimed"] as! Bool){
                        // Bracelet is not orphaned, display message
                        let alert = UIAlertController(title: "Bracelet Already Registered", message: "This Bracelet belongs to another user. If you forgot your login info, get in touch.", preferredStyle: UIAlertControllerStyle.Alert)
                        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: {(alertAction:UIAlertAction) -> Void in
                            self.enterBIDTextField.becomeFirstResponder()
                        })
                        alert.addAction(alertAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    // BID Unclaimed
                    else{
                        // Register current user as owner of BID
                        self.bracelet = bracelet
                        PFUser.currentUser()!["bracelet"] = bracelet
                        PFUser.currentUser()!.saveEventually({(success, error) -> Void in
                        if (success){
                            self.bracelet["claimed"] = true
                            print(bracelet)
                            self.bracelet.saveEventually({(success, error) -> Void in
                                if (!success){
                                    print(error)
                                    self.braceletSerialNumber = BID
                                }
                                else{
                                    print("BID claimed on Parse")
                                }
                                
                            })
                            let alert = UIAlertController(title: "Bracelet Registered", message: "You are now the owner of Bracelet(\(BID!))", preferredStyle: UIAlertControllerStyle.Alert)
                            let alertAction = UIAlertAction(title: "Great!", style: UIAlertActionStyle.Cancel, handler: {(alertAction:UIAlertAction) -> Void in
                                self.performSegueWithIdentifier("showPairBracelet", sender: self)
                            })
                            alert.addAction(alertAction)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        else{
                            print(error)
                        }
                        })
                        // Transition to Feed View Controller
                    }
                }
            }
            else{
                print(error)
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPairBracelet"){
            let destinationVC = segue.destinationViewController as! PairBraceletViewController
            destinationVC.braceletSerialNumber = self.bracelet["serialNumber"] as? String
        }
    }

}
