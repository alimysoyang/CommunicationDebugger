//
//  AYHClientManage.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/23.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

@objc protocol AYHClientManageDelegate
{
    func udpClientManage(clientManage:AYHClientManage, didConnected info:String);
    func udpClientManage(clientManage:AYHClientManage, receivedThenSaveSuccess success:Bool);
    
    func tcpClientManage(clientManage:AYHClientManage, didNotConnected error:String);
    func tcpClientManageDidConnecting(clientManage:AYHClientManage);
    func tcpClientManage(clientManage:AYHClientManage, didConnected connectInfo:String);
    func tcpClientManage(clientManage:AYHClientManage, didDisConnected error:String);
    func tcpClientManage(clientManage:AYHClientManage, receivedThenSaveSuccess success:Bool);
    
    func clientManage(clientManage:AYHClientManage, sendedThenSaveSuccess success:Bool);
    
    
}

/**
 * 客户端管理对象
 */
class AYHClientManage: NSObject 
{
    // MARK: - properties
    weak var delegate:AYHClientManageDelegate?;
    
    private var udpClientSocket:GCDAsyncUdpSocket?;
    private var tcpClientSocket:GCDAsyncSocket?;
    private var sendTag:Int = 0;
    private var sendedData:AYHSendedData?;
    
    // MARK: - life cycle
    override init()
    {
		super.init();
        if (AYHCMParams.sharedInstance.socketType == .kCMSTUDP)
        {
            self.udpClientSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue());
        }
        else
        {
            self.tcpClientSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue());
        }
    }
	
    convenience init(delegate:AYHClientManageDelegate?)
    {
        self.init();
        self.delegate = delegate;
    }
    
    deinit
    {
        self.clientClosedThenNil();
        self.delegate = nil;
    }

    // MARK: - public methods
    func clientConnecting()
    {
        if (AYHCMParams.sharedInstance.socketType == .kCMSTUDP)
        {
            self.udpClientConnecting();
        }
        else
        {
            self.tcpClientConnecting();
        }
    }
    
    func clientClosed()
    {
        if (AYHCMParams.sharedInstance.socketType == .kCMSTUDP)
        {
            self.udpClientClosed();
        }
        else
        {
            self.tcpClientClosed();
        }
    }
    
    func clientSendData(sendData:String)
    {
        func sendedToUdpServer(data:NSData)
        {
            self.udpClientSocket?.sendData(data, toHost: AYHCMParams.sharedInstance.remoteIP, port: UInt16(AYHCMParams.sharedInstance.remotePort), withTimeout: 5, tag: self.sendTag);
            self.sendTag++;
        }
        
        func sendedToTcpServer(data:NSData)
        {
            self.tcpClientSocket?.writeData(data, withTimeout: 5, tag: self.sendTag);
            self.tcpClientSocket?.readDataWithTimeout(-1, tag: self.sendTag);
            self.sendTag++;
        }
        
        defer
        {
            if (self.sendedData?.sendedDataResultType != .kCMMSuccess)
            {
                let msgID:Int = self.sendedToNewMessage(AYHCMParams.sharedInstance.socketType);
            }
        }
        
        self.sendedData = AYHSendedData();
        self.sendedData?.sendedMsg = sendData;
        self.sendedData?.sendedTag = self.sendTag;
        let streamData:NSData? = sendData.toNSData(AYHCMParams.sharedInstance.sHexData, characterSetType: AYHCMParams.sharedInstance.sCharacterSet.rawValue);
        if let data = streamData
        {
            if (AYHCMParams.sharedInstance.socketType == .kCMSTUDP)
            {
                sendedToUdpServer(data);
            }
            else
            {
                sendedToTcpServer(data);
            }
        }
        else
        {
            self.sendedData?.sendedDataResultType = .kCMMSErrorData;
            self.sendedData?.sendedMsg = String(format: "%@:\n%@", NSLocalizedString("SendedDataError", comment: ""), sendData);
        }
    }
    
    // MARK: - event response

    // MARK: - delegate

    // MARK: - private methods
    private func udpClientConnecting()
    {
        var info:String = "";
        defer
        {
            self.delegate?.udpClientManage(self, didConnected: info)
        }
        
        do
        {
            try self.udpClientSocket?.bindToPort(0);
            do
            {
                try self.udpClientSocket?.beginReceiving();
                info = String(format: NSLocalizedString("ClientStartedSuccess", comment: ""), "UDP",  AYHCMParams.sharedInstance.remoteAddress());
                self.notificationToNewMessage(.kCMSTUDP, notificationType: .kCMSMTNotification, notificationInfo: info);
                
            } catch let error as NSError
            {
                info = String(format: NSLocalizedString("BeginReceivedError", comment: ""), NSLocalizedString("Client", comment: ""), error.localizedDescription);
                self.notificationToNewMessage(.kCMSTUDP, notificationType: .kCMSMTErrorNotification, notificationInfo: info);
            }
        } catch let error as NSError
        {
            info = String(format: NSLocalizedString("PortBingError", comment: ""), NSLocalizedString("Client", comment: ""), error.localizedDescription);
            self.notificationToNewMessage(.kCMSTUDP, notificationType: .kCMSMTErrorNotification, notificationInfo: info);
        }
    }
    
    private func tcpClientConnecting()
    {
        do
        {
            try self.tcpClientSocket?.connectToHost(AYHCMParams.sharedInstance.remoteIP, onPort: UInt16(AYHCMParams.sharedInstance.remotePort), withTimeout: 10);
            guard let _ = self.delegate?.tcpClientManageDidConnecting(self) else
            {
                return;
            }
        } catch let error as NSError
        {
            let errorInfo:String = String(format: NSLocalizedString("TcpConnectedFailed", comment: ""), AYHCMParams.sharedInstance.remoteAddress(), error.localizedDescription);
            self.notificationToNewMessage(.kCMSTTCP, notificationType: .kCMSMTErrorNotification, notificationInfo: errorInfo);
            guard let _ = self.delegate?.tcpClientManage(self, didNotConnected: errorInfo) else
            {
                return;
            }
            
        }
    }
    
    private func udpClientClosed()
    {
        if let lUdpClientSocket = self.udpClientSocket
        {
            lUdpClientSocket.closeAfterSending();
        }
    }
    
    private func tcpClientClosed()
    {
        if let lTcpClientSocket = self.tcpClientSocket
        {
            lTcpClientSocket.disconnectAfterReadingAndWriting();
        }
    }
    
    private func clientClosedThenNil()
    {
        if (AYHCMParams.sharedInstance.socketType == .kCMSTUDP)
        {
            self.udpClientClosed();
            self.udpClientSocket = nil;
        }
        else
        {
            self.tcpClientClosed();
            self.tcpClientSocket = nil;
        }
    }
    
    
    private func receivedToNewMessage(socketType:SocketType, received:AYHReceivedData)->Int
    {
        let message:AYHMessage = AYHMessage();
        message.msgTime = NSDate();
        message.serviceType = .kCMSTClient;
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
        message.serviceType = .kCMSTClient;
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
        message.serviceType = .kCMSTClient;
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
extension AYHClientManage : GCDAsyncUdpSocketDelegate
{
    func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
        if let _ = self.sendedData
        {
            if let sendedTag = self.sendedData!.sendedTag
            {
                if (sendedTag == tag)
                {
                    self.sendedData?.sendedDataResultType = .kCMMSuccess;
                    let msgID:Int = self.sendedToNewMessage(.kCMSTUDP);
                    guard let _ = self.delegate?.clientManage(self, sendedThenSaveSuccess: (msgID != -1)) else
                    {
                        return;
                    }
                }
            }
        }
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
   
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        let received:AYHReceivedData = AYHelper.parseReceivedData(data);
        received.receivedAddress = AYHCMParams.sharedInstance.remoteAddress();
        
        let msgID:Int = self.receivedToNewMessage(.kCMSTUDP, received: received);
        guard let _ = self.delegate?.udpClientManage(self, receivedThenSaveSuccess: (msgID != -1)) else
        {
            return;
        }
    }
}

