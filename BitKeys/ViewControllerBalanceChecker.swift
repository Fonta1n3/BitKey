//
//  ViewControllerBalanceChecker.swift
//  BitKeys
//
//  Created by Peter on 1/20/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import AVFoundation

class ViewControllerBalanceChecker: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate {
    
    let segwit = SegwitAddrCoder()
    var legacyMode = Bool()
    var segwitMode = Bool()
    var testnetMode = Bool()
    var mainnetMode = Bool()
    var coldMode = Bool()
    var hotMode = Bool()
    var imageView:UIView!
    let avCaptureSession = AVCaptureSession()
    var balance = Double()
    var backUpButton = UIButton(type: .custom)
    var addressBookButton = UIButton()
    var bitcoinAddressQRCode = UIImage()
    var stringURL = String()
    var myAddressButton = UIButton()
    var addressLabel = UILabel()
    var addressBook: [[String: Any]] = []
    
    var addresses = String()

    
    @IBAction func addressText(_ sender: Any) {
        
        
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        getUserDefaults()
        addHomeButton()
        addAddressBookButton()
        scanQRCode()
        
        self.addressLabel.frame = CGRect(x: self.view.center.x - (self.view.frame.width / 2 - 20), y: 100, width: self.view.frame.width - 40, height: 60)
        
    }
    
