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
        let imageView = UIImageView()
        imageView.image = UIImage(named:"background.jpg")
        imageView.frame = self.view.frame
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.alpha = 0.02
        self.view.addSubview(imageView)
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
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
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
        
        return self.transactionArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath)
        
        let titleLabel = cell.viewWithTag(1) as! UILabel
        let subTitleLabel1 = cell.viewWithTag(2) as! UILabel
        let subTitleLabel2 = cell.viewWithTag(3) as! UILabel
        let subTitleLabel3 = cell.viewWithTag(4) as! UILabel
        
        let type = self.transactionArray[indexPath.row]["type"] as! String
        let fees = self.transactionArray[indexPath.row]["fees"] as! Double
        let confirmations = self.transactionArray[indexPath.row]["confirmations"] as! Int
        let date = self.transactionArray[indexPath.row]["date"] as! String
        var fromAddress = String()
        
        if type == "receiving" {
            
            let fromAddresses = self.transactionArray[indexPath.row]["fromAddress"] as! [String]
            let amountReceived = self.transactionArray[indexPath.row]["amountReceived"] as! Double
            
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
            
            var toAddress = self.transactionArray[indexPath.row]["toAddress"] as! String
            let amountSent = self.transactionArray[indexPath.row]["amountSent"] as! Double
            
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
        
        if confirmations < 6 && confirmations > 0 {
            
            cell.backgroundColor = UIColor.yellow
            
        } else if confirmations == 0 {
            
            cell.backgroundColor = UIColor.red
            
        } else {
            
            cell.backgroundColor = UIColor.white
        }
        
        return cell
        
    }
    
    /*func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Transaction History for \"\(self.wallet["label"] as! String)\""
    }*/
    
    @objc func getLatestBlock() {
        print("getLatestBlock")
        
        if isInternetAvailable() == true {
            
            self.addSpinner()
            
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
        
        self.addSpinner()
        
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
                                
                                if let historyCheck = jsonAddressResult["txs"] as? NSArray {
                                    
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
                                                            
                                                            toAddresses.append(outPutDict["addr"] as! String)
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
                                                        //print("this transaction received bitcoin from multiple addresses")
                                                    }
                                                    
                                                    //print("\(inputAddr) sent \(amountSent[index])")
                                                    
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
                                                        
                                                        //print("\(outputAddr) my address is the primary recipient and received \(amountReceived[index])")
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
                                        
                                        
                                        //self.transactionArray = self.transactionArray.sorted{ ($0["date"] as? String)! > ($1["date"] as? String)! }
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
            
            /*url = NSURL(string: "https://blockchain.info/rawaddr/\(address)")
            
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
                                                            
                                                            toAddresses.append(outPutDict["addr"] as! String)
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
                                                        //print("this transaction received bitcoin from multiple addresses")
                                                    }
                                                    
                                                    //print("\(inputAddr) sent \(amountSent[index])")
                                                    
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
                                                        
                                                        //print("\(outputAddr) my address is the primary recipient and received \(amountReceived[index])")
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
                                        
                                        
                                        //self.transactionArray = self.transactionArray.sorted{ ($0["date"] as? String)! > ($1["date"] as? String)! }
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
            
            task.resume()*/
            
        } else if address.hasPrefix("m") || address.hasPrefix("2") || address.hasPrefix("n") {
            
            //url = NSURL(string: "https://testnet.blockchain.info/rawaddr/\(address)")
            url = NSURL(string: "https://api.blockcypher.com/v1/btc/test3/addrs/\(address)/full?token=a9d88ea606fb4a92b5134d34bc1cb2a0")
            
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
                                    
                                    self.transactionArray.removeAll()
                                    
                                    for txDictionary in historyCheck {
                                        
                                        if let transaction = txDictionary as? NSDictionary {
                                            
                                            if let hashCheck = transaction["hash"] as? String {
                                                
                                                //var blockheight = Int()
                                                var fromAddresses = [String]()
                                                var toAddresses = [String]()
                                                //var amountSpent = Int()
                                                var amountReceived = [Int]()
                                                var amountSent = [Int]()
                                                var confirmations = Int()
                                                //var secondsSince = Double()
                                                //let currentDate = Date()
                                                var dateString = ""
                                                var hash = ""
                                                
                                                var dictionary = [String:Any]()
                                                
                                                hash = hashCheck
                                                print("hashCheck = \(hashCheck)")
                                                
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
                                                    
                                                    //print("\(inputAddr) sent \(amountSent[index])")
                                                    
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
                                                        
                                                        //print("\(outputAddr) my address is the primary recipient and received \(amountReceived[index])")
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
                                        
                                        //print("historyCheck count = \(historyCheck.count)")
                                        
                                    }
                                    
                                    DispatchQueue.main.async {
                                        //self.transactionArray = self.transactionArray.sorted{ ($0["date"] as? String)! > ($1["date"] as? String)! }
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
        }
        
    }
    
    func addSpinner() {
        
        DispatchQueue.main.async {
            
            
            
            
            /*if self.imageView != nil {
                self.imageView.removeFromSuperview()
            }
            let bitcoinImage = UIImage(named: "Bitsense image.png")
            self.imageView = UIImageView(image: bitcoinImage!)
            self.imageView.center = self.view.center
            //self.backButton = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
            self.imageView.frame = CGRect(x: self.view.frame.maxX - 55, y: 20, width: 50, height: 50)
            rotateAnimation(imageView: self.imageView as! UIImageView)
            self.view.addSubview(self.imageView)*/
            
        }
        
    }
    
    func removeSpinner() {
        
        DispatchQueue.main.async {
            
            self.activityIndicator.stopAnimating()
            self.refresher.endRefreshing()
            
        }
    }

}
