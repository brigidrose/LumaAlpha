//
//  AppDelegate.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 8/14/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import ParseFacebookUtilsV4

func sync(lock: AnyObject, closure: () -> Void) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

//borrowed from here: https://gist.github.com/licvido/55d12a8eb76a8103c753
func RBSquareImage(image: UIImage) -> UIImage {
    let originalWidth  = image.size.width
    let originalHeight = image.size.height
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var edge: CGFloat = 0.0
    
    if (originalWidth > originalHeight) {
        // landscape
        edge = originalHeight
        x = (originalWidth - edge) / 2.0
        y = 0.0
        
    } else if (originalHeight > originalWidth) {
        // portrait
        edge = originalWidth
        x = 0.0
        y = (originalHeight - originalWidth) / 2.0
    } else {
        // square
        edge = originalWidth
    }
    
    let cropSquare = CGRectMake(x, y, edge, edge)
    let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
    
    return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
}




extension UIImage {
    var rounded: UIImage {
        let imageView = UIImageView(image: self)
        imageView.layer.cornerRadius = size.height < size.width ? size.height/2 : size.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    var circle: UIImage {
        let square = CGSize(width: 100, height: 100)//size.width < size.height ? CGSize(width: size.width, height: size.width) : CGSize(width: size.height, height: size.height)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var beans:NSMutableDictionary!
    var metawearManager:MBLMetaWearManager!
    var locationManager:CLLocationManager!
    var deviceId:String!
    var latestBatteryLife:Int?
    var collectionController:CharmCollectionTableViewController!
    var tabBarController:UITabBarController!
    
    //degrees only go from -180 to 180 so set to 500 which means No Location Yet
    var latestLocation:[Double] = [500, 500]

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        
        
        Charm.registerSubclass()
        Charm_Group.registerSubclass()
        User.registerSubclass()
        User_Charm_Group.registerSubclass()
        Story.registerSubclass()
        Story_Unit.registerSubclass()

        // Initialize Parse.
        Parse.setApplicationId("xAFjlwpW52pygLuQXOCMuDH5TtqVRttGNQH3Kj4d",
            clientKey: "VPxuBA4ASQBaPpusXfocIPKAKNrtJALBYd6LKlSx")
        
        checkForUnlockedItems()
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
//        PFTwitterUtils.initializeWithConsumerKey("lHc76e87Hs94HCNkw3NPV0lwW",  consumerSecret:"aRGu4WrbVfezsca8gpBQ1z24yPF2KvkcZRndDGBHND3BWbpNoy")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier("61a46dddbdd74ab28c333a61976dc4d2")
        // Do some additional configuration if needed here
        BITHockeyManager.sharedHockeyManager().startManager()
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
        
        Instabug.startWithToken("fe9bd4920cf21acf47c498d683dbc416", captureSource: IBGCaptureSourceUIKit, invocationEvent: IBGInvocationEventShake)

        
        let userNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
//        UIApplication.sharedApplication().registerUserNotificationSettings(userNotificationSettings)
        application.registerUserNotificationSettings(userNotificationSettings)
        application.registerForRemoteNotifications()
        
        UIStyleController.applyStyle()
        self.metawearManager = MBLMetaWearManager.sharedManager()

        self.window?.tintColor = UIColor(red:0.95, green:0.09, blue:0.25, alpha:1)
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startMonitoringSignificantLocationChanges()
        
//        let delay = 10000.0;
//        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay));
//        dispatch_after(time, dispatch_get_main_queue(), {
//            NSThread.detachNewThreadSelector(Selector("pushReceived"), toTarget:self, withObject: nil);
//        })

        return true
    }

    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }

    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        print("application did enter background")

    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        print("application will enter foreground")
        checkForUnlockedItems()
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("application did become active")
        if (PFInstallation.currentInstallation().badge != 0) {
            PFInstallation.currentInstallation().badge = 0
            PFInstallation.currentInstallation().saveEventually(nil)
        }
        FBSDKAppEvents.activateApp()
        
