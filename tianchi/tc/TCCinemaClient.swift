//
//  TCCinemaClient.swift
//  tc
//
//  Created by Sasori on 16/9/8.
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


class TCCinemaClient: NSObject {
    let path = "TianChiServer/GetMovieList"
    let pagePath = "TianChiServer/GetMovieTotalPage"
    
    var client:MCJSONClient? = {
        var c:MCJSONClient?
        if let url = TCCinemaContext.sharedContext().serverAddress {
            c = MCJSONClient(baseURL: URL(string: String(format: "http://%@:8080/", url)))
        }
        return c
    }()
    
    var pageClient:AFHTTPSessionManager? = {
        var c:AFHTTPSessionManager?
        if let url = TCCinemaContext.sharedContext().serverAddress {
            c = AFHTTPSessionManager(baseURL: URL(string: String(format: "http://%@:8080/", url)))
            c?.responseSerializer = AFHTTPResponseSerializer()
        }
        return c
    }()
    
    func movieIconURL(_ movieId:Int64) -> URL {
        return URL(string: String(format: "http://%@:8080/TianChiServer/GetImg?path=mnt/sata1/CACHELIBRARY/%lld.jpg",TCCinemaContext.sharedContext().serverAddress!, movieId))!
    }
    
    func getMovies(_ keyword:String?, type:String, area:String, year:String , page:Int, limit:Int, getTotalPage:Bool, complete: @escaping (_ movies:[TCMovie]?, _ totalPage:String, _ flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword?.characters.count > 0 {
            params["py"] = keyword!.uppercased() as AnyObject?
        }
        params["path"] = "mnt/sata1/media.db" as AnyObject?
        if type  != "全部" {
            params["type"] = type as AnyObject?
        }
        if area  != "全部" {
            params["area"] = area as AnyObject?
        }
        if year  != "全部" {
            params["year"] = year as AnyObject?
        }
        
        params["page"] = NSNumber(value: page as Int)
        params["pageSize"] = NSNumber(value: limit as Int)
        
        self.client?.cancelAllHTTPOperations(withPath: self.path)
        var count = 1
        var movies = [TCMovie]()
        var totalPage = ""
        if getTotalPage {
            count = count + 1
            _ = self.pageClient?.get(self.pagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                totalPage = String(data: resp as! Data, encoding: String.Encoding.utf8)!
                count = count - 1
                if count == 0 {
                    complete(movies,totalPage, true)
                }
                }, failure: { (dataTask, error) in
                    count = count - 1
                    if count == 0 {
                        complete(movies,totalPage, false)
                    }
            })
        }
        _ = self.client?.MCGet(self.path, parameters: params, success: { (json) in
            for jsonMovie in json.arrayValue {
                let movie = TCMovie()
                movie.config(jsonMovie)
                movies.append(movie)
            }
            
            count = count - 1
            if count == 0 {
                complete(movies,totalPage, true)
            }
            
            }, failure: { (error) in
                count = count - 1
                if count == 0 {
                    complete(movies,totalPage, false)
                }
        })
        
    }
}

