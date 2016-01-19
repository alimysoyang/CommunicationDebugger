//
//  AYHMessageContentView.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/26.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

/**
 * Cell中的消息内容显示组件
 */
class AYHMessageContentView: UIView 
{
    // MARK: - properties
    private let space:CGFloat = 20.0;
    var message:AYHMessage? {
        didSet {
            if let lmessage = self.message
            {
                self.hidden = false;
                self.backgroundView?.frame = CGRectMake(0.0, 0.0, lmessage.msgContentTextSize.width + self.space, lmessage.msgContentTextSize.height + self.space);
                self.lbContent?.frame = CGRectMake(self.space / 2.0, self.space / 3.0, lmessage.msgContentTextSize.width, lmessage.msgContentTextSize.height);
                
                self.lbContent?.text = lmessage.msgContent;
                var image:UIImage = UIImage(named: "SendTextBkg")!;
                if (lmessage.msgType == .kCMSMTSend)
                {
                    image = UIImage(named: "SendTextBkg")!;
                    self.frame = CGRectMake(AYHelper.screenWidth - lmessage.msgContentTextSize.width - self.space - 54.0, lmessage.msgTimeTextSize.height + self.space, AYHelper.screenWidth - 74.0, lmessage.msgContentTextSize.height + self.space);
                }
                else if (lmessage.msgType == .kCMSMTReceived)
                {
                    image = UIImage(named: "ReceiveTextBkg")!;
                    self.frame = CGRectMake(54.0, lmessage.msgTimeTextSize.height + self.space, AYHelper.screenWidth - 74.0, lmessage.msgContentTextSize.height + self.space);
                }
                else
                {
                    self.frame = CGRectZero;
                    self.hidden = true;
                }
                //self.backgroundView?.image = image.resizableImageWithCapInsets(UIEdgeInsetsMake(3.0, 3.0, 3.0, 3.0), resizingMode: UIImageResizingMode.Stretch);
                self.backgroundView?.image = image.stretchableImageWithLeftCapWidth(10, topCapHeight: 30);
            }
        }
    }
    
    private var backgroundView:UIImageView?;
    private var lbContent:UILabel?;

    // MARK: - life cycle
    override init(frame:CGRect)
    {
        super.init(frame: frame);
        self.initViews();
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
	
    deinit
    {
	
    }

    // MARK: - private methods
    private func initViews()
    {
        self.backgroundView = UIImageView(frame: CGRectZero);
        //self.backgroundView?.backgroundColor = UIColor.grayColor();
        self.addSubview(self.backgroundView!);
        
        self.lbContent = UILabel(frame: CGRectZero);
        //self.lbContent?.backgroundColor = UIColor.lightGrayColor();
        self.lbContent?.font = AYHelper.p15Font;
        self.lbContent?.textColor = UIColor.blackColor();
        self.lbContent?.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        self.lbContent?.numberOfLines = Int.max;
        self.addSubview(self.lbContent!);
    }
}