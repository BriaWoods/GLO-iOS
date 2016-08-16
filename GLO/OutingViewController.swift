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
import Parse
//import CoreLocation

class OutingViewController:UIViewController {
    
    // Wu Tang Demo View
    let members = WuTang.all()
    
    
    // Member Array which will hold their location, name, an image for the outing and their marker, and their current status (safe, uncomfortable, or emergency)
    var memberDict:[String:Member] = [:]
    
    
    
    ////// Testing out Socket.io
    let socket = SocketIOClient(socketURL: NSURL(string: "https://glo-app.herokuapp.com")!, options: [.Log(true), .ForcePolling(true)])
    @IBOutlet weak var memberScrollView: UIScrollView!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var homeSafeButton: UIButton!
    @IBOutlet weak var uncomfortableButton: UIButton!
    @IBOutlet weak var emergencyButton: UIButton!
    
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
        
        homeSafeButton.layer.borderWidth = 2.0
        homeSafeButton.layer.borderColor = UIColor.greenColor().CGColor
        homeSafeButton.layer.cornerRadius = 8.0
        
        uncomfortableButton.layer.borderWidth = 2.0
        uncomfortableButton.layer.borderColor = UIColor.yellowColor().CGColor
        uncomfortableButton.layer.cornerRadius = 8.0
        
        emergencyButton.layer.borderWidth = 2.0
        emergencyButton.layer.borderColor = UIColor.redColor().CGColor
        emergencyButton.layer.cornerRadius = 8.0
        
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
    
    override func viewWillAppear(animated: Bool) {
        
        // Prep the arrival of the Wu Tang Clan
        if memberScrollView.subviews.count < members.count {
            memberScrollView.viewWithTag(0)?.tag = 1000 //prevent confusion when looking up images
            setupList()
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        // Disconnect from the socket when the view will disappear (in the final version, you actually will never disconnect from the event until the event is concluded
        socket.disconnect()
    }
    
    
    @IBAction func postMessage(sender: AnyObject) {
        socket.emit("chatMessage", "YO HO HO, A PIRATES LIFE FER ME")
    }
    
    @IBAction func emitLocation(sender: AnyObject) {
        // Emit my location to everyone connected to the socket.
        
        let currentUser = PFUser.currentUser()
        
        if (currentUser != nil) {
            let userName = currentUser!.username
            
            socket.emit("emitLocation", userName!, -18.39, -41.38)
        }
    }
    
    
    
    // MARK: Map Live-Updating Methods
    
    func updateMarkerCoords(userName:String ,lat:Double, lon:Double) {
        
        print("updating ", userName, "'s", " marker to lat: ", lat, " and lon: ", lon)
        
        // Am going to need to make a subclass to represent a user on the map, so that I can create a user when they first connect, access their marker object, and update it at an inteval
        
        var updatingMember = memberDict[userName]
        updatingMember!.location = CLLocationCoordinate2D.init(latitude: lat, longitude: lon)
        
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
            
            // TODO: After connecting, emit user data (userName, clientID,  here
            let currentUser = PFUser.currentUser()
            
            self.socket.emit("newUser", currentUser!.username!, "The Chef", "ShimmyShimmyYa")
            
        }
        
        /*
         * Print a message showing the clientID, and their lat and lon if it was passed with socket.io
         */
        socket.on("updateLocation") {data, ack in
            print("Received Update Location message!")
            
            if let userName = data[0] as? String {
            print("FERK YERH heres the clientID: ", userName)
            
                if let lat = data[1] as? Double {
                
                    if let lon = data[2] as? Double {
                        
                        print("and clientLat: ", lat)
                        print("and clientLon: ", lon)
                    
                    
                        // Update Client location since all data was passed successfully
                        // Get the clientID, access that entry in memberDict, then update that members marker
                        self.updateMarkerCoords(userName, lat: lat, lon: lon)
                    }
                }
            }
            
            // This is where I will update the specific user's lat and lon to where they are. The number needs to be precise to avoid jumping around of the user's pin due to a silly thing like rounding.
            
            // TODO: Update the user's location
            
        }
        
        socket.on("newUser") {data, ack in
            
            // TODO: Create a Member struct with the user's data, then add it to the Outing's member array
            
             // This will actually be the username property
            print("adding a new user to the dict")
            
            var newMember = Member.init(mapView:self.mapView)
            newMember.clientID = data[0] as! String
            newMember.name = data[1] as! String
            newMember.description = data[2] as! String
            
            // TODO: Add in GET for pulling the newUser's profile image from Parse, then once that is finished, set the profile pic as the member's "user image" property, then add that member to the memberDict on completion of pulling the image.
            
            self.memberDict[newMember.clientID] = newMember
        }
    }

    
    // MARK: Wu Tang Scroll View Positioning
    func setupList() {
        print("Setup List Items")
        for i in 0 ..< members.count {
            
            //create image view
            let imageView  = UIImageView(image: UIImage(named: members[i].image))
            imageView.tag = i
            imageView.contentMode = .ScaleAspectFill
            imageView.userInteractionEnabled = true
            imageView.layer.cornerRadius = 20.0
            imageView.layer.masksToBounds = true
            memberScrollView.addSubview(imageView)
            
            //attach tap detector
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("didTapImageView:")))
        }
        
        memberScrollView.backgroundColor = UIColor.clearColor()
        positionListItems()
    }
    
    //position all images inside the list
    func positionListItems() {
        print("Posistion List Items")
        let ratio = view.frame.size.height / view.frame.size.width
        print("ratio:", ratio)
        let itemHeight: CGFloat = memberScrollView.frame.height * 1.0
        let itemWidth: CGFloat = itemHeight / ratio
        
        let horizontalPadding: CGFloat = 10.0
        memberScrollView.contentSize = CGSize(
            width: CGFloat(members.count) * (itemWidth + horizontalPadding) + horizontalPadding,
            height:  0)
        print(members)
        for i in 0 ..< members.count {
            let imageView = memberScrollView.viewWithTag(i) as! UIImageView
            imageView.frame = CGRect(
                x: CGFloat(i) * itemWidth + CGFloat(i+1) * horizontalPadding, y: 0.0,
                width: itemWidth, height: itemHeight)
            print(i, imageView.frame)
        }
        
    }

    func didTapImageView(sender: AnyObject) {
        print("tapped the image")
        
        // TODO: Send the location of the user whose image was tapped, which could them animate the marker image on the map somehow. Currently this will just display raekwon on the map
        
        emitLocation(sender)
    }
    
}


