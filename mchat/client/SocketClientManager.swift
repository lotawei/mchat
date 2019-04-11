//
//  SocketClientManager.swift
//  mchat
//
//  Created by lotawei on 2019/3/30.
//  Copyright © 2019 lotawei. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
typealias   processfinishbolck = (_ data:Any) -> Void
typealias   connectBlock = (_ data:String?) -> Void

class SocketClientManager:NSObject,GCDAsyncSocketDelegate{
    var connectres:connectBlock?
    var   sendmsgblock:processfinishbolck?
    var   recievemsgblock:processfinishbolck?
    public   static var  instance = SocketClientManager()
    
    var   connected = false
    var   writereadtimeout = 3.0
   
    var  serverip = "localhost"
    var  port:UInt16  = 10013
    private var  quene:DispatchQueue!
    private  var  socket:GCDAsyncSocket!
    
    lazy   var   loadingActivityView:NVActivityIndicatorView = NVActivityIndicatorView.init(frame: CGRect.zero)
    
    override init() {
        super.init()
        
    }
    func setHost(_ ip:String, _ port:UInt16 )
    {
        self.serverip = ip
        
        self.port = port
    }
  func  connect(_ connectblock:connectBlock?) {
        if socket == nil {
            quene = DispatchQueue.global()
            socket = GCDAsyncSocket.init(delegate: self, delegateQueue: quene)
        }
        self.connectres = connectblock
    
        if !socket.isConnected {
           
         
            do {
                try socket.connect(toHost: serverip, onPort: port, viaInterface: "", withTimeout: 5.0)
            } catch let _ {
                
                
                
            }
        }
        
    
    }
    func  close() {
        if socket != nil && socket.isConnected {
            socket.disconnect()
        }
        
        
        
    }
    func showLoadingView() {
        let window = UIApplication.shared.delegate?.window
        guard let  superview = window! else {
            return
        }
        loadingActivityView.type = .orbit
        loadingActivityView.color = UIColor.black
        if (loadingActivityView.superview == nil){
            superview.addSubview(loadingActivityView)
            
        }
        
        loadingActivityView.frame = CGRect.init(x: superview.frame.size.width/2.0-25, y: superview.frame.size.height/2.0 + 20, width: 50, height: 50)
        loadingActivityView.startAnimating()
        
        
    }
    
    func dismissLoadingView() {
        loadingActivityView.stopAnimating()
        
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
        print("已连接服务器")
        DispatchQueue.main.async {
            if self.connectres != nil {
                self.connectres!(nil)
            }
        }
        
    }
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("读取数据")
        let  josnres = String.init(data: data, encoding: .utf8)
        DispatchQueue.main.async {
            self.dismissLoadingView()
            self.sendmsgblock?(josnres!)
            print("发送完毕..已收到确认消息")
        }
        
        
    }
    
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if err != nil {
              print("异常断开")
             print(err!.localizedDescription)
            if self.connectres != nil{
                DispatchQueue.main.async {
                    self.connectres!("forcedisconnect")
                }
                
            }

            
        }
        else{
              print("正常断开")
            if self.connectres != nil{
                DispatchQueue.main.async {
                    self.connectres!("normaldisconnect")
                }
                
            }
            
        }
        
       
        
    }
    
    func reconnect(){
        if socket != nil && !socket.isConnected  {
            DispatchQueue.main.async {
                 self.connect(self.connectres)
            }
           
        }
        
    }
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        return  writereadtimeout
    }
 
    func   sendMsg(_ data:String,_ resblock:processfinishbolck?){
        if socket != nil  && socket.isConnected {
        self.sendmsgblock = resblock
        DispatchQueue.main.async {
            self.showLoadingView()
            print("发送中........")
        }
        
        if !socket.isConnected {
            
            print("发送失败请重新连接服务器........")
            DispatchQueue.main.async {
                self.dismissLoadingView()
                print("发生异常........")
            }
            
            return
        }
      
        let  data = data.data(using: .utf8)
        socket.write(data!, withTimeout: writereadtimeout, tag: 1)
        socket.readData(withTimeout: -1, tag: 1)
        }else{
            
            resblock?("网络未连接")
            DispatchQueue.main.async {
                self.dismissLoadingView()
                print("发生异常........")
            }
            
            return
        }
    }
    
    
    
    
    
}

