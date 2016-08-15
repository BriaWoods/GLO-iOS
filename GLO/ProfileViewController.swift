//
//  ProfileViewController.swift
//  GLO
//
//  Created by Stephen Looney on 8/13/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import UIKit
import GoogleMaps
import QuartzCore

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPopoverControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: ShadowLabel!
    @IBOutlet weak var phoneNumberLabel: ShadowLabel!
    
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
        
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = max(profileImageView.frame.size.height / 2.0, profileImageView.frame.size.width / 2.0)
        
        // TODO: Add tap gesture recognizer to profile pic that pushes the camera view (so you can take a selfie).
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:Selector("takePicture:")))
        
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
