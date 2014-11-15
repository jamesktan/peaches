//
//  EditCredsViewController.swift
//  Peaches
//
//  Created by James Tan on 11/12/14.
//  Copyright (c) 2014 Axon Flux. All rights reserved.
//

import UIKit

class EditCredsViewController: UIViewController {

    @IBOutlet var tf_all: [UITextField]!
    
    @IBOutlet weak var l_stringDisplay: UILabel!
    @IBOutlet weak var tf_serviceNumber: UITextField!
    @IBOutlet weak var tf_accountNumber: UITextField!
    @IBOutlet weak var tf_pinCode: UITextField!
    @IBOutlet weak var tf_countryCode: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Have them all intercept the trigger
        tf_all.map({$0.addTarget(self, action: "a_updateTextEvents:", forControlEvents: UIControlEvents.EditingChanged)})
        
    }
    
    override func viewWillAppear(animated:Bool) {
        
        // Set the proper string on setup
        l_stringDisplay.text = ABManager.sharedInstance.fetchBeginningString() as NSString!
        
        var prefixComponents = ABManager.sharedInstance.fetchPrefixParameters()
        tf_serviceNumber.text = prefixComponents.service as NSString
        tf_accountNumber.text = prefixComponents.account as NSString
        tf_pinCode.text = prefixComponents.pin as NSString
        tf_countryCode.text = prefixComponents.country as NSString

        if (!ABManager.sharedInstance.getPermission()) {
            UIAlertView(title: "Permissions Denied", message: "You denied permission for this application to edit your Address Book. Please grant permission in your Settings -> Privacy -> Contacts. ", delegate: nil, cancelButtonTitle: "Okay").show()
        }

    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        tf_all.map({$0.resignFirstResponder()})
    }

    @IBAction func a_updateTextEvents(sender: AnyObject) {
        var string : NSString = NSString(string: "")
        string = string.stringByAppendingString(tf_serviceNumber.text).stringByAppendingString(",")
        string = string.stringByAppendingString(tf_accountNumber.text).stringByAppendingString(tf_pinCode.text).stringByAppendingString("#")
        string = string.stringByAppendingString(tf_countryCode.text)
        l_stringDisplay.text = string
        
        ABManager.sharedInstance.setBeginningString(string, service: tf_serviceNumber.text, account: tf_accountNumber.text, pin: tf_pinCode.text, country: tf_countryCode.text)
        
    }

    @IBAction func a_dismissSelf(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        tf_all.map({$0.resignFirstResponder()})
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
