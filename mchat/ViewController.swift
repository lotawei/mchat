//
//  ViewController.swift
//  mchat
//
//  Created by lotawei on 2019/3/29.
//  Copyright © 2019 lotawei. All rights reserved.
//

import UIKit
import SwiftyJSON
class ViewController: UIViewController {
    var  txtbuffs = ""
    var  pushtime = 2.0
    @IBOutlet weak var ipconfig: UITextField!
    @IBOutlet weak var btnone: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chanegHost()
        
      
      
        // Do any additional setup after loading the view.
    }
 
    @IBOutlet weak var lblname: UILabel!
    
    @IBOutlet weak var imgportait: UIImageView!
    
    @IBAction func changeip(_ sender: Any) {
      
        chanegHost()
    }
    func chanegHost()  {
        guard let  iptext = self.ipconfig.text else {
            return
        }
        let  spilts = iptext.components(separatedBy: ":")
        
        
        
        SocketClientManager.instance.setHost(spilts.first!, UInt16.init(spilts.last!)!)
    }
    @IBAction func connect(_ sender: Any) {
        
        
        guard let  txt = self.btnone.titleLabel?.text else {
            return
        }
        if   txt == "连接" {
            SocketClientManager.instance.connect({
                res in
                
                if res != nil  && res! == "forcedisconnect"{
           
                 
                    SweetAlert.init().showAlert(res!,subTitle:"错误",style: .error)
                    weak  var  weaksefl = self
                    weaksefl?.btnone.setTitle("连接", for: .normal)
                }
                    
                else if  (res != nil  && res! == "normaldisconnect") {
                    
                    weak  var  weaksefl = self
                    weaksefl?.btnone.setTitle("连接", for: .normal)
              
                }
                else{
                    
                    weak  var  weaksefl = self
                    weaksefl?.btnone.setTitle("断开", for: .normal)
                }
                
                
            })
        }
        else{
            SocketClientManager.instance.close()
            SweetAlert.init().showAlert("已断开与服务器的连接",subTitle:"",style: .error)
            weak  var  weaksefl = self
            weaksefl?.btnone.setTitle("连接", for: .normal)
        }
        
        
   
        
        
        
    }
    
    
    @IBOutlet weak var recievetxt: UITextView!
    @IBOutlet weak var txtsendmsg: UITextField!
    
    @IBAction func sendmsg(_ sender: Any) {
        
        guard let txt = self.txtsendmsg.text else {
            return
        }
        
        let datatjson  = txt.data(using: .utf8)
        SocketClientManager.instance.sendMsgByloading(datatjson!, {
            res in
            
             weak var  weakself = self
             weakself?.txtbuffs = res as! String
             weakself?.updateui()
        })
        
        
    }
    
   public  func  updateUserview(_ jsonstr:Any){
        
        let userinfo = UserItemPro.init(jsonstr)
    
    
        self.lblname.text = userinfo.userphone
        
        
    }
    
    
    func updateui(){
        
        self.recievetxt.text = self.txtbuffs
        
    }
    
    
    func gologin()  {
        
    }
    
    @IBAction func loginserver(_ sender: Any) {
        
        let   userinfo = UserItemPro.init()
        userinfo.userid = "lotawei"
        
        
        DataMessageCenter.sendLoginmsg(userinfo) { (data) in
            
            self.updateUserview(data)
           
            
            
        }
        
        
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
    }


}

