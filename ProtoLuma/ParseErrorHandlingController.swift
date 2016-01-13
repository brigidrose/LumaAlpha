//
//  ParseErrorHandlingController.swift
//  ProtoLuma
//
//  Created by Chris on 1/13/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import Foundation
import Parse
import ParseFacebookUtilsV4

class ParseErrorHandlingController: NSObject {
    class func handleParseError(error: NSError?) {
        guard let error = error else { return }
        
        //check that it's actually a parse error, and handle it if not.
        switch(error.domain){
        case NSURLErrorDomain:
            handleNSURLError(error)
            return
        case PFParseErrorDomain:
            break
        default:
            unknownError(error)
            return
        }
        
        //handle the parse error code
        switch (error.code) {
        case PFErrorCode.ErrorInvalidSessionToken.rawValue:
            handleInvalidSessionTokenError()
        case PFErrorCode.ErrorConnectionFailed.rawValue:
            noInternetError()
        default:
            unknownError(error)
        }
    }
    
    private class func handleNSURLError(error: NSError!){
        if(error.code == NSURLErrorNotConnectedToInternet){
            noInternetError()
        }else{
            unknownError(error)
        }
    }
    
    private class func handleInvalidSessionTokenError() {
        print("Invalid Session Token")
         let presentingViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
         let logInViewController = LoginViewController()
         logInViewController.isModal = true
         presentingViewController?.presentViewController(logInViewController, animated: true, completion: nil)
    }
    
    private class func noInternetError(){
        let alert = UIAlertController(title: "Error", message: "You don't appear to be connected to the internet.  You need internet to use this app.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    private class func unknownError(error: NSError!){
        let alert = UIAlertController(title: "Error", message: "An unknown error occured.  Please report this to the app developer.  Error code is \(error.code) and the error itself is  \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
}