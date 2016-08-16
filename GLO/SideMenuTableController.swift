//
//  SideMenuTableController.swift
//  GLO
//
//  Created by Stephen Looney on 8/10/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import UIKit
import Parse

class SideMenuTableController: UITableViewController {

    var menuOptions = ["Profile", "Settings", "Friend Requests", "Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: TableView Protocol
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("SimpleTableItem")
        
        if (cell == nil) {
            cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "DefaultCell")
        }
        
        
        
        cell!.textLabel!.text = menuOptions[indexPath.row]
        cell!.textLabel!.textColor = UIColor.whiteColor()
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        cell!.backgroundColor = UIColor.clearColor()
        
        
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuOptions.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Customize what happens when each option is pressed (push corresponding views)
        
        // TODO: Add an option for logging the user out when they click "Logout"
        // TODO: Add in a friend Request view so that users can accept/deny friend requests; this will be processed on the backend by a cloud function that will create a relation between the current Parse user and the selected user.
        
        print("Tapped ", menuOptions[indexPath.row])
        if (indexPath.row == 0) {
            let pvc = ProfileViewController()
            self.navigationController?.pushViewController(pvc, animated: true)
        } else if (indexPath.row == 2) {
            let ctvc = ContactTableViewController()
            self.navigationController?.pushViewController(ctvc, animated: true)
        } else if (indexPath.row == 3) {
            print("Proceeding to log out the user")
            // Logout current User then present the login storyboard.
            PFUser.logOut()
            let storyboard = UIStoryboard.init(name: "PhoneLogin", bundle: nil)
            self.presentViewController(storyboard.instantiateInitialViewController()!, animated: true, completion: nil)
        }
    }
    

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
