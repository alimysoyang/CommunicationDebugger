//
//  AYHTCPClientsManage.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/11/23.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import Foundation

/**
 *  TCP服务端管理接入的TCP客户端的队列数据管理器
 */
class AYHTCPClientsManage: NSObject 
{
    // MARK: - properties
    private var tcpClients:AYHSynchronizedArray<AYHTCPClientSocket> = AYHSynchronizedArray<AYHTCPClientSocket>();

    var tcpClientSocket:AYHTCPClientSocket? {
        get {
            if (self.tcpClients.count == 0)
            {
                return nil;
            }
            
            return self.tcpClients.last;
        }
    }
    
    var isEmpty:Bool {
        get { return self.tcpClients.isEmpty; }
    }
    
    
    // MARK: - life cycle
    override init()
    {
		super.init();
    }
	
    deinit
    {
	
    }

    // MARK: - public methods
    func addClientSocket(newSocket:GCDAsyncSocket)
    {
        let tcpClientSocket:AYHTCPClientSocket = AYHTCPClientSocket(clientSocket: newSocket);
        var isExists:Bool = false;
        for index in 0..<self.tcpClients.count
        {
            let item:AYHTCPClientSocket = self.tcpClients[index];
            if let itemSocket = item.socket where itemSocket === newSocket
            {
                isExists = true;
                break;
            }
        }
        
        if (!isExists)
        {
            self.tcpClients.append(tcpClientSocket, completionClosure: { () -> Void in
            });
        }
    }
    
    func removeAtSocket(socket:GCDAsyncSocket)
    {
        var index:Int = self.tcpClients.count - 1;
        while (index >= 0)
        {
            let item:AYHTCPClientSocket = self.tcpClients[index];
            if let itemSocket = item.socket where itemSocket === socket
            {
                self.tcpClients.removeAtIndex(index);
                break;
            }
            index--;
        }
    }
    
    func removeClientSocketAtIndex(index:Int)
    {
        if (index < 0 || index > self.tcpClients.count)
        {
            return;
        }
        
        self.tcpClients.removeAtIndex(index);
    }
    
    func removeAtClientSocket(clientSocket:AYHTCPClientSocket?)
    {
        guard let lTcpClientSocket = clientSocket else
        {
            return;
        }
        
        var foundIndex:Int = -1;
        for index in 0..<self.tcpClients.count
        {
            let item:AYHTCPClientSocket = self.tcpClients[index];
            if let itemSocket = item.socket, removeSocket = lTcpClientSocket.socket
            {
                if (itemSocket === removeSocket)
                {
                    foundIndex = index;
                    break;
                }
            }
        }
        
        if (foundIndex >= 0)
        {
            self.tcpClients.removeAtIndex(foundIndex);
        }
    }
    
    func removeAll()
    {
        self.tcpClients.removeAll({ () -> Void in
            
        });
    }
}