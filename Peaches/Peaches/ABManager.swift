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
class ABManager: NSObject {
    /**
    getAddressBookNames
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
    
    func processContactNames()
    {
        var errorRef: Unmanaged<CFError>?
        var addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        println("records in the array \(contactList.count)")
        
        for record:ABRecordRef in contactList {
            processAddressbookRecord(record)
            NSLog("--------")
        }
    }
    
    func processAddressbookRecord(addressBookRecord: ABRecordRef) {
        var contactName: String = ABRecordCopyCompositeName(addressBookRecord).takeRetainedValue() as NSString
        NSLog("contactName: \(contactName)")
        processEmail(addressBookRecord)
        processPhone(addressBookRecord)
    }
    
    func processEmail(addressBookRecord: ABRecordRef) {
        let emailArray:ABMultiValueRef = extractABEmailRef(ABRecordCopyValue(addressBookRecord, kABPersonEmailProperty))!
        for (var j = 0; j < ABMultiValueGetCount(emailArray); ++j) {
            var emailAdd = ABMultiValueCopyValueAtIndex(emailArray, j)
            var myString = extractABEmailAddress(emailAdd)
            NSLog("email: \(myString)")
        }
    }
    
    func processPhone(addressBookRecord:ABRecordRef) {
        let phoneArray:ABMultiValueRef = extractABEmailRef(ABRecordCopyValue(addressBookRecord, kABPersonPhoneProperty))!
        for (var j = 0; j < ABMultiValueGetCount(phoneArray); ++j) {
            var phoneAdd = ABMultiValueCopyValueAtIndex(phoneArray, j)
            var myString = extractABPhoneNumber(phoneAdd)
            NSLog("phone: \(myString)")
        }
    }
    
    func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    func extractABEmailRef (abEmailRef: Unmanaged<ABMultiValueRef>!) -> ABMultiValueRef? {
        if let ab = abEmailRef {
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
    
    func extractABEmailAddress (abEmailAddress: Unmanaged<AnyObject>!) -> String? {
        if let ab = abEmailAddress {
            return Unmanaged.fromOpaque(abEmailAddress.toOpaque()).takeUnretainedValue() as CFStringRef
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
