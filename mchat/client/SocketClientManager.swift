//
//  SocketClientManager.swift
//  mchat
//
//  Created by lotawei on 2019/3/30.
//  Copyright © 2019 lotawei. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import NVActivityIndicatorView
typealias   processfinishbolck = (_ data:Any) -> Void
typealias   connectBlock = (_ data:String?) -> Void

class SocketClientManager:NSObject,GCDAsyncSocketDelegate{
    public var connectres:connectBlock?
    public  var   sendmsgblock:processfinishbolck?
    public   var   recievemsgblock:processfinishbolck?
    public   static var  instance = SocketClientManager()
    private let   heartbyte = "isline"
    //读写超时
    private var   writereadtimeout = 3.0
    //重连次数最大
   
    
    
    private  let   pushcount = 5;
    //当前重连次数
    private  var   curpushindex = 0;
    //heartbeat定时器
    private  var   heartbeatTimer:Timer!
    private  let   heartTimer = 3.0
    
    
    //重连 定时器
    private  var  reconnectTimer:Timer?
    //重连 间隔
    private  var  pushTime = 2.0
    
    
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
            socket.autoDisconnectOnClosedReadStream = true
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
    
    
    
    func socket(_ sock: GCDAsyncSocket, didConnectTo url: URL) {
       
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
        print("已连接服务器")
        DispatchQueue.main.async {
            self.curpushindex = 0
            
            
            
            if self.connectres != nil {
                self.connectres!(nil)
            }
            
            
            if   self.heartbeatTimer == nil {
                
                self.heartbeatTimer = Timer.init(timeInterval: self.heartTimer, target: self, selector: #selector(self.sendHearbeat), userInfo: nil, repeats: true)
                RunLoop.current.add(self.heartbeatTimer, forMode: .default)
                RunLoop.current.add(self.heartbeatTimer, forMode: .tracking)
                
            }
            if  self.reconnectTimer != nil {
                
                self.pushTime = 0
                self.reconnectTimer?.invalidate()
                self.reconnectTimer = nil
            }
        }
      
        
        
    }
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("读取数据")
        DispatchQueue.main.async {
        let  josnres = String.init(data: data, encoding: .utf8)
        
       
        if   josnres != nil && josnres! == self.heartbyte{
            
             print("保持心跳中....")
             return
        }
          
            self.dismissLoadingView()
            self.sendmsgblock?(josnres!)
            print("发送完毕..已收到确认消息")
        }
        
        
    }
    @objc func  sendHearbeat() {
        
        
        if  self.socket != nil && self.socket.isConnected{
            let  heartdata = heartbyte.data(using: .utf8)
            
            
            self.socket.write(heartdata!, withTimeout: writereadtimeout, tag: 1)
            self.socket.readData(withTimeout: -1, tag: 1)
        }
        
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
        DispatchQueue.main.async {
            
        if err != nil {
            
            print("异常断开")
            print(err!.localizedDescription)
            
            if  self.reconnectTimer == nil {
                self.reconnectTimer = Timer.init(timeInterval: self.pushTime, repeats: true, block: { (timer) in
                    
                    if   self.curpushindex < self.pushcount {
                        self.pushTime = self.pushTime * 2.0
                        timer.fireDate = Date.init(timeIntervalSinceReferenceDate: self.pushTime)
                        self.curpushindex = self.curpushindex + 1
                        //
                        print("尝试第\(self.curpushindex)次重连.......")
                        self.reconnect()
                        
                    }else{
                        print("彻底连不上.....尽力了")
                        self.pushTime = 2.0
                        timer.invalidate()
                        
                    }
                    
                    
                    
                })
                
                
                RunLoop.current.add(self.reconnectTimer!, forMode: .default)
                RunLoop.current.add(self.reconnectTimer!, forMode: .tracking)
                
            }
            
            
            if self.connectres != nil{
     
                    self.connectres!("forcedisconnect")
                
                
            }
            
            
        }
        else{
            print("正常断开")
            self.curpushindex = 0
            self.heartbeatTimer.invalidate()
            self.reconnectTimer?.invalidate()
            self.reconnectTimer = nil
            self.heartbeatTimer = nil
            
            if self.connectres != nil{
                DispatchQueue.main.async {
                    self.connectres!("normaldisconnect")
                }
                
            }
            
        }
        
        //程序处于前台才尝试重连
        if !self.isforbackground() {
            
            
            
            
        }
      
        
        }
        
        
        
    }
    
    func reconnect(){
        if self.socket != nil && !self.socket.isConnected {
            DispatchQueue.main.async {
                self.connect(self.connectres)
            }
            
        }
      
        
    }
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        
        DispatchQueue.main.async {
            self.dismissLoadingView()
            
        }
        
        
    }
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        return  writereadtimeout
    }
    
    
    
    
    func   sendMsgByloading(_ data:Data,_ resblock:processfinishbolck?){
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
            
            
            socket.write(data, withTimeout: writereadtimeout, tag: 1)
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
    
    
    func  isforbackground() -> Bool{
        
        let curstatus = UserDefaults.standard.object(forKey: "Statu") as? String
       
        guard let  res = curstatus else {
            return  false
        }
        return   res == "foreground"
        
    }
    
    
}

