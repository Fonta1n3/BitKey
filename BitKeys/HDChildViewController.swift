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
    let blurView = UIView()
    var textToShare = String()
    var fileName = String()
    var backUpButton = UIButton()
    var settingsButton = UIButton()
    var privateKeyQRView = UIImageView()
    var privateKeyQRCode = UIImage()
    var privateKeyTitle = UILabel()
    var myField = UITextView()
    var currency = String()
    var createButton = UIButton()
    var amountToSend = UITextField()
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
    var backgroundColours = [UIColor()]
    var backgroundLoop:Int = 0
    
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
        
        print("masterWallet = \(masterWallet)")
        getArrays()
        
        backgroundColours = [UIColor.red, UIColor.blue, UIColor.yellow]
        backgroundLoop = 0
        animateBackgroundColour()
    }
    
    func animateBackgroundColour () {
        if backgroundLoop < backgroundColours.count - 1 {
            self.backgroundLoop += 1
        } else {
            backgroundLoop = 0
        }
        UIView.animate(withDuration: 5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop];
            self.blurView.backgroundColor =  self.backgroundColours[self.backgroundLoop];
        }) {(Bool) -> Void in
            self.animateBackgroundColour();
        }
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
        
        self.amountToSend.placeholder = "Optional"
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
        
        return keyArray.count//1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1//keyArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HDCell", for: indexPath)
        cell.layer.cornerRadius = 10
        cell.selectionStyle = .none
        
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
        var name = self.wallet["label"] as! String
        let privateKey = self.wallet["privateKey"] as! String
        let address = self.wallet["address"] as! String
        //let publicKey = self.wallet["publicKey"] as! String
        //let mnemonic = self.wallet["mnemonic"] as! String
        //let xpub = self.wallet["xpub"] as! String
        //let xprv = self.wallet["xpriv"] as! String
        //let redemptionScript = self.wallet["redemptionScript"] as! String
        
        if name == "" {
            name = address
        }
        
        array.append(["stringToExport":privateKey, "descriptor":"privateKey", "title":"Private Key", "label":name])
        array.append(["stringToExport":address, "descriptor":"address", "title":"Address", "label":name])
        //array.append(["stringToExport":publicKey, "descriptor":"publicKey", "title":"Public Key", "label":name])
        //array.append(["stringToExport":mnemonic, "descriptor":"mnemonic", "title":"Recovery Phrase", "label":name])
        //array.append(["stringToExport":xpub, "descriptor":"xpub", "title":"XPUB", "label":name])
        //array.append(["stringToExport":xprv, "descriptor":"xpriv", "title":"XPRV", "label":name])
        //array.append(["stringToExport":redemptionScript, "descriptor":"redemptionScript", "title":"Redemption Script", "label":name])
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Select Item to Export", message: "From: \(name)", preferredStyle: .alert)
            
            for item in array {
                
                let title = item["title"] as! String
                
                if item["stringToExport"] as! String != "" {
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString(title, comment: ""), style: .default, handler: { (action) in
                        
                        self.walletToExport = item
                        
                        switch title {
                        case "Private Key": authorize(item:item["stringToExport"] as! String)
                        //case "Recovery Phrase": authorize(item:item["stringToExport"] as! String)
                        //case "XPUB": authorize(item:item["stringToExport"] as! String)
                        //case "XPRV": authorize(item:item["stringToExport"] as! String)
                        //case "Redemption Script": authorize(item:item["stringToExport"] as! String)
                        default: self.performSegue(withIdentifier: "exportHD", sender: self)
                        }
                        
                    }))
                    
                }
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
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
                                    
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.HDChildTable.reloadData()
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
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.HDChildTable.reloadData()
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
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.HDChildTable.reloadData()
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
        
        showButtonView()
        
        let modelName = UIDevice.modelName
        
        self.blurView.frame = self.view.frame
        self.view.addSubview(self.blurView)
        
        let imageView = UIImageView()
        imageView.image = UIImage(named:"background.jpg")
        imageView.frame = self.view.frame
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.alpha = 0.05
        self.blurView.addSubview(imageView)
        
        if modelName == "iPhone X" {
            
            self.backButton = UIButton(frame: CGRect(x: 5, y: 30, width: 55, height: 55))
            
            
        } else {
            
            self.backButton = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
            
        }
        
        self.backButton.showsTouchWhenHighlighted = true
        self.backButton.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
        self.backButton.addTarget(self, action: #selector(self.dismissInvoiceView), for: .touchUpInside)
        self.blurView.addSubview(self.backButton)
        
        self.settingsButton.removeFromSuperview()
        
        if modelName == "iPhone X" {
            
            self.settingsButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 50, y: 30, width: 45, height: 45))
            
        } else {
            
            self.settingsButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 50, y: 20, width: 45, height: 45))
            
        }
        
        self.settingsButton.showsTouchWhenHighlighted = true
        self.settingsButton.setImage(#imageLiteral(resourceName: "settings2.png"), for: .normal)
        self.settingsButton.addTarget(self, action: #selector(self.goToSettings), for: .touchUpInside)
        self.blurView.addSubview(self.settingsButton)
        
        self.amountToSend.frame = CGRect(x: 50, y: self.view.frame.minY + 150, width: self.view.frame.width - 100, height: 50)
        self.amountToSend.textAlignment = .center
        self.amountToSend.borderStyle = .roundedRect
        self.amountToSend.backgroundColor = UIColor.groupTableViewBackground
        self.amountToSend.keyboardType = UIKeyboardType.decimalPad
        self.amountToSend.keyboardAppearance = UIKeyboardAppearance.dark
        self.blurView.addSubview(self.amountToSend)
        
        amountLabel.frame = CGRect(x: 50, y: self.amountToSend.frame.minY - 65, width: self.view.frame.width - 100, height: 55)
        amountLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 30)
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.textAlignment = .center
        amountLabel.textColor = UIColor.white
        amountLabel.text = "Amount to Receive in \(self.currency):"
        addShadow(view: amountLabel)
        
        self.createButton = UIButton(frame: CGRect(x: self.view.center.x - 40, y: self.amountToSend.frame.maxY + 10, width: 80, height: 55))
        self.createButton.showsTouchWhenHighlighted = true
        addShadow(view: self.createButton)
        self.createButton.backgroundColor = UIColor.clear
        self.createButton.setTitle("Next", for: .normal)
        self.createButton.setTitleColor(UIColor.white, for: .normal)
        self.createButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        self.createButton.addTarget(self, action: #selector(self.createNow), for: .touchUpInside)
        self.blurView.addSubview(self.createButton)
        
        self.amountToSend.becomeFirstResponder()
        self.blurView.addSubview(amountLabel)
        
    }
    
    @objc func createNow() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        if self.amountToSend.text != "" {
            
            self.amountToSend.resignFirstResponder()
            self.amountToSend.removeFromSuperview()
            self.amountLabel.removeFromSuperview()
            self.amountLabel.removeFromSuperview()
            self.settingsButton.removeFromSuperview()
            self.createButton.removeFromSuperview()
            
            self.addInvoiceView(address: self.wallet["address"] as! String, amount: self.amountToSend.text!, currency: self.currency)
            
        } else {
            
            self.amountToSend.resignFirstResponder()
            self.amountToSend.removeFromSuperview()
            self.amountLabel.removeFromSuperview()
            self.amountLabel.removeFromSuperview()
            self.settingsButton.removeFromSuperview()
            self.createButton.removeFromSuperview()
            
            self.addInvoiceView(address: self.wallet["address"] as! String, amount: "0", currency: self.currency)
        }
        
    }
    
    func generateQrCode(key: String) -> UIImage? {
        print("generateQrCode")
        let ciContext = CIContext()
        let data = key.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let upScaledImage = filter.outputImage?.transformed(by: transform)
            let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
            let qrCode = UIImage(cgImage: cgImage!)
            return qrCode
        }
        
        return nil
        
    }
    
    func addInvoiceView(address: String, amount: String, currency: String) {
        
        print("amount = \(amount)")
        
        if currency != "BTC" && currency != "SAT" {
            
            displayAlert(viewController: self, title: "FYI", message: "This invoice is denominated in \(currency) and not Bitcoin, therefore this invoice will only work for someone who is using BitSense.\n\nInvoices denominated in Bitcoin or Satoshis will work with any wallet that is BIP21 compatible.")
        }
        
        var stringToShare = String()
        var amountToShare = amount
        
        if currency == "SAT" && amount != "0" || currency == "BTC" && amount != "0" {
            
            if currency == "SAT" {
                
                amountToShare = (Double(amount)! / 100000000).avoidNotation
                
            }
            
            stringToShare = "bitcoin:\(address)?amount=\(amountToShare)"
            
        } else if self.currency != "SAT" && amount != "0" || self.currency != "BTC" && amount != "0" {
            
            stringToShare = "address:\(address)?amount:\(amountToShare)?currency:\(currency)"
            
        } else if currency == "SAT" && amount == "0" || currency == "BTC" && amount == "0" {
            
            stringToShare = "bitcoin:\(address)"
            
        } else if self.currency != "SAT" && amount == "0" || self.currency != "BTC" && amount == "0" {
            
            stringToShare = "bitcoin:\(address)"
            
        }
        
        self.privateKeyQRCode = self.generateQrCode(key: stringToShare)!
        self.textToShare = stringToShare
        self.privateKeyQRView = UIImageView(image: privateKeyQRCode)
        privateKeyQRView.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 70) / 2), y: self.view.center.y - ((self.view.frame.width - 70) / 2), width: self.view.frame.width - 70, height: self.view.frame.width - 70)
        privateKeyQRView.alpha = 0
        addShadow(view: privateKeyQRView)
        self.blurView.addSubview(privateKeyQRView)
        
        UIView.animate(withDuration: 0.5, animations: {
            
        }, completion: { _ in
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.privateKeyQRView.alpha = 1
                
            }, completion: { _ in
                
                DispatchQueue.main.async {
                    
                    self.privateKeyTitle = UILabel(frame: CGRect(x: self.view.center.x - ((self.view.frame.width - 20) / 2), y: self.privateKeyQRView.frame.minY - 80, width: self.view.frame.width - 20, height: 50))
                    self.fileName = "Invoice"
                    self.privateKeyTitle.text = "Invoice\n🤑"
                    addShadow(view: self.privateKeyTitle)
                    self.privateKeyTitle.numberOfLines = 0
                    self.privateKeyTitle.adjustsFontSizeToFitWidth = true
                    self.privateKeyTitle.font = UIFont.init(name: "HelveticaNeue-Bold", size: 32)
                    self.privateKeyTitle.textColor = UIColor.white
                    self.privateKeyTitle.textAlignment = .center
                    self.blurView.addSubview(self.privateKeyTitle)
                    
                }
                
                let name = self.wallet["address"] as! String
                
                var foramttedCurrency = String()
                self.myField = UITextView (frame:CGRect(x: self.view.center.x - ((self.view.frame.width - 10)/2), y: self.privateKeyQRView.frame.maxY + 10, width: self.view.frame.width - 10, height: 75))
                self.myField.isEditable = false
                self.myField.backgroundColor = UIColor.clear
                self.myField.textColor = UIColor.white
                addShadow(view: self.myField)
                self.myField.isSelectable = true
                self.myField.font = UIFont.init(name: "HelveticaNeue-Bold", size: 15)
                
                var amountwithcommas = amount
                
                if Double(amount)! > 100.0 {
                    
                    amountwithcommas = (Double(amount)?.withCommas())!
                    
                }
                
                switch (self.currency) {
                case "USD": foramttedCurrency = "US Dollars"
                case "GBP": foramttedCurrency = "British Pounds"
                case "EUR": foramttedCurrency = "Euros"
                case "SAT": foramttedCurrency = "Satoshis"
                case "BTC": foramttedCurrency = "Bitcoin"
                default: break
                }
                if amount != "0" {
                    self.myField.text = "Invoice of \(String(describing: amountwithcommas)) \(foramttedCurrency), to be paid to \(name)"
                } else {
                    self.myField.text = "Send Bitcoin to \(name)"
                }
                
                self.myField.textAlignment = .center
                self.blurView.addSubview(self.myField)
                
                self.backUpButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 90, y: self.view.frame.maxY - 60, width: 80, height: 55))
                self.backUpButton.showsTouchWhenHighlighted = true
                self.backUpButton.setTitle("Share", for: .normal)
                self.backUpButton.backgroundColor = UIColor.clear
                addShadow(view: self.backUpButton)
                self.backUpButton.setTitleColor(UIColor.white, for: .normal)
                self.backUpButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
                self.backUpButton.addTarget(self, action: #selector(self.goTo(sender:)), for: .touchUpInside)
                self.blurView.addSubview(self.backUpButton)
                
            })
            
        })
        
    }
    
    func share(textToShare: String, filename: String) {
        
        DispatchQueue.main.async {
            
            let ciContext = CIContext()
            let data = textToShare.data(using: String.Encoding.ascii)
            var qrCodeImage = UIImage()
            
            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let upScaledImage = filter.outputImage?.transformed(by: transform)
                let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
                qrCodeImage = UIImage(cgImage: cgImage!)
                
            }
            
            if let data = UIImagePNGRepresentation(qrCodeImage) {
                
                let fileName = getDocumentsDirectory().appendingPathComponent(filename + ".png")
                
                try? data.write(to: fileName)
                
                let objectsToShare = [fileName]
                
                DispatchQueue.main.async {
                    
                    let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    self.present(activityController, animated: true, completion: nil)
                    
                }
                
            }
            
        }
        
    }
    
    @objc func goTo(sender: UIButton) {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.share(textToShare: self.textToShare, filename: self.fileName)
        
    }
    
    @objc func dismissInvoiceView() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.backUpButton.removeFromSuperview()
        self.amountToSend.text = ""
        self.privateKeyTitle.text = ""
        self.privateKeyTitle.removeFromSuperview()
        self.textToShare = ""
        self.fileName = ""
        self.settingsButton.removeFromSuperview()
        self.privateKeyQRView.removeFromSuperview()
        self.createButton.removeFromSuperview()
        self.amountToSend.removeFromSuperview()
        self.amountLabel.removeFromSuperview()
        self.myField.removeFromSuperview()
        self.blurView.removeFromSuperview()
        
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
