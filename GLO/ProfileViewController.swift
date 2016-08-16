//
//  ProfileViewController.swift
//  GLO
//
//  Created by Stephen Looney on 8/13/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import UIKit
import Parse
import GoogleMaps
import QuartzCore
import GooglePlacesAPI

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPopoverControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: ShadowLabel!
    @IBOutlet weak var phoneNumberLabel: ShadowLabel!
    
    var homeBaseMarker:GMSMarker?
    @IBOutlet weak var homeBaseMapView: GMSMapView!
    @IBOutlet weak var updateHomebaseButton: UIButton!
    
    @IBOutlet weak var outingCountLabel: ShadowLabel!
    @IBOutlet weak var friendCountLabel: ShadowLabel!
    
    var imagePickerPopover:UIPopoverController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        homeBaseMapView.layer.cornerRadius = max(homeBaseMapView.frame.size.height / 2.0, homeBaseMapView.frame.size.width / 2.0)
        
        updateHomebaseButton.layer.borderColor = UIColor.whiteColor().CGColor
        updateHomebaseButton.layer.borderWidth = 1.0
        updateHomebaseButton.layer.cornerRadius = 8.0
        
        // TODO: Set all of the user's details from the NSUserDefaults that were (will be) set in the intro sequence
        
        // Initialize the Google Map, and draw a pin where the user previously set their homebase.
        
        
        // TODO: The lat and long should be initialized from Coordinates stored in NSUserDefaults.standardUserDefaults
        
        /* Replacing this code with the setHomeBaseMarker() function
        let lat:Double = 40.7128
        let lon:Double = 74.0059
        
        let camera = GMSCameraPosition.cameraWithLatitude(lat, longitude: lon, zoom: 3.0)
        self.homeBaseMapView.camera = camera
        //mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: camera)
        homeBaseMapView.myLocationEnabled = true
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.title = "Outing Destination"
        marker.snippet = "Party Time"
        marker.map = homeBaseMapView
        */
        
        setHomeBaseMarker()
        
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = max(profileImageView.frame.size.height / 2.0, profileImageView.frame.size.width / 2.0)
        
        // TODO: Add tap gesture recognizer to profile pic that pushes the camera view (so you can take a selfie).
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:Selector("takePicture:")))
        
        if ((NSUserDefaults.standardUserDefaults().objectForKey("ProfilePic")) != nil) {
            // If there is a saved profile pic, set that as the image
            let imageData = NSUserDefaults.standardUserDefaults().objectForKey("ProfilePic") as! NSData
            let image = UIImage.init(data: imageData)
            profileImageView.image = image
        } else {
            // Otherwise set it as Raekwon
            profileImageView.image = UIImage.init(named: "Raekwon")
        }
        
        //Set name and description labels
        nameLabel.text = NSUserDefaults.standardUserDefaults().objectForKey("Name") as! String
        phoneNumberLabel.text = PFUser.currentUser()?.username
        
    }
    
    func setHomeBaseMarker() {
        // Remove current marker before initializing a new one
        
        homeBaseMarker?.map = nil
        
        let homeBaseLat = NSUserDefaults.standardUserDefaults().objectForKey("HomeBaseLat") as! CLLocationDegrees
        let homeBaseLon = NSUserDefaults.standardUserDefaults().objectForKey("HomeBaseLon") as! CLLocationDegrees
        
        homeBaseMarker = GMSMarker.init(position: CLLocationCoordinate2D(latitude: homeBaseLat, longitude: homeBaseLon))
        homeBaseMarker?.map = homeBaseMapView
        
        
        // Center the Map View around the newly drawn marker
        let camera = GMSCameraPosition.cameraWithLatitude(homeBaseLat, longitude: homeBaseLon, zoom: 3.0)
        homeBaseMapView.camera = camera
        homeBaseMapView.myLocationEnabled = true
        
    }
    
    func takePicture(sender: AnyObject) {
    
        print("tapped takePicture")
        
        if let ipp = imagePickerPopover {
            if(ipp.popoverVisible) {
                imagePickerPopover?.dismissPopoverAnimated(true)
                imagePickerPopover = nil
            
            }
        }
        
        
        var imagePicker = UIImagePickerController.init()
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        
        imagePicker.delegate = self
        
        // Place image picker on the screen
        // Check for iPad device before instantiating the popover controller
        // Consider removing iPad control for right now, there isn't a camera bar button item at the moment
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad) {
            // Create a new popover controller that will display the imagePicker
            imagePickerPopover = UIPopoverController.init(contentViewController: imagePicker)
            imagePickerPopover!.delegate = self
            
            // Display the popover controller; sender is the button I designate as the camera button.
            imagePickerPopover?.presentPopoverFromBarButtonItem(sender as! UIBarButtonItem, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            
        } else {
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedUpdateHomeBase(sender: AnyObject) {
        print("called tappedSetHomeBase")
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.presentViewController(autocompleteController, animated: true, completion: nil)
    }
    
    // MARK: Image Picker Protocol
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // Get a new image
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        NSUserDefaults.standardUserDefaults().setObject(UIImagePNGRepresentation(image), forKey: "ProfilePic")
        
        profileImageView.image = image
        // TODO: May need to set the image to be circular (will require another UIImage extension variable)
        
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone) {
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            // If on the iPad, the image picker is in the popover. Dismiss the popover.
            imagePickerPopover?.dismissPopoverAnimated(true)
            imagePickerPopover = nil
        }
        
        
        
    }

}

extension ProfileViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        print("Place Coordinates: ", place.coordinate)
        
        // This is where I set the user's home base coordinates in user defaults
        NSUserDefaults.standardUserDefaults().setObject(place.coordinate.latitude, forKey: "HomeBaseLat")
        NSUserDefaults.standardUserDefaults().setObject(place.coordinate.longitude, forKey: "HomeBaseLon")
        
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


