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
    func didReceivePayload(_ payload:TCSocketPayload)
    func didDisconnect()
    func didHandShake()
    func didConnect()
}

class TCSocketManager: NSObject, GCDAsyncSocketDelegate {

    var delegate:TCSocketManagerDelegate?
    
    var socket = GCDAsyncSocket()
    var repeatTimer: Timer?
    var heartbeatTimeoutTimer: Timer?
    var address:String?
    var port:UInt16?
    var startHeartbeatCmd:Int = 0
    var heartbeatCmd:Int = 0
    
    override init() {
        super.init()
        self.socket?.delegate = self
    }
    
    func connect() {
        if (self.socket?.isConnected)! {
            self.disConnect()
            self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        }
        do {
            self.socket?.delegate = self
            self.socket?.delegateQueue = DispatchQueue.main
            try self.socket?.connect(toHost: self.address, onPort: self.port!, withTimeout: 2)
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
        self.socket?.delegate = nil
        self.socket?.disconnect()
    }
    
    func sendPayload(_ payload: TCSocketPayload) {
        let data = payload.dataValue()
        self.socket?.write(data as Data!, withTimeout: -1, tag: 0)
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
        self.socket?.delegate = nil
        self.socket?.disconnect()
    }
    
    func writeStartHeartbeat() {
        let startHeartbeatPayload = TCSocketPayload()
        startHeartbeatPayload.cmdType = self.startHeartbeatCmd
        self.socket?.write(startHeartbeatPayload.dataValue() as Data!, withTimeout: -1, tag: 0)
        self.startTimeoutTimer()
    }
    
    func startRepeatHeartbeat() {
        self.repeatTimer = Timer(timeInterval: 3, target: self, selector: #selector(TCSocketManager.repeatHeartbeat), userInfo: nil, repeats: true)
        RunLoop.main.add(self.repeatTimer!, forMode: RunLoopMode.commonModes)
        self.startTimeoutTimer()
        self.repeatHeartbeat()
    }
    
    func startTimeoutTimer() {
        self.heartbeatTimeoutTimer?.invalidate()
        self.heartbeatTimeoutTimer = Timer(timeInterval: 10, target: self, selector: #selector(TCSocketManager.heartbeatTimeout), userInfo: nil, repeats: false)
        RunLoop.main.add(self.heartbeatTimeoutTimer!, forMode: RunLoopMode.commonModes)
    }
    
    func repeatHeartbeat() {
        let payload = TCSocketPayload()
        payload.cmdType = self.heartbeatCmd
        self.socket?.write(payload.dataValue() as Data!, withTimeout: -1, tag: 0)
    }
    
    // MARK: - Delegate
    
    func socket(_ sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        DDLogInfo("didConnect")
        self.delegate?.didConnect()
        if self.startHeartbeatCmd > 0 {
            self.writeStartHeartbeat()
        } else {
            self.startRepeatHeartbeat()
        }
        self.socket?.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket!, didRead data: Data!, withTag tag: Int) {
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
        sock.readData(withTimeout: -1, tag: 0)
        DDLogInfo("didReadData: " + "\(payload.cmdType)")
    }
    
    func socket(_ sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        DDLogInfo("didWriteData: ")
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket!, withError err: NSError!) {
        DDLogInfo("socket didDisconnect error: " + err.description)
        self.delegate?.didDisconnect()
    }
}
