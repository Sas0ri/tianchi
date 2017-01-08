//
//  TCKTVSingerClient.swift
//  tc
//
//  Created by Sasori on 16/6/21.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class TCKTVSingerClient: NSObject {
    let path = "TianChiServer/GetSingerList"
    let pagePath = "TianChiServer/GetSingerTotalPage"
    
    var client:MCJSONClient? = {
        var c:MCJSONClient?
        if let url = TCKTVContext.sharedContext().serverAddress {
            c = MCJSONClient(baseURL: URL(string: String(format: "http://%@:8080/", url)))
        }
        return c
    }()
    
    var pageClient:AFHTTPSessionManager? = {
        var c:AFHTTPSessionManager?
        if let url = TCKTVContext.sharedContext().serverAddress {
            c = AFHTTPSessionManager(baseURL: URL(string: String(format: "http://%@:8080/", url)))
            c?.responseSerializer = AFHTTPResponseSerializer()
        }
        return c
    }()
    
    func singerIconURL(_ singerId:Int64) -> URL {
        return URL(string: String(format: "http://%@:8080/TianChiServer/GetImg?path=mnt/sata/singers/%lld.jpg",TCKTVContext.sharedContext().serverAddress!, singerId))!
    }
    
    func getSingers(_ keyword:String?, type:Int, page:Int, limit:Int, getTotalPage:Bool, complete: @escaping (_ singers:[TCKTVSinger]?, _ totalPage:String, _ flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword?.characters.count > 0 {
            params["py"] = keyword!.uppercased() as AnyObject?
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db" as AnyObject?
        if type == 1 || type == 3 {
            params["six"] = "STP1" as AnyObject?
        } else if type == 2 || type == 4 {
            params["six"] = "STP2" as AnyObject?
        } else if type == 5 {
            params["six"] = "STP3" as AnyObject?
        } else {
            params["six"] = "STP" as AnyObject?
        }
        
        if type == 1 || type == 2 {
            params["area"] = "ATP1" as AnyObject?
        } else if type == 3 || type == 4 {
            params["area"] = "ATP2" as AnyObject?
        } else {
            params["area"] = "ATP" as AnyObject?
        }
        
        params["page"] = NSNumber(value: page as Int)
        params["pageSize"] = NSNumber(value: limit as Int)
        
        self.client?.cancelAllHTTPOperations(withPath: self.path)
        var count = 1
        var singers = [TCKTVSinger]()
        var totalPage = ""
        if getTotalPage {
            count = count + 1
            _ = self.pageClient?.get(self.pagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                totalPage = String(data: resp as! Data, encoding: String.Encoding.utf8)!
                count = count - 1
                if count == 0 {
                    complete(singers,totalPage, true)
                }
                }, failure: { (dataTask, error) in
                    count = count - 1
                    if count == 0 {
                        complete(singers,totalPage, false)
                    }
            })
        }
        _ = self.client?.MCGet(self.path, parameters: params, success: { (json) in
            for jsonSinger in json.arrayValue {
                let singer = TCKTVSinger()
                singer.config(jsonSinger)
                singers.append(singer)
            }
            
            count = count - 1
            if count == 0 {
                complete(singers,totalPage, true)
            }
            
            }, failure: { (error) in
                count = count - 1
                if count == 0 {
                    complete(singers,totalPage, false)
                }
        })
    }
}
