//
//  AYHServerManage.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/23.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

//@objc protocol AYHServerManageDelegate
//{
//    func udpServerManage(serverManage:AYHServerManage, receivedThenSaveSuccess success:Bool);
//    
//    func tcpServerManage(serverManage:AYHServerManage, didAcceptNewSocket info:String);
//    func tcpServerManage(serverManage:AYHServerManage, receivedThenSaveSuccess success:Bool);
//    
//
//    func serverManage(serverManage:AYHServerManage, sendedThenSaveSuccess success:Bool);
//}

@objc protocol AYHServerManageDelegate
{
    func serverManage(serverManage:AYHServerManage, didReadied info:String);
}

class AYHServerManage: NSObject
{
    // MARK: - properties
    weak var delegate:AYHServerManageDelegate?;
    
    private var udpSocket:GCDAsyncUdpSocket?;
    private var listenerTcpSocket:GCDAsyncSocket?;
    
    private var tcpClientsManage:AYHTCPClientsManage?;
    private var udpRemoteAddress:NSData?;
    private var sendTag:Int = 0;
    private var sendedData:AYHSendedData?;
    
    // MARK: - life cycle
    override init()
    {
        super.init();
        if (AYHCMParams.sharedInstance.socketType == .kCMSTUDP)
        {
            self.udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_queue_create("socketQueue", nil));
        }
        else
        {
            self.listenerTcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_queue_create("socketQueue", nil));
            self.tcpClientsManage = AYHTCPClientsManage();
        }
    }
    
    convenience init(delegate:AYHServerManageDelegate?)
    {
        self.init();
        self.delegate = delegate;
    }
    
    deinit
    {
        self.serverClosedThenNil();
        self.delegate = nil;
    }
    
    // MARK: - public methods
    func serverReadied()
    {
        if (AYHCMParams.sharedInstance.socketType == .kCMSTUDP)
        {
            self.udpServerReadied();
        }
        else
        {
            self.tcpServerReadied();
        }
    }
    
    func serverClosed()
    {
        if (AYHCMParams.sharedInstance.socketType == .kCMSTUDP)
        {
            self.udpServerClosed();
        }
        else
        {
            self.tcpServerClosed();
        }
        
        self.notificationToNewMessage(.kCMSTTCP, notificationType: .kCMSMTNotification, notificationInfo: NSLocalizedString("ServerClosed", comment: ""));
    }
    
    func serverSendData(sendData:String)
    {
        func sendedToUDPClient(data:NSData)
        {
            self.udpSocket?.sendData(data, toAddress: self.udpRemoteAddress!, withTimeout: 5, tag: self.sendTag);
            self.sendTag++;
        }
        
        func sendedToTCPClient(data:NSData)
        {
            self.tcpClientsManage?.tcpClientSocket?.socket?.writeData(data, withTimeout: 5, tag: self.sendTag);
            self.sendTag++;
        }
        
        defer
        {
            if (self.sendedData?.sendedDataResultType != .kCMMSuccess)
            {
                let msgID:Int = self.sendedToNewMessage(AYHCMParams.sharedInstance.socketType);
                
//                self.delegate?.serverManage(self, sendedThenSaveSuccess: (msgID != -1));
            }
        }
        
        self.sendedData = AYHSendedData();
        self.sendedData?.sendedMsg = sendData;
        self.sendedData?.sendedTag = self.sendTag;
        if (AYHCMParams.sharedInstance.socketType == .kCMSTUDP)
        {
            guard let _ = self.udpRemoteAddress else
            {
                self.sendedData?.sendedDataResultType = .kCMMSValideAddress;
                self.sendedData?.sendedMsg = String(format: "%@:\n%@", NSLocalizedString("SendedDataValideAddress", comment: ""), sendData);
                return;
            }
            
            let streamData:NSData? = sendData.toNSData(AYHCMParams.sharedInstance.sHexData, characterSetType: AYHCMParams.sharedInstance.sCharacterSet.rawValue);
            if let data = streamData
            {
                sendedToUDPClient(data);
            }
            else
            {
                self.sendedData?.sendedDataResultType = .kCMMSErrorData;
                self.sendedData?.sendedMsg = String(format: "%@:\n%@", NSLocalizedString("SendedDataError", comment: ""), sendData);
            }
        }
        else
        {
            if (self.tcpClientsManage!.isEmpty)
            {
                self.sendedData?.sendedDataResultType = .kCMMSValideAddress;
                self.sendedData?.sendedMsg = String(format: "%@:\n%@", NSLocalizedString("SendedDataValideAddress", comment: ""), sendData);
            }
            else
            {
                let streamData:NSData? = sendData.toNSData(AYHCMParams.sharedInstance.sHexData, characterSetType: AYHCMParams.sharedInstance.sCharacterSet.rawValue);
                if let data = streamData
                {
                    sendedToTCPClient(data);
                }
                else
                {
                    self.sendedData?.sendedDataResultType = .kCMMSErrorData;
                    self.sendedData?.sendedMsg = String(format: "%@:\n%@", NSLocalizedString("SendedDataError", comment: ""), sendData);
                }
            }
        }
        
        
    }
    
    // MARK: - private methods
    private func udpServerReadied()
    {
        var info:String = "";
        defer
        {
            //self.delegate?.serverManage(self, didReadied: info);
        }
        
        do
        {
            try self.udpSocket?.bindToPort(UInt16(AYHCMParams.sharedInstance.localPort));
            do
            {
                try self.udpSocket?.beginReceiving();
                info = String(format: NSLocalizedString("ServerStartedSuccess", comment: ""), "UDP",  AYHCMParams.sharedInstance.localPort);
                self.notificationToNewMessage(.kCMSTUDP, notificationType: .kCMSMTNotification, notificationInfo: info);
            } catch let error as NSError
            {
                info = String(format: NSLocalizedString("BeginReceivedError", comment: ""), NSLocalizedString("Server", comment: ""), error.localizedDescription);
                self.notificationToNewMessage(.kCMSTUDP, notificationType: .kCMSMTErrorNotification, notificationInfo: info);
            }
        } catch let error as NSError
        {
            info = String(format: NSLocalizedString("PortBingError", comment: ""), NSLocalizedString("Server", comment: ""), error.localizedDescription);
            self.notificationToNewMessage(.kCMSTUDP, notificationType: .kCMSMTErrorNotification, notificationInfo: info);
        }
    }
    
    private func tcpServerReadied()
    {
        var info:String = "";
        defer
        {
            self.delegate?.serverManage(self, didReadied: info);
        }
        
        do
        {
            try self.listenerTcpSocket?.acceptOnPort(UInt16(AYHCMParams.sharedInstance.localPort));
            info = String(format: NSLocalizedString("ServerStartedSuccess", comment: ""), "TCP",  AYHCMParams.sharedInstance.localPort);
            self.notificationToNewMessage(.kCMSTTCP, notificationType: .kCMSMTNotification, notificationInfo: info);
        } catch let error as NSError
        {
            info = String(format: NSLocalizedString("PortBingError", comment: ""), NSLocalizedString("Server", comment: ""), error.localizedDescription);
            self.notificationToNewMessage(.kCMSTTCP, notificationType: .kCMSMTErrorNotification, notificationInfo: info);
        }
    }
    
    private func udpServerClosed()
    {
        if let lUdpSocket = self.udpSocket
        {
            lUdpSocket.closeAfterSending();
        }
    }
    
    private func tcpServerClosed()
    {
        if let lListenerTcpSocket = self.listenerTcpSocket
        {
            lListenerTcpSocket.disconnect();
            self.tcpClientsManage?.removeAll();
        }
    }
    
    private func serverClosedThenNil()
    {
        if (AYHCMParams.sharedInstance.socketType == .kCMSTUDP)
        {
            self.udpServerClosed();
            self.udpSocket = nil;
        }
        else
        {
            self.tcpServerClosed();
            self.listenerTcpSocket = nil;
            self.tcpClientsManage = nil;
        }
    }
    
    private func receivedToNewMessage(socketType:SocketType, received:AYHReceivedData)->Int
    {
        let message:AYHMessage = AYHMessage();
        message.msgTime = NSDate();
        message.serviceType = .kCMSTServer;
        message.msgType = .kCMSMTReceived;
        message.msgStatus = received.receivedDataResultType;
        message.msgContent = received.receivedMsg;
        message.msgAddress = received.receivedAddress;
        message.calculateCellHeight();
        AYHDBHelper.sharedInstance.saveMessage(socketType, message: message);
        return (message.msgID ?? -1);
    }
    
    private func sendedToNewMessage(socketType:SocketType)->Int
    {
        let message:AYHMessage = AYHMessage();
        message.msgTime = NSDate();
        message.serviceType = .kCMSTServer;
        message.msgType = .kCMSMTSend;
        message.msgStatus = self.sendedData?.sendedDataResultType
        message.msgContent = self.sendedData?.sendedMsg;
        message.msgAddress = "";
        message.calculateCellHeight();
        AYHDBHelper.sharedInstance.saveMessage(socketType, message: message);
        return (message.msgID ?? -1);
    }
    
    private func notificationToNewMessage(socketType:SocketType, notificationType:SocketMessageType, notificationInfo:String)->Int
    {
        let message:AYHMessage = AYHMessage();
        message.msgTime = NSDate();
        message.serviceType = .kCMSTServer;
        message.msgType = notificationType;
        message.msgStatus = .kCMMSuccess;
        message.msgContent = notificationInfo;
        message.msgAddress = "";
        message.calculateCellHeight();
        AYHDBHelper.sharedInstance.saveMessage(socketType, message: message);
        return (message.msgID ?? -1);
    }
}

