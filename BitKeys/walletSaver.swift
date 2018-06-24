//
//  walletSaver.swift
//  BitKeys
//
//  Created by Peter on 6/16/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import Foundation

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
    
    /*func saveToAddressBookAlert() {
        
        let alert = UIAlertController(title: "Save this wallet for later use?", message: "If you do not save the wallet it will not get saved to your address book and won't be stored on your device in anyway.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
            
            saveWalletToAddressBook()
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .destructive, handler: { (action) in
            
        }))
        
        viewController.present(alert, animated: true, completion: nil)
    }*/
    
    func saveWalletToAddressBook() {
        
        let alert = UIAlertController(title: "Give your wallet a name", message: "Adding a name will make it easier to differentiate between the wallets in your address book.", preferredStyle: .alert)
        
        alert.addTextField { (textField1) in
            
            textField1.placeholder = "Optional"
            
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default, handler: { (action) in
            
            let label = alert.textFields![0].text!
            
            addressBook.append(["address": "\(address)", "label": "\(label)",  "balance": "", "network": "\(network)", "privateKey": "\(privateKey)", "publicKey": "\(publicKey)", "redemptionScript": redemptionScript, "type":"\(type)"])
            
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
        
        //saveToAddressBookAlert()
        saveWalletToAddressBook()
        
    }
    
    
}
