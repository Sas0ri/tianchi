//
//  AFNetworking+Cancel.swift
//  tc
//
//  Created by Sasori on 16/8/23.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

extension AFURLSessionManager {
    func cancelAllHTTPOperations(withPath path:String) {
        self.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            self.cancelTasks(inArray: dataTasks, withPath: path)
            self.cancelTasks(inArray: uploadTasks, withPath: path)
            self.cancelTasks(inArray: downloadTasks, withPath: path)
        }
    }
    
    func cancelTasks(inArray taskArray:[NSURLSessionTask], withPath path:String) {
        for dataTask in taskArray {
            if let _ = dataTask.currentRequest?.URL?.absoluteString.rangeOfString(path) {
                dataTask.cancel()
            }
        }
    }
}
