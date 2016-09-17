//
//  TCKTVSongNameClient.swift
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


class TCKTVSongClient: NSObject {
    
    let path = "TianChiServer/GetSongList"
    let cloudPath = "TianChiServer/GetCloundList"
    let rankingPath = "TianChiServer/GetRankingSongList"
    let orderedPath = "TianChiServer/GetPointList"
    let downloadPath = "TianChiServer/GetDownloadList"
    
    let pagePath = "TianChiServer/GetSongTotalPage"
    let cloudPagePath = "TianChiServer/GetCloundTotalPage"
    let rankingPagePath = "TianChiServer/GetRankingTotalPage"
    let orderedPagePath = "TianChiServer/GetPointTotalPage"
    let downloadPagePath = "TianChiServer/GetDownloadTotalPage"
    
    var client:MCJSONClient? = {
        var mc:MCJSONClient?
        if let url = TCContext.sharedContext().serverAddress {
            mc = MCJSONClient(baseURL: URL(string: String(format: "http://%@:8080/", url)))
        }
        return mc
    }()
    
    var pageClient:AFHTTPSessionManager? = {
        var c:AFHTTPSessionManager?
        if let url = TCContext.sharedContext().serverAddress {
            c = AFHTTPSessionManager(baseURL: URL(string: String(format: "http://%@:8080/", url)))
            c?.responseSerializer = AFHTTPResponseSerializer()
        }
        return c
    }()
    
