//
//  TransactionBuilder.swift
//  BitKeys
//
//  Created by Peter on 6/19/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import Foundation

public func createTransaction(viewcontroller: UIViewController, network: String, preference: String, satoshiAmount: String, receivingAddress: String, debitAddress: String, manualMiningFee: String) -> NSMutableDictionary {
    print("createTransaction")
    
    var url:URL!
    var jsonResult:NSMutableDictionary!
    
    if network == "testnet" {
        
        url = URL(string: "https://api.blockcypher.com/v1/btc/test3/txs/new")
        
    } else {
        
        url = URL(string: "https://api.blockcypher.com/v1/btc/main/txs/new")
        
    }
    
    var request = URLRequest(url: url)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    
    if manualMiningFee != "" {
        
        request.httpBody = "{\"inputs\": [{\"addresses\": [\"\(debitAddress)\"]}], \"outputs\": [{\"addresses\": [\"\(receivingAddress)\"], \"value\": \(satoshiAmount)}],\"fees\": \(manualMiningFee)}".data(using: .utf8)
        
    } else {
        
        request.httpBody = "{\"inputs\": [{\"addresses\": [\"\(debitAddress)\"]}], \"outputs\": [{\"addresses\": [\"\(receivingAddress)\"], \"value\": \(satoshiAmount)}],\"preference\": \"\(preference)\"}".data(using: .utf8)
        
    }
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
        
        do {
            
            if error != nil {
                
                DispatchQueue.main.async {
                    
                    displayAlert(viewController: viewcontroller, title: "Error", message: "\(String(describing: error))")
                    
                }
                
            } else {
                
                if let urlContent = data {
                    
                    do {
                        
                        let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                        
                        if let error = jsonAddressResult["errors"] as? NSArray {
                            
                            DispatchQueue.main.async {
                                
                                var errors = [String]()
                                
                                for e in error {
                                    
                                    if let errordescription = (e as? NSDictionary)?["error"] as? String {
                                        
                                        errors.append(errordescription)
                                    }
                                    
                                }
                                
                                displayAlert(viewController: viewcontroller, title: "Error", message: "\(errors)")
                                
                            }
                            
                        } else {
                            
                            jsonResult = jsonAddressResult.mutableCopy() as! NSMutableDictionary
                            
                            
                            
                            //if let toSignCheck = jsonAddressResult["tosign"] as? NSArray {
                                
                                /*for tosign in toSignCheck {
                                    
                                    self.transactionToBeSigned.append(tosign as! String)
                                    
                                }*/
                                
                                //self.json = jsonAddressResult.mutableCopy() as! NSMutableDictionary
                                
                                /*if self.setFeeMode == false {
                                    
                                    if let sizeCheck = (jsonAddressResult["tx"] as? NSDictionary)?["fees"] as? NSInteger {
                                        
                                        self.fees = sizeCheck
                                        
                                    }
                                }*/
                                
                                /*if self.sweepMode && self.hotMode {
                                    
                                    self.getPrivateKeySignature(key: self.privateKeytoDebit)
                                    self.removeSpinner()
                                    
                                } else {
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.removeSpinner()
                                        
                                        if self.coldMode {
                                            
                                            self.sweepMode = false
                                            
                                            let alert = UIAlertController(title: NSLocalizedString("Turn Airplane Mode On", comment: ""), message: "We need to scan your Private Key so that we can create a signature to sign your transaction with, you may enable airplane mode during this operation for maximum security, this is optional. We NEVER save your Private Keys, the signature is created locally and the internet is not used at all, however we will need the internet after you sign the transaction in order to send the bitcoins.", preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    self.addScanner()
                                                    
                                                }
                                                
                                            }))
                                            
                                            self.present(alert, animated: true, completion: nil)
                                            
                                        } else {
                                            
                                            //let wif = UserDefaults.standard.object(forKey: "wif") as! String
                                            self.getPrivateKeySignature(key: self.privateKeytoDebit)
                                            
                                        }
                                        
                                    }
                                    
                                }*/
                                
                            //}
                            
                        }
                        
                    } catch {
                        
                        print("JSon processing failed")
                        
                        DispatchQueue.main.async {
                            
                            displayAlert(viewController: viewcontroller, title: "Error", message: "Please try again.")
                            
                        }
                    }
                }
            }
        }
    }
    
    task.resume()
    
    return jsonResult
}

