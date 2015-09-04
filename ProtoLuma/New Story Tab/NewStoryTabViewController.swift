//
//  NewStoryTabViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/21/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class NewStoryTabViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonTapped:")
        self.navigationItem.leftBarButtonItem = cancelButton
        
        let sendButton = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Done, target: self, action: "sendButtonTapped:")
        self.navigationItem.rightBarButtonItem = sendButton
        
        self.navigationItem.title = "Moment"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    func cancelButtonTapped(sender:UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendButtonTapped(sender:UIBarButtonItem){
        print("Send button tapped")
    }

    
}
