//
//  TCKTVPayloadHandler.swift
//  tc
//
//  Created by Sasori on 16/6/22.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

var _sharedHandler:TCKTVPayloadHandler = TCKTVPayloadHandler()


class TCKTVPayloadHandler: NSObject {

    static func sharedHandler() -> TCKTVPayloadHandler {
        return _sharedHandler
    }
    
    func handlePayload(payload:TCSocketPayload) {
        
    }
}
