//
//  AppDelegate.swift
//  GLO
//
//  Created by Stephen Looney on 7/9/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import UIKit
import Parse
import GoogleMaps
import GooglePlacesAPI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        print("app did finish launching with options")
        self.window = UIWindow.init(frame: UIScreen.mainScreen().bounds)
        
        // Google Maps Config
        GMSServices.provideAPIKey("AIzaSyBY5PwOMXnsTKQifiyxLNJerny4R4MNDJg")
        
        // Google Places Config
        GoogleMapsService.provideAPIKey("AIzaSyBY5PwOMXnsTKQifiyxLNJerny4R4MNDJg")
        
        // Google Places Confid
        GooglePlaces.provideAPIKey("AIzaSyBY5PwOMXnsTKQifiyxLNJerny4R4MNDJg")
        
        
        // Parse Server Config
        Parse.initializeWithConfiguration(ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) -> Void in
            configuration.server = "https://glo-app.herokuapp.com/parse/" // '/' important after 'parse'
            configuration.applicationId = "3DSGLOBALROUNDUP"
        }))
        
        
        let params = ["phoneNumber": "1234567", "codeEntry": "1234"] as [NSObject:AnyObject]
        
        
        print("About to call cloud code login")
        /*
        PFCloud.callFunctionInBackground("logIn", withParameters: params) { response, error in
            if let description = error?.description {
                //self.editing = true
                return //self.showAlert("Login Error", message: description)
            }
            
            if let res = response as? String {
                print("Success! Here's the cloud login response: ", res)
                
                /*
                PFUser.becomeInBackground(token) { user, error in
                    if let _ = error {
                        self.showAlert("Login Error", message: NSLocalizedString("warningGeneral", comment: "Something happened while trying to log in.\nPlease try again."))
                        self.editing = true
                        return self.step1()
                    }
                    return self.dismissViewControllerAnimated(true, completion: nil)
                }
                */
                
            } else {
                print("Login error with Parse Cloud");
                //self.editing = true
                //self.showAlert("Login Error", message: NSLocalizedString("warningGeneral", comment: "Something went wrong.  Please try again."))
                return //self.step1()
            }
        }
        */
        
        
        // TODO: Need to initialize view controller above and then set one as the root view controller as below
        
        let hpvc = HomePageViewController.init()
        
        let hpnc = UINavigationController.init(rootViewController: hpvc)
        
        self.window?.rootViewController = hpnc
        
        self.window!.makeKeyAndVisible()
        
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            
            print("Houston we have a user")
            
        } else {
            
            print("present the login!")
            //let storyboard = UIStoryboard.init(name: "LoginStoryboard", bundle: nil)
            let storyboard = UIStoryboard.init(name: "PhoneLogin", bundle: nil)
            self.window?.rootViewController?.presentViewController(storyboard.instantiateInitialViewController()!, animated: true, completion: nil)
            
        }
        
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        let success:Bool = GLODataStore.sharedInstance.saveChanges()
        if (success) {
            print("Saved all of the stuff")
        } else {
            print("Could not save any of the stuff")
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension UIButton {
    
    override public func drawRect(rect: CGRect) {
        
        // Overriding draw rect to add in a glow around border
        let shadowOffset = CGSizeMake(0.0, -3.0)
        let shadowRadius:CGFloat = 5.0
        let context = UIGraphicsGetCurrentContext()
        
        
        CGContextSetShadowWithColor(context, shadowOffset, shadowRadius, UIColor.whiteColor().CGColor);
        
        // End by calling super.shadow
        super.drawRect(rect)
    }
    
}
