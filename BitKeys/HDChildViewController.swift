//
//  HDChildViewController.swift
//  BitKeys
//
//  Created by Peter on 7/7/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import AES256CBC
import LocalAuthentication
import CoreData

class HDChildViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var walletToExport = [String:Any]()
    let amountLabel = UILabel()
    var exchangeRate = Double()
    var index = UInt32()
    var fromIndex:UInt32 = 0
    var toIndex:UInt32 = 0
    var currency = String()
    var createButton = UIButton()
    var wallet = [String:Any]()
    var buttonTitle = UILabel()
    var buttonViewVisible = Bool()
    var buttonView = UIView()
    var activityIndicator:UIActivityIndicatorView!
    @IBOutlet var HDChildTable: UITableView!
    var keyArray = [[String: Any]]()
    var masterWallet = [String:Any]()
    var refresher: UIRefreshControl!
    var backButton = UIButton()
    var addButton = UIButton()
    var segwit = SegwitAddrCoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        HDChildTable.delegate = self
        HDChildTable.dataSource = self
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(self.getArrays), for: UIControlEvents.valueChanged)
        HDChildTable.addSubview(refresher)
        addBackButton()
        addPlusButton()
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: view.center.x - 25, y: view.center.y - 25, width: 50, height: 50))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.isUserInteractionEnabled = true
        view.addSubview(self.activityIndicator)
        activityIndicator.startAnimating()
        getArrays()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addButtonView()
        
        if let BTC = checkTransactionSettingsForKey(keyValue: "bitcoin") as? Bool {
            if BTC {
                self.currency = "BTC"
            }
        }
        if let SAT = checkTransactionSettingsForKey(keyValue: "satoshi") as? Bool {
            if SAT {
                self.currency = "SAT"
            }
        }
        if let USD = checkTransactionSettingsForKey(keyValue: "dollar") as? Bool {
            if USD {
                self.currency = "USD"
            }
        }
        if let GBP = checkTransactionSettingsForKey(keyValue: "pounds") as? Bool {
            if GBP {
                self.currency = "GBP"
                
            }
        }
        if let EUR = checkTransactionSettingsForKey(keyValue: "euro") as? Bool {
            if EUR {
                self.currency = "EUR"
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.buttonView.removeFromSuperview()
        buttonViewVisible = false
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "spendFromChild") {
            
            if let vc = segue.destination as? TransactionBuilderViewController {
                
                self.wallet["label"] = ""
                self.wallet["network"] = self.masterWallet["network"]
                vc.walletToSpendFrom = self.wallet
                print("vc.walletToSpendFrom = \(vc.walletToSpendFrom)")
                vc.sendingFromAddress = self.wallet["address"] as! String
                
            }
            
        } else if (segue.identifier == "checkHistoryFromHD") {
    
            if let vc = segue.destination as? TransactionHistoryViewController {
                
                self.wallet["label"] = ""
                self.wallet["network"] = self.masterWallet["network"]
                vc.wallet = self.wallet
    
            }
    
        } else if (segue.identifier == "exportHD") {
            
            if let vc = segue.destination as? ViewController {
                
                vc.exportKeys = true
                vc.walletToExport = self.walletToExport
            }
        } else if (segue.identifier == "createChildInvoice") {
            
            if let vc = segue.destination as? CreateInvoiceViewController {
                
                vc.wallet = self.wallet
                
            }
        }
        
    }
    
    func convertBTCtoCurrency(btcAmount: String, exchangeRate: Double) -> String {
        
        var convertedAmount = ""
        let btcDouble = Double(btcAmount)!
        
        func convertToFiat(currency: String) -> String {
            
            var sign = ""
            switch currency {
            case "USD": sign = "﹩"
            case "GBP": sign = "£"
            case "EUR": sign = "€"
            case "BTC": sign = "﹩"
            case "SAT": sign = "﹩"
            default:
                break
            }
            
            let usdAmount = btcDouble * exchangeRate
            let roundedUsdAmount = round(100 * usdAmount) / 100
            let roundedInt = Int(roundedUsdAmount)
            let fiat = "\(sign)\(roundedInt.withCommas()) \(currency)"
            return fiat
            
        }
        
        switch self.currency {
        case "USD":convertedAmount = convertToFiat(currency: "USD")
        case "GBP":convertedAmount = convertToFiat(currency: "GBP")
        case "EUR":convertedAmount = convertToFiat(currency: "EUR")
        case "SAT":convertedAmount = convertToFiat(currency: "USD")
        case "BTC":convertedAmount = convertToFiat(currency: "USD")
        default:
            break
        }
        
        return convertedAmount
    }

    
    func showButtonView() {
        print("buttonView")
        
        let modelName = UIDevice.modelName
        
        if buttonViewVisible == false {
            
            self.buttonViewVisible = true
            DispatchQueue.main.async {
                
                self.buttonTitle.frame = CGRect(x: 10, y: 3, width: self.buttonView.frame.width - 20, height: 20)
                
                var text = String()
                
                if let _ = self.wallet["address"] as? String {
                    print("wallet = \(self.wallet)")
                    
                    text = self.wallet["address"] as! String
                        
                }
                
                self.buttonTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 15)
                self.buttonTitle.textColor = UIColor.white
                self.buttonTitle.textAlignment = .center
                self.buttonTitle.adjustsFontSizeToFitWidth = true
                self.buttonTitle.text = text
                self.buttonView.addSubview(self.buttonTitle)
                
                UIView.animate(withDuration: 0.3, animations: {
                    if modelName == "iPhone X" {
                        self.buttonView.frame = CGRect(x: 0, y: self.view.frame.maxY - 160, width: self.view.frame.width, height: 160)
                    } else {
                        
                        self.buttonView.frame = CGRect(x: 0, y: self.view.frame.maxY - 100, width: self.view.frame.width, height: 100)
                    }
                    
                }, completion: { _ in
                    
                })
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                self.buttonTitle.removeFromSuperview()
                self.buttonTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 15)
                self.buttonTitle.textColor = UIColor.white
                self.buttonTitle.textAlignment = .center
                self.buttonTitle.adjustsFontSizeToFitWidth = true
                self.buttonTitle.text = self.wallet["address"] as! String
                self.buttonView.addSubview(self.buttonTitle)
            }
            
        }
        
        
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
            
            let title = UILabel(frame: CGRect(x: (self.view.center.x) - ((self.view.frame.width - 130) / 2), y: 20, width: self.view.frame.width - 130, height: 55))
            title.font = UIFont.init(name: "HelveticaNeue-Bold", size: 18)
            title.textColor = UIColor.black
            title.numberOfLines = 0
            title.adjustsFontSizeToFitWidth = true
            var txt = self.masterWallet["label"] as! String
            if txt == "" {
                txt = self.masterWallet["address"] as! String
            }
            title.text = txt + " " + "\n∞"
            title.textAlignment = .center
            self.view.addSubview(title)
        }
        
    }
    
    func addPlusButton() {
        print("addPlusButton")
        
        DispatchQueue.main.async {
            
            self.addButton.alpha = 0
            self.addButton.removeFromSuperview()
            self.addButton = UIButton(frame: CGRect(x: self.view.frame.width - 60, y: 28, width: 35, height: 35))
            self.addButton.showsTouchWhenHighlighted = true
            self.addButton.setImage(#imageLiteral(resourceName: "plus.png"), for: .normal)
            self.addButton.addTarget(self, action: #selector(self.add), for: .touchUpInside)
            self.view.addSubview(self.addButton)
        }
        
    }
    
    @objc func back() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func add() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.fromIndex = self.fromIndex + 21
        self.toIndex = self.fromIndex + 20
        self.addRange(from: self.fromIndex, to: self.toIndex)
        
       
    }
    
    @objc func getArrays() {
        
        if fromIndex != 0 {
            
            self.addRange(from: self.fromIndex, to: self.toIndex)
            
        } else {
            
            let aespassword = KeychainWrapper.standard.string(forKey: "AESPassword")!
            let network = self.masterWallet["network"] as! String
            let type = self.masterWallet["type"] as! String
            let address = self.masterWallet["address"] as! String
            let label = self.masterWallet["label"] as! String
            
            if let xpriv = self.masterWallet["xpriv"] as? String, xpriv != "" {
                print("encrypted xpriv = \(xpriv)")
                
                if let decryptedXpriv = AES256CBC.decryptString(xpriv, password: aespassword) {
                    print("decryptedXpriv = \(decryptedXpriv)")
                    
                    if let keychain = BTCKeychain.init(extendedKey: decryptedXpriv) {
                        
                        keychain.key.isPublicKeyCompressed = true
                        
                        for i in 0 ... 20 {
                            
                            let int = UInt32(i)
                            
                            var addressHD = String()
                            var privateKey = String()
                            
                            if network == "testnet" {
                                
                                privateKey = (keychain.key(at: int).privateKeyAddressTestnet.string)
                                addressHD = (keychain.key(at: int).addressTestnet.string)
                                
                            } else if network == "mainnet" {
                                
                                privateKey = (keychain.key(at: int).privateKeyAddress.string)
                                addressHD = (keychain.key(at: int).address.string)
                                
                            }
                            
                            var bitcoinAddress = String()
                            
                            if address.hasPrefix("1") || address.hasPrefix("3") || address.hasPrefix("2") || address.hasPrefix("m") || address.hasPrefix("n") {
                                
                                bitcoinAddress = addressHD
                                
                            } else if address.hasPrefix("bc1") || address.hasPrefix("tb") {
                                
                                let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain.key(at: int).compressedPublicKey as Data!) as Data!) as Data!
                                
                                do {
                                    
                                    if network == "mainnet" {
                                        
                                        bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                                        
                                    } else if network == "testnet" {
                                        
                                        bitcoinAddress = try segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                                        
                                    }
                                    
                                } catch {
                                    
                                    displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                    
                                }
                                
                            }
                            
                            let dict = ["address":bitcoinAddress,"privateKey":privateKey,"balance":"", "network":network, "label":label, "fiatBalance":"", "index":"\(int)"]
                            self.keyArray.append(dict)
                            
                        }
                        
                        keychain.key.clear()
                        self.HDChildTable.reloadData()
                        DispatchQueue.main.async {
                            UIImpactFeedbackGenerator().impactOccurred()
                        }
                        
                        for (index, key) in keyArray.enumerated() {
                            
                            self.checkBalance(address: key["address"] as! String, index: index, network: network, type: type)
                        }
                    }
                    
                }
                
                
            } else if let mnemonic = self.masterWallet["mnemonic"] as? String {
                
                if mnemonic != "" {
                    
                    if let decryptedMnemonic = AES256CBC.decryptString(mnemonic, password: aespassword) {
                        
                        print("decryptedMnemonic = \(decryptedMnemonic)")
                        let replaceSpaces = decryptedMnemonic.replacingOccurrences(of: " ", with: "")
                        let words = replaceSpaces.split(separator: ",")
                        print("words = \(words)")
                        var password = ""
                        
                        if let passwordCheck = KeychainWrapper.standard.string(forKey: "BIP39Password") {
                            
                            password = passwordCheck
                            
                        }
                        
                        if let testInputMnemonic = BTCMnemonic.init(words: words, password: password, wordListType: BTCMnemonicWordListType.english) {
                            
                            let keychain = testInputMnemonic.keychain.derivedKeychain(withPath: "m/44'/0'/0'/0")
                            keychain?.key.isPublicKeyCompressed = true
                            
                            let xpriv = (keychain?.extendedPrivateKey)!
                            let encryptedXpriv = AES256CBC.encryptString(xpriv, password: aespassword)!
                            
                            //ensures backwards compatibility
                            self.editWallet(address: address, newValue: encryptedXpriv, oldValue: "", keyToEdit: "xpriv")
                            
                            for i in 0 ... 20 {
                                
                                let int = UInt32(i)
                                
                                var addressHD = String()
                                var privateKey = String()
                                
                                if network == "testnet" {
                                    
                                    privateKey = (keychain?.key(at: int).privateKeyAddressTestnet.string)!
                                    addressHD = (keychain?.key(at: int).addressTestnet.string)!
                                    
                                } else if network == "mainnet" {
                                    
                                    privateKey = (keychain?.key(at: int).privateKeyAddress.string)!
                                    addressHD = (keychain?.key(at: int).address.string)!
                                    
                                }
                                
                                var bitcoinAddress = String()
                                
                                if address.hasPrefix("1") || address.hasPrefix("3") || address.hasPrefix("2") || address.hasPrefix("m") || address.hasPrefix("n") {
                                    
                                    bitcoinAddress = addressHD
                                    
                                } else if address.hasPrefix("bc1") || address.hasPrefix("tb") {
                                    
                                    let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain?.key(at: int).compressedPublicKey as Data!) as Data!) as Data!
                                    
                                    do {
                                        
                                        if network == "mainnet" {
                                            
                                            bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                                            
                                        } else if network == "testnet" {
                                            
                                            bitcoinAddress = try segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                                            
                                        }
                                        
                                    } catch {
                                        
                                        displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                        
                                    }
                                    
                                }
                                
                                let dict = ["address":bitcoinAddress,"privateKey":privateKey,"balance":"", "network":network, "label":label, "fiatBalance":"", "index":"\(int)"]
                                self.keyArray.append(dict)
                                
                            }
                            
                            keychain?.key.clear()
                            self.HDChildTable.reloadData()
                            DispatchQueue.main.async {
                                UIImpactFeedbackGenerator().impactOccurred()
                            }
                            
                            for (index, key) in keyArray.enumerated() {
                                
                                self.checkBalance(address: key["address"] as! String, index: index, network: network, type: type)
                            }
                            
                            
                        } else {
                            
                            DispatchQueue.main.async {
                                
                                displayAlert(viewController: self, title: "Error", message: "Sorry we had a problem with your seed, please try again, you can contact us at BitSenseApp@gmail.com if you have an issue.")
                            }
                        }
                    }
                    
                } else if let xpub = self.masterWallet["xpub"] as? String {
                    
                    if xpub != "" {
                        
                        print("xpub = \(xpub)")
                        
                        if let decryptedXpub = AES256CBC.decryptString(xpub, password: aespassword) {
                            
                            if let watchOnlyTestKey = BTCKeychain.init(extendedKey: decryptedXpub) {
                                //watchOnlyTestKey.is
                                
                                for i in 0 ... 20 {
                                    
                                    let int = UInt32(i)
                                    
                                    var addressHD = String()
                                    
                                    if network == "testnet" {
                                        
                                        addressHD = (watchOnlyTestKey.key(at: int).addressTestnet.string)
                                        
                                    } else if network == "mainnet" {
                                        
                                        addressHD = (watchOnlyTestKey.key(at: int).address.string)
                                        
                                    }
                                    
                                    var bitcoinAddress = String()
                                    
                                    if address.hasPrefix("1") || address.hasPrefix("3") || address.hasPrefix("2") || address.hasPrefix("m") || address.hasPrefix("n") {
                                        
                                        bitcoinAddress = addressHD
                                        
                                    } else if address.hasPrefix("bc1") || address.hasPrefix("tb") {
                                        
                                        let compressedPKData = BTCRIPEMD160(BTCSHA256(watchOnlyTestKey.key(at: int).compressedPublicKey as Data!) as Data!) as Data!
                                        
                                        do {
                                            
                                            if network == "mainnet" {
                                                
                                                bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                                                
                                            } else if network == "testnet" {
                                                
                                                bitcoinAddress = try segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                                                
                                            }
                                            
                                        } catch {
                                            
                                            displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                            
                                        }
                                        
                                    }
                                    
                                    let dict = ["address":bitcoinAddress,"privateKey":"","balance":"", "network": network, "label": label, "fiatBalance":"", "index":"\(int)"]
                                    self.keyArray.append(dict)
                                    
                                }
                                
                                watchOnlyTestKey.key.clear()
                                self.HDChildTable.reloadData()
                                DispatchQueue.main.async {
                                    UIImpactFeedbackGenerator().impactOccurred()
                                }
                                
                                for (index, key) in keyArray.enumerated() {
                                    
                                    self.checkBalance(address: key["address"] as! String, index: index, network: network, type: type)
                                }
                                
                                
                            } else {
                                
                                DispatchQueue.main.async {
                                    
                                    displayAlert(viewController: self, title: "Error", message: "Sorry we had a problem with that xpub, please try again.")
                                }
                            }
                        } else {
                            
                            displayAlert(viewController: self, title: "Error", message: "Error decrypting your xpub.")
                        }
                    }
                }
            }
        }
        
    }
    
    func editWallet(address: String, newValue: String, oldValue: String, keyToEdit: String) {
        
        var appDelegate = AppDelegate()
        
        if let appDelegateCheck = UIApplication.shared.delegate as? AppDelegate {
            
            appDelegate = appDelegateCheck
            
        } else {
            
            displayAlert(viewController: self, title: "Error", message: "Something strange has happened and we do not have access to app delegate, please try again.")
            
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AddressBook")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(fetchRequest) as [NSManagedObject]
            
            if results.count > 0 {
                
                for data in results {
                    
                    if address == data.value(forKey: "address") as? String {
                        
                        if keyToEdit == "label" {
                            
                            data.setValue(newValue, forKey: keyToEdit)
                            displayAlert(viewController: self, title: "Success", message: "You updated \"\(oldValue)\" to \"\(newValue)\". Swipe the table to refresh it.")
                            
                        } else if keyToEdit == "privateKey" {
                            
                            data.setValue(newValue, forKey: keyToEdit)
                            data.setValue("cold", forKey: "type")
                            displayAlert(viewController: self, title: "Success", message: "The wallet is now cold. Swipe the table to refresh it.")
                            
                        } else {
                            
                            data.setValue(newValue, forKey: keyToEdit)
                            
                        }
                        
                        print("edited succesfully")
                        
                        do {
                            
                            try context.save()
                            
                        } catch {
                            
                            print("error editing")
                            
                        }
                        
                    }
                    
                }
                
            } else {
                
                print("no results")
                
            }
            
        } catch {
            
            print("Failed")
            
        }
    }
    
    func addRange(from: UInt32, to: UInt32) {
        
        self.keyArray.removeAll()
        self.HDChildTable.reloadData()
        
        let aespassword = KeychainWrapper.standard.string(forKey: "AESPassword")!
        let network = self.masterWallet["network"] as! String
        let type = self.masterWallet["type"] as! String
        let address = self.masterWallet["address"] as! String
        
        
        if let xpriv = self.masterWallet["xpriv"] as? String, xpriv != "" {
            
            if let decryptedXpriv = AES256CBC.decryptString(xpriv, password: aespassword) {
                
                if let keychain = BTCKeychain.init(extendedKey: decryptedXpriv) {
                    
                    keychain.key.isPublicKeyCompressed = true
                    
                    for i in from ... to {
                        
                        let int = UInt32(i)
                        
                        var addressHD = String()
                        var privateKey = String()
                        
                        if network == "testnet" {
                            
                            privateKey = (keychain.key(at: int).privateKeyAddressTestnet.string)
                            addressHD = (keychain.key(at: int).addressTestnet.string)
                            
                        } else if network == "mainnet" {
                            
                            privateKey = (keychain.key(at: int).privateKeyAddress.string)
                            addressHD = (keychain.key(at: int).address.string)
                            
                        }
                        
                        var bitcoinAddress = String()
                        
                        if address.hasPrefix("1") || address.hasPrefix("3") || address.hasPrefix("2") || address.hasPrefix("m") || address.hasPrefix("n") {
                            
                            bitcoinAddress = addressHD
                            
                        } else if address.hasPrefix("bc1") || address.hasPrefix("tb") {
                            
                            let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain.key(at: int).compressedPublicKey as Data!) as Data!) as Data!
                            
                            do {
                                
                                if network == "mainnet" {
                                    
                                    bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                                    
                                } else if network == "testnet" {
                                    
                                    bitcoinAddress = try segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                                    
                                }
                                
                            } catch {
                                
                                displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                
                            }
                            
                        }
                        
                        let dict = ["address":bitcoinAddress,"privateKey":privateKey,"balance":"", "fiatBalance":"", "index":"\(int)"]
                        self.keyArray.append(dict)
                        
                    }
                    
                    keychain.key.clear()
                    self.HDChildTable.reloadData()
                    DispatchQueue.main.async {
                        UIImpactFeedbackGenerator().impactOccurred()
                    }
                    
                    for (index, key) in keyArray.enumerated() {
                        
                        self.checkBalance(address: key["address"] as! String, index: index, network: network, type: type)
                    }
                }
                
            }
            
            
        } else if let mnemonic = self.masterWallet["mnemonic"] as? String {
            
            if mnemonic != "" {
                
                if let decryptedMnemonic = AES256CBC.decryptString(mnemonic, password: aespassword) {
                    
                    print("decryptedMnemonic = \(decryptedMnemonic)")
                    let replaceSpaces = decryptedMnemonic.replacingOccurrences(of: " ", with: "")
                    let words = replaceSpaces.split(separator: ",")
                    print("words = \(words)")
                    var password = ""
                    
                    if let passwordCheck = KeychainWrapper.standard.string(forKey: "BIP39Password") {
                        
                        password = passwordCheck
                        
                    }
                    
                    if let testInputMnemonic = BTCMnemonic.init(words: words, password: password, wordListType: BTCMnemonicWordListType.english) {
                        
                        let keychain = testInputMnemonic.keychain.derivedKeychain(withPath: "m/44'/0'/0'/0")
                        keychain?.key.isPublicKeyCompressed = true
                        
                        for i in from ... to {
                            
                            let int = UInt32(i)
                            
                            var addressHD = String()
                            var privateKey = String()
                            
                            if network == "testnet" {
                                
                                privateKey = (keychain?.key(at: int).privateKeyAddressTestnet.string)!
                                addressHD = (keychain?.key(at: int).addressTestnet.string)!
                                
                            } else if network == "mainnet" {
                                
                                privateKey = (keychain?.key(at: int).privateKeyAddress.string)!
                                addressHD = (keychain?.key(at: int).address.string)!
                                
                            }
                            
                            var bitcoinAddress = String()
                            
                            if address.hasPrefix("1") || address.hasPrefix("3") || address.hasPrefix("2") || address.hasPrefix("m") || address.hasPrefix("n") {
                                
                                bitcoinAddress = addressHD
                                
                            } else if address.hasPrefix("bc1") || address.hasPrefix("tb") {
                                
                                let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain?.key(at: int).compressedPublicKey as Data!) as Data!) as Data!
                                
                                do {
                                    
                                    if network == "mainnet" {
                                        
                                        bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                                        
                                    } else if network == "testnet" {
                                        
                                        bitcoinAddress = try segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                                        
                                    }
                                    
                                } catch {
                                    
                                    displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                    
                                }
                                
                            }
                            
                            let dict = ["address":bitcoinAddress,"privateKey":privateKey,"balance":"", "fiatBalance":"", "index":"\(int)"]
                            self.keyArray.append(dict)
                            
                        }
                        
                        keychain?.key.clear()
                        self.HDChildTable.reloadData()
                        
                        DispatchQueue.main.async {
                            UIImpactFeedbackGenerator().impactOccurred()
                        }
                        
                        for (index, key) in keyArray.enumerated() {
                            
                            self.checkBalance(address: key["address"] as! String, index: index, network: network, type: type)
                        }
                        
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            
                            displayAlert(viewController: self, title: "Error", message: "Sorry we had a problem with your seed, please try again, you can contact us at BitSenseApp@gmail.com if you have an issue.")
                        }
                    }
                }
                
            } else if let xpub = self.masterWallet["xpub"] as? String {
                
                if xpub != "" {
                    
                    print("xpub = \(xpub)")
                    
                    if let decryptedXpub = AES256CBC.decryptString(xpub, password: aespassword) {
                        
                        if let watchOnlyTestKey = BTCKeychain.init(extendedKey: decryptedXpub) {
                            
                            for i in from ... to {
                                
                                let int = UInt32(i)
                                
                                var addressHD = String()
                                
                                if network == "testnet" {
                                    
                                    addressHD = (watchOnlyTestKey.key(at: int).addressTestnet.string)
                                    
                                } else if network == "mainnet" {
                                    
                                    addressHD = (watchOnlyTestKey.key(at: int).address.string)
                                    
                                }
                                
                                var bitcoinAddress = String()
                                
                                if address.hasPrefix("1") || address.hasPrefix("3") || address.hasPrefix("2") || address.hasPrefix("m") || address.hasPrefix("n") {
                                    
                                    bitcoinAddress = addressHD
                                    
                                } else if address.hasPrefix("bc1") || address.hasPrefix("tb") {
                                    
                                    let compressedPKData = BTCRIPEMD160(BTCSHA256(watchOnlyTestKey.key(at: int).compressedPublicKey as Data!) as Data!) as Data!
                                    
                                    do {
                                        
                                        if network == "mainnet" {
                                            
                                            bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                                            
                                        } else if network == "testnet" {
                                            
                                            bitcoinAddress = try segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                                            
                                        }
                                        
                                    } catch {
                                        
                                        displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                        
                                    }
                                    
                                }
                                
                                let dict = ["address":bitcoinAddress,"privateKey":"","balance":"", "fiatBalance":"", "index":"\(int)"]
                                self.keyArray.append(dict)
                                
                            }
                            
                            watchOnlyTestKey.key.clear()
                            self.HDChildTable.reloadData()
                            
                            DispatchQueue.main.async {
                                UIImpactFeedbackGenerator().impactOccurred()
                            }
                            
                            for (index, key) in keyArray.enumerated() {
                                
                                self.checkBalance(address: key["address"] as! String, index: index, network: network, type: type)
                            }
                            
                            
                        } else {
                            
                            DispatchQueue.main.async {
                                
                                displayAlert(viewController: self, title: "Error", message: "Sorry we had a problem with that xpub, please try again.")
                            }
                        }
                        
                    } else {
                        
                        displayAlert(viewController: self, title: "Error", message: "Error decrypting your xpub.")
                    }
                }
            }
        }
        
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return keyArray.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HDCell", for: indexPath)
        cell.layer.cornerRadius = 10
        cell.selectionStyle = .none
        cell.contentView.alpha = 0.8
        let balanceLabel = cell.viewWithTag(2) as! UILabel
        let nameLabel = cell.viewWithTag(1) as! UILabel
        let fiat = cell.viewWithTag(3) as! UILabel
        let index = cell.viewWithTag(4) as! UILabel
        let dictionary = keyArray[indexPath.section]
        nameLabel.text = (dictionary["address"] as! String)
        nameLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 18)
        nameLabel.adjustsFontSizeToFitWidth = true
        balanceLabel.text = (dictionary["balance"] as! String)
        balanceLabel.font = UIFont.init(name: "HelveticaNeue", size: 15)
        balanceLabel.textColor = UIColor.white
        fiat.text = (dictionary["fiatBalance"] as! String)
        fiat.font = UIFont.init(name: "HelveticaNeue", size: 15)
        fiat.textColor = UIColor.white
        index.text = "#\((dictionary["index"] as! String))"
        index.font = UIFont.init(name: "HelveticaNeue", size: 15)
        index.textColor = UIColor.white
        nameLabel.textColor = UIColor.white
        balanceLabel.textColor = UIColor.white
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        self.index = UInt32(indexPath.section)
        self.wallet = self.keyArray[indexPath.section]
        self.showButtonView()
        
    }
    
    func addButtonView() {
        
        let modelName = UIDevice.modelName
        
        if modelName == "iPhone X" {
            buttonView.frame = CGRect(x: 0, y: self.view.frame.maxY + 6, width: view.frame.width, height: 160)
        } else {
            buttonView.frame = CGRect(x: 0, y: view.frame.maxY + 6, width: view.frame.width, height: 100)
        }
        
        buttonView.backgroundColor = UIColor.black
        buttonView.layer.shadowColor = UIColor.black.cgColor
        buttonView.layer.shadowOffset = CGSize(width: -2.5, height: -2.5)
        buttonView.layer.shadowRadius = 2.5
        buttonView.layer.shadowOpacity = 0.5
        buttonViewVisible = false
        view.addSubview(buttonView)
        
        let createInvoiceButton =  UIButton(frame: CGRect(x: 10, y: 25, width: 35, height: 35))
        createInvoiceButton.showsTouchWhenHighlighted = true
        createInvoiceButton.setImage(#imageLiteral(resourceName: "whiteInvoice.png"), for: .normal)
        createInvoiceButton.addTarget(self, action: #selector(createWalletInvoice), for: .touchUpInside)
        buttonView.addSubview(createInvoiceButton)
        
        let createInvoiceLabel = UILabel(frame: CGRect(x: createInvoiceButton.center.x - (createInvoiceButton.frame.width / 2), y: 61, width: createInvoiceButton.frame.width, height: 12))
        createInvoiceLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        createInvoiceLabel.textColor = UIColor.white
        createInvoiceLabel.textAlignment = .center
        createInvoiceLabel.text = "Invoice"
        buttonView.addSubview(createInvoiceLabel)
        
        let spendButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) - (self.view.frame.width / 4 - (35/2)) - 5, y: 25, width: 35, height: 35))
        spendButton.showsTouchWhenHighlighted = true
        spendButton.setImage(#imageLiteral(resourceName: "whitePay.png"), for: .normal)
        spendButton.addTarget(self, action: #selector(spendFromWallet), for: .touchUpInside)
        buttonView.addSubview(spendButton)
        
        let spendLabel = UILabel(frame: CGRect(x: spendButton.center.x - (spendButton.frame.width / 2), y: 61, width: spendButton.frame.width, height: 12))
        spendLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        spendLabel.textColor = UIColor.white
        spendLabel.textAlignment = .center
        spendLabel.text = "Pay"
        buttonView.addSubview(spendLabel)
        
        let historyButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)), y: 25, width: 35, height: 35))
        historyButton.showsTouchWhenHighlighted = true
        historyButton.setImage(#imageLiteral(resourceName: "whiteHistory.png"), for: .normal)
        historyButton.addTarget(self, action: #selector(getHistoryWallet), for: .touchUpInside)
        buttonView.addSubview(historyButton)
        
        let historyLabel = UILabel(frame: CGRect(x: historyButton.center.x - (historyButton.frame.width / 2), y: 61, width: historyButton.frame.width, height: 12))
        historyLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        historyLabel.textColor = UIColor.white
        historyLabel.textAlignment = .center
        historyLabel.text = "History"
        buttonView.addSubview(historyLabel)
        
        let addSaveButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) + (self.view.frame.width / 4 - (35/2)) - 5, y: 25, width: 35, height: 35))
        addSaveButton.showsTouchWhenHighlighted = true
        addSaveButton.setImage(#imageLiteral(resourceName: "whiteSave.png"), for: .normal)
        addSaveButton.addTarget(self, action: #selector(saveWallet), for: .touchUpInside)
        buttonView.addSubview(addSaveButton)
        
        let saveLabel = UILabel(frame: CGRect(x: addSaveButton.center.x - (addSaveButton.frame.width / 2), y: 61, width: addSaveButton.frame.width, height: 12))
        saveLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        saveLabel.textColor = UIColor.white
        saveLabel.textAlignment = .center
        saveLabel.text = "Save"
        buttonView.addSubview(saveLabel)
        
       let exportButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 45, y: 25, width: 35, height: 35))
        exportButton.showsTouchWhenHighlighted = true
        exportButton.setImage(#imageLiteral(resourceName: "whiteQR.png"), for: .normal)
        exportButton.addTarget(self, action: #selector(exportWallet), for: .touchUpInside)
        buttonView.addSubview(exportButton)
        
        let exportLabel = UILabel(frame: CGRect(x: exportButton.center.x - (exportButton.frame.width / 2), y: 61, width: exportButton.frame.width, height: 12))
        exportLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        exportLabel.textColor = UIColor.white
        exportLabel.textAlignment = .center
        exportLabel.text = "Export"
        buttonView.addSubview(exportLabel)
        
    }
    
    @objc func exportWallet() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        
        
        func authorize(item: String) {
            
            if UserDefaults.standard.object(forKey: "bioMetricsEnabled") != nil {
                
                self.authenticationWithTouchID(item: item)
                
            } else if let _ = KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
                
                var password = String()
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Please input your password", message: "Please enter your password to export your private key", preferredStyle: .alert)
                    
                    alert.addTextField { (textField1) in
                        
                        textField1.placeholder = "Enter Password"
                        textField1.isSecureTextEntry = true
                        
                    }
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Export", comment: ""), style: .default, handler: { (action) in
                        
                        password = alert.textFields![0].text!
                        
                        if password == KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
                            
                            self.walletToExport["stringToExport"] = item
                            self.performSegue(withIdentifier: "exportHD", sender: self)
                            
                            
                        } else {
                            
                            displayAlert(viewController: self, title: "Error", message: "Incorrect password!")
                        }
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                        
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            
        }
        
        var array = [[String:Any]]()
        let privateKey = self.wallet["privateKey"] as! String
        let address = self.wallet["address"] as! String
        let name = address
        
        array.append(["stringToExport":privateKey, "descriptor":"privateKey", "title":"Private Key", "label":name])
        array.append(["stringToExport":address, "descriptor":"address", "title":"Address", "label":name])
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Select Item to Export", message: "From: \(name)", preferredStyle: .actionSheet)
            
            for item in array {
                
                let title = item["title"] as! String
                
                if item["stringToExport"] as! String != "" {
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString(title, comment: ""), style: .default, handler: { (action) in
                        
                        self.walletToExport = item
                        
                        switch title {
                        case "Private Key":
                            
                            if !isInternetAvailable() {
                                
                              authorize(item:item["stringToExport"] as! String)
                                
                            } else {
                                
                                displayAlert(viewController: self, title: "Security Alert!", message: "You must put your device into airplane mode and turn off wifi in order to do that.")
                            }
                            
                        default: self.performSegue(withIdentifier: "exportHD", sender: self)
                        }
                        
                    }))
                    
                }
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
                
            }))
            
            alert.popoverPresentationController?.sourceView = self.view
            
            self.present(alert, animated: true) {
                print("option menu presented")
            }
            
        }
        
    }
    
    @objc func spendFromWallet() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.performSegue(withIdentifier: "spendFromChild", sender: self)
    }
    
    @objc func saveWallet() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        addButtonView()
        
        let network = self.masterWallet["network"] as! String
        let type = self.masterWallet["type"] as! String
        let address = self.wallet["address"] as! String
        var pubkey = ""
        var privateKey = ""
        //let xpub = self.masterWallet["xpub"] as! String
        
        if let pk = self.wallet["privateKey"] as? String {
            privateKey = pk
            if let key = BTCKey.init(wif: pk) {
                pubkey = key.publicKey.hex()
            }
        }
        
        let success = BitKeys.saveWallet(viewController: self, mnemonic: "", xpub: "", address: address, privateKey: privateKey, publicKey: pubkey, redemptionScript: "", network: network, type: type, index: self.index, label: "", xpriv: "")
        if success {
            displayAlert(viewController: self, title: "Success", message: "Your new wallet was saved")
        } else {
            displayAlert(viewController: self, title: "Error", message: "We had an issue please contact us at BitSenseApp@gmail.com.")
        }
    }
    
    @objc func getHistoryWallet() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        performSegue(withIdentifier: "checkHistoryFromHD", sender: self)
        
    }
    
    func checkBalance(address: String, index: Int, network: String, type: String) {
        print("checkBalance")
        
        var url:NSURL!
        var btcAmount = ""
        
        func getSegwitBalance() {
            
            let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
                
                do {
                    
                    if error != nil {
                        
                        print(error as Any)
                        self.removeSpinner()
                        
                    } else {
                        
                        if let urlContent = data {
                            
                            do {
                                
                                let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                                
                                if let btcAmountCheck = ((jsonAddressResult["data"] as? NSArray)?[0] as? NSDictionary)?["sum_value_unspent"] as? Double {
                                    
                                    let btcAmount = btcAmountCheck.avoidNotation
                                    
                                    self.keyArray[index]["fiatBalance"] = self.convertBTCtoCurrency(btcAmount: btcAmount, exchangeRate: self.exchangeRate)
                                    
                                    self.keyArray[index]["balance"] = btcAmount + " BTC"
                                    
                                    let indexPath = IndexPath(item: 0, section: index)
                                    DispatchQueue.main.async {
                                        self.HDChildTable.reloadRows(at: [indexPath], with: .none)
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
        
        func getLegacyBalance() {
            
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
                                    
                                    btcAmount = (finalBalanceCheck / 100000000).avoidNotation
                                    
                                    self.keyArray[index]["fiatBalance"] = self.convertBTCtoCurrency(btcAmount: btcAmount, exchangeRate: self.exchangeRate)
                                    
                                    self.keyArray[index]["balance"] = btcAmount + " BTC"
                                    
                                    let indexPath = IndexPath(item: 0, section: index)
                                    DispatchQueue.main.async {
                                        self.HDChildTable.reloadRows(at: [indexPath], with: .none)
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
        
        func getTestNetBalance() {
            
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
                                    
                                    btcAmount = (finalBalanceCheck / 100000000).avoidNotation
                                    
                                    self.keyArray[index]["fiatBalance"] = self.convertBTCtoCurrency(btcAmount: btcAmount, exchangeRate: self.exchangeRate)
                                    
                                    self.keyArray[index]["balance"] = btcAmount + " tBTC"
                                    
                                    let indexPath = IndexPath(item: 0, section: index)
                                    DispatchQueue.main.async {
                                        self.HDChildTable.reloadRows(at: [indexPath], with: .none)
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
        
        if address.hasPrefix("1") || address.hasPrefix("3") {
            
            url = NSURL(string: "https://blockchain.info/rawaddr/\(address)")
            getLegacyBalance()
            
        } else if address.hasPrefix("m") || address.hasPrefix("2") || address.hasPrefix("n") {
            
            url = NSURL(string: "https://testnet.blockchain.info/rawaddr/\(address)")
            
            getTestNetBalance()
            
        } else if address.hasPrefix("b") {
            
            url = NSURL(string: "https://api.blockchair.com/bitcoin/dashboards/address/\(address)")
            getSegwitBalance()
            
        } else if address.hasPrefix("t") {
            
            displayAlert(viewController: self, title: "Error", message: "We are unable to find a balance for address: \(address).\n\nWe can not find a testnet blockexplorer that is bech32 compatible, if you know of one please email us at tripkeyapp@gmail.com")
            
        }
        
        
    }
    
    func removeSpinner() {
        
        DispatchQueue.main.async {
            
            self.activityIndicator.stopAnimating()
            self.refresher.endRefreshing()
            
        }
    }
    
    @objc func goToSettings() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.performSegue(withIdentifier: "goToSettingsFromChild", sender: self)
        
    }
    
    @objc func createWalletInvoice() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.performSegue(withIdentifier: "createChildInvoice", sender: self)
       
    }
    
    
    
    func authenticationWithTouchID(item: String) {
        
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
        
        var authError: NSError?
        let reasonString = "To Export a Secret"
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    DispatchQueue.main.async {
                            
                        self.walletToExport["stringToExport"] = item
                        self.performSegue(withIdentifier: "exportHD", sender: self)
                            
                    }
                    
                    
                } else {
                    //TODO: User did not authenticate successfully, look at error and take appropriate action
                    guard let error = evaluateError else {
                        return
                    }
                    
                    displayAlert(viewController: self, title: "Error", message: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    
                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                    
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            displayAlert(viewController: self, title: "Error", message: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
        }
    }
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
                
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
            default:
                message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."
                
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"
                
            default:
                message = "Did not find error code on LAError object"
            }
        }
        
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }

}