    func getSongsByName(_ keyword:String?, words:Int, page:Int, limit:Int, getTotalPage:Bool, complete: @escaping (_ songs:[TCKTVSong]?, _ totalPage:String, _ flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!.uppercased() as AnyObject?
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db" as AnyObject?
        if words > 0 {
            params["words"] = NSNumber(value: words as Int)
        }
        params["page"] = NSNumber(value: page as Int)
        params["pageSize"] = NSNumber(value: limit as Int)
        
        self.client?.cancelAllHTTPOperations(withPath: self.path)
        var count = 1
        var songs = [TCKTVSong]()
        var totalPage = ""
        if getTotalPage {
            count = count + 1
            self.pageClient?.get(self.pagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                count = count - 1
                totalPage = String(data: resp as! Data, encoding: String.Encoding.utf8)!
                if count == 0 {
                    complete(songs,totalPage, true)
                }
                }, failure: { (dataTask, error) in
                    count = count - 1
                    if count == 0 {
                        complete(songs, totalPage, false)
                    }
            })
        }
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            for jsonSong in json.arrayValue {
                let song = TCKTVSong()
                song.config(jsonSong)
                songs.append(song)
            }
            count = count - 1
            if count == 0 {
                complete(songs, totalPage, true)
            }
            
            }, failure: { (error) in
                count = count - 1
                if count == 0 {
                    complete(songs, totalPage, false)
                }
        })
    }
    
    func getSongsByCategory(_ keyword:String?, words:Int, type:String, page:Int, limit:Int, getTotalPage:Bool, complete: @escaping (_ songs:[TCKTVSong]?, _ totalPage:String, _ flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!.uppercased() as AnyObject?
        }
        if words > 0 {
            params["words"] = NSNumber(value: words as Int)
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db" as AnyObject?
        params["type"] = type as AnyObject?
        params["page"] = NSNumber(value: page as Int)
        params["pageSize"] = NSNumber(value: limit as Int)
        
        self.client?.cancelAllHTTPOperations(withPath: self.path)
        var count = 1
        var songs = [TCKTVSong]()
        var totalPage = ""
        if getTotalPage {
            count = count + 1
            self.pageClient?.get(self.pagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                count = count - 1
                totalPage = String(data: resp as! Data, encoding: String.Encoding.utf8)!
                if count == 0 {
                    complete(songs,totalPage, true)
                }
                }, failure: { (dataTask, error) in
                    count = count - 1
                    if count == 0 {
                        complete(songs, totalPage, false)
                    }
            })
        }
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            for jsonSong in json.arrayValue {
                let song = TCKTVSong()
                song.config(jsonSong)
                songs.append(song)
            }
            count = count - 1
            if count == 0 {
                complete(songs, totalPage, true)
            }
            
            }, failure: { (error) in
                count = count - 1
                if count == 0 {
                    complete(songs, totalPage, false)
                }
        })
    }
    
    func getSongsBySinger(_ keyword:String?, singer:String, words:Int, page:Int, limit:Int, getTotalPage:Bool, complete: @escaping (_ songs:[TCKTVSong]?, _ totalPage:String, _ flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!.uppercased() as AnyObject?
        }
        if words > 0 {
            params["words"] = NSNumber(value: words as Int)
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db" as AnyObject?
        params["singer"] = singer as AnyObject?
        params["page"] = NSNumber(value: page as Int)
        params["pageSize"] = NSNumber(value: limit as Int)
        
        self.client?.cancelAllHTTPOperations(withPath: self.path)
        var count = 1
        var songs = [TCKTVSong]()
        var totalPage = ""
        if getTotalPage {
            count = count + 1
            self.pageClient?.get(self.pagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                count = count - 1
                totalPage = String(data: resp as! Data, encoding: String.Encoding.utf8)!
                if count == 0 {
                    complete(songs,totalPage, true)
                }
                }, failure: { (dataTask, error) in
                    count = count - 1
                    if count == 0 {
                        complete(songs, totalPage, false)
                    }
            })
        }
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            for jsonSong in json.arrayValue {
                let song = TCKTVSong()
                song.config(jsonSong)
                songs.append(song)
            }
            count = count - 1
            if count == 0 {
                complete(songs, totalPage, true)
            }
            
            }, failure: { (error) in
                count = count - 1
                if count == 0 {
                    complete(songs, totalPage, false)
                }
        })
    }
    
    func getSongsByLanguage(_ keyword:String?, words:Int, language:Int, page:Int, limit:Int, getTotalPage:Bool, complete: @escaping (_ songs:[TCKTVSong]?, _ totalPage:String, _ flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!.uppercased() as AnyObject?
        }
        if words > 0 {
            params["words"] = NSNumber(value: words as Int)
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db" as AnyObject?
        params["language"] = NSNumber(value: language as Int)
        params["page"] = NSNumber(value: page as Int)
        params["pageSize"] = NSNumber(value: limit as Int)
        
        self.client?.cancelAllHTTPOperations(withPath: self.path)
        var count = 1
        var songs = [TCKTVSong]()
        var totalPage = ""
        if getTotalPage {
            count = count + 1
            self.pageClient?.get(self.pagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                count = count - 1
                totalPage = String(data: resp as! Data, encoding: String.Encoding.utf8)!
                if count == 0 {
                    complete(songs,totalPage, true)
                }
                }, failure: { (dataTask, error) in
                    count = count - 1
                    if count == 0 {
                        complete(songs, totalPage, false)
                    }
            })
        }
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            for jsonSong in json.arrayValue {
                let song = TCKTVSong()
                song.config(jsonSong)
                songs.append(song)
            }
            count = count - 1
            if count == 0 {
                complete(songs, totalPage, true)
            }
            
            }, failure: { (error) in
                count = count - 1
                if count == 0 {
                    complete(songs, totalPage, false)
                }
        })
    }
    
    func getRankingSongs(_ keyword:String?, page:Int, limit:Int, getTotalPage:Bool, complete: @escaping (_ songs:[TCKTVSong]?, _ totalPage:String, _ flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!.uppercased() as AnyObject?
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db" as AnyObject?
        params["page"] = NSNumber(value: page as Int)
        params["pageSize"] = NSNumber(value: limit as Int)
        
        self.client?.cancelAllHTTPOperations(withPath: self.rankingPath)
        var count = 1
        var songs = [TCKTVSong]()
        var totalPage = ""
        if getTotalPage {
            count = count + 1
            self.pageClient?.get(self.rankingPagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                count = count - 1
                totalPage = String(data: resp as! Data, encoding: String.Encoding.utf8)!
                if count == 0 {
                    complete(songs,totalPage, true)
                }
                }, failure: { (dataTask, error) in
                    count = count - 1
                    if count == 0 {
                        complete(songs, totalPage, false)
                    }
            })
        }
        self.client?.MCGet(self.rankingPath, parameters: params, success: { (json) in
            for jsonSong in json.arrayValue {
                let song = TCKTVSong()
                song.config(jsonSong)
                songs.append(song)
            }
            count = count - 1
            if count == 0 {
                complete(songs, totalPage, true)
            }
            
            }, failure: { (error) in
                count = count - 1
                if count == 0 {
                    complete(songs, totalPage, false)
                }
        })
    }
    
    func getCloudSongs(_ keyword:String?, words:Int, page:Int, limit:Int, getTotalPage:Bool, complete: @escaping (_ clouds:[TCKTVCloud]?, _ totalPage:String, _ flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!.uppercased() as AnyObject?
        }
        if words > 0 {
            params["words"] = NSNumber(value: words as Int)
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db" as AnyObject?
        params["page"] = NSNumber(value: page as Int)
        params["pageSize"] = NSNumber(value: limit as Int)
        
        self.client?.cancelAllHTTPOperations(withPath: self.cloudPath)
        var count = 1
        var clouds = [TCKTVCloud]()
        var totalPage = ""
        if getTotalPage {
            count = count + 1
            self.pageClient?.get(self.cloudPagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                count = count - 1
                totalPage = String(data: resp as! Data, encoding: String.Encoding.utf8)!
                if count == 0 {
                    complete(clouds,totalPage, true)
                }
                }, failure: { (dataTask, error) in
                    count = count - 1
                    if count == 0 {
                        complete(clouds,totalPage, false)
                    }
            })
        }
        self.client?.MCGet(self.cloudPath, parameters: params, success: { (json) in
            for jsonCloud in json.arrayValue {
                let cloud = TCKTVCloud()
                cloud.config(jsonCloud)
                clouds.append(cloud)
            }
            count = count - 1
            if count == 0 {
                complete(clouds,totalPage, true)
            }
            
            }, failure: { (error) in
                count = count - 1
                if count == 0 {
                    complete(clouds,totalPage, false)
                }
        })
    }
    
    func getDownloadSongs(_ complete: @escaping (_ downloads:[TCKTVDownload]?, _ flag:Bool)->()) {
        var params = [String: AnyObject]()
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db" as AnyObject?
        self.client?.MCGet(self.downloadPath, parameters: params, success: { (json) in
            var downloads = [TCKTVDownload]()
            for jsonDownload in json.arrayValue {
                let download = TCKTVDownload()
                download.config(jsonDownload)
                downloads.append(download)
            }
            complete(downloads, true)
            }, failure: { (error) in
                complete(nil, false)
        })
    }
    
    func getOrderedSongs(_ complete: @escaping (_ ordereds:[TCKTVPoint]?, _ flag:Bool)->()) {
        var params = [String: AnyObject]()
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db" as AnyObject?
        self.client?.MCGet(self.orderedPath, parameters: params, success: { (json) in
            var ordereds = [TCKTVPoint]()
            for jsonOrdered in json.arrayValue {
                let ordered = TCKTVPoint()
                ordered.config(jsonOrdered)
                ordereds.append(ordered)
            }
            complete(ordereds, true)
            }, failure: { (error) in
                complete(nil, false)
        })
    }
    
    //    http://192.168.31.219:8080/TianChiServer/GetCloundList?path=mnt/sata/SOFMIT_DBBSM.db&words=？&language=？&py=？&singerName=？&sortType=？&pageSize=9
    func searchCloudSongs(_ keyword:String?, words:Int, page:Int, limit:Int, language:Int?, singer:String?, type:String?, getTotalPage:Bool, complete: @escaping (_ clouds:[TCKTVCloud]?, _ totalPage:String, _ flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!.uppercased() as AnyObject?
        }
        if words > 0 {
            params["words"] = NSNumber(value: words as Int)
        }
        if language > 0 {
            params["language"] = NSNumber(value: language! as Int)
        }
        if singer?.characters.count > 0 {
            params["singerName"] = singer as AnyObject?
        }
        if type?.characters.count > 0 {
            params["sortType"] = type as AnyObject?
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db" as AnyObject?
        params["page"] = NSNumber(value: page as Int)
        params["pageSize"] = NSNumber(value: limit as Int)
        
        self.client?.cancelAllHTTPOperations(withPath: self.cloudPath)
        var count = 1
        var clouds = [TCKTVCloud]()
        var totalPage = ""
        if getTotalPage {
            count = count + 1
            self.pageClient?.get(self.cloudPagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                count = count - 1
                totalPage = String(data: resp as! Data, encoding: String.Encoding.utf8)!
                if count == 0 {
                    complete(clouds,totalPage, true)
                }
                }, failure: { (dataTask, error) in
                    count = count - 1
                    if count == 0 {
                        complete(clouds,totalPage, false)
                    }
            })
        }
        self.client?.MCGet(self.cloudPath, parameters: params, success: { (json) in
            for jsonCloud in json.arrayValue {
                let cloud = TCKTVCloud()
                cloud.config(jsonCloud)
                clouds.append(cloud)
            }
            count = count - 1
            if count == 0 {
                complete(clouds,totalPage, true)
            }
            
            }, failure: { (error) in
                count = count - 1
                if count == 0 {
                    complete(clouds,totalPage, false)
                }
        })
    }
    
}
