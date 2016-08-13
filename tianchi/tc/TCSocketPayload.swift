//
//  TCSocketPayload.swift
//  tc
//
//  Created by Sasori on 16/6/22.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCSocketPayload: NSObject {
    var cmdType:Int!
    var cmdContent:Int?
    
    convenience init(data:NSData) {
        self.init()
        let json = JSON(data: data)
        self.cmdType = json["cmd_type"].intValue
        self.cmdContent = json["cmd_cotent"].intValue
    }
    
    func dataValue() -> NSData? {
        var json:JSON = ["cmd_type": NSNumber(integer: self.cmdType)]
        if self.cmdContent != nil {
            json["cmd_cotent"] = JSON(NSNumber(integer:self.cmdContent!))
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
