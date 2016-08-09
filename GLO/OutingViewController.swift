//
//  OutingViewController.swift
//  GLO
//
//  Created by Stephen Looney on 7/9/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SocketIOClientSwift
import GoogleMaps

class OutingViewController:UIViewController {
    
    ////// Testing out Socket.io
    let socket = SocketIOClient(socketURL: NSURL(string: "https://glo-app.herokuapp.com")!, options: [.Log(true), .ForcePolling(true)])
    
    @IBOutlet weak var mapView: GMSMapView!
    
    
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
        
        mapView.layer.cornerRadius = 25.0
        
        // Add a google Map View
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        
        // Get current Outing lat and lng as floats
        
        //TODO: This lat and lng data should pull from the backend so that all users get the same data
        
        let lat = NSUserDefaults.standardUserDefaults().objectForKey("currentOutingLat") as! Double
        let lng = NSUserDefaults.standardUserDefaults().objectForKey("currentOutingLng") as! Double
        
        print("CURRENT OUTING LAT: ", lat, " AND LNG: ", lng)
        
        let camera = GMSCameraPosition.cameraWithLatitude(lat, longitude: lng, zoom: 3.0)
        self.mapView.camera = camera
        //mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: camera)
        mapView.myLocationEnabled = true
        //view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        marker.title = "Outing Destination"
        marker.snippet = "Party Time"
        marker.map = mapView
        
        
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