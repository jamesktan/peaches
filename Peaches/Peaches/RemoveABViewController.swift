//
//  RemoveABViewController.swift
//  Peaches
//
//  Created by James Tan on 11/12/14.
//  Copyright (c) 2014 Axon Flux. All rights reserved.
//

import UIKit

class RemoveABViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var ab_removeTable: UITableView!
    var ab : NSMutableArray = []
    var ab_selected : NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        ab_removeTable.delegate = self
        ab_removeTable.dataSource = self
        
        ab = ABManager.sharedInstance.fetchAddressBookContacts()
        ab_removeTable.reloadData()

    }

    @IBAction func a_dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func a_revert(sender: AnyObject) {
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /**
    *  
    /**
    *
    */
    */
    // MARK: - Table View Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ab.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Create the Cell
        var cell : UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: ab.objectAtIndex(indexPath.row).phoneNumber? )
        
        // Create the Labels
        cell.textLabel.text = ab.objectAtIndex(indexPath.row).name as NSString!
        cell.detailTextLabel?.text = ab.objectAtIndex(indexPath.row).phoneNumber as NSString!
        
        // Style the Cell
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.textLabel.font = UIFont(name: "GillSans", size: 16)
        cell.detailTextLabel?.font = UIFont(name: "GillSans", size: 14)
        
        // Toggle the Right Cell
        var abSelectedArray : Array = ab_selected as Array!
        var c = abSelectedArray.filter({$0.phoneNumber == cell.reuseIdentifier})
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
        
        ab_removeTable.deselectRowAtIndexPath(indexPath, animated: true)
        
        
    }
}
