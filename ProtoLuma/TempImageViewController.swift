//
//  TempImageViewController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/21/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class TempImageViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var url:NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Plain, target: self, action: "closeButtonTapped:")
        self.navigationItem.leftBarButtonItem = closeButton
        print(url)
        self.webView.loadRequest(NSURLRequest(URL: url))
        self.navigationItem.title = "Moment"
        // Do any additional setup after loading the view.
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

    func closeButtonTapped(sender:UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
}
