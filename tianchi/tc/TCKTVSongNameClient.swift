//
//  TCKTVSongNameClient.swift
//  tc
//
//  Created by Sasori on 16/6/21.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

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
            mc = MCJSONClient(baseURL: NSURL(string: String(format: "http://%@:8080/", url)))
        }
        return mc
    }()
    
    var pageClient:AFHTTPSessionManager? = {
        var c:AFHTTPSessionManager?
        if let url = TCContext.sharedContext().serverAddress {
            c = AFHTTPSessionManager(baseURL: NSURL(string: String(format: "http://%@:8080/", url)))
            c?.responseSerializer = AFHTTPResponseSerializer()
        }
        return c
    }()
    
    func getSongsByName(keyword:String?, words:Int, page:Int, limit:Int, complete: (songs:[TCKTVSong]?, totalPage:String, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        if words > 0 {
            params["words"] = NSNumber(integer: words)
        }
        params["page"] = NSNumber(integer: page)
        params["pageSize"] = NSNumber(integer: limit)
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            self.pageClient?.GET(self.pagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                var songs = [TCKTVSong]()
                for jsonSong in json.arrayValue {
                    let song = TCKTVSong()
                    song.config(jsonSong)
                    songs.append(song)
                }
                complete(songs: songs,totalPage: String(data: resp as! NSData, encoding: NSUTF8StringEncoding)!, flag: true)
                }, failure: { (dataTask, error) in
                    
            })

            }, failure: { (error) in
                complete(songs: nil, totalPage: "", flag: false)
        })
    }
    
    func getSongsByCategory(keyword:String?, words:Int, type:String, page:Int, limit:Int, complete: (songs:[TCKTVSong]?, totalPage:String, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!
        }
        if words > 0 {
            params["words"] = NSNumber(integer: words)
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        params["type"] = type
        params["page"] = NSNumber(integer: page)
        params["pageSize"] = NSNumber(integer: limit)
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            self.pageClient?.GET(self.pagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                var songs = [TCKTVSong]()
                for jsonSong in json.arrayValue {
                    let song = TCKTVSong()
                    song.config(jsonSong)
                    songs.append(song)
                }
                complete(songs: songs,totalPage: String(data: resp as! NSData, encoding: NSUTF8StringEncoding)!, flag: true)
                }, failure: { (dataTask, error) in
                    complete(songs: nil, totalPage: "", flag: false)
                    
            })
            }, failure: { (error) in
                complete(songs: nil, totalPage: "", flag: false)
        })
    }
    
    func getSongsBySinger(keyword:String?, singer:String, words:Int, page:Int, limit:Int, complete: (songs:[TCKTVSong]?, totalPage:String, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!
        }
        if words > 0 {
            params["words"] = NSNumber(integer: words)
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        params["singer"] = singer
        params["page"] = NSNumber(integer: page)
        params["pageSize"] = NSNumber(integer: limit)
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            self.pageClient?.GET(self.pagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                var songs = [TCKTVSong]()
                for jsonSong in json.arrayValue {
                    let song = TCKTVSong()
                    song.config(jsonSong)
                    songs.append(song)
                }
                complete(songs: songs,totalPage: String(data: resp as! NSData, encoding: NSUTF8StringEncoding)!, flag: true)
                }, failure: { (dataTask, error) in
                    complete(songs: nil, totalPage: "", flag: false)

            })
            }, failure: { (error) in
                complete(songs: nil, totalPage: "", flag: false)
        })
    }
    
    func getSongsByLanguage(keyword:String?, words:Int, language:Int, page:Int, limit:Int, complete: (songs:[TCKTVSong]?, totalPage:String, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!
        }
        if words > 0 {
            params["words"] = NSNumber(integer:words)
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        params["language"] = NSNumber(integer: language)
        params["page"] = NSNumber(integer: page)
        params["pageSize"] = NSNumber(integer: limit)
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            self.pageClient?.GET(self.pagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                var songs = [TCKTVSong]()
                for jsonSong in json.arrayValue {
                    let song = TCKTVSong()
                    song.config(jsonSong)
                    songs.append(song)
                }
                complete(songs: songs,totalPage: String(data: resp as! NSData, encoding: NSUTF8StringEncoding)!, flag: true)
                }, failure: { (dataTask, error) in
                    complete(songs: nil, totalPage: "", flag: false)
                    
            })
            }, failure: { (error) in
                complete(songs: nil, totalPage: "", flag: false)
        })
    }
    
    func getRankingSongs(keyword:String?, page:Int, limit:Int, complete: (songs:[TCKTVSong]?, totalPage:String, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        params["page"] = NSNumber(integer: page)
        params["pageSize"] = NSNumber(integer: limit)
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            self.pageClient?.GET(self.rankingPagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                var songs = [TCKTVSong]()
                for jsonSong in json.arrayValue {
                    let song = TCKTVSong()
                    song.config(jsonSong)
                    songs.append(song)
                }
                complete(songs: songs,totalPage: String(data: resp as! NSData, encoding: NSUTF8StringEncoding)!, flag: true)
                }, failure: { (dataTask, error) in
                    complete(songs: nil, totalPage: "", flag: false)
                    
            })
            }, failure: { (error) in
                complete(songs: nil, totalPage: "", flag: false)
        })
    }

    func getCloudSongs(keyword:String?, words:Int, page:Int, limit:Int, complete: (clouds:[TCKTVCloud]?, totalPage:String, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!
        }
        if words > 0 {
            params["words"] = NSNumber(integer: words)
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        params["page"] = NSNumber(integer: page)
        params["pageSize"] = NSNumber(integer: limit)
        self.client?.MCGet(self.cloudPath, parameters: params, success: { (json) in
            self.pageClient?.GET(self.cloudPagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                var clouds = [TCKTVCloud]()
                for jsonCloud in json.arrayValue {
                    let cloud = TCKTVCloud()
                    cloud.config(jsonCloud)
                    clouds.append(cloud)
                }
                complete(clouds: clouds,totalPage: String(data: resp as! NSData, encoding: NSUTF8StringEncoding)!, flag: true)
                }, failure: { (dataTask, error) in
                    complete(clouds: nil, totalPage:"", flag: false)
            })

            }, failure: { (error) in
                complete(clouds: nil, totalPage:"", flag: false)
        })
    }
    
    func getDownloadSongs(complete: (downloads:[TCKTVDownload]?, flag:Bool)->()) {
        var params = [String: AnyObject]()
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        self.client?.MCGet(self.downloadPath, parameters: params, success: { (json) in
            var downloads = [TCKTVDownload]()
            for jsonDownload in json.arrayValue {
                let download = TCKTVDownload()
                download.config(jsonDownload)
                downloads.append(download)
            }
            complete(downloads: downloads, flag: true)
            }, failure: { (error) in
                complete(downloads: nil, flag: false)
        })
    }
    
    func getOrderedSongs(complete: (ordereds:[TCKTVPoint]?, flag:Bool)->()) {
        var params = [String: AnyObject]()
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        self.client?.MCGet(self.orderedPath, parameters: params, success: { (json) in
            var ordereds = [TCKTVPoint]()
            for jsonOrdered in json.arrayValue {
                let ordered = TCKTVPoint()
                ordered.config(jsonOrdered)
                ordereds.append(ordered)
            }
            complete(ordereds: ordereds, flag: true)
            }, failure: { (error) in
                complete(ordereds: nil, flag: false)
        })
    }
    
