//
//  TCSocketPayload.swift
//  tc
//
//  Created by Sasori on 16/6/22.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCSocketPayload: NSObject {
    var cmdType:String!
    var cmdContent:String!
    
    convenience init(data:NSData) {
        self.init()
        let json = JSON(data)
        self.cmdType = json["cmd_type"].stringValue
        self.cmdContent = json["cmd_content"].stringValue
    }
    
    func dataValue() -> NSData? {
        let json:JSON = ["cmd_type": self.cmdType, "cmd_content": self.cmdContent]
        do {
            let data = try json.rawData()
            return data
        } catch let error as NSError {
            DDLogError(error.description)
        }
        return nil
    }
}
