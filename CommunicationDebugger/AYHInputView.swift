//
//  AYHInputView.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/26.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation
import UIKit

@objc protocol AYHInputViewDelegate
{
    func inputView(inputView:AYHInputView, didSendData data:String?);
    func inputViewDidViewHeightChange(inputView:AYHInputView);
}

class AYHInputView: UIView 
{
    // MARK: - properties
    weak var delegate:AYHInputViewDelegate?;
    
    private let maxTextViewHeight:CGFloat = 130.0;
    private let defaultTextViewHeight:CGFloat = 40.0;
    
    private var oldHeight:CGFloat?;
    private var sourceOldHeight:CGFloat?;
    private var sourceHeight:CGFloat?;
    private var sourceY:CGFloat?;
    private var constraintSize:CGSize?;
    private var tvContentSize:CGSize?;
    
    private var tvInput:UITextView?;
    private var btnSend:UIButton?;
    private var seperatorLayer:CALayer?;
    
    // MARK: - life cycle
    override init(frame:CGRect)
    {
        super.init(frame:frame);
        
        self.initViews();
        
        self.constraintSize = CGSizeMake(self.tvInput!.frame.size.width, CGFloat.max);
        self.tvContentSize = self.tvInput?.sizeThatFits(self.constraintSize!);
        self.oldHeight = self.tvContentSize?.height;
        self.sourceOldHeight = self.oldHeight;
        self.sourceHeight = self.frame.size.height;
        self.sourceY = self.frame.origin.y;
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
	
    deinit
    {
        self.delegate = nil;
    }

    // MARK: - public methods
    func clearText()
    {
        self.tvInput?.text = "";
        self.oldHeight = self.sourceOldHeight;
        self.btnSend?.enabled = false;
        self.textViewDidClearAnimation();
    }
    
    // MARK: - event response
    internal func buttonClicked(sender:UIButton)
    {
        guard let _ = self.delegate?.inputView(self, didSendData: self.tvInput?.text) else
        {
            return;
        }
        
        self.tvInput?.resignFirstResponder();
        self.clearText();
    }

    // MARK: - private methods
    private func initViews()
    {
        self.backgroundColor = UIColor(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0);
        
        self.seperatorLayer = CALayer();
        self.seperatorLayer?.frame = CGRectMake(0.0, 0.0, self.frame.size.width, AYHelper.singleLine);
        self.seperatorLayer?.backgroundColor = UIColor.lightGrayColor().CGColor;
        self.layer.addSublayer(self.seperatorLayer!);
        
        self.tvInput = UITextView(frame: CGRectMake(5.0, 5.0, self.frame.size.width - 65.0, self.defaultTextViewHeight));
        self.tvInput?.backgroundColor = UIColor(red: 253.0 / 255.0, green: 253.0 / 255.0, blue: 254.0 / 255.0, alpha: 1.0);
        self.tvInput?.layer.cornerRadius = 5.0;
        self.tvInput?.layer.borderWidth = AYHelper.singleLine;
        self.tvInput?.layer.borderColor = UIColor(red: 172.0 / 255.0, green: 174.0 / 255.0, blue: 178.0 / 255.0, alpha: 1.0).CGColor;
        self.tvInput?.font = UIFont.systemFontOfSize(18.0);
        self.tvInput?.delegate = self;
        self.addSubview(self.tvInput!);
        
        self.btnSend = UIButton(frame: CGRectMake(self.tvInput!.frame.size.width + 5.0, self.frame.size.height - 45.0, 60.0, self.defaultTextViewHeight));
        self.btnSend?.enabled = false;
        self.btnSend?.titleLabel?.font = UIFont.systemFontOfSize(15.0);
        self.btnSend?.setTitle(NSLocalizedString("Send", comment: ""), forState: UIControlState.Normal);
        self.btnSend?.setTitleColor(UIColor(red: 142.0 / 255.0, green: 142.0 / 255.0, blue: 142.0 / 255.0, alpha: 1.0), forState: UIControlState.Disabled);
        self.btnSend?.setTitleColor(UIColor(red: 0.0, green: 204.0 / 255.0, blue: 71.0 / 255.0, alpha: 1.0), forState: UIControlState.Normal);
        self.btnSend?.setTitleColor(UIColor(red: 206.0 / 255.0, green: 237.0 / 255.0, blue: 203.0 / 255.0, alpha: 1.0   ), forState: UIControlState.Highlighted);
        self.btnSend?.addTarget(self, action: Selector("buttonClicked:"), forControlEvents: UIControlEvents.TouchUpInside);
        self.addSubview(self.btnSend!);
    }
    
    private func textViewDidChangeAnimation()
    {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            var frame:CGRect = self.frame;
            frame.size.height = self.tvContentSize!.height + 10.0;
            self.frame = frame;
            
            frame = self.tvInput!.frame;
            frame.size.height = self.tvContentSize!.height;
            self.tvInput?.frame = frame;
            
            frame = self.btnSend!.frame;
            frame.origin.y = self.frame.size.height - 45.0;
            self.btnSend?.frame = frame;
        });
    }
    
    private func textViewDidClearAnimation()
    {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            var frame:CGRect = self.frame;
            frame.origin.y = self.sourceY!;
            frame.size.height = self.sourceHeight!;
            self.frame = frame;
            
            frame = self.tvInput!.frame;
            frame.size.height = self.defaultTextViewHeight;
            self.tvInput?.frame = frame;
            
            frame = self.btnSend!.frame;
            frame.origin.y = self.frame.size.height - 45.0;
            self.btnSend?.frame = frame;
        });
    }
    
    private func textViewScrollToBottom()
    {
        self.tvInput?.scrollRangeToVisible(NSMakeRange(self.tvInput!.text.characters.count, 0));
        self.tvInput?.scrollEnabled = false;
        self.tvInput?.scrollEnabled = true;
        self.tvInput?.setContentOffset(CGPointMake(0.0, self.tvInput!.contentSize.height), animated: true);
    }
}

extension AYHInputView : UITextViewDelegate
{
    func textViewDidChange(textView: UITextView) {
        self.tvContentSize = textView.sizeThatFits(self.constraintSize!);
        if (self.tvContentSize?.height >= self.maxTextViewHeight)
        {
            self.tvContentSize?.height = self.maxTextViewHeight;
        }
        
        if (self.oldHeight != self.tvContentSize?.height)
        {
            self.textViewDidChangeAnimation();
            if (self.tvContentSize!.height / self.oldHeight! > 3.3)
            {
                self.textViewScrollToBottom();
            }
            guard let _ = self.delegate?.inputViewDidViewHeightChange(self) else
            {
                return;
            }
        }
        
        self.oldHeight = self.tvContentSize?.height;
        if (textView.text.trim().isEmpty)
        {
            self.btnSend?.enabled = false;
        }
        else
        {
            if (self.btnSend?.enabled == false)
            {
                self.btnSend?.enabled = true;
            }
        }
    }
}