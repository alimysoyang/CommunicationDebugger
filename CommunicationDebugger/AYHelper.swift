//
//  AYHelper.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/23.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 全局枚举类型
/**
 手机屏幕尺寸
 
 - kPST_3_5: 3.5寸，4s以前
 - kPST_4:   4寸，5、5c、5s
 - kPST_4_7: 4.7寸，6
 - kPST_5_5: 5.5寸，6plus
 - kPSTUnkown: 其它尺寸
 */
enum PhoneSizeType:Int
{
    case kPST_3_5 = 0
    case kPST_4
    case kPST_4_7
    case kPST_5_5
    case kPSTUnkown
}

/**
 服务类型
 
 - kCMSTServer:  服务端
 - kCMSTClient:  客户端
 */
enum ServiceType:Int
{
    case kCMSTServer = 0
    case kCMSTClient
}

/**
 通讯类型
 
 - kCMSTUDP: UDP方式
 - kCMSTTCP: TCP方式
 */
enum SocketType:Int
{
    case kCMSTUDP = 0
    case kCMSTTCP
}

/**
 通讯传输的字符集
 
 - kCMSCSGBK: GBK字符集
 - kCMSCSUTF8: UTF8字符集
 */
enum SocketCharacetSet:Int
{
    case kCMSCSGBK = 0
    case kCMSCSUTF8
}

/**
 通讯的消息类型
 
 - kCMSMTSend:                 发送
 - kCMSMTReceived:            接收
 - kCMSMTNotification:        通知
 - kCMSMTErrorNotification: 错误数据的通知(文字采用红色)
 */
enum SocketMessageType:Int
{
    case kCMSMTSend = 0
    case kCMSMTReceived
    case kCMSMTNotification
    case kCMSMTErrorNotification
}

/**
 通讯数据状态
 
 - kCMMSuccess:    发送、接收成功
 - kCMMSFailed:    发送失败
 - kCMMSErrorData: 发送、接收数据无法解析
 - kCMMSValideAddress: 发送的无效地址
 */
enum MessageStatus:Int
{
    case kCMMSuccess = 0
    case kCMMSFailed
    case kCMMSErrorData
    case kCMMSValideAddress
}

/**
 项目助手单元
 
 */
class AYHelper: NSObject
{
    // MARK: - properties
    // MARK: - 通讯配置文件名
    class var configFileName: String
    {
        return "cmparams";
    }
    
    // MARK: - app配置文件名
    class var sconfigFileName: String
    {
        return "apparams";
    }
    
    // MARK: - 屏幕宽度
    class var screenWidth:CGFloat
    {
        return UIScreen.mainScreen().bounds.size.width;
    }
    
    class var singleLine:CGFloat
    {
        return 1.0 / UIScreen.mainScreen().scale;
    }
    
    // MARK: - 12号字体
    class var p12Font:UIFont
    {
        return UIFont.systemFontOfSize(12.0);
    }
    
    // MARK: - 15号字体
    class var p15Font:UIFont
    {
        return UIFont.systemFontOfSize(15.0);
    }
    
    // MARK: - 默认背景色
    class var defaultBackgroundColor:UIColor
    {
        return UIColor(red: 249.0 / 255.0, green: 247.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0);
        //return UIColor(red: 235.0 / 255.0 , green: 235.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0);
    }
    
    // MARK: - 默认弹出式的背景色
    class var defaultPopBackgroundColor:UIColor
    {
        return UIColor(red: 249.0 / 255.0, green: 247.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0);
    }
    
    class var dateformatter : NSDateFormatter
    {
        struct sharedInstance
        {
            static var onceToken:dispatch_once_t = 0;
            static var staticInstance:NSDateFormatter? = nil;
        }
        
        dispatch_once(&sharedInstance.onceToken, { () -> Void in
            sharedInstance.staticInstance = NSDateFormatter();
            sharedInstance.staticInstance?.dateFormat = "yyyy-MM-dd HH:mm:ss";
        });
        
        return sharedInstance.staticInstance!;
    }
    
    // MARK: - life cycle
    override init()
    {
        super.init();
    }
    
    deinit
    {
        
    }
    
    // MARK: - static methods
    
