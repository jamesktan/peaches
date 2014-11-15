//
//  ConvertABViewController.swift
//  Peaches
//
//  Created by James Tan on 11/12/14.
//  Copyright (c) 2014 Axon Flux. All rights reserved.
//

import UIKit

class ConvertABViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tv_abTable: UITableView!
    var ab : NSMutableArray = []
    var ab_selected : NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tv_abTable.delegate = self
        tv_abTable.dataSource = self
        
        ab = ABManager.sharedInstance.fetchAddressBookContacts()
        tv_abTable.reloadData()
    }

    @IBAction func a_dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
    a_convert
    Purpose: Convert the contacts on button click and then dismiss the user and prompt them about success
    :param: sender The Button on the UI
    */
    @IBAction func a_convert(sender: AnyObject) {
        // No Selection
        if (ab_selected.count == 0) {
            UIAlertView(title: "No contacts selected!", message: "Please select some contacts to transform.", delegate: nil, cancelButtonTitle: "Okay").show()
            return
        }
        // No Prefix
        if (ABManager.sharedInstance.beginningString.isEqualToString("")) {
            UIAlertView(title: "No prefix detected!", message: "You haven't configured a prefix yet!", delegate: nil, cancelButtonTitle: "Okay").show()
            return

        }
        
        // True - Convert the Number
        for bee in ab_selected {
            ABManager.sharedInstance.convertPhoneNumber(bee as ABContact, flag: true)
        }
        self.dismissViewControllerAnimated(true, completion: {
            UIAlertView(title: "Success!", message: "You successfully converted your contacts!", delegate: nil, cancelButtonTitle: "Okay").show()
        })
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// MARK: - Table View Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ab.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var contact = ab.objectAtIndex(indexPath.row) as ABContact

        // Create the Cell
        var cell : UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: contact.name)
        
        // Create the Labels
        cell.textLabel.text = contact.name as NSString!
        cell.detailTextLabel?.text = contact.phoneNumber.objectAtIndex(0) as NSString
        
        // Style the Cell
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.textLabel.font = UIFont(name: "GillSans", size: 16)
        cell.detailTextLabel?.font = UIFont(name: "GillSans", size: 14)
        
        // Toggle the Right Cell
        var abSelectedArray : Array = ab_selected as Array!
        var c = abSelectedArray.filter({$0.name == cell.reuseIdentifier})
        if (c.count > 0) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if (cell.accessoryType == UITableViewCellAccessoryType.Checkmark) {
            cell.accessoryType = UITableViewCellAccessoryType.None
            ab_selected.removeObject(ab.objectAtIndex(indexPath.row))
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            ab_selected.addObject(ab.objectAtIndex(indexPath.row))
        }
        
        tv_abTable.deselectRowAtIndexPath(indexPath, animated: true)

        
    }

}
