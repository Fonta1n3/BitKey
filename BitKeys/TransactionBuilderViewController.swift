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

class TransactionBuilderViewController: UIViewController, /*BTCTransactionBuilderDataSource,*/ AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate {
    
    let avCaptureSession = AVCaptureSession()
    var bitcoinAddressQRCode = UIImage()
    var unspentOutputs = NSMutableArray()
    let btcAddress = "mo7WCetPLw6yMkT7MdzYfQ1L4eWqAuT2j7"
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
    var amount = "1"
    var backButton = UIButton()
    var currecny = String()
    var amountInBTC = Float()
    var satoshiAmount = Int()
    
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
    }
    
    func getAmount() {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: NSLocalizedString("Please choose your currency", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("BTC", comment: ""), style: .default, handler: { (action) in
                
                self.amountToSend.placeholder = "Amount to send in BTC"
                self.currecny = "BTC"
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("USD", comment: ""), style: .default, handler: { (action) in
                
                self.amountToSend.placeholder = "Amount to send in USD"
                self.currecny = "USD"
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("EUR", comment: ""), style: .default, handler: { (action) in
                
                self.amountToSend.placeholder = "Amount to send in EUR"
                self.currecny = "EUR"
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("GBP", comment: ""), style: .default, handler: { (action) in
                
                self.amountToSend.placeholder = "Amount to send in GBP"
                self.currecny = "GBP"
                
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
        
        self.videoPreview.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.view.center.y - ((self.view.frame.width - 50)/2), width: self.view.frame.width - 50, height: self.view.frame.width - 50)
        self.view.addSubview(self.videoPreview)
    }
    
    func addAmount() {
        
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
        
        self.amount = self.amountToSend.text!
        print("self.amount = \(self.amount)")
        self.amountToSend.resignFirstResponder()
        
    }
    
    func addTextInput() {
        
        self.addressToDisplay.frame = CGRect(x: self.view.frame.minX + 5, y: self.videoPreview.frame.minY - 55, width: self.view.frame.width - 10, height: 50)
        self.addressToDisplay.textAlignment = .center
        self.addressToDisplay.borderStyle = .roundedRect
        self.addressToDisplay.backgroundColor = UIColor.groupTableViewBackground
        self.addressToDisplay.returnKeyType = UIReturnKeyType.go
        
        if getReceivingAddressMode {
          
            self.addressToDisplay.placeholder = "Receiving Address"
            
        } else if getPayerAddressMode {
            
            self.addressToDisplay.placeholder = "Sending Address"
            
        } else if getSignatureMode {
            
            self.addressToDisplay.placeholder = "Private Key to sign"
            
        }
        
        self.view.addSubview(self.addressToDisplay)
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.amountToSend {
          
            getAmount()
            
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
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
            
        } else if textField == self.amountToSend {
            
            self.getSatoshiAmount()
            
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
                                                
                                            let alert = UIAlertController(title: NSLocalizedString("Please Confirm", comment: ""), message: "You would like to send \(self.amount) \(self.currecny) which is equal to \(self.amountInBTC) Bitcoin and equal to \(self.satoshiAmount) Satoshis", preferredStyle: UIAlertControllerStyle.alert)
                                                
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                                                    
                                                self.amountToSend.removeFromSuperview()
                                                self.addQRScannerView()
                                                self.addTextInput()
                                                self.scanQRCode()
                                                
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
        
        DispatchQueue.main.async {
            self.addQRScannerView()
            self.addTextInput()
            self.scanQRCode()
        }
    }
    
    func removeScanner() {
        
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
                    self.addScanner()
                    
                } else if getPayerAddressMode {
                    
                    self.sendingFromAddress = stringURL
                    print("self.sendingFromAddress = \(self.sendingFromAddress)")
                    self.getPayerAddressMode = false
                    self.getSignatureMode = true
                    self.removeScanner()
                    self.makeHTTPPostRequest()
                    self.addScanner()
                    
                } else if getSignatureMode {
                    
                    self.getPrivateKeySignature(key: self.stringURL)
                    print("privateKey = \(self.stringURL)")
                    
                    
                }
                
                
                
            }
        }
    }
    
    func getPrivateKeySignature(key: String) {
        print("getPrivateKeySignature")
        
        print("key = \(key)")
        
        let privateKey = BTCPrivateKeyAddress(string: key)
        print("privateKey = \(privateKey)")
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
            
            let alert = UIAlertController(title: NSLocalizedString("Please confirm your transaction before sending.", comment: ""), message: "From: \(self.sendingFromAddress)\nTo: \(self.recievingAddress)\nAmount: \(self.amount) \(self.currecny)", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Send", comment: ""), style: .default, handler: { (action) in
                self.postTransaction()
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
        var url:URL!
        url = URL(string: "http://api.blockcypher.com/v1/btc/test3/txs/new")
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = "{\"inputs\": [{\"addresses\": [\"\(self.sendingFromAddress)\"]}], \"outputs\": [{\"addresses\": [\"\(self.recievingAddress)\"], \"value\": \(self.satoshiAmount)}]}".data(using: .utf8)
        
        print("request.httpBody = \("{\"inputs\": [{\"addresses\": [\"\(self.sendingFromAddress)\"]}], \"outputs\": [{\"addresses\": [\"\(self.recievingAddress)\"], \"value\": \(self.satoshiAmount)}]}")")
        
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
                                self.addScanner()
                                
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
        
        let jsonData = try? JSONSerialization.data(withJSONObject: self.json)
        
        var url:URL!
        url = URL(string: "http://api.blockcypher.com/v1/btc/test3/txs/send")
        
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
                                    self.removeScanner()
                                    
                                    DispatchQueue.main.async {
                                        
                                        let alert = UIAlertController(title: NSLocalizedString("Transaction Sent", comment: ""), message: "Transaction ID: \(hashCheck)", preferredStyle: UIAlertControllerStyle.actionSheet)
                                        
                                        alert.addAction(UIAlertAction(title: NSLocalizedString("Copy to Clipboard", comment: ""), style: .default, handler: { (action) in
                                            UIPasteboard.general.string = hashCheck
                                        }))
                                        
                                        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
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
        //let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: (myAction))
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: TransactionBuilderViewController(), action: myAction)
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
}