    // MARK: - 判断当前设备的屏幕类型
    class func currentDevicePhoneSizeType()->PhoneSizeType
    {
        var retVal:PhoneSizeType = .kPSTUnkown;
        let currentModeSize:CGSize = UIScreen.mainScreen().currentMode!.size;
        var isSame:Bool = UIScreen.instancesRespondToSelector("currentMode") ? CGSizeEqualToSize(CGSizeMake(1242, 2208), currentModeSize) : false;
        if (isSame)
        {
            retVal = .kPST_5_5;
        }
        else
        {
            isSame = UIScreen.instancesRespondToSelector("currentMode") ? CGSizeEqualToSize(CGSizeMake(750, 1334), currentModeSize) : false;
            if (isSame)
            {
                retVal = .kPST_4_7;
            }
            else
            {
                isSame = UIScreen.instancesRespondToSelector("currentMode") ? CGSizeEqualToSize(CGSizeMake(640, 1136), currentModeSize) : false;
                if (isSame)
                {
                    retVal = .kPST_4;
                }
                else
                {
                    isSame = UIScreen.instancesRespondToSelector("currentMode") ? CGSizeEqualToSize(CGSizeMake(640, 960), currentModeSize) : false;
                    if (isSame)
                    {
                        retVal = .kPST_3_5
                    }
                }
            }
        }
        return retVal;
    }
    
    // MARK: - 获取本地IP地址
    class func getIPAddress()->String
    {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        if getifaddrs(&ifaddr) == 0
        {
            // For each interface ...
            for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next)
            {
                let flags = Int32(ptr.memory.ifa_flags)
                var addr = ptr.memory.ifa_addr.memory
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING)
                {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6)
                    {
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0)
                        {
                            if let address = String.fromCString(hostname)
                            {
                                addresses.append(address)
                            }
                        }
                    }
                }
            }
            freeifaddrs(ifaddr);
        }
        
        if (addresses.count > 0)
        {
            return addresses[0];
        }
        
        return NSLocalizedString("UnkownIP", comment: "");
    }

    // MARK: - 16进制字符转单字节
    class func charsToByte(highChar:unichar, lowChar:unichar)->UInt8
    {
        var highb:unichar;
        var lowb:unichar;
        var tmpb:unichar;
        if (highChar >= 48 && highChar <= 57)
        {
            tmpb = 48;
        }
        else if (highChar >= 65 && highChar <= 70)
        {
            tmpb = 55;
        }
        else
        {
            tmpb = 87;
        }
        highb = (highChar - tmpb) * 16;
        
        if (lowChar >= 48 && lowChar <= 57)
        {
            tmpb = 48;
        }
        else if (lowChar >= 65 && lowChar <= 70)
        {
            tmpb = 55;
        }
        else
        {
            tmpb = 87;
        }
        lowb = lowChar - tmpb;
        return UInt8(highb + lowb);
    }
    
    class func parseReceivedData(receivedData:NSData)->AYHReceivedData
    {
        let retVal:AYHReceivedData = AYHReceivedData();
        if (AYHCMParams.sharedInstance.rHexData)
        {
            retVal.receivedMsg = receivedData.toHexString("");
        }
        else
        {
            if (AYHCMParams.sharedInstance.rCharacterSet == .kCMSCSGBK)
            {
                retVal.receivedMsg = NSString(data: receivedData, encoding: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))) as? String;
            }
            else
            {
                retVal.receivedMsg = NSString(data: receivedData, encoding: NSUTF8StringEncoding) as? String;
            }
        }
        
        guard let _ = retVal.receivedMsg else
        {
            retVal.receivedDataResultType = .kCMMSErrorData;
            retVal.receivedMsg = String(format: "%@:\n%@", NSLocalizedString("ReceivedDataUnkown", comment: "ReceivedDataUnkown"), receivedData.toHexString(""));
            return retVal;
        }
        return retVal;
    }
}

