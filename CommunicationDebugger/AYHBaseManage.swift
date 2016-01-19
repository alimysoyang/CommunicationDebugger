//
//  AYHBaseManage.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/12/9.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

class AYHBaseManage<T> : NSObject
{
    // MARK: - properties
    private var delegates:[T] = [];

    // MARK: - life cycle
    override init()
    {
		super.init();
    }
	
    deinit
    {
        self.delegates.removeAll();
    }

    // MARK: - public methods
    func append(newElement:T)
    {
        let isExist:Bool = self.delegates.contains({ (element:T) -> Bool in
            if (newElement == element)
            {
                return true;
            }
            else
            {
                return false;
            }
        });
    
        if !self.delegates.contains(newElement)
        {
            self.delegates.append(newElement);
        }
    }
    
    func removeAtIndex(index:Int)
    {
        if (index < 0 || index > self.delegates.count)
        {
            return;
        }
        self.delegates.removeAtIndex(index);
    }
    
    func removeAll()
    {
        self.delegates.removeAll();
    }
    
    // MARK: - event response

    // MARK: - delegate

    // MARK: - private methods

}