// MARK: - TCP Delegate
extension AYHClientManage : GCDAsyncSocketDelegate
{
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        sock.readDataWithTimeout(-1, tag: 0);
        let connectedInfo:String = String(format: NSLocalizedString("TcpConnectedSuccess", comment: ""), AYHCMParams.sharedInstance.remoteAddress());
        self.notificationToNewMessage(.kCMSTTCP, notificationType: .kCMSMTNotification, notificationInfo: connectedInfo);
        guard let _ = self.delegate?.tcpClientManage(self, didConnected: connectedInfo) else
        {
            return;
        }
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        if let _ = err
        {
            if (err.code == 61)
            {
                let errorInfo:String = String(format: NSLocalizedString("TcpConnectedFailed", comment: ""), AYHCMParams.sharedInstance.remoteAddress(), err.localizedDescription);
                self.notificationToNewMessage(.kCMSTTCP, notificationType: .kCMSMTErrorNotification, notificationInfo: errorInfo);
                guard let _ = self.delegate?.tcpClientManage(self, didNotConnected: errorInfo) else
                {
                    return;
                }
            }
            else
            {
                let errorInfo:String = String(format: NSLocalizedString("TcpConnectionInterrupted", comment: ""), AYHCMParams.sharedInstance.remoteAddress(), err.localizedDescription);
                self.notificationToNewMessage(.kCMSTTCP, notificationType: .kCMSMTErrorNotification, notificationInfo: errorInfo);
                guard let _ = self.delegate?.tcpClientManage(self, didDisConnected: errorInfo) else
                {
                    return;
                }
            }
        }
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        let received:AYHReceivedData = AYHelper.parseReceivedData(data);
        received.receivedAddress = AYHCMParams.sharedInstance.remoteAddress();
        sock.readDataWithTimeout(-1, tag: 0);
        
        let msgID:Int = self.receivedToNewMessage(.kCMSTTCP, received: received);
        guard let _ = self.delegate?.tcpClientManage(self, receivedThenSaveSuccess: (msgID != -1)) else
        {
            return;
        }
    }
    
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        if let _ = self.sendedData
        {
            if let sendedTag = self.sendedData!.sendedTag
            {
                if (sendedTag == tag)
                {
                    self.sendedData?.sendedDataResultType = .kCMMSuccess;
                    let msgID:Int = self.sendedToNewMessage(.kCMSTTCP);
                    guard let _ = self.delegate?.clientManage(self, sendedThenSaveSuccess: (msgID != -1)) else
                    {
                        return;
                    }
                }
            }
        }
    }
    
}