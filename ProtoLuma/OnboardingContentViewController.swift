//
//  OnboardingContentViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/30/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class OnboardingContentViewController: UIViewController {

    var pageIndex:Int!
    var titleLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.titleLabel = UILabel(frame: CGRectZero)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.text = "Title"
        self.view.addSubview(self.titleLabel)
        
//        let metricsDictionary = []
//        let viewsDictionary = ["titleLabel":self.titleLabel]
        
        let verticalConstraint = NSLayoutConstraint(item: self.titleLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.view.addConstraint(verticalConstraint)
        
        let horizontalConstraint = NSLayoutConstraint(item: self.titleLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        self.view.addConstraint(horizontalConstraint)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
