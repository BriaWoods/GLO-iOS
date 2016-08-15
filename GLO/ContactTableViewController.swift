//
//  ContactTableViewController.swift
//  GLO
//
//  Created by Stephen Looney on 8/10/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import Foundation
import Contacts
import UIKit
import MessageUI

struct Contact {
    let fullName : String
    let phoneNumber : String
}

@available(iOS 9.0, *)
class ContactTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
    
    var contactsArray:[Contact] = []
    var delegate = UIApplication.sharedApplication().delegate
    var contactStore = CNContactStore()
    
    // Setting up for search delegate
    let searchController = UISearchController(searchResultsController: nil)
    var postData:NSData? = NSData.init()
    var searchReturnName:NSMutableArray = []
    var searchReturnID:NSMutableArray = []
    var searchReturnDescription:NSMutableArray = []
    var filteredContacts = [Contact]()
    
    
    @available(iOS 9.0, *)
    lazy var contacts: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containersMatchingPredicate(nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                results.appendContentsOf(containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchController.searchBar.tintColor = UIColor.whiteColor()
        
        var textFieldInsideSearchBar = searchController.searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        
        var textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.valueForKey("placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = UIColor.whiteColor()
        
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        setBackgroundColor()
        contactsArray = []
    }
    
    override func viewDidAppear(animated: Bool) {
        // TODO: Next, we need to pass the numbers of each of the contacts to a search function to search the backend for any matches, and if there is a match, the cell gets added to the "has Clique Music section" and the add/invite button becomes "add" and this adds the person as a friend/you start following them. Otherwise the contact gets added to the "doesn't have the  the add/invite button becomes "invite" which populates a text with a download link for the app and a username.
        print("VIEW DID APPEAR")
        
        self.requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                print ("YEAHHHH BUDDY we good to go");
                
                //print (self.contacts)
                
                for contact in self.contacts {
                    var mobileNumber = ""
                    var homeNumber = ""
                    
                    for numbers in contact.phoneNumbers {
                        //print("Here's the phone numbers label! ->", numbers.label)
                        if (numbers.label == "_$!<Mobile>!$_") {
                            // get cell phone number if there is one
                            mobileNumber = (numbers.value as! CNPhoneNumber).valueForKey("digits") as! String
                        } else if (numbers.label == "_$!<Home>!$_") {
                            // get home phone number if there is one
                            homeNumber = (numbers.value as! CNPhoneNumber).valueForKey("digits") as! String
                        }
                    }
                    
                    // If mobile number is blank, add home number for "Phone Number" key instead
                    var contactNumber = ""
                    if (mobileNumber != "") {
                        contactNumber = mobileNumber
                    } else {
                        contactNumber = homeNumber
                    }
                    
                    // Init dictionary withtwo fields: Full Name and Phone Number
                    let vars = NSMutableDictionary.init(dictionary: ["Full Name":(contact.givenName + " " + contact.familyName), "Phone Number":contactNumber])
                    
                    let fullName = contact.givenName + " " + contact.familyName
                    let phoneNumber = contactNumber
                    
                    //Create Struct
                    let newContact = Contact.init(fullName: fullName, phoneNumber: phoneNumber)
                    
                    // Add this struct to the contact name and numbers field
                    self.contactsArray.append(newContact)
                }
                
                //print("Contacts Array:",self.contactsArray)
                self.tableView.reloadData()
            } else {
                print ("aww man, no go on contacts")
            }
        }
    }
    
    // MARK: TableView Protocol
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ContactTableCell") as? ContactTableViewCell
        
        if (cell == nil) {
            let nib:NSArray = NSBundle.mainBundle().loadNibNamed("ContactTableViewCell", owner:self, options:nil)
            cell = nib.objectAtIndex(0) as? ContactTableViewCell
            cell!.contentView.layer.cornerRadius = 5
        }
        
        
        let fullNameLabel = cell!.viewWithTag(1) as! UILabel
        let phoneNumberLabel = cell!.viewWithTag(2) as! UILabel
        let userImage = cell!.viewWithTag(3) as! UIImageView
        let inviteButton = cell!.viewWithTag(4) as! UIButton
        
        let contact: Contact
        
        if searchController.active && searchController.searchBar.text != "" {
            contact = filteredContacts[indexPath.row]
        } else {
            contact = contactsArray[indexPath.row]
        }
        
        
        fullNameLabel.text = contact.fullName
        phoneNumberLabel.text = contact.phoneNumber
        
        inviteButton.addTarget(self, action: "inviteButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell!
    }
    
    
    func requestForAccess(completionHandler: (accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)
        case .Denied, .NotDetermined:
            self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.Denied {
                        print("Error in message app delegate stuff")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\n To view which of your friends has Clique, allow the app to access your contacts through the Settings."
                            print(message)
                            //self.showMessage(message)
                        })
                    }
                }
            })
            
        default:
            completionHandler(accessGranted: false)
        }
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredContacts.count
        }
        
        return contactsArray.count;
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func setBackgroundColor() {
        
        // Configure Background Color
        if(NSUserDefaults.standardUserDefaults().floatForKey("colorTheme") == 1.0) {
            // Green Theme
            self.view.backgroundColor = UIColor.init(red: 0/255, green: 175/255, blue: 50/255, alpha: 1.0)
            
        } else if(NSUserDefaults.standardUserDefaults().floatForKey("colorTheme") == 2.0) {
            // Blue Theme
            self.view.backgroundColor = UIColor.init(red: 20/255, green: 170/255, blue: 255/255, alpha: 1.0)
            
        } else if(NSUserDefaults.standardUserDefaults().floatForKey("colorTheme") == 3.0) {
            // Orange Theme
            self.view.backgroundColor = UIColor.init(red: 255/255, green: 160/255, blue: 20/255, alpha: 1.0)
            
        } else if(NSUserDefaults.standardUserDefaults().floatForKey("colorTheme") == 4.0) {
            // Pink Theme
            self.view.backgroundColor = UIColor.init(red: 255/255, green: 105/255, blue: 180/255, alpha: 1.0)
            
        } else if(NSUserDefaults.standardUserDefaults().floatForKey("colorTheme") == 5.0) {
            // Purple Theme
            self.view.backgroundColor = UIColor.init(red: 150/255, green: 0/255, blue: 255/255, alpha: 1.0)
        }
        
    }
    
    
    // MARK: Message Compose Delegate
    
    func inviteButtonPressed(sender:AnyObject) {
        
        
        print("inviteButtonPressed")
        let buttonPosition:CGPoint = sender.convertPoint(CGPointZero, toView:self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)
        
        print ("row: ", indexPath!.row)
        print("section: ", indexPath!.section)
        
        var fullName:String?
        var phoneNumber:String?
        var recipients:[String]?
        
        if searchController.active && searchController.searchBar.text != "" {
            fullName = filteredContacts[indexPath!.row].fullName
            phoneNumber = filteredContacts[indexPath!.row].phoneNumber
            //var recipients:[String]?
            if let phoneNumber = phoneNumber {
                recipients = [phoneNumber] as [String]?
                print ("here are the recipients! ", recipients)
            }
        } else {
            fullName = contactsArray[indexPath!.row].fullName
            phoneNumber = contactsArray[indexPath!.row].phoneNumber
            //var recipients:[String]?
            if let phoneNumber = phoneNumber {
                recipients = [phoneNumber] as [String]?
                print ("here are the recipients! ", recipients)
            }
        }
        
        print(fullName, " ", phoneNumber)
        if (!(MFMessageComposeViewController.canSendText())) {
            //let warningView = UIAlertView.init(title: "Error", message: "Your device doesn't support SMS!", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles:nil)
            let warningAlert = UIAlertView.init(title: "Error", message: "Your device doesn't support SMS!", delegate: nil, cancelButtonTitle: "OK")
            warningAlert.show()
            return
        }
        
        var message = "Hey, this is GLO, the app that simplifies making sure we all get home safe after a night out! AppStore: <Insert App Store Link Here>"
        
        if let fullName = fullName {
            message = "Hey \(fullName)! This is GLO, the app that simplifies making sure we all get home safe after a night out. <Insert App Store Link Here>"
        }
        
        let messageController = MFMessageComposeViewController.init()
        messageController.messageComposeDelegate = self
        
        if let recipients = recipients {
            messageController.recipients = recipients
        } else {
            messageController.recipients = [""]
        }
        
        messageController.body = message
        
        self.presentViewController(messageController, animated: true, completion: nil)
        
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result {
        case MessageComposeResultCancelled:
            print("Message Compose Result Cancelled")
            controller.dismissViewControllerAnimated(false, completion: {
                self.tableView.reloadData()
            })
            break
            
        case MessageComposeResultFailed:
            print("Message Compose Result Failed! Ruh Roh")
            let warningAlert = UIAlertView.init(title: "Error", message: "Failed to send SMS!", delegate: nil, cancelButtonTitle: "OK")
            warningAlert.show()
            controller.dismissViewControllerAnimated(false, completion: {
                self.tableView.reloadData()
            })
            break
            
        case MessageComposeResultSent:
            print("Message Sent! Aww Yiss")
            controller.dismissViewControllerAnimated(false, completion: {
                self.tableView.reloadData()
            })
            break
            
        default:
            break
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredContacts = contactsArray.filter({( contact : Contact) -> Bool in
            //let categoryMatch = (scope == "All") || (candy.category == scope)
            return contact.fullName.lowercaseString.containsString(searchText.lowercaseString)
        })
        tableView.reloadData()
    }
    
    
}



@available(iOS 9.0, *)
extension ContactTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
        //searchDatabaseForUser(searchBar.text!)
    }
}

@available(iOS 9.0, *)
extension ContactTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchController.searchBar.text!)
        //searchDatabaseForUser(searchBar.text!)
    }
}
