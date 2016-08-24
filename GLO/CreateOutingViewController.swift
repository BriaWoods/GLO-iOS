//
//  CreateOutingViewController.swift
//  GLO
//
//  Created by Stephen Looney on 7/10/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import GoogleMaps
import Alamofire
import Parse


class CreateOutingViewController:UIViewController,UIScrollViewDelegate, UITextFieldDelegate, GMSAutocompleteViewControllerDelegate {
    
    let members = WuTang.all()
    
    var homeBaseMarker:GMSMarker?
    var didSetDestination = false
    
    // Need a pointer to the HomePageViewController instance, so that I can add this newly created outing to the HPVC's outing array
    var hpvc:HomePageViewController?
    var newOuting:OutingObject = GLODataStore.sharedInstance.createOuting()
    
    @IBOutlet var outingNameTextField: UITextField!
    @IBOutlet var addMemberButton: UIButton!
    @IBOutlet var memberScrollView: UIScrollView!
    //@IBOutlet var destinationTextField: UITextField!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet var curfewTimePicker: UIDatePicker!
    @IBOutlet var createOutingButton: UIButton!
    
    @IBOutlet weak var createOutingLabel: ShadowLabel!
    @IBOutlet weak var addMemberLabel: ShadowLabel!
    @IBOutlet weak var curfewLabel: ShadowLabel!
    
    var titleLabelArray:[UILabel] = []
    
    var dismissBlock:(() -> Void)! = {}
    
    var postData:NSData? = NSData.init()
    
    
    
