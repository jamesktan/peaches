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
    var phoneNumber : NSString = ""
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
    fetchAddressBookContacts
    
    :returns: NSMutableArray of ABContact objects. Each object contains information about the name and phone number for an individual. This is the complete addressbook including converted values.
    */
    func fetchAddressBookContacts() -> NSMutableArray {
        if (addressBookArray.count == 0) {
            addressBookArray = getAddressBookNames()
        }
        return addressBookArray
    }
    
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
    
    func processContactNames()
    {
        var errorRef: Unmanaged<CFError>?
        var addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        println("records in the array \(contactList.count)")
        
        for record:ABRecordRef in contactList {
            processAddressbookRecord(record)
            
            var v : ABContact = ABContact()
            
            
            NSLog("--------")
        }
    }
    
    func processAddressbookRecord(addressBookRecord: ABRecordRef) {
        var contactName: String = ABRecordCopyCompositeName(addressBookRecord).takeRetainedValue() as NSString
        processPhone(addressBookRecord, name: contactName)
    }
    
    func processPhone(addressBookRecord:ABRecordRef, name: NSString) {
        let phoneArray:ABMultiValueRef = extractABPhoneRef(ABRecordCopyValue(addressBookRecord, kABPersonPhoneProperty))!
        for (var j = 0; j < ABMultiValueGetCount(phoneArray); ++j) {
            var phoneAdd = ABMultiValueCopyValueAtIndex(phoneArray, j)
            var myPhone = extractABPhoneNumber(phoneAdd)
            
            var c : ABContact = ABContact()
            c.name = name
            c.phoneNumber = myPhone as NSString!
            addressBookArray.addObject(c)
            
        }
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