    func getUserDefaults() {
        
        print("checkUserDefaults")
        
        addressBook = checkUserDefaults().addressBook
        
        coldMode = UserDefaults.standard.object(forKey: "coldMode") as! Bool
        hotMode = UserDefaults.standard.object(forKey: "hotMode") as! Bool
        testnetMode = UserDefaults.standard.object(forKey: "testnetMode") as! Bool
        mainnetMode = UserDefaults.standard.object(forKey: "mainnetMode") as! Bool
        legacyMode = UserDefaults.standard.object(forKey: "legacyMode") as! Bool
        segwitMode = UserDefaults.standard.object(forKey: "segwitMode") as! Bool
        
    }
    
    
    func addSpinner() {
        
        DispatchQueue.main.async {
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
    
    
    @IBOutlet var addressToDisplay: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addressToDisplay.delegate = self
        print("ViewControllerBalanceChecker")
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }

    @IBOutlet var videoPreview: UIView!
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        
        if textField == self.addressToDisplay {
            
            DispatchQueue.main.async {
                
                self.checkBalance(address: self.addressToDisplay.text!)
                self.addressToDisplay.text = ""
                self.avCaptureSession.stopRunning()
                
            }
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        self.addresses = self.addressToDisplay.text!
        self.addressLabel.text = self.addressToDisplay.text!
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
                print("stringURL = \(stringURL)")
                
                DispatchQueue.main.async {
                    self.addressToDisplay.text = self.stringURL
                }
                
                self.addresses = stringURL
                
                self.addressLabel.text = self.addresses
                
                self.avCaptureSession.stopRunning()
                self.checkBalance(address: stringURL)
                
            }
        }
    }
    
    func scanQRNow() throws {
        
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
        
        self.avCaptureSession.startRunning()
        
    }
    
    func checkBalance(address: String) {
        print("checkBalance")
        
        self.addSpinner()
        
        var url:NSURL!
        
        if address.hasPrefix("1") || address.hasPrefix("3") {
            
            url = NSURL(string: "https://blockchain.info/balance?active=\(address)")
            
        } else if testnetMode {
            
            url = NSURL(string: "https://testnet.blockchain.info/balance?active=\(address)")
            
        } else if mainnetMode {
            
            url = NSURL(string: "https://blockchain.info/balance?active=\(address)")
            
        }
        
        print("url = \(url)")
        
        /*if address.count == 64 {
            
            url = NSURL(string: "https://testnet.blockchain.info/rawtx/\(address)")
            
        } */
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    self.removeSpinner()
                    DispatchQueue.main.async {
                        self.avCaptureSession.startRunning()
                        displayAlert(viewController: self, title: "Error", message: "\(String(describing: error))")
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            print("jsonAddressResult = \(jsonAddressResult)")
                            
                            if let addressCheck = jsonAddressResult["\(address)"] as? NSDictionary {
                                
                                if let finalBalanceCheck = addressCheck["final_balance"] as? Double {
                                    
                                    
                                let btcAmount = finalBalanceCheck / 100000000
                                self.balance = btcAmount
                                
                                    DispatchQueue.main.async {
                                        self.videoPreview.removeFromSuperview()
                                        self.addressToDisplay.removeFromSuperview()
                                        
                                        let btcBalanceLabel = UILabel()
                                        btcBalanceLabel.frame = CGRect(x: self.view.center.x - (self.view.frame.width / 2), y: self.view.center.y - ((self.view.frame.height / 2) + 120), width: self.view.frame.width, height: self.view.frame.height)
                                        btcBalanceLabel.text = "\(btcAmount.avoidNotation) BTC"
                                        btcBalanceLabel.textColor = UIColor.black
                                        btcBalanceLabel.font = UIFont.systemFont(ofSize: 32)
                                        btcBalanceLabel.textAlignment = .center
                                        self.view.addSubview(btcBalanceLabel)
                                        
                                        
                                        self.addressLabel.adjustsFontSizeToFitWidth = true
                                        self.addressLabel.textColor = UIColor.black
                                        self.addressLabel.font = UIFont.systemFont(ofSize: 23)
                                        self.addressLabel.textAlignment = .center
                                        self.view.addSubview(self.addressLabel)
                                        
                                        self.addressBookButton.removeFromSuperview()
                                        self.myAddressButton.removeFromSuperview()
                                        self.addBackUpButton()
                                        self.generateQrCode(key: address)
                                        self.getExchangeRates()
                                        
                                    }
                                    
                                } else {
                                    
                                    DispatchQueue.main.async {
                                        self.removeSpinner()
                                        self.avCaptureSession.startRunning()
                                        displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                    }
                                    
                                }
                                
                            } else {
                                
                                DispatchQueue.main.async {
                                    self.removeSpinner()
                                    self.avCaptureSession.startRunning()
                                    displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                }
                                
                            }
                            
                        } catch {
                            
                            print("JSon processing failed")
                            DispatchQueue.main.async {
                                self.removeSpinner()
                                self.avCaptureSession.startRunning()
                                displayAlert(viewController: self, title: "Error", message: "Please try again.")
                            }
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func getExchangeRates() {
        
        var url:NSURL!
        url = NSURL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    self.removeSpinner()
                    DispatchQueue.main.async {
                        self.avCaptureSession.startRunning()
                        displayAlert(viewController: self, title: "Error", message: "\(String(describing: error))")
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonQuoteResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            if let exchangeCheck = jsonQuoteResult["bpi"] as? NSDictionary {
                                
                                print("exchangeCheck = \(exchangeCheck)")
                                
                                self.removeSpinner()
                                if let usdCheck = exchangeCheck["USD"] as? NSDictionary {
                                    
                                    if let rateCheck = usdCheck["rate_float"] as? Float {
                                        
                                        DispatchQueue.main.async {
                                            
                                            let exchangeRate = Double(rateCheck)
                                            let usdAmount = (self.balance * exchangeRate)
                                            let roundedUsdAmount = round(100 * usdAmount) / 100
                                            let roundedInt = Int(roundedUsdAmount)
                                            let usdBalanceLabel = UILabel()
                                            usdBalanceLabel.frame = CGRect(x: self.view.center.x - (self.view.frame.width / 2), y: self.view.center.y - ((self.view.frame.height / 2) + 60), width: self.view.frame.width, height: self.view.frame.height)
                                            usdBalanceLabel.text = "\(roundedInt.withCommas()) USD"
                                            usdBalanceLabel.textColor = UIColor.black
                                            usdBalanceLabel.font = UIFont.systemFont(ofSize: 32)
                                            usdBalanceLabel.textAlignment = .center
                                            self.view.addSubview(usdBalanceLabel)
                                            
                                        }
                                    }
                                }
                                
                                if let gbpCheck = exchangeCheck["GBP"] as? NSDictionary {
                                    
                                    if let rateCheck = gbpCheck["rate_float"] as? Float {
                                        
                                        DispatchQueue.main.async {
                                            let exchangeRate = Double(rateCheck)
                                            let gbpAmount = (self.balance * exchangeRate)
                                            let roundedGbpAmount = round(100 * gbpAmount) / 100
                                            let roundedInt = Int(roundedGbpAmount)
                                            let gbpBalanceLabel = UILabel()
                                            gbpBalanceLabel.frame = CGRect(x: self.view.center.x - (self.view.frame.width / 2), y: self.view.center.y - ((self.view.frame.height / 2)), width: self.view.frame.width, height: self.view.frame.height)
                                            gbpBalanceLabel.text = "\(roundedInt.withCommas()) GBP"
                                            gbpBalanceLabel.textColor = UIColor.black
                                            gbpBalanceLabel.font = UIFont.systemFont(ofSize: 32)
                                            gbpBalanceLabel.textAlignment = .center
                                            self.view.addSubview(gbpBalanceLabel)
                                            
                                        }
                                    }
                                }
                                
                                if let euroCheck = exchangeCheck["EUR"] as? NSDictionary {
                                    
                                    if let rateCheck = euroCheck["rate_float"] as? Float {
                                        
                                        DispatchQueue.main.async {
                                            let exchangeRate = Double(rateCheck)
                                            let euroAmount = (self.balance * exchangeRate)
                                            let roundedEuroAmount = round(100 * euroAmount) / 100
                                            let roundedInt = Int(roundedEuroAmount)
                                            let euroBalanceLabel = UILabel()
                                            euroBalanceLabel.frame = CGRect(x: self.view.center.x - (self.view.frame.width / 2), y: self.view.center.y - ((self.view.frame.height / 2) - 60), width: self.view.frame.width, height: self.view.frame.height)
                                            euroBalanceLabel.text = "\(roundedInt.withCommas()) EUR"
                                            euroBalanceLabel.textColor = UIColor.black
                                            euroBalanceLabel.font = UIFont.systemFont(ofSize: 32)
                                            euroBalanceLabel.textAlignment = .center
                                            self.view.addSubview(euroBalanceLabel)
                                            
                                        }
                                    }
                                }
                             }
 
                        } catch {
                            
                            print("JSon processing failed")
                            DispatchQueue.main.async {
                                self.removeSpinner()
                                self.avCaptureSession.startRunning()
                                displayAlert(viewController: self, title: "Error", message: "Please try again.")
                            }
                        }
                    }
                }
            }
        }
        
        task.resume()
        
    }
    
    func addHomeButton() {
        
        DispatchQueue.main.async {
            
            let button = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
            button.showsTouchWhenHighlighted = true
            button.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
            button.addTarget(self, action: #selector(self.home), for: .touchUpInside)
            self.view.addSubview(button)
            
        }
        
    }
    
    @objc func home() {
        
        DispatchQueue.main.async {
            
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func addBackUpButton() {
        
        DispatchQueue.main.async {
            
            self.backUpButton.removeFromSuperview()
            self.backUpButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 60, y: self.view.frame.maxY - 60, width: 55, height: 55))
            self.backUpButton.setImage(#imageLiteral(resourceName: "backUp.jpg"), for: .normal)
            self.backUpButton.addTarget(self, action: #selector(self.airDropImage), for: .touchUpInside)
            self.view.addSubview(self.backUpButton)
            
        }
        
    }
    
    func addAddressBookButton() {
        
        DispatchQueue.main.async {
            
            self.addressBookButton.removeFromSuperview()
            self.addressBookButton = UIButton(frame: CGRect(x: 10, y: self.view.frame.maxY - 60, width: 50, height: 50))
            self.addressBookButton.showsTouchWhenHighlighted = true
            self.addressBookButton.setImage(#imageLiteral(resourceName: "addressBook.png"), for: .normal)
            self.addressBookButton.addTarget(self, action: #selector(self.openAddressBook), for: .touchUpInside)
            self.view.addSubview(self.addressBookButton)
            
        }
        
    }
    
    @objc func openAddressBook() {
        print("openAddressBook")
        
        DispatchQueue.main.async {
            
            if self.addressBook.count > 1 {
                
                let alert = UIAlertController(title: "Which Wallet?", message: "Please select which wallet you'd like to check the balance for", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                for (index, wallet) in self.addressBook.enumerated() {
                    
                    let walletName = wallet["label"] as! String
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString(walletName, comment: ""), style: .default, handler: { (action) in
                        
                        let bitcoinAddress = self.addressBook[index]["address"] as! String
                        
                        if bitcoinAddress.hasPrefix("b") {
                            
                            self.checkBech32Address(address: bitcoinAddress)
                            
                        } else {
                            
                            self.checkBalance(address: bitcoinAddress)
                            
                        }
                        
                        if walletName != "" {
                            
                           self.addressLabel.text = walletName
                            
                        } else {
                            
                           self.addressLabel.text = bitcoinAddress
                        }
                        
                    }))
                    
                }
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            } else if self.addressBook.count == 1 {
                
                let walletName = self.addressBook[0]["label"] as! String
                let bitcoinAddress = self.addressBook[0]["address"] as! String
                
                if walletName != "" {
                    
                    self.addressLabel.text = walletName
                    
                } else {
                    
                    self.addressLabel.text = bitcoinAddress
                }
                
                if bitcoinAddress.hasPrefix("b") {
                    
                    self.checkBech32Address(address: bitcoinAddress)
                    
                } else {
                    
                    self.checkBalance(address: bitcoinAddress)
                    
                }
                
            } else if self.addressBook.count == 0 {
                
                shakeAlert(viewToShake: self.imageView)
                
            }
            
            
        }

    }
    
    func checkBech32Address(address: String) {
        
        print("checkBech32Address")
        
        self.addSpinner()
        
        var url:NSURL!
        
        if testnetMode {
            
            //find testnet for bech32
            url = NSURL(string: "https://api.blockchair.com/bitcoin/dashboards/address/\(address)")
            
        } else if mainnetMode {
            
            url = NSURL(string: "https://api.blockchair.com/bitcoin/dashboards/address/\(address)")
            
        }
        
        print("url = \(url)")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    self.removeSpinner()
                    DispatchQueue.main.async {
                        self.avCaptureSession.startRunning()
                        displayAlert(viewController: self, title: "Error", message: "\(String(describing: error))")
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            print("jsonAddressResult = \(jsonAddressResult)")
                            
                           
                            
                            if let btcAmount = ((jsonAddressResult["data"] as? NSArray)?[0] as? NSDictionary)?["sum_value_unspent"] as? Double {
                                    
                                print("btcAmount = \(btcAmount)")
                                
                                self.balance = btcAmount
                                
                                DispatchQueue.main.async {
                                    
                                    self.videoPreview.removeFromSuperview()
                                    self.addressToDisplay.removeFromSuperview()
                                    
                                    let btcBalanceLabel = UILabel()
                                    btcBalanceLabel.frame = CGRect(x: self.view.center.x - (self.view.frame.width / 2), y: self.view.center.y - ((self.view.frame.height / 2) + 120), width: self.view.frame.width, height: self.view.frame.height)
                                    btcBalanceLabel.text = "\(btcAmount.avoidNotation) BTC"
                                    btcBalanceLabel.textColor = UIColor.black
                                    btcBalanceLabel.font = UIFont.systemFont(ofSize: 32)
                                    btcBalanceLabel.textAlignment = .center
                                    self.view.addSubview(btcBalanceLabel)
                                    
                                    self.addressLabel.adjustsFontSizeToFitWidth = true
                                    self.addressLabel.textColor = UIColor.black
                                    self.addressLabel.font = UIFont.systemFont(ofSize: 23)
                                    self.addressLabel.textAlignment = .center
                                    self.view.addSubview(self.addressLabel)
                                    
                                    self.addressBookButton.removeFromSuperview()
                                    self.myAddressButton.removeFromSuperview()
                                    self.addBackUpButton()
                                    self.generateQrCode(key: address)
                                    self.getExchangeRates()
                                    
                                }
 
                            } else {
                                
                                DispatchQueue.main.async {
                                    self.removeSpinner()
                                    self.avCaptureSession.startRunning()
                                    displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                }
                            }
 
                        } catch {
                            
                            print("JSon processing failed")
                            DispatchQueue.main.async {
                                self.removeSpinner()
                                self.avCaptureSession.startRunning()
                                displayAlert(viewController: self, title: "Error", message: "Please try again.")
                            }
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func addToAddressBookAlert() {
        
        //get a label for the address, add type watch only as defualt for now, create dictionary save it to array of dictionaries
        let alert = UIAlertController(title: "Add a label?", message: "Adding a label will make it easier to differentiate between the addresses in your address book.", preferredStyle: .alert)
        
        alert.addTextField { (textField1) in
            
            textField1.placeholder = "Optional"
            
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default, handler: { (action) in
            
            let label = alert.textFields![0].text!
            let address = self.addressLabel.text!
            var network = ""
            
            if address.hasPrefix("1") || address.hasPrefix("3") || address.hasPrefix("b") {
                
                network = "mainnet"
                
            } else if address.hasPrefix("m") || address.hasPrefix("2") || address.hasPrefix("t") {
                
                network = "testnet"
                
            }
            
            var addressBook: [[String: Any]] = []
            
            if UserDefaults.standard.object(forKey: "addressBook") != nil {
                
                addressBook = UserDefaults.standard.object(forKey: "addressBook") as! [[String: Any]]
                
            }
            
            addressBook.append(["address": "\(address)", "label": label,  "balance": "", "network": "\(network)", "privateKey": "", "publicKey": "", "redemptionScript": "", "type": "cold"])
            
           UserDefaults.standard.set(addressBook, forKey: "addressBook")
            
            displayAlert(viewController: self, title: "Success", message: "You added \"\(address)\" with label \"\(label)\" to your address book.")
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func airDropImage() {
        
        print("airDropImage")
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Save/Share/Copy", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            var addressAlreadySaved = Bool()
            
            for wallet in self.addressBook {
                
                let address = wallet["address"] as! String
                let label = wallet["label"] as! String
                
                if self.addressLabel.text == address || self.addressLabel.text == label {
                    
                    addressAlreadySaved = true
                }
                
            }
            
            if addressAlreadySaved != true {
              
                alert.addAction(UIAlertAction(title: NSLocalizedString("Add to Address Book", comment: ""), style: .default, handler: { (action) in
                    
                    UserDefaults.standard.set(self.addressLabel.text, forKey: "address")
                    print("addressToSave = \(String(describing: self.addressLabel.text))")
                    
                    DispatchQueue.main.async {
                        
                        displayAlert(viewController: self, title: "Address Saved", message: "")
                    }
                    
                    self.addToAddressBookAlert()
                    
                }))
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Bitcoin Address QR Code", comment: ""), style: .default, handler: { (action) in
                    
                    if let data = UIImagePNGRepresentation(self.bitcoinAddressQRCode) {
                        
                        let fileName = getDocumentsDirectory().appendingPathComponent("bitcoinAddress.png")
                        
                        try? data.write(to: fileName)
                        
                        let objectsToShare = [fileName]
                        DispatchQueue.main.async {
                            let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                            self.present(activityController, animated: true, completion: nil)
                        }
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Bitcoin Address Text", comment: ""), style: .default, handler: { (action) in
                    
                    let activityViewController = UIActivityViewController(activityItems: [self.addresses], applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                
            
        }
        
    }
    
    func generateQrCode(key: String) {
        
        let ciContext = CIContext()
        let data = key.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let upScaledImage = filter.outputImage?.transformed(by: transform)
            let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
            self.bitcoinAddressQRCode = UIImage(cgImage: cgImage!)
        }
        
    }
 
}