// MARK: - String扩展
extension String
{
    /**
     字符串去除空格
     
     - returns: 更新后的字符串
     */
    func trim()->String
    {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet());
    }
    
    /**
     判断当前字符串是不是合法的IP地址
     
     :returns: true，false
     */
    func isValideIPAddress()->Bool
    {
        var retVal:Bool = false;
        do
        {
            let regx:NSRegularExpression = try NSRegularExpression(pattern: "^(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])$", options: NSRegularExpressionOptions.CaseInsensitive);
            let nStr:NSString = self as NSString;
            let matches = regx.matchesInString(self, options:[], range: NSMakeRange(0, nStr.length));
            retVal = matches.count > 0;
        } catch let error as NSError
        {
            retVal = false;
            debugPrint("isValideIPAddress:\(error)");
        }
        return retVal;
    }
    
    /**
     判断当前字符串是不是一个有效的16进制字符串
     
     :returns: true，false
     */
    func isValideHexString()->Bool
    {
        let compareHex = "01234567890abcdefABCDEF";
        let cs:NSCharacterSet = NSCharacterSet(charactersInString: compareHex).invertedSet;
        let filtereds:NSArray = self.componentsSeparatedByCharactersInSet(cs) as NSArray;
        let filtered:String = filtereds.componentsJoinedByString("");
        
        return self == filtered;
    }
    
    /**
     将普通字符串或16进制字符串转成NSData
     
     :param: hexData          true，false
     :param: characterSetType 字符集类型0-GBK，1-UTF8，默认1-UTF8
     
     :returns: NSData
     */
    func toNSData(hexData:Bool, characterSetType:Int = 1)->NSData?
    {
        var retVal:NSData?;
        let nStr:NSString = self as NSString;
        if (hexData)
        {
            if (self.isValideHexString())
            {
                let length:Int = nStr.length / 2;
                var values:[UInt8] = [UInt8](count:length, repeatedValue:0);
                var i:Int = 0;
                var j:Int = 0;
                while (i < length * 2)
                {
                    let highChar:unichar = nStr.characterAtIndex(i);
                    let lowChar:unichar = nStr.characterAtIndex(i + 1);
                    values[j] = AYHelper.charsToByte(highChar, lowChar: lowChar);
                    i += 2;
                    j++;
                }
                
                retVal = NSData(bytes: values, length: length);
            }
        }
        else
        {
            if (characterSetType == 0)//GBK
            {
                retVal = self.dataUsingEncoding(CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)));
            }
            else
            {
                retVal = self.dataUsingEncoding(NSUTF8StringEncoding);
            }
        }
        
        return retVal;
    }
}

// MARK: - NSData扩展
extension NSData
{
    /**
     NSData转成16进制字符串
     
     :param: seperatorChar 分割字符，可以为空
     
     :returns: 16进制字符串
     */
    func toHexString(seperatorChar:String?)->String
    {
        var retVal:String = "";
        let count:Int = self.length / sizeof(UInt8);
        var bytes:[UInt8] = [UInt8](count:count, repeatedValue:0);
        self.getBytes(&bytes, length: count * sizeof(UInt8));
        for index in 0..<count
        {
            if let sChar = seperatorChar
            {
                if (index == count - 1)
                {
                    retVal += String(format: "%02X", bytes[index]);
                }
                else
                {
                    retVal += (String(format: "%02X", bytes[index]) + sChar);
                }
            }
            else
            {
                retVal += String(format: "%02X", bytes[index]);
            }
        }
        
        return retVal;
    }
}

extension NSDate
{
    func currentDateToStartDateAndEndDate()->(startDate:NSDate?, endDate:NSDate?)
    {
        let calendar:NSCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!;
        let compents:NSDateComponents = calendar.components([.NSYearCalendarUnit, .NSMonthCalendarUnit, .NSDayCalendarUnit, .NSHourCalendarUnit, .NSMinuteCalendarUnit, .NSSecondCalendarUnit], fromDate: self);
        compents.hour = 0;
        compents.minute = 0;
        compents.second = 0;
        let startDate:NSDate? = calendar.dateFromComponents(compents);
        compents.hour = 23;
        compents.minute = 59;
        compents.second = 59;
        let endData:NSDate? = calendar.dateFromComponents(compents);
        return (startDate, endData);
    }
    
    func anyDateToStartDateAndEndDate(daySpace:Int)->(startDate:NSDate?, endDate:NSDate?)
    {
        let calendar:NSCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!;
        let compents:NSDateComponents = calendar.components([.NSYearCalendarUnit, .NSMonthCalendarUnit, .NSDayCalendarUnit, .NSHourCalendarUnit, .NSMinuteCalendarUnit, .NSSecondCalendarUnit], fromDate: self);
        compents.hour = 0;
        compents.minute = 0;
        compents.second = 0;
        var tmpDate:NSDate? = calendar.dateFromComponents(compents);
        if let _ = tmpDate
        {
            tmpDate = tmpDate!.dateByAddingTimeInterval(NSTimeInterval(daySpace * 86400));
            return tmpDate!.currentDateToStartDateAndEndDate();
        }
        return (nil, nil);
    }
    
}