    // TODO: Will need to add in method to handle clicking the "Add member" button. This will pull all of the current user's friends from Parse, then display them in a table view and allow for selection which users you want to include on the outing.
    
    
    init() {
       super.init(nibName: nil, bundle: nil)
        print("init")
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        titleLabelArray = [createOutingLabel, addMemberLabel, curfewLabel]
        
        addMemberButton.layer.cornerRadius = 15.0
        createOutingButton.layer.cornerRadius = 8.0
        createOutingButton.layer.borderColor = UIColor.whiteColor().CGColor
        createOutingButton.layer.borderWidth = 1.0
        createOutingButton.layer.shadowRadius = 8.0
        createOutingButton.layer.shadowColor = UIColor.whiteColor().CGColor
        
        
        curfewTimePicker.setValue(UIColor.whiteColor(), forKey: "textColor")
        curfewTimePicker.sendAction("setHighlightsToday:", to: nil, forEvent: nil)
        
        outingNameTextField.delegate = self
        //destinationTextField.delegate = self
        
        
        
        
        outingNameTextField.layer.shadowRadius = 8.0
        outingNameTextField.layer.shadowColor = UIColor.whiteColor().CGColor
        outingNameTextField.layer.shouldRasterize = true
        
        mapView.layer.cornerRadius = 25.0
        mapView.layer.shadowColor = UIColor.whiteColor().CGColor
        //mapView.layer.shadowOffset = CGSizeMake(0, 0)
        mapView.layer.shadowRadius = 16.0
        mapView.layer.shadowOpacity = 0.9
        
        
        
        // Add a google Map View
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.cameraWithLatitude(-33.86, longitude: 151.20, zoom: 6.0)
        self.mapView.camera = camera
        //mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: camera)
        mapView.myLocationEnabled = true
        //view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("CreateOutingView will appear")
        // Set up the member scroll view
        if memberScrollView.subviews.count < members.count {
            memberScrollView.viewWithTag(0)?.tag = 1000 //prevent confusion when looking up images
            setupList()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        print("bye felicia")
        // TODO: Handle closing out this view
        
    }
    
    func setHomeBaseMarker() {
        // Remove current marker before initializing a new one
        
        homeBaseMarker?.map = nil
        
        let homeBaseLat = newOuting.destinationLat
        let homeBaseLon = newOuting.destinationLon
        
        let coordinate = CLLocationCoordinate2DMake(homeBaseLat, homeBaseLon)
        
        // init the marker at the home base and set it to the current map view
        homeBaseMarker = GMSMarker.init(position: coordinate)
        
        homeBaseMarker?.map = mapView
        
        // Center the Map View around the home base with animation
        let update = GMSCameraUpdate.setTarget(coordinate, zoom: 15.0)
        mapView.animateWithCameraUpdate(update)
        
    }
    
    @IBAction func tappedUpdateHomeBase(sender: AnyObject) {
        print("called tappedSetHomeBase")
        
        let autocompleteController = GMSAutocompleteViewController() //OutingDestinationAutoComplete()
        
        //autocompleteController.outing = newOuting
        autocompleteController.delegate = self
        self.presentViewController(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func createOutingButtonPressed(sender: AnyObject) {
        
        if ((outingNameTextField.text == "") || (didSetDestination == false)) {
            
            let a = UIAlertController.init(title: "Missing Some Info" , message: "Add a name and set your destination please!", preferredStyle: .Alert)
            
            //a.view.backgroundColor = UIColor.blackColor()
            //a.view.tintColor = UIColor.blueColor()
            
            let okAction = UIAlertAction(title: "Got It", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                print("Pressed OK Block")
            }
            
            a.addAction(okAction)
            
            self.presentViewController(a, animated: true, completion: nil)
            
        } else {
            
            // TODO: Create the outing object, initialize all of the data, then
            //       pass that outing to an OutingViewController, then add that
            //       OVC to the hpvc's OutingViewArray
            
            let curfewDate = curfewTimePicker.date.timeIntervalSinceReferenceDate
            let curfewTimeInterval = curfewTimePicker.date.timeIntervalSinceNow
            
            let newOuting = GLODataStore.sharedInstance.createOuting()
            
            newOuting.name = outingNameTextField.text!
            newOuting.outingCreator = NSUserDefaults.standardUserDefaults().objectForKey("userID") as! String
            newOuting.curfew = curfewDate
            newOuting.curfewTimeInterval = curfewTimeInterval
            newOuting.destinationLat = NSUserDefaults.standardUserDefaults().doubleForKey("newOutingLatitude")
            newOuting.destinationLon = NSUserDefaults.standardUserDefaults().doubleForKey("newOutingLongitude")
            
            // Initialize a new OutingViewController and set its outing property
            let newOVC = OutingViewController.init()
            newOVC.outing = newOuting
            
            print("NEW OUTING CHECK 2 LAT: ", newOuting.destinationLat, " AND LON: ", newOuting.destinationLon)
            
            // Add the newOVC to the hpvc's outingViewArray and currentOutingArray
            hpvc!.currentOutingArray.append(newOuting)
            hpvc!.outingViewArray.append(newOVC)
            // Set up the hpvc's progress bar scroll view programmatically so that the timer doesn't try update a progress bar before it's drawn
            hpvc!.setupList()
            
            postOuting(outingNameTextField.text!,
                       outingID: newOuting.outingID,
                       creator: newOuting.outingCreator,
                       dateCreated: newOuting.dateCreated,
                       destinationLat: Double(newOuting.destinationLat),
                       destinationLon: Double(newOuting.destinationLon),
                       curfewDate: curfewDate,
                       curfewTimeInterval:newOuting.curfewTimeInterval)
            
            // Consider moving the dismiss command to the success block in postOuting
            self.dismissViewControllerAnimated(true, completion: dismissBlock)
        }
    }
    
    func postOuting(name:String, outingID:String, creator:String, dateCreated:Double, destinationLat:Double, destinationLon:Double, curfewDate:Double, curfewTimeInterval:Double) {
        
        let parameters = [
            "name": name,
            "outingID": outingID,
            "creator": creator,
            "dateCreated": dateCreated,
            "destinationLat": destinationLat,
            "destinationLon": destinationLon,
            "turd": "ferguson",
            "curfewDate": curfewDate,
            "curfewTimeInterval": curfewTimeInterval,
            "ACL": [creator]
        ]
        
        let userParams:[String:AnyObject] = [
            "name":name,
            "userID":creator,
            "description":NSUserDefaults.standardUserDefaults().objectForKey("Description") as! String
        ]
        
        
        var newOuting = PFObject(className:"Outing")
        newOuting["name"] = name
        newOuting["outingID"] = outingID
        newOuting["creator"] = creator
        newOuting["dateCreated"] = dateCreated
        newOuting["destinationLat"] = destinationLat
        newOuting["destinationLon"] = destinationLon
        newOuting["turd"] = "ferguson"
        newOuting["curfewDate"] = curfewDate
        newOuting["curfewTimeInterval"] = curfewTimeInterval
        newOuting["socketMemberList"] = [] // init a blank socketMemberList to be populated later
        
        var outingACL = PFACL.init(user: PFUser.currentUser()!)
        newOuting.ACL = outingACL
        
        newOuting.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                print("Parse outing saved successfully!")
            } else {
                // There was a problem, check error.description
                print("Error creating the parse outing! ", error?.description)
                
            }
        }
        
        
        
        // TODO: This needs to be replaced with creating a parse Object, then setting the ACL
        
        /* Going to try creating outing as Parse Object instead so that it has a built in ACL (for security)
         
        Alamofire.request(.POST, "https://glo-app.herokuapp.com/createOuting", parameters: parameters as? [String : AnyObject], encoding: .JSON)
                .responseJSON { response in
                    print("here's the request", response.request)  // original URL request
                    print("here's the URL Response", response.response) // URL response
                    print("here's the server data", response.data)     // server data
                    print("here's the result of response serialization", response.result)   // result of response serialization
                
                    if let JSON = response.result.value {
                        print("Alamofire JSON response: \(JSON)")
                        
                        // This returns the lat and lon of the address that was just entered. Take that, save it as the lat and lon of the current outing, use that to draw the pin/center the map for the outing view
                        print("AAWWWOOOOKKK lat", JSON.objectForKey("lat"))
                        print("annnd lon: ", JSON.objectForKey("lng"))
                        
                        NSUserDefaults.standardUserDefaults().setObject(JSON.objectForKey("lat"), forKey: "currentOutingLat")
                        NSUserDefaults.standardUserDefaults().setObject(JSON.objectForKey("lng"), forKey: "currentOutingLng")
                        
                        
                    } else {
                        print("Failure posting outing!")
                    }
                }
        */
        
        
    }

    
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
        let itemHeight: CGFloat = memberScrollView.frame.height * 1.25
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
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    
    // MARK: Location Picker Protocol
    
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        print("Place Coordinates: ", place.coordinate)
        
        
        let coords = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        
        
        
        newOuting.destinationLat = place.coordinate.latitude
        newOuting.destinationLon = place.coordinate.longitude
        
        //save coordinates to user defaults since they are not passing back properly
        NSUserDefaults.standardUserDefaults().setDouble(place.coordinate.latitude, forKey: "newOutingLatitude")
        NSUserDefaults.standardUserDefaults().setDouble(place.coordinate.longitude, forKey: "newOutingLongitude")
        
        
        
        print("NEW OUTING DESTINATION LAT: ", newOuting.destinationLat, " AND LON: ", newOuting.destinationLon)
        
        // Did finish setting outing destination, make Bool = true
        didSetDestination = true
        
        
        
        self.dismissViewControllerAnimated(true, completion: {
            self.setHomeBaseMarker()
        })
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    
}


struct WuTang {
    