// MARK: - UDP Delegate
extension AYHServerManage : GCDAsyncUdpSocketDelegate
{
    // MARK: - UDP连接成功
    func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {
        
    }
    
    // MARK: - UDP未连接，连接失败
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        debugPrint("udp didNotConnect \(error)")
    }
    
    // MARK: - UDP数据发送完成后
    func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
        if let _ = self.sendedData
        {
            if let sendedTag = self.sendedData!.sendedTag
            {
                if (sendedTag == tag)
                {
                    self.sendedData?.sendedDataResultType = .kCMMSuccess;
                    self.sendedToNewMessage(.kCMSTUDP);
//                    guard let _ = self.delegate?.serverManage(self, sendedThenSaveSuccess: (msgID != -1)) else
//                    {
//                        return;
//                    }
                }
            }
        }
    }
    
    // MARK: - UDP数据发送失败，错误
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        debugPrint("udp didNotSendDataWithTag \(error)")
    }
    
    // MARK: - UDP数据接收
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        var remoteIP:NSString?;
        var remotePort:UInt16 = 0;
        GCDAsyncUdpSocket.getHost(&remoteIP, port: &remotePort, fromAddress: address);
        
        let received = AYHelper.parseReceivedData(data);
        received.receivedAddress = "\(remoteIP):\(remotePort)";
        self.udpRemoteAddress = address;
        
        self.receivedToNewMessage(.kCMSTUDP, received: received);
