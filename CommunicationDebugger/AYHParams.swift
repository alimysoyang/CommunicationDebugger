//
//  AYHParams.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/12/7.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

/**
 *  系统参数
 */
class AYHParams: NSObject, NSCoding
{
    // MARK: - properties
    var isSaveLogs = false;
    
    static let sharedInstance:AYHParams =
    {
        let instance = AYHParams();
        return instance;
    }();
    
//    class var sharedInstance : AYHParams
//    {
//        struct sharedInstance
//        {
//            static var onceToken:dispatch_once_t = 0;
//            static var staticInstance:AYHParams?;
//        }
//        
//        dispatch_once(&sharedInstance.onceToken, { () -> Void in
//            sharedInstance.staticInstance = AYHParams();
//        });
//        
//        return sharedInstance.staticInstance!;
//    }
    
    // MARK: - life cycle
    override init()
    {
		super.init();
        let configFilePath:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0].stringByAppendingString(AYHelper.sconfigFileName);
        var fm:NSFileManager? = NSFileManager();
        defer
        {
            fm = nil;
        }
        if (fm!.fileExistsAtPath(configFilePath))
        {
            let tmp:AYHParams = NSKeyedUnarchiver.unarchiveObjectWithFile(configFilePath) as! AYHParams;
            self.isSaveLogs = tmp.isSaveLogs;
        }
    }
	
    deinit
    {
	
    }

    required init(coder aDecoder: NSCoder)
    {
        super.init();
        
        self.isSaveLogs = aDecoder.decodeBoolForKey("isSaveLogs");
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeBool(self.isSaveLogs, forKey: "isSaveLogs");
    }
    
    func toSave()
    {
        let configFilePath:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0].stringByAppendingString(AYHelper.sconfigFileName);
        let configData:NSData = NSKeyedArchiver.archivedDataWithRootObject(self);
        configData.writeToFile(configFilePath, atomically: true);
    }
    
    // MARK: - public methods

    // MARK: - event response

    // MARK: - delegate

    // MARK: - private methods

}