//
//  CharmSettingsButtonCell.swift
//  ProtoLuma
//
//  Created by Chris on 1/9/16.
//  Copyright © 2016 Chun-Wei Chen. All rights reserved.
//

class CharmSettingsButtonCell: UITableViewCell {

    @IBOutlet var button: UIButton!
    var buttonAction:(() -> Void)!
    
    @IBAction func buttonPressed(sender: AnyObject) {
        buttonAction()
    }
    
    func setup(buttonTitle:String, buttonAction: () -> Void){
        button.setTitle(buttonTitle, forState: .Normal)
        self.buttonAction = buttonAction
    }
}
