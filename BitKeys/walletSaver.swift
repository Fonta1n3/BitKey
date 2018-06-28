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
    
    var addressAlreadySaved = Bool()
    
    func saveWalletToAddressBook() {
        
        let alert = UIAlertController(title: "Give your wallet a name", message: "Adding a name will make it easier to differentiate between the wallets in your address book.", preferredStyle: .alert)
        
        alert.addTextField { (textField1) in
            
            textField1.placeholder = "Optional"
            
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Add Name", comment: ""), style: .default, handler: { (action) in
            
            let label = alert.textFields![0].text!
            
            saveToCoreData(label: label)
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
            
            saveToCoreData(label: "")
            
        }))
        
        viewController.present(alert, animated: true, completion: nil)
        
        
    }
    
    saveWalletToAddressBook()
    
    func saveToCoreData(label: String) {
        
        let keys = ["address", "balance", "label", "network", "privateKey", "publicKey", "recoveryPhrase", "redemptionScript", "type", "xpriv", "xpub"]
        let values = [address, "", label, network, privateKey, publicKey, "", redemptionScript, type, "", ""]
        var alreadySaved = Bool()
        var success = Bool()
        
        var appDelegate = AppDelegate()
        
        if let appDelegateCheck = UIApplication.shared.delegate as? AppDelegate {
            
            appDelegate = appDelegateCheck
            
        } else {
            
            displayAlert(viewController: viewController, title: "Error", message: "Something strange has happened and we do not have access to app delegate, please try again.")
            
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AddressBook")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(fetchRequest) as [NSManagedObject]
            
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
                            success = true
                            
                        } catch {
                            
                            print("Failed saving")
                            success = false
                        }
                    }
                    
                    if success {
                        
                        if label == "" {
                            
                            displayAlert(viewController: viewController, title: "Success", message: "You added a new wallet with address: \"\(address)\" to your address book.")
                            
                        } else {
                            
                            displayAlert(viewController: viewController, title: "Success", message: "You added a new wallet named: \"\(label)\" to your address book.")
                            
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
                
                if success {
                    
                    if label == "" {
                        
                        displayAlert(viewController: viewController, title: "Success", message: "You added a new wallet with address: \"\(address)\" to your address book.")
                        
                    } else {
                        
                        displayAlert(viewController: viewController, title: "Success", message: "You added a new wallet named: \"\(label)\" to your address book.")
                    }
                    
                }
                
            }
            
        } catch {
            
            print("Failed")
            
        }
        
    }
    
    
}
