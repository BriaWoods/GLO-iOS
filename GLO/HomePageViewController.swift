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