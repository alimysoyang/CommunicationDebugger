//
//  AYHDBHelper.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/27.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

typealias loadCompletionClosure = (success:Bool) -> Void;

class AYHDBHelper: NSObject
{
    private var loadMessagesStartDate:NSDate?;
    private var loading:Bool = false;
    
    // MARK: - properties
    static let sharedInstance:AYHDBHelper =
    {
        let instance = AYHDBHelper();
        return instance;
    }();
    
//    class var sharedInstance : AYHDBHelper
//    {
//        struct sharedInstance
//        {
//            static var onceToken:dispatch_once_t = 0;
//            static var staticInstance:AYHDBHelper? = nil;
//        }
//        
//        dispatch_once(&sharedInstance.onceToken, { () -> Void in
//            sharedInstance.staticInstance = AYHDBHelper();
//        });
//        
//        return sharedInstance.staticInstance!;
//    }
    
    // MARK: - life cycle
    override init()
    {
		super.init();
        self.createDBFileAndTables();
    }
	
    deinit
    {
	
    }
    
    // MARK: - public methods
    func deleteDbFile()->String?
    {
        let fm:NSFileManager = NSFileManager();
        if (fm.fileExistsAtPath(SD.databasePath()))
        {
            do
            {
                try fm.removeItemAtPath(SD.databasePath());
                self.createDBFileAndTables();
                AYHMessageManage.sharedInstance.removeAll();
            } catch let error as NSError
            {
                return error.localizedDescription;
            }
        }
        return nil;
    }
    
    func saveMessage(socketType:SocketType, message:AYHMessage)
    {
        if (AYHParams.sharedInstance.isSaveLogs)
        {
            let tableName:String = self.tableName(socketType);
            let strSQL:String = "insert into \(tableName) (msgtime, servicetype, msgtype, msgstatus, msgcontent, msgaddress) values (datetime('\(message.msgStrTime!)'), \(message.serviceType!.rawValue), \(message.msgType!.rawValue), \(message.msgStatus!.rawValue), '\(message.msgContent!)' , '\(message.msgAddress!)')";
            let task:() -> Void =
            {
                if let _ = SD.executeChange(strSQL)
                {
                    message.msgID = -1;
                }
                else
                {
                    message.msgID = SD.lastInsertedRowID().rowID;
                }
                AYHMessageManage.sharedInstance.append(message);
            }
            
            SD.executeWithConnection(.ReadWrite, closure: task);
        }
        else
        {
            AYHMessageManage.sharedInstance.append(message);
        }
    }

    func deleteMessage(socketType:SocketType, msgID:Int?, index:Int?)
    {
        if (AYHParams.sharedInstance.isSaveLogs)
        {
            guard let _ = msgID else
            {
                return;
            }
            let tableName:String = self.tableName(socketType);
            let strSQL:String = "delete from \(tableName) where msgid=\(msgID!)";
            guard let _ = SD.executeChange(strSQL) else
            {
                if let _ = index
                {
                    AYHMessageManage.sharedInstance.removeAtIndex(index!);
                }
                return;
            }
        }
        else
        {
            if let _ = index
            {
                AYHMessageManage.sharedInstance.removeAtIndex(index!);
            }
        }
    }
    
//    func loadMessages(serviceType:ServiceType, socketType:SocketType, offset:UInt,completion:loadCompletionClosure)
//    {
//        defer
//        {
//            completion();
//        }
//        
//        let tableName:String = self.tableName(socketType);
//        if (offset == 0)
//        {
//            self.loadMessagesStartDate = NSDate();
//        }
//        
//        let strSQL:String = "select msgid, msgtime, servicetype, msgtype, msgstatus, msgcontent, msgaddress from \(tableName) where msgtime<=datetime('\(AYHelper.dateformatter.stringFromDate(self.loadMessagesStartDate!))') order by msgtime desc limit 10 offset \(offset)";
//        let (resultSet, error) = SD.executeQuery(strSQL);
//        guard let _ = error else
//        {
//            for row in resultSet
//            {
//                let message:AYHMessage = AYHMessage();
//                if let msgID = row["msgid"]?.asInt()
//                {
//                    message.msgID = msgID;
//                }
//                else
//                {
//                    message.msgID = -1;
//                }
//                if let msgtime = row["msgtime"]?.asString()
//                {
//                    message.msgTime = AYHelper.dateformatter.dateFromString(msgtime);
//                }
//                if let serviceType = row["servicetype"]?.asInt()
//                {
//                    message.serviceType = ServiceType(rawValue: serviceType);
//                }
//                if let msgtype = row["msgtype"]?.asInt()
//                {
//                    message.msgType = SocketMessageType(rawValue: msgtype);
//                }
//                if let msgstatus = row["msgstatus"]?.asInt()
//                {
//                    message.msgStatus = MessageStatus(rawValue: msgstatus);
//                }
//                if let msgcontent = row["msgcontent"]?.asString()
//                {
//                    message.msgContent = msgcontent;
//                }
//                else
//                {
//                    message.msgContent = "";
//                }
//                if let msgaddress = row["msgaddress"]?.asString()
//                {
//                    message.msgAddress = msgaddress;
//                }
//                else
//                {
//                    message.msgAddress = "";
//                }
//                message.calculateCellHeight();
//                if (AYHMessageManage.sharedInstance.isEmpty())
//                {
//                    AYHMessageManage.sharedInstance.append(message);
//                }
//                else
//                {
//                    AYHMessageManage.sharedInstance.insertObject(message, atIndex: 0);
//                }
//            }
//            
//            return;
//        }
//    }
    
