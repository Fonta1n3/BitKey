//
//  SpendMultiSigViewController.swift
//  BitKeys
//
//  Created by Peter on 6/8/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import Signer

class SpendMultiSigViewController: UIViewController {
    
    var privateKeyToSign = String()
    var transactionToBeSigned = [String]()
    var json = NSMutableDictionary()
    let publickKeyArray = ["0229c403d4654999fd7ca3fe8cdf75abb6519a0cdb4b77ae69f1f607c9e94f2916", "03e6ab3953a40cf8da61b4fe8c2a767ee42a19cae84aea83a39cd597e0a3d0fd60"]
    let privateKeyArray = ["Kzyok1i6RfJz1W67MedPhFQVWvr2MYzFcMdYKGdTxpb4HxoNEDvd", "L1obEsBNo7nqiaUrEwtRtsBQ3YXivAhgo8qp5pw1W1WJ7TzUdRGM"]
    //let publickKeyArray = ["0415bb65cf6ded39a28d5769c4d6564c4ee3c59b264e1ad801d366014d2b5e72463755d2d1a9a555d63f10c59bc0ad87642c49fbf9bf81cddb981cc1047c85a67b", "04228ac86795acb233da7272c85b8af8f89929e0f7acffac9bbc6562b08246f47b6358acd03815e7ac57f80019b00a8365eb71bba9681ef7a34a7c6783c6a629d1"]
    //publickKeyArray = [<0315bb65 cf6ded39 a28d5769 c4d6564c 4ee3c59b 264e1ad8 01d36601 4d2b5e72 46>, <03228ac8 6795acb2 33da7272 c85b8af8 f89929e0 f7acffac 9bbc6562 b08246f4 7b>]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //getPubKeys()
        makeHTTPPostRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func makeHTTPPostRequest() {
        print("makeHTTPPostRequest")
        
        var url:URL!
        
        url = URL(string: "https://api.blockcypher.com/v1/btc/main/txs/new")
        
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        request.httpBody = "{\"inputs\": [{\"addresses\": [\"0229c403d4654999fd7ca3fe8cdf75abb6519a0cdb4b77ae69f1f607c9e94f2916\", \"03e6ab3953a40cf8da61b4fe8c2a767ee42a19cae84aea83a39cd597e0a3d0fd60\"], \"script_type\" : \"multisig-2-of-2\"}], \"outputs\": [{\"addresses\" : [\"1PEAXvpQzqwy5Wcj6SxfbwVAffY41SabRX\"], \"value\" : 2000}],\"preference\": \"low\"}".data(using: .utf8)
        
        //curl -d '{ "inputs" : [ {"addresses": ["0471b0e83960b9a8ad980400fc7ee85e9739009f0ee08ef033784bdcefe7f38c64e9ba2b9d842089486735556e0b1940304db510ad521865bb5b028dee229c1dbd", "04a3cc3225df2f6ca72e960c5cab0059731301d5efe61e7ffa1c4cac3a8e4994adcb27f01a282b7747d96ffdad324e774087c4a35197e99016bca62541af26eab", "04db43666cf4206e7848aaaf551e2ea6af2488b23046c155f1456d0dd175c782eef61acc42ededcd45a37012c7e096125e356c839e9c0a5f9c75d48aeddcad6712"], "script_type" : "multisig-2-of-3" }],"outputs":[{"addresses": ["mgMZ3UdQsEmJ1ebjRV9ibTn1DFCxgmMo7a"], "value": 200000000}]}' https://api.blockcypher.com/v1/btc/test3/txs/new?includeToSignTx=true

            
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    
                } else {
                    
                    print("response = \(response)")
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            print("jsonAddressResult = \(jsonAddressResult)")
                            
                            if let error = jsonAddressResult["errors"] as? NSArray {
                                
                                DispatchQueue.main.async {
                                    
                                    var errors = [String]()
                                    
                                    for e in error {
                                        
                                        if let errordescription = (e as? NSDictionary)?["error"] as? String {
                                            
                                            errors.append(errordescription)
                                        }
                                        
                                    }
                                    
                                    print(error)
                                    
                                }
                                
                            } else {
                                
                                if let toSignCheck = jsonAddressResult["tosign"] as? NSArray {
                                    
                                    for tosign in toSignCheck {
                                        
                                        self.transactionToBeSigned.append(tosign as! String)
                                        
                                    }
                                    
                                    self.json = jsonAddressResult.mutableCopy() as! NSMutableDictionary
                                    
                                    var signatureArray = [String]()
                                    var pubkeyArray = [String]()
                                    
                                    for (index, key) in self.privateKeyArray.enumerated() {
                                    
                                        for transaction in self.transactionToBeSigned {
                                            
                                            if let privateKey = BTCPrivateKeyAddress(string: key) {
                                                
                                                let btcKey = BTCKey.init(privateKeyAddress: privateKey)
                                                
                                                SignerGetSignature(btcKey?.privateKey.hex()!, transaction)
                                                
                                                if let signature = Signer.signature() {
                                                    
                                                    signatureArray.append(signature)
                                                    pubkeyArray.append(self.publickKeyArray[index])
                                                    
                                                } else {
                                                    
                                                    print("error")
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    self.json["signatures"] = signatureArray
                                    self.json["pubkeys"] = pubkeyArray
                                    print("json = \(self.json)")
                                    self.postTransaction()
                                    
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
    
    func postTransaction() {
        print("postTransaction")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: self.json)
        var url:URL!
        
        url = URL(string: "https://api.blockcypher.com/v1/btc/main/txs/send")
            
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    DispatchQueue.main.async {
                        
                        print("error = \(String(describing: error))")
                        
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            print("response = \(String(describing: response))")
                            
                            if let error = jsonAddressResult["errors"] as? NSArray {
                                
                                DispatchQueue.main.async {
                                    
                                    var errors = [String]()
                                    
                                    for e in error {
                                        
                                        if let errordescription = (e as? NSDictionary)?["error"] as? String {
                                            
                                            errors.append(errordescription)
                                            
                                        }
                                        
                                    }
                                    
                                    print("errors = \(error)")
                                    
                                }
                                
                            } else {
                                
                                if let txCheck = jsonAddressResult["tx"] as? NSDictionary {
                                    
                                    if let hashCheck = txCheck["hash"] as? String {
                                        
                                        print("hashCheck = \(hashCheck)")
                                        
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
    
    func getPubKeys() {
        
        var publickKeyArray = [Any]()
        
        let privateKeyArray = ["cPYbSLEvKaUxRdYGdRzQkgXgyhovv6Mr1yZ5RwhyUXPhMqMhCMie", "cTEcTdnS89xYVoTyejpZzovRJrbueVLtc2DUMdufAzH6utzBaxuJ"]
        
        for privateKey in privateKeyArray {
            
                    if let key = BTCKey.init(wif: privateKey) {
                        
                        key.isPublicKeyCompressed = true
                        
                        if let pubKey = key.publicKey {
                            
                            publickKeyArray.append(pubKey)
                            
                        }
                        
                        print("publickKeyArray = \(publickKeyArray)")
                        
                    } else {
                        
                        print("error with \(privateKey)")
                        
                    }
                    
        }
        
    }

}
