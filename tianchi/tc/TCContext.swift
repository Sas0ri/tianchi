//
//  TCContext.swift
//  tc
//
//  Created by Sasori on 16/6/20.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

var _sharedContext:TCContext = TCContext()

class TCContext: NSObject, TCSocketManagerDelegate, UIAlertViewDelegate {
    
    var serverAddress:String?
    var socketManager = TCSocketManager()
    var verifyAlertView: UIAlertView?
    
    enum AlertTag: Int {
        case Address = 501
        case Verify = 502
        case Both = 503
    }
    
    static func sharedContext() -> TCContext {
        return _sharedContext
    }
    
    override init() {
        super.init()
        self.socketManager.delegate = self
    }
    
    func didReceivePayload(payload: TCSocketPayload) {
        if payload.cmdType == "1900" {
            self.showVerify()
            return
        }
        if payload.cmdType == "1901" {
            self.verifyAlertView?.dismissWithClickedButtonIndex(0, animated: false)
            return
        }
        if payload.cmdType == "1902" {
            self.showBoth()
            return
        }
        TCKTVPayloadHandler.sharedHandler().handlePayload(payload)
    }
    
    func didDisconnect() {
        let alertView = UIAlertView(title: nil, message: "与服务端断开连接", delegate: nil, cancelButtonTitle: "确定")
        alertView.show()
    }
    
    func showBoth() {
        let alertView = UIAlertView(title: "", message: "请选择", delegate: self, cancelButtonTitle: "重新输入IP地址", otherButtonTitles: "重新输入验证码")
        alertView.tag = AlertTag.Both.rawValue
        alertView.show()
    }
    
    func showInputAddress() {
        let alertView = UIAlertView(title: nil, message: "输入服务端地址", delegate: self, cancelButtonTitle: "确定")
        alertView.alertViewStyle = .PlainTextInput
        alertView.tag = AlertTag.Address.rawValue
        alertView.show()
        
    }
    
    func showVerify() {
        let alertView = UIAlertView(title: "", message: "请输入验证码", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "确定")
        alertView.alertViewStyle = .PlainTextInput
        alertView.tag = AlertTag.Verify.rawValue
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == AlertTag.Address.rawValue {
            self.serverAddress = alertView.textFieldAtIndex(0)?.text
        } else if alertView.tag == AlertTag.Verify.rawValue {
            let textField = alertView.textFieldAtIndex(0)
            let payload = TCSocketPayload()
            payload.cmdType = "1900"
            payload.cmdContent = textField!.text
            self.socketManager.sendPayload(payload)
            
            let alertView = UIAlertView(title: "", message: "正在验证...", delegate: nil, cancelButtonTitle: nil)
            let aiView = UIActivityIndicatorView(frame: CGRectMake(125.0, 40, 30.0, 30.0))
            aiView.activityIndicatorViewStyle = .WhiteLarge;
            aiView.startAnimating()
            aiView.color = UIColor.blackColor()
            
            alertView.setValue(aiView, forKey: "accessoryView")
            alertView.show()
            self.verifyAlertView = alertView
        } else if alertView.tag == AlertTag.Both.rawValue {
            if buttonIndex == 0 {
                self.showInputAddress()
            } else if buttonIndex == 1 {
                self.showVerify()
            }
        }
    }
}