/*public func getPrivateKeySignature(key: String) {
    print("getPrivateKeySignature")
    
    if let privateKey = BTCPrivateKeyAddress(string: key) {
        print("privateKey = \(String(describing: privateKey))")
        
        let key = BTCKey.init(privateKeyAddress: privateKey)
        print("privateKey = \(String(describing: privateKey))")
        
        if self.hotMode || self.sweepMode {
            
            if self.testnetMode {
                
                let legacyAddress1 = (key?.addressTestnet.description)!
                let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
                self.sendingFromAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                self.privateKey = String(describing: privateKey)
                
            } else {
                
                let legacyAddress1 = (key?.address.description)!
                let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
                self.sendingFromAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                self.privateKey = String(describing: privateKey)
            }
            
            
        }
        
        if self.sweepMode {
            
            self.removeSpinner()
            self.checkBalance(address: self.sendingFromAddress)
        }
        
        
        
        DispatchQueue.main.async {
            
            var message = String()
            
            func postAlert() {
                
                let publicKey = key?.publicKey
                let publicKeyString = BTCHexFromData(publicKey as Data!)
                print("prvKey = \(String(describing: key?.privateKey.hex()))")
                self.privateKeyToSign = (key?.privateKey.hex())!
                
                var signatureArray = [String]()
                var pubkeyArray = [String]()
                
                for transaction in self.transactionToBeSigned {
                    
                    SignerGetSignature(self.privateKeyToSign, transaction)
                    
                    if let signature = Signer.signature() {
                        
                        signatureArray.append(signature)
                        pubkeyArray.append(publicKeyString!)
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            displayAlert(viewController: self, title: "Error", message: "Error creating signatures.")
                        }
                    }
                    
                    
                }
                
                self.json["signatures"] = signatureArray
                self.json["pubkeys"] = pubkeyArray
                print("json = \(self.json)")
                
                let alert = UIAlertController(title: NSLocalizedString("Please confirm your transaction before sending.", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Send", comment: ""), style: .default, handler: { (action) in
                    
                    if isInternetAvailable() {
                        
                        DispatchQueue.main.async {
                            self.postTransaction()
                        }
                        
                        
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            
                            let alert = UIAlertController(title: NSLocalizedString("No Internet Connection.", comment: ""), message: "Please connect now and tap 'Try Again' when you are connected again.", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Try Again", comment: ""), style: .default, handler: { (action) in
                                
                                if isInternetAvailable() {
                                    
                                    DispatchQueue.main.async {
                                        self.postTransaction()
                                    }
                                    
                                } else {
                                    
                                    DispatchQueue.main.async {
                                        
                                        displayAlert(viewController: self, title: "No Internet Connection", message: "In order to broadcast your transaction to the network we need a connection.")
                                        
                                    }
                                    
                                }
                                
                            }))
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                                
                                self.dismiss(animated: true, completion: nil)
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            if self.currency != "BTC" && self.currency != "SAT" && self.sweepMode == false {
                
                let feeInFiat = self.exchangeRate * (Double(self.fees) / 100000000)
                let roundedFiatFeeAmount = round(100 * feeInFiat) / 100
                let roundedFiatToSendAmount = (round(100 * Double(self.amount)!) / 100).withCommas()
                
                message = "From: \(self.sendingFromAddress)\nTo: \(self.recievingAddress)\nAmount: \(roundedFiatToSendAmount) \(self.currency) with a miner fee of \(self.fees!.withCommas()) Satoshis or \(roundedFiatFeeAmount) \(self.currency)"
                postAlert()
                
            } else if self.currency == "BTC" || self.currency == "SAT" && self.sweepMode == false {
                
                if self.sweepAmount != "" {
                    
                    message = "From: \(self.sendingFromAddress)\nTo: \(self.recievingAddress)\nAmount: \(self.sweepAmount) \(self.currency) with a miner fee of \(self.fees!.withCommas()) Satoshis"
                    
                } else {
                    
                    message = "From: \(self.sendingFromAddress)\nTo: \(self.recievingAddress)\nAmount: \(self.amount) \(self.currency) with a miner fee of \(self.fees!.withCommas()) Satoshis"
                }
                
                postAlert()
                
            }
            
            if self.sweepMode {
                
                self.makeHTTPPostRequest()
                
            }
            
        }
        
    } else {
        
        DispatchQueue.main.async {
            
            displayAlert(viewController: self, title: "Error", message: "The Private Key is not valid, please try again.")
            
        }
        
    }
    
}*/

