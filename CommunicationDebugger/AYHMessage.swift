//
//  AYHMessage.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/23.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation
import UIKit

class AYHMessage: NSObject 
{
    // MARK: - properties
    private let defaultWidth = AYHelper.screenWidth - 94.0;
    private let defaultTimeWidth = AYHelper.screenWidth - 18.0;
    private(set) var msgStrTime:String?;
    private(set) var msgTimeTextSize:CGSize = CGSizeZero;
    private(set) var msgContentTextSize:CGSize = CGSizeMake(0.0, 54.0);
    private(set) var msgNotificationText:NSAttributedString?;
    
    var msgID:Int?;
    var serviceType:ServiceType?;
    var msgType:SocketMessageType?;
    var msgStatus:MessageStatus?;
    var msgAddress:String?;
    var msgCellHeight:CGFloat = 115.0;
    var isEdit:Bool = false;
    
    var msgTime:NSDate? {
        didSet {
            guard let newMsgTime = self.msgTime else
            {
                self.msgStrTime = "";
                self.msgTimeTextSize = CGSizeZero;
                return;
            }
            
            self.msgStrTime = AYHelper.dateformatter.stringFromDate(newMsgTime);
            if let lmsgStrTime = self.msgStrTime
            {
                if (!lmsgStrTime.trim().isEmpty)
                {
                    self.msgTimeTextSize = self.timeTextframeSize(lmsgStrTime, textFont: AYHelper.p12Font);
                }
            }
        }
    }
    
    var msgContent:String? {
        didSet {
            guard let newMsgContent = self.msgContent else
            {
                self.msgContentTextSize = CGSizeMake(0.0, 54.0);
                return;
            }
            
            if (newMsgContent.isEmpty)
            {
                self.msgContentTextSize = CGSizeMake(0.0, 54.0);
            }
            else
            {
                let tmpSize:CGSize = self.contentTextframeSize(newMsgContent, textFont: AYHelper.p15Font);
                if (tmpSize.height < self.msgContentTextSize.height)
                {
                    self.msgContentTextSize = CGSizeMake(tmpSize.width, 54.0);
                }
                else
                {
                    self.msgContentTextSize = tmpSize;
                }
            }
        }
    }

    // MARK: - life cycle
    override init()
    {
		super.init();
    }
	
    deinit
    {
	
    }

    // MARK: - private methods
    private func contentTextframeSize(text:String, textFont:UIFont) -> CGSize
    {
        var tmpLabel:UILabel? = UILabel(frame: CGRectMake(0.0, 0.0, self.defaultWidth, CGFloat.max));
        tmpLabel?.font = textFont;
        tmpLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        tmpLabel?.numberOfLines = Int.max;
        tmpLabel?.text = text;
        tmpLabel!.sizeToFit();
        let retVal:CGSize = tmpLabel!.frame.size;
        tmpLabel = nil;
        return retVal;
    }
    
    private func timeTextframeSize(text:String, textFont:UIFont) -> CGSize
    {
        var tmpLabel:UILabel? = UILabel(frame: CGRectMake(0.0, 0.0, self.defaultTimeWidth, CGFloat.max));
        tmpLabel?.font = textFont;
        tmpLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        tmpLabel?.numberOfLines = Int.max;
        tmpLabel?.text = text;
        tmpLabel?.sizeToFit();
        let retVal:CGSize = tmpLabel!.frame.size;
        tmpLabel = nil;
        return retVal;
    }
    
    private func toAttributedString()->NSAttributedString
    {
        let retVal:NSMutableAttributedString = NSMutableAttributedString(string: self.msgStrTime!, attributes: [NSFontAttributeName:AYHelper.p12Font, NSForegroundColorAttributeName:UIColor.whiteColor()]);
        if (self.msgType == .kCMSMTNotification)
        {
            if let _ = self.msgContent
            {
                retVal.appendAttributedString(NSAttributedString(string: "\n\(self.msgContent!)", attributes: [NSFontAttributeName:AYHelper.p12Font, NSForegroundColorAttributeName:UIColor.blackColor()]))
            }
        }
        else if (self.msgType == .kCMSMTErrorNotification)
        {
            if let _ = self.msgContent
            {
                retVal.appendAttributedString(NSAttributedString(string: "\n\(self.msgContent!)", attributes: [NSFontAttributeName:AYHelper.p12Font, NSForegroundColorAttributeName:UIColor.redColor()]));
            }
        }
        return retVal;
    }
    
    private func messageCellHeight()->CGFloat
    {
        self.msgNotificationText = self.toAttributedString();
        guard let _ = self.msgContent else
        {
            return 115.0;
        }
        
        return 45.0 + self.msgTimeTextSize.height + self.msgContentTextSize.height;
    }
    
    private func notificationCellHeight()->CGFloat
    {
        if let _ = self.msgContent
        {
            self.msgTimeTextSize = self.timeTextframeSize("\(self.msgStrTime!)\n\(self.msgContent!)", textFont: AYHelper.p12Font);
        }
        self.msgNotificationText = self.toAttributedString();
        return 35.0 + self.msgTimeTextSize.height;
    }
    
    func calculateCellHeight()
    {
        if (self.msgType == .kCMSMTNotification || self.msgType == .kCMSMTErrorNotification)
        {
            self.msgCellHeight = self.notificationCellHeight();
        }
        else
        {
            self.msgCellHeight = self.messageCellHeight();
        }
    }
}