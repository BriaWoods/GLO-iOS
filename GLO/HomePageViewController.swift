//
//  HomePageViewController.swift
//  GLO
//
//  Created by Stephen Looney on 7/9/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import Foundation
import UIKit


class HomePageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let data = ["Girls night, no boys!", "Wu Tang Clan", "Magic Mike n' Martinis"]
    
    @IBOutlet weak var currentOuting: UIButton!
    
    @IBOutlet weak var posseTableview: UITableView!
    
    
    let menuOptions = ["profile", ""]
    
    init() {
        super.init(nibName: nil, bundle: nil)
        print("In init for home page controller")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load homebase")
        
        let leftbbi = UIBarButtonItem.init(title: "Menu", style: UIBarButtonItemStyle.Plain, target: self, action: "presentMenu:")
        
        self.navigationItem.leftBarButtonItem = leftbbi
        
        // Configure the side menu
        // Define the menus
        let menuTableController = SideMenuTableController()
        
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController:menuTableController)
        menuLeftNavigationController.leftSide = true
        menuLeftNavigationController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        menuLeftNavigationController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "X", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        
        menuTableController.tableView.backgroundColor = UIColor.clearColor()
        menuTableController.tableView.scrollEnabled = false
                
        
        // UISideMenuNavigationController is a subclass of UINavigationController, so do any additional configuration of it here like setting its viewControllers.
        
        SideMenuManager.menuWidth = max(round(min(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height) * 0.33), 160)
        SideMenuManager.menuShadowColor = UIColor.whiteColor()
        SideMenuManager.menuShadowRadius = 8.0
        SideMenuManager.menuBlurEffectStyle = UIBlurEffectStyle.Dark
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuPresentMode = .MenuSlideIn
        SideMenuManager.menuParallaxStrength = 100
        
        
        SideMenuManager.menuLeftNavigationController = menuLeftNavigationController
        
        
        let menuRightNavigationController = UISideMenuNavigationController()
        // UISideMenuNavigationController is a subclass of UINavigationController, so do any additional configuration of it here like setting its viewControllers.
        SideMenuManager.menuRightNavigationController = menuRightNavigationController
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        
        // Check to see if the user still needs to add their info
        checkForDeets()
        
    }
    
    
    func checkForDeets() {
        // Pushes the Detail Entry View if the user hasn't filled in their information yet (i.e. Set their home base, entered a name,  a short description, and taken a profile pic.
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        
        if (!userDefaults.boolForKey("HasLaunchedOnce") ||
            userDefaults.stringForKey("Name") == nil         ||
            userDefaults.stringForKey("Description") == nil   ||
            userDefaults.objectForKey("ProfilePic") == nil
            ) {
            
            // Launch the deets entry page
            let edvc = EnterDeetsViewController()
            
            self.presentViewController(edvc, animated: true, completion: nil)
            
        }
        
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("possecell") as? PosseTableViewCell
        
        if (cell == nil) {
            let nib:NSArray = NSBundle.mainBundle().loadNibNamed("PosseTableViewCell", owner:self, options:nil)
            cell = nib.objectAtIndex(0) as? PosseTableViewCell
        }
        
        cell!.textLabel?.text = data[indexPath.row]
        cell?.textLabel?.textAlignment = .Center
        
        print("in cellforrowatindexpath")
        
        return cell!
    }
    
    
    @IBAction func presentMenu(sender: AnyObject) {
        presentViewController(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    //MARK: IBACTIONS
    @IBAction func createOutingButton(sender: AnyObject) {
        
        print("create outing button pressed")
        
        let covc = CreateOutingViewController.init()
        covc.dismissBlock = { () -> Void in
            print("inside create outing dismiss block")
            // Add in more goodies here
            // TODO: Init a nav controller add outing view, push onto stack
            let ovc = OutingViewController.init()
            self.presentViewController(ovc, animated: true, completion: nil)
            
        }
        self.presentViewController(covc, animated: true, completion: nil)
        
        
    }
    
    @IBAction func presentCurrentVC(sender: AnyObject) {
        
        let ovc = OutingViewController.init()
        
        self.presentViewController(ovc, animated: true, completion: nil)
        
    }
    
    @IBAction func currentOutingButton(sender: AnyObject) {
        
        print("current outing button pressed")
        
    }
    
    @IBAction func createPosseButton(sender: AnyObject) {
        
        print("create possee button pressed")
        
        let pnvc = PosseNameViewController.init()
        let navController = UINavigationController(rootViewController: pnvc)
        
        self.presentViewController(navController, animated: true, completion: nil)
        
    }
    

}