//
//  SignUpController.swift
//  GLO
//
//  Created by Stephen Looney on 7/9/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import Parse

class SignUpController: UIViewController {
 
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var reenterPasswordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var drunkPinTextField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    
    override func viewDidLoad() {
        print("Sign Up viewDidLoad")
        signUpButton.layer.cornerRadius = 8.0
    }
    
    override func viewWillAppear(animated: Bool) {
        print("Sign Up view will appear")
    }
    
    @IBAction func dismissButtonPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        print("signUpButtonPressed")
        
        
        var user = PFUser()
        user.username = userNameTextField.text
        user.password = passwordTextField.text
        user.email = emailTextField.text
        // other fields can be set just like with PFObject
        user["phone"] = "867-5309"
        user["Sharty"] = "McShartface"
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as? NSString
                // Show the errorString somewhere and let the user try again.
            } else {
                // Hooray! Let them use the app now.
                print("You're in!")
                
                let a = UIAlertController.init(title: "You're In."  , message: "Work Hard, play hard, stay safe. GLO...Now let's party.", preferredStyle: .Alert)
                
                //a.view.backgroundColor = UIColor.blackColor()
                //a.view.tintColor = UIColor.blueColor()
                
                let okAction = UIAlertAction(title: "Let's go", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    print("Let's Go pressed, dismiss view and enter the app")
                    //self.dismissViewControllerAnimated(true, completion: nil)
                    self.dismissViewControllerAnimated(true, completion: { 
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
                
                a.addAction(okAction)
                
                self.presentViewController(a, animated: true, completion: nil)
                
                
            }
        }
        
        
    }

    

}