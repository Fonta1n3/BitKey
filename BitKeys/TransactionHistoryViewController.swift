//
//  TransactionHistoryViewController.swift
//  BitKeys
//
//  Created by Peter on 6/20/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit

class TransactionHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var imageView:UIView!
    var address = String()
    var wallet = [String:Any]()
    var backButton = UIButton()
    var latestBlockHeight = Int()
    var transactionArray = [[String:Any]]()
    //https://blockchain.info/rawaddr/$bitcoin_address
    
    @IBOutlet var transactionHistoryTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        transactionHistoryTable.delegate = self
        addBackButton()
        
        print("wallet = \(self.wallet)")
        
        address = wallet["address"] as! String
        getLatestBlock()
        checkBalance(address: address)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addBackButton() {
        print("addBackButton")
        
        DispatchQueue.main.async {
            
            self.backButton.removeFromSuperview()
            self.backButton = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
            self.backButton.showsTouchWhenHighlighted = true
            self.backButton.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
            self.backButton.addTarget(self, action: #selector(self.back), for: .touchUpInside)
            self.view.addSubview(self.backButton)
            
        }
        
    }
    
    @objc func back() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "History"
    }
    
    //https://blockchain.info/latestblock
    
    func getLatestBlock() {
        print("checkBalance")
        
        self.addSpinner()
        
        var url:NSURL!
        
        url = NSURL(string: "https://blockchain.info/latestblock")
            
        
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    self.removeSpinner()
                    DispatchQueue.main.async {
                        displayAlert(viewController: self, title: "Error", message: "\(String(describing: error))")
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            if let heightCheck = jsonAddressResult["height"] as? Int {
                                
                                self.latestBlockHeight = heightCheck
                                
                            } else {
                                
                                DispatchQueue.main.async {
                                    displayAlert(viewController: self, title: "Error", message: "Please try again.")
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
    
    func checkBalance(address: String) {
        print("checkBalance")
        
        self.addSpinner()
        
        var url:NSURL!
        
        if address.hasPrefix("1") || address.hasPrefix("3") {
            
            url = NSURL(string: "https://blockchain.info/rawaddr/\(address)")
            
        } else if address.hasPrefix("m") || address.hasPrefix("2") || address.hasPrefix("n") {
            
            url = NSURL(string: "https://testnet.blockchain.info/rawaddr/\(address)")
            
        }
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    self.removeSpinner()
                    DispatchQueue.main.async {
                        displayAlert(viewController: self, title: "Error", message: "\(String(describing: error))")
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            print("jsonAddressResult = \(jsonAddressResult)")
                            
                            if let historyCheck = jsonAddressResult["txs"] as? NSArray {
                                
                                print("historyCheck = \(historyCheck)")
                                
                                var blockheight = Int()
                                //var hash = String()
                                var fromAddresses = [String]()
                                var toAddress = [String]()
                                var amountSpent = Int()
                                var amountReceived = [Int]()
                                var amountSent = [Int]()
                                //var changeAddress = NSArray()
                                //var fees = Double()
                                var confirmations = Int()
                                
                                var dictionary = ["confirmations":"", "fromAddress":"", "toAddress":"", "amountReceived":"", "date":""]
                                
                                for txDictionary in historyCheck {
                                    
                                    for (key, value) in (txDictionary as? NSDictionary)! {
                                        
                                        if key as! String == "block_height" {
                                            
                                            blockheight = value as! Int
                                            confirmations = self.latestBlockHeight - blockheight
                                            
                                       }
                                        
                                        if key as! String == "inputs" {
                                            
                                            let inputs = value as! NSArray
                                            
                                            for input in inputs {
                                                
                                                for (key, value) in (input as? NSDictionary)! {
                                                    
                                                    print("input key and value = \(key, value)")
                                                    
                                                    if key as! String == "prev_out" {
                                                        
                                                        let prevOut = value as! NSDictionary
                                                        amountSent.append(prevOut["value"] as! Int)
                                                        fromAddresses.append(prevOut["addr"] as! String)
                                                        
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                        if key as! String == "out" {
                                            
                                            let outputs = value as! NSArray
                                            
                                            for output in outputs {
                                                
                                                for (key, value) in (output as? NSDictionary)! {
                                                    
                                                    print("output key and value = \(key, value)")
                                                    
                                                    if key as! String == "addr" {
                                                        
                                                      toAddress.append(value as! String)
                                                        
                                                    }
                                                    
                                                    if key as! String == "value" {
                                                        
                                                        amountReceived.append(value as! Int)
                                                        
                                                    }
                                                    
                                                 }
                                                
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    dictionary = ["confirmations":"\(confirmations)", "fromAddress":"\(fromAddresses)", "toAddress":"\(toAddress)", "amountReceived":"\(amountReceived)", "date":""]
                                    self.transactionArray.append(dictionary)
                                    fromAddresses.removeAll()
                                    toAddress.removeAll()
                                    amountReceived.removeAll()
                                    
                                }
                                
                                //print("self.transactionArray = \(self.transactionArray)")
                                
                                for transaction in self.transactionArray {
                                    
                                    print("transaction = \(transaction)\n\n")
                                    
                                }
                                
                            } else {
                                
                                DispatchQueue.main.async {
                                    displayAlert(viewController: self, title: "Error", message: "Please try again.")
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
    
    func addSpinner() {
        
        DispatchQueue.main.async {
            
            if self.imageView != nil {
                self.imageView.removeFromSuperview()
            }
            let bitcoinImage = UIImage(named: "img_311477.png")
            self.imageView = UIImageView(image: bitcoinImage!)
            self.imageView.center = self.view.center
            self.imageView.frame = CGRect(x: self.view.center.x - 25, y: 20, width: 50, height: 50)
            rotateAnimation(imageView: self.imageView as! UIImageView)
            self.view.addSubview(self.imageView)
            
        }
        
    }
    
    func removeSpinner() {
        
        DispatchQueue.main.async {
            
            self.imageView.removeFromSuperview()
            
        }
    }

}
