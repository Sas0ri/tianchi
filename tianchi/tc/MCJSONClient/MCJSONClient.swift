//
//  MCJSONClient.swift
//  customer
//
//  Created by Sasori on 16/3/21.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class MCJSONResponseSerializer : AFHTTPResponseSerializer {
    
    override init() {
        super.init()
        acceptableContentTypes = ["application/json", "text/json", "plain/text", "text/html"]
    }

    override func responseObjectForResponse(response: NSURLResponse?, data: NSData?, error: NSErrorPointer) -> AnyObject? {
        DDLogInfo("json: " + String(data:data!, encoding:4)!)
        do {
            try self.validateResponse(response as? NSHTTPURLResponse, data: data)
            let json = JSON(data: data!).object
            return json
        } catch {
            DDLogInfo("AFHTTPResponseSerializer Error: " + String(data: data!, encoding: 4)!)
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

class MCJSONClient: AFHTTPSessionManager {
    
    override init(baseURL url: NSURL?, sessionConfiguration configuration: NSURLSessionConfiguration?) {
        super.init(baseURL: url, sessionConfiguration: configuration)
        responseSerializer = MCJSONResponseSerializer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func MCPost(path: String!, parameters: [NSObject : AnyObject]!, success: ((JSON) -> Void)!, failure: ((NSError!) -> Void)!) {
        self.POST(path, parameters: parameters, progress: nil, success: { (dataTask, response) -> Void in
            if let json = response {
                success(JSON(json))
            } else {
                let err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "解析错误"])
                failure(err)

            }
            }) { (dataTask, error) -> Void in
                DDLogError(error.description)
                if error.code == NSURLErrorCancelled {
                    return
                }
                var err:NSError!
                if !AFNetworkReachabilityManager.sharedManager().reachable {
                    err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "网络错误"])
                } else {
                    err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "服务器错误"])
                }
                failure(err)
 
        }
    }
    
    func MCGet(path: String!, parameters: [NSObject : AnyObject]!, success: ((JSON) -> Void)!, failure: ((NSError!) -> Void)!) {
        self.GET(path, parameters: parameters, progress: nil, success: { (dataTask, response) -> Void in
            if let json = response {
                success(JSON(json))
            } else {
                let err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "解析错误"])
                failure(err)
                
            }
            }) { (dataTask, error) -> Void in
                DDLogError(error.description)
                if error.code == NSURLErrorCancelled {
                    return
                }
                var err:NSError!
                if !AFNetworkReachabilityManager.sharedManager().reachable {
                    err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "网络错误"])
                } else {
                    err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "服务器错误"])
                }
                failure(err)
                
        }

    }
}
