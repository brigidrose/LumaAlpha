//
//  LumaTabBarController.swift
//  ProtoLuma
//
//  Created by Chun-Wei Chen on 1/28/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

import UIKit

class LumaTabBarController: CYLTabBarController {

    let Title = ["Collection","Account"]
    //选中时的图片
    let SelectedImage = ["Collection","AccountBarButtonIcon"]
    //未选中时的图片
    let Image = ["Collection","AccountBarButtonIcon"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tabBarItemsAttributes: [AnyObject] = []
        var viewControllers:[AnyObject] = []
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        for i in 0 ... Title.count - 1 {
            let dict: [NSObject : AnyObject] = [
                CYLTabBarItemTitle: Title[i],
                CYLTabBarItemImage: Image[i],
                CYLTabBarItemSelectedImage: SelectedImage[i]
            ]
            var vc:UIViewController!
            switch i{
            case 0:
                vc = mainStoryboard.instantiateViewControllerWithIdentifier("CharmCollectionNavigationController")
            case 1:
                vc = mainStoryboard.instantiateViewControllerWithIdentifier("AccountNavigationController")
            default:
                vc = UIViewController()
            }
            tabBarItemsAttributes.append(dict)
            viewControllers.append(vc!)
        }
        self.tabBarItemsAttributes = tabBarItemsAttributes
        self.viewControllers = viewControllers

    }
    

}



class PlusButtonSubclass : CYLPlusButton, CYLPlusButtonSubclassing{
    
    class func plusButton() -> AnyObject! {
        let button:PlusButtonSubclass =  PlusButtonSubclass()

        button.setImage(UIImage(named: "NewStoryBarButtonIcon"), forState: UIControlState.Normal)
        button.titleLabel!.textAlignment = NSTextAlignment.Center;
        button.adjustsImageWhenHighlighted = false;
//        button.addTarget(button, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
//        button.userInteractionEnabled = true
        button.frame = CGRectMake(0, 0, 49.5, 49.5)
        return  button
    }
    
    //点击事件
    func buttonClicked(sender:CYLPlusButton)
    {
//        print("hello mm")
    }

    static func multiplerInCenterY() -> CGFloat {
        return 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 控件大小,间距大小
        let imageViewEdge   = self.bounds.size.width * 0.6;
        let centerOfView    = self.bounds.size.width * 0.5;
        let labelLineHeight = self.titleLabel!.font.lineHeight;
        //        let verticalMarginT = self.bounds.size.height - labelLineHeight - imageViewEdge;
        //        let verticalMargin  = verticalMarginT / 2;
        
        // imageView 和 titleLabel 中心的 Y 值
        //        _  = verticalMargin + imageViewEdge * 0.5;
        let centerOfTitleLabel = imageViewEdge  + labelLineHeight + 2;
        
        //imageView position 位置
        self.imageView!.bounds = CGRectMake(0, 0, 36, 36);
        self.imageView!.center = CGPointMake(centerOfView, 0)//centerOfImageView * 2 );
        
        //title position 位置
        self.titleLabel!.bounds = CGRectMake(0, 0, self.bounds.size.width, labelLineHeight);
        self.titleLabel!.center = CGPointMake(centerOfView, centerOfTitleLabel);
    }
}
