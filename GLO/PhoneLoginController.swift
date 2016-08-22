//
//  PhoneLoginController.swift
//  GLO
//
//  Created by Stephen Looney on 8/5/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import UIKit
import Parse
import Alamofire

class PhoneLoginController: UIViewController {

    var rawPhoneString = ""
    var formattedPhoneString = ""
    
    var codeEntryString = ""
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var passcode1: UILabel!
    @IBOutlet weak var passcode2: UILabel!
    @IBOutlet weak var passcode3: UILabel!
    @IBOutlet weak var passcode4: UILabel!
    
    @IBOutlet weak var sendCodeButton: UIButton!
    
    @IBOutlet weak var key1: UIButton!
    @IBOutlet weak var key2: UIButton!
    @IBOutlet weak var key3: UIButton!
    @IBOutlet weak var key4: UIButton!
    @IBOutlet weak var key5: UIButton!
    @IBOutlet weak var key6: UIButton!
    @IBOutlet weak var key7: UIButton!
    @IBOutlet weak var key8: UIButton!
    @IBOutlet weak var key9: UIButton!
    @IBOutlet weak var key0: UIButton!
    
    var keypadArray:[UIButton] = []
    
    var inCodeEntryPhase = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        inCodeEntryPhase = false
        
        // Start by hiding the passcode text labels. When a code gets sent they will be made visible
        passcode1.hidden = true
        passcode2.hidden = true
        passcode3.hidden = true
        passcode4.hidden = true
        
        sendCodeButton.enabled = false
        
        keypadArray = [key1, key2, key3, key4, key5, key6, key7, key8, key9, key0]
        
