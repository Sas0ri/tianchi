//
//  TCSocketPayload.swift
//  tc
//
//  Created by Sasori on 16/6/22.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCSocketPayload: NSObject {
    var cmdType:Int! = 0
    var cmdContent:JSON?
    
    convenience init(data:NSData) {
        self.init()
        let json = JSON(data: data)
        self.cmdType = json["cmd_type"].intValue
        self.cmdContent = json["cmd_cotent"]
    }
    
    func dataValue() -> NSData? {
        var json:JSON = ["cmd_type": NSNumber(integer: self.cmdType)]
        if self.cmdContent != nil {
            json["cmd_cotent"] = self.cmdContent!
        }
        do {
            let data = try json.rawData()
            return data
        } catch let error as NSError {
            DDLogError(error.description)
        }
        return nil
    }
}
