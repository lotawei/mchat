//
//  ViewController.swift
//  mchat
//
//  Created by lotawei on 2019/3/29.
//  Copyright © 2019 lotawei. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var  txtbuffs = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func connect(_ sender: Any) {
        
        SocketClientManager.instance.connect({ res in
            if res{
               print("ui 界面去刷新已经成功了")
               
                
            }else{
            print("ui 与服务器断开连接了")
            }
        })
        
        
        
        
    }
    
    @IBOutlet weak var recievetxt: UITextView!
    @IBOutlet weak var txtsendmsg: UITextField!
    
    @IBAction func sendmsg(_ sender: Any) {
        
        guard let txt = self.txtsendmsg.text else {
            return
        }
        
        
        SocketClientManager.instance.sendMsg(txt, {
            res in
            
             weak var  weakself = self
             weakself?.txtbuffs = res as! String
             weakself?.updateui()
        })
        
        
    }
    func updateui(){
        
        self.recievetxt.text = self.txtbuffs
        
    }
    
    
    func gologin()  {
        
    }
    
    @IBAction func close(_ sender: Any) {
        
        SocketClientManager.instance.close()
        
        
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          
        
        
    }


}

