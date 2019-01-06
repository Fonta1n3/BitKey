//
//  ViewControllerBalanceChecker.swift
//  BitKeys
//
//  Created by Peter on 1/20/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import AVFoundation
import AES256CBC
import SwiftKeychainWrapper

class ViewControllerBalanceChecker: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate {
    
    let textInputLabel = UILabel()
    var backgroundColours = [UIColor()]
    var backgroundLoop:Int = 0
    var activityIndicator:UIActivityIndicatorView!
    var exRate = Double()
    var currency = String()
    var gbpBalanceLabel = UILabel()
    var euroBalanceLabel = UILabel()
    var usdBalanceLabel = UILabel()
    var btcBalanceLabel = UILabel()
    var segwit = SegwitAddrCoder()
    var addressArray = [[String:Any]]()
    var totalBTC = Double()
    var usdXe = Double()
    var gbpXe = Double()
    var eurXe = Double()
    var addressToDisplay = UITextField()
    var videoPreview = UIView()
    var legacyMode = Bool()
    var segwitMode = Bool()
    var testnetMode = Bool()
    var mainnetMode = Bool()
    var coldMode = Bool()
    var hotMode = Bool()
    //var imageView:UIView!
    let avCaptureSession = AVCaptureSession()
    var balance = Double()
    var backUpButton = UIButton(type: .custom)
    var addressBookButton = UIButton()
    var bitcoinAddressQRCode = UIImage()
    var stringURL = String()
    var myAddressButton = UIButton()
    var addressLabel = UILabel()
    var addressBook = [[String: Any]]()
    var addresses = String()
    var addressToShare = String()

    
    @IBAction func addressText(_ sender: Any) {
        
        
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
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
        
        getExchangeRates()
        addHomeButton()
        addAddressBookButton()
        getUserDefaults()
        
        self.addressLabel.frame = CGRect(x: self.view.center.x - (self.view.frame.width / 2 - 20), y: 100, width: self.view.frame.width - 40, height: 60)
        
    }
    
