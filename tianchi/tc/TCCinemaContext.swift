//
//  TCCinemaContext.swift
//  tc
//
//  Created by Sasori on 16/9/8.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

let _cinemaContext = TCCinemaContext()

class TCCinemaContext: NSObject, TCSocketManagerDelegate, UIAlertViewDelegate {
    
    
    class func sharedContext() -> TCCinemaContext {
        return _cinemaContext
    }
    
    var serverAddress:String? {
        get {
            return TCContext.sharedContext().serverAddress
        }
    }
    
    var socketManager = TCSocketManager()
    
    enum AlertTag: Int {
        case Address = 501
        case Verify = 502
        case Both = 503
        case Reconnect = 504
    }
    
    let port:UInt16 = 9597
    
    override init() {
        super.init()
        self.socketManager.heartbeatCmd = 2001
        self.socketManager.delegate = self
        
        self.socketManager.port = self.port
        self.connect()
    }
    
    func didConnect() {
        UIApplication.sharedApplication().keyWindow?.rootViewController?.view.hideHud()
    }
    
    func didReceivePayload(payload: TCSocketPayload) {
        
    }
    
    func connect() {
        if self.socketManager.socket.isConnected {
            return
        }
        self.socketManager.address = self.serverAddress
        self.socketManager.connect()
    }
    
    func disconnect() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self.socketManager)
        self.socketManager.disConnect()
        UIApplication.sharedApplication().keyWindow?.rootViewController?.view.hideHud()
    }
    
    func connectFailed() {
        self.socketManager.performSelector(#selector(TCSocketManager.connect), withObject: nil, afterDelay: 2)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.view.showHudWithText("连接中...", indicator: false, userInteraction:false)
    }
    
    func didDisconnect() {
        self.socketManager.performSelector(#selector(TCSocketManager.connect), withObject: nil, afterDelay: 2)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.view.showHudWithText("连接中...", indicator: false, userInteraction:false)
        
    }
    
    func didHandShake() {
        
    }
    
}
