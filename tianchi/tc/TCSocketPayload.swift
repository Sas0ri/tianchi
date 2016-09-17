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
    
    convenience init(data:Data) {
        self.init()
        let json = JSON(data: data)
        self.cmdType = json["cmd_type"].intValue
        self.cmdContent = json["cmd_cotent"]
    }
    
    func dataValue() -> Data? {
        var json:JSON = ["cmd_type": NSNumber(value: self.cmdType as Int)]
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