/*public func postTransaction() {
    print("postTransaction")
    
    self.addSpinner()
    let jsonData = try? JSONSerialization.data(withJSONObject: self.json)
    var url:URL!
    
    if testnetMode {
        
        url = URL(string: "https://api.blockcypher.com/v1/btc/test3/txs/send")
        
    } else {
        
        url = URL(string: "https://api.blockcypher.com/v1/btc/main/txs/send")
        
    }
    
    var request = URLRequest(url: url)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = jsonData
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
        
        do {
            
            if error != nil {
                
                self.removeSpinner()
                
                DispatchQueue.main.async {
                    
                    displayAlert(viewController: self, title: "Error", message: "\(String(describing: error))")
                    
                }
                
            } else {
                
                if let urlContent = data {
                    
                    do {
                        
                        let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                        
                        if let error = jsonAddressResult["errors"] as? NSArray {
                            
                            self.removeSpinner()
                            
                            DispatchQueue.main.async {
                                
                                var errors = [String]()
                                
                                for e in error {
                                    
                                    if let errordescription = (e as? NSDictionary)?["error"] as? String {
                                        
                                        errors.append(errordescription)
                                        
                                    }
                                    
                                }
                                
                                displayAlert(viewController: self, title: "Error", message: "\(errors)")
                                
                            }
                            
                        } else {
                            
                            if let txCheck = jsonAddressResult["tx"] as? NSDictionary {
                                
                                if let hashCheck = txCheck["hash"] as? String {
                                    
                                    self.transactionID = hashCheck
                                    self.removeScanner()
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.removeSpinner()
                                        
                                        let alert = UIAlertController(title: NSLocalizedString("Transaction Sent", comment: ""), message: "Transaction ID: \(hashCheck)", preferredStyle: UIAlertControllerStyle.actionSheet)
                                        
                                        alert.addAction(UIAlertAction(title: NSLocalizedString("Copy to Clipboard", comment: ""), style: .default, handler: { (action) in
                                            
                                            UIPasteboard.general.string = hashCheck
                                            
                                            self.dismiss(animated: true, completion: nil)
                                            
                                        }))
                                        
                                        alert.addAction(UIAlertAction(title: NSLocalizedString("See Transaction", comment: ""), style: .default, handler: { (action) in
                                            self.getTransaction()
                                        }))
                                        
                                        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .cancel, handler: { (action) in
                                            
                                            self.dismiss(animated: true, completion: nil)
                                            
                                        }))
                                        
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    }
                                }
                            }
                        }
                        
                    } catch {
                        
                        print("JSon processing failed")
                        
                        self.removeSpinner()
                        
                        DispatchQueue.main.async {
                            
                            displayAlert(viewController: self, title: "Error", message: "Please try again.")
                            
                        }
                    }
                }
            }
        }
    }
    
    task.resume()
}*/
