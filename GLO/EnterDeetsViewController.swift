//
//  EnterDeetsViewController.swift
//  GLO
//
//  Created by Stephen Looney on 8/15/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import UIKit

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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedSetHomeBase(sender: AnyObject) {
    }

    @IBAction func tappedCompleteButton(sender: AnyObject) {
        
        // first check to make sure all of the details are filled out, and only dismiss if they are all set correctly
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if (nameTextField.text == "") {
            // Prompt the user to enter their name
            pushAlertView("Enter Your Name", message: "Make sure you enter your name so that your friends know who you are!")
        } else if (descriptionTextField.text == "") {
            pushAlertView("Enter a Description", message: "Enter a one-liner that your friends can see and laugh at.")
        } else if (userDefaults.objectForKey("HomeBaseCoordinates") == nil) {
            pushAlertView("Set a Home Base", message: "Tap on the 'Set Home Base' button to set your home base (where you plan on ending up after an outing")
        } else {
            print("All deets are either entered or configured, proceed!")
            
            userDefaults.setObject(nameTextField.text, forKey: "Name")
            userDefaults.setObject(descriptionTextField.text, forKey: "Description")
            
            // Whatever the profile pic currently is displayed as, commit it to user defaults
            userDefaults.setObject(UIImagePNGRepresentation(profileImageView.image!), forKey: "ProfilePic")
            
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
