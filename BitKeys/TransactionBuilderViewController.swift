//
//  TransactionBuilderViewController.swift
//  BitKeys
//
//  Created by Peter on 2/7/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import Signer
import AVFoundation
import SystemConfiguration
//import GoTransactionBuilder

class TransactionBuilderViewController: UIViewController, /*BTCTransactionBuilderDataSource, */AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var simpleMode = Bool()
    var advancedMode = Bool()
    var testnetMode = Bool()
    var mainnetMode = Bool()
    var coldMode = Bool()
    var hotMode = Bool()
    var sweepAmount = String()
    var privateKey = String()
    var imageView:UIView!
    let avCaptureSession = AVCaptureSession()
    var bitcoinAddressQRCode = UIImage()
    var unspentOutputs = NSMutableArray()
    var json = NSMutableDictionary()
    var transactionToBeSigned = [String]()
    var privateKeyToSign = String()
    var videoPreview = UIView()
    var addressToDisplay = UITextField()
    var amountToSend = UITextField()
    var stringURL = String()
    var recievingAddress = String()
    var sendingFromAddress = String()
    var getReceivingAddressMode = Bool()
    var getPayerAddressMode = Bool()
    var getSignatureMode = Bool()
    var signature = String()
    var amount = ""
    var backButton = UIButton()
    var currency = String()
    var amountInBTC = Double()
    var satoshiAmount = Int()
    var connected:Bool!
    var preference = "medium"
    var transactionID = ""
    var rawTransaction = String()
    var fees:Int!
    var manuallySetFee = Bool()
    var totalSize = Int()
    var setFeeMode = Bool()
    var transactionView = UITextView()
    var refreshButton = UIButton()
    var exchangeRate = Double()
    var rawTransactionView = UITextView()
    var pushRawTransactionButton = UIButton()
    var decodeRawTransactionButton = UIButton()
    var xpubkey = String()
    var sweepMode = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("TransactionBuilderViewController")
        
        addressToDisplay.delegate = self
        rawTransactionView.delegate = self
        amountToSend.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        checkUserDefaults()
        getReceivingAddressMode = true
        getSignatureMode = false
        manuallySetFee = false
        setFeeMode = true
        sweepMode = false
        addBackButton()
        addAmount()
        getAmount()
        
    }
    
    func checkUserDefaults() {
        
        print("checkUserDefaults")
        
        simpleMode = UserDefaults.standard.object(forKey: "simpleMode") as! Bool
        advancedMode = UserDefaults.standard.object(forKey: "advancedMode") as! Bool
        coldMode = UserDefaults.standard.object(forKey: "coldMode") as! Bool
        hotMode = UserDefaults.standard.object(forKey: "hotMode") as! Bool
        testnetMode = UserDefaults.standard.object(forKey: "testnetMode") as! Bool
        mainnetMode = UserDefaults.standard.object(forKey: "mainnetMode") as! Bool
        
    }
   
    func isInternetAvailable() -> Bool {
        print("isInternetAvailable")
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        self.connected = isReachable
        return (isReachable && !needsConnection)
    }
    
    func setPreference() {
        print("setPreference")
        
        if simpleMode {
            
            self.preference = "medium"
            self.setFeeMode = false
            
            if self.sweepMode {
                print("self.sweepMode")
                
                self.getSatsAndBTCs()
                
            } else {
                
                self.amountToSend.becomeFirstResponder()
                
                if self.currency != "BTC" {
                    
                    self.getSatoshiAmount()
                    
                } else {
                    
                    self.getSatsAndBTCs()
                    
                }
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: NSLocalizedString("Please set your miner fee preference", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("High Fee (1-2 blocks)", comment: ""), style: .default, handler: { (action) in
                    
                    self.preference = "high"
                    self.setFeeMode = false
                    
                    if self.sweepMode {
                        print("self.sweepMode")
                        
                        self.getSatsAndBTCs()
                        
                    } else {
                        
                        self.amountToSend.becomeFirstResponder()
                        
                        if self.currency != "BTC" && self.currency != "SAT" {
                            
                            self.getSatoshiAmount()
                            
                        } else {
                            
                            self.getSatsAndBTCs()
                        }
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Medium Fee (3-6 blocks)", comment: ""), style: .default, handler: { (action) in
                    
                    self.preference = "medium"
                    self.setFeeMode = false
                    
                    if self.sweepMode {
                        print("self.sweepMode")
                        
                        self.getSatsAndBTCs()
                        
                    } else {
                        
                        self.amountToSend.becomeFirstResponder()
                        
                        if self.currency != "BTC" && self.currency != "SAT" {
                            
                            self.getSatoshiAmount()
                            
                        } else {
                            
                            self.getSatsAndBTCs()
                        }
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Low Fee (7 blocks plus)", comment: ""), style: .default, handler: { (action) in
                    
                    self.preference = "low"
                    self.setFeeMode = false
                    
                    if self.sweepMode {
                        print("self.sweepMode")
                        
                        self.getSatsAndBTCs()
                        
                    } else {
                        
                        self.amountToSend.becomeFirstResponder()
                        
                        if self.currency != "BTC" && self.currency != "SAT" {
                            
                            self.getSatoshiAmount()
                            
                        } else {
                            
                            self.getSatsAndBTCs()
                        }
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Manually Set", comment: ""), style: .default, handler: { (action) in
                    
                    self.preference = ""
                    self.manuallySetFee = true
                    self.addFeeAmount()
                    self.amountToSend.becomeFirstResponder()
                    self.setFeeMode = false
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }

        }
        
        
    }
    
    func getAmount() {
        print("getAmount")
        
        if simpleMode {
            
            self.amountToSend.placeholder = "Amount to send in USD"
            self.currency = "USD"
            self.amountToSend.becomeFirstResponder()
            
        } else {
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: NSLocalizedString("Please choose your currency", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Satoshis", comment: ""), style: .default, handler: { (action) in
                    
                    self.amountToSend.placeholder = "Amount to send in Satoshis"
                    self.currency = "SAT"
                    self.amountToSend.becomeFirstResponder()
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("BTC", comment: ""), style: .default, handler: { (action) in
                    
                    self.amountToSend.placeholder = "Amount to send in BTC"
                    self.currency = "BTC"
                    self.amountToSend.becomeFirstResponder()
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("USD", comment: ""), style: .default, handler: { (action) in
                    
                    self.amountToSend.placeholder = "Amount to send in USD"
                    self.currency = "USD"
                    self.amountToSend.becomeFirstResponder()
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("EUR", comment: ""), style: .default, handler: { (action) in
                    
                    self.amountToSend.placeholder = "Amount to send in EUR"
                    self.currency = "EUR"
                    self.amountToSend.becomeFirstResponder()
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("GBP", comment: ""), style: .default, handler: { (action) in
                    
                    self.amountToSend.placeholder = "Amount to send in GBP"
                    self.currency = "GBP"
                    self.amountToSend.becomeFirstResponder()
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Sweep All Funds", comment: ""), style: .default, handler: { (action) in
                    
                    self.amountToSend.removeFromSuperview()
                    self.sweepMode = true
                    self.currency = "SAT"
                    
                    if self.hotMode {
                        
                        if let wif = UserDefaults.standard.object(forKey: "wif") as? String {
                            
                            if self.testnetMode {
                                
                                let privateKey = BTCPrivateKeyAddressTestnet(string: wif)
                                let key = BTCKey.init(privateKeyAddress: privateKey)
                                key?.isPublicKeyCompressed = true
                                let legacyAddress1 = (key?.addressTestnet.description)!
                                let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
                                self.sendingFromAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                                self.removeSpinner()
                                self.checkBalance(address: self.sendingFromAddress)
                                
                            } else {
                                
                                let privateKey = BTCPrivateKeyAddress(string: wif)
                                let key = BTCKey.init(privateKeyAddress: privateKey)
                                key?.isPublicKeyCompressed = true
                                let legacyAddress1 = (key?.address.description)!
                                let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
                                self.sendingFromAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                                self.removeSpinner()
                                self.checkBalance(address: self.sendingFromAddress)
                                
                            }
                            
                        }
                        
                    } else {
                        
                        self.amount = "-1"
                        self.setPreference()
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Raw Transaction Tool", comment: ""), style: .default, handler: { (action) in
                    
                    self.amountToSend.removeFromSuperview()
                    self.addRawTransactionView()
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    func checkBalance(address: String) {
        
        print("checkBalance")
        
        self.addSpinner()
        
        var url:NSURL!
        
        if testnetMode {
           
            url = NSURL(string: "https://testnet.blockchain.info/rawaddr/\(address)")
            
        } else {
            
            url = NSURL(string: "https://blockchain.info/rawaddr/\(address)")
            
        }
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    self.removeSpinner()
                    DispatchQueue.main.async {
                        self.displayAlert(title: "Error", message: "\(String(describing: error))")
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            if let finalBalanceCheck = jsonAddressResult["final_balance"] as? Double {
                                
                                if self.sweepMode && self.coldMode {
                                    
                                   self.sweepAmount = String(finalBalanceCheck)
                                    self.removeSpinner()
                                    
                                } else {
                                  
                                    self.amount = String(Int(finalBalanceCheck))
                                    self.removeSpinner()
                                    self.setPreference()
                                    
                                }
                                
                            } else {
                                
                                DispatchQueue.main.async {
                                    
                                    self.removeSpinner()
                                    self.displayAlert(title: "Error", message: "Please try again.")
                                    
                                }
                                
                            }
                            
                        } catch {
                            
                            print("JSon processing failed")
                            
                            DispatchQueue.main.async {
                                
                                self.removeSpinner()
                                self.displayAlert(title: "Error", message: "Please try again.")
                                
                            }
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func addRawTransactionView() {
        
        print("addRawTransactionView")
        
        self.rawTransactionView.frame = CGRect(x: (self.view.frame.width / 2) - ((self.view.frame.width - 10) / 2), y: self.view.frame.minY + 100, width: self.view.frame.width - 10, height: 325)
        self.rawTransactionView.textAlignment = .left
        self.rawTransactionView.backgroundColor = UIColor.groupTableViewBackground
        self.rawTransactionView.keyboardDismissMode = .interactive
        self.rawTransactionView.isEditable = true
        self.rawTransactionView.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        self.rawTransactionView.returnKeyType = UIReturnKeyType.done
        self.view.addSubview(self.rawTransactionView)
        
        self.pushRawTransactionButton = UIButton(frame: CGRect(x: self.view.center.x - 150, y: self.rawTransactionView.frame.maxY + 10, width: 300, height: 55))
        self.pushRawTransactionButton.showsTouchWhenHighlighted = true
        self.pushRawTransactionButton.titleLabel?.textAlignment = .center
        self.pushRawTransactionButton.layer.cornerRadius = 10
        self.pushRawTransactionButton.backgroundColor = UIColor.black//lightText
        self.pushRawTransactionButton.layer.shadowColor = UIColor.black.cgColor
        self.pushRawTransactionButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        self.pushRawTransactionButton.layer.shadowRadius = 2.5
        self.pushRawTransactionButton.layer.shadowOpacity = 0.8
        self.pushRawTransactionButton.setTitle("Push", for: .normal)
        self.pushRawTransactionButton.addTarget(self, action: #selector(self.pushRawTransaction), for: .touchUpInside)
        self.view.addSubview(self.pushRawTransactionButton)
        
        self.decodeRawTransactionButton = UIButton(frame: CGRect(x: self.view.center.x - 150, y: self.pushRawTransactionButton.frame.maxY + 10, width: 300, height: 55))
        self.decodeRawTransactionButton.showsTouchWhenHighlighted = true
        self.decodeRawTransactionButton.titleLabel?.textAlignment = .center
        self.decodeRawTransactionButton.layer.cornerRadius = 10
        self.decodeRawTransactionButton.backgroundColor = UIColor.black
        self.decodeRawTransactionButton.layer.shadowColor = UIColor.black.cgColor
        self.decodeRawTransactionButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        self.decodeRawTransactionButton.layer.shadowRadius = 2.5
        self.decodeRawTransactionButton.layer.shadowOpacity = 0.8
        self.decodeRawTransactionButton.setTitle("Decode", for: .normal)
        self.decodeRawTransactionButton.addTarget(self, action: #selector(self.decodeRawTransaction), for: .touchUpInside)
        self.view.addSubview(self.decodeRawTransactionButton)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text as NSString).rangeOfCharacter(from: CharacterSet.newlines).location == NSNotFound {
            return true
        }
        self.rawTransactionView.resignFirstResponder()
        return false
    }
    
    func addBackButton() {
        
        DispatchQueue.main.async {
            
            self.backButton = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
            self.backButton.showsTouchWhenHighlighted = true
            /*self.backButton.layer.cornerRadius = 10
            self.backButton.backgroundColor = UIColor.lightText
            self.backButton.layer.shadowColor = UIColor.black.cgColor
            self.backButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.backButton.layer.shadowRadius = 2.5
            self.backButton.layer.shadowOpacity = 0.8
            self.backButton.setTitle("Back", for: .normal)*/
            self.backButton.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
            self.backButton.addTarget(self, action: #selector(self.home), for: .touchUpInside)
            self.view.addSubview(self.backButton)
            
        }
        
    }
    
    @objc func home() {
        
        self.dismiss(animated: true, completion: nil)
                    
    }

    func addQRScannerView() {
        print("addQRScannerView")
        
        self.videoPreview.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.view.center.y - ((self.view.frame.width - 50)/2), width: self.view.frame.width - 50, height: self.view.frame.width - 50)
        self.view.addSubview(self.videoPreview)
    }
    
    func addFeeAmount() {
        print("addFeeAmount")
        
        self.amountToSend.frame = CGRect(x: self.view.frame.minX + 5, y: self.view.frame.minY + 150, width: self.view.frame.width - 10, height: 50)
        self.amountToSend.textAlignment = .center
        self.amountToSend.borderStyle = .roundedRect
        self.amountToSend.backgroundColor = UIColor.groupTableViewBackground
        self.amountToSend.keyboardType = UIKeyboardType.decimalPad
        self.amountToSend.addDoneButtonToKeyboard(myAction:  #selector(self.setFee))
        self.amountToSend.placeholder = "Fee in Satoshis"
        self.view.addSubview(self.amountToSend)
    }
    
    @objc func setFee() {
        print("setFee")
        
        if self.amountToSend.text != "" {
            
            self.fees = Int(self.amountToSend.text!)!
            self.amountToSend.resignFirstResponder()
            self.amountToSend.removeFromSuperview()
            
        } else {
            
            self.shakeAlert(viewToShake: self.amountToSend)
        }
        
    }
    
    func shakeAlert(viewToShake: UIView) {
        print("shakeAlert")
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: viewToShake.center.x - 10, y: viewToShake.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: viewToShake.center.x + 10, y: viewToShake.center.y))
        
        DispatchQueue.main.async {
            
            viewToShake.layer.add(animation, forKey: "position")
            
        }
    }
    
    func addAmount() {
        print("addAmount")
        
        self.amountToSend.frame = CGRect(x: self.view.frame.minX + 5, y: self.view.frame.minY + 150, width: self.view.frame.width - 10, height: 50)
        self.amountToSend.textAlignment = .center
        self.amountToSend.borderStyle = .roundedRect
        self.amountToSend.backgroundColor = UIColor.groupTableViewBackground
        self.amountToSend.keyboardType = UIKeyboardType.decimalPad
        self.amountToSend.addDoneButtonToKeyboard(myAction:  #selector(self.saveAmountInSatoshis))
        self.amountToSend.placeholder = "Amount to Send"
        self.view.addSubview(self.amountToSend)
    }
    
    @objc func saveAmountInSatoshis() {
        print("saveAmountInSatoshis")
        
        if self.amountToSend.text != "" {
            
            self.amount = self.amountToSend.text!
            self.amountToSend.text = ""
            self.amountToSend.resignFirstResponder()
            self.amountToSend.removeFromSuperview()
            self.setPreference()
            
        } else {
            
           self.shakeAlert(viewToShake: self.amountToSend)
            
        }
        
    }
    
    func addSpinner() {
        print("addSpinner")
        
        DispatchQueue.main.async {
            let bitcoinImage = UIImage(named: "img_311477.png")
            self.imageView = UIImageView(image: bitcoinImage!)
            self.imageView.center = self.view.center
            self.imageView.frame = CGRect(x: self.view.center.x - 50, y: self.view.center.y - 50, width: 100, height: 100)
            self.rotateAnimation(imageView: self.imageView as! UIImageView)
            self.view.addSubview(self.imageView)
        }
        
    }
    
    func removeSpinner() {
        print("removeSpinner")
        
        DispatchQueue.main.async {
            
            if self.imageView != nil {
                
             self.imageView.removeFromSuperview()
                
            }
            
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
    
    func addTextInput() {
        print("addTextInput")
        
        self.addressToDisplay.frame = CGRect(x: self.view.frame.minX + 5, y: self.videoPreview.frame.minY - 55, width: self.view.frame.width - 10, height: 50)
        self.addressToDisplay.textAlignment = .center
        self.addressToDisplay.borderStyle = .roundedRect
        self.addressToDisplay.autocorrectionType = .no
        self.addressToDisplay.autocapitalizationType = .none
        self.addressToDisplay.backgroundColor = UIColor.groupTableViewBackground
        self.addressToDisplay.returnKeyType = UIReturnKeyType.go
        
        if getReceivingAddressMode {
          
            self.addressToDisplay.placeholder = "Scan or Type Receiving Address"
            
        } else if getPayerAddressMode && self.coldMode {
            
            self.addressToDisplay.placeholder = "Scan or Type Debit Address"
            
        } else if getSignatureMode {
            
            self.addressToDisplay.placeholder = "Scan or Type Private Key to debit"
            
        }
        
        self.view.addSubview(self.addressToDisplay)
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        
        if textField == self.amountToSend {
            
            if self.preference == "" {
                
                self.preference = "high"
                
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        
        func processKeys() {
            
            if textField == self.addressToDisplay {
                
                if getReceivingAddressMode {
                    
                    func processReceivingAddress() {
                        
                        self.recievingAddress = self.addressToDisplay.text!
                        
                        self.getReceivingAddressMode = false
                        
                        if self.coldMode {
                            
                            self.getPayerAddressMode = true
                            
                        }
                        
                        self.getSignatureMode = true
                        self.removeScanner()
                        
                        if self.simpleMode {
                            
                            if let wif = UserDefaults.standard.object(forKey: "wif") as? String {
                                
                                if self.testnetMode {
                                    
                                    let privateKey = BTCPrivateKeyAddressTestnet(string: wif)
                                    let key = BTCKey.init(privateKeyAddress: privateKey)
                                    key?.isPublicKeyCompressed = true
                                    let legacyAddress1 = (key?.addressTestnet.description)!
                                    let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
                                    self.sendingFromAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                                    self.getSignatureMode = true
                                    self.removeScanner()
                                    self.makeHTTPPostRequest()
                                    
                                } else {
                                    
                                    let privateKey = BTCPrivateKeyAddress(string: wif)
                                    let key = BTCKey.init(privateKeyAddress: privateKey)
                                    key?.isPublicKeyCompressed = true
                                    let legacyAddress1 = (key?.address.description)!
                                    let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
                                    self.sendingFromAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                                    self.getSignatureMode = true
                                    self.removeScanner()
                                    self.makeHTTPPostRequest()
                                }
                                
                            }
                            
                        } else {
                            
                            if self.hotMode {
                                
                                if let wif = UserDefaults.standard.object(forKey: "wif") as? String {
                                    
                                    if self.testnetMode {
                                        
                                        let privateKey = BTCPrivateKeyAddressTestnet(string: wif)
                                        let key = BTCKey.init(privateKeyAddress: privateKey)
                                        key?.isPublicKeyCompressed = true
                                        let legacyAddress1 = (key?.addressTestnet.description)!
                                        let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
                                        self.sendingFromAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                                        self.getSignatureMode = true
                                        self.removeScanner()
                                        self.makeHTTPPostRequest()
                                        
                                    } else {
                                        
                                        let privateKey = BTCPrivateKeyAddress(string: wif)
                                        let key = BTCKey.init(privateKeyAddress: privateKey)
                                        key?.isPublicKeyCompressed = true
                                        let legacyAddress1 = (key?.address.description)!
                                        let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
                                        self.sendingFromAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                                        self.getSignatureMode = true
                                        self.removeScanner()
                                        self.makeHTTPPostRequest()
                                    }
                                    
                                }
                                
                            } else {
                                
                                self.addScanner()
                                self.addressToDisplay.text = ""
                            }
                            
                        }
                    }
                    
                    if let _ = BTCPublicKeyAddressTestnet.init(string: self.addressToDisplay.text!) {
                        
                        processReceivingAddress()
                        
                    } else if let _ = BTCAddress.init(string: self.addressToDisplay.text!) {
                        
                        processReceivingAddress()
                        
                    } else {
                        
                        displayAlert(title: "Error", message: "That is not a valid Bitcoin Address")
                        
                    }
                    
                } else if getPayerAddressMode && self.coldMode {
                    
                    func processPayerAddress() {
                     
                        self.sendingFromAddress = self.addressToDisplay.text!
                        
                        if sweepMode {
                            
                            self.removeSpinner()
                            self.checkBalance(address: self.sendingFromAddress)
                            
                        }
                        
                        self.getPayerAddressMode = false
                        self.getSignatureMode = true
                        self.removeScanner()
                        self.addressToDisplay.text = ""
                        self.makeHTTPPostRequest()
                        
                    }
                    
                    if let _ = BTCPublicKeyAddressTestnet.init(string: self.addressToDisplay.text!) {
                        
                        processPayerAddress()
                        
                    } else if let _ = BTCAddress.init(string: self.addressToDisplay.text!) {
                        
                        processPayerAddress()
                        
                    } else {
                        
                        displayAlert(title: "Error", message: "That is not a valid Bitcoin Address")
                        
                    }
                    
                    
                } else if getSignatureMode {
                    
                    func processPrivateKey() {
                        
                        DispatchQueue.main.async {
                            
                            self.removeSpinner()
                            self.removeScanner()
                            
                            let alert = UIAlertController(title: NSLocalizedString("Please confirm", comment: ""), message: "We will use private key: \(self.addressToDisplay.text!) to create a signature. You can just check first few and last few characters as if its incorrect the worst that will happen is you'll have to start over.", preferredStyle: UIAlertControllerStyle.actionSheet)
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Looks Good, please sign", comment: ""), style: .default, handler: { (action) in
                                
                                self.getPrivateKeySignature(key: self.addressToDisplay.text!)
                                
                                
                            }))
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                                
                                self.dismiss(animated: true, completion: nil)
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    
                    if let _ = BTCPrivateKeyAddressTestnet.init(string: self.addressToDisplay.text!) {
                        
                        processPrivateKey()
                        
                    } else if let _ = BTCPrivateKeyAddress.init(string: self.addressToDisplay.text!) {
                        
                        processPrivateKey()
                        
                    } else {
                        
                        displayAlert(title: "Error", message: "That is not a valid Bitcoin Address")
                        
                    }
                }
                
            } else if textField == self.amountToSend && self.setFeeMode == false {
                
                if self.currency != "BTC" && self.currency != "SAT" {
                    
                    self.getSatoshiAmount()
                    
                } else {
                    
                    self.getSatsAndBTCs()
                    
                }
            }
        }
        
        if self.getSignatureMode || self.getPayerAddressMode || self.getReceivingAddressMode && textField != self.amountToSend {
            
            if textField.text != "" {
                
                if let _ = BTCAddress.init(string: textField.text) {
                    
                    processKeys()
                    
                } else if let _ = BTCPrivateKeyAddress.init(string: textField.text) {
                    
                    processKeys()
                    
                } else if let _ = BTCPublicKeyAddressTestnet.init(string: textField.text) {
                    
                    processKeys()
                    
                } else if let _ = BTCPrivateKeyAddressTestnet.init(string: textField.text) {
                    
                    processKeys()
                    
                } else {
                    
                    self.displayAlert(title: "Error", message: "That is not a valid Bitcoin Key.")
                    
                }
                
            } else {
                
                self.shakeAlert(viewToShake: textField)
                
            }
            
        } else {
            
            processKeys()
                
        }
        
    }
    
    func getSatsAndBTCs() {
        print("getSatsAndBTCs")
        
        var noNotationBTC = String()
        var noNotationSatoshi = String()
        
        func sendMessage() {
            
            DispatchQueue.main.async {
                
                var message = String()
                
                if self.fees != nil {
                    
                    message = "You would like to send \(noNotationBTC) Bitcoin, equal to \(noNotationSatoshi) Satoshis with a miner fee of \(self.fees!) Satoshis."
                    
                } else {
                    
                    message = "You would like to send \(noNotationBTC) Bitcoin, equal to \(noNotationSatoshi) Satoshis with a \(self.preference) miner fee preference."
                }
                
                let alert = UIAlertController(title: NSLocalizedString("Please Confirm", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                    
                    self.addQRScannerView()
                    self.addTextInput()
                    self.scanQRCode()
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: { (action) in
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        if self.amount == "-1" {
            
            self.amountToSend.removeFromSuperview()
            self.addQRScannerView()
            self.addTextInput()
            self.scanQRCode()
            
            
        } else if self.currency == "BTC" {
            
            self.amountInBTC = Double(self.amount)!
            self.satoshiAmount = Int(self.amountInBTC * 100000000)
            noNotationBTC = self.amountInBTC.avoidNotation
            noNotationSatoshi = Float(self.satoshiAmount).avoidNotation
            sendMessage()
            
        } else if self.currency == "SAT" {
            
            self.satoshiAmount = Int(self.amount)!
            self.amountInBTC = Double(self.amount)! / 100000000
            noNotationBTC = self.amountInBTC.avoidNotation
            noNotationSatoshi = Float(self.satoshiAmount).avoidNotation
            sendMessage()
            
        }
        
    }
    
    func getSatoshiAmount() {
        print("getSatoshiAmount")
        
        self.addSpinner()
        var url:NSURL!
        url = NSURL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    self.removeSpinner()
                    print(error as Any)
                    DispatchQueue.main.async {
                        self.displayAlert(title: "Error", message: "\(String(describing: error))")
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonQuoteResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            if let exchangeCheck = jsonQuoteResult["bpi"] as? NSDictionary {
                                
                                if let exchangeRateCheck = exchangeCheck[self.currency] as? NSDictionary {
                                    
                                    if let rateCheck = exchangeRateCheck["rate_float"] as? Float {
                                        
                                        self.exchangeRate = Double(rateCheck)
                                        self.amountInBTC = Double(self.amount)! / Double(rateCheck)
                                        self.satoshiAmount = Int(self.amountInBTC * 100000000)
                                        let roundedBtcAmount = round(100000000 * self.amountInBTC) / 100000000
                                        
                                        DispatchQueue.main.async {
                                            
                                            var message = String()
                                            
                                            if self.fees != nil {
                                                
                                                let feeInFiat = self.exchangeRate * (Double(self.fees) / 100000000)
                                                let roundedFiatFeeAmount = round(100 * feeInFiat) / 100
                                                let satoshiNoNotation = self.satoshiAmount.avoidNotation
                                                
                                                message = "You would like to send \(self.amount) \(self.currency) which is equal to \(roundedBtcAmount.avoidNotation) Bitcoin or \(satoshiNoNotation) Satoshis, with a miner fee of \(self.fees.withCommas()) Satoshis or \(roundedFiatFeeAmount) \(self.currency)"
                                                
                                            } else if self.preference != "" {
                                                
                                                let satoshiNoNotation = self.satoshiAmount.avoidNotation
                                                print("satoshiNoNotation = \(satoshiNoNotation)")
                                                
                                                
                                                message = "You would like to send \(self.amount) \(self.currency) which is equal to \(roundedBtcAmount.avoidNotation) Bitcoin or \(satoshiNoNotation) Satoshis, with a \(self.preference) miner fee preference."
                                            }
                                            
                                            self.removeSpinner()
                                            
                                            if self.simpleMode {
                                                
                                                self.amountToSend.removeFromSuperview()
                                                self.addScanner()
                                                
                                            } else {
                                                
                                                let alert = UIAlertController(title: NSLocalizedString("Please Confirm", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                                                    
                                                    self.amountToSend.removeFromSuperview()
                                                    self.addScanner()
                                                    
                                                }))
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: { (action) in
                                                    
                                                    self.dismiss(animated: true, completion: nil)
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                            }
                                                
                                            
                                                
                                        }
                                    }
                                }
                            }
                            
                        } catch {
                            
                            self.removeSpinner()
                            print("JSon processing failed")
                            DispatchQueue.main.async {
                                self.displayAlert(title: "Error", message: "Please try again")
                            }
                            
                        }
                    }
                }
            }
        }
        
        task.resume()
        
    }
    
    func addScanner() {
        print("addScanner")
        
        DispatchQueue.main.async {
            self.addQRScannerView()
            self.addTextInput()
            self.scanQRCode()
        }
    }
    
    func removeScanner() {
        print("removeScanner")
        
        DispatchQueue.main.async {
            self.addressToDisplay.removeFromSuperview()
            self.avCaptureSession.stopRunning()
            self.videoPreview.removeFromSuperview()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        
        self.view.endEditing(true)
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing")
        
        addressToDisplay.resignFirstResponder()
            
        return true
    }
    
    enum error: Error {
        
        case noCameraAvailable
        case videoInputInitFail
        
    }
    
    func scanQRCode() {
        
        do {
            
            try scanQRNow()
            print("scanQRNow")
            
        } catch {
            
            print("Failed to scan QR Code")
            
        }
    }
    
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            print("metadataOutput")
            
            addressToDisplay.removeFromSuperview()
            
            let machineReadableCode = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if machineReadableCode.type == AVMetadataObject.ObjectType.qr {
                
                stringURL = machineReadableCode.stringValue!
                
                func processKeys() {
                    
                    if getReceivingAddressMode {
                        print("getReceivingAddressMode")
                        
                        func processReceivingAddress() {
                            
                            if self.coldMode {
                                
                                self.recievingAddress = stringURL
                                self.getReceivingAddressMode = false
                                self.getPayerAddressMode = true
                                self.removeScanner()
                                self.getSignatureMode = true
                                self.addScanner()
                                
                            } else {
                                
                                //debit wallet programmatically
                                if let wif = UserDefaults.standard.object(forKey: "wif") as? String {
                                    
                                    if self.testnetMode {
                                        
                                        self.recievingAddress = stringURL
                                        let privateKey = BTCPrivateKeyAddressTestnet(string: wif)
                                        let key = BTCKey.init(privateKeyAddress: privateKey)
                                        key?.isPublicKeyCompressed = true
                                        let legacyAddress1 = (key?.addressTestnet.description)!
                                        let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
                                        self.sendingFromAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                                        
                                    } else {
                                        
                                        self.recievingAddress = stringURL
                                        let privateKey = BTCPrivateKeyAddress(string: wif)
                                        let key = BTCKey.init(privateKeyAddress: privateKey)
                                        key?.isPublicKeyCompressed = true
                                        let legacyAddress1 = (key?.address.description)!
                                        let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
                                        self.sendingFromAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                                        
                                    }
                                    
                                    self.getSignatureMode = true
                                    self.removeScanner()
                                    self.makeHTTPPostRequest()
                                    
                                } else {
                                    
                                    DispatchQueue.main.async {
                                        self.displayAlert(title: "Error", message: "No private key saved.")
                                    }
                                }
                            }
                        }
                        
                        if let _ = BTCAddress.init(string: stringURL) {
                            
                            processReceivingAddress()
                            
                        } else if let _ = BTCPublicKeyAddressTestnet.init(string: stringURL) {
                            
                            processReceivingAddress()
                            
                        } else {
                            
                            self.displayAlert(title: "Error", message: "That is not a valid Bitcoin Address.")
                            
                        }
                        
                    } else if getPayerAddressMode && self.coldMode {
                        
                        func processPayerAddress() {
                            
                            self.sendingFromAddress = stringURL
                            print("self.sendingFromAddress = \(self.sendingFromAddress)")
                            
                            if sweepMode {
                                
                                self.removeSpinner()
                                self.checkBalance(address: self.sendingFromAddress)
                                
                            }
                            
                            self.getPayerAddressMode = false
                            self.getSignatureMode = true
                            self.removeScanner()
                            self.makeHTTPPostRequest()
                        }
                        
                        if let _ = BTCAddress.init(string: stringURL) {
                            
                            processPayerAddress()
                            
                        } else if let _ = BTCPublicKeyAddressTestnet.init(string: stringURL) {
                            
                            processPayerAddress()
                            
                        } else {
                            
                            self.displayAlert(title: "Error", message: "That is not a valid Bitcoin Address.")
                            
                        }
                        
                    } else if getSignatureMode {
                        
                        func processSignatures() {
                            
                            DispatchQueue.main.async {
                                
                                self.removeScanner()
                                self.removeSpinner()
                                
                                let alert = UIAlertController(title: NSLocalizedString("Please confirm", comment: ""), message: "We will use private key: \(self.stringURL) to create a signature. You can check the first few and last few characters, if its incorrect the worst that will happen is you'll have to start over.", preferredStyle: UIAlertControllerStyle.actionSheet)
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Looks Good, please sign", comment: ""), style: .default, handler: { (action) in
                                    
                                    print("privateKey = \(self.stringURL)")
                                    self.getPrivateKeySignature(key: self.stringURL)
                                    
                                }))
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                                    
                                    self.dismiss(animated: true, completion: nil)
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        
                        if let _ = BTCPrivateKeyAddress.init(string: stringURL) {
                            
                            processSignatures()
                            
                        } else if let _ = BTCPrivateKeyAddress.init(string: stringURL) {
                            
                            processSignatures()
                            
                        } else {
                            
                            self.displayAlert(title: "Error", message: "That is not a valid Bitcoin Address.")
                            
                        }
                    }
                }
                
                if let _ = BTCAddress.init(string: stringURL) {
                    
                    processKeys()
                    
                } else if let _ = BTCPrivateKeyAddress.init(string: stringURL) {
                    
                    processKeys()
                    
                } else if let _ = BTCPublicKeyAddressTestnet.init(string: stringURL) {
                    
                    processKeys()
                    
                } else if let _ = BTCPrivateKeyAddressTestnet.init(string: stringURL) {
                    
                    processKeys()
                    
                } else {
                    
                    self.displayAlert(title: "Error", message: "That is not a valid Bitcoin Key.")
                    
                }
                
            }
        }
    }
    
    func getPrivateKeySignature(key: String) {
        print("getPrivateKeySignature")
        
        if let privateKey = BTCPrivateKeyAddress(string: key) {
          print("privateKey = \(String(describing: privateKey))")
            
            let key = BTCKey.init(privateKeyAddress: privateKey)
            print("privateKey = \(String(describing: privateKey))")
            
            if self.hotMode || self.sweepMode {
                
                if self.testnetMode {
                    
                    let legacyAddress1 = (key?.addressTestnet.description)!
                    let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
                    self.sendingFromAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                    self.privateKey = String(describing: privateKey)
                    
                } else {
                    
                    let legacyAddress1 = (key?.address.description)!
                    let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
                    self.sendingFromAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                    self.privateKey = String(describing: privateKey)
                }
                
                
            }
            
            if self.sweepMode {
                
                self.removeSpinner()
                self.checkBalance(address: self.sendingFromAddress)
            }
            
            
            
            DispatchQueue.main.async {
                
                var message = String()
                
                func postAlert() {
                    
                    let publicKey = key?.publicKey
                    let publicKeyString = BTCHexFromData(publicKey as Data!)
                    print("prvKey = \(String(describing: key?.privateKey.hex()))")
                    self.privateKeyToSign = (key?.privateKey.hex())!
                    
                    var signatureArray = [String]()
                    var pubkeyArray = [String]()
                    
                    for transaction in self.transactionToBeSigned {
                        
                        SignerGetSignature(self.privateKeyToSign, transaction)
                        
                        if let signature = Signer.signature() {
                            
                            signatureArray.append(signature)
                            pubkeyArray.append(publicKeyString!)
                            
                        } else {
                            
                            DispatchQueue.main.async {
                                self.displayAlert(title: "Error", message: "Error creating signatures.")
                            }
                        }
                        
                        
                    }
                    
                    self.json["signatures"] = signatureArray
                    self.json["pubkeys"] = pubkeyArray
                    print("json = \(self.json)")
                    
                    let alert = UIAlertController(title: NSLocalizedString("Please confirm your transaction before sending.", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Send", comment: ""), style: .default, handler: { (action) in
                        
                        self.isInternetAvailable()
                        
                        if self.connected == true {
                            
                            DispatchQueue.main.async {
                                self.postTransaction()
                            }
                            
                            
                            
                        } else {
                            
                            DispatchQueue.main.async {
                                
                                let alert = UIAlertController(title: NSLocalizedString("No Internet Connection.", comment: ""), message: "Please connect now and tap 'Try Again' when you are connected again.", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Try Again", comment: ""), style: .default, handler: { (action) in
                                    
                                    self.isInternetAvailable()
                                    
                                    if self.connected == true {
                                        
                                        DispatchQueue.main.async {
                                            self.postTransaction()
                                        }
                                        
                                    } else {
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.displayAlert(title: "No Internet Connection", message: "In order to broadcast your transaction to the network we need a connection.")
                                            
                                        }
                                        
                                    }
                                    
                                }))
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                                    
                                    self.dismiss(animated: true, completion: nil)
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
                if self.currency != "BTC" && self.currency != "SAT" && self.sweepMode == false {
                    
                    let feeInFiat = self.exchangeRate * (Double(self.fees) / 100000000)
                    let roundedFiatFeeAmount = round(100 * feeInFiat) / 100
                    let roundedFiatToSendAmount = (round(100 * Double(self.amount)!) / 100).withCommas()
                    
                    message = "From: \(self.sendingFromAddress)\nTo: \(self.recievingAddress)\nAmount: \(roundedFiatToSendAmount) \(self.currency) with a miner fee of \(self.fees!.withCommas()) Satoshis or \(roundedFiatFeeAmount) \(self.currency)"
                    postAlert()
                    
                } else if self.currency == "BTC" || self.currency == "SAT" && self.sweepMode == false {
                    
                    if self.sweepAmount != "" {
                        
                       message = "From: \(self.sendingFromAddress)\nTo: \(self.recievingAddress)\nAmount: \(self.sweepAmount) \(self.currency) with a miner fee of \(self.fees!.withCommas()) Satoshis"
                        
                    } else {
                        
                        message = "From: \(self.sendingFromAddress)\nTo: \(self.recievingAddress)\nAmount: \(self.amount) \(self.currency) with a miner fee of \(self.fees!.withCommas()) Satoshis"
                    }
                    
                    postAlert()
                    
                }
                
                if self.sweepMode {
                    
                    self.makeHTTPPostRequest()
                    
                }
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                self.displayAlert(title: "Error", message: "The Private Key is not valid, please try again.")
                
            }
            
        }
        
    }
    
    func scanQRNow() throws {
        
        if self.getReceivingAddressMode {
          
            guard let avCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
                
                print("no camera")
                throw error.noCameraAvailable
                
            }
            
            guard let avCaptureInput = try? AVCaptureDeviceInput(device: avCaptureDevice) else {
                
                print("failed to int camera")
                throw error.videoInputInitFail
            }
            
            let avCaptureMetadataOutput = AVCaptureMetadataOutput()
            avCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            self.avCaptureSession.addInput(avCaptureInput)
            self.avCaptureSession.addOutput(avCaptureMetadataOutput)
            avCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession)
            avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            avCaptureVideoPreviewLayer.frame = videoPreview.bounds
            self.videoPreview.layer.addSublayer(avCaptureVideoPreviewLayer)
            
        }
        
        self.avCaptureSession.startRunning()
        
    }
    
    func makeHTTPPostRequest() {
        print("makeHTTPPostRequest")
        
        self.addSpinner()
        var url:URL!
        
        if testnetMode {
            
            url = URL(string: "https://api.blockcypher.com/v1/btc/test3/txs/new")
            
        } else {
            
            url = URL(string: "https://api.blockcypher.com/v1/btc/main/txs/new")
            
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        if self.sweepMode {
            
            self.satoshiAmount = -1
        }
        
        if self.manuallySetFee {
            
          request.httpBody = "{\"inputs\": [{\"addresses\": [\"\(self.sendingFromAddress)\"]}], \"outputs\": [{\"addresses\": [\"\(self.recievingAddress)\"], \"value\": \(self.satoshiAmount)}],\"fees\": \(self.fees!)}".data(using: .utf8)
            
        } else {
            
            request.httpBody = "{\"inputs\": [{\"addresses\": [\"\(self.sendingFromAddress)\"]}], \"outputs\": [{\"addresses\": [\"\(self.recievingAddress)\"], \"value\": \(self.satoshiAmount)}],\"preference\": \"\(self.preference)\"}".data(using: .utf8)
            
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    self.removeSpinner()
                    
                    DispatchQueue.main.async {
                        
                        self.displayAlert(title: "Error", message: "\(String(describing: error))")
                        
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            if let error = jsonAddressResult["errors"] as? NSArray {
                                
                                self.removeSpinner()
                                
                                DispatchQueue.main.async {
                                    
                                    var errors = [String]()
                                    
                                    for e in error {
                                        
                                        if let errordescription = (e as? NSDictionary)?["error"] as? String {
                                            
                                            errors.append(errordescription)
                                        }
                                        
                                    }
                                    
                                    self.displayAlert(title: "Error", message: "\(errors)")
                                    
                                }
                                
                            } else {
                                
                                if let toSignCheck = jsonAddressResult["tosign"] as? NSArray {
                                    
                                    for tosign in toSignCheck {
                                        
                                        self.transactionToBeSigned.append(tosign as! String)
                                        
                                    }
                                    
                                    self.json = jsonAddressResult.mutableCopy() as! NSMutableDictionary
                                    self.removeScanner()
                                    
                                    if self.setFeeMode == false {
                                        
                                        if let sizeCheck = (jsonAddressResult["tx"] as? NSDictionary)?["fees"] as? NSInteger {
                                            
                                            self.fees = sizeCheck
                                            
                                        }
                                    }
                                    
                                    if self.sweepMode && self.hotMode {
                                        
                                        self.sweepMode = false
                                        self.privateKey = UserDefaults.standard.object(forKey: "wif") as! String
                                        self.getPrivateKeySignature(key: self.privateKey)
                                        self.removeSpinner()
                                        
                                    } else {
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.removeSpinner()
                                            
                                            if self.coldMode {
                                                
                                                self.sweepMode = false
                                                
                                                let alert = UIAlertController(title: NSLocalizedString("Turn Airplane Mode On", comment: ""), message: "We need to scan your Private Key so that we can create a signature to sign your transaction with, you may enable airplane mode during this operation for maximum security, this is optional. We NEVER save your Private Keys, the signature is created locally and the internet is not used at all, however we will need the internet after you sign the transaction in order to send the bitcoins.", preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                    DispatchQueue.main.async {
                                                        
                                                        self.addScanner()
                                                        
                                                    }
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                            } else {
                                                
                                                let wif = UserDefaults.standard.object(forKey: "wif") as! String
                                                self.getPrivateKeySignature(key: wif)
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        } catch {
                            
                            self.removeSpinner()
                            print("JSon processing failed")
                            
                            DispatchQueue.main.async {
                                
                                self.displayAlert(title: "Error", message: "Please try again.")
                                
                            }
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func postTransaction() {
        print("postTransaction")
        
        self.addSpinner()
        let jsonData = try? JSONSerialization.data(withJSONObject: self.json)
        var url:URL!
        
        if testnetMode {
            
            url = URL(string: "https://api.blockcypher.com/v1/btc/test3/txs/send")
            
        } else {
            
            url = URL(string: "https://api.blockcypher.com/v1/btc/main/txs/send")
            
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    self.removeSpinner()
                    
                    DispatchQueue.main.async {
                        
                        self.displayAlert(title: "Error", message: "\(String(describing: error))")
                        
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            if let error = jsonAddressResult["errors"] as? NSArray {
                                
                                self.removeSpinner()
                                
                                DispatchQueue.main.async {
                                    
                                    var errors = [String]()
                                    
                                    for e in error {
                                        
                                        if let errordescription = (e as? NSDictionary)?["error"] as? String {
                                            
                                            errors.append(errordescription)
                                            
                                        }
                                        
                                    }
                                    
                                    self.displayAlert(title: "Error", message: "\(errors)")
                                    
                                }
                                
                            } else {
                                
                                if let txCheck = jsonAddressResult["tx"] as? NSDictionary {
                                    
                                    if let hashCheck = txCheck["hash"] as? String {
                                        
                                        self.transactionID = hashCheck
                                        self.removeScanner()
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.removeSpinner()
                                            
                                            let alert = UIAlertController(title: NSLocalizedString("Transaction Sent", comment: ""), message: "Transaction ID: \(hashCheck)", preferredStyle: UIAlertControllerStyle.actionSheet)
                                            
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("Copy to Clipboard", comment: ""), style: .default, handler: { (action) in
                                                
                                                UIPasteboard.general.string = hashCheck
                                                
                                                self.dismiss(animated: true, completion: nil)
                                                
                                            }))
                                            
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("See Transaction", comment: ""), style: .default, handler: { (action) in
                                                self.getTransaction()
                                            }))
                                            
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .cancel, handler: { (action) in
                                                
                                                self.dismiss(animated: true, completion: nil)
                                                
                                            }))
                                            
                                            self.present(alert, animated: true, completion: nil)
                                            
                                        }
                                    }
                                }
                            }
                            
                        } catch {
                            
                            print("JSon processing failed")
                            
                            self.removeSpinner()
                            
                            DispatchQueue.main.async {
                                
                                self.displayAlert(title: "Error", message: "Please try again.")
                                
                            }
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
    
    @objc func pushRawTransaction() {
        
        self.rawTransaction = self.rawTransactionView.text
        self.addSpinner()
        var url:URL!
        
        if testnetMode {
            
            url = URL(string: "https://api.blockcypher.com/v1/btc/test3/txs/push?token=a9d88ea606fb4a92b5134d34bc1cb2a0")
            
        } else if mainnetMode {
            
            url = URL(string: "https://api.blockcypher.com/v1/btc/main/txs/push?token=a9d88ea606fb4a92b5134d34bc1cb2a0")
            
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = "{\"tx\":\"\(self.rawTransactionView.text!)\"}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    self.removeSpinner()
                    
                    DispatchQueue.main.async {
                        
                        self.displayAlert(title: "Error", message: "\(String(describing: error))")
                        
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            self.removeSpinner()
                            
                            if let error = jsonAddressResult["errors"] as? NSArray {
                                
                                self.removeSpinner()
                                
                                DispatchQueue.main.async {
                                    
                                    var errors = [String]()
                                    
                                    for e in error {
                                        
                                        if let errordescription = (e as? NSDictionary)?["error"] as? String {
                                            
                                            errors.append(errordescription)
                                        }
                                        
                                    }
                                    
                                    self.displayAlert(title: "Error", message: "\(errors)")
                                    
                                }
                                
                            } else if let error = jsonAddressResult["error"] as? String {
                                
                                DispatchQueue.main.async {
                                    
                                    self.displayAlert(title: "Error", message: "\(error)")
                                    
                                }
                                
                            } else {
                                
                                if let txCheck = jsonAddressResult["tx"] as? NSDictionary {
                                    
                                    if let hashCheck = txCheck["hash"] as? String {
                                        
                                        self.transactionID = hashCheck
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.removeSpinner()
                                            
                                            let alert = UIAlertController(title: NSLocalizedString("Transaction Sent", comment: ""), message: "Transaction ID: \(hashCheck)", preferredStyle: UIAlertControllerStyle.actionSheet)
                                            
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("Copy to Clipboard", comment: ""), style: .default, handler: { (action) in
                                                
                                                UIPasteboard.general.string = hashCheck
                                                
                                                self.dismiss(animated: true, completion: nil)
                                                
                                            }))
                                            
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("See Transaction", comment: ""), style: .default, handler: { (action) in
                                                self.getTransaction()
                                            }))
                                            
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .cancel, handler: { (action) in
                                                
                                                self.dismiss(animated: true, completion: nil)
                                                
                                            }))
                                            
                                            self.present(alert, animated: true, completion: nil)
                                            
                                        }
                                    }
                                }
                                
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
    
    @objc func decodeRawTransaction() {
        
        print("decodeRawTransaction")
        
        self.rawTransaction = self.rawTransactionView.text
        
        if self.rawTransaction != "" {
            
            self.addSpinner()
            
            var url:URL!
            
            if testnetMode {
                
                url = URL(string: "https://api.blockcypher.com/v1/btc/test3/txs/decode?token=a9d88ea606fb4a92b5134d34bc1cb2a0")
                
            } else {
                
                url = URL(string: "https://api.blockcypher.com/v1/btc/main/txs/decode?token=a9d88ea606fb4a92b5134d34bc1cb2a0")
                
            }
            
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = "{\"tx\":\"\(self.rawTransactionView.text!)\"}".data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
                
                do {
                    
                    if error != nil {
                        
                        self.removeSpinner()
                        
                        DispatchQueue.main.async {
                            
                            self.displayAlert(title: "Error", message: "\(String(describing: error))")
                            
                        }
                        
                    } else {
                        
                        if let urlContent = data {
                            
                            do {
                                
                                let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                                
                                self.removeSpinner()
                                
                                if let error = jsonAddressResult["errors"] as? NSArray {
                                    
                                    self.removeSpinner()
                                    
                                    DispatchQueue.main.async {
                                        
                                        var errors = [String]()
                                        
                                        for e in error {
                                            
                                            if let errordescription = (e as? NSDictionary)?["error"] as? String {
                                                
                                                errors.append(errordescription)
                                                
                                            }
                                            
                                        }
                                        
                                        self.displayAlert(title: "Error", message: "\(errors)")
                                        
                                    }
                                    
                                } else if let error = jsonAddressResult["error"] as? String {
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.displayAlert(title: "Error", message: "\(error)")
                                        
                                    }
                                    
                                } else {
                                    
                                    self.displayAlert(title: "Decoded Transaction", message: "\(jsonAddressResult)")
                                    
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
            
        } else {
            
            DispatchQueue.main.async {
                
                self.displayAlert(title: "Error", message: "You need to paste or type a raw transaction into the text field.")
                
            }
            
        }
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    
    func getTransaction() {
        print("getTransaction")
        
        self.addSpinner()
        var url:URL!
        
        if testnetMode {
            
            url = URL(string: "https://api.blockcypher.com/v1/btc/test3/txs/\(self.transactionID)")
            
        } else {
            
            url = URL(string: "https://api.blockcypher.com/v1/btc/main/txs/\(self.transactionID)")
            
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    self.removeSpinner()
                    
                    DispatchQueue.main.async {
                        
                        self.displayAlert(title: "Error", message: "\(String(describing: error))")
                        
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            if let error = jsonAddressResult["errors"] as? NSArray {
                                
                                self.removeSpinner()
                                
                                DispatchQueue.main.async {
                                    
                                    var errors = [String]()
                                    
                                    for e in error {
                                        
                                        if let errordescription = (e as? NSDictionary)?["error"] as? String {
                                            
                                            errors.append(errordescription)
                                            
                                        }
                                        
                                    }
                                    
                                    self.displayAlert(title: "Error", message: "\(errors)")
                                    
                                }
                                
                            } else {
                                
                                if let txCheck = jsonAddressResult["confirmations"] as? NSInteger {
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.removeSpinner()
                                        
                                        var blockheight = Double()
                                        var hash = String()
                                        var fromAddress = NSArray()
                                        var changeAddress = NSArray()
                                        var fees = Double()
                                        
                                        for (key, value) in jsonAddressResult {
                                            
                                            if key as! String == "block_height" {
                                                
                                                blockheight = value as! Double
                                                
                                            }
                                            
                                            if key as! String == "hash" {
                                                
                                               hash = value as! String
                                                
                                            }
                                            
                                            if key as! String == "outputs" {
                                                
                                                fromAddress = value as! NSArray
                                                
                                            }
                                            
                                            if key as! String == "inputs" {
                                                
                                                changeAddress = value as! NSArray
                                                
                                            }
                                            
                                            if key as! String == "fees" {
                                                
                                                fees = value as! Double
                                                
                                            }
                                            
                                        }
                                        
                                        self.transactionView = UITextView (frame:CGRect(x: self.view.frame.minX + 5, y: self.view.frame.minY + 80, width: self.view.frame.width - 10, height: self.view.frame.height - 160))
                                        self.transactionView.text = "\n\nTransaction ID =\n\n\(hash)\n\nConfirmations = \(txCheck)\n\nFees = \(fees)\n\nBlockheight = \(blockheight)\n\nOutput Transaction Info =\n\n\(fromAddress)\n\nChange Transaction Info =\n\n\(changeAddress)"
                                        self.transactionView.textAlignment = .natural
                                        self.transactionView.isSelectable = true
                                        self.transactionView.font = .systemFont(ofSize: 18)
                                        self.view.addSubview(self.transactionView)
                                        
                                        self.refreshButton = UIButton(frame: CGRect(x: self.view.center.x - 150, y: self.view.frame.maxY - 60, width: 300, height: 55))
                                        self.refreshButton.showsTouchWhenHighlighted = true
                                        self.refreshButton.layer.cornerRadius = 10
                                        self.refreshButton.backgroundColor = UIColor.black
                                        self.refreshButton.layer.shadowColor = UIColor.black.cgColor
                                        self.refreshButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
                                        self.refreshButton.layer.shadowRadius = 2.5
                                        self.refreshButton.layer.shadowOpacity = 0.8
                                        self.refreshButton.setTitle("Refresh", for: .normal)
                                        self.refreshButton.addTarget(self, action: #selector(self.tapRefresh), for: .touchUpInside)
                                        self.view.addSubview(self.refreshButton)
                                    }
                                }
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
    
    @objc func tapRefresh() {
        
        self.transactionView.removeFromSuperview()
        self.refreshButton.removeFromSuperview()
        self.getTransaction()
    
    }
    
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
    }

}

extension UITextField {
    
    func addDoneButtonToKeyboard(myAction:Selector){
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: TransactionBuilderViewController(), action: myAction)
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.inputAccessoryView = doneToolbar
        
    }
}

extension Float {
    
    var avoidNotation: String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 8
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(for: self) ?? ""
        
    }
}

extension Int {
    
    var avoidNotation: String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 8
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(for: self) ?? ""
        
    }
}

extension Double {
    
    var avoidNotation: String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 8
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(for: self) ?? ""
        
    }
}
