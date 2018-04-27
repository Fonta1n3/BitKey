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

class TransactionBuilderViewController: UIViewController, /*BTCTransactionBuilderDataSource,*/ AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate {
    
    let avCaptureSession = AVCaptureSession()
    var bitcoinAddressQRCode = UIImage()
    var unspentOutputs = NSMutableArray()
    //let btcAddress = "mo7WCetPLw6yMkT7MdzYfQ1L4eWqAuT2j7"
    var json = NSMutableDictionary()
    var transactionToBeSigned = String()
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
    var currecny = String()
    var amountInBTC = Float()
    var satoshiAmount = Int()
    var connected:Bool!
    var preference = "high"
    var transactionID = "8e8e91062670c518ae02b633ce303dc6a15b7b2025fdb4d338f4262db7d37d71"
    var rawTransaction = String()
    var fees:Int!
    var manuallySetFee = Bool()
    var totalSize = Int()
    var setFeeMode = Bool()
    var transactionView = UITextView()
    var refreshButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("TransactionBuilderViewController")
        getReceivingAddressMode = true
        getPayerAddressMode = false
        getSignatureMode = false
        addressToDisplay.delegate = self
        amountToSend.delegate = self
        addBackButton()
        addAmount()
        getAmount()
        manuallySetFee = false
        setFeeMode = true
    }
    
    func isInternetAvailable() -> Bool {
        
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
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: NSLocalizedString("Please set your miner fee preference", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("High for 1-2 blocks", comment: ""), style: .default, handler: { (action) in
                
                self.preference = "high"
                self.amountToSend.becomeFirstResponder()
                self.setFeeMode = false
                
                if self.currecny != "BTC" && self.currecny != "SAT" {
                    
                    self.getSatoshiAmount()
                    
                } else {
                    
                    self.getSatsAndBTCs()
                }
                
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Medium for 3-6 blocks", comment: ""), style: .default, handler: { (action) in
                
                self.preference = "medium"
                self.amountToSend.becomeFirstResponder()
                self.setFeeMode = false
                
                if self.currecny != "BTC" && self.currecny != "SAT" {
                    
                    self.getSatoshiAmount()
                    
                } else {
                    
                    self.getSatsAndBTCs()
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Low for 7 blocks +", comment: ""), style: .default, handler: { (action) in
                
                self.preference = "low"
                self.amountToSend.becomeFirstResponder()
                self.setFeeMode = false
                
                if self.currecny != "BTC" && self.currecny != "SAT" {
                    
                    self.getSatoshiAmount()
                    
                } else {
                    
                    self.getSatsAndBTCs()
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Manually Set", comment: ""), style: .default, handler: { (action) in
                
                self.manuallySetFee = true
                self.addFeeAmount()
                self.amountToSend.becomeFirstResponder()
                self.setFeeMode = false
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
                self.amountToSend.becomeFirstResponder()
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    func getAmount() {
        print("getAmount")
        
        DispatchQueue.main.async {
                
                let alert = UIAlertController(title: NSLocalizedString("Please choose your currency", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Satoshis", comment: ""), style: .default, handler: { (action) in
                    
                    self.amountToSend.placeholder = "Amount to send in Satoshis"
                    self.currecny = "SAT"
                    self.amountToSend.becomeFirstResponder()
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("BTC", comment: ""), style: .default, handler: { (action) in
                    
                    self.amountToSend.placeholder = "Amount to send in BTC"
                    self.currecny = "BTC"
                    self.amountToSend.becomeFirstResponder()
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("USD", comment: ""), style: .default, handler: { (action) in
                    
                    self.amountToSend.placeholder = "Amount to send in USD"
                    self.currecny = "USD"
                    self.amountToSend.becomeFirstResponder()
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("EUR", comment: ""), style: .default, handler: { (action) in
                    
                    self.amountToSend.placeholder = "Amount to send in EUR"
                    self.currecny = "EUR"
                    self.amountToSend.becomeFirstResponder()
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("GBP", comment: ""), style: .default, handler: { (action) in
                    
                    self.amountToSend.placeholder = "Amount to send in GBP"
                    self.currecny = "GBP"
                    self.amountToSend.becomeFirstResponder()
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                }))
            
            
                self.present(alert, animated: true, completion: nil)
            
            }

    }
    
    func addBackButton() {
        
        DispatchQueue.main.async {
            self.backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100 , height: 55))
            self.backButton.showsTouchWhenHighlighted = true
            self.backButton.backgroundColor = .black
            self.backButton.setTitle("Back", for: .normal)
            self.backButton.addTarget(self, action: #selector(self.home), for: .touchUpInside)
            self.view.addSubview(self.backButton)
        }
    }
    
    @objc func home() {
        
        self.dismiss(animated: false, completion: nil)
                    
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
        
        self.fees = Int(self.amountToSend.text!)!
        self.amountToSend.resignFirstResponder()
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
        
        self.amount = self.amountToSend.text!
        print("self.amount = \(self.amount)")
        self.amountToSend.text = ""
        self.amountToSend.resignFirstResponder()
        self.amountToSend.removeFromSuperview()
        self.setPreference()
        
    }
    
    func addTextInput() {
        print("addTextInput")
        
        self.addressToDisplay.frame = CGRect(x: self.view.frame.minX + 5, y: self.videoPreview.frame.minY - 55, width: self.view.frame.width - 10, height: 50)
        self.addressToDisplay.textAlignment = .center
        self.addressToDisplay.borderStyle = .roundedRect
        self.addressToDisplay.backgroundColor = UIColor.groupTableViewBackground
        self.addressToDisplay.returnKeyType = UIReturnKeyType.go
        
        if getReceivingAddressMode {
          
            self.addressToDisplay.placeholder = "Receiving Address"
            
        } else if getPayerAddressMode {
            
            self.addressToDisplay.placeholder = "Debit Address"
            
        } else if getSignatureMode {
            
            self.addressToDisplay.placeholder = "Private Key to sign"
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: NSLocalizedString("Turn Airplane Mode On", comment: ""), message: "We need to scan your Private Key so that we can create a signature to sign your transaction with, you may enable airplane mode during this operation for maximum security. We NEVER save your Private Keys, the signature is created locally and the internet is not needed at all, we do need the internet however to broadcast your transaction to the Bitcoin network and actually send the Bitcoin.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
        self.view.addSubview(self.addressToDisplay)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        
        if textField == self.addressToDisplay {
            
            if getReceivingAddressMode {
                
                self.recievingAddress = self.addressToDisplay.text!
                print("self.recievingAddress = \(self.recievingAddress)")
                self.getReceivingAddressMode = false
                self.getPayerAddressMode = true
                self.removeScanner()
                self.addScanner()
                
            } else if getPayerAddressMode {
                
                self.sendingFromAddress = self.addressToDisplay.text!
                print("self.sendingFromAddress = \(self.sendingFromAddress)")
                self.getPayerAddressMode = false
                self.getSignatureMode = true
                self.removeScanner()
                self.addScanner()
                
            } else if getSignatureMode {
                
                self.getPrivateKeySignature(key: self.addressToDisplay.text!)
                print("privateKey = \(self.addressToDisplay.text!)")
                self.removeScanner()
            }
            
        } else if textField == self.amountToSend && self.setFeeMode == false {
            
            if self.currecny != "BTC" && self.currecny != "SAT" {
              
              self.getSatoshiAmount()
                
            } else {
               
                self.getSatsAndBTCs()
                
            }
            
            getSatsAndBTCs()
        }
    }
    
    func getSatsAndBTCs() {
        
        if self.currecny == "BTC" {
            
            self.amountInBTC = Float(self.amount)!
            self.satoshiAmount = Int(self.amountInBTC * 100000000)
            
        } else if self.currecny == "SAT" {
            
            self.satoshiAmount = Int(self.amount)!
            print("self.satoshiAmount = \(self.satoshiAmount)")
            self.amountInBTC = Float(Float(self.amount)! / 100000000)
            
            
        }
        
        let noNotationBTC = self.amountInBTC.avoidNotation
        let noNotationSatoshi = Int(Float(self.satoshiAmount).avoidNotation)?.withCommas()
        
        DispatchQueue.main.async {
            
            var message = String()
            
            if self.fees != nil {
                
                message = "You would like to send \(noNotationBTC) Bitcoin, equal to \(noNotationSatoshi!) Satoshis with a miner fee of \(self.fees!) Satoshis."
                
            } else {
                
                message = "You would like to send \(noNotationBTC) Bitcoin, equal to \(noNotationSatoshi!) Satoshis with a \(self.preference) miner fee preference."
            }
            
            let alert = UIAlertController(title: NSLocalizedString("Please Confirm", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                
                self.amountToSend.removeFromSuperview()
                self.addQRScannerView()
                self.addTextInput()
                self.scanQRCode()
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: { (action) in
                
                self.dismiss(animated: false, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func getSatoshiAmount() {
        print("getSatoshiAmount")
        
        var url:NSURL!
        url = NSURL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonQuoteResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            if let exchangeCheck = jsonQuoteResult["bpi"] as? NSDictionary {
                                
                                print("exchangeCheck = \(exchangeCheck)")
                                
                                if let exchangeRateCheck = exchangeCheck[self.currecny] as? NSDictionary {
                                    
                                    if let rateCheck = exchangeRateCheck["rate_float"] as? Float {
                                        
                                        print("rateCheck = \(rateCheck) \(self.currecny)")
                                            
                                        self.amountInBTC = Float(self.amount)! / rateCheck
                                        self.satoshiAmount = Int(self.amountInBTC * 100000000)
                                        
                                        DispatchQueue.main.async {
                                                
                                            let alert = UIAlertController(title: NSLocalizedString("Please Confirm", comment: ""), message: "You would like to send \(self.amount) \(self.currecny) which is equal to \(self.amountInBTC) Bitcoin and equal to \(self.satoshiAmount.withCommas()) Satoshis", preferredStyle: UIAlertControllerStyle.actionSheet)
                                                
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                                                    
                                                self.amountToSend.removeFromSuperview()
                                                //self.addQRScannerView()
                                                //self.addTextInput()
                                                //self.scanQRCode()
                                                self.addScanner()
                                                
                                            }))
                                                
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: { (action) in
                                                    
                                            }))
                                                
                                            self.present(alert, animated: true, completion: nil)
                                                
                                        }
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
        
        self.view.endEditing(true)
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
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
                
                if getReceivingAddressMode {
                    
                    self.recievingAddress = stringURL
                    print("self.recievingAddress = \(self.recievingAddress)")
                    self.getReceivingAddressMode = false
                    self.getPayerAddressMode = true
                    self.removeScanner()
                    
                    DispatchQueue.main.async {
                        
                        let alert = UIAlertController(title: NSLocalizedString("Scan Succesful", comment: ""), message: "Sending payment to \(self.recievingAddress)", preferredStyle: UIAlertControllerStyle.actionSheet)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Scan Debit Address", comment: ""), style: .default, handler: { (action) in
                            
                            self.addScanner()
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                            
                            self.dismiss(animated: false, completion: nil)
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    
                } else if getPayerAddressMode {
                    
                    self.sendingFromAddress = stringURL
                    print("self.sendingFromAddress = \(self.sendingFromAddress)")
                    self.getPayerAddressMode = false
                    self.getSignatureMode = true
                    self.removeScanner()
                    self.makeHTTPPostRequest()
                    
                    
                } else if getSignatureMode {
                    
                    self.getPrivateKeySignature(key: self.stringURL)
                    print("privateKey = \(self.stringURL)")
                        
                }
            }
        }
    }
    
    func getPrivateKeySignature(key: String) {
        print("getPrivateKeySignature")
        
        let privateKey = BTCPrivateKeyAddress(string: key)
        print("privateKey = \(String(describing: privateKey))")
        let key = BTCKey.init(privateKeyAddress: privateKey)
        let publicKey = key?.publicKey
        let publicKeyString = BTCHexFromData(publicKey as Data!)
        print("prvKey = \(String(describing: key?.privateKey.hex()))")
        self.privateKeyToSign = (key?.privateKey.hex())!
        SignerGetSignature(self.privateKeyToSign, self.transactionToBeSigned)
        let signature = Signer.signature()
        self.json["signatures"] = ["\(String(describing: signature!))"]
        self.json["pubkeys"] = ["\(String(describing: publicKeyString!))"]
        print("json = \(self.json)")
        
        DispatchQueue.main.async {
            
            self.removeScanner()
            
            let alert = UIAlertController(title: NSLocalizedString("Please confirm your transaction before sending.", comment: ""), message: "From: \(self.sendingFromAddress)\nTo: \(self.recievingAddress)\nAmount: \(self.amount) \(self.currecny) with a miner fee of \(self.fees!) Satoshis", preferredStyle: UIAlertControllerStyle.actionSheet)
            
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
                            self.dismiss(animated: false, completion: nil)
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    self.dismiss(animated: false, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
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
    
    /*
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
    */
    
    func makeHTTPPostRequest() {
        print("makeHTTPPostRequest")
        
        //insert spinner
        
        var url:URL!
        url = URL(string: "https://api.blockcypher.com/v1/btc/test3/txs/new")
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        print("preference = \(self.preference)")
        
        if self.manuallySetFee {
            
          request.httpBody = "{\"inputs\": [{\"addresses\": [\"\(self.sendingFromAddress)\"]}], \"outputs\": [{\"addresses\": [\"\(self.recievingAddress)\"], \"value\": \(self.satoshiAmount)}],\"fees\": \(self.fees!)}".data(using: .utf8)
            
        } else {
            
            request.httpBody = "{\"inputs\": [{\"addresses\": [\"\(self.sendingFromAddress)\"]}], \"outputs\": [{\"addresses\": [\"\(self.recievingAddress)\"], \"value\": \(self.satoshiAmount)}],\"preference\": \"\(self.preference)\"}".data(using: .utf8)
            
        }
        
        print("request.httpBody = \("{\"inputs\": [{\"addresses\": [\"\(self.sendingFromAddress)\"]}], \"outputs\": [{\"addresses\": [\"\(self.recievingAddress)\"], \"value\": \(self.satoshiAmount)}],\"preference\": \"\(self.preference)\"}")")
        
        
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
                                self.json = jsonAddressResult.mutableCopy() as! NSMutableDictionary
                                self.removeScanner()
                                
                                if self.setFeeMode == false {
                                    
                                    if let sizeCheck = (jsonAddressResult["tx"] as? NSDictionary)?["fees"] as? NSInteger {
                                        
                                        print("sizeCheck = \(sizeCheck)")
                                        //self.totalSize = sizeCheck + 100
                                        self.fees = sizeCheck
                                        
                                    }
                                }
                                
                                DispatchQueue.main.async {
                                    
                                    let alert = UIAlertController(title: NSLocalizedString("Scan Successful.", comment: ""), message: "You are sending Bitcoin from address \(self.sendingFromAddress)", preferredStyle: UIAlertControllerStyle.actionSheet)
                                    
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Scan Private Key", comment: ""), style: .default, handler: { (action) in
                                        
                                        self.addScanner()
                                        
                                    }))
                                    
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                                        
                                        self.dismiss(animated: false, completion: nil)
                                        
                                    }))
                                    
                                    self.present(alert, animated: true, completion: nil)
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
        
        //insert spinner
        let jsonData = try? JSONSerialization.data(withJSONObject: self.json)
        var url:URL!
        url = URL(string: "https://api.blockcypher.com/v1/btc/test3/txs/send")
        
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
                                    self.transactionID = hashCheck
                                    self.removeScanner()
                                    
                                    DispatchQueue.main.async {
                                        
                                        let alert = UIAlertController(title: NSLocalizedString("Transaction Sent", comment: ""), message: "Transaction ID: \(hashCheck)", preferredStyle: UIAlertControllerStyle.actionSheet)
                                        
                                        alert.addAction(UIAlertAction(title: NSLocalizedString("Copy to Clipboard", comment: ""), style: .default, handler: { (action) in
                                            UIPasteboard.general.string = hashCheck
                                            self.dismiss(animated: false, completion: nil)
                                        }))
                                        
                                        alert.addAction(UIAlertAction(title: NSLocalizedString("See Transaction", comment: ""), style: .default, handler: { (action) in
                                            self.getTransaction()
                                        }))
                                        
                                        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .cancel, handler: { (action) in
                                            self.dismiss(animated: false, completion: nil)
                                        }))
                                        
                                        self.present(alert, animated: true, completion: nil)
                                        
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
    
    func pushRawTransaction() {
        /*
        curl -d '{"tx":"01000000011935b41d12936df99d322ac8972b74ecff7b79408bbccaf1b2eb8015228beac8000000006b483045022100921fc36b911094280f07d8504a80fbab9b823a25f102e2bc69b14bcd369dfc7902200d07067d47f040e724b556e5bc3061af132d5a47bd96e901429d53c41e0f8cca012102152e2bb5b273561ece7bbe8b1df51a4c44f5ab0bc940c105045e2cc77e618044ffffffff0240420f00000000001976a9145fb1af31edd2aa5a2bbaa24f6043d6ec31f7e63288ac20da3c00000000001976a914efec6de6c253e657a9d5506a78ee48d89762fb3188ac00000000"}' https://api.blockcypher.com/v1/bcy/test/txs/push?token=YOURTOKEN
        */
        
        print("pushRawTransaction")
        
        //insert spinner
        
        var url:URL!
        url = URL(string: "https://api.blockcypher.com/v1/btc/test3/txs/send")
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = "{\"tx\":\"\(self.rawTransaction)\"}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            print("jsonAddressResult = \(jsonAddressResult)")
                            /*
                            //check if tosign was consumed.. get TX hash
                            if let txCheck = jsonAddressResult["tx"] as? NSDictionary {
                                
                                print("txCheck = \(txCheck)")
                                
                                if let hashCheck = txCheck["hash"] as? String {
                                    
                                    print("hashCheck = \(hashCheck)")
                                    self.removeScanner()
                                    
                                    DispatchQueue.main.async {
                                        
                                        let alert = UIAlertController(title: NSLocalizedString("Transaction Sent", comment: ""), message: "Transaction ID: \(hashCheck)", preferredStyle: UIAlertControllerStyle.actionSheet)
                                        
                                        alert.addAction(UIAlertAction(title: NSLocalizedString("Copy to Clipboard", comment: ""), style: .default, handler: { (action) in
                                            UIPasteboard.general.string = hashCheck
                                            self.dismiss(animated: false, completion: nil)
                                        }))
                                        
                                        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .cancel, handler: { (action) in
                                            self.dismiss(animated: false, completion: nil)
                                        }))
                                        
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    }
                                }
                            }
                            */
                        } catch {
                            
                            print("JSon processing failed")
                            
                        }
                    }
                    
                }
            }
        }
        task.resume()
    }
    
    func getTransaction() {
        print("getTransaction")
        
        var url:URL!
        url = URL(string: "https://api.blockcypher.com/v1/btc/test3/txs/\(self.transactionID)")
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            print("jsonAddressResult = \(jsonAddressResult)")
                            
                            //check if tosign was consumed.. get TX hash
                            if let txCheck = jsonAddressResult["confirmations"] as? NSInteger {
                                
                                print("txCheck = \(txCheck)")
                                
                                DispatchQueue.main.async {
                                    
                                    self.transactionView = UITextView (frame:CGRect(x: self.view.frame.minX + 5, y: self.view.frame.minY + 60, width: self.view.frame.width - 10, height: self.view.frame.height - 60))
                                    self.transactionView.text = "\(jsonAddressResult)"
                                    self.transactionView.textAlignment = .natural
                                    self.transactionView.isSelectable = true
                                    self.transactionView.font = .systemFont(ofSize: 18)
                                    self.view.addSubview(self.transactionView)

                                    
                                    self.refreshButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.maxY - 55, width: self.view.frame.width, height: 55))
                                    self.refreshButton.showsTouchWhenHighlighted = true
                                    self.refreshButton.backgroundColor = .black
                                    self.refreshButton.setTitle("Refresh", for: .normal)
                                    self.refreshButton.addTarget(self, action: #selector(self.tapRefresh), for: .touchUpInside)
                                    self.view.addSubview(self.refreshButton)
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

extension UITextField{
    
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