// MARK: - UIColor扩展
extension UIColor
{
    /**
     16进制字符串颜色值转UIColor
     
     - parameter hexColor: 16进制字符串
     - parameter alpha:    透明度，默认1.0
     
     - returns: UIColor
     */
    public convenience init?(hexColor:String, alpha:CGFloat = 1.0)
    {
        var hex = hexColor
        
        if hex.hasPrefix("#")
        {
            hex = hex.substringFromIndex(hex.startIndex.advancedBy(1));
        }
        
        if (hex.rangeOfString("(^[0-9A-Fa-f]{6}$)|(^[0-9A-Fa-f]{3}$)", options: .RegularExpressionSearch) != nil)
        {
            if hex.characters.count == 3
            {
                let redHex   = hex.substringToIndex(hex.startIndex.advancedBy(1));
                let greenHex = hex.substringWithRange(Range<String.Index>(start: hex.startIndex.advancedBy(1), end: hex.startIndex.advancedBy(2)));
                let blueHex  = hex.substringFromIndex(hex.startIndex.advancedBy(2));
                
                hex = redHex + redHex + greenHex + greenHex + blueHex + blueHex;
            }
            
            let redHex = hex.substringToIndex(hex.startIndex.advancedBy(2));
            let greenHex = hex.substringWithRange(Range<String.Index>(start: hex.startIndex.advancedBy(2), end: hex.startIndex.advancedBy(4)));
            let blueHex = hex.substringWithRange(Range<String.Index>(start: hex.startIndex.advancedBy(4), end: hex.startIndex.advancedBy(6)));
            
            var redInt:   CUnsignedInt = 0;
            var greenInt: CUnsignedInt = 0;
            var blueInt:  CUnsignedInt = 0;
            
            NSScanner(string: redHex).scanHexInt(&redInt);
            NSScanner(string: greenHex).scanHexInt(&greenInt);
            NSScanner(string: blueHex).scanHexInt(&blueInt);
            
            self.init(red: CGFloat(redInt) / 255.0, green: CGFloat(greenInt) / 255.0, blue: CGFloat(blueInt) / 255.0, alpha: alpha);
        }
        else
        {
            self.init();
            return nil;
        }
        
    }
    
    /**
     整型数据转UIColor，可以是16进制整型数据
     
     - parameter rgb:   RGB颜色整型值
     - parameter alpha: 透明度，默认1.0
     
     - returns: UIColor
     */
    public convenience init(rgb:Int,alpha:CGFloat = 1.0)
    {
        let red:CGFloat = CGFloat((rgb & 0xFF0000) >> 16) / 255.0;
        let green:CGFloat = CGFloat((rgb & 0x00FF00) >> 8) / 255.0;
        let blue:CGFloat = CGFloat(rgb & 0x0000FF) / 255.0;
        self.init(red:red, green:green, blue:blue, alpha:alpha);
    }
}

// MARK:- CGSize 扩展
extension CGSize
{
    public func isEqualSize(compareSize:CGSize)->Bool
    {
        if (self.width == compareSize.width && self.height == compareSize.height)
        {
            return true;
        }
        
        return false;
    }
}

extension UIView
{
    enum AlertViewType:Int
    {
        case kAVTSuccess = 0
        case kAVTFailed
        case kAVTNone
    }
    
    func alert(msg:String, alertType:AlertViewType)
    {
        let hud:MBProgressHUD = MBProgressHUD.showHUDAddedTo(self, animated: true);
        hud.labelText = msg;
        hud.removeFromSuperViewOnHide = true;
        
        if (alertType == .kAVTNone)
        {
            hud.customView = UIView();
        }
        else
        {
            var image:UIImage = UIImage(named: "alertsuccess")!;
            if (alertType == .kAVTFailed)
            {
                image = UIImage(named: "alertfailed")!;
            }
            hud.customView = UIImageView(image: image);
        }
        
        hud.mode = MBProgressHUDMode.CustomView;
        self.addSubview(hud);
        hud.show(true);
        hud.hide(true, afterDelay: 2.0);
    }
    
    func showLoadAlert(msg:String)
    {
        let hud:MBProgressHUD = MBProgressHUD.showHUDAddedTo(self, animated: true);
        hud.labelText = msg;
//        hud.dimBackground = true;背景加入渐变颜色
        //hud.mode = MBProgressHUDMode.Indeterminate;
        hud.tag = 1010;
        self.addSubview(hud);
        self.bringSubviewToFront(hud);
        hud.show(true);
    }
    
    func hideLoadAlert()
    {
        self.viewWithTag(1010)?.removeFromSuperview();
        MBProgressHUD.hideHUDForView(self, animated: true);
    }
}

// MARK:- UIViewController 扩展
extension UIViewController
{
    public func showAlertTip(tipMessage:String)
    {
        if #available(iOS 8.0, *)
        {
            let alertController:UIAlertController = UIAlertController(title:NSLocalizedString("Information", comment: ""), message: tipMessage, preferredStyle: UIAlertControllerStyle.Alert);
            
            let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                alertController.dismissViewControllerAnimated(true, completion: { () -> Void in
                });
            });
            alertController.addAction(alertAction);
            self.presentViewController(alertController, animated: true, completion: nil);
        }
        else
        {
            let alertView:UIAlertView = UIAlertView(title: NSLocalizedString("Information", comment: ""), message: tipMessage, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""));
            alertView.show();
        }
    }
}