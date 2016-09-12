//
//  TCSocketManager.swift
//  tc
//
//  Created by Sasori on 16/6/22.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

protocol TCSocketManagerDelegate {
    func connectFailed()
    func didReceivePayload(payload:TCSocketPayload)
    func didDisconnect()
    func didHandShake()
    func didConnect()
}

class TCSocketManager: NSObject, GCDAsyncSocketDelegate {

    var delegate:TCSocketManagerDelegate?
    
    var socket = GCDAsyncSocket()
    var repeatTimer: NSTimer?
    var heartbeatTimeoutTimer: NSTimer?
    var address:String?
    var port:UInt16?
    var startHeartbeatCmd:Int = 0
    var heartbeatCmd:Int = 0
    
    override init() {
        super.init()
        self.socket.delegate = self
    }
    
    func connect() {
        if self.socket.isConnected {
            self.disConnect()
            self.socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        }
        do {
            self.socket.delegate = self
            self.socket.delegateQueue = dispatch_get_main_queue()
            try self.socket.connectToHost(self.address, onPort: self.port!, withTimeout: 2)
        } catch let error as NSError {
            DDLogError(error.description)
            self.delegate?.connectFailed()
        }
        return
    }
    
    func disConnect() {
        DDLogInfo("force disconnect")
        self.repeatTimer?.invalidate()
        self.repeatTimer = nil
        self.heartbeatTimeoutTimer?.invalidate()
        self.heartbeatTimeoutTimer = nil
        self.socket.delegate = nil
        self.socket.disconnect()
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
        DDLogInfo("heartbeatTimeout")
        self.repeatTimer?.invalidate()
        self.heartbeatTimeoutTimer?.invalidate()
        self.delegate?.didDisconnect()
        self.socket.delegate = nil
        self.socket.disconnect()
    }
    
    func writeStartHeartbeat() {
        let startHeartbeatPayload = TCSocketPayload()
        startHeartbeatPayload.cmdType = self.startHeartbeatCmd
        self.socket.writeData(startHeartbeatPayload.dataValue(), withTimeout: -1, tag: 0)
        self.startTimeoutTimer()
    }
    
    func startRepeatHeartbeat() {
        self.repeatTimer = NSTimer(timeInterval: 3, target: self, selector: #selector(TCSocketManager.repeatHeartbeat), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(self.repeatTimer!, forMode: NSRunLoopCommonModes)
        self.startTimeoutTimer()
        self.repeatHeartbeat()
    }
    
    func startTimeoutTimer() {
        self.heartbeatTimeoutTimer?.invalidate()
        self.heartbeatTimeoutTimer = NSTimer(timeInterval: 10, target: self, selector: #selector(TCSocketManager.heartbeatTimeout), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(self.heartbeatTimeoutTimer!, forMode: NSRunLoopCommonModes)
    }
    
    func repeatHeartbeat() {
        let payload = TCSocketPayload()
        payload.cmdType = self.heartbeatCmd
        self.socket.writeData(payload.dataValue(), withTimeout: -1, tag: 0)
    }
    
    // MARK: - Delegate
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        DDLogInfo("didConnect")
        self.delegate?.didConnect()
        if self.startHeartbeatCmd > 0 {
            self.writeStartHeartbeat()
        } else {
            self.startRepeatHeartbeat()
        }
        self.socket.readDataWithTimeout(-1, tag: 0)
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        let payload = TCSocketPayload(data: data)
        //开始检测心跳
        if payload.cmdType == self.startHeartbeatCmd {
            self.startRepeatHeartbeat()
            self.delegate?.didHandShake()
        } else if payload.cmdType == self.heartbeatCmd {
            self.startTimeoutTimer()
        } else {
            self.delegate?.didReceivePayload(payload)
        }
        sock.readDataWithTimeout(-1, tag: 0)
        DDLogInfo("didReadData: " + "\(payload.cmdType)")
    }
    
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        DDLogInfo("didWriteData: ")
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        DDLogInfo("socket didDisconnect error: " + err.description)
        self.delegate?.didDisconnect()
    }
}
