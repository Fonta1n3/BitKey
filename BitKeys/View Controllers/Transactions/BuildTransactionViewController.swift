//
//  BuildTransactionViewController.swift
//  BitKeys
//
//  Created by Peter on 7/18/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit

class BuildTransactionViewController: UIViewController, BTCTransactionBuilderDataSource {
    
    var addressToSpendFrom = "1FUYtNWBSEATA3fvkHEXiam1FtFXwaDZmn"
    var privateKeyToSign = "Kz5L6nhJAjYjF87BagK5kttepmKCDtpGfWfo6m4oZiM2ETtZutaZ"
    var receiverAddress = "1NSffuQnz6ieZdvcu3A6xRz5JDES3Qtb1b"
    var inputData = NSDictionary()
    var scriptArray = [String]()
    var transaction = BTCTransaction()
    var inputDictionary = NSDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()

        getUTXOforAddress(address: addressToSpendFrom)
    }

    func getUTXOforAddress(address: String) {
        
        var url:NSURL!
        url = NSURL(string: "https://api.blockcypher.com/v1/btc/main/addrs/\(address)?includeScript=true")
        
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
                                
                                self.inputData = utxoCheck[0] as! NSDictionary
                                print("utxoCheck = \(utxoCheck)")
                                
                                //for item in self.inputData {
                                    
                                   let transactionHash = (self.inputData)["tx_hash"] as! String
                                    //let value = (self.inputData)["value"] as! Int
                                    
                                    var url:NSURL!
                                    url = NSURL(string: "https://api.blockcypher.com/v1/btc/main/txs/\(transactionHash)")
                                    
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
                                                        
                                                        if let inputsCheck = txHashResult["inputs"] as? NSArray {
                                                            
                                                            print("inputs = \(inputsCheck)")
                                                            
                                                            for input in inputsCheck {
                                                                
                                                                print("input = \(input)")
                                                                
                                                                self.inputDictionary = input as! NSDictionary
                                                                //self.callBTCTransaction()
                                                                self.createRawTx()
                                                                
                                                                /*if let valueCheck = (input as! NSDictionary)["value"] as? Int {
                                                                    
                                                                    if valueCheck == value {
                                                                        
                                                                        let script = (input as! NSDictionary)["script"] as! String
                                                                        self.scriptArray.append(script)
                                                                        print("script = \(script)")
                                                                    }
                                                                    
                                                                }*/
                                                                
                                                            }
                                                            
                                                            print("inputData = \(self.inputData)")
                                                            print("scriptArray = \(self.scriptArray)")
                                                            //self.callBTCTransaction()
                                                            
                                                            
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
                                //}
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
    
    
    
    /*func callBTCTransaction() {
        print("callBTCTransaction")
        
        let address = BTCAddress(string: self.receiverAddress)
        let newTransaction = BTCTransactionBuilder()
        newTransaction.dataSource = self
        newTransaction.shouldSign = false
        newTransaction.changeAddress = BTCAddress(string: self.addressToSpendFrom)
        
        //newTransaction.changeScript = BTCScript.init(address: BTCAddress(string: self.addressToSpendFrom))
        newTransaction.outputs = [BTCTransactionOutput(value: BTCAmount(10000), address: address)]
        newTransaction.feeRate = BTCAmount(2000)
        print("newtransaction = \(newTransaction.outputs)")
        
     
        
        //txIn.script = BTCScript.init(hex: (self.inputDictionary)["script"] as! String)
        //txIn.index = UInt32((item).value(forKey: "tx_output_n") as! Int)
        //print("txIndex = \(txIn.index)")
        //txIn.confirmations = UInt((self.inputDictionary).value(forKey: "confirmations") as! Int)
        
        
        
        var result:BTCTransactionBuilderResult? = nil
        do {
            result = try newTransaction.buildTransaction()
            print("transactionRaw = \(String(describing: result!.transaction!.hex!))")
            //print("rwtx = \(re)")
        } catch {
            print("error = \(error as Any)")
        }
    }*/
    
    /*func transactionBuilder(_ txbuilder: BTCTransactionBuilder!, keyForUnspentOutput txout: BTCTransactionOutput!) -> BTCKey! {
        print("transactionBuilder")
        
        let key = BTCKey.init(wif: self.privateKeyToSign)
        key?.isPublicKeyCompressed = true
        
        return key
    }*/
    
    
    
    func unspentOutputs(for txbuilder: BTCTransactionBuilder!) -> NSEnumerator! {
        print("unspentOutputs")
        
        let outputs = NSMutableArray()
                
        //for item in inputData {
            
            let txout = BTCTransactionOutput()
            txout.value = BTCAmount((inputData).value(forKey: "value") as! Int64)
            txout.script = BTCScript.init(hex: (inputData)["script"] as! String)
            txout.index = UInt32((inputData).value(forKey: "tx_output_n") as! Int)
            print("txIndex = \(txout.index)")
            txout.confirmations = UInt((inputData).value(forKey: "confirmations") as! Int)
            let transactionHash = (inputData)["tx_hash"] as! String
            txout.transactionHash = transactionHash.data(using: .utf8)
            outputs.add(txout)
            
        //}
        
        print("outputs = \(outputs)")
        
        return outputs.objectEnumerator()
    }
    
    func createRawTx() {
        
        let address = BTCAddress(string: self.receiverAddress)
        let transactionBuilder = BTCTransactionBuilder()
        transactionBuilder.dataSource = self
        transactionBuilder.shouldSign = false
        transactionBuilder.changeAddress = BTCAddress(string: self.addressToSpendFrom)
        transactionBuilder.outputs = [BTCTransactionOutput(value: BTCAmount(10000), address: address)]
        transactionBuilder.feeRate = BTCAmount(2000)
        
        var result:BTCTransactionBuilderResult? = nil
        do {
            result = try transactionBuilder.buildTransaction()
            print("transactionRaw = \(String(describing: result!.transaction!.hex!))")
            //print("rwtx = \(re)")
        } catch {
            print("error = \(error as Any)")
        }
        
    }

}
