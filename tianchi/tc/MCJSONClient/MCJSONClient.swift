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
    
    override func responseObject(for response: URLResponse?, data: Data?, error: NSErrorPointer) -> Any? {
        DDLogInfo("json: " + String(data:data!, encoding: String.Encoding.utf8)!)
        do {
            try self.validate(response as? HTTPURLResponse, data: data)
            let json = JSON(data: data!).object
            return json as Any?
        } catch {
            DDLogInfo("AFHTTPResponseSerializer Error: " + String(data: data!, encoding: String.Encoding.utf8)!)
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

class MCJSONClient: AFHTTPSessionManager {
    
    override init(baseURL url: URL?, sessionConfiguration configuration: URLSessionConfiguration?) {
        super.init(baseURL: url, sessionConfiguration: configuration)
        responseSerializer = MCJSONResponseSerializer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func MCPost(_ path: String!, parameters: [AnyHashable: Any]!, success: ((JSON) -> Void)!, failure: ((NSError?) -> Void)!) {
        self.post(path, parameters: parameters, success: { (dataTask, response) -> Void in
            if let json = response {
                success(JSON(json))
            } else {
                let err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "解析错误"])
                failure(err)

            }
            }) { (dataTask, error) -> Void in
                DDLogError(error.localizedDescription)
                
                if (error as NSError).code == NSURLErrorCancelled {
                    return
                }
                var err:NSError!
                if !AFNetworkReachabilityManager.shared().isReachable {
                    err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "网络错误"])
                } else {
                    err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "服务器错误"])
                }
                failure(err)
 
        }
    }
    
    func MCGet(_ path: String!, parameters: [AnyHashable: Any]!, success: ((JSON) -> Void)!, failure: ((NSError?) -> Void)!) {
        self.get(path, parameters: parameters, success: { (dataTask, response) -> Void in
            if let json = response {
                success(JSON(json))
            } else {
                let err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "解析错误"])
                failure(err)
                
            }
        }) { (dataTask, error) -> Void in
                DDLogError(error.localizedDescription)
                if (error as NSError).code == NSURLErrorCancelled {
                    return
                }
                var err:NSError!
                if !AFNetworkReachabilityManager.shared().isReachable {
                    err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "网络错误"])
                } else {
                    err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "服务器错误"])
                }
                failure(err)
                
        }

    }
}