struct Member {
    
    var clientID = ""
    var name = ""
    var description = "Chef in the kitchen cookin' up with the crimeys"
    
    var userImage = UIImage(named: "Raekwon")?.markerPinMode
    
    var marker:GMSMarker?
    var currentMapView:GMSMapView
    
    var location:CLLocationCoordinate2D? = nil {
        didSet {
            // When setting the location, apply this location to the users marker and update it
            if let newLocation = location {
               
                if let marker = marker {
                    print("Updating ", name, "'s marker's location")
                    marker.position = newLocation
                } else {
                    print("initializing the marker then drawing it")
                    // If a marker hasn't been drawn yet, initialize it then set the location and map
                    marker = GMSMarker(position:newLocation)
                    
                    marker!.title = name
                    marker!.icon = userImage
                    marker!.map = currentMapView
                }
                
                
            }
        }
    }
    
    init(mapView:GMSMapView) {
        // When initializing the Member, a map should be provided so that it is known where to draw their location marker
        currentMapView = mapView
    }
}

// Extending UIImage to allow for setting a marker pin-sized image from the original image used
extension UIImage {
    /*
     * To use markerPinMode, after initializing the UIImage call image.markerPinMode
     */
    var markerPinMode: UIImage? {
        
        let oSize = size
        let newRect = CGRectMake(0, 0, 40, 40)
        
        let ratio = max(newRect.size.width / oSize.width, newRect.size.height / oSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newRect.size, false, 0.0)
        
        let path = UIBezierPath(roundedRect: newRect, cornerRadius: 20.0)
        
        path.addClip()
        
        var projectRect = CGRect()
        projectRect.size.width = ratio * oSize.width
        projectRect.size.height = ratio * oSize.height
        projectRect.origin.x = (newRect.size.height - projectRect.size.height) / 2.0
        
        let image = self
        image.drawInRect(projectRect)
        
        let markerPinImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return markerPinImage
    }
}

