//
//  TransactionBuilderViewController.swift
//  BitKeys
//
//  Created by Peter on 2/7/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit


class TransactionBuilderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("TransactionBuilderViewController")
        
        
        // Get address from user
        let btcAddress = "mo7WCetPLw6yMkT7MdzYfQ1L4eWqAuT2j7"
        
        //get transactions for that btc address. with url call
        parseAddress(address: btcAddress)
        
        //prompt user to shut internet
        
        //get outputs amount and script from parseAddress
        //addOutputs
        //let output = BTCTransactionOutput.init(value: <#T##BTCAmount#>, script: <#T##BTCScript!#>)
        
        
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func parseAddress(address: String) {
        print("getAddressTransactionInputs")
        
        var url:NSURL!
        url = NSURL(string: "https://testnet.blockchain.info/unspent?active=\(address)")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            //print("jsonAddressResult = \(jsonAddressResult)")
                            
                            if let utxoCheck = jsonAddressResult["unspent_outputs"] as? NSArray {
                                
                                //print("transactionsCheck =\(transactionsCheck)")
                                
                                var balance:Double = 0
                                
                               for utxo in utxoCheck {
                                    
                                let utxoDictionary:NSDictionary! = utxo as! NSDictionary
                                print("utxo = \(utxoDictionary)")
                                
                                var amount = Double()
                                var transactionHash = String()
                                var transactionOutputN = Double()
                                var lockingScript = String()
                                var transactionIndex = Double()
                                
                                amount = utxoDictionary["value"] as! Double
                                transactionHash = utxoDictionary["tx_hash"] as! String
                                transactionOutputN = utxoDictionary["tx_output_n"] as! Double
                                lockingScript = utxoDictionary["script"] as! String
                                transactionIndex = utxoDictionary["tx_index"] as! Double
                                /*
                                 print("transactionHash =\(transactionHash)")
                                 print("transactionOutputN =\(transactionOutputN)")
                                 print("lockingScript =\(lockingScript)")
                                 print("transactionIndex =\(transactionIndex)")
                                 */
                                balance = balance + amount
                                
                                let script = BTCScript.init(hex: lockingScript)
                                let txId = transactionHash.data(using: .utf8)
                                
                                let newInput = BTCTransactionInput()
                                newInput.previousHash = txId
                                newInput.previousIndex = UInt32(transactionIndex)
                                newInput.value = BTCAmount(balance)
                                newInput.signatureScript = script
                                
                                
                                let address = BTCAddress.init(string: "mxxky7EDvEVa4z9pwenveSMcj6L3CJ85di")
                                let primaryOutput = BTCTransactionOutput(value: 129870000, address: address)
                                
                                
                                let newTransaction = BTCTransactionBuilder()
                                newTransaction.shouldSign = false
                                
                                let transaction = BTCTransaction()
                                transaction.addInput(newInput)
                                transaction.addOutput(primaryOutput)
                                transaction.fee = 130000
                                
                                do {
                                    
                                    let transactionRaw = try newTransaction.buildTransaction()
                                    print("transactionRaw = \(transactionRaw)")
                                    
                                } catch {
                                    
                                    print("error = \(error as Any)")
                                    
                                }
                                
                            }
                           
                            }
                            
                        } catch {
                            
                            print("JSon processing failed")
                            
                        }
                    }
                    
                    
                }
            }
        }
        
        task.resume()
        
    }

}
