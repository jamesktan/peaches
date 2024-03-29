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
    fetchPrefixParameters
    
    :returns: Tuple(String,String,String,String) - A tuple contained the individual prefix elements that were added.
    */
    func fetchPrefixParameters() -> (service: AnyObject, account: AnyObject, pin: AnyObject, country: AnyObject) {
        var service : AnyObject? = NSUserDefaults.standardUserDefaults().valueForKey("service")
        if (service == nil) {service = "" }

        var account : AnyObject? = NSUserDefaults.standardUserDefaults().valueForKey("account")
        if (account == nil) {account = "" }

        var pin : AnyObject? = NSUserDefaults.standardUserDefaults().valueForKey("pin")
        if (pin == nil) {pin = "" }

        var country : AnyObject? = NSUserDefaults.standardUserDefaults().valueForKey("country")
        if (country == nil) {country = "" }

        return (service!, account!, pin!, country!)
    }
    
    /**
    setBeginningString
    
    :param: string NSString or string to store in the defaults
    */
    func setBeginningString(string: NSString, service: NSString, account: NSString, pin: NSString, country: NSString) {
        beginningString = string
        
        // Store the string locally
        NSUserDefaults.standardUserDefaults().setValue(string, forKey: "prefix")
        
        NSUserDefaults.standardUserDefaults().setValue(service, forKey: "service")
        NSUserDefaults.standardUserDefaults().setValue(account, forKey: "account")
        NSUserDefaults.standardUserDefaults().setValue(pin, forKey: "pin")
        NSUserDefaults.standardUserDefaults().setValue(country, forKey: "country")

        NSUserDefaults.standardUserDefaults().synchronize()
    }

    /**
    fetchAddressBookContacts
    
    :returns: NSMutableArray of ABContact objects. Each object contains information about the name and phone number for an individual. This is the complete addressbook including converted values.
    */
    func fetchAddressBookContacts() -> NSMutableArray {
        deleteAddressBookContacts()
        getAddressBookNames()
        
        var a = addressBookArray as Array!
        a.sort({ $1.name > $0.name })
        var c : NSMutableArray = NSMutableArray(array: a)
        
        return c
    }
    func sortAB(d1:ABContact, d2:ABContact) -> NSComparisonResult {
        return d1.name.caseInsensitiveCompare(d2.name)
    }
    /**
    deleteAddressBookContacts
    Purpose: Deletes all local contacts. Used only for debugging.
    */
    func deleteAddressBookContacts() {
        addressBookArray.removeAllObjects()
    }
    
    
    func convertPhoneNumber(person: ABContact, flag:Bool) {
        
        // Get the AddressBook
        var errorRef: Unmanaged<CFError>?
        var addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))

        // Copy All the Individuals
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        
        // Find the contact
        // @jtan : Use Predicates for this in the future.
        for record:ABRecordRef in contactList {
            //Verify Name
            var contactName: NSString = ABRecordCopyCompositeName(record).takeRetainedValue() as NSString
            if contactName.isEqualToString(person.name) {
                NSLog("Found Name")
                //Verify Number
                var contactPhone : NSArray = processPhoneList(record, name: contactName) as NSArray
                if person.phoneNumber.isEqualToArray(contactPhone) {
                    
                    // FOUND RECORD MATCH
                    // EDIT
                    // REPLACE
                    // @jtan: Turns out, you don't need to delete any records.
                    
                    var newRecord : ABRecordRef = convertPhoneNumberHelper(record, flag: flag)
                    
                    ABAddressBookAddRecord(addressBook, newRecord, &errorRef)
                    
                    break
                }
                
            }
        }
        ABAddressBookSave(addressBook,&errorRef)
    }
    
    func convertPhoneNumberHelper(record: ABRecordRef, flag: Bool) -> ABRecordRef {
        var errorRef: Unmanaged<CFError>
        
        // Get the phoneArray
        let phoneArray:ABMultiValueRef = extractABPhoneRef(ABRecordCopyValue(record, kABPersonPhoneProperty))!
        var list : NSMutableArray = []
        var listLabel : NSMutableArray = []
        for (var j = 0; j < ABMultiValueGetCount(phoneArray); ++j) {
            var phoneAdd = ABMultiValueCopyValueAtIndex(phoneArray, j)
            var phoneLabel = ABMultiValueCopyLabelAtIndex(phoneArray, j);

            var myPhone : NSString = extractABPhoneNumber(phoneAdd) as NSString!
            var phoneLabelString = phoneLabel.takeUnretainedValue() as NSString!
            
            list.addObject(myPhone)
            listLabel.addObject(phoneLabelString)
        }
        
        // Create the New List
        var newList : NSMutableArray = []
        for number in list {
            if (flag) {
                // True - Convert
                var numarr : NSArray = number.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
                var stringNoPrefix : NSString = numarr.componentsJoinedByString("")
                var string : NSString = NSString(string: beginningString + stringNoPrefix + endingString)
                newList.addObject(string)
            } else {
                // False - Revert
                var numarr : NSArray = number.componentsSeparatedByString("#")
                var index = 1
                if numarr.count < 2 {
                    index = 0 // if index is 0 we don't have the right string!
                }
                var string : NSString =  numarr.objectAtIndex(index) as NSString
                
                // Remove the string's country code, should be the first 3 numbers
                if index == 1 {
                    var range : NSRange = NSMakeRange(0,3);
                    string = string.stringByReplacingCharactersInRange(range, withString: "")
                }
                newList.addObject(string)
            }
        }

        // Compose the new ABRecord Phone List
        var phoneNumberMV : ABMutableMultiValueRef = createMultiStringRef()
        for (var i = 0; i < newList.count ; ++i) {
            var label : CFString = listLabel.objectAtIndex(i) as CFString
            ABMultiValueAddValueAndLabel(phoneNumberMV , newList.objectAtIndex(i) , label as CFString, nil);
        }
        
        ABRecordRemoveValue(record, kABPersonPhoneProperty, nil)
        ABRecordSetValue(record, kABPersonPhoneProperty, phoneNumberMV, nil)
        
        return record
    }

    
    /**
    /**
    Below this are some lower level functions
    */
    */
    
    func getPermission() -> Bool {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        if (authorizationStatus == ABAuthorizationStatus.NotDetermined)
        {
            NSLog("requesting access...")
            var emptyDictionary: CFDictionaryRef?
            var addressBook = !(ABAddressBookCreateWithOptions(emptyDictionary, nil) != nil)
            ABAddressBookRequestAccessWithCompletion(addressBook,{success, error in
            })
        }
        
        if (authorizationStatus == ABAuthorizationStatus.Denied || authorizationStatus == ABAuthorizationStatus.Restricted) {
            return false
        } else {
            return true
        }
    }
    
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
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeopleInSource(addressBook, ABAddressBookCopyDefaultSource(addressBook).takeRetainedValue()).takeRetainedValue()
        
        // Process the Records
        for record:ABRecordRef in contactList {
            let first = ABRecordCopyValue(record, kABPersonFirstNameProperty)?.takeRetainedValue() as String?
            let last  = ABRecordCopyValue(record, kABPersonLastNameProperty)?.takeRetainedValue() as String?
            let nick  = ABRecordCopyValue(record, kABPersonNicknameProperty)?.takeRetainedValue() as String?

            if first != nil {
                processAddressbookRecord(record)
            } else if last != nil {
                processAddressbookRecord(record)
            } else if nick != nil {
                processAddressbookRecord(record)
            } else {
                
                println("JTAN: contact has no name")
            }
        }
    }
    
    /**
    processAddressbookRecord
    
    :param: addressBookRecord ABRecordRef - an AddressBook Framework object for a Contact
    */
    func processAddressbookRecord(addressBookRecord: ABRecordRef) {
        var contactName = ABRecordCopyCompositeName(addressBookRecord).takeRetainedValue()
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
        
        if list.count == 0 {
            println("JTAN: no contacts! skip!")
            return
        }
        
        var c : ABContact = ABContact()
        c.name = name
        c.phoneNumber = list
        addressBookArray.addObject(c)

    }
    
    /**
    processPhoneList
    
    :param: addressBookRecord ABRecordRef - an AddressBook Framework Object for a Contact
    :param: name              NSString - the name of the contact to whom the number belongs
    
    :returns: NSMutableArray - A list of phone numbers
    */
    func processPhoneList(addressBookRecord:ABRecordRef, name: NSString) ->NSMutableArray {
        let phoneArray:ABMultiValueRef = extractABPhoneRef(ABRecordCopyValue(addressBookRecord, kABPersonPhoneProperty))!
        
        var list : NSMutableArray = []
        for (var j = 0; j < ABMultiValueGetCount(phoneArray); ++j) {
            var phoneAdd = ABMultiValueCopyValueAtIndex(phoneArray, j)
            if phoneAdd != nil {
                var myPhone : NSString = extractABPhoneNumber(phoneAdd) as NSString!
                list.addObject(myPhone)

            }
        }
        
        return list
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
    
    func createMultiStringRef() -> ABMutableMultiValueRef {
        let propertyType: NSNumber = kABMultiStringPropertyType
        return Unmanaged.fromOpaque(ABMultiValueCreateMutable(propertyType.unsignedIntValue).toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
    }


}
