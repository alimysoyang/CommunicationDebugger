//
//  AYHMessageCell.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/26.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

/**
 * 自定义消息Cell组件，包括时间，消息，头像
 */
class AYHMessageCell: UITableViewCell 
{
    // MARK: - properties
    var index:Int?;
    var message:AYHMessage? {
        didSet {
            if let _ = self.message
            {
                if (self.message!.isEdit)
                {
                    self.selectionStyle = UITableViewCellSelectionStyle.Default;
                }
                else
                {
                    self.selectionStyle = UITableViewCellSelectionStyle.None;
                }
                self.messageTimeView?.message = self.message;
                self.messageIconView?.message = self.message;
                self.messageContentView?.message = self.message;
            }
        }
    }
    private var messageTimeView:AYHMessageTimeView?;
    private var messageIconView:AYHMessageIconView?;
    private var messageContentView:AYHMessageContentView?;
    
    // MARK: - life cycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.backgroundColor = UIColor.clearColor();
        self.initViews();
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
	
    deinit
    {
    }

    override func canBecomeFirstResponder() -> Bool {
        return true;
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if (action == Selector("deleteMenuItemClicked") || action == Selector("copyMenuItemClicked"))
        {
            return true;
        }
        
        return false;
    }
    // MARK: - public methods

    // MARK: - event response
    internal func deleteMenuItemClicked()
    {
        AYHDBHelper.sharedInstance.deleteMessage(AYHCMParams.sharedInstance.socketType, msgID: self.message?.msgID, index: self.index);
    }
    
    internal func copyMenuItemClicked()
    {
        let pasteboard:UIPasteboard = UIPasteboard.generalPasteboard();
        pasteboard.string = self.message?.msgContent;
    }
    
    internal func handlerTapPressGestureRecognizer(sender:UITapGestureRecognizer)
    {
        self.becomeFirstResponder();
        let deleteMenuItem:UIMenuItem = UIMenuItem(title: NSLocalizedString("Delete", comment: ""), action: Selector("deleteMenuItemClicked"));
        let copyMenuItem:UIMenuItem = UIMenuItem(title: NSLocalizedString("Copy", comment: ""), action: Selector("copyMenuItemClicked"));
        let menuController:UIMenuController = UIMenuController.sharedMenuController();
        menuController.menuItems = [deleteMenuItem, copyMenuItem];
        menuController.setTargetRect(self.messageContentView!.frame, inView: self);
        menuController.setMenuVisible(true, animated: true);
    }
    
    // MARK: - delegate

    // MARK: - private methods
    private func initViews()
    {
        self.messageTimeView = AYHMessageTimeView(frame: CGRectZero);
        self.messageIconView = AYHMessageIconView(frame: CGRectZero);
        self.messageContentView = AYHMessageContentView(frame: CGRectZero);
        self.addSubview(self.messageTimeView!);
        self.addSubview(self.messageIconView!);
        self.addSubview(self.messageContentView!);
        
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handlerTapPressGestureRecognizer:"));
        self.messageContentView?.addGestureRecognizer(tapGestureRecognizer);
    }
}