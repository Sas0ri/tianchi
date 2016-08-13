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
    func connectFailed()
    func didReceivePayload(payload:TCSocketPayload)
    func didDisconnect()
    func didHandShake()
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
    
    func connect() {
        if self.socket.isConnected() {
            self.socket.setDelegate(nil)
            self.socket.disconnect()
            self.socket = AsyncSocket(delegate: self)
        }
        do {
            try self.socket.connectToHost(self.address!, onPort: self.port!)
        } catch let error as NSError {
            DDLogError(error.description)
            self.delegate?.connectFailed()
        }
        return
    }
    
    func sendPayload(payload: TCSocketPayload) {
        let data = payload.dataValue()
        self.socket.writeData(data, withTimeout: -1, tag: 0)
        DDLogInfo("send payload cmd: " + "\(payload.cmdType)")
        if payload.cmdContent != nil {
            DDLogInfo("content: " + "\(payload.cmdContent!)")
        }
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
        startHeartbeatPayload.cmdType = 1700
        self.socket.writeData(startHeartbeatPayload.dataValue(), withTimeout: -1, tag: 0)
        self.startTimeoutTimer()
    }
    
    func startRepeatHeartbeat() {
        self.repeatTimer = NSTimer(timeInterval: 3, target: self, selector: #selector(TCSocketManager.repeatHeartbeat), userInfo: nil, repeats: true)
        self.startTimeoutTimer()
        self.repeatHeartbeat()
    }
    
    func startTimeoutTimer() {
        self.heartbeatTimeoutTimer?.invalidate()
        self.heartbeatTimeoutTimer = NSTimer(timeInterval: 10, target: self, selector: #selector(TCSocketManager.heartbeatTimeout), userInfo: nil, repeats: false)
    }
    
    func repeatHeartbeat() {
        let payload = TCSocketPayload()
        payload.cmdType = 1400
        self.socket.writeData(payload.dataValue(), withTimeout: -1, tag: 0)
    }
    
    // MARK: - Delegate
    
    func onSocket(sock: AsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        DDLogInfo("didConnect")
        self.writeStartHeartbeat()
        self.socket.readDataWithTimeout(-1, tag: 0)
    }
    
    func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        let payload = TCSocketPayload(data: data)
        //开始检测心跳
        if payload.cmdType == 1700 {
            self.startRepeatHeartbeat()
            self.delegate?.didHandShake()
        } else if payload.cmdType == 1400 {
            self.startTimeoutTimer()
        } else {
            self.delegate?.didReceivePayload(payload)
        }
        sock.readDataWithTimeout(-1, tag: 0)
        DDLogInfo("didReadData: " + "\(payload.cmdType)")
    }
    
    func onSocket(sock: AsyncSocket!, didWriteDataWithTag tag: Int) {
        DDLogInfo("didWriteData: ")
    }
    
    func onSocket(sock: AsyncSocket!, willDisconnectWithError err: NSError!) {
        self.delegate?.didDisconnect()
    }
    
    func onSocketDidDisconnect(sock: AsyncSocket!) {
        DDLogInfo("socket disconnect")
    }
}
