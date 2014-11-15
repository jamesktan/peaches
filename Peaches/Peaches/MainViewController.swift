//
//  ViewController.swift
//  Peaches
//
//  Created by James Tan on 11/11/14.
//  Copyright (c) 2014 Axon Flux. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var test: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(animated:Bool) {
        if (!ABManager.sharedInstance.getPermission()) {
            UIAlertView(title: "Permissions Denied", message: "You denied permission for this application to edit your Address Book. Please grant permission in your Settings -> Privacy -> Contacts. ", delegate: nil, cancelButtonTitle: "Okay").show()
        }
    }
    @IBAction func a_credentials(sender: AnyObject) {
        self.performSegueWithIdentifier("editCredentials", sender: self)
    }
    
    @IBAction func a_convert(sender: AnyObject) {
        self.performSegueWithIdentifier("convertAB", sender: self)
    }
    
    @IBAction func a_remove(sender: AnyObject) {
        self.performSegueWithIdentifier("removeAB", sender: self)
    }
    
    @IBAction func a_how(sender: AnyObject) {
        self.performSegueWithIdentifier("howTo", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

