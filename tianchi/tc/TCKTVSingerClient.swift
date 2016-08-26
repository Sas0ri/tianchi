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
        return NSURL(string: String(format: "http://%@:8080/TianChiServer/GetImg?path=mnt/sata/singers/%lld.jpg",TCContext.sharedContext().serverAddress!, singerId))!
    }
    
    func getSingers(keyword:String?, type:Int, page:Int, limit:Int, getTotalPage:Bool, complete: (singers:[TCKTVSinger]?, totalPage:String, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword?.characters.count > 0 {
            params["py"] = keyword!.uppercaseString
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
        
        self.client?.cancelAllHTTPOperations(withPath: self.path)
        var count = 1
        var singers = [TCKTVSinger]()
        var totalPage = ""
        if getTotalPage {
            count = count + 1
            self.pageClient?.GET(self.pagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                totalPage = String(data: resp as! NSData, encoding: NSUTF8StringEncoding)!
                count = count - 1
                if count == 0 {
                    complete(singers: singers,totalPage: totalPage, flag: true)
                }
                }, failure: { (dataTask, error) in
                    count = count - 1
                    if count == 0 {
                        complete(singers: singers,totalPage: totalPage, flag: false)
                    }
            })
        }
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            for jsonSinger in json.arrayValue {
                let singer = TCKTVSinger()
                singer.config(jsonSinger)
                singers.append(singer)
            }

            count = count - 1
            if count == 0 {
                complete(singers: singers,totalPage: totalPage, flag: true)
            }
            
            }, failure: { (error) in
                count = count - 1
                if count == 0 {
                    complete(singers: singers,totalPage: totalPage, flag: false)
                }
        })
        
    }
}
