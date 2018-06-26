//
//  walletSaver.swift
//  BitKeys
//
//  Created by Peter on 6/16/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import Foundation
import CoreData

public func saveWallet(viewController: UIViewController, address: String, privateKey: String, publicKey: String, redemptionScript: String, network: String, type: String) {
    
    print("saveWallet")
    
    var addressBook = [[String: Any]]()
    var addressAlreadySaved = Bool()
    
    if UserDefaults.standard.object(forKey: "addressBook") != nil {
        
        addressBook = UserDefaults.standard.object(forKey: "addressBook") as! [[String: Any]]
        print("addressBook = \(addressBook)")
        
        if addressBook.count > 1 {
            
            for savedAddress in addressBook {
                
                if address == savedAddress["address"] as! String {
                    
                    addressAlreadySaved = true
                    
                }
            }
        }
        
    }
    
    func saveWalletToAddressBook() {
        
        let alert = UIAlertController(title: "Give your wallet a name", message: "Adding a name will make it easier to differentiate between the wallets in your address book.", preferredStyle: .alert)
        
        alert.addTextField { (textField1) in
            
            textField1.placeholder = "Optional"
            
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default, handler: { (action) in
            
            let label = alert.textFields![0].text!
            
            addressBook.append(["address": "\(address)", "label": "\(label)",  "balance": "", "network": "\(network)", "privateKey": "\(privateKey)", "publicKey": "\(publicKey)", "redemptionScript": redemptionScript, "type":"\(type)"])
            
            saveToCoreData(label: label)
            
            UserDefaults.standard.set(addressBook, forKey: "addressBook")
            
            displayAlert(viewController: viewController, title: "Success", message: "You added a new wallet named: \"\(label)\" to your address book.")
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
            
            addressBook.append(["address": "\(address)", "label": "",  "balance": "", "network": "\(network)", "privateKey": "\(privateKey)", "publicKey": "\(publicKey)", "redemptionScript": redemptionScript, "type":"\(type)"])
            
            
            
            UserDefaults.standard.set(addressBook, forKey: "addressBook")
            
            displayAlert(viewController: viewController, title: "Success", message: "You added a new wallet with address: \"\(address)\" to your address book.")
            
        }))
        
        viewController.present(alert, animated: true, completion: nil)
        
        
    }
    
    if addressAlreadySaved {
        
        displayAlert(viewController: viewController, title: "Error, Address already saved.", message: "You can not save duplicate addresses to your address book.")
        
    } else {
        
        saveWalletToAddressBook()
        
    }
    
    func saveToCoreData(label: String) {
        
        let keys = ["address", "balance", "label", "network", "privateKey", "publicKey", "recoveryPhrase", "redemptionScript", "type", "xpriv", "xpub"]
        let values = [address, "", label, network, privateKey, publicKey, "", redemptionScript, type, "", ""]
        var alreadySaved = Bool()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AddressBook")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(fetchRequest) as [NSManagedObject]
            
            print("results in saver = \(results)")
            
            if results.count > 0 {
                
                for data in results {
                    
                    for _ in keys {
                        
                        if values[0] == data.value(forKey: "address") as? String {
                            
                            alreadySaved = true
                            displayAlert(viewController: viewController, title: "Error", message: "Can not save the same address to your Address Book more then once, please delete the old wallet and try again.")
                            
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
                            
                        } catch {
                            
                            print("Failed saving")
                            
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
                        
                    } catch {
                        
                        print("Failed saving")
                        
                    }
                }
               
                
            }
            
        } catch {
            
            print("Failed")
            
        }
        
    }
    
    
}
