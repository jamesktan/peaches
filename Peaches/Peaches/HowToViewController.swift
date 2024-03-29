//
//  HowToViewController.swift
//  Peaches
//
//  Created by James Tan on 11/12/14.
//  Copyright (c) 2014 Axon Flux. All rights reserved.
//

import UIKit

class HowToViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!ABManager.sharedInstance.getPermission()) {
            UIAlertView(title: "Permissions Denied", message: "You denied permission for this application to edit your Address Book. Please grant permission in your Settings -> Privacy -> Contacts. ", delegate: nil, cancelButtonTitle: "Okay").show()
        }


        // Do any additional setup after loading the view.
    }

    @IBAction func a_dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
