//
//  AddCharmViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/4/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

class AddCharmViewController: UIViewController, UITextFieldDelegate {

    var instructionLabel:UILabel!
    var enterCIDTextField:UITextField!
    var numCharms:Int!
    var charm:PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Add Charm"
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonTapped:")
        self.navigationItem.leftBarButtonItem = cancelButton
        
        let addButton = UIBarButtonItem(title: "Confirm", style: UIBarButtonItemStyle.Done, target: self, action: "confirmButtonTapped")
        self.navigationItem.rightBarButtonItem = addButton

        self.view = TPKeyboardAvoidingScrollView(frame: self.view.frame)
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.instructionLabel = UILabel(frame: CGRectZero)
        self.instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.instructionLabel.text = "Enter Charm ID"
        self.instructionLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(self.instructionLabel)
        
        self.enterCIDTextField = UITextField(frame: CGRectZero)
        self.enterCIDTextField.translatesAutoresizingMaskIntoConstraints = false
        self.enterCIDTextField.borderStyle = UITextBorderStyle.RoundedRect
        self.enterCIDTextField.keyboardType = UIKeyboardType.NumberPad
        self.enterCIDTextField.delegate = self
        self.view.addSubview(self.enterCIDTextField)
        
        let centerXConstraint = NSLayoutConstraint(item: self.instructionLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.view.addConstraint(centerXConstraint)
        
        let viewsDictionary = ["instructionLabel":self.instructionLabel, "enterCIDTextField":self.enterCIDTextField]
        
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|->=120-[instructionLabel]-12-[enterCIDTextField(44)]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: viewsDictionary)
        self.view.addConstraints(verticalConstraints)
        
        let textFieldHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|->=20-[enterCIDTextField(>=280)]->=20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.view.addConstraints(textFieldHConstraints)
        
        self.enterCIDTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.enterCIDTextField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelButtonTapped(sender:UIBarButtonItem){
        print("cancel button tapped")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func confirmButtonTapped(){
        print("confirm button tapped")

        // Get CID from user input
        let CID = self.enterCIDTextField.text!
        print(CID)
        // Check if BID submitted is found in purchased inventory
        let queryCheckCIDExistsAndOrphaned = PFQuery(className: "Charm")
        queryCheckCIDExistsAndOrphaned.whereKey("serialNumber", equalTo: CID)
        queryCheckCIDExistsAndOrphaned.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            if error == nil {
                if objects?.count != 0 {
                    // CID exists
                    self.charm = objects![0]
//                    if (charm["claimed"] as? Bool == true){
//                        // CID already claimed
//                        print("CID already claimed")
//                    }
//                    else{
                        print("CID available")
//                         CID available, proceed to add user as owner of charm
                        self.charm["owner"] = PFUser.currentUser()!
                        self.charm["claimed"] = true
                    
                        self.charm.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if error == nil {
                                print("charm registered on Parse")
                                self.performSegueWithIdentifier("showSetCharmGroup", sender: self)
                            }else{
                                print(error)
                            }
                        })
//                    }
                }
                else{
                    // CID doesn't exist
                    print("CID doesn't exist!");
                }
            }
            else{
                print(error)
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("return button tapped")
        self.confirmButtonTapped()
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSetCharmGroup" {
            let dvc = segue.destinationViewController as! SetCharmGroupViewController
            dvc.charm = self.charm
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
