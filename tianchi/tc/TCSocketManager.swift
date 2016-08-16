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
}

class TCSocketManager: NSObject, GCDAsyncSocketDelegate {

    var delegate:TCSocketManagerDelegate?
    
    var socket = GCDAsyncSocket()
    var repeatTimer: NSTimer?
    var heartbeatTimeoutTimer: NSTimer?
    var address:String?
    var port:UInt16?
    
    override init() {
        super.init()
        self.socket.delegate = self
    }
    
    func connect() {
        if self.socket.isConnected {
            self.socket.delegate = nil
            self.socket.disconnect()
            self.socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        }
        do {
            try self.socket.connectToHost(self.address, onPort: self.port!, withTimeout: 5)
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
        self.delegate?.didDisconnect()
        self.socket.delegate = nil
        self.socket.disconnect()
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
    
    func onSocket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        DDLogInfo("didConnect")
        self.writeStartHeartbeat()
        self.socket.readDataWithTimeout(-1, tag: 0)
    }
    
    func onSocket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
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
    
    func onSocket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        DDLogInfo("didWriteData: ")
    }
    
    func onSocket(sock: GCDAsyncSocket!, willDisconnectWithError err: NSError!) {
        DDLogInfo("socket willDisconnect error: " + err.description)
        self.delegate?.didDisconnect()
    }
    
    func onSocketDidDisconnect(sock: GCDAsyncSocket!) {
        DDLogInfo("socket disconnect")
    }
}