    func getUserDefaults() {
        
        print("checkUserDefaults")
        
        addressBook = checkAddressBook()
        hotMode = checkSettingsForKey(keyValue: "hotMode")
        coldMode = checkSettingsForKey(keyValue: "coldMode")
        legacyMode = checkSettingsForKey(keyValue: "legacyMode")
        segwitMode = checkSettingsForKey(keyValue: "segwitMode")
        mainnetMode = checkSettingsForKey(keyValue: "mainnetMode")
        testnetMode = checkSettingsForKey(keyValue: "testnetMode")
        
    }
    
    
    func addSpinner() {
        
        DispatchQueue.main.async {
            self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25, y: self.view.center.y - 25, width: 50, height: 50))
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            self.activityIndicator.isUserInteractionEnabled = true
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
        }
        
    }
    
    func removeSpinner() {
        print("removeSpinner")
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView()
        imageView.image = UIImage(named:"background.jpg")
        imageView.frame = self.view.frame
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.alpha = 0.05
        self.view.addSubview(imageView)
        
        self.addressToDisplay.delegate = self
        print("ViewControllerBalanceChecker")
        
        addTextInput()
        addQRScannerView()
        scanQRCode()
        
        backgroundColours = [UIColor.red, UIColor.blue, UIColor.yellow]
        backgroundLoop = 0
        //animateBackgroundColour()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        addressToDisplay.resignFirstResponder()
        //amountToSend.resignFirstResponder()
    }
    
    func animateBackgroundColour () {
        /*if backgroundLoop < backgroundColours.count - 1 {
            self.backgroundLoop += 1
        } else {
            backgroundLoop = 0
        }
        UIView.animate(withDuration: 5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop];
        }) {(Bool) -> Void in
            self.animateBackgroundColour();
        }*/
    }
    
    func addQRScannerView() {
        print("addQRScannerView")
        
        self.videoPreview.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.addressToDisplay.frame.maxY + 10, width: self.view.frame.width - 50, height: self.view.frame.width - 50)
        addShadow(view:self.videoPreview)
        self.view.addSubview(self.videoPreview)
    }
    
    func addTextInput() {
        
        print("addTextInput")
        
        addressToDisplay.frame = CGRect(x: self.view.frame.minX + 25, y: 150, width: self.view.frame.width - 50, height: 50)
        addressToDisplay.textAlignment = .center
        addressToDisplay.borderStyle = .roundedRect
        addressToDisplay.backgroundColor = UIColor.groupTableViewBackground
        addressToDisplay.keyboardAppearance = UIKeyboardAppearance.dark
        addressToDisplay.adjustsFontSizeToFitWidth = true
        addressToDisplay.keyboardType = UIKeyboardType.default
        addressToDisplay.placeholder = "Type or Scan a Bitcoin Address"
        self.view.addSubview(self.addressToDisplay)
        
        textInputLabel.frame = CGRect(x: 50, y: self.addressToDisplay.frame.minY - 65, width: self.view.frame.width - 100, height: 55)
        textInputLabel.adjustsFontSizeToFitWidth = true
        textInputLabel.textColor = UIColor.white
        textInputLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 30)
        addShadow(view: textInputLabel)
        textInputLabel.textAlignment = .center
        textInputLabel.numberOfLines = 0
        textInputLabel.text = "Scan an Address To See a Balance"
        self.view.addSubview(textInputLabel)
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        
        if textField == self.addressToDisplay {
            
            DispatchQueue.main.async {
                
                if self.addressToDisplay.text!.hasPrefix("bc1") {
                    
                    self.checkBech32Address(address: self.addressToDisplay.text!)
                    
                } else {
                    
                    self.checkBalance(address: self.addressToDisplay.text!)
                    
                }
                
                self.addressToDisplay.text = ""
                self.avCaptureSession.stopRunning()
                self.addBalanceView()
                
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
            textInputLabel.removeFromSuperview()
            
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
                
                if stringURL.hasPrefix("bc1") {
                    
                    self.checkBech32Address(address: stringURL)
                    
                } else {
                    
                    self.checkBalance(address: stringURL)
                    
                }
                
                self.addBalanceView()
                
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
        self.addressToShare = address
        var url:NSURL!
        
        func get() {
         
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
                                        
                                        
                                        DispatchQueue.main.async {
                                            self.balance = finalBalanceCheck / 100000000
                                            self.totalBTC = self.balance + self.totalBTC
                                            self.btcBalanceLabel.text = "\(self.totalBTC.avoidNotation) BTC"
                                            self.usdBalanceLabel.text = self.convertBTCtoCurrency(btcAmount: self.totalBTC, exchangeRate: self.exRate)
                                            self.removeSpinner()
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
       
        if address.hasPrefix("1") || address.hasPrefix("3") {
            
            url = NSURL(string: "https://blockchain.info/balance?active=\(address)")
            get()
            
        } else if address.hasPrefix("m") || address.hasPrefix("2") || address.hasPrefix("n") {
            
            url = NSURL(string: "https://testnet.blockchain.info/balance?active=\(address)")
            get()
            
        } else {
            
            displayAlert(viewController: self, title: "Oops", message: "You scanned an invalid Bitcoin address, if you are trying to scan a private key then go to the main screen and tap the plus button to import it. You can put BitSense into cold mode for watch only keys.")
        }
    }
    
    func getExchangeRates() {
        
        var url:NSURL!
        url = NSURL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    DispatchQueue.main.async {
                        displayAlert(viewController: self, title: "Error", message: "Please check your internet connection.")
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonQuoteResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            if let exchangeCheck = jsonQuoteResult["bpi"] as? NSDictionary {
                                
                                print("exchangeCheck = \(exchangeCheck)")
                                
                                if let check = exchangeCheck[self.currency] as? NSDictionary {
                                    
                                    if let rateCheck = check["rate_float"] as? Float {
                                        
                                        self.exRate = Double(rateCheck)
                                        
                                    }
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
        
    }
    
    func convertBTCtoCurrency(btcAmount: Double, exchangeRate: Double) -> String {
        
        var convertedAmount = ""
        //let btcDouble = Double(btcAmount)!
        
        func convertToFiat(currency: String) -> String {
            
            var sign = ""
            switch currency {
            case "USD": sign = "﹩"
            case "GBP": sign = "£"
            case "EUR": sign = "€"
            case "BTC": sign = ""
            case "SAT": sign = ""
            default:
                break
            }
            
            let usdAmount = btcAmount * exchangeRate
            let roundedUsdAmount = round(100 * usdAmount) / 100
            let roundedInt = Int(roundedUsdAmount)
            let fiat = "\(sign)\(roundedInt.withCommas()) \(currency)"
            return fiat
            
        }
        
        switch self.currency {
        case "USD":convertedAmount = convertToFiat(currency: "USD")
        case "GBP":convertedAmount = convertToFiat(currency: "GBP")
        case "EUR":convertedAmount = convertToFiat(currency: "EUR")
        case "SAT":convertedAmount = "\((btcAmount * 100000000).withCommas()) Sat"
        case "BTC":convertedAmount = ""
        default:
            break
        }
        
        return convertedAmount
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
        print("addBackUpButton")
        DispatchQueue.main.async {
            self.backUpButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 90, y: self.view.frame.maxY - 60, width: 80, height: 55))
            self.backUpButton.showsTouchWhenHighlighted = true
            self.backUpButton.backgroundColor = UIColor.clear
            self.backUpButton.setTitle("Share", for: .normal)
            addShadow(view: self.backUpButton)
            self.backUpButton.setTitleColor(UIColor.white, for: .normal)
            self.backUpButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
            self.backUpButton.addTarget(self, action: #selector(self.airDropImage), for: .touchUpInside)
            self.view.addSubview(self.backUpButton)
        }
        
    }
    
    func addAddressBookButton() {
        
        DispatchQueue.main.async {
            
            if self.addressBook.count > 0 {
                
                self.addressBookButton.removeFromSuperview()
                self.addressBookButton = UIButton(frame: CGRect(x: 10, y: self.view.frame.maxY - 60, width: 50, height: 50))
                self.addressBookButton.showsTouchWhenHighlighted = true
                self.addressBookButton.setImage(#imageLiteral(resourceName: "addressBook.png"), for: .normal)
                self.addressBookButton.addTarget(self, action: #selector(self.openAddressBook), for: .touchUpInside)
                self.view.addSubview(self.addressBookButton)
                
            }
            
        }
        
    }
    
    @objc func openAddressBook() {
        print("openAddressBook")
        
        let aespassword = KeychainWrapper.standard.string(forKey: "AESPassword")!
        
        DispatchQueue.main.async {
            
            if self.addressBook.count > 1 {
                
                let alert = UIAlertController(title: "Which Wallet?", message: "Please select which wallet you'd like to check the balance for", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                for wallet in self.addressBook {
                    
                    var walletName = wallet["label"] as! String
                    
                    if walletName == "" {
                        
                        walletName = wallet["address"] as! String
                    }
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString(walletName, comment: ""), style: .default, handler: { (action) in
                        
                        let address = wallet["address"] as! String
                        let network = wallet["network"] as! String
                        
                        if walletName != "" {
                            
                            self.addressLabel.text = walletName
                            
                        } else {
                            
                            self.addressLabel.text = address
                        }
                        
                        if let index = wallet["index"] as? UInt32 {
                            
                            print("index = \(index)")
                            
                            if let xpub = wallet["xpub"] as? String {
                                
                                if xpub != "" {
                                    
                                    if let decryptedXpub = AES256CBC.decryptString(xpub, password: aespassword) {
                                    
                                        self.fetchTotalBalance(network: network, address: address, index: index, xpub: decryptedXpub)
                                        
                                    } else {
                                        
                                        displayAlert(viewController: self, title: "Error", message: "Error decrypting your xpub.")
                                    }
                                    
                                } else {
                                    
                                    if address.hasPrefix("b") {
                                        
                                        self.checkBech32Address(address: address)
                                        
                                    } else {
                                        
                                        self.checkBalance(address: address)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        } else {
                            
                            if address.hasPrefix("b") {
                                
                                self.checkBech32Address(address: address)
                                
                            } else {
                                
                                self.checkBalance(address: address)
                                
                            }
                            
                        }
                        
                    }))
                    
                }
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                }))
                
                alert.popoverPresentationController?.sourceView = self.view
                
                self.present(alert, animated: true) {
                    print("option menu presented")
                }
                
            } else if self.addressBook.count == 1 {
                
                let walletName = self.addressBook[0]["label"] as! String
                let address = self.addressBook[0]["address"] as! String
                let network = self.addressBook[0]["network"] as! String
                
                if walletName != "" {
                    
                    self.addressLabel.text = walletName
                    
                } else {
                    
                    self.addressLabel.text = address
                }
                
                if let index = self.addressBook[0]["index"] as? UInt32 {
                    
                    if let xpub = self.addressBook[0]["xpub"] as? String {
                        
                        if xpub != "" {
                            
                            if let decryptedXpub = AES256CBC.decryptString(xpub, password: aespassword) {
                                
                                self.fetchTotalBalance(network: network, address: address, index: index, xpub: decryptedXpub)
                                
                            } else {
                                
                                displayAlert(viewController: self, title: "Error", message: "Error decrypting your xpub.")
                            }
                            
                        }
                        
                    }
                    
                    //self.fetchTotalBalance(network: network, address: address, index: index, xpub: xpub)
                    
                } else {
                    
                    if address.hasPrefix("b") {
                        
                        self.checkBech32Address(address: address)
                        
                    } else {
                        
                        self.checkBalance(address: address)
                        
                    }
                    
                }
                
            } else if self.addressBook.count == 0 {
                
                displayAlert(viewController: self, title: "Oops", message: "Your address book is empty, please create or import some wallets")
                
            }
            
           self.addBalanceView()
            
        }
        
    }
    
    func addBalanceView() {
        
        DispatchQueue.main.async {
            self.videoPreview.removeFromSuperview()
            self.addressToDisplay.removeFromSuperview()
            self.textInputLabel.removeFromSuperview()
            
            self.btcBalanceLabel.frame = CGRect(x: self.view.center.x - (self.view.frame.width / 2), y: self.view.center.y - ((self.view.frame.height / 2) + 120), width: self.view.frame.width, height: self.view.frame.height)
            self.btcBalanceLabel.textColor = UIColor.white
            addShadow(view: self.btcBalanceLabel)
            self.btcBalanceLabel.textAlignment = .center
            self.btcBalanceLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 35)
            self.view.addSubview(self.btcBalanceLabel)
            
            self.usdBalanceLabel.textColor = UIColor.white
            addShadow(view: self.usdBalanceLabel)
            self.usdBalanceLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 35)
            self.usdBalanceLabel.textAlignment = .center
            self.usdBalanceLabel.frame = CGRect(x: self.view.center.x - (self.view.frame.width / 2), y: self.view.center.y - ((self.view.frame.height / 2) + 60), width: self.view.frame.width, height: self.view.frame.height)
            
            self.addressLabel.adjustsFontSizeToFitWidth = true
            addShadow(view: self.addressLabel)
            self.addressLabel.textColor = UIColor.white
            self.addressLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 23)
            self.addressLabel.textAlignment = .center
            self.view.addSubview(self.addressLabel)
            
            self.addressBookButton.removeFromSuperview()
            self.myAddressButton.removeFromSuperview()
            self.addBackUpButton()
            self.view.addSubview(self.usdBalanceLabel)
            
        }
    }
    
    func fetchTotalBalance(network: String, address: String, index: UInt32, xpub: String) {
        
        if let watchOnlyTestKey = BTCKeychain.init(extendedKey: xpub) {
            
                for i in 0 ... index {
                    
                    var addressHD = String()
                        
                    if network == "testnet" {
                            
                        addressHD = (watchOnlyTestKey.key(at: i).addressTestnet.string)
                            
                    } else if network == "mainnet" {
                            
                        addressHD = (watchOnlyTestKey.key(at: i).address.string)
                            
                    }
                        
                    var bitcoinAddress = String()
                        
                    if address.hasPrefix("1") || address.hasPrefix("3") || address.hasPrefix("2") || address.hasPrefix("m") || address.hasPrefix("n") {
                            
                        bitcoinAddress = addressHD
                            
                    } else if address.hasPrefix("bc1") || address.hasPrefix("tb") {
                            
                        let compressedPKData = BTCRIPEMD160(BTCSHA256(watchOnlyTestKey.key(at: i).compressedPublicKey as Data!) as Data!) as Data!
                            
                        do {
                                
                            if network == "mainnet" {
                                    
                                bitcoinAddress = try self.segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                                    
                            } else if network == "testnet" {
                                    
                                bitcoinAddress = try self.segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                                    
                            }
                                
                        } catch {
                                
                            displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                
                        }
                            
                    }
                        
                    let dict = ["address":bitcoinAddress]
                    self.addressArray.append(dict)
                        
                }
                    
                if address.hasPrefix("b") {
                        
                    for key in self.addressArray {
                            
                        self.checkBech32Address(address: key["address"] as! String)
                    }
                        
                } else {
                        
                    for key in self.addressArray {
                            
                        self.checkBalance(address: key["address"] as! String)
                    }
                        
                }
                    
            
        } else {
            
            displayAlert(viewController: self, title: "Error", message: "We had an issue with the xpub.")
        }
            
    }
    
    func checkBech32Address(address: String) {
        
        print("checkBech32Address")
        
        self.addSpinner()
        self.addressToShare = address
        var url:NSURL!
        
        func get() {
            
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
                                
                                if let btcAmount = ((jsonAddressResult["data"] as? NSArray)?[0] as? NSDictionary)?["sum_value_unspent"] as? String {
                                    
                                    DispatchQueue.main.async {
                                        self.balance = Double(btcAmount)!
                                        self.btcBalanceLabel.text = "\(self.balance.avoidNotation) BTC"
                                        self.usdBalanceLabel.text = self.convertBTCtoCurrency(btcAmount: self.totalBTC, exchangeRate: self.exRate)
                                        self.removeSpinner()
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
        
        
        
        if address.hasPrefix("tb") || address.hasPrefix("bc1") {
            
            //find testnet for bech32
            url = NSURL(string: "https://api.blockchair.com/bitcoin/dashboards/address/\(address)")
            get()
            
        } else {
            
            displayAlert(viewController: self, title: "Oops", message: "That is not a valid address, if you'd like to create a watch only address with a private key then put the app into cold mode in settings then tap the plus button on the home screen to import a watch only key.")
        }
    }
    
    @objc func airDropImage() {
        
        print("airDropImage")
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Share", message: "You can share the QR Code or the text format of the address however you'd like", preferredStyle: UIAlertControllerStyle.actionSheet)
            
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
                    
                    let address = self.addressLabel.text!
                    var network = ""
                    
                    if address.hasPrefix("1") || address.hasPrefix("3") || address.hasPrefix("b") {
                        
                        network = "mainnet"
                        
                    } else if address.hasPrefix("m") || address.hasPrefix("2") || address.hasPrefix("t") {
                        
                        network = "testnet"
                        
                    }
                    
                    let success = saveWallet(viewController: self,mnemonic: "", xpub: "", address: self.addressToShare, privateKey: "", publicKey: "", redemptionScript: "", network: network, type: "cold", index:UInt32(), label: "", xpriv: "")
                    if success {
                        
                        displayAlert(viewController: self, title: "Success", message: "Your new wallet was saved")
                    } else {
                        displayAlert(viewController: self, title: "Error", message: "We had an issue please contact us at BitSenseApp@gmail.com.")
                    }
                    
                }))
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("QR Code", comment: ""), style: .default, handler: { (action) in
                
                let qrcode = self.generateQrCode(key: self.addressToShare)
                    
                    if let data = UIImagePNGRepresentation(qrcode) {
                        
                        let fileName = getDocumentsDirectory().appendingPathComponent("bitcoinAddress.png")
                        
                        try? data.write(to: fileName)
                        
                        let objectsToShare = [fileName]
                        DispatchQueue.main.async {
                            let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                            self.present(activityController, animated: true, completion: nil)
                        }
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Text", comment: ""), style: .default, handler: { (action) in
                    
                    let activityViewController = UIActivityViewController(activityItems: [self.addressToShare], applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                }))
                
            alert.popoverPresentationController?.sourceView = self.view
            
            self.present(alert, animated: true) {
                print("option menu presented")
            }
                
                
            
        }
        
    }
    
    func generateQrCode(key: String) -> UIImage {
        var qrcode = UIImage()
        let ciContext = CIContext()
        let data = key.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let upScaledImage = filter.outputImage?.transformed(by: transform)
            let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
            qrcode = UIImage(cgImage: cgImage!)
            return qrcode
        }
        
       return qrcode
    }
 
}


