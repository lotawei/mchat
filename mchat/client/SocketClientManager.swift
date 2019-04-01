//
//  SocketClientManager.swift
//  mchat
//
//  Created by lotawei on 2019/3/30.
//  Copyright © 2019 lotawei. All rights reserved.
//

import Foundation
import UIKit
typealias   processfinishbolck = (_ data:Any) -> Void
typealias   connectBlock = (_ data:Bool) -> Void

class SocketClientManager:NSObject,GCDAsyncSocketDelegate{
    var connectres:connectBlock?
    var   sendmsgblock:processfinishbolck?
    var   recievemsgblock:processfinishbolck?
    static var  instance = SocketClientManager()
    var   writereadtimeout = 3.0
    var  serverip = "127.0.0.1"
    var  port:UInt16  = 10013
    private var  quene:DispatchQueue!
    private  var  socket:GCDAsyncSocket!
    override init() {
        super.init()
        quene = DispatchQueue.global()
        socket = GCDAsyncSocket.init(delegate: self, delegateQueue: quene)
    }
    
    @discardableResult  func  connect(_ connectblock:connectBlock?) -> Bool{
        self.connectres = connectblock
        if !socket.isConnected {
            do {
                try socket.connect(toHost: serverip, onPort: port)
            } catch let er {
                print(er)
                self.connectres?(false)
                return false
            }
        }
        
        return   socket.isConnected
    }
    func  close() {
        
        socket.disconnect()
        
    }
    
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("已连上服务器")
    }
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("读取数据")
        
        let  josnres = String.init(data: data, encoding: .utf8)
        
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
             self.sendmsgblock?(josnres!)
            print("发送完毕..已收到确认消息")
        }
        
        
    }
    
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if err != nil {
            print("连接失败")
        }
        else{
            print("正常断开")
        }
        self.connectres?(false)
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func reconnect(){
        if !socket.isConnected {
            connect(self.connectres)
        }
        
    }
    
    func   sendMsg(_ data:String,_ resblock:processfinishbolck?){
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            print("发送中........")
        }
    
        if !socket.isConnected {
            
             print("发送失败请重新连接服务器........")
            return
        }
        self.sendmsgblock = resblock
        let  data = data.data(using: .utf8)
        socket.write(data!, withTimeout: 3.0, tag: 1)
        socket.readData(withTimeout: -1, tag: 1)
    }
    
    
    
    
    
}
