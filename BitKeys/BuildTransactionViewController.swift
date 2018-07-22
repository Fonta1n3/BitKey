//
//  BuildTransactionViewController.swift
//  BitKeys
//
//  Created by Peter on 7/18/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit

class BuildTransactionViewController: UIViewController, BTCTransactionBuilderDataSource {
    
    var addressToSpendFrom = "n1QQYAHbw3q6UjWN6Q4d9oqa6u5iUDnPHT"
    var privateKeyToSign = "cNeZkP1QPQ37C4rLvoQ8xZ5eujcjsYHZMj8CLfPPohYPvfKhzHWu"
    var receiverAddress = "n1v9HH9Abs36fYf8KbwnFUfzR4prLBXhtW"
    var inputData = [NSDictionary]()
    var scriptArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        getUTXOforAddress(address: addressToSpendFrom)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //https://api.blockcypher.com/v1/btc/main/txs/f854aebae95150b379cc1187d848d58225f3c4157fe992bcd166f58bd5063449

    func getUTXOforAddress(address: String) {
        
        var url:NSURL!
        url = NSURL(string: "https://api.blockcypher.com/v1/btc/test3/addrs/\(address)?unspentOnly=true")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    DispatchQueue.main.async {
                        displayAlert(viewController: self, title: "Error", message: "Please check your interent connection.")
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonUTXOResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            print("json = \(jsonUTXOResult)")
                            
                            if let utxoCheck = jsonUTXOResult["txrefs"] as? NSArray {
                                
                                self.inputData = utxoCheck as! [NSDictionary]
                                print("utxoCheck = \(utxoCheck)")
                                
                                for item in self.inputData {
                                    
                                   let transactionHash = (item)["tx_hash"] as! String
                                    let value = (item)["value"] as! Int
                                    
                                    var url:NSURL!
                                    url = NSURL(string: "https://api.blockcypher.com/v1/btc/test3/txs/\(transactionHash)")
                                    
                                    let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
                                        
                                        do {
                                            
                                            if error != nil {
                                                
                                                print(error as Any)
                                                DispatchQueue.main.async {
                                                    displayAlert(viewController: self, title: "Error", message: "Please check your interent connection.")
                                                }
                                                
                                            } else {
                                                
                                                if let urlContent = data {
                                                    
                                                    do {
                                                        
                                                        let txHashResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                                                        
                                                        print("txHashResult = \(txHashResult)")
                                                        
                                                        if let outputsCheck = txHashResult["outputs"] as? NSArray {
                                                            
                                                            print("outputs = \(outputsCheck)")
                                                            
                                                            for output in outputsCheck {
                                                                
                                                                if let valueCheck = (output as! NSDictionary)["value"] as? Int {
                                                                    
                                                                    if valueCheck == value {
                                                                        
                                                                        let script = (output as! NSDictionary)["script"] as! String
                                                                        self.scriptArray.append(script)
                                                                        print("script = \(script)")
                                                                    }
                                                                    
                                                                }
                                                                
                                                            }
                                                            
                                                            print("inputData = \(self.inputData)")
                                                            print("scriptArray = \(self.scriptArray)")
                                                            self.callBTCTransaction()
                                                            
                                                        }
                                                        
                                                    } catch {
                                                        
                                                        print("JSon processing failed")
                                                        DispatchQueue.main.async {
                                                            displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    task.resume()
                                }
                           }
                            
                        } catch {
                            
                            print("JSon processing failed")
                            DispatchQueue.main.async {
                                displayAlert(viewController: self, title: "Error", message: "Please try again.")
                            }
                        }
                    }
                }
            }
        }
        
        task.resume()
        
    }
    
    func callBTCTransaction() {
        
        let address = BTCAddress(string: self.receiverAddress)
        let newTransaction = BTCTransactionBuilder()
        newTransaction.dataSource = self
        newTransaction.shouldSign = false
        newTransaction.changeAddress = BTCAddress(string: self.addressToSpendFrom)
        newTransaction.outputs = [BTCTransactionOutput(value: BTCAmount(1000), address: address)]
        newTransaction.feeRate = BTCAmount(2000)
        var result:BTCTransactionBuilderResult? = nil
        do {
            result = try newTransaction.buildTransaction()
            print("transactionRaw = \(String(describing: result?.transaction.hex))")
        } catch {
            print("error = \(error as Any)")
        }
    }
    
    /*func transactionBuilder(_ txbuilder: BTCTransactionBuilder!, signatureScriptFor tx: BTCTransaction!, script outputScript: BTCScript!, inputIndex: UInt) -> BTCScript! {
        print("transactionBuilder")
    }
    
    func transactionBuilder(_ txbuilder: BTCTransactionBuilder!, keyForUnspentOutput txout: BTCTransactionOutput!) -> BTCKey! {
        print("transactionBuilder")
    }*/
    
    
    
    func unspentOutputs(for txbuilder: BTCTransactionBuilder!) -> NSEnumerator! {
        
        let outputs = NSMutableArray()
        
        for (index, item) in inputData.enumerated() {
            
            let txout = BTCTransactionOutput()
            txout.value = BTCAmount((item).value(forKey: "value") as! Int64)
            txout.script = BTCScript.init(hex: self.scriptArray[index])
            txout.index = UInt32((item).value(forKey: "tx_output_n") as! Int)
            txout.confirmations = UInt((item).value(forKey: "confirmations") as! Int)
            let transactionHash = (item)["tx_hash"] as! String
            txout.transactionHash = transactionHash.data(using: .utf8)
            outputs.add(txout)
            
        }
        
        return outputs.objectEnumerator()
    }

}
