//
//  ViewController.swift
//  Peaches
//
//  Created by James Tan on 11/11/14.
//  Copyright (c) 2014 Axon Flux. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var test: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dial(sender: AnyObject) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: "tel:3000,734224")!)
    }

}

