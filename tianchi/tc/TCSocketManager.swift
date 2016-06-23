//
//  TCSocketManager.swift
//  tc
//
//  Created by Sasori on 16/6/22.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

protocol TCSocketManagerDelegate {
    func didReceivePayload(payload:TCSocketPayload)
    func didDisconnect()
}

class TCSocketManager: NSObject, AsyncSocketDelegate {

    var delegate:TCSocketManagerDelegate?
    
    var socket = AsyncSocket()
    var repeatTimer: NSTimer?
    var heartbeatTimeoutTimer: NSTimer?
    var address:String?
    var port:UInt16?
    
    override init() {
        super.init()
        self.socket.setDelegate(self)
    }
    
    func connect() -> Bool{
        if self.socket.isConnected() {
            self.socket.setDelegate(nil)
            self.socket.disconnect()
            self.socket = AsyncSocket(delegate: self)
        }
        do {
            try self.socket.connectToHost(self.address!, onPort: self.port!)
        } catch let error as NSError {
            DDLogError(error.description)
            return false
        }
        return true
    }
    
    func sendPayload(payload: TCSocketPayload) {
        self.socket.writeData(payload.dataValue(), withTimeout: -1, tag: 0)
    }
    
    func heartbeatTimeout() {
        self.repeatTimer?.invalidate()
        self.heartbeatTimeoutTimer?.invalidate()
        self.socket.setDelegate(nil)
        self.socket.disconnect()
        self.delegate?.didDisconnect()
    }
    
    func writeStartHeartbeat() {
        let startHeartbeatPayload = TCSocketPayload()
        startHeartbeatPayload.cmdType = "1700"
        self.socket.writeData(startHeartbeatPayload.dataValue(), withTimeout: -1, tag: 0)
    }
    
    func startRepeatHeartbeat() {
        self.repeatTimer = NSTimer(timeInterval: 3, target: self, selector: #selector(TCSocketManager.repeatHeartbeat), userInfo: nil, repeats: true)
        self.heartbeatTimeoutTimer = NSTimer(timeInterval: 10, target: self, selector: #selector(TCSocketManager.heartbeatTimeout), userInfo: nil, repeats: false)
        self.repeatHeartbeat()
    }
    
    func repeatHeartbeat() {
        let payload = TCSocketPayload()
        payload.cmdType = "1400"
        self.socket.writeData(payload.dataValue(), withTimeout: -1, tag: 0)
    }
    
    // MARK: - Delegate
    
    func onSocket(sock: AsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        self.writeStartHeartbeat()
        self.socket.readDataWithTimeout(-1, tag: 0)
    }
    
    func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        let payload = TCSocketPayload(data: data)
        //开始检测心跳
        if payload.cmdType == "1700" {
            self.startRepeatHeartbeat()
        } else {
            self.delegate?.didReceivePayload(payload)
        }
        sock.readDataWithTimeout(-1, tag: 0)
    }
    
    func onSocket(sock: AsyncSocket!, willDisconnectWithError err: NSError!) {
        self.delegate?.didDisconnect()
    }
    
    func onSocketDidDisconnect(sock: AsyncSocket!) {
        DDLogInfo("socket disconnect")
    }
}