//        guard let _ = self.delegate?.udpServerManage(self, receivedThenSaveSuccess: (msgID != -1)) else
//        {
//            return;
//        }
    }
    
    // MARK: - UDP关闭
    func udpSocketDidClose(sock: GCDAsyncUdpSocket!, withError error: NSError!) {
        
    }
}

// MARK: - TCP Delegate
extension AYHServerManage : GCDAsyncSocketDelegate
{
    // MARK: - 新的TCP客户端接入响应
    func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        self.tcpClientsManage?.addClientSocket(newSocket);
        newSocket.readDataWithTimeout(-1, tag: 0);
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let info:String = String(format: NSLocalizedString("TcpNewAcceptSocket", comment: ""), "\(newSocket.connectedHost):\(newSocket.connectedPort)");
            self.notificationToNewMessage(.kCMSTTCP, notificationType: .kCMSMTNotification, notificationInfo: info);
        });
        
//        guard let _ = self.delegate?.tcpServerManage(self, didAcceptNewSocket: info) else
//        {
//            return;
//        }
    }
    
    // MARK: - TCP客户端断开响应
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        if (err == nil)
        {
            return;
        }
        self.tcpClientsManage?.removeAtSocket(sock);
        let info:String = err.localizedDescription;
        self.notificationToNewMessage(.kCMSTTCP, notificationType: .kCMSMTErrorNotification, notificationInfo: info);
    }
    
    // MARK: - TCP数据接收
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        let received:AYHReceivedData = AYHelper.parseReceivedData(data);
        received.receivedAddress = "\(sock.connectedHost):\(sock.connectedPort)";
        sock.readDataWithTimeout(-1, tag: 0);
        
        self.receivedToNewMessage(.kCMSTTCP, received: received);
//        guard let _ = self.delegate?.tcpServerManage(self, receivedThenSaveSuccess: (msgID != -1)) else
//        {
//            return;
//        }
    }
    
    // MARK: - TCP数据发送完成
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        if let _ = self.sendedData
        {
            if let sendedTag = self.sendedData!.sendedTag
            {
                if (sendedTag == tag)
                {
                    self.sendedData?.sendedDataResultType = .kCMMSuccess;
                    self.sendedToNewMessage(.kCMSTTCP);
//                    guard let _ = self.delegate?.serverManage(self, sendedThenSaveSuccess: (msgID != -1)) else
//                    {
//                        return;
//                    }
                }
            }
        }
    }
}