//    http://192.168.31.219:8080/TianChiServer/GetCloundList?path=mnt/sata/SOFMIT_DBBSM.db&words=？&language=？&py=？&singerName=？&sortType=？&pageSize=9
    func searchCloudSongs(keyword:String?, words:Int, page:Int, limit:Int, language:Int?, singer:String?, type:String?, complete: (clouds:[TCKTVCloud]?, totalPage:String, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!
        }
        if words > 0 {
            params["words"] = NSNumber(integer: words)
        }
        if language > 0 {
            params["language"] = NSNumber(integer: language!)
        }
        if singer?.characters.count > 0 {
            params["singerName"] = singer
        }
        if type?.characters.count > 0 {
            params["sortType"] = type
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        params["page"] = NSNumber(integer: page)
        params["pageSize"] = NSNumber(integer: limit)
        self.client?.MCGet(self.cloudPath, parameters: params, success: { (json) in
            self.pageClient?.GET(self.cloudPagePath, parameters: params, progress: nil, success: { (dataTask, resp) in
                var clouds = [TCKTVCloud]()
                for jsonCloud in json.arrayValue {
                    let cloud = TCKTVCloud()
                    cloud.config(jsonCloud)
                    clouds.append(cloud)
                }
                complete(clouds: clouds,totalPage: String(data: resp as! NSData, encoding: NSUTF8StringEncoding)!, flag: true)
                }, failure: { (dataTask, error) in
                    complete(clouds: nil, totalPage:"", flag: false)
            })
            
            }, failure: { (error) in
                complete(clouds: nil, totalPage:"", flag: false)
        })
    }

}
