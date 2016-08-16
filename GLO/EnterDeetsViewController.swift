//
//  EnterDeetsViewController.swift
//  GLO
//
//  Created by Stephen Looney on 8/15/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import UIKit
import Parse
import GooglePlacesAPI
import GoogleMaps

class EnterDeetsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPopoverControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var setHomeBaseButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    
    var imagePickerPopover:UIPopoverController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setHomeBaseButton.layer.borderColor = UIColor.whiteColor().CGColor
        setHomeBaseButton.layer.borderWidth = 1.0
        setHomeBaseButton.layer.cornerRadius = 8.0
        
        completeButton.layer.borderColor = UIColor.whiteColor().CGColor
        completeButton.layer.borderWidth = 1.0
        completeButton.layer.cornerRadius = 8.0
        
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = max(profileImageView.frame.size.height / 2.0, profileImageView.frame.size.width / 2.0)
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
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedSetHomeBase(sender: AnyObject) {
        // TODO: Present the location address selector, so that the user can choose their location
        print("called tappedSetHomeBase")
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.presentViewController(autocompleteController, animated: true, completion: nil)
        
    }

    @IBAction func tappedCompleteButton(sender: AnyObject) {
        
        // first check to make sure all of the details are filled out, and only dismiss if they are all set correctly
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if (nameTextField.text == "") {
            // Prompt the user to enter their name
            pushAlertView("Enter Your Name", message: "Make sure you enter your name so that your friends know who you are!")
        } else if (descriptionTextField.text == "") {
            pushAlertView("Enter a Description", message: "Enter a one-liner that your friends can see and laugh at.")
        } else if (userDefaults.objectForKey("HomeBaseLat") == nil || userDefaults.objectForKey("HomeBaseLon") == nil) {
            pushAlertView("Set a Home Base", message: "Tap on the 'Set Home Base' button to set your home base (where you plan on ending up after an outing).")
        } else {
            print("All deets are either entered or configured, proceed!")
            
            userDefaults.setObject(nameTextField.text, forKey: "Name")
            userDefaults.setObject(descriptionTextField.text, forKey: "Description")
            
            // Whatever the profile pic currently is displayed as, commit it to user defaults
            let profPicData = UIImagePNGRepresentation(profileImageView.image!)
            
            userDefaults.setObject(profPicData, forKey: "ProfilePic")
            
            // Create a parse file object to save the image
            let imageFile = PFFile.init(name: "ProfilePic.png", data: profPicData!)
            
            // TODO: Save all this data to the current Parse user so that others will be able to pull it!
            
            imageFile?.saveInBackgroundWithBlock({ (succeeded:Bool, error:NSError?) in
                let currentUser = PFUser.currentUser()
                
                currentUser?.setObject(imageFile!, forKey: "ProfilePic")
                currentUser?.setObject(self.nameTextField.text!, forKey: "Name")
                currentUser?.setObject(self.descriptionTextField.text!, forKey: "Description")
                
                currentUser?.saveInBackground()
            })
            
            var currentUser = PFUser.currentUser()
            if currentUser != nil {
                // save the data to the current user
            } else {
                // Show the login screen because there's no user
            }
            // The home base should already be set, so we're good to go with dismissing the view. Display an alert view proclaiming success!
            
            let a = UIAlertController.init(title: "Success"  , message: "You successfully updated your deets", preferredStyle: .Alert)
            
            //a.view.backgroundColor = UIColor.blackColor()
            //a.view.tintColor = UIColor.blueColor()
            
            let okAction = UIAlertAction(title: "Awesome!", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                
                
                print("Dismissing deets view")
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            a.addAction(okAction)
            
            self.presentViewController(a, animated: true, completion: nil)
            
            
        }
        
        
    }
    
    func pushAlertView(title:String, message:String) {
        let a = UIAlertController.init(title: title  , message: message, preferredStyle: .Alert)
        
        //a.view.backgroundColor = UIColor.blackColor()
        //a.view.tintColor = UIColor.blueColor()
        
        let okAction = UIAlertAction(title: "Understood", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            print("pressed OK in alert view")
        }
        
        a.addAction(okAction)
        
        self.presentViewController(a, animated: true, completion: nil)
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
    
    // MARK: Text Field Protocol
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EnterDeetsViewController: GMSAutocompleteViewControllerDelegate {
    
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