        // Format the keys in the keypad to give make them round and give them a thin black border
        for key in keypadArray {
            key.layer.borderColor = UIColor.blackColor().CGColor
            key.layer.borderWidth = 1.0
            key.layer.cornerRadius = 25.0
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // TODO: Configure view and text entry depending on whether or not inCodeEntryPhase is enabled
    
    
    @IBAction func didPressKey(sender: AnyObject) {
        
        
        // Below handles the phone number entry. Need to add check to see if we've entered the code entry phase of login. If so, keypad taps need to be handled differently.
        if (inCodeEntryPhase == false) {
            let number = (sender as! UIButton).titleLabel!.text
            print("Just pressed ", number)
            if (rawPhoneString.characters.count < 10) {
                rawPhoneString.appendContentsOf(number!)
            } else {
                print("Max limit of numbers in phone # already reached!")
            }
        
            print("Making the number: ", rawPhoneString)
        
            print("proceeding to format the phone number")
            formatPhoneString()
        
            // Enable the send code button if the phone number has 10 digits
        
            if (rawPhoneString.characters.count == 10) {
                // TODO: Add in an enabled animation to let the user know they can tap it
                sendCodeButton.enabled = true
            } else {
                sendCodeButton.enabled = false
            }
        
        } else if (inCodeEntryPhase == true) {
            let number = (sender as! UIButton).titleLabel!.text
            print("Just pressed ", number, " in code entry mode")
            
            if (codeEntryString.characters.count < 4) {
                codeEntryString.appendContentsOf(number!)
                
                
                
            } else {
                print("Max limit of numbers in Code already reached!")
            }
            
            
            // Format the code so that it appears correctly in the labels
            formatCode()
            
            
            if (codeEntryString.characters.count == 4) {
                // Send the code to the backend
                
                print("About to call login with ", rawPhoneString, " and code (as Int) ", Int(codeEntryString)!)
                
                doLogin(rawPhoneString, code: Int(codeEntryString)!)
                
            }
            
            
            
        } else {
            
            // TODO: Do I need to throw an exception here? The inCodeEntryPhase should always be either true or false
            
            print("EXCEPTION: THIS ERROR SHOULD NOT OCCUR, inCodeEntryPhase should always be either true of false")
            
            
        }
        
    }
    
    func formatPhoneString() {
        
        if rawPhoneString.characters.count == 0 {
            formattedPhoneString = ""
        } else if (rawPhoneString.characters.count <= 3) {
            formattedPhoneString = "(\(rawPhoneString))"
        } else if (rawPhoneString.characters.count > 3) && (rawPhoneString.characters.count <= 6) {
            let index3 = rawPhoneString.startIndex.advancedBy(3)
            formattedPhoneString = "(\(rawPhoneString.substringToIndex(index3)))\(rawPhoneString.substringFromIndex(index3))"
        } else if (rawPhoneString.characters.count > 6) && (rawPhoneString.characters.count <= 10) {
            
            let first3Char:String = rawPhoneString.substringToIndex(rawPhoneString.startIndex.advancedBy(3))
            let midRange = rawPhoneString.startIndex.advancedBy(3)...rawPhoneString.startIndex.advancedBy(5)
            let next3Char:String = rawPhoneString.substringWithRange(midRange)
            let lastChars:String = rawPhoneString.substringFromIndex(rawPhoneString.startIndex.advancedBy(6))
            
            formattedPhoneString = "(\(first3Char))\(next3Char)-\(lastChars)"
            
        } else {
            print("Phone number not in correct format")
        }
        
        phoneNumberTextField.text = formattedPhoneString
    
    }
    
    
    
    func formatCode() {
        
        if (codeEntryString.characters.count == 0) {
            passcode1.text = ""
            passcode2.text = ""
            passcode3.text = ""
            passcode4.text = ""
        } else if (codeEntryString.characters.count == 1) {
            passcode1.text = String(codeEntryString[codeEntryString.startIndex])
            passcode2.text = ""
            passcode3.text = ""
            passcode4.text = ""
        } else if (codeEntryString.characters.count == 2) {
            passcode1.text = String(codeEntryString[codeEntryString.startIndex])
            passcode2.text = String(codeEntryString[codeEntryString.startIndex.advancedBy(1)])
            passcode3.text = ""
            passcode4.text = ""
        } else if (codeEntryString.characters.count == 3) {
            passcode1.text = String(codeEntryString[codeEntryString.startIndex])
            passcode2.text = String(codeEntryString[codeEntryString.startIndex.advancedBy(1)])
            passcode3.text = String(codeEntryString[codeEntryString.startIndex.advancedBy(2)])
            passcode4.text = ""
        } else if (codeEntryString.characters.count == 4) {
            passcode1.text = String(codeEntryString[codeEntryString.startIndex])
            passcode2.text = String(codeEntryString[codeEntryString.startIndex.advancedBy(1)])
            passcode3.text = String(codeEntryString[codeEntryString.startIndex.advancedBy(2)])
            passcode4.text = String(codeEntryString[codeEntryString.startIndex.advancedBy(3)])
        }
    }
    
    
    func prepareForCodeEntry() {
        
        inCodeEntryPhase = true
        
        // Show the code entry labels where the numbers show up
        passcode1.hidden = false
        passcode2.hidden = false
        passcode3.hidden = false
        passcode4.hidden = false
        
        // Hide the phone number entry stuff
        phoneNumberTextField.hidden = true
        sendCodeButton.hidden = true
        
    }
    

    @IBAction func sendCodePressed(sender: AnyObject) {
        print("Send Code Pressed")
        
        // TODO: If there is a valid phone number entered, hit up Parse+Twilio to send a four digit code to enter
        
        
        
        if (rawPhoneString.characters.count == 10) {
            print("proceeding to send code via parse+twilio")
            
            // commenting out alamofire api hit at the moment
            /*
            let parameters = [
                "phoneNumber": "6511234567",
                "turd": "ferguson"
            ]
            
            Alamofire.request(.POST, "https://glo-app.herokuapp.com/sendCode", parameters: parameters, encoding: .JSON)
            */
            
            
            // Commenting out Cloud Code call at the moment
             
            // Proceed to send the 4-digit code
            
            self.editing = false
            print("rawPhoneString:", rawPhoneString)
            let params = ["phoneNumber" : rawPhoneString]//, "language" : preferredLanguage]
            PFCloud.callFunctionInBackground("sendCode", withParameters: params) { response, error in
                self.editing = true
                if let error = error {
                    var description = error.description
                    if description.characters.count == 0 {
                        description = NSLocalizedString("warningGeneral", comment: "Something went wrong with sending the code. Please try again.") // "There was a problem with the service.\nTry again later."
                    } else if let message = error.userInfo["error"] as? String {
                        description = message
                    }
                    //self.showAlert("Login Error", message: description)
                    //return self.step1()
                    
                    // This happens if there is a user already logged in to the backend, I get a 'Cannot modify user error' - I think this has to do with the backend attempting to modify a user's password without using the required credentials (useMasterKey
                    print ("There was a login error")
                }
                //return self.step2()
                
                // The code was sent successfully (!), so reconfigure the view to receive the 4-digit code input
                // After the 4-digit code input, we can call the logIn function in parse cloud, and this will then check if the user exists, then log them in if they do or create a new user for the phone number if they don't.
                
                print("Code Send Success Message: ", response)
                
                self.prepareForCodeEntry()
                
            }
 
 
            
            
        } else {
            print("The phone number isn't the correct length.")
            
            // TODO: Decide where I should put the code that checks the code and compares it to the code that was send via SMS to the inputted phone number
            
            /*
            if textFieldText.characters.count == 4, let code = Int(textFieldText) {
                return doLogin(phoneNumber, code: code)
            }
            
            showAlert("Code Entry", message: NSLocalizedString("warningCodeLength", comment: "You must enter the 4 digit code texted to your phone number."))
             */
        }
        
    
        
    }
    
    
    func doLogin(phoneNumber: String, code: Int) {
        self.editing = false
        
        let params = ["phoneNumber": phoneNumber, "codeEntry": code] as [NSObject:AnyObject]
        
        
        PFCloud.callFunctionInBackground("logIn", withParameters: params) { response, error in
            
            // Log the error from trying to access logIn
            if let description = error?.description {
                self.editing = true
                
                // TODO: This is where you show the password was incorrect and allow them to reenter code.
                print("login error: ", description)
                return //self.showAlert("Login Error", message: description)
            }
            
            
            
            // If there was a login response (the response passes back a session token), handle it
            if let token = response as? String {
                
                PFUser.becomeInBackground(token) { user, error in
                    if let _ = error {
                        
                        
                        //self.showAlert("Login Error", message: NSLocalizedString("warningGeneral", comment: "Something happened while trying to log in.\nPlease try again."))
                        print("Server-side login was successful, but something happened while trying to log in locally on iPhone.\nPlease try again.")
                        self.editing = true
                        
                        // TODO: Will need to reset the view to try entering the code to try logging in again
                        
                        return //self.step1()
                        
                    }
                    
                    // Login was successful on backend and front-end! Dismiss the view and let the user use the app!
                    
                    print("Success! You were successfully logged in to the glo!")
                    
                    let userID = PFUser.currentUser()?.username
                    NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "userID")
                    
                    let a = UIAlertController.init(title: "You're in!"  , message: "Login was successful. Welcome to GLO.", preferredStyle: .Alert)
                    
                    //a.view.backgroundColor = UIColor.blackColor()
                    //a.view.tintColor = UIColor.blueColor()
                    
                    let okAction = UIAlertAction(title: "Let's Roll", style: UIAlertActionStyle.Default) {
                        UIAlertAction in
                        print("Pressed OK, dismiss the view")
                        
                        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    a.addAction(okAction)
                    
                    self.presentViewController(a, animated: true, completion: nil)
                    
                    //return
                }
            } else {
                self.editing = true
                //self.showAlert("Login Error", message: NSLocalizedString("warningGeneral", comment: "Something went wrong.  Please try again."))
                
                print("Didn't get a response from the server, there was a login error!")
                
                // TODO: Will need to reset the view to allow for typing in the phone number again and doing the whole code login
                
                self.inCodeEntryPhase = false
                
                // Call "reformatView" here, and maybe display an error code
                
                return //self.step1()
            }
        }
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
