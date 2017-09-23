//
//  TCContext.swift
//  tc
//
//  Created by Sasori on 16/6/20.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

let LightStatusChangedNotification = "LightStatusChangedNotification"

let _sharedContext:TCContext = TCContext()

class TCContext: NSObject, TCSocketManagerDelegate, UIAlertViewDelegate {
    
    static let TCShowAddressInputViewNotification = "TCShowAddressInputViewNotification"

    
    static let port:UInt16 = 9594

    static let useK800SKey = "useK800SKey"
    
    var useK800S:Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: TCContext.useK800SKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: TCContext.useK800SKey)
        }
    }
    
    class func sharedContext() -> TCContext {
        return _sharedContext
    }
    
    var serverAddress:String? {
        didSet {
            if let sa = serverAddress {
                UserDefaults.standard.set(sa, forKey: "SA")
                self.socketManager.address = sa
            }
        }
    }
    
    var ktvServerAddress:String? {
        didSet {
            if let sa = ktvServerAddress {
                UserDefaults.standard.set(sa, forKey: "KSA")
            }
        }
    }
    
    var socketManager = TCSocketManager()
    var verifyAlertView: UIAlertView?

    enum AlertTag: Int {
        case address = 501
        case verify = 502
        case both = 503
        case reconnect = 504
    }
    
    override init() {
        super.init()
        UISearchBarAppearance.setupSearchBar()
        self.socketManager.delegate = self
        self.socketManager.heartbeatCmd = 2202
        if tcVersion == .full {
            self.socketManager.startHeartbeatCmd = 2201
        }
        self.serverAddress = UserDefaults.standard.object(forKey: "SA") as? String
        if tcVersion == .full {
            self.ktvServerAddress = UserDefaults.standard.object(forKey: "KSA") as? String
        }

        self.socketManager.port = TCContext.port

        if self.serverAddress != nil {
            self.socketManager.address = self.serverAddress
            self.socketManager.connect()
        } else {
            self.showInputAddress()
        }
    }
    
    func disconnect() {
        NSObject.cancelPreviousPerformRequests(withTarget: self.socketManager)
        self.socketManager.disConnect()
        UIApplication.shared.keyWindow?.rootViewController?.view.hideHud()
    }
    
    func didConnect() {
        if tcVersion == .full {
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: TCAppsContext.CanLoadAppsNotification), object: self)
        }
    }
    
    func didReceivePayload(_ payload: TCSocketPayload) {
        if payload.cmdType == 2112 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TCAppsContext.DidLoadAppsNotification), object: payload.cmdContent!.stringValue)
        }
        
        if tcVersion == .full && payload.cmdType == 2202 && payload.cmdContent?.string != nil {
            NotificationCenter.default.post(name: Notification.Name(rawValue: LightStatusChangedNotification), object: (payload.cmdContent?.string)!)
        }
    }
    
    func connectFailed() {
        let alertView = UIAlertView(title: "", message: "无法连接服务器", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "重新连接", "输入服务器地址")
        alertView.tag = AlertTag.reconnect.rawValue
        alertView.show()
    }
    
    func didDisconnect() {
        let alertView = UIAlertView(title: "", message: "与服务器断开连接", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "重新连接", "输入服务器地址")
        alertView.tag = AlertTag.reconnect.rawValue
        alertView.show()
    }
    
    func didHandShake() {
    }
    
    func showBoth() {
        let alertView = UIAlertView(title: "", message: "请选择", delegate: self, cancelButtonTitle: "重新输入服务器地址", otherButtonTitles: "重新输入验证码")
        alertView.tag = AlertTag.both.rawValue
        alertView.show()
    }
    
    func showInputAddress() {
        if tcVersion == .v800s {
            let alertView = UIAlertView(title: nil, message: "输入服务器地址", delegate: self, cancelButtonTitle: "确定")
            alertView.alertViewStyle = .plainTextInput
            alertView.tag = AlertTag.address.rawValue
            alertView.show()
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:TCContext.TCShowAddressInputViewNotification), object: self)
        }
    }
    
    func showVerify() {
        let alertView = UIAlertView(title: "", message: "请输入验证码", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "确定")
        alertView.alertViewStyle = .plainTextInput
        alertView.tag = AlertTag.verify.rawValue
        alertView.show()
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.tag == AlertTag.address.rawValue {
            self.serverAddress = alertView.textField(at: 0)?.text
            self.socketManager.address = self.serverAddress
            self.socketManager.port = TCContext.port
            self.socketManager.connect()
        } else if alertView.tag == AlertTag.verify.rawValue {
            let textField = alertView.textField(at: 0)
            let payload = TCSocketPayload()
            payload.cmdType = 1900
            payload.cmdContent = JSON(NSNumber(value: Int(textField!.text!)! as Int))
            self.socketManager.sendPayload(payload)
            
            let alertView = UIAlertView(title: "", message: "正在验证...", delegate: nil, cancelButtonTitle: nil)
            let aiView = UIActivityIndicatorView(frame: CGRect(x: 125.0, y: 40, width: 30.0, height: 30.0))
            aiView.activityIndicatorViewStyle = .whiteLarge;
            aiView.startAnimating()
            aiView.color = UIColor.black
            
            alertView.setValue(aiView, forKey: "accessoryView")
            alertView.show()
            self.verifyAlertView = alertView
        } else if alertView.tag == AlertTag.both.rawValue {
            if buttonIndex == 1 {
                self.showInputAddress()
            } else if buttonIndex == 2 {
                self.showVerify()
            }
        } else if alertView.tag == AlertTag.reconnect.rawValue {
            if buttonIndex == 1 {
                self.socketManager.connect()
            } else if buttonIndex == 2 {
                self.showInputAddress()
            }
        }
    }
}
