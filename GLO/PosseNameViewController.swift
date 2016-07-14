//
//  PosseNameViewController.swift
//  
//
//  Created by Toph on 7/9/16.
//
//

import UIKit

class PosseNameViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var posseTextfield: UITextField!
    
    
    init(){
        super.init(nibName: nil, bundle: nil)
        
        let navItem = self.navigationItem
        
        let cancelBtn = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelButton))
        
        navItem.leftBarButtonItem = cancelBtn
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.posseTextfield.delegate = self
        
    }
    
    
    //MARK: BUTTON ACTION METHODS
    
    func cancelButton(){
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func createButtonPressed(sender: AnyObject) {
        
        
        
        
        if !posseTextfield.text!.isEmpty {
            
            let cvc = ContactsViewController.init()
            self.navigationController?.pushViewController(cvc, animated: true)
            
        } else {
            
            let alert = UIAlertController(title: "Hold on there!", message: "You've gotta gimme a Posse Name", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    
    
    //MARK: DELEGATE METHODS
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.posseTextfield.endEditing(true)
        
        return false
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        self.posseTextfield.endEditing(true)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
