//
//  AYHCMParams.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/9/10.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

/**
 通讯参数设置、读取单元类
 */
class AYHCMParams: NSObject, NSCoding
{
    // MARK: - property属性
    var serviceType: ServiceType = .kCMSTClient;
    var noConfigFile:Bool = true;
    var socketType: SocketType = .kCMSTUDP;
    var remoteIP: String = "";
    var remotePort: UInt = 0;
    var localIP: String = "";
    var localPort: UInt = 0;
    var sHexData: Bool = false;
    var rHexData: Bool = false;
    var sCharacterSet: SocketCharacetSet = .kCMSCSUTF8;
    var rCharacterSet: SocketCharacetSet = .kCMSCSUTF8;
    
    // MARK: - life cycle 生命周期
    static let sharedInstance:AYHCMParams =
    {
        let instance = AYHCMParams();
        return instance;
    }();
    
//    class var sharedInstance:AYHCMParams
//    {
//        struct ssharedInstance
//        {
//            static var onceToken:dispatch_once_t = 0;
//            static var staticInstance:AYHCMParams?;
//        }
//        
//        dispatch_once(&ssharedInstance.onceToken, { () -> Void in
//            ssharedInstance.staticInstance = AYHCMParams();
//        });
//        
//        return ssharedInstance.staticInstance!;
//    }
    
    override init()
    {
        super.init();
        
        let configFilePath:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0].stringByAppendingString(AYHelper.configFileName);
        var fm:NSFileManager? = NSFileManager();
        defer
        {
            fm = nil;
        }
        if (fm!.fileExistsAtPath(configFilePath))
        {
            self.noConfigFile = false;
            let tmp:AYHCMParams = NSKeyedUnarchiver.unarchiveObjectWithFile(configFilePath) as! AYHCMParams;
            self.serviceType = tmp.serviceType;
            self.socketType = tmp.socketType;
            self.remoteIP = tmp.remoteIP;
            self.remotePort = tmp.remotePort;
            self.localIP = tmp.localIP;
            self.localPort = tmp.localPort;
            self.sHexData = tmp.sHexData;
            self.rHexData = tmp.rHexData;
            self.sCharacterSet = tmp.sCharacterSet;
            self.rCharacterSet = tmp.rCharacterSet;
        }
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init();
        
        self.serviceType = ServiceType(rawValue: aDecoder.decodeIntegerForKey("serviceType"))!;
        self.socketType = SocketType(rawValue: aDecoder.decodeIntegerForKey("socketType"))!;
        self.remoteIP = aDecoder.decodeObjectForKey("remoteIP") as! String;
        self.remotePort = UInt(aDecoder.decodeIntegerForKey("remotePort"));
        self.localIP = aDecoder.decodeObjectForKey("localIP") as! String;
        self.localPort = UInt(aDecoder.decodeIntegerForKey("localPort"));
        self.sHexData = aDecoder.decodeBoolForKey("sHexData");
        self.rHexData = aDecoder.decodeBoolForKey("rHexData");
        self.sCharacterSet = SocketCharacetSet(rawValue: aDecoder.decodeIntegerForKey("sCharacterSet"))!;
        self.rCharacterSet = SocketCharacetSet(rawValue: aDecoder.decodeIntegerForKey("rCharacterSet"))!;
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeInteger(self.serviceType.rawValue, forKey: "serviceType");
        aCoder.encodeInteger(self.socketType.rawValue, forKey: "socketType");
        aCoder.encodeObject(self.remoteIP, forKey: "remoteIP");
        aCoder.encodeInteger(Int(self.remotePort), forKey: "remotePort");
        aCoder.encodeObject(self.localIP, forKey: "localIP");
        aCoder.encodeInteger(Int(self.localPort), forKey: "localPort");
        aCoder.encodeBool(self.sHexData, forKey: "sHexData");
        aCoder.encodeBool(self.rHexData, forKey: "rHexData");
        aCoder.encodeInteger(self.sCharacterSet.rawValue, forKey: "sCharacterSet");
        aCoder.encodeInteger(self.rCharacterSet.rawValue, forKey: "rCharacterSet");
    }
    
    // MARK: - public methods
    func toSave()
    {
        let configFilePath:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0].stringByAppendingString(AYHelper.configFileName);
        let configData:NSData = NSKeyedArchiver.archivedDataWithRootObject(self);
        configData.writeToFile(configFilePath, atomically: true);
    }
    
    func remoteAddress()->String
    {
        return "\(self.remoteIP):\(self.remotePort)";
    }
    
    func decription()->String
    {
        var retVal:String = "";
        if (self.serviceType == .kCMSTServer)
        {
            retVal += String(format: " %@\n", NSLocalizedString("Server", comment: ""));
        }
        else
        {
            retVal += String(format: " %@\n", NSLocalizedString("Client", comment: ""));
        }
        if (self.socketType == .kCMSTUDP)
        {
            retVal += " UDP\n ";
        }
        else
        {
            retVal += " TCP\n ";
        }
        if (self.serviceType == .kCMSTServer)
        {
            retVal += String(format: NSLocalizedString("ListenerPort", comment: ""), self.localPort);
        }
        else
        {
            retVal += String(format: NSLocalizedString("RemoteIPAndPort", comment: ""), self.remoteAddress());
        }
        retVal += "\n";
        if (self.sHexData)
        {
            retVal += String(format: " %@\n", NSLocalizedString("SendedDataType", comment: ""));
        }
        else
        {
            if (self.sCharacterSet == .kCMSCSUTF8)
            {
                retVal += String(format: " %@:%@\n", NSLocalizedString("SendedCharacetSet", comment: ""), "UTF-8");
            }
            else
            {
                retVal += String(format: " %@:%@\n", NSLocalizedString("SendedCharacetSet", comment: ""), "GBK");
            }
        }
        if (self.rHexData)
        {
            retVal += String(format: " %@", NSLocalizedString("ReceivedDataType", comment: ""));
        }
        else
        {
            if (self.rCharacterSet == .kCMSCSUTF8)
            {
                retVal += String(format: " %@:%@", NSLocalizedString("ReceivedCharacetSet", comment: ""), "UTF-8");
            }
            else
            {
                retVal += String(format: " %@:%@", NSLocalizedString("ReceivedCharacetSet", comment: ""), "GBK");
            }
        }
        return retVal;
    }
}
