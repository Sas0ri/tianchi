//
//  TCKTVPayloadHandler.swift
//  tc
//
//  Created by Sasori on 16/6/22.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

var _sharedHandler:TCKTVPayloadHandler = TCKTVPayloadHandler()

let TCKTVDownloadLoadedNotification = "TCKTVDownloadLoadedNotification"
let TCKTVOrderedUpdatedNotification = "TCKTVOrderedUpdatedNotification"
let TCKTVDownloadUpdatedNotification = "TCKTVDownloadUpdatedNotification"
let TCKTVDownloadRemovedNotification = "TCKTVDownloadRemovedNotification"

class TCKTVPayloadHandler: NSObject {

    static func sharedHandler() -> TCKTVPayloadHandler {
        return _sharedHandler
    }
    
    func handlePayload(payload:TCSocketPayload) {
        if payload.cmdType > 1000 && payload.cmdType < 1005 || payload.cmdType == 1012 {
            NSNotificationCenter.defaultCenter().postNotificationName(TCKTVOrderedUpdatedNotification, object: self)
        }
        if payload.cmdType > 1005 && payload.cmdType < 1009 && payload.cmdContent != nil {
            var index:Int?
            for i in 0..<TCContext.sharedContext().downloads.count {
                let download = TCContext.sharedContext().downloads[i]
                if download.songNum == Int(payload.cmdContent!) {
                    index = i
                    break
                }
            }
            if index != nil {
                TCContext.sharedContext().downloads.removeAtIndex(index!)
                NSNotificationCenter.defaultCenter().postNotificationName(TCKTVDownloadRemovedNotification, object: self)
            }
        }
        if payload.cmdType == 1005 {
            TCContext.sharedContext().getDownload()
        }
        if payload.cmdType == 1009 && payload.cmdContent != nil {
            var index:Int?
            for i in 0..<TCContext.sharedContext().downloads.count {
                let download = TCContext.sharedContext().downloads[i]
                if download.songNum == Int(payload.cmdContent!) {
                    index = i
                    break
                }
            }
            if index != nil {
                let download = TCContext.sharedContext().downloads[index!]
                TCContext.sharedContext().downloads.removeAtIndex(index!)
                TCContext.sharedContext().downloads.insert(download, atIndex: 0)
                NSNotificationCenter.defaultCenter().postNotificationName(TCKTVDownloadUpdatedNotification, object: self)
            } else {
                TCContext.sharedContext().getDownload()
            }
        }
    }
}
