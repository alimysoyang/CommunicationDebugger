//
//  AYHAlertViewController.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/24.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation
import UIKit

@objc protocol AYHAlertViewControllerDelegate
{
    func alertController(alertController:AYHAlertViewController, clickedButtonAtIndex buttonIndex:Int);
}

class AYHAlertViewController: NSObject
{
    // MARK: - properties
    weak var delegate:AYHAlertViewControllerDelegate?;
    var tag:Int = 0;
    
    private let kActionIndex:Int = 4000;
    private var title:String?;
    private var message:String?;
    private var buttonTitles:[String]?;
    private weak var controller:UIViewController?;
    
    // MARK: - life cycle
    override init()
    {
		super.init();
    }
	
    init(title:String?, message:String?, delegate:AYHAlertViewControllerDelegate?, parentController:UIViewController?, buttonTitles:String...)
    {
        self.title = title;
        self.message = message;
        self.delegate = delegate;
        self.buttonTitles = buttonTitles;
        self.controller = parentController;
    }
    
    deinit
    {
        self.delegate = nil;
        self.controller = nil;
    }

    // MARK: - public methods
    func showView()
    {
        guard let _ = self.controller else
        {
            return;
        }
        
        if let buttons = self.buttonTitles
        {
            if #available(iOS 8.0, *)
            {
                let alertController:UIAlertController = UIAlertController(title: self.title, message: self.message, preferredStyle: UIAlertControllerStyle.Alert);
                
                for index in 0..<buttons.count
                {
                    var alertActionStyle:UIAlertActionStyle = UIAlertActionStyle.Cancel;
                    if (index == 0)
                    {
                        alertActionStyle = UIAlertActionStyle.Destructive;
                    }
                    let alertAction:UIAlertAction = UIAlertAction(title: buttons[index], style: alertActionStyle, handler: { (action:UIAlertAction) -> Void in
                        defer
                        {
                            alertController.dismissViewControllerAnimated(true, completion: { () -> Void in
                            });
                        }
                        guard let _ = self.delegate?.alertController(self, clickedButtonAtIndex: index) else
                        {
                            return;
                        }
                    });
                    alertController.addAction(alertAction);
                }
                self.controller?.presentViewController(alertController, animated: true, completion: nil);
            }
            else
            {
                let alertActionView:UIAlertView = UIAlertView();
                alertActionView.title = self.title!;
                alertActionView.delegate = self;
                for index in 0..<buttons.count
                {
                    alertActionView.addButtonWithTitle(buttons[index]);
                }
                alertActionView.show();
            }
        }
    }
}

extension AYHAlertViewController : UIAlertViewDelegate
{
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        guard let _ = self.delegate?.alertController(self, clickedButtonAtIndex: buttonIndex) else
        {
            return;
        }
    }
}