    func loadMessages(serviceType:ServiceType, socketType:SocketType, offSet:Int, completion:loadCompletionClosure)
    {
        var success:Bool = false;
        defer
        {
            self.loading = false;
            completion(success: success);
        }
        
        if (self.loading)
        {
            return
        }
        
        self.loading = true;
        let tableName:String = self.tableName(socketType);
        var paramDate:(startDate:NSDate?, endDate:NSDate?);
        if (offSet == 0)
        {
            paramDate = NSDate().currentDateToStartDateAndEndDate();
        }
        else
        {
            paramDate = NSDate().anyDateToStartDateAndEndDate(-1 * offSet);
        }
        if let _ = paramDate.startDate, let _ = paramDate.endDate
        {
            let startDate:String = AYHelper.dateformatter.stringFromDate(paramDate.startDate!);
            let endDate:String = AYHelper.dateformatter.stringFromDate(paramDate.endDate!);
            let strSQL:String = String(format: "select msgid, msgtime, servicetype, msgtype, msgstatus, msgcontent, msgaddress from %@ where msgtime>=datetime('%@') and msgtime<=datetime('%@') and servicetype=%i order by msgtime", tableName, startDate, endDate, AYHCMParams.sharedInstance.serviceType.rawValue);
            
            let (resultSet, error) = SD.executeQuery(strSQL);
            guard let _ = error else
            {
                if (offSet == 0 && AYHParams.sharedInstance.isSaveLogs)
                {
                    AYHMessageManage.sharedInstance.removeAll();
                }
                
                var tmp:[AYHMessage] = [AYHMessage]();
                for row in resultSet
                {
                    let message:AYHMessage = AYHMessage();
                    if let msgID = row["msgid"]?.asInt()
                    {
                        message.msgID = msgID;
                    }
                    else
                    {
                        message.msgID = -1;
                    }
                    if let msgtime = row["msgtime"]?.asString()
                    {
                        message.msgTime = AYHelper.dateformatter.dateFromString(msgtime);
                    }
                    if let serviceType = row["servicetype"]?.asInt()
                    {
                        message.serviceType = ServiceType(rawValue: serviceType);
                    }
                    if let msgtype = row["msgtype"]?.asInt()
                    {
                        message.msgType = SocketMessageType(rawValue: msgtype);
                    }
                    if let msgstatus = row["msgstatus"]?.asInt()
                    {
                        message.msgStatus = MessageStatus(rawValue: msgstatus);
                    }
                    if let msgcontent = row["msgcontent"]?.asString()
                    {
                        message.msgContent = msgcontent;
                    }
                    else
                    {
                        message.msgContent = "";
                    }
                    if let msgaddress = row["msgaddress"]?.asString()
                    {
                        message.msgAddress = msgaddress;
                    }
                    else
                    {
                        message.msgAddress = "";
                    }
                    message.calculateCellHeight();
                    tmp.append(message);
                    //AYHMessageManage.sharedInstance.append(message);
                }
                
                success = true;
                AYHMessageManage.sharedInstance.insertArray(tmp);
                return;
            }
        }
    }

    // MARK: - private methods
    private func dbFileExists()->Bool
    {
        var retVal:Bool = false;
        let fileManage:NSFileManager = NSFileManager();
        retVal = fileManage.fileExistsAtPath(SD.databasePath());
        return retVal;
    }
    
    /**
     msgid 编号
     msgtime 数据产生的时间
     servicetype 服务端，客户端
     msgtype 发送，接收，普通通知，错误通知
     msgstatus 发送，接收 - (成功，失败，无法解析)
     msgcontent 内容
     msgaddress 地址(发送，通知无地址)，接收(远端地址)
     */
    private func createDBFileAndTables()
    {
        if (!self.dbFileExists())
        {
            let sqls:[String] = ["PRAGMA auto_vacuum=1;",
                "create table if not exists tab_udp_messages (msgid integer primary key autoincrement, msgtime timestamp, servicetype integer, msgtype integer, msgstatus integer, msgcontent text, msgaddress text);",
                "create table if not exists tab_tcp_messages (msgid integer primary key autoincrement, msgtime timestamp, servicetype integer, msgtype integer, msgstatus integer, msgcontent text, msgaddress text);",
                "create index if not exists tab_udp_messages_id_index on tab_udp_messages (msgid);",
                "create index if not exists tab_udp_messages_servicetype_index on tab_udp_messages (servicetype);",
                "create index if not exists tab_udp_messages_time_index on tab_udp_messages (msgtime);",
                "create index if not exists tab_tcp_messages_id_index on tab_tcp_messages (msgid);",
                "create index if not exists tab_tcp_messages_servicetype_index on tab_tcp_messages (servicetype);",
                "create index if not exists tab_tcp_messages_time_index on tab_tcp_messages (msgtime);"];
            let task:() -> Void =
            {
                if let error = SD.executeMultipleChanges(sqls)
                {
                    print("create db failed:\(error)");
                }
            }
            
            SD.executeWithConnection(.ReadWriteCreate, closure: task);
        }
    }
    
    private func tableName(socketType:SocketType)->String
    {
        if (socketType == .kCMSTUDP)
        {
            return "tab_udp_messages";
        }
        
        return "tab_tcp_messages";
    }
}