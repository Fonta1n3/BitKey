//
//  saveMultiSig.swift
//  BitKeys
//
//  Created by Peter on 7/16/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import Foundation
import CoreData

public func saveMultiSigWallet(viewController: UIViewController, mnemonic: String, xpub: String, address: String, privateKeys: String, publicKeys: String, redemptionScript: String, network: String, type: String, index: UInt32, label: String, xpriv: String) -> Bool {
    
    print("saveWallet")
    
    var success = Bool()
    
    let keys = ["mnemonic", "xpub", "address", "balance", "label", "network", "privateKey", "publicKey", "redemptionScript", "type", "index", "xpriv"]
    
    
    
    let values = ["", "", address, "", "", network, privateKeys, publicKeys, redemptionScript, type, index, ""] as [Any]
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
                    
                    if (values[0] as! String) == data.value(forKey: "address") as? String {
                        
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

