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
    
    var client:MCJSONClient? = {
        var c:MCJSONClient?
        if let url = TCContext.sharedContext().serverAddress {
            c = MCJSONClient(baseURL: NSURL(string: String(format: "http://%@:8080/", url)))
        }
        return c
    }()
    
    func getSongsByName(keyword:String?, words:String, page:Int, complete: (songs:[TCKTVSong]?, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        params["words"] = words
        params["page"] = NSNumber(integer: page)
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            var songs = [TCKTVSong]()
            for jsonSong in json.arrayValue {
                let song = TCKTVSong()
                song.config(jsonSong)
                songs.append(song)
            }
            complete(songs: songs, flag: true)
            }, failure: { (error) in
                complete(songs: nil, flag: false)
        })
    }
    
    func getSongsByCategory(keyword:String?, type:String, page:Int, complete: (songs:[TCKTVSong]?, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        params["type"] = type
        params["page"] = NSNumber(integer: page)
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            var songs = [TCKTVSong]()
            for jsonSong in json.arrayValue {
                let song = TCKTVSong()
                song.config(jsonSong)
                songs.append(song)
            }
            complete(songs: songs, flag: true)
            }, failure: { (error) in
                complete(songs: nil, flag: false)
        })
    }
    
    func getSongsBySinger(keyword:String?, singer:String, page:Int, complete: (songs:[TCKTVSong]?, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        params["singer"] = singer
        params["page"] = NSNumber(integer: page)
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            var songs = [TCKTVSong]()
            for jsonSong in json.arrayValue {
                let song = TCKTVSong()
                song.config(jsonSong)
                songs.append(song)
            }
            complete(songs: songs, flag: true)
            }, failure: { (error) in
                complete(songs: nil, flag: false)
        })
    }
    
    func getSongsByLanguage(keyword:String?, language:Int, page:Int, complete: (songs:[TCKTVSong]?, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        params["language"] = NSNumber(integer: language)
        params["page"] = NSNumber(integer: page)
        self.client?.MCGet(self.path, parameters: params, success: { (json) in
            var songs = [TCKTVSong]()
            for jsonSong in json.arrayValue {
                let song = TCKTVSong()
                song.config(jsonSong)
                songs.append(song)
            }
            complete(songs: songs, flag: true)
            }, failure: { (error) in
                complete(songs: nil, flag: false)
        })
    }
    
    func getRankingSongs(keyword:String?, page:Int, complete: (songs:[TCKTVSong]?, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        params["page"] = NSNumber(integer: page)
        self.client?.MCGet(self.rankingPath, parameters: params, success: { (json) in
            var songs = [TCKTVSong]()
            for jsonSong in json.arrayValue {
                let song = TCKTVSong()
                song.config(jsonSong)
                songs.append(song)
            }
            complete(songs: songs, flag: true)
            }, failure: { (error) in
                complete(songs: nil, flag: false)
        })
    }

    func getCloudSongs(keyword:String?, page:Int, complete: (clouds:[TCKTVCloud]?, flag:Bool)->()) {
        var params = [String: AnyObject]()
        if keyword != nil {
            params["py"] = keyword!
        }
        params["path"] = "mnt/sata/SOFMIT_DBBSM.db"
        params["page"] = NSNumber(integer: page)
        self.client?.MCGet(self.cloudPath, parameters: params, success: { (json) in
            var clouds = [TCKTVCloud]()
            for jsonCloud in json.arrayValue {
                let cloud = TCKTVCloud()
                cloud.config(jsonCloud)
                clouds.append(cloud)
            }
            complete(clouds: clouds, flag: true)
            }, failure: { (error) in
                complete(clouds: nil, flag: false)
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
}
