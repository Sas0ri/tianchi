//
//  TCKTVSingerClient.swift
//  tc
//
//  Created by Sasori on 16/6/21.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCKTVSingerClient: NSObject {
    let path = "TianChiServer/GetSingerList"
    let pagePath = "TianChiServer/GetSingerTotalPage"
    
    var client:MCJSONClient? = {
        var c:MCJSONClient?
        if let url = TCContext.sharedContext().serverAddress {
            c = MCJSONClient(baseURL: NSURL(string: String(format: "http://%@:8080/", url)))
        }
        return c
    }()
    
    var pageClient:AFHTTPSessionManager? = {
        var c:AFHTTPSessionManager?
        if let url = TCContext.sharedContext().serverAddress {
            c = AFHTTPSessionManager(baseURL: NSURL(string: String(format: "http://%@:8080/", url)))
            c?.responseSerializer = AFHTTPResponseSerializer()
        }
        return c
    }()
        
    func singerIconURL(singerId:Int64) -> NSURL {
        return NSURL(string: String(format: "http://%@:8080/TianChiServer/GetImg?path=mnt/sata/singers/%lldd.jpg", singerId))!
    }
    
    func getSingers(keyword:String?, type:Int, page:Int, limit:Int, complete: (singers:[TCKTVSinger]?, totalPage:String, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword?.characters.count > 0 {
            params["py"] = keyword!
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        if type == 1 || type == 3 {
            params["six"] = "STP1"
        } else if type == 2 || type == 4 {
            params["six"] = "STP2"
        } else if type == 5 {
            params["six"] = "STP3"
        } else {
            params["six"] = "STP"
        }
        
        if type == 1 || type == 2 {
            params["area"] = "ATP1"
        } else if type == 3 || type == 4 {
            params["area"] = "ATP2"
        } else {
            params["area"] = "ATP"
        }
        
        params["page"] = NSNumber(integer: page)
        params["pageSize"] = NSNumber(integer: limit)
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            self.pageClient?.GET(self.pagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                var singers = [TCKTVSinger]()
                for jsonSinger in json.arrayValue {
                    let singer = TCKTVSinger()
                    singer.config(jsonSinger)
                    singers.append(singer)
                }
                complete(singers: singers, totalPage: String(data: resp as! NSData, encoding: NSUTF8StringEncoding)!, flag: true)
                }, failure: { (dataTask, error) in
                    complete(singers: nil, totalPage: "", flag: false)
            })

            }, failure: { (error) in
                complete(singers: nil, totalPage: "", flag: false)
        })
    }
}
