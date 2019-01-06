//
//  CreateInvoiceViewController.swift
//  BitKeys
//
//  Created by Peter on 7/21/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import CoreData
import AES256CBC

class CreateInvoiceViewController: UIViewController  {
    
    var addressBook = [[String: Any]]()
    var wallet = [String:Any]()
    var HDAddress = String()
    let segwit = SegwitAddrCoder()
    let backButton = UIButton()
    var privateKeyQRView = UIImageView()
    var privateKeyQRCode = UIImage()
    var settingsButton = UIButton()
    var amountToSend = UITextField()
    var currency = String()
    var textToShare = String()
    var fileName = String()
    let backUpButton = UIButton()
    let createButton = UIButton()
    let amountLabel = UILabel()
    let privateKeyTitle = UILabel()
    let myField = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        addressBook = checkAddressBook()
        
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
        
        newAddress(wallet: wallet)
    }

    @objc func checkforHD() {
        
        addressBook = checkAddressBook()
        
        for (index, address) in addressBook.enumerated() {
            
            if address["address"] as! String == self.wallet["address"] as! String {
                
                self.wallet = self.addressBook[index]
            }
        }
        
        let address = self.wallet["address"] as! String
        let network = self.wallet["network"] as! String
        var aesPassword = String()
        
        if let aespasswordCheck = KeychainWrapper.standard.string(forKey: "AESPassword") {
            
            aesPassword = aespasswordCheck
            
            if let xpub = self.wallet["xpub"] as? String {
                
                if xpub != "" {
                    
                    if let decryptedXpub = AES256CBC.decryptString(xpub, password: aesPassword) {
                        
                        if let index = self.wallet["index"] as? UInt32 {
                            
                            self.createInvoiceforHD(network: network, address: address, index: index + 1, xpub: decryptedXpub)
                            
                        }
                        
                    } else {
                        
                        displayAlert(viewController: self, title: "Error", message: "Error decrypting your xpub.")
                    }
                    
                } else {
                    
                    self.HDAddress = address
                    self.createWalletInvoice()
                    
                }
                
            }
            
        }
        
    }
    
    func createInvoiceforHD(network: String, address: String, index: UInt32, xpub: String) {
        
        if let watchOnlyTestKey = BTCKeychain.init(extendedKey: xpub) {
            
            if network == "testnet" {
                
                self.HDAddress = (watchOnlyTestKey.key(at: index).addressTestnet.string)
                
            } else if network == "mainnet" {
                
                self.HDAddress = (watchOnlyTestKey.key(at: index).address.string)
                
            }
            
            if address.hasPrefix("1") || address.hasPrefix("3") || address.hasPrefix("2") || address.hasPrefix("m") || address.hasPrefix("n") {
                
                self.createWalletInvoice()
                self.editHDWallet(address: address, newValue: UInt32(index), oldValue: index, keyToEdit: "index")
                
            } else if address.hasPrefix("bc1") || address.hasPrefix("tb") {
                
                let compressedPKData = BTCRIPEMD160(BTCSHA256(watchOnlyTestKey.key(at: index).compressedPublicKey as Data!) as Data!) as Data!
                
                do {
                    
                    if network == "mainnet" {
                        
                        self.HDAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                        self.createWalletInvoice()
                        self.editHDWallet(address: address, newValue: UInt32(index), oldValue: index, keyToEdit: "index")
                        
                    } else if network == "testnet" {
                        
                        self.HDAddress = try segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                        self.createWalletInvoice()
                        self.editHDWallet(address: address, newValue: UInt32(index), oldValue: index, keyToEdit: "index")
                        
                    }
                    
                } catch {
                    
                    displayAlert(viewController: self, title: "Error", message: "Please try again.")
                    
                }
            }
        }
    }
    
    @objc func createWalletInvoice() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        let modelName = UIDevice.modelName
        let imageView = UIImageView()
        imageView.image = UIImage(named:"background.jpg")
        imageView.frame = self.view.frame
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.alpha = 0.05
        self.view.addSubview(imageView)
        
        if modelName == "iPhone X" {
            self.backButton.frame = CGRect(x: 5, y: 30, width: 55, height: 55)
        } else {
            self.backButton.frame = CGRect(x: 5, y: 20, width: 55, height: 55)
        }
        
        self.backButton.showsTouchWhenHighlighted = true
        self.backButton.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
        self.backButton.addTarget(self, action: #selector(self.dismissInvoiceView), for: .touchUpInside)
        self.view.addSubview(self.backButton)
        self.settingsButton.removeFromSuperview()
        
        if modelName == "iPhone X" {
            self.settingsButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 50, y: 30, width: 45, height: 45))
        } else {
            self.settingsButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 50, y: 20, width: 45, height: 45))
        }
        
        self.settingsButton.showsTouchWhenHighlighted = true
        self.settingsButton.setImage(#imageLiteral(resourceName: "settings2.png"), for: .normal)
        self.settingsButton.addTarget(self, action: #selector(self.goToSettings), for: .touchUpInside)
        self.view.addSubview(self.settingsButton)
        
        self.amountToSend.frame = CGRect(x: 50, y: self.view.frame.minY + 150, width: self.view.frame.width - 100, height: 50)
        self.amountToSend.textAlignment = .center
        self.amountToSend.borderStyle = .roundedRect
        self.amountToSend.backgroundColor = UIColor.groupTableViewBackground
        self.amountToSend.keyboardType = UIKeyboardType.decimalPad
        self.amountToSend.keyboardAppearance = UIKeyboardAppearance.dark
        self.view.addSubview(self.amountToSend)
        
        amountLabel.frame = CGRect(x: 50, y: self.amountToSend.frame.minY - 65, width: self.view.frame.width - 100, height: 55)
        amountLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 30)
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.textAlignment = .center
        amountLabel.textColor = UIColor.white
        amountLabel.text = "Amount to Receive in \(self.currency):"
        addShadow(view: amountLabel)
        
        self.createButton.frame = CGRect(x: self.view.center.x - 40, y: self.amountToSend.frame.maxY + 10, width: 80, height: 55)
        self.createButton.showsTouchWhenHighlighted = true
        addShadow(view: self.createButton)
        self.createButton.backgroundColor = UIColor.clear
        self.createButton.setTitle("Next", for: .normal)
        self.createButton.setTitleColor(UIColor.white, for: .normal)
        self.createButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        self.createButton.addTarget(self, action: #selector(self.createNow), for: .touchUpInside)
        self.view.addSubview(self.createButton)
        
        self.amountToSend.becomeFirstResponder()
        self.view.addSubview(amountLabel)
        
    }
    
    @objc func createNow() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        if self.amountToSend.text != "" {
            
            self.amountToSend.resignFirstResponder()
            self.amountToSend.removeFromSuperview()
            self.amountLabel.removeFromSuperview()
            self.settingsButton.removeFromSuperview()
            self.createButton.removeFromSuperview()
            self.addInvoiceView(address: self.HDAddress, amount: self.amountToSend.text!, currency: self.currency)
            
        } else {
            
            self.amountToSend.resignFirstResponder()
            self.amountToSend.removeFromSuperview()
            self.amountLabel.removeFromSuperview()
            self.settingsButton.removeFromSuperview()
            self.createButton.removeFromSuperview()
            self.addInvoiceView(address: self.HDAddress, amount: "0", currency: self.currency)
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
        
        if currency != "BTC" && currency != "SAT" && amount != "0" {
            
            displayAlert(viewController: self, title: "FYI", message: "This invoice is denominated in \(currency) and not Bitcoin, therefore this invoice will only work for someone who is using BitSense.\n\nInvoices denominated in Bitcoin or Satoshis will work with any wallet that is BIP21 compatible.")
        }
        
        var stringToShare = String()
        var amountToShare = amount
        
        if currency == "SAT" && amount != "0" || currency == "BTC" && amount != "0" {
            
            if currency == "SAT" {
                
                amountToShare = (Double(amount)! / 100000000).avoidNotation
                
            }
            
            stringToShare = "bitcoin:\(self.HDAddress)?amount=\(amountToShare)"
            
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
        self.view.addSubview(privateKeyQRView)
        
        UIView.animate(withDuration: 0.5, animations: {
            
        }, completion: { _ in
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.privateKeyQRView.alpha = 1
                
            }, completion: { _ in
                
                DispatchQueue.main.async {
                    
                    self.privateKeyTitle.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 20) / 2), y: self.privateKeyQRView.frame.minY - 80, width: self.view.frame.width - 20, height: 50)
                    self.fileName = "Invoice"
                    self.privateKeyTitle.text = "Invoice\n🤑"
                    addShadow(view: self.privateKeyTitle)
                    self.privateKeyTitle.numberOfLines = 0
                    self.privateKeyTitle.adjustsFontSizeToFitWidth = true
                    self.privateKeyTitle.font = UIFont.init(name: "HelveticaNeue-Bold", size: 32)
                    self.privateKeyTitle.textColor = UIColor.white
                    self.privateKeyTitle.textAlignment = .center
                    self.view.addSubview(self.privateKeyTitle)
                    
                }
                
                var name = self.wallet["label"] as! String
                if name == "" {
                    name = self.HDAddress
                }
                
                var foramttedCurrency = String()
                self.myField.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 10)/2), y: self.privateKeyQRView.frame.maxY + 10, width: self.view.frame.width - 10, height: 75)
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
                self.view.addSubview(self.myField)
                
                self.backUpButton.frame = CGRect(x: self.view.frame.maxX - 90, y: self.view.frame.maxY - 60, width: 80, height: 55)
                self.backUpButton.showsTouchWhenHighlighted = true
                self.backUpButton.setTitle("Share", for: .normal)
                self.backUpButton.backgroundColor = UIColor.clear
                addShadow(view: self.backUpButton)
                self.backUpButton.setTitleColor(UIColor.white, for: .normal)
                self.backUpButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
                self.backUpButton.addTarget(self, action: #selector(self.goTo(sender:)), for: .touchUpInside)
                self.view.addSubview(self.backUpButton)
                
            })
            
        })
        
    }
    
    func editHDWallet(address: String, newValue: UInt32, oldValue: UInt32, keyToEdit: String) {
        
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
                        
                        if keyToEdit == "index" {
                            
                            data.setValue(newValue, forKey: keyToEdit)
                            
                        }
                        
                        do {
                            
                            try context.save()
                            print("success updated wallet index to \(newValue)")
                            
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
    
    @objc func dismissInvoiceView() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func goToSettings() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.performSegue(withIdentifier: "goToSettings", sender: self)
        
    }
    
    @objc func goTo(sender: UIButton) {
        
        switch sender {
            
        case self.backUpButton:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            self.share(textToShare: self.textToShare, filename: self.fileName)
        default: break
        }
        
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
            
            let alert = UIAlertController(title: "Share", message: "You can share the QR Code or the text format however you'd like", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(qrCodeImage) {
                    
                    let fileName = getDocumentsDirectory().appendingPathComponent(filename + ".png")
                    
                    try? data.write(to: fileName)
                    
                    let objectsToShare = [fileName]
                    
                    DispatchQueue.main.async {
                        
                        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        self.present(activityController, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }))
            
            if self.textToShare != "" {
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Text", comment: ""), style: .default, handler: { (action) in
                    
                    let textToShare = [textToShare]
                    let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                    
                }))
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            alert.popoverPresentationController?.sourceView = self.view
            
            self.present(alert, animated: true) {
                print("option menu presented")
            }
            
        }
        
    }
    
    func newAddress(wallet: [String:Any]) {
        print("newAddress")
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        let aespassword = KeychainWrapper.standard.string(forKey: "AESPassword")!
        let network = wallet["network"] as! String
        let address = wallet["address"] as! String
        
        if let xpub = self.wallet["xpub"] as? String {
            
            if xpub != "" {
                
                if let decryptedXpub = AES256CBC.decryptString(xpub, password: aespassword) {
                    
                    if let index = wallet["index"] as? UInt32 {
                        
                        self.createInvoiceforHD(network: network, address: address, index: index + 1, xpub: decryptedXpub)
                    }
                    
                } else {
                    
                    displayAlert(viewController: self, title: "Error", message: "Error decrypting your xpub.")
                }
                
            } else {
                
                self.HDAddress = wallet["address"] as! String
                self.createWalletInvoice()
            }
            
        } else {
            
            self.HDAddress = wallet["address"] as! String
            self.createWalletInvoice()
        }
    }


}
