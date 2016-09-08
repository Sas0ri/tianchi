//
//  TCMovie.swift
//  tc
//
//  Created by Sasori on 16/9/8.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCMovie: NSObject {
    var title:String!
    var info:String!
    var movieId:Int64!
    
    func config(json:JSON) {
        self.title = json["title"].stringValue
        self.info = json["info"].stringValue
        self.movieId = json["id"].int64Value
    }
}
