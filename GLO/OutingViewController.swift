//
//  OutingViewController.swift
//  GLO
//
//  Created by Stephen Looney on 7/9/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import Foundation
import UIKit
import SocketIOClientSwift

class OutingViewController:UIViewController {
    
    ////// Testing out Socket.io
    let socket = SocketIOClient(socketURL: NSURL(string: "https://pure-caverns-99011.herokuapp.com")!, options: [.Log(true), .ForcePolling(true)])
    
    init() {
        super.init(nibName: nil, bundle: nil)
        print("In init for home page controller")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }

    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        print("close button pressed in OVC")
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load homebase")
        
        addHandlers()
        socket.connect()
        
    }
    
    
    @IBAction func postMessage(sender: AnyObject) {
        socket.emit("chatMessage", "YO HO HO, A PIRATES LIFE FER ME")
    }
    
    func addHandlers() {
        /*
         * Call incoming message handler upon receiving a msg
         */
        socket.on("chatMessage") {[weak self] data, ack in
            if let msg = data[0] as? String {
                //self?.handleReceiveMessage(msg)
                print("FUCK YEAHH HERES YER MESSAGE: ", msg)
            }
        }
        
        /*
         * Print a message when the socket has successfully connected
         */
        socket.on("connect") {data, ack in
            print("socket connected!!!")
        }
    }

    
    
}