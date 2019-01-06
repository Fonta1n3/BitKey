//
//  walletSaver.swift
//  BitKeys
//
//  Created by Peter on 6/16/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import Foundation
import CoreData
import SwiftKeychainWrapper
import AES256CBC

public func saveWallet(viewController: UIViewController, mnemonic: String, xpub: String, address: String, privateKey: String, publicKey: String, redemptionScript: String, network: String, type: String, index: UInt32, label: String, xpriv: String) -> Bool {
    
    print("saveWallet")
    
    var success = Bool()
    
    let aesPassword = KeychainWrapper.standard.string(forKey: "AESPassword")
    
    let keys = ["mnemonic", "xpub", "address", "balance", "label", "network", "privateKey", "publicKey", "redemptionScript", "type", "index", "xpriv"]
        
    var mn = mnemonic
    var pk = privateKey
    var xp = xpub
    var xpk = xpriv
    
    if xpk != "" {
        xpk = AES256CBC.encryptString(xpk, password: aesPassword!)!
    }
        
    if xp != "" {
        xp = AES256CBC.encryptString(xp, password: aesPassword!)!
    }
        
    if pk != "" {
        pk = AES256CBC.encryptString(pk, password: aesPassword!)!
            
    }
        
    if mn != "" {
            
        mn = AES256CBC.encryptString(mn, password: aesPassword!)!
            
    }
        
    let values = [mn, xp, address, "", label, network, pk, publicKey, redemptionScript, type, index, xpk] as [Any]
    var alreadySaved = Bool()
    
    var appDelegate = AppDelegate()
        
    if let appDelegateCheck = UIApplication.shared.delegate as? AppDelegate {
            
        appDelegate = appDelegateCheck
            
    } else {
            
        displayAlert(viewController: viewController, title: "Error", message: "Something strange has happened and we do not have access to app delegate, please try again.")
        success = false
            
    }
        
    let context = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AddressBook")
    fetchRequest.returnsObjectsAsFaults = false
        
    do {
            
        let results = try context.fetch(fetchRequest) as [NSManagedObject]
            
        if results.count > 0 {
                
            for data in results {
                    
                for _ in keys {
                        
                    if (values[2] as! String) == data.value(forKey: "address") as? String {
                            
                        alreadySaved = true
                        displayAlert(viewController: viewController, title: "Error", message: "Can not save the same address to your Address Book more then once, please delete the old wallet and try again.")
                        success = false
                            
                    }
                        
                }
                    
            }
                
            if alreadySaved != true {
                    
                let entity = NSEntityDescription.entity(forEntityName: "AddressBook", in: context)
                let myAddressBook = NSManagedObject(entity: entity!, insertInto: context)
                    
                    
                for (index, key) in keys.enumerated() {
                        
                    myAddressBook.setValue(values[index], forKey: key)
                        
                    do {
                            
                        try context.save()
                        success = true
                            
                    } catch {
                            
                        print("Failed saving")
                        success = false
                    }
                }
                    
            }
                
        } else {
                
            print("no results so create one")
                
            let entity = NSEntityDescription.entity(forEntityName: "AddressBook", in: context)
            let myAddressBook = NSManagedObject(entity: entity!, insertInto: context)
                
                
            for (index, key) in keys.enumerated() {
                    
                myAddressBook.setValue(values[index], forKey: key)
                    
                do {
                        
                    try context.save()
                    success = true
                        
                } catch {
                        
                    print("Failed saving")
                    success = false
                        
                }
            }
                
        }
            
    } catch {
            
        print("Failed")
            
    }
        
    return success
    
}
