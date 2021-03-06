//
//  VersionDefine.swift
//  tc
//
//  Created by Sasori on 2016/10/19.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import Foundation

enum TCVersion:Int {
    case v800s = 1
    case full = 2
}

#if v800s
let tcVersion:TCVersion = .v800s
#else
let tcVersion:TCVersion = .full
#endif
