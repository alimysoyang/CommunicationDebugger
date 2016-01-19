//
//  AYHMessageTimeView.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/26.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

/**
 * Cell中的时间显示组件
 */
class AYHMessageTimeView: UIView 
{
    // MARK: - properties
    private let space:CGFloat = 10.0;
    var message:AYHMessage? {
        didSet {
            if let lmessage = self.message
            {
                self.frame = CGRectMake(0.0, 0.0, AYHelper.screenWidth, lmessage.msgTimeTextSize.height + self.space);
                self.backgroundView?.frame = CGRectMake((self.frame.size.width - lmessage.msgTimeTextSize.width - self.space) / 2.0, 0.0, lmessage.msgTimeTextSize.width + self.space, lmessage.msgTimeTextSize.height + self.space);
                self.lbText?.frame = CGRectMake(self.backgroundView!.frame.origin.x + self.space / 2.0, self.space / 2.0, lmessage.msgTimeTextSize.width, lmessage.msgTimeTextSize.height);
                
                self.lbText?.attributedText = lmessage.msgNotificationText;
            }
        }
    }
    
    private var backgroundView:UIImageView?;
    private var lbText:UILabel?;

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

    // MARK: - public methods

    // MARK: - event response

    // MARK: - delegate

    // MARK: - private methods
    private func initViews()
    {
        let image:UIImage = UIImage(named: "MessageTimeBkg")!;
        self.backgroundView = UIImageView(frame: CGRectZero);
        self.backgroundView?.image = image.stretchableImageWithLeftCapWidth(5, topCapHeight: 5);
        self.addSubview(self.backgroundView!);
        
        self.lbText = UILabel(frame: CGRectZero);
        self.lbText?.font = AYHelper.p12Font;
        self.lbText?.textColor = UIColor.whiteColor();
        self.lbText?.textAlignment = NSTextAlignment.Center;
        self.lbText?.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        self.lbText?.numberOfLines = Int.max;
        self.addSubview(self.lbText!);
    }
}