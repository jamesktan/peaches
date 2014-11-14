//
//  ABManager.swift
//  Peaches
//
//  Created by James Tan on 11/12/14.
//  Copyright (c) 2014 Axon Flux. All rights reserved.
//

import UIKit
import AddressBook

extension UIViewController {
    func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

class ABContact : NSObject {
    var name : NSString = ""
    var phoneNumber : NSArray = []
}

class ABManager: NSObject {
    
    var beginningString : NSString = ""
    var endingString : NSString = "#"
    var addressBookArray : NSMutableArray = []
    
    /// Singleton Design Pattern
    /// Return the Shared Instance
    class var sharedInstance : ABManager {
        struct Static {
            static let instance : ABManager = ABManager()
        }
        return Static.instance
    }
    
    /**
    fetchBeginningString
    
    :returns: Pass back the stored value of the string or don't pass back anything. In the process, set the state variable.
    */
    func fetchBeginningString() -> NSString! {
        var x : NSString = NSString(string:"None")
        
        var ret: AnyObject? = NSUserDefaults.standardUserDefaults().valueForKey("prefix")
        
        if (ret != nil) {
            beginningString = ret as NSString!
            return ret as NSString!
        } else {
            return x
        }
    }
    
    /**
    setBeginningString
    
    :param: string NSString or string to store in the defaults
    */
    func setBeginningString(string: NSString) {
        beginningString = string
        
        // Store the string locally
        NSUserDefaults.standardUserDefaults().setValue(string, forKey: "prefix")
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    /**
    fetchAddressBookContacts
    
    :returns: NSMutableArray of ABContact objects. Each object contains information about the name and phone number for an individual. This is the complete addressbook including converted values.
    */
    func fetchAddressBookContacts() -> NSMutableArray {
        if (addressBookArray.count == 0) {
            getAddressBookNames()
        }
        return addressBookArray
    }
    func deleteAddressBookContacts() {
        addressBookArray.removeAllObjects()
    }
    func convertPhoneNumber(person: ABContact) {
        
    }
    func revertPhoneNumber(person:ABContact) {
        
    }
    
    
    /**
    /**
    Description
    */
    */
    
    
    /**
    getAddressBookNames
    Purpose: to get access to the user's addressbook.
    */
    func getAddressBookNames() {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        if (authorizationStatus == ABAuthorizationStatus.NotDetermined)
        {
            NSLog("requesting access...")
            var emptyDictionary: CFDictionaryRef?
            var addressBook = !(ABAddressBookCreateWithOptions(emptyDictionary, nil) != nil)
            ABAddressBookRequestAccessWithCompletion(addressBook,{success, error in
                if success {
                    self.processContactNames();
                }
                else {
                    NSLog("unable to request access")
                }
            })
        }
        else if (authorizationStatus == ABAuthorizationStatus.Denied || authorizationStatus == ABAuthorizationStatus.Restricted) {
            NSLog("access denied")
        }
        else if (authorizationStatus == ABAuthorizationStatus.Authorized) {
            NSLog("access granted")
            processContactNames()
        }
    }
    
    /**
    processContactNames
    Purpose: to generate contacts for the addressbook
    */
    func processContactNames()
    {
        var errorRef: Unmanaged<CFError>?
        var addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        
        // Compose a List of Contacts
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()

        // Process the Records
        for record:ABRecordRef in contactList {
            processAddressbookRecord(record)
        }
    }
    
    /**
    processAddressbookRecord
    
    :param: addressBookRecord ABRecordRef - an AddressBook Framework object for a Contact
    */
    func processAddressbookRecord(addressBookRecord: ABRecordRef) {
        var contactName: String = ABRecordCopyCompositeName(addressBookRecord).takeRetainedValue() as NSString
        processPhone(addressBookRecord, name: contactName)
    }
    
    /**
    processPhone
    
    :param: addressBookRecord ABRecordRef - an AddressBook Framework Object for a Contact
    :param: name              NSString - the name of the contact to whome the number belongs to
    */
    func processPhone(addressBookRecord:ABRecordRef, name: NSString) {
        let phoneArray:ABMultiValueRef = extractABPhoneRef(ABRecordCopyValue(addressBookRecord, kABPersonPhoneProperty))!
        
        var list : NSMutableArray = []
        for (var j = 0; j < ABMultiValueGetCount(phoneArray); ++j) {
            var phoneAdd = ABMultiValueCopyValueAtIndex(phoneArray, j)
            var myPhone : NSString = extractABPhoneNumber(phoneAdd) as NSString!
            list.addObject(myPhone)
        }
        
        var c : ABContact = ABContact()
        c.name = name
        c.phoneNumber = list
        addressBookArray.addObject(c)

    }
    
    func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    func extractABPhoneRef (abPhoneRef: Unmanaged<ABMultiValueRef>!) -> ABMultiValueRef? {
        if let ab = abPhoneRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    func extractABPhoneNumber(abPhoneNumber: Unmanaged<AnyObject>!) -> String? {
        if let ab = abPhoneNumber {
            return Unmanaged.fromOpaque(abPhoneNumber.toOpaque()).takeUnretainedValue() as CFStringRef
        }
        return nil
    }

}
