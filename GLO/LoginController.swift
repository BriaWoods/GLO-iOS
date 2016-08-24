//
//  LoginController.swift
//  GLO
//
//  Created by Stephen Looney on 7/9/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class LoginController: UIViewController {
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    /*
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        self.init()
        //fatalError("init(coder:) has not been implemented")
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
    }

    override func viewWillAppear(animated: Bool) {
        print("Login View Will Appear")
        loginButton.layer.cornerRadius = 8.0
        signUpButton.layer.cornerRadius = 8.0
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        print("Pressed Login Button")
    }
    
    @IBAction func forgotPasswordPressed(sender: AnyObject) {
        
    }
    
    @IBAction func dismissButtonPressed(sender: AnyObject) {
        print("Login dismiss pressed")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}