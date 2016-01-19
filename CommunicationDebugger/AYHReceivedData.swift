//
//  AYHReceivedData.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/23.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

/**
 *  接收的数据对象，用于Delegate返回状态和界面显示
 */
class AYHReceivedData: NSObject 
{
    // MARK: - properties
    var receivedMsg:String?;
    var receivedAddress:String?;
    var receivedDataResultType:MessageStatus = .kCMMSuccess;

    // MARK: - life cycle
    override init()
    {
		super.init();
    }
	
    deinit
    {
	
    }
}