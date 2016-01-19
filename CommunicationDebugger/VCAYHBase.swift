//
//  VCAYHBase.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/24.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import UIKit
import Foundation

/**
 * UIViewController Base
 */
class VCAYHBase: UIViewController 
{
    // MARK: - property 属性
    
    // MARK: - life cycle ViewController生命周期
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.view.backgroundColor = AYHelper.defaultBackgroundColor;
        self.edgesForExtendedLayout = UIRectEdge.None;
        
        SSASwiftReachability.sharedManager?.startMonitoring();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reachabilityStatusChanged:"), name: SSAReachabilityDidChangeNotification, object: nil);
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit
    {
        SSASwiftReachability.sharedManager?.stopMonitoring();
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SSAReachabilityDidChangeNotification, object: nil);
    }
    
    // MARK: - event response
    internal func reachabilityStatusChanged(notification:NSNotification)
    {
        if (!SSASwiftReachability.sharedManager!.isReachable())
        {
            self.view.alert(NSLocalizedString("NetworkDisconnected", comment: ""), alertType: UIView.AlertViewType.kAVTFailed);
        }
    }
    
    // MARK: - public methods
    
    // MARK: - private methods
}