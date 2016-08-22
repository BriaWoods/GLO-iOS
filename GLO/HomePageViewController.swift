//
//  HomePageViewController.swift
//  GLO
//
//  Created by Stephen Looney on 7/9/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import Foundation
import UIKit

// TODO: Will need to add in "current Outing" button, that has a circular progress bar reflecting the time left until curfew (this will probably look pretty sweet).

class HomePageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let data = ["Girls night, no boys!", "Wu Tang Clan", "Magic Mike n' Martinis"]
    @IBOutlet weak var outingScrollView: UIScrollView!
    
    var outingViewArray:[OutingViewController] = []
    var currentOutingArray:[OutingObject] = []
    
    var updateProgressTimer = NSTimer.init()
    
    @IBOutlet weak var currentOuting: UIButton!
    @IBOutlet weak var posseTableview: UITableView!
    
    // Below will need to be replaced at some point (we will be creating circle progress programmatically)
    //@IBOutlet weak var circularProgress: KDCircularProgress!
    //@IBOutlet weak var curfewTimerLabel: ShadowLabel!
    
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
        
        // TODO: Load all of the Current Outings from data
        
        
        
        
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
        
        
        // TODO: Create the right bbi, have that push the "outing invites" view where the user can accept or deny the 
        
        
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
        
        // Start timer to update progress bars
        updateProgressTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updateProgressBars"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(updateProgressTimer, forMode: NSRunLoopCommonModes)
        
        // Load all outings from data and set them in the currentOutingArray
        if (GLODataStore.sharedInstance.currentOutings.count > 0) {
            currentOutingArray = GLODataStore.sharedInstance.currentOutings
            print("Here's the currentOutingArray, fresh from Core Data! ", currentOutingArray)
            
            
        }
        var buildOVCArray:[OutingViewController] = []
        for outing in currentOutingArray {
            let ovc = OutingViewController()
            ovc.outing = outing
            buildOVCArray.append(ovc)
        }
        
        outingViewArray = buildOVCArray
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("HomePageView will appear")
        print(outingScrollView.subviews.count , " < ", currentOutingArray.count, " ?")
        // Set up the member scroll view
        
        // I already create and append the OVC in create outing, I don't think this should be here
        /*
        if currentOutingArray.count > outingViewArray.count {
            let ovc = OutingViewController.init()
            ovc.outing = currentOutingArray.last
            outingViewArray.append(ovc)
        }
        */
        
        if ((outingScrollView.subviews.count) < currentOutingArray.count) {
            //TODO: Below is causing problems?
            outingScrollView.viewWithTag(0)?.tag = 1000 // prevent confusion when lookingup images
            setupList()
        }
    }
    
    
    func checkForDeets() {
        // Pushes the Detail Entry View if the user hasn't filled in their information yet (i.e. Set their home base, entered a name,  a short description, and taken a profile pic.
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        
        if (!userDefaults.boolForKey("HasLaunchedOnce")      ||
            userDefaults.stringForKey("Name") == nil         ||
            userDefaults.stringForKey("Description") == nil  ||
            userDefaults.objectForKey("ProfilePic") == nil   ||
            userDefaults.objectForKey("HomeBaseLat") == nil  ||
            userDefaults.objectForKey("HomeBaseLon") == nil
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
    
    
    func updateProgressBars() {
        
        // This code works! But commenting out for now to make the outing views into a SideScroll thing.
        let color1 = UIColor.init(red: 15/255.0, green: 255/255.0, blue: 111/255.0, alpha: 1.0)
        let color2 = UIColor.init(red: 14/255.0, green: 255/255.0, blue: 229/255.0, alpha: 1.0)
        let color3 = UIColor.init(red: 185/255.0, green: 255/255.0, blue: 6/255.0, alpha: 1.0)
        
        // Get newest Outing from array
        //let lastOVC = outingViewArray.last
        //let curfewTimeInterval:NSTimeInterval
        
        //if let ovc = lastOVC {
            
            // Add for loop here to cycle through circular progress bars
        
        if (currentOutingArray.count > 0) {
            for i in 0 ..< currentOutingArray.count {
                let outing = currentOutingArray[i] as! OutingObject
                let circularProgress = outingScrollView.viewWithTag(i) as! KDCircularProgress
                let ovc = outingViewArray[i]
                
                let curfewDate = NSDate(timeIntervalSinceReferenceDate: outing.curfew)
                let timeUntilCurfew = curfewDate.timeIntervalSinceNow
                
                // Updated the curfew timer label within the outing view controller
                if (ovc.viewHasLoaded) {
                    ovc.updateTimerLabel()
                }
            
                if (timeUntilCurfew >= 0) {
                
                    
                    //Define Two more colors, set them to the circular progress.
                
                    circularProgress.setColors(color1, color2, color3)
                    
                    let curfewTimeInterval = outing.curfewTimeInterval
            
                    print("timeUntilCurfew: ", timeUntilCurfew)
            
                    let newAngle = (timeUntilCurfew / curfewTimeInterval) * 360
            
                    //circularProgress.angle = newAngle
                    circularProgress.animateToAngle(newAngle, duration: 0.4, completion: nil)
            
                    // Also need to update the timer label to show the countdown time
                    let hours = Int(timeUntilCurfew) / 3600
                    print("Hours: ", hours)
                    let minutes = (Int(timeUntilCurfew) % 3600) / 60
                    print("Minutes: ", minutes)
                    let seconds = ((Int(timeUntilCurfew) % 3600) % 60)
                    print("Seconds: ", seconds)
            
                    //curfewTimerLabel.text = "\(hours):\(minutes):\(seconds)"
                    //curfewTimerLabel.text = String.localizedStringWithFormat("%.2d:%.2d:%.2d", hours, minutes, seconds)
                    // Still need to add in curfew Timer Label to the scroll View Hierarchy
                    
                } else {
                    // When curfew is expired, make the circular progress glow red.
                    circularProgress.angle = 360
                    circularProgress.setColors(UIColor.redColor(), UIColor.orangeColor(), UIColor.redColor())
                    //curfewTimerLabel.text = "Past Curfew!"
                }
            }
        }
        //}
    
        
    }
    
    // MARK: Outing Side-ScrollView Implementation
    
    func setupList() {
        
        print("Setting up the list for circular progress bar views")
        
        // Colors for Green Progress Bar
        let color1 = UIColor.init(red: 15/255.0, green: 255/255.0, blue: 111/255.0, alpha: 1.0)
        let color2 = UIColor.init(red: 14/255.0, green: 255/255.0, blue: 229/255.0, alpha: 1.0)
        let color3 = UIColor.init(red: 185/255.0, green: 255/255.0, blue: 6/255.0, alpha: 1.0)
        
        for i in 0 ..< currentOutingArray.count {
            
            // Create the Circular Progress View
            var cpv = KDCircularProgress()
            cpv.tag = i
            cpv.contentMode = .ScaleAspectFit
            cpv.userInteractionEnabled = true
            outingScrollView.addSubview(cpv)
            cpv.setColors(color1, color2, color3)
            cpv.angle = 360.0
            cpv.startAngle = 270.0
            cpv.progressThickness = 0.175
            cpv.glowAmount = 1.0
            
            
            cpv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("didTapCPV:")))
        }
        outingScrollView.backgroundColor = UIColor.clearColor()
        positionListItems()
    }
    
    func positionListItems() {
        print("Position CPVs")
        let scrollViewHeight = outingScrollView.frame.height
        
        // Define the height of the progress scroll view...80%?
        let itemHeight:CGFloat = scrollViewHeight * 0.8
        let itemWidth = itemHeight
        
        // Define the horizontal padding between the circle progress views
        let horizontalPadding:CGFloat = 10.0
        outingScrollView.contentSize = CGSize(width: CGFloat(currentOutingArray.count) * (itemWidth + horizontalPadding), height: 0)
        
        print("Here's the current Outing array in positionListItems: ", currentOutingArray)
        
        for i in 0 ..< currentOutingArray.count {
            let CPV = outingScrollView.viewWithTag(i) as! KDCircularProgress
            CPV.frame = CGRect(x: CGFloat(i) * itemWidth + CGFloat(i+1) * horizontalPadding,
                               y: 0.0,
                               width: itemWidth,
                               height: itemHeight)
        }
        
        
    }
    
    func didTapCPV(tap: UITapGestureRecognizer) {
        
        print("Tapped CPV view tag#: ", tap.view!.tag)
        
        let ovc = outingViewArray[tap.view!.tag]
        
        self.presentViewController(ovc, animated: true, completion: nil)
    }
    
    
    // MARK: IBACTIONS
    
    @IBAction func presentMenu(sender: AnyObject) {
        presentViewController(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    
    @IBAction func createOutingButton(sender: AnyObject) {
        
        print("create outing button pressed")
        
        let covc = CreateOutingViewController.init()
        covc.dismissBlock = { () -> Void in
            print("inside create outing dismiss block")
            // Add in more goodies here
            // TODO: This is where I need to pass the configured outing information forward to the OutingViewController, i.e. create the outing object inside the outing vire controller, then pass that outing object to the ovc that is initialized below.
            
            // TODO: Present the last item in the Outing View Array here
            
            if let ovc = self.outingViewArray.last {
                self.presentViewController(ovc, animated: true, completion: nil)
            }
        }
        
        covc.hpvc = self
        
        self.presentViewController(covc, animated: true, completion: nil)
        
    }
    
    @IBAction func presentCurrentVC(sender: AnyObject) {
        
        print("presentCurrentVC")
        
        if let ovc = self.outingViewArray.last {
            self.presentViewController(ovc, animated: true, completion: nil)
        }
        
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