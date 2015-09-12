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

//        let event:MBLEvent = device.ancs.eventWithCategoryIds(MBLANCSCategoryID.Any)
//        print(device.ancs)
//        event.programCommandsToRunOnEvent({
//            device.led.flashLEDColor(UIColor.redColor(), withIntensity: 1.0, numberOfFlashes: 5)

//            let length = 3 // Specific to your NeoPixel stand
//            let color:MBLColorOrdering = MBLColorOrdering.RGB; // Specific to your NeoPixel stand
//            let speed:MBLStrandSpeed = MBLStrandSpeed.Slow; // Specific to your NeoPixel stand
//            
//            let strand:MBLNeopixelStrand = device.neopixel.strandWithColor(color, speed: speed, pin: 0, length: UInt8(length))
//            for (var i = 0; i < length; i++){
//                strand.setPixel(UInt8(i), color: UIColor.greenColor())
//            }
//            print("neopixelset")
//            strand.turnStrandOff()

//        })
        
//        let event3:MBLEvent = device.ancs.eventWithCategoryIds(MBLANCSCategoryID.Any, eventIds: MBLANCSEventID.NotificationAdded, eventFlags: MBLANCSEventFlag.Any, attributeId: MBLANCSNotificationAttributeID.AppIdentifier, attributeData: "com.chunweichen.ProtoLuma")
//        event3.programCommandsToRunOnEvent({
//            device.led.flashLEDColor(UIColor.greenColor(), withIntensity: 1.0, numberOfFlashes: 20)
//
//        })
        
        let event5:MBLEvent = device.ancs.eventWithCategoryIds(MBLANCSCategoryID.Any, eventIds: MBLANCSEventID.NotificationAdded, eventFlags: MBLANCSEventFlag.Any, attributeId: MBLANCSNotificationAttributeID.AppIdentifier, attributeData: "com.chunweichen.ProtoLuma")
        event5.programCommandsToRunOnEvent({
            device.led.flashLEDColor(UIColor.blueColor(), withIntensity: 1.0, numberOfFlashes: 20)
        })

        
//        let event4:MBLEvent = device.ancs.eventWithCategoryIds(MBLANCSCategoryID.Any, eventIds: MBLANCSEventID.NotificationAdded, eventFlags: MBLANCSEventFlag.Any, attributeId: MBLANCSNotificationAttributeID.Subtitle, attributeData: "subtitle")
//        event4.programCommandsToRunOnEvent({
//            device.led.flashLEDColor(UIColor.greenColor(), withIntensity: 1.0, numberOfFlashes: 20)
//        })

        
        let event2:MBLEvent = device.mechanicalSwitch.switchUpdateEvent
        event2.programCommandsToRunOnEvent({
            device.led.flashLEDColor(UIColor.redColor(), withIntensity: 1.0, numberOfFlashes: 3)
        })
    }
    
}