    let name: String
    let image: String
    let description: String
    
    static func all() -> [WuTang] {
        return [
            WuTang(name: "RZA", image: "RZA", description: "The master of the Wu-Tang Clan, the beatsmith himself, Robert Fitzgerald “RZA” Diggs came to define the Wu sound throughout its rise. He has produced almost all of Wu-Tang Clan's albums as well as many Wu-Tang solo and affiliate projects. He is a cousin of the late group-mate, Ol' Dirty Bastard and GZA (who also formed the group with RZA). He has also released solo albums under the alter-ego Bobby Digital, along with executive producing credits for side projects."),
            
            WuTang(name: "GZA", image: "GZA", description: "The Genious. A founding member of the hip hop group the Wu-Tang Clan, GZA is known as the group's 'spiritual head', being both the oldest and the first within the group to receive a record deal. He has appeared on his fellow Clan members' solo projects, and since the release of his critically acclaimed solo album Liquid Swords (1995), he has maintained a successful solo career."),
            
            WuTang(name: "Ol'Dirty Bastard", image: "OlDirty", description: "Russell Tyrone Jones (November 15, 1968 – November 13, 2004),[2] better known under his stage name Ol' Dirty Bastard (or ODB), was an American rapper, producer and one of the founding members of the Wu-Tang Clan. ODB was often noted for his trademark microphone techniques and his 'outrageously profane, free-associative rhymes delivered in a distinctive half-rapped, half-sung style'. His stage name was derived from the 1980 martial arts film Ol' Dirty and the Bastard (also called An Old Kung Fu Master, starring Yuen Siu-tien)."),
            
            WuTang(name: "Inspectah Deck", image: "Inspectah.jpg", description: "Jason Hunter (born July 6, 1970) aka Inspectah Deck, is an American rapper, producer, and member of the Wu-Tang Clan. He has acquired critical praise for his intricate lyricism, and for his verses on many of the group's most revered songs (see: 'Triumph'). He has grown to become a producer in his own right, taking up tracks for fellow clansmen and his own projects."),
            
            WuTang(name: "Raekwon the Chef", image: "Raekwon.jpg", description: "Corey Woods, or Raekwon, is a rapper and a member of the Wu-Tang Clan. He released his solo debut, Only Built 4 Cuban Linx… in 1995, and has since recorded four solo albums, as well as work with Wu-Tang and an extensive amount of guest contributions with other hip hop artists. Raekwon is often cited as one of the pioneers of the Mafioso rap sub-genre. In 2007, The editors of About.com placed him on their list of the Top 50 MCs of Our Time. The Miami New Times described Raekwon’s music as being street epics that are 'straightforward yet linguistically rich universes not unlike a gangsta Illiad.'"),
            
            WuTang(name: "U-God", image: "UGOD.jpg", description: "Lamont Jody Hawkins[1] (born October 11, 1970),[2] better known as U-God (short for Universal God), is an American rapper and member of the hip hop collective, Wu-Tang Clan. He has been with the group since its inception, and is known for having a deep, rhythmic flow that can alternate between being gruff or smooth."),
            
            WuTang(name: "Ghostface Killah", image: "Ghostface.jpg", description: "Ghostface Killah, born Dennis Coles, is a Staten Island rapper and member of the Wu-Tang Clan, known for both his work with Wu-Tang and his extensive solo career. Ghostface is known for his dense flow style, his stream-of-consciousness storytelling, and his emotive delivery. Ghostface was also the co-star of Raekwon’s critically acclaimed 1995 Only Built 4 Cuban Linx… album, and followed it soon with his own 1996 solo debut, Ironman His 2000 sophomore album Supreme Clientele is widely regarded as one of the best Wu Tang solo projects. Since then, he’s continued to evolve, from his gambino-themed 2006 album Fishscale, to his collaboration with BADBADNOTGOOD, 2015’s Sour Soul. His name is taken from the villain in 1979 martial arts film Mystery of Chessboxing."),
            
            WuTang(name: "The Method Man", image: "MethodMan.jpg", description: "Clifford Smith (born March 2,[2] 1971), better known by his stage name Method Man, is an American rapper, record producer, and actor. He took his stage name from the 1979 film Method Man. He is perhaps best known as a member of the East Coast hip hop collective Wu-Tang Clan. He is also one half of the hip hop duo Method Man & Redman. In 1996, he won a Grammy Award for Best Rap Performance by a Duo or Group, for 'I'll Be There for You/You're All I Need to Get By', with American R&B singer-songwriter Mary J. Blige"),
            
            WuTang(name: "Cappadonna", image: "cappadonna.jpg", description: "The 'unofficial official' tenth member of the Wu-Tang Clan, Cappadonna has been there since the beginning. During the formative years of the Clan, Cappa was slated to become a core member until he landed behind bars and was replaced by the Method Man. Like other members of the group, Cappa’s name also has a hidden meaning behind an acronym. Consider All Poor People Acceptable Don’t Oppress Nor Neglect Anyone is the full meaning behind Cappachino’s name. First appearing on Ghostface Killah’s classic joint “Ice Cream,” Cappadonna has gone on to drop nine solo albums and numerous other collaborations."),
            
            WuTang(name: "Masta Killa", image: "MastaKilla.jpg", description:"Jamel Irief (born Elgin Turner; August 18, 1969), better known by his stage name Masta Killa, is an American rapper and member of the Wu-Tang Clan.[2] Though one of the lesser-known members of the group (he was featured on only one track on their 1993 debut album Enter the Wu-Tang (36 Chambers)), he has been prolific on Clan group albums and solo projects since the mid-1990s. He released his debut album No Said Date in 2004 to positive reviews, and has since released two additional albums.")
        ]
    }
}

class OutingDestinationAutoComplete:GMSAutocompleteViewController {
    var outing:OutingObject?
}

/*
extension CreateOutingViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        print("Place Coordinates: ", place.coordinate)
        
        // This is where I set the user's home base coordinates in user defaults
        //NSUserDefaults.standardUserDefaults().setObject(place.coordinate.latitude, forKey: "HomeBaseLat")
        //NSUserDefaults.standardUserDefaults().setObject(place.coordinate.longitude, forKey: "HomeBaseLon")
        
        let coords = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        
        // Set Coordinate, and individual Lat and Long of the new Outing
        
        //newOuting.destinationLat = Double(place.coordinate.latitude)
        //newOuting.destinationLon = Double(place.coordinate.longitude)
        
        newOuting.destinationLat = place.coordinate.latitude
        newOuting.destinationLon = place.coordinate.longitude
        
        print("NEW OUTING DESTINATION LAT: ", newOuting.destinationLat, " AND LON: ", newOuting.destinationLon)
        
        // Did finish setting outing destination, make Bool = true
        didSetDestination = true
        
        // TODO: Draw marker at and center around these coordinates on the map. I will call an update map pin function, and will need a homeBasePin GMSMarker property.
        setHomeBaseMarker()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
}
*/