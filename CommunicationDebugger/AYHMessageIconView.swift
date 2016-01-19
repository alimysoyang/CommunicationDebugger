//
//  AYHMessageIconView.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/26.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

/**
 * Cell中显示头像的组件, 发-蓝，收-红
 */
class AYHMessageIconView: UILabel
{
    // MARK: - properties
    var message:AYHMessage? {
        didSet {
            if let lmessage = self.message
            {
                self.hidden = false;
                if (lmessage.msgType == .kCMSMTSend)
                {
                    self.frame = CGRectMake(AYHelper.screenWidth - 49.0, lmessage.msgTimeTextSize.height + 20.0, 44.0, 44.0);
                    self.text = NSLocalizedString("IconSend", comment: "");
                    self.textColor = UIColor.blueColor();
                    self.layer.borderColor = UIColor.blueColor().CGColor;
                }
                else if (lmessage.msgType == .kCMSMTReceived)
                {
                    self.frame = CGRectMake(5.0, lmessage.msgTimeTextSize.height + 20.0, 44.0, 44.0);
                    self.text = NSLocalizedString("IconReceived", comment: "");
                    self.textColor = UIColor.redColor();
                    self.layer.borderColor = UIColor.redColor().CGColor;
                }
                else
                {
                    self.frame = CGRectZero;
                    self.hidden = true;
                }
                self.frame = frame;
                self.layer.cornerRadius = frame.size.width / 2.0;
            }
        }
    }
    // MARK: - life cycle
    override init(frame:CGRect)
    {
        super.init(frame: frame);
        self.layer.borderWidth = AYHelper.singleLine * 2.0;
        self.layer.backgroundColor = UIColor.whiteColor().CGColor;
        self.textAlignment = NSTextAlignment.Center;
        self.font = UIFont.boldSystemFontOfSize(22.0);
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
	
    deinit
    {
	
    }

    // MARK: - public methods

    // MARK: - event response

    // MARK: - delegate

    // MARK: - private methods

}