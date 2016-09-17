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
    
    func handlePayload(_ payload:TCSocketPayload) {
        if payload.cmdType > 1000 && payload.cmdType < 1005 || payload.cmdType == 1102 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: TCKTVOrderedUpdatedNotification), object: self)
        }
        if payload.cmdType > 1005 && payload.cmdType < 1009 && payload.cmdContent != nil {
            var index:Int?
            for i in 0..<TCKTVContext.sharedContext().downloads.count {
                let download = TCKTVContext.sharedContext().downloads[i]
                if download.songNum == payload.cmdContent!.intValue {
                    index = i
                    break
                }
            }
            if index != nil {
                TCKTVContext.sharedContext().downloads.remove(at: index!)
                NotificationCenter.default.post(name: Notification.Name(rawValue: TCKTVDownloadRemovedNotification), object: self)
            }
        }
        if payload.cmdType == 1005 {
            TCKTVContext.sharedContext().getDownload()
        }
        if payload.cmdType == 1009 && payload.cmdContent != nil {
            var index:Int?
            for i in 0..<TCKTVContext.sharedContext().downloads.count {
                let download = TCKTVContext.sharedContext().downloads[i]
                if download.songNum == payload.cmdContent!.intValue {
                    index = i
                    break
                }
            }
            if index != nil {
                let download = TCKTVContext.sharedContext().downloads[index!]
                TCKTVContext.sharedContext().downloads.remove(at: index!)
                TCKTVContext.sharedContext().downloads.insert(download, at: 0)
                NotificationCenter.default.post(name: Notification.Name(rawValue: TCKTVDownloadUpdatedNotification), object: self)
            } else {
                TCKTVContext.sharedContext().getDownload()
            }
        }
    }
}
