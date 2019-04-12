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
    @objc  optional func  serialdata() -> Data?
    @objc optional  func   unserialdata(_ data:Data) -> [String:Any]?
    
    @objc optional  func   responseDic() -> [String:Any]?
}

class BaseAuthInfo:NSObject{
    
    let   authcode = "md5xxx"
    let   checknum = "lotawei"
    let  device_id = "ajsdk1askd#!D"
    var  messagename = "BaseAuthInfo"
}

class  Responseinfo:NSObject,Serialdatapro{
   
    
    public   var  code:Int!
    public  var   msg:String!
    public var   bodydata:String!
    public static  func  makeerrresponse(_ code:Int,_ msg:String ) -> Responseinfo{
        let   responseinfo = Responseinfo.init()
        responseinfo.code = code
        responseinfo.msg = msg
        responseinfo.bodydata = ""
        return  responseinfo
        
    }
    func serialdata() -> Data? {
        var  jsonres = [String:Any]()
        jsonres["code"] = code
        jsonres["msg"] = msg
        jsonres["bodydata"] = bodydata
        
        let  json = JSON.init(jsonres)
        do{
            let resdta = try json.rawData()
            return  resdta
        }catch{
            
            return  nil
        }
        
    }
    func responseDic() -> [String : Any]? {
        return   JSON.init(self).dictionaryObject
    }
    
    
}
class UserItemPro:BaseAuthInfo,Serialdatapro {
    
   public  var  userid:String = ""
   public var  username:String = ""
   public var  usericon:String = ""
   public var  userlevelvip:String = ""
  public  var  userphone:String = ""
    override init() {
        super.init()
        messagename = "userlogin"
    }
    
    
    convenience init(_ jsondata:Any) {
        self.init()
        messagename = "userlogin"
        let str = JSON.init(jsondata)
        let  jsonmap = DataMessageCenter.getDictionaryFromJSONString(jsonString: str.string!)
        self.userid = jsonmap["userid"] as! String
      
         self.username = jsonmap["username"] as! String
         self.usericon = jsonmap["usericon"] as! String
         self.userlevelvip = jsonmap["userlevelvip"] as! String
         self.userphone = jsonmap["userphone"] as! String
        
        
        
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
    
    /// JSONString转换为字典
    ///
    /// - Parameter jsonString: <#jsonString description#>
    /// - Returns: <#return value description#>
  static public  func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
        
        
    }
    
    /**
     字典转换为JSONString
     
     - parameter dictionary: 字典参数
     
     - returns: JSONString
     */
   static public func getJSONStringFromDictionary(dictionary:NSDictionary) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
    let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData?
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
        
    }
}

