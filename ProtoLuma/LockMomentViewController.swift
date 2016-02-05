//
//  LockMomentViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 2/4/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit

class LockMomentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Lock Moment"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonTapped")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "donelButtonTapped")

        self.view.backgroundColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelButtonTapped(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func donelButtonTapped(){
    
    }


}