        self.metawearManager.retrieveSavedMetaWearsWithHandler({(devices:[AnyObject]!) -> Void in
            if (devices.count > 0){
                let bracelet = devices[0] as! MBLMetaWear
                if (bracelet.state != MBLConnectionState.Connected){
                    bracelet.connectWithHandler({(error) -> Void in
                        if error == nil{
                            print("reconnected with \(bracelet.deviceInfo.serialNumber)")
                            //get battery life and upload
                            self.setBatteryLife(bracelet)
                        }else{
                            print(error)
                            ParseErrorHandlingController.handleParseError(error)
                        }
                    })
                }
                else{
                    print("\(bracelet) already connected")
                    self.setBatteryLife(bracelet)
                }
            }
            else{
                print("no saved bracelet found in appdelegate")
            }
        })
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        latestLocation[0] = userLocation.coordinate.latitude
        latestLocation[1] = userLocation.coordinate.longitude
        checkForUnlockedItems()
    }
    
    func checkForUnlockedItems(){
        let date = NSDate()
        //fix this so that we are sending UTC time instead of local time to the server.
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute, .Month, .Year, .Day], fromDate: date)
        let params:[String:NSObject] = [
            "hour": components.hour,
            "minutes": components.minute,
            "month": components.month,
            "year": components.year,
            "day": components.day,
            "locationX": latestLocation[0],
            "locationY": latestLocation[1],
            "timezoneOffset": NSTimeZone.localTimeZone().secondsFromGMT / 60 / 60 // divide by 60 twice to get hours from seconds.
        ]
        PFCloud.callFunctionInBackground("unlockMoments", withParameters: params) { (response, error) -> Void in
            if error == nil{
                print("Unlocked moments response: \(response)")
                if response!["unlockedMoments"] as! Int == 1{
                    //refresh the charms because one is unlocked!
                    self.collectionController.loadCharms()
                }
            }else{
                print(error)
                ParseErrorHandlingController.handleParseError(error)
            }
            
        }
    }
    
    func setBatteryLife(device: MBLMetaWear){
        device.readBatteryLifeWithHandler({ (num, err) -> Void in
            self.latestBatteryLife = Int(num)
        } as MBLNumberHandler)
    }
    

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current Installation and save it to Parse
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
//        print("Device token: ")
//        print(installation.deviceToken)
        installation.saveInBackgroundWithBlock(nil)
    }
    

    
    
    func notifyBracelet(device: MBLMetaWear, charmSlot: UInt8){
        device.hapticBuzzer.startHapticWithDutyCycle(255, pulseWidth: 500, completion: nil)
        device.led.flashLEDColor(UIColor.greenColor(), withIntensity: 1.0, numberOfFlashes: 3)
        let length:UInt8 = 7; // Specific to your NeoPixel stand
        let color:MBLColorOrdering = MBLColorOrdering.GRB; // Specific to your NeoPixel stand
        let speed:MBLStrandSpeed = MBLStrandSpeed.Slow; // Specific to your NeoPixel stand
        
        let strand:MBLNeopixelStrand = device.neopixel.strandWithColor(color, speed: speed, pin: 0, length: length);
        
        strand.setPixel(charmSlot, color: UIColor.redColor())
        
        let timeBetweenFlashes = 800 * NSEC_PER_MSEC
        
        var delay = timeBetweenFlashes
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            strand.setPixel(charmSlot, color: UIColor.greenColor())
        })
        
        delay += timeBetweenFlashes
        time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            strand.setPixel(charmSlot, color: UIColor.blueColor())
            
        })
        
        delay += timeBetweenFlashes
        time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            strand.turnStrandOff()
            self.setBatteryLife(device)
        })
    }
    
    func pushReceivedWithCharmSlot(charmSlot: UInt8){
//        self.metawearManager.startScanForMetaWearsAllowDuplicates(false, handler: {(devices:[AnyObject]!) -> Void in
//            print("scanned for metawear")
//            for device in devices as! [MBLMetaWear]{
//                // Loop connect to all devices and drop connection until matches bracelet on file, needs solution where ble advertises serialNumber
//                if (device.state == MBLConnectionState.Connected){
//                    print("already connected to bracelet")
//                    self.notifyBracelet(device, charmSlot: charmSlot)
//                }
//                else{
//                    device.connectWithHandler({(error) -> Void in
//                        print("Connected")
//                        if (error == nil){
//                            print("connected to \(device.deviceInfo.serialNumber)")
//                            if (device.deviceInfo.serialNumber == currentuser.bracelet.serialNumber){
//                                self.notifyBracelet(device, charmSlot: charmSlot)
//                            }
//                        }
//                        else{
//                            print(error)
//                        }
//                    })
//                }
//            }
//        })
//        
//        
        self.metawearManager.retrieveSavedMetaWearsWithHandler({(devices:[AnyObject]!) -> Void in
            if (devices.count > 0){
                
                let device = devices[0] as! MBLMetaWear
                if (device.state == MBLConnectionState.Connected){
                    print("already connected to bracelet")
                    self.notifyBracelet(device, charmSlot: charmSlot)
                }else{
                    print("not connected to bracelet.  connecting.")
                    device.connectWithHandler({(error) -> Void in
                        print("connected")
                        if (error == nil){
                            print("error is nil")
                            self.notifyBracelet(device, charmSlot: charmSlot)
                        }else{
                            print(error)
                            ParseErrorHandlingController.handleParseError(error)
                        }
                    })
                }
            }else{
                print("no saved metawears found in push notification handler.  fuck.")
            }
        })

    }
    
    // MARK: Handle notifications
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        let message = String(userInfo["aps"]!["alert"])
        print("Push notification message is: "+message)
        var charmSlot = UInt8(0)
        if (userInfo["charmSlot"] != nil){
            charmSlot = UInt8(userInfo["charmSlot"] as! Int)
        }
        print("CharmSlot: \(charmSlot)")
        
        
        pushReceivedWithCharmSlot(charmSlot)
        
        completionHandler(UIBackgroundFetchResult.NewData)
        
    }
    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.chunweichen.ProtoLuma" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("ProtoLuma", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as? NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func imageWithColor(color:UIColor) -> UIImage{
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    

    

}

