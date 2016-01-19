//
//  AYHTCPClientSocket.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/23.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

/**
 *  TCP服务端管理的TCP客户端连接的对象
 */
class AYHTCPClientSocket: NSObject, NSCopying
{
    // MARK: - properties
    var host:String?;
    var port:UInt16?;
    var socket:GCDAsyncSocket?;

    // MARK: - life cycle
    override init()
    {
		super.init();
        self.host = "";
        self.port = 0;
        self.socket = nil;
    }
	
    convenience init(clientSocket:GCDAsyncSocket)
    {
        self.init();
        self.host = clientSocket.connectedHost;
        self.port = clientSocket.connectedPort;
        self.socket = clientSocket;
    }
    
    convenience init(tcpClientSocket:AYHTCPClientSocket)
    {
        self.init();
        self.host = tcpClientSocket.host;
        self.port = tcpClientSocket.port;
        self.socket = tcpClientSocket.socket;
    }
    
    deinit
    {
        if let lSocket = self.socket
        {
            lSocket.disconnectAfterReadingAndWriting();
        }
        self.socket = nil;
    }

    // MARK: - public methods
    func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copyObject:AYHTCPClientSocket = AYHTCPClientSocket();
        copyObject.host = self.host;
        copyObject.port = self.port;
        copyObject.socket = self.socket;
        return copyObject;
    }
}