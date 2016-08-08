//
//  CreateOutingViewController.swift
//  GLO
//
//  Created by Stephen Looney on 7/10/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class CreateOutingViewController:UIViewController,UIScrollViewDelegate, UITextFieldDelegate {
    
    struct WuTang {
        
        let name: String
        let image: String
        let description: String
        
        static func all() -> [WuTang] {
            return [
                WuTang(name: "RZA", image: "RZA", description: "The master of the Wu-Tang Clan, the beatsmith himself, Robert Fitzgerald “RZA” Diggs came to define the Wu sound throughout its rise. He has produced almost all of Wu-Tang Clan's albums as well as many Wu-Tang solo and affiliate projects. He is a cousin of the late group-mate, Ol' Dirty Bastard and GZA (who also formed the group with RZA). He has also released solo albums under the alter-ego Bobby Digital, along with executive producing credits for side projects."),
                
                WuTang(name: "GZA", image: "GZA", description: "The Genious. A founding member of the hip hop group the Wu-Tang Clan, GZA is known as the group's 'spiritual head', being both the oldest and the first within the group to receive a record deal. He has appeared on his fellow Clan members' solo projects, and since the release of his critically acclaimed solo album Liquid Swords (1995), he has maintained a successful solo career."),
                
                WuTang(name: "Ol'Dirty Bastard", image: "OlDirty", description: "Russell Tyrone Jones (November 15, 1968 – November 13, 2004),[2] better known under his stage name Ol' Dirty Bastard (or ODB), was an American rapper, producer and one of the founding members of the Wu-Tang Clan. ODB was often noted for his trademark microphone techniques and his 'outrageously profane, free-associative rhymes delivered in a distinctive half-rapped, half-sung style'. His stage name was derived from the 1980 martial arts film Ol' Dirty and the Bastard (also called An Old Kung Fu Master, starring Yuen Siu-tien)."),
                
                WuTang(name: "Inspectah Deck", image: "Inspectah.jpg", description: "Jason Hunter (born July 6, 1970) aka Inspectah Deck, is an American rapper, producer, and member of the Wu-Tang Clan. He has acquired critical praise for his intricate lyricism, and for his verses on many of the group's most revered songs (see: 'Triumph'). He has grown to become a producer in his own right, taking up tracks for fellow clansmen and his own projects."),
                
                WuTang(name: "Raekwon the Chef", image: "Raekwon.jpg", description: "Corey Woods, or Raekwon, is a rapper and a member of the Wu-Tang Clan. He released his solo debut, Only Built 4 Cuban Linx… in 1995, and has since recorded four solo albums, as well as work with Wu-Tang and an extensive amount of guest contributions with other hip hop artists. Raekwon is often cited as one of the pioneers of the Mafioso rap sub-genre. In 2007, The editors of About.com placed him on their list of the Top 50 MCs of Our Time. The Miami New Times described Raekwon’s music as being street epics that are 'straightforward yet linguistically rich universes not unlike a gangsta Illiad.'"),
                
                WuTang(name: "U-God", image: "UGOD.jpg", description: "Lamont Jody Hawkins[1] (born October 11, 1970),[2] better known as U-God (short for Universal God), is an American rapper and member of the hip hop collective, Wu-Tang Clan. He has been with the group since its inception, and is known for having a deep, rhythmic flow that can alternate between being gruff or smooth."),
                
                WuTang(name: "Ghostface Killah", image: "Ghostface.jpg", description: "Ghostface Killah, born Dennis Coles, is a Staten Island rapper and member of the Wu-Tang Clan, known for both his work with Wu-Tang and his extensive solo career. Ghostface is known for his dense flow style, his stream-of-consciousness storytelling, and his emotive delivery. Ghostface was also the co-star of Raekwon’s critically acclaimed 1995 Only Built 4 Cuban Linx… album, and followed it soon with his own 1996 solo debut, Ironman His 2000 sophomore album Supreme Clientele is widely regarded as one of the best Wu Tang solo projects. Since then, he’s continued to evolve, from his gambino-themed 2006 album Fishscale, to his collaboration with BADBADNOTGOOD, 2015’s Sour Soul. His name is taken from the villain in 1979 martial arts film Mystery of Chessboxing."),
                
                WuTang(name: "The Method Man", image: "MethodMan.jpg", description: "Clifford Smith (born March 2,[2] 1971), better known by his stage name Method Man, is an American rapper, record producer, and actor. He took his stage name from the 1979 film Method Man. He is perhaps best known as a member of the East Coast hip hop collective Wu-Tang Clan. He is also one half of the hip hop duo Method Man & Redman. In 1996, he won a Grammy Award for Best Rap Performance by a Duo or Group, for 'I'll Be There for You/You're All I Need to Get By', with American R&B singer-songwriter Mary J. Blige"),
                
                WuTang(name: "Cappadonna", image: "cappadonna.jpg", description: "The 'unofficial official' tenth member of the Wu-Tang Clan, Cappadonna has been there since the beginning. During the formative years of the Clan, Cappa was slated to become a core member until he landed behind bars and was replaced by the Method Man. Like other members of the group, Cappa’s name also has a hidden meaning behind an acronym. Consider All Poor People Acceptable Don’t Oppress Nor Neglect Anyone is the full meaning behind Cappachino’s name. First appearing on Ghostface Killah’s classic joint “Ice Cream,” Cappadonna has gone on to drop nine solo albums and numerous other collaborations."),
                
                WuTang(name: "Masta Killa", image: "MastaKilla.jpg", description:"Jamel Irief (born Elgin Turner; August 18, 1969), better known by his stage name Masta Killa, is an American rapper and member of the Wu-Tang Clan.[2] Though one of the lesser-known members of the group (he was featured on only one track on their 1993 debut album Enter the Wu-Tang (36 Chambers)), he has been prolific on Clan group albums and solo projects since the mid-1990s. He released his debut album No Said Date in 2004 to positive reviews, and has since released two additional albums.")
            ]
        }
    }

    
    let members = WuTang.all()
    
    @IBOutlet var outingNameTextField: UITextField!
    @IBOutlet var addMemberButton: UIButton!
    @IBOutlet var memberScrollView: UIScrollView!
    @IBOutlet var destinationTextField: UITextField!
    @IBOutlet var mapImageView: UIImageView!
    @IBOutlet var curfewTimePicker: UIDatePicker!
    @IBOutlet var createOutingButton: UIButton!
    
    var dismissBlock:(() -> Void)! = {}
    
    var postData:NSData? = NSData.init()
    
    
    init() {
       super.init(nibName: nil, bundle: nil)
        print("init")
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        addMemberButton.layer.cornerRadius = 15.0
        createOutingButton.layer.cornerRadius = 8.0
        mapImageView.layer.cornerRadius = 10.0
        
        outingNameTextField.delegate = self
        destinationTextField.delegate = self
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("CreateOutingView will appear")
        // Set up the member scroll view
        if memberScrollView.subviews.count < members.count {
            memberScrollView.viewWithTag(0)?.tag = 1000 //prevent confusion when looking up images
            setupList()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        print("bye felicia")
        // TODO: Handle closing out this view
        
    }
    
    @IBAction func createOutingButtonPressed(sender: AnyObject) {
        
        if ((destinationTextField.text == "") || (outingNameTextField.text == "")) {
            
            let a = UIAlertController.init(title: "Add a name and destination please!" , message: "What's a party without a venue, and what's an outing without a name? Go on, fill out the deets please.", preferredStyle: .Alert)
            
            //a.view.backgroundColor = UIColor.blackColor()
            //a.view.tintColor = UIColor.blueColor()
            
            let okAction = UIAlertAction(title: "Got It", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                print("Pressed OK Block")
            }
            
            a.addAction(okAction)
            
            self.presentViewController(a, animated: true, completion: nil)
            
        } else {
            // TODO: This is where the API hit will get called to POST the data (destination for now)
            postOuting(outingNameTextField.text!, destination: destinationTextField.text!)
            self.dismissViewControllerAnimated(true, completion: dismissBlock)
        }
    }
    
    func postOuting(name:String, destination:String) {
        
            // TODO: Consider moving this request to CliqueDataStore so other classes can call it.
            //Set postData as nil just in case it had some other value
            postData = nil
        
            // TODO: Below can be replaced with cliqueObject.
        let vars = NSMutableDictionary.init(dictionary: ["name":name, "destination":destination])
        
            
            do {
                postData = try NSJSONSerialization.dataWithJSONObject(vars, options: NSJSONWritingOptions(rawValue:0))
            } catch {
                print("Error with NSJSONSerialization in CliqueDataStore.getOneClique!")
            }
            var postLength = ""
            if let postData = postData {
                postLength = String("%lu", postData.length)
            }
            
            // Next initialize the request
            let request = NSMutableURLRequest.init()
            request.URL = CFURLCreateWithString(nil, "https://pure-caverns-99011.herokuapp.com/createOuting", nil)
            request.HTTPMethod = "POST"
            request.setValue(postLength, forHTTPHeaderField: "Content-Length")
            request.HTTPBody = postData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let returnArray:NSMutableArray = []
            
            // Execute the request
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
                
                guard error == nil && data != nil else {
                    // check for fundamental networking error
                    print("error=\(error)")
                    return
                }
                
                let requestReply = NSString.init(data: data!, encoding: NSASCIIStringEncoding)
                print("postCreateOuting reply:", requestReply)
                
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSMutableDictionary
                    print("postCreateOuting JSON response ->", json)
                    
                    // TODO: May want to include a dismiss block to handle the data beyond this
                    //self.updateCliqueTrackArrayBlock() // updates CliqueSongID Array data
                    /*
                     dispatch_async(dispatch_get_main_queue(), {
                     self.tableView.reloadData()
                     self.viewDidLoad()
                     })
                     */
                } catch {
                    print("Something went wrong, better figure it out derp")
                    //self.searchReturnName.removeAllObjects()
                    //self.searchReturnID.removeAllObjects()
                    dispatch_async(dispatch_get_main_queue(), {
                        // self.tableView.reloadData()
                    })
                }
            }
            task.resume()
        }

    
    func setupList() {
        print("Setup List Items")
        for i in 0 ..< members.count {
            
            //create image view
            let imageView  = UIImageView(image: UIImage(named: members[i].image))
            imageView.tag = i
            imageView.contentMode = .ScaleAspectFill
            imageView.userInteractionEnabled = true
            imageView.layer.cornerRadius = 20.0
            imageView.layer.masksToBounds = true
            memberScrollView.addSubview(imageView)
            
            //attach tap detector
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("didTapImageView:")))
        }
        
        memberScrollView.backgroundColor = UIColor.clearColor()
        positionListItems()
    }
    
    //position all images inside the list
    func positionListItems() {
        print("Posistion List Items")
        let ratio = view.frame.size.height / view.frame.size.width
        print("ratio:", ratio)
        let itemHeight: CGFloat = memberScrollView.frame.height * 1.25
        let itemWidth: CGFloat = itemHeight / ratio
        
        let horizontalPadding: CGFloat = 10.0
        memberScrollView.contentSize = CGSize(
            width: CGFloat(members.count) * (itemWidth + horizontalPadding) + horizontalPadding,
            height:  0)
        print(members)
        for i in 0 ..< members.count {
            let imageView = memberScrollView.viewWithTag(i) as! UIImageView
            imageView.frame = CGRect(
                x: CGFloat(i) * itemWidth + CGFloat(i+1) * horizontalPadding, y: 0.0,
                width: itemWidth, height: itemHeight)
            print(i, imageView.frame)
        }
        
    }
    
    func didTapImageView(sender: AnyObject) {
        print("tapped the image")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }


    
    
    
}