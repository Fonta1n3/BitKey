//
//  TransactionBuilderViewController.swift
//  BitKeys
//
//  Created by Peter on 2/7/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import Signer

class TransactionBuilderViewController: UIViewController, BTCTransactionBuilderDataSource {
    
    var unspentOutputs = NSMutableArray()
    let btcAddress = "mo7WCetPLw6yMkT7MdzYfQ1L4eWqAuT2j7"
    var json = NSMutableDictionary()
    var transactionToBeSigned = String()
    var privateKeyToSign = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("TransactionBuilderViewController")
        //parseAddress(address: btcAddress)
        
        makeHTTPPostRequest()
        
        //print(HelloGreetings("gopher"))
        
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
    
    func makeHTTPPostRequest() {
        
        let addressToPay = "mwsPvCKh8GusWcYD7TfrnJabiP8rjSYDKS"
        let addressToRecieve = "mxxky7EDvEVa4z9pwenveSMcj6L3CJ85di"
        let privateKey = "cVci5ZPPF2JJbzbBL48j4uBBjuTQrxPU94pcGJTdvNsKEXxqYPXx"
        let amount = "4"
        var url:URL!
        url = URL(string: "http://api.blockcypher.com/v1/btc/test3/txs/new")
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = "{\"inputs\": [{\"addresses\": [\"\(addressToPay)\"]}], \"outputs\": [{\"addresses\": [\"\(addressToRecieve)\"], \"value\": \(amount)}]}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            print("jsonAddressResult = \(jsonAddressResult)")
                            
                            if let toSignCheck = jsonAddressResult["tosign"] as? NSArray {
                                
                                print("toSignCheck = \(toSignCheck[0])")
                                self.transactionToBeSigned = toSignCheck[0] as! String
                                let privateKey = BTCPrivateKeyAddress(string: privateKey)
                                let key = BTCKey.init(privateKeyAddress: privateKey)
                                let publicKey = key?.publicKey
                                let publicKeyString = BTCHexFromData(publicKey as Data!)
                                print("prvKey = \(String(describing: key?.privateKey.hex()))")
                                
                                self.privateKeyToSign = (key?.privateKey.hex())!
                                
                                self.json = jsonAddressResult.mutableCopy() as! NSMutableDictionary
                                
                                SignerGetSignature(self.privateKeyToSign, self.transactionToBeSigned)
                                
                                let signature = Signer.signature()
                                
                                
                                
                                
                                self.json["signatures"] = ["\(String(describing: signature!))"]
                                self.json["pubkeys"] = ["\(String(describing: publicKeyString!))"]
                                
                                print("json = \(self.json)")
                                
                                self.postTransaction()
                                
                                
                                
                                
                            }
                            
                            
                            
                        } catch {
                            
                            print("JSon processing failed")
                            
                        }
                    }
                    
                    
                }
            }
        }
        
        
        
        /*
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            print("response = \(String(describing: response))")
            
            print("data = \(data?.hex())")
            
            
            let b58 = BTCBase58StringWithData(data)
            print("b58 = \(b58)")
            
            //let BTCinput:BTCTransactionInput = BTCTransactionInput.init(data: data)
            //BTCinput.signatureScript = BTCScript.in
            
            let privateKey = BTCPrivateKeyAddress(string: privateKey)
            let key = BTCKey.init(privateKeyAddress: privateKey)
            let sig = key?.signature(forHash: data! as Data)
            let sigHex = sig?.hex()
            print("signedTransaction = \(String(describing: sigHex))")
            
            print("prvKey = \(key?.privateKey.hex())")
            
            //let NSerror = NSErrorPointer(error as! AutoreleasingUnsafeMutablePointer<NSError?>)
            
            
            
            
            //let sign = SignerSign(key?.privateKey as Data!, data, error)
            
        }
        */
        task.resume()
    }
    
    func postTransaction() {
        
        let jsonData = try? JSONSerialization.data(withJSONObject: self.json)
        
        var url:URL!
        url = URL(string: "http://api.blockcypher.com/v1/btc/test3/txs/send")
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            print("jsonAddressResult = \(jsonAddressResult)")
                            
                            //check if tosign was consumed.. get TX hash
                            if let txCheck = jsonAddressResult["tx"] as? NSDictionary {
                                
                                print("txCheck = \(txCheck)")
                                
                                if let hashCheck = txCheck["hash"] as? String {
                                    
                                    print("hashCheck = \(hashCheck)")
                                    
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
