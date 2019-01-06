//
//  TransactionHistoryViewController.swift
//  BitKeys
//
//  Created by Peter on 6/20/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit

class TransactionHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var refresher: UIRefreshControl!
    var imageView:UIView!
    var address = String()
    var wallet = [String:Any]()
    var backButton = UIButton()
    var latestBlockHeight = Int()
    var transactionArray = [[String:Any]]()
    var addressBook = [[String:Any]]()
    var activityIndicator:UIActivityIndicatorView!
    
    @IBOutlet var transactionHistoryTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactionHistoryTable.delegate = self
        addBackButton()
        address = wallet["address"] as! String
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(self.getLatestBlock), for: UIControlEvents.valueChanged)
        transactionHistoryTable.addSubview(refresher)
        
        let title = UILabel(frame: CGRect(x: 70, y: 25, width: self.view.frame.width - 140, height: 50))
        title.font = UIFont.init(name: "HelveticaNeue-Bold", size: 18)
        title.textColor = UIColor.black
        title.textAlignment = .center
        
        if self.wallet["label"] as! String != "" {
            
            title.text = "\(self.wallet["label"] as! String)"
            
        } else {
            
            title.text = self.wallet["address"] as! String
            
        }
        
        title.adjustsFontSizeToFitWidth = true
        title.font = UIFont.init(name: "HelveticaNeue-Bold", size: 18)
        title.textColor = UIColor.black
        title.textAlignment = .center
        self.view.addSubview(title)
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25, y: self.view.center.y - 25, width: 50, height: 50))
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.activityIndicator.isUserInteractionEnabled = true
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        getLatestBlock()
        addressBook = checkAddressBook()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        transactionArray.removeAll()
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return transactionArray.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath)
        cell.layer.cornerRadius = 10
        cell.contentView.alpha = 0.8
        cell.alpha = 0.8
        
        let titleLabel = cell.viewWithTag(1) as! UILabel
        let subTitleLabel1 = cell.viewWithTag(2) as! UILabel
        let subTitleLabel2 = cell.viewWithTag(3) as! UILabel
        let subTitleLabel3 = cell.viewWithTag(4) as! UILabel
        
        subTitleLabel1.textColor = UIColor.white
        subTitleLabel2.textColor = UIColor.white
        subTitleLabel3.textColor = UIColor.white
        titleLabel.textColor = UIColor.white
        
        let type = self.transactionArray[indexPath.section]["type"] as! String
        let fees = self.transactionArray[indexPath.section]["fees"] as! Double
        let confirmations = self.transactionArray[indexPath.section]["confirmations"] as! Int
        let date = self.transactionArray[indexPath.section]["date"] as! String
        var fromAddress = String()
        
        if type == "receiving" {
            
            let fromAddresses = self.transactionArray[indexPath.section]["fromAddress"] as! [String]
            let amountReceived = self.transactionArray[indexPath.section]["amountReceived"] as! Double
            
            var addressesEqual = Bool()
            
            if fromAddresses.count > 1 {
                
                for (index, address) in fromAddresses.enumerated() {
                    
                    if index > 0 {
                        
                        if address != fromAddresses[index - 1] {
                            
                            addressesEqual = false
                            fromAddress = "Multiple Addresses"
                            
                        } else {
                            
                            addressesEqual = true
                        }
                    }
                }
                
            } else {
                
                fromAddress = fromAddresses[0]
                
            }
            
            if addressesEqual {
                
               fromAddress = fromAddresses[0]
                
            }
            
            for wallet in self.addressBook {
                
                if wallet["address"] as! String == fromAddress {
                    
                    fromAddress = wallet["label"] as! String
                }
                
            }
            
            titleLabel.text = "Received \((amountReceived / 100000000).avoidNotation) Bitcoin"
            subTitleLabel1.text = "From: \(fromAddress)"
            subTitleLabel2.text = "Confirmed \(confirmations) times, for a fee of \((fees / 100000000).avoidNotation)"
            subTitleLabel3.text = "\(date)"
            
        } else if type == "sending" {
            
            var toAddress = self.transactionArray[indexPath.section]["toAddress"] as! String
            let amountSent = self.transactionArray[indexPath.section]["amountSent"] as! Double
            
            for wallet in self.addressBook {
                
                if wallet["address"] as! String == toAddress {
                    
                    toAddress = wallet["label"] as! String
                }
                
            }
            
            titleLabel.text = "Sent \((amountSent / 100000000).avoidNotation) Bitcoin"
            subTitleLabel1.text = "To: \(toAddress)"
            subTitleLabel2.text = "Confirmed \(confirmations) times, for a fee of \((fees / 100000000).avoidNotation)"
            subTitleLabel3.text = "\(date)"
            
        }
        
        return cell
        
    }
    
    @objc func getLatestBlock() {
        print("getLatestBlock")
        
        if isInternetAvailable() == true {
            
            var url:NSURL!
            
            if address.hasPrefix("1") || address.hasPrefix("3") || address.hasPrefix("bc1") {
                
                url = NSURL(string: "https://blockchain.info/latestblock")
                
            } else if address.hasPrefix("m") || address.hasPrefix("2") || address.hasPrefix("n") || address.hasPrefix("tb") {
                
                url = NSURL(string: "https://testnet.blockchain.info/latestblock")
                
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
                                
                                if let heightCheck = jsonAddressResult["height"] as? Int {
                                    
                                    self.latestBlockHeight = heightCheck
                                    self.checkBalance(address: self.address)
                                    
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
            
        } else {
            
            displayAlert(viewController: self, title: "Oops", message: "We need internet to fetch you transaction history, please check your connection.")
            
        }
        
       
    }
    
    func checkBalance(address: String) {
        print("checkBalance")
        
        var url:NSURL!
        
        if address.hasPrefix("1") || address.hasPrefix("3") {
            
            url = NSURL(string: "https://blockchain.info/rawaddr/\(address)")
            
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
                                
                                print("result = \(jsonAddressResult)")
                                
                                if let historyCheck = jsonAddressResult["txs"] as? NSArray {
                                    
                                    if historyCheck.count == 0 {
                                        
                                        displayAlert(viewController: self, title: "No transactions yet for address \(address)", message: "")
                                    }
                                    
                                    self.transactionArray.removeAll()
                                    
                                    for txDictionary in historyCheck {
                                        
                                        if let transaction = txDictionary as? NSDictionary {
                                            
                                            if let hashCheck = transaction["hash"] as? String {
                                                
                                                var blockheight = Int()
                                                var fromAddresses = [String]()
                                                var toAddresses = [String]()
                                                var amountReceived = [Int]()
                                                var amountSent = [Int]()
                                                var confirmations = Int()
                                                var secondsSince = Double()
                                                var dateString = ""
                                                var hash = ""
                                                
                                                var dictionary = [String:Any]()
                                                
                                                hash = hashCheck
                                                
                                                if let blockCheck = transaction["block_height"] as? Int {
                                                    
                                                    blockheight = blockCheck
                                                    confirmations = self.latestBlockHeight - blockheight
                                                    
                                                }
                                                
                                                if let timeCheck = transaction["time"] as? Double {
                                                    
                                                    secondsSince = timeCheck
                                                    let date = Date(timeIntervalSince1970: secondsSince)
                                                    let dateFormatter = DateFormatter()
                                                    dateFormatter.dateFormat = "MMMM-dd-yyyy HH:mm"
                                                    dateString = dateFormatter.string(from: date)
                                                    
                                                }
                                                
                                                if let inputsCheck = transaction["inputs"] as? NSArray {
                                                    
                                                    for input in inputsCheck {
                                                        
                                                        if let inputDict = input as? NSDictionary {
                                                            
                                                            if let prevOutCheck = inputDict["prev_out"] as? NSDictionary {
                                                                
                                                                amountSent.append(prevOutCheck["value"] as! Int)
                                                                fromAddresses.append(prevOutCheck["addr"] as! String)
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                
                                                if let outPutsCheck = transaction["out"] as? NSArray {
                                                    
                                                    for output in outPutsCheck {
                                                        
                                                        if let outPutDict = output as? NSDictionary {
                                                            
                                                            if let addr = outPutDict["addr"] as? String {
                                                                toAddresses.append(addr)
                                                            } else {
                                                                toAddresses.append("No readable address")
                                                            }
                                                            amountReceived.append(outPutDict["value"] as! Int)
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                
                                                var type = String()
                                                var primaryAmountIReceived = Double()
                                                var primaryRecipient = String()
                                                var primaryAmountRecipientReceived = Double()
                                                
                                                for inputAddr in fromAddresses {
                                                    
                                                    if fromAddresses.count > 1 {
                                                        
                                                        //this transaction received bitcoin from multiple addresses
                                                    }
                                                    
                                                    if self.address != inputAddr {
                                                        
                                                        type = "receiving"
                                                        
                                                    } else if self.address == inputAddr {
                                                        
                                                        type = "sending"
                                                    }
                                                    
                                                }
                                                
                                                for (index, outputAddr) in toAddresses.enumerated() {
                                                    
                                                    if type == "sending" && outputAddr == self.address {
                                                        
                                                        //this is me sending myself change
                                                        
                                                    } else if type == "receiving" && outputAddr != self.address {
                                                        
                                                        //change address receiving change (not me)
                                                        
                                                    } else if type == "receiving" && outputAddr == self.address {
                                                        
                                                        primaryAmountIReceived = Double(amountReceived[index])
                                                        
                                                    } else if type == "sending" && outputAddr != self.address {
                                                        
                                                        primaryRecipient = outputAddr
                                                        primaryAmountRecipientReceived = Double(amountReceived[index])
                                                    }
                                                    
                                                }
                                                
                                                let totalSent = amountSent.reduce(0, +)
                                                let totalReceived = amountReceived.reduce(0, +)
                                                let fees = Double(totalSent - totalReceived)
                                                
                                                if type == "receiving" {
                                                    
                                                    dictionary = ["confirmations":confirmations, "fromAddress":fromAddresses, "amountReceived":primaryAmountIReceived, "date":dateString, "type":type, "hash":hash, "fees":fees]
                                                    
                                                } else if type == "sending" {
                                                    
                                                    dictionary = ["confirmations":confirmations, "toAddress":primaryRecipient, "amountSent":primaryAmountRecipientReceived, "date":dateString, "type":type, "hash":hash, "fees":fees]
                                                    
                                                }
                                                
                                                
                                                self.transactionArray.append(dictionary)
                                                fromAddresses.removeAll()
                                                toAddresses.removeAll()
                                                amountReceived.removeAll()
                                                amountSent.removeAll()
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.transactionHistoryTable.reloadData()
                                    }
                                    
                                    self.removeSpinner()
                                    
                                    
                                } else {
                                    
                                    DispatchQueue.main.async {
                                        self.removeSpinner()
                                        displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                    }
                                }
                                
                            } catch {
                                
                                print("JSon processing failed")
                                DispatchQueue.main.async {
                                    self.removeSpinner()
                                    displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                }
                            }
                        }
                    }
                }
            }
            
            task.resume()
            
        } else if address.hasPrefix("m") || address.hasPrefix("2") || address.hasPrefix("n") {
            
            url = NSURL(string: "https://api.blockcypher.com/v1/btc/test3/addrs/\(address)/full")
            
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
                                
                                if let historyCheck = jsonAddressResult["txs"] as? NSArray {
                                    
                                    if historyCheck.count == 0 {
                                        
                                        displayAlert(viewController: self, title: "No transactions yet for address \(address)", message: "")
                                    }
                                    
                                    self.transactionArray.removeAll()
                                    
                                    for txDictionary in historyCheck {
                                        
                                        if let transaction = txDictionary as? NSDictionary {
                                            
                                            if let hashCheck = transaction["hash"] as? String {
                                                
                                                var fromAddresses = [String]()
                                                var toAddresses = [String]()
                                                var amountReceived = [Int]()
                                                var amountSent = [Int]()
                                                var confirmations = Int()
                                                var dateString = ""
                                                var hash = ""
                                                var dictionary = [String:Any]()
                                                hash = hashCheck
                                                
                                                if let confirmationsCheck = transaction["confirmations"] as? Int {
                                                    
                                                    confirmations = confirmationsCheck
                                                    
                                                }
                                                
                                                if let timeCheck = transaction["received"] as? String {
                                                    
                                                    var periodExists = Bool()
                                                    var formattedDateString = String()
                                                    
                                                    for character in timeCheck {
                                                        
                                                        if character == "." {
                                                            
                                                            periodExists = true
                                                        }
                                                    }
                                                    
                                                    if periodExists {
                                                        
                                                        let dateArray = timeCheck.split(separator: ".")
                                                        formattedDateString = String(dateArray[0])
                                                        
                                                    } else {
                                                        
                                                        formattedDateString = timeCheck.replacingOccurrences(of: "Z", with: "")
                                                        
                                                    }
                                                    
                                                    let dateFormatter = DateFormatter()
                                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                                                    dateFormatter.timeZone = TimeZone.current
                                                    dateFormatter.locale = Locale.current
                                                    let date = dateFormatter.date(from: formattedDateString)
                                                    
                                                    let convertDateFormatter = DateFormatter()
                                                    convertDateFormatter.dateFormat = "MMMM-dd-yyyy HH:mm"
                                                    convertDateFormatter.timeZone = TimeZone.current
                                                    convertDateFormatter.locale = Locale.current
                                                    dateString = convertDateFormatter.string(from: date!)
                                                    print("dateString = \(dateString)")
                                                    
                                                }
                                                
                                                if let inputsCheck = transaction["inputs"] as? NSArray {
                                                    
                                                    for input in inputsCheck {
                                                        
                                                        if let inputDict = input as? NSDictionary {
                                                            
                                                            amountSent.append(inputDict["output_value"] as! Int)
                                                            
                                                            if let addresses = inputDict["addresses"] as? NSArray {
                                                                
                                                                for address in addresses {
                                                                    
                                                                    fromAddresses.append(address as! String)
                                                                }
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                
                                                if let outPutsCheck = transaction["outputs"] as? NSArray {
                                                    
                                                    for output in outPutsCheck {
                                                        
                                                        if let outPutDict = output as? NSDictionary {
                                                            
                                                            amountReceived.append(outPutDict["value"] as! Int)
                                                            
                                                            if let addresses = outPutDict["addresses"] as? NSArray {
                                                                
                                                                for address in addresses {
                                                                    
                                                                    toAddresses.append(address as! String)
                                                                }
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                
                                                var type = String()
                                                var primaryAmountIReceived = Double()
                                                var primaryRecipient = String()
                                                var primaryAmountRecipientReceived = Double()
                                                
                                                for inputAddr in fromAddresses {
                                                    
                                                    if fromAddresses.count > 1 {
                                                        
                                                        //this transaction received bitcoin from multiple addresses
                                                        //print("this transaction received bitcoin from multiple addresses")
                                                    }
                                                    
                                                    if self.address != inputAddr {
                                                        
                                                        type = "receiving"
                                                        
                                                    } else if self.address == inputAddr {
                                                        
                                                        type = "sending"
                                                        //print("type == sending")
                                                        
                                                    }
                                                    
                                                }
                                                
                                                for (index, outputAddr) in toAddresses.enumerated() {
                                                    
                                                    if type == "sending" && outputAddr == self.address {
                                                        
                                                        //this is me sending myself change
                                                        //print("\(outputAddr) received change of \(amountReceived[index])")
                                                        
                                                    } else if type == "receiving" && outputAddr != self.address {
                                                        
                                                        //change address receiving change (not me)
                                                        //print("\(outputAddr) received change of \(amountReceived[index])")
                                                        
                                                    } else if type == "receiving" && outputAddr == self.address {
                                                        
                                                        primaryAmountIReceived = Double(amountReceived[index])
                                                        
                                                    } else if type == "sending" && outputAddr != self.address {
                                                        
                                                        primaryRecipient = outputAddr
                                                        primaryAmountRecipientReceived = Double(amountReceived[index])
                                                    }
                                                    
                                                }
                                                
                                                let totalSent = amountSent.reduce(0, +)
                                                let totalReceived = amountReceived.reduce(0, +)
                                                let fees = Double(totalSent - totalReceived)
                                                
                                                if type == "receiving" {
                                                    
                                                    dictionary = ["confirmations":confirmations, "fromAddress":fromAddresses, "amountReceived":primaryAmountIReceived, "date":dateString, "type":type, "hash":hash, "fees":fees]
                                                    
                                                } else if type == "sending" {
                                                    
                                                    dictionary = ["confirmations":confirmations, "toAddress":primaryRecipient, "amountSent":primaryAmountRecipientReceived, "date":dateString, "type":type, "hash":hash, "fees":fees]
                                                    
                                                }
                                                
                                                self.transactionArray.append(dictionary)
                                                fromAddresses.removeAll()
                                                toAddresses.removeAll()
                                                amountReceived.removeAll()
                                                amountSent.removeAll()
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.transactionHistoryTable.reloadData()
                                        self.removeSpinner()
                                    }
                                    
                                } else {
                                    
                                    DispatchQueue.main.async {
                                        self.removeSpinner()
                                        displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                    }
                                }
                                
                            } catch {
                                
                                print("JSon processing failed")
                                DispatchQueue.main.async {
                                    self.removeSpinner()
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
    
   func removeSpinner() {
        
        DispatchQueue.main.async {
            
            self.activityIndicator.stopAnimating()
            self.refresher.endRefreshing()
            
        }
    }

}
