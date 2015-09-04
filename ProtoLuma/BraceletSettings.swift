//
//  BraceletSettings.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 9/3/15.
//  Copyright © 2015 Chun-Wei Chen. All rights reserved.
//

import UIKit

class BraceletSettings: NSObject, MBLRestorable {

    var notifications:NSMutableArray!
    
    override init() {
        super.init()
        self.notifications = NSMutableArray()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.notifications = aDecoder.decodeObjectForKey("notifications") as! NSMutableArray
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.notifications, forKey: "notifications")
    }
    
    func runOnDeviceBoot(device: MBLMetaWear!) {

        let event:MBLEvent = device.ancs.eventWithCategoryIds(MBLANCSCategoryID.Any)
        print(device.ancs)
        event.programCommandsToRunOnEvent({
            device.led.flashLEDColor(UIColor.greenColor(), withIntensity: 1.0, numberOfFlashes: 10)
        })
        
        let event2:MBLEvent = device.mechanicalSwitch.switchUpdateEvent
        event2.programCommandsToRunOnEvent({
            device.led.flashLEDColor(UIColor.redColor(), withIntensity: 1.0, numberOfFlashes: 3)
        })
    }
    
}
