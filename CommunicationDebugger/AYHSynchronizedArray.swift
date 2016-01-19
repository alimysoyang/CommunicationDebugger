//
//  AYHSynchronizedArray.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/9/14.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

typealias CompletionClosure = () -> Void;

// MARK: - 线程安全队列
class AYHSynchronizedArray<T>
{
    // MARK: - properties
    private var array:[T] = [];
    private let accessQueue:dispatch_queue_t = dispatch_queue_create("SynchronizedArrayAccess", DISPATCH_QUEUE_SERIAL);
    
    subscript(index:Int)->T {
        set(newValue) {
            dispatch_async(self.accessQueue, {[weak self] () -> Void in
                self?.array[index] = newValue;
                });
        }
        get {
            var element:T!;
            dispatch_sync(self.accessQueue, {[weak self] () -> Void in
                element = self?.array[index];
                });
            return element;
        }
    }
    
    var count:Int {
        get { return self.array.count; }
    }
    
    var last:T? {
        get {
            var element:T?;
            dispatch_sync(self.accessQueue, {[weak self] () -> Void in
                element = self?.array.last;
            });
            return element;
        }
    }
    
    var isEmpty:Bool {
        get { return self.array.isEmpty; }
    }
    
    // MARK: - public methods
    func append(newElement:T, completionClosure:CompletionClosure)
    {
        //这里才用的同步线程，如果要给界面刷新数据时，有可能出现数据未添加完成，数据无法显示到界面上的问题，因此添加一个block确认数据添加成功
        dispatch_async(self.accessQueue, {[weak self] () -> Void in
            self?.array.append(newElement);
            completionClosure();
        });
    }
    
    func insert(newElement:T, atIndex index:Int)
    {
        dispatch_async(self.accessQueue, {[weak self] () -> Void in
            self?.array.insert(newElement, atIndex: index);
            
        });
    }
    
    func insertContentsOf(newElements:[T], atIndex at:Int)
    {
        dispatch_async(self.accessQueue, {[weak self] () -> Void in
            self?.array.insertContentsOf(newElements, at: at);
            });
    }
    
    func removeAtIndex(index:Int)
    {
        dispatch_async(self.accessQueue, {[weak self] () -> Void in
            self?.array.removeAtIndex(index);
        });
    }
    
    func removeAll(completionClosure:CompletionClosure)
    {
        dispatch_async(self.accessQueue, {[weak self] () -> Void in
            self?.array.removeAll();
            completionClosure();
        });
    }
}
