//
//  AddressBookViewController.swift
//  BitKeys
//
//  Created by Peter on 6/14/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit

class AddressBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var addressBookTable: UITableView!
    
    var backButton = UIButton()
    var addButton = UIButton()
    var addressBook: [[String: Any]] = []
    var imageView:UIView!
    var hotMainnetArray = [[String: Any]]()
    var hotTestnetArray = [[String: Any]]()
    var coldMainnetArray = [[String: Any]]()
    var coldTestnetArray = [[String: Any]]()
    var sections = Int()
    
    //addressBook.append(["address": "\(address)", "label": label, "type": "watchOnly"])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addressBookTable.delegate = self
        addBackButton()
        addPlusButton()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        
        if UserDefaults.standard.object(forKey: "addressBook") != nil {
            
            addressBook = UserDefaults.standard.object(forKey: "addressBook") as! [[String: Any]]
            print("addressBook = \(addressBook)")
        }
        
        getArrays()
        
        
        
    }
    
    func getArrays() {
        
        self.sections = 0
        
        for address in self.addressBook {
            
            let network = address["network"] as! String
            let type = address["type"] as! String
            
            if network == "mainnet" && type == "hot" {
                
                self.hotMainnetArray.append(address)
                self.sections = sections + 1
                
            } else if network == "testnet" && type == "hot" {
                
                self.hotTestnetArray.append(address)
                self.sections = sections + 1
                
            } else if network == "mainnet" && type == "cold" {
                
                self.coldMainnetArray.append(address)
                self.sections = sections + 1
                
            } else if network == "testnet" && type == "cold" {
                
                self.coldTestnetArray.append(address)
                self.sections = sections + 1
                
            }
            
        }
        
        for (index, address) in hotMainnetArray.enumerated() {
            
            let addressToCheck = address["address"] as! String
            self.checkBalance(address: addressToCheck, index: index, network: "mainnet", type: "hot")
            
        }
        
        for (index, address) in hotTestnetArray.enumerated() {
            
            let addressToCheck = address["address"] as! String
            self.checkBalance(address: addressToCheck, index: index, network: "testnet", type: "hot")
            
        }
        
        for (index, address) in coldMainnetArray.enumerated() {
            
            let addressToCheck = address["address"] as! String
            self.checkBalance(address: addressToCheck, index: index, network: "mainnet", type: "cold")
            
        }
        
        for (index, address) in coldTestnetArray.enumerated() {
            
            let addressToCheck = address["address"] as! String
            self.checkBalance(address: addressToCheck, index: index, network: "testnet", type: "cold")
            
        }
        
        addressBookTable.reloadData()
        
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
    
    func addPlusButton() {
        print("addPlusButton")
        
        DispatchQueue.main.async {
            
            self.addButton.removeFromSuperview()
            self.addButton = UIButton(frame: CGRect(x: self.view.frame.width - 40, y: 25, width: 35, height: 35))
            self.addButton.showsTouchWhenHighlighted = true
            self.addButton.setImage(#imageLiteral(resourceName: "add.png"), for: .normal)
            self.addButton.addTarget(self, action: #selector(self.add), for: .touchUpInside)
            self.view.addSubview(self.addButton)
            
        }
        
    }
    
    @objc func add() {
        
        print("add")
        
    }
    
    @objc func back() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        /*
            var sections = 0
            
            for address in self.addressBook {
                
                let network = address["network"] as! String
                let type = address["type"] as! String
                
                if network == "mainnet" && type == "cold" {
                    
                    sections = sections + 1
                    //return sections
                    
                } else  if network == "mainnet" && type == "hot" {
                    
                    sections = sections + 1
                    //return sections
                    
                } else if network == "testnet" && type == "cold" {
                    
                    sections = sections + 1
                    //return sections
                    
                } else if network == "testnet" && type == "hot" {
                    
                    sections = sections + 1
                    
                }
                
                return sections
                
            }
        */
            
        return 4
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.addressBookTable {
           
            if section == 0 {
                
                return hotMainnetArray.count
                
            } else if section == 1 {
                
                return hotTestnetArray.count
                
            } else if section == 2 {
                
                return coldMainnetArray.count
                
            } else if section == 3 {
                
                return coldTestnetArray.count
                
            }
            
        }
        
       return 0
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        
        if indexPath.section == 0 {
            
            let label = self.hotMainnetArray[indexPath.row]["label"] as! String
            let address = self.hotMainnetArray[indexPath.row]["address"] as! String
            let balance = self.hotMainnetArray[indexPath.row]["balance"] as! String
            
            if label != "" {
                
                cell.textLabel?.text = "\(label) \(balance)"
                    
            } else {
                
                cell.textLabel?.text = "\(address) \(balance)"
                
            }
            
        } else if indexPath.section == 1 {
            
            let label = self.hotTestnetArray[indexPath.row]["label"] as! String
            let address = self.hotTestnetArray[indexPath.row]["address"] as! String
            let balance = self.hotTestnetArray[indexPath.row]["balance"] as! String
            
            if label != "" {
                
                cell.textLabel?.text = "\(label) \(balance)"
                
            } else {
                
                cell.textLabel?.text = "\(address) \(balance)"
                
            }
            
        } else if indexPath.section == 2 {
            
            let label = self.coldMainnetArray[indexPath.row]["label"] as! String
            let address = self.coldMainnetArray[indexPath.row]["address"] as! String
            let balance = self.coldMainnetArray[indexPath.row]["balance"] as! String
            
            if label != "" {
                
                cell.textLabel?.text = "\(label) \(balance)"
                
            } else {
                
                cell.textLabel?.text = "\(address) \(balance)"
                
            }
            
        } else if indexPath.section == 3 {
            
            let label = self.coldTestnetArray[indexPath.row]["label"] as! String
            let address = self.coldTestnetArray[indexPath.row]["address"] as! String
            let balance = self.coldTestnetArray[indexPath.row]["balance"] as! String
            
            if label != "" {
                
                cell.textLabel?.text = "\(label) \(balance)"
                
            } else {
                
                cell.textLabel?.text = "\(address) \(balance)"
                
            }
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 && self.hotMainnetArray.count > 0 {
            
            return "Hot - Mainnet"
            
        } else if section == 1 && self.hotTestnetArray.count > 0 {
            
            return "Hot - Testnet"
            
        } else if section == 2 && self.coldMainnetArray.count > 0 {
            
            return "Cold - Mainnet"
            
        } else if section == 3 && self.coldTestnetArray.count > 0 {
            
            return "Cold - Testnet"
            
        }
        
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       if indexPath.section == 0 {
            
            for (index, wallet) in self.addressBook.enumerated() {
                
                if self.hotMainnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String{
                    
                    print("wallet = \(self.addressBook[index])")
                    self.showKeyManagementAlert(wallet: self.addressBook[index])
                }
                
            }
            
        } else if indexPath.section == 1 {
            
            for (index, wallet) in self.addressBook.enumerated() {
                
                if self.hotTestnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String{
                    
                    print("wallet = \(self.addressBook[index])")
                    self.showKeyManagementAlert(wallet: self.addressBook[index])
                    
                }
                
            }
            
        } else if indexPath.section == 2 {
            
            for (index, wallet) in self.addressBook.enumerated() {
                
                if self.coldMainnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String{
                    
                    print("wallet = \(self.addressBook[index])")
                    self.showKeyManagementAlert(wallet: self.addressBook[index])
                    
                }
                
            }
            
        } else if indexPath.section == 3 {
            
            for (index, wallet) in self.addressBook.enumerated() {
                
                if self.coldTestnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String{
                    
                    print("wallet = \(self.addressBook[index])")
                    self.showKeyManagementAlert(wallet: self.addressBook[index])
                    
                }
                
            }
            
        }
        
    }
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
     // Override to support editing the table view.
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if indexPath.section == 0 {
                
                for (index, wallet) in self.addressBook.enumerated() {
                    
                    if self.hotMainnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String {
                        
                        self.addressBook.remove(at: index)
                        UserDefaults.standard.set(self.addressBook, forKey: "addressBook")
                        
                    }
                    
                }
                
                self.hotMainnetArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            } else if indexPath.section == 1 {
                
                for (index, wallet) in self.addressBook.enumerated() {
                    
                    if self.hotTestnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String {
                        
                        self.addressBook.remove(at: index)
                        UserDefaults.standard.set(self.addressBook, forKey: "addressBook")
                        
                    }
                    
                }
                
                self.hotTestnetArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            } else if indexPath.section == 2 {
                
                for (index, wallet) in self.addressBook.enumerated() {
                    
                    if self.coldMainnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String {
                        
                        self.addressBook.remove(at: index)
                        UserDefaults.standard.set(self.addressBook, forKey: "addressBook")
                        
                    }
                    
                }
                
                self.coldMainnetArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            } else if indexPath.section == 3 {
                
                for (index, wallet) in self.addressBook.enumerated() {
                    
                    if self.coldTestnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String{
                        
                        self.addressBook.remove(at: index)
                        UserDefaults.standard.set(self.addressBook, forKey: "addressBook")
                        
                    }
                    
                }
                
                self.coldTestnetArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
        }
        
     }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    func showKeyManagementAlert(wallet: [String: Any]) {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Key Management", message: "Please select an option.", preferredStyle: UIAlertControllerStyle.actionSheet)
            
             alert.addAction(UIAlertAction(title: NSLocalizedString("Create Multi-Sig", comment: ""), style: .default, handler: { (action) in
             
             //self.performSegue(withIdentifier: "createMultiSig", sender: self)
             
             }))
 
            alert.addAction(UIAlertAction(title: NSLocalizedString("Export Keys", comment: ""), style: .default, handler: { (action) in
             
             //self.export()
             
            }))
 
            
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkBalance(address: String, index: Int, network: String, type: String) {
        print("checkBalance")
        
        addSpinner()
        
        var url:NSURL!
        var btcAmount = ""
        
        if address.hasPrefix("1") || address.hasPrefix("3") {
            
            url = NSURL(string: "https://blockchain.info/rawaddr/\(address)")
            
        } else if address.hasPrefix("m") || address.hasPrefix("2") || address.hasPrefix("n") {
            
            url = NSURL(string: "https://testnet.blockchain.info/rawaddr/\(address)")
            
        } else if address.hasPrefix("t") || address.hasPrefix("b") {
            
            //use blockchair
            
        }
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    self.removeSpinner()
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            if let finalBalanceCheck = jsonAddressResult["final_balance"] as? Double {
                                
                                btcAmount = String(finalBalanceCheck / 100000000)
                                
                                if network == "mainnet" && type == "hot" {
                                    
                                    self.hotMainnetArray[index]["balance"] = " - " + btcAmount + " BTC"
                                    
                                } else if network == "testnet" && type == "hot" {
                                    
                                    self.hotTestnetArray[index]["balance"] = " - " + btcAmount + " BTC"
                                    
                                } else if network == "mainnet" && type == "cold" {
                                    
                                    self.coldMainnetArray[index]["balance"] = " - " + btcAmount + " BTC"
                                    
                                } else if network == "testnet" && type == "cold" {
                                    
                                    self.coldTestnetArray[index]["balance"] = " - " + btcAmount + " BTC"
                                    
                                }
                                
                                DispatchQueue.main.async {
                                    
                                    self.addressBookTable.reloadData()
                                    self.removeSpinner()
                                    
                                }
                                
                            } else {
                                
                               self.removeSpinner()
                                
                            }
                            
                        } catch {
                            
                            print("JSon processing failed")
                            self.removeSpinner()
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
            self.rotateAnimation(imageView: self.imageView as! UIImageView)
            self.view.addSubview(self.imageView)
            
        }
        
    }
    
    func rotateAnimation(imageView:UIImageView,duration: CFTimeInterval = 2.0) {
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 8.0)
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = Float.greatestFiniteMagnitude;
        imageView.layer.add(rotateAnimation, forKey: nil)
        
    }
    
    func removeSpinner() {
        
        DispatchQueue.main.async {
            
            self.imageView.removeFromSuperview()
            
        }
    }

}
