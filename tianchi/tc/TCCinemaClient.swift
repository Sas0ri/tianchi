//
//  TCCinemaClient.swift
//  tc
//
//  Created by Sasori on 16/9/8.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCCinemaClient: NSObject {
    let path = "TianChiServer/GetMovieList"
    let pagePath = "TianChiServer/GetMovieTotalPage"
    
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
    
    func movieIconURL(movieId:Int64) -> NSURL {
        return NSURL(string: String(format: "http://%@:8080/TianChiServer/GetImg?path=mnt/sata1/CACHELIBRARY/%lld.jpg",TCContext.sharedContext().serverAddress!, movieId))!
    }
    
    func getMovies(keyword:String?, type:String, area:String, year:String , page:Int, limit:Int, getTotalPage:Bool, complete: (movies:[TCMovie]?, totalPage:String, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword?.characters.count > 0 {
            params["py"] = keyword!.uppercaseString
        }
        params["path"] = "mnt/sata1/media.db"
        if type  != "全部" {
            params["type"] = type
        }
        if area  != "全部" {
            params["area"] = area
        }
        if year  != "全部" {
            params["year"] = year
        }
        
        params["page"] = NSNumber(integer: page)
        params["pageSize"] = NSNumber(integer: limit)
        
        self.client?.cancelAllHTTPOperations(withPath: self.path)
        var count = 1
        var movies = [TCMovie]()
        var totalPage = ""
        if getTotalPage {
            count = count + 1
            self.pageClient?.GET(self.pagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                totalPage = String(data: resp as! NSData, encoding: NSUTF8StringEncoding)!
                count = count - 1
                if count == 0 {
                    complete(movies: movies,totalPage: totalPage, flag: true)
                }
                }, failure: { (dataTask, error) in
                    count = count - 1
                    if count == 0 {
                        complete(movies: movies,totalPage: totalPage, flag: false)
                    }
            })
        }
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            for jsonMovie in json.arrayValue {
                let movie = TCMovie()
                movie.config(jsonMovie)
                movies.append(movie)
            }
            
            count = count - 1
            if count == 0 {
                complete(movies: movies,totalPage: totalPage, flag: true)
            }
            
            }, failure: { (error) in
                count = count - 1
                if count == 0 {
                    complete(movies: movies,totalPage: totalPage, flag: false)
                }
        })
        
    }
}

