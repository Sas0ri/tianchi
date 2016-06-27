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
    var client:MCJSONClient? = {
        var c:MCJSONClient?
        if let url = TCContext.sharedContext().serverAddress {
            c = MCJSONClient(baseURL: NSURL(string: String(format: "http://%@:8080/", url)))
        }
        return c
    }()
    
    func getSingers(keyword:String?, type:Int, page:Int, complete: (singers:[TCKTVSinger]?, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword?.characters.count > 0 {
            params["py"] = keyword!
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        if type == 0 || type == 2 {
            params["six"] = "STP1"
        } else if type == 1 || type == 3 {
            params["six"] = "STP2"
        } else if type == 4 {
            params["six"] = "STP3"
        } else {
            params["six"] = "STP"
        }
        
        if type == 0 || type == 1 {
            params["area"] = "ATP1"
        } else if type == 2 || type == 3 {
            params["area"] = "ATP2"
        } else {
            params["area"] = "ATP"
        }
        
        params["page"] = NSNumber(integer: page)
        
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            var singers = [TCKTVSinger]()
            for jsonSinger in json.arrayValue {
                let singer = TCKTVSinger()
                singer.config(jsonSinger)
                singers.append(singer)
            }
            complete(singers: singers, flag: true)
            }, failure: { (error) in
                complete(singers: nil, flag: false)
        })
    }
}
