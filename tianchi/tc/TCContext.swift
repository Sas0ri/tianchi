//
//  TCContext.swift
//  tc
//
//  Created by Sasori on 16/6/20.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

var _sharedContext:TCContext = TCContext()

class TCContext: NSObject, TCSocketManagerDelegate {

    var serverAddress:String?
    var socketManager = TCSocketManager()
    
    static func sharedContext() -> TCContext {
        return _sharedContext
    }
    
    override init() {
        super.init()
        self.socketManager.delegate = self
    }
    
    func didReceivePayload(payload: TCSocketPayload) {
        TCKTVPayloadHandler.sharedHandler().handlePayload(payload)
    }
    
    func didDisconnect() {
        
    }
}
