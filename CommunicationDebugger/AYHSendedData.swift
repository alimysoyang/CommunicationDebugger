//
//  AYHSendedData.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/23.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

/**
 *  发送的数据对象，用于Delegate返回状态和界面显示
 */
class AYHSendedData: NSObject 
{
    // MARK: - properties
    var sendedMsg:String?;
    var sendedTag:Int?;
    var sendedDataResultType:MessageStatus = .kCMMSuccess;

    // MARK: - life cycle
    override init()
    {
		super.init();
    }
	
    deinit
    {
	
    }
}