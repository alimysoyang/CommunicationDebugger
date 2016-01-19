//
//  AYHMessageManage.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/26.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

@objc protocol AYHMessageManageDelegate
{
    func messageManageDidAdded();
    func messageManageDidUpdate();
    func messageManageDidRemoved();
    func messageManageDidRemoveAll();
}

class AYHMessageManage: NSObject 
{
    // MARK: - properties
    weak var delegate:AYHMessageManageDelegate?;
    private var messages:AYHSynchronizedArray<AYHMessage> = AYHSynchronizedArray<AYHMessage>();

    subscript(index:Int)->AYHMessage? {
        get {
            if (index < 0 || index >= self.messages.count)
            {
                return nil;
            }
            
            return self.messages[index];
        }
        set(newValue) {
            if (index < 0 || index >= self.messages.count)
            {
                return;
            }
            self.messages[index] = newValue!;
        }
    }
    
    static let sharedInstance:AYHMessageManage =
    {
        let instance = AYHMessageManage();
        return instance;
    }();
    
//    class var sharedInstance : AYHMessageManage
//    {
//        struct sharedInstance
//        {
//            static var onceToken:dispatch_once_t = 0;
//            static var staticInstance:AYHMessageManage? = nil;
//        }
//        
//        dispatch_once(&sharedInstance.onceToken, { () -> Void in
//            sharedInstance.staticInstance = AYHMessageManage();
//        });
//        
//        return sharedInstance.staticInstance!;
//    }
    
    // MARK: - life cycle
    override init()
    {
		super.init();
    }
	
    deinit
    {
        self.messages.removeAll({ () -> Void in
            
        });
    }

    // MARK: - public methods
    func isEmpty()->Bool
    {
        return self.messages.isEmpty;
    }
    
    func count()->Int
    {
        return self.messages.count;
    }
    
    func append(newMessage:AYHMessage)
    {
        self.messages.append(newMessage, completionClosure:{ () -> Void in
            guard let _ = self.delegate?.messageManageDidAdded() else
            {
                return;
            }
        });
    }
    
    func insertObject(newMessage:AYHMessage, atIndex index:Int)
    {
        if (index < 0 || index >= self.messages.count)
        {
            return;
        }
        self.messages.insert(newMessage, atIndex: index);
        guard let _ = self.delegate?.messageManageDidAdded() else
        {
            return;
        }
    }
    
    func insertArray(messages:[AYHMessage])
    {
        if (messages.count > 0)
        {
            self.messages.insertContentsOf(messages, atIndex: 0);
        }
    }
    
    func removeAtIndex(index:Int)
    {
        if (index < 0 || index >= self.messages.count)
        {
            return;
        }
        
        self.messages.removeAtIndex(index);
        guard let _ = self.delegate?.messageManageDidRemoved() else
        {
            return;
        }
    }
    
    func removeAtID(msgID:Int)
    {
        var index = self.messages.count - 1;
        while (index >= 0)
        {
            let message:AYHMessage = self.messages[index];
            if let lmsgID = message.msgID
            {
                if (lmsgID == msgID)
                {
                    self.messages.removeAtIndex(index);
                    guard let _ = self.delegate?.messageManageDidRemoved() else
                    {
                        return;
                    }
                    break;
                }
            }
            index--;
        }
    }
    
    func removeAll()
    {
        self.messages.removeAll( { () -> Void in
            guard let _ = self.delegate?.messageManageDidRemoveAll() else
            {
                return;
            }
        });
    }
    
    func updateEdit(isEdit:Bool)
    {
        for index in 0..<self.messages.count
        {
            let message = self.messages[index];
            message.isEdit = isEdit;
        }
        guard let _ = self.delegate?.messageManageDidUpdate() else
        {
            return;
        }
    }
}