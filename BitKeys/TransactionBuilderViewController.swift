//
//  TransactionBuilderViewController.swift
//  BitKeys
//
//  Created by Peter on 2/7/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit


class TransactionBuilderViewController: UIViewController, BTCTransactionBuilderDataSource {
    
    var unspentOutputs = NSMutableArray()
    let btcAddress = "mo7WCetPLw6yMkT7MdzYfQ1L4eWqAuT2j7"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("TransactionBuilderViewController")
        parseAddress(address: btcAddress)
        
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
                            
                            if let utxoCheck = jsonAddressResult["unspent_outputs"] as? NSArray {
                                
                                print("utxoCheck = \(utxoCheck)")
                                
                                self.unspentOutputs = utxoCheck.mutableCopy() as! NSMutableArray
                                
                                self.callBTCTransaction()
                                
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
    
    
    
    func callBTCTransaction() {
        //testnet private key to sign with
        let privateKeyString = "cVci5ZPPF2JJbzbBL48j4uBBjuTQrxPU94pcGJTdvNsKEXxqYPXx"
        //testnet address to send from
        let originAddressString = "mwsPvCKh8GusWcYD7TfrnJabiP8rjSYDKS"
        
        //attempting to create a signature script
        let privateKey = BTCPrivateKeyAddress(string: privateKeyString)
        let key = BTCKey.init(privateKeyAddress: privateKey)
        let hash = BTCSHA256(privateKey?.data)
        let sig = key?.signature(forHash: hash! as Data)
        print("sig = \(sig?.hex())")
        let sigScript = BTCScript.init(data: sig)
        
        let input = BTCTransactionInput()
        input.signatureScript = sigScript
        let tx = BTCTransaction()
        tx.addInput(input)
        
        let address = BTCAddress(string: "mxxky7EDvEVa4z9pwenveSMcj6L3CJ85di")
        let newTransaction = BTCTransactionBuilder()
        
        
        
        newTransaction.dataSource = self
        newTransaction.shouldSign = false
        newTransaction.changeAddress = BTCAddress(string: self.btcAddress)
        newTransaction.outputs = [BTCTransactionOutput(value: BTCAmount(50000), address: address)]
        newTransaction.feeRate = BTCAmount(5000)
        
        
        var result:BTCTransactionBuilderResult? = nil
        do {
            result = try newTransaction.buildTransaction()
            
            print("transactionRaw = \(String(describing: result?.transaction.hex))")
            
        } catch {
            print("error = \(error as Any)")
        }
        
        
    }
    
    func unspentOutputs(for txbuilder: BTCTransactionBuilder!) -> NSEnumerator! {
        
        let outputs = NSMutableArray()
        
        for item in self.unspentOutputs {
            
            print("item = \(item)")
            
            let txout = BTCTransactionOutput()
            txout.value = BTCAmount((item as! NSDictionary).value(forKey: "value") as! Int64)
            txout.script = BTCScript.init(hex: (item as! NSDictionary).value(forKey: "script") as! String)
            txout.index = UInt32((item as! NSDictionary).value(forKey: "tx_output_n") as! Int)
            txout.confirmations = UInt((item as! NSDictionary).value(forKey: "confirmations") as! Int)
            let transactionHash = (item as! NSDictionary)["tx_hash"] as! String
            txout.transactionHash = transactionHash.data(using: .utf8)
            outputs.add(txout)
            
        }

        return outputs.objectEnumerator()
        
    }

}
