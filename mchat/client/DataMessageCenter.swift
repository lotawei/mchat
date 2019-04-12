//
//  RecieveDataManager.swift
//  mchat
//
//  Created by lotawei on 2019/3/30.
//  Copyright © 2019 lotawei. All rights reserved.
//

import Foundation
import SwiftyJSON

@objc public protocol   Serialdatapro:NSObjectProtocol {
    @objc   func  serialdata() -> Data?
    @objc  func   unserialdata(_ data:Data) -> [String:Any]?
}

class BaseAuthInfo:NSObject{
    
    let   authcode = "md5xxx"
    let   checknum = "lotawei"
    let  device_id = "ajsdk1askd#!D"
    var  messagename = "BaseAuthInfo"
}


class UserItemPro:BaseAuthInfo,Serialdatapro {
    
    var  userid:String = ""
    var  username:String = ""
    var  usericon:String = ""
    var  userlevelvip:String = ""
    var  userphone:String = ""
    override init() {
        super.init()
        messagename = "userlogin"
    }
    func serialdata() -> Data? {
        var   dicvalue = [String:Any]()
        dicvalue["messagename"] = messagename
        dicvalue["userid"] = userid
        dicvalue["username"] = username
        dicvalue["usericon"] = usericon
        dicvalue["userlevelvip"] = userlevelvip
        dicvalue["userphone"] = userphone
        let  jsondata = JSON.init(dicvalue)
        do{
            let   transdata = try jsondata.rawData()
            return transdata
        }
        catch (let  err){
            
            print(err)
        }
        
        
        return  nil
        
    }
    
    func unserialdata(_ data: Data) -> [String:Any]?{
        do {
            let   jsondata = try JSON.init(data: data)
            return jsondata.dictionaryObject
        }catch(let err){
            
            print(err)
            return  nil
        }
        
        
    }
    
    
}

class  DataMessageCenter {
    
    public  static  var  instance = DataMessageCenter()
    
    public   static  func  sendLoginmsg(_ usermap:UserItemPro,_ resblock:@escaping processfinishbolck){
          SocketClientManager.instance.sendMsgByloading(usermap.serialdata()!, resblock)
        
        
    }
    
    
}

