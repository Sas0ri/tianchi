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
            return tcVersion == .full ? TCContext.sharedContext().ktvServerAddress : TCContext.sharedContext().serverAddress
        }
    }
    
    var socketManager = TCSocketManager()
    
    enum AlertTag: Int {
        case address = 501
        case verify = 502
        case both = 503
        case reconnect = 504
    }
    
    let port:UInt16 = 9597
    
    override init() {
        super.init()
        self.socketManager.heartbeatCmd = 2001
        self.socketManager.delegate = self
        
        self.socketManager.port = self.port
//        self.connect()
    }
    
    func didConnect() {
        UIApplication.shared.keyWindow?.rootViewController?.view.hideHud()
    }
    
    func didReceivePayload(_ payload: TCSocketPayload) {
        
    }
    
    func connect() {
        if (self.socketManager.socket?.isConnected)! {
            return
        }
        self.socketManager.address = self.serverAddress
        self.socketManager.connect()
    }
    
    func disconnect() {
        NSObject.cancelPreviousPerformRequests(withTarget: self.socketManager)
        self.socketManager.disConnect()
        UIApplication.shared.keyWindow?.rootViewController?.view.hideHud()
    }
    
    func connectFailed() {
        self.socketManager.perform(#selector(TCSocketManager.connect), with: nil, afterDelay: 2)
        UIApplication.shared.keyWindow?.rootViewController?.view.showHud(withText: "连接中...", indicator: false, userInteraction:false)
    }
    
    func didDisconnect() {
        self.socketManager.perform(#selector(TCSocketManager.connect), with: nil, afterDelay: 2)
        UIApplication.shared.keyWindow?.rootViewController?.view.showHud(withText: "连接中...", indicator: false, userInteraction:false)
        
    }
    
    func didHandShake() {
        
    }
    
}
