//
//  AddressBookViewController.swift
//  BitKeys
//
//  Created by Peter on 6/14/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import LocalAuthentication
import SwiftKeychainWrapper
import AES256CBC

class AddressBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    
    var descriptor = String()
    var stringToExport = String()
    var stopColorChange = Bool()
    let amountLabel = UILabel()
    @IBOutlet var bottomView: UIView!
    let blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let imageImportView = UIImageView()
    var tapGesture = UITapGestureRecognizer()
    var words = ""
    var testnetMode = Bool()
    var mainnetMode = Bool()
    let priceLabel = UILabel()
    var transactionsButton = UIButton()
    var newAddressButton = UIButton()
    var checkAddressButton = UIButton(type: .custom)
    var coldMode = Bool()
    var hotMode = Bool()
    var infoButton = UIButton()
    var lockButton = UIButton()
    var scanQRCodeButton = UIButton()
    var settingsGenButton = UIButton()
    var balance = Double()
    var totalBTC = Double()
    var exchangeRate = Double()
    var HDAddress = String()
    var uploadButton = UIButton()
    let imagePicker = UIImagePickerController()
    var buttonTitle = UILabel()
    var activityIndicator:UIActivityIndicatorView!
    var backUpButton = UIButton()
    var settingsButton = UIButton()
    var privateKeyQRView = UIImageView()
    var privateKeyQRCode = UIImage()
    var privateKeyTitle = UILabel()
    var myField = UITextView()
    var currency = String()
    var createButton = UIButton()
    var amountToSend = UITextField()
    var textToShare = String()
    var fileName = String()
    var editWalletMode = Bool()
    let blurView = UIView()
    var buttonViewVisible = Bool()
    var buttonView = UIView()
    var textInput = UITextField()
    var qrImageView = UIView()
    @IBOutlet var addressBookTable: UITableView!
    var stringURL = String()
    let avCaptureSession = AVCaptureSession()
    let importView = UIView()
    var walletNameToExport = String()
    var backButton = UIButton()
    var addButton = UIButton()
    var addressBook = [[String: Any]]()
    var imageView:UIView!
    var sections = Int()
    var addressToExport = String()
    var privateKeyToExport = String()
    var refresher: UIRefreshControl!
    var ableToDelete = Bool()
    var wallet = [String:Any]()
    var walletToExport = [String:Any]()
    var segwitMode = Bool()
    var legacyMode = Bool()
    var segwit = SegwitAddrCoder()
    var backgroundColours = [UIColor()]
    var backgroundLoop:Int = 0    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("AddressBookViewController")
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        addressBookTable.delegate = self
        addressBookTable.dataSource = self
        addressBookTable.layer.cornerRadius = 10
        textInput.delegate = self
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(self.getArrays), for: UIControlEvents.valueChanged)
        addressBookTable.addSubview(refresher)
        addHomeScreen()
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOffset = CGSize(width: -2.5, height: -2.5)
        bottomView.layer.shadowRadius = 2.5
        bottomView.layer.shadowOpacity = 0.5
        
        
        
        if UserDefaults.standard.object(forKey: "firstTimeHere") != nil {
            
        } else {
            
            UserDefaults.standard.set(true, forKey: "firstTimeHere")
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                
                return
                
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TransactionSettings")
            
            do {
                
                let results = try context.fetch(fetchRequest) as [NSManagedObject]
                
                if results.count > 0 {
                    
                    
                } else {
                    
                    let entity = NSEntityDescription.entity(forEntityName: "TransactionSettings", in: context)
                    let mySettings = NSManagedObject(entity: entity!, insertInto: context)
                    mySettings.setValue(false, forKey: "dollar")
                    mySettings.setValue(true, forKey: "bitcoin")
                    mySettings.setValue(false, forKey: "satoshi")
                    mySettings.setValue(false, forKey: "pounds")
                    mySettings.setValue(false, forKey: "euro")
                    mySettings.setValue(0, forKey: "customFee")
                    mySettings.setValue(false, forKey: "high")
                    mySettings.setValue(true, forKey: "low")
                    mySettings.setValue(false, forKey: "medium")
                    
                    do {
                        
                        try context.save()
                        
                    } catch {
                        
                        print("Failed saving")
                        
                    }
                    
                }
                
            } catch {
                
                print("Failed")
                
            }
            
        }
        
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25, y: self.view.center.y - 25, width: 50, height: 50))
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.activityIndicator.isUserInteractionEnabled = true
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissButtonView))
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        addButtonView()
        addressBook = checkAddressBook()
        
        for (index, _) in addressBook.enumerated() {
            
            addressBook[index]["fiatBalance"] = "loading..."
        }
        
        backgroundColours = [UIColor.red, UIColor.blue, UIColor.green]
        backgroundLoop = 0
        animateBackgroundColour()
    }
    
   func animateBackgroundColour () {
        
        if !stopColorChange {
            
            if backgroundLoop < backgroundColours.count - 1 {
                self.backgroundLoop += 1
            } else {
                backgroundLoop = 0
            }
            UIView.animate(withDuration: 5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
                self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop];
                self.blurView.backgroundColor =  self.backgroundColours[self.backgroundLoop];
                self.importView.backgroundColor =  self.backgroundColours[self.backgroundLoop];
            }) {(Bool) -> Void in
                self.animateBackgroundColour();
            }
            
        }
        
    }
    
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view == self.importView {
            
            return false
            
        } else if touch.view == self.addressBookTable {
            
           return !(touch.view is UITableViewCell)
            
        }
        
        return !(touch.view is UIButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewdidappear")
        
        
        
        getArrays()
        
        words = ""
        
        if let password = UserDefaults.standard.object(forKey: "password") as? String {
            
            let saveSuccessful:Bool = KeychainWrapper.standard.set(password, forKey: "BIP39Password")
            
            if saveSuccessful {
                
                UserDefaults.standard.removeObject(forKey: "password")
                
            }
            
        }
        
        if KeychainWrapper.standard.object(forKey: "firstTime") != nil {
            
            
        } else {
            
            let key = BTCKey.init()
            var password = ""
            
            let compressedPKData = BTCRIPEMD160(BTCSHA256(key?.compressedPublicKey as Data!) as Data!) as Data!
            
            do {
                
                password = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                
                for _ in password {
                    
                    if password.count > 32 {
                        
                        password.removeFirst()
                        
                    }
                    
                }
                
                let saveSuccessful:Bool = KeychainWrapper.standard.set(password, forKey: "AESPassword")
                print("Save was successful: \(saveSuccessful)")
                
                
                
            } catch {
                
                print("error")
                
            }
            
            KeychainWrapper.standard.set(true, forKey: "firstTime")
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                
                return
                
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Settings")
            
            do {
                
                let results = try context.fetch(fetchRequest) as [NSManagedObject]
                
                if results.count > 0 {
                    
                    
                } else {
                    
                    print("no results so create one")
                    let entity = NSEntityDescription.entity(forEntityName: "Settings", in: context)
                    let mySettings = NSManagedObject(entity: entity!, insertInto: context)
                    mySettings.setValue(true, forKey: "hotMode")
                    mySettings.setValue(false, forKey: "coldMode")
                    mySettings.setValue(true, forKey: "legacyMode")
                    mySettings.setValue(false, forKey: "segwitMode")
                    mySettings.setValue(true, forKey: "mainnetMode")
                    mySettings.setValue(false, forKey: "testnetMode")
                    
                    do {
                        
                        try context.save()
                        
                    } catch {
                        
                        print("Failed saving")
                        
                    }
                    
                }
                
            } catch {
                
                print("Failed")
                
            }
            
            self.createNewAccount()
            
        }
        
        ableToDelete = false
        legacyMode = checkSettingsForKey(keyValue: "legacyMode")
        segwitMode = checkSettingsForKey(keyValue: "segwitMode")
        hotMode = checkSettingsForKey(keyValue: "hotMode")
        coldMode = checkSettingsForKey(keyValue: "coldMode")
        mainnetMode = checkSettingsForKey(keyValue: "mainnetMode")
        testnetMode = checkSettingsForKey(keyValue: "testnetMode")
        
        if hotMode == false && coldMode == false && legacyMode == false && segwitMode == false && mainnetMode == false && testnetMode == false {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                
                return
                
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Settings")
            
            do {
                
                let results = try context.fetch(fetchRequest) as [NSManagedObject]
                
                if results.count > 0 {
                    
                    
                } else {
                    
                    print("no results so create one")
                    let entity = NSEntityDescription.entity(forEntityName: "Settings", in: context)
                    let mySettings = NSManagedObject(entity: entity!, insertInto: context)
                    mySettings.setValue(true, forKey: "hotMode")
                    mySettings.setValue(false, forKey: "coldMode")
                    mySettings.setValue(true, forKey: "legacyMode")
                    mySettings.setValue(false, forKey: "segwitMode")
                    mySettings.setValue(true, forKey: "mainnetMode")
                    mySettings.setValue(false, forKey: "testnetMode")
                    
                    do {
                        
                        try context.save()
                        
                    } catch {
                        
                        print("Failed saving")
                        
                    }
                    
                }
                
            } catch {
                
                print("Failed")
                
            }
            
        }
        
        
         if KeychainWrapper.standard.string(forKey: "unlockAESPassword") != nil {
            self.lockButton.setImage(#imageLiteral(resourceName: "whiteLock.png"), for: .normal)
        } else {
            self.lockButton.setImage(#imageLiteral(resourceName: "whiteUnlocked.png"), for: .normal)
        }
        
        if UserDefaults.standard.object(forKey: "wif") != nil {
            
            ensureBackwardsCompatibility()
            
        }

        
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
    
    func createNewAccount() {
        
        self.performSegue(withIdentifier: "createAccount", sender: self)
        
    }
    
    func ensureBackwardsCompatibility() {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Things have changed", message: "We have done a big upgrade to the wallet, don't worry your Bitcoin are safe, we will automatically add your hot wallet to your new \"Address Book\". Now you can have many wallets saved at the same time, all accesible through the address book. You will be prompted to give the wallet a name, which is optional. To access your wallet simply tap the \"Address Book\" button in top right of your screen. Tap OK to proceed.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                
                let wif = UserDefaults.standard.object(forKey: "wif") as! String
                
                if wif.hasPrefix("5") || wif.hasPrefix("K") || wif.hasPrefix("L") {
                    
                    if let privateKey = BTCPrivateKeyAddress(string: wif) {
                        
                        UserDefaults.standard.removeObject(forKey: "wif")
                        
                        if let key = BTCKey.init(privateKeyAddress: privateKey) {
                            
                            let privateKeyWIF = key.privateKeyAddress.string
                            let addressHD = key.address.string
                            let publicKey = key.compressedPublicKey.hex()!
                            
                            var bitcoinAddress = String()
                            
                            if self.legacyMode {
                                
                                bitcoinAddress = addressHD
                                
                            } else if self.segwitMode {
                                
                                let compressedPKData = BTCRIPEMD160(BTCSHA256(key.compressedPublicKey as Data!) as Data!) as Data!
                                
                                do {
                                    
                                    bitcoinAddress = try self.segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                                    
                                } catch {
                                    
                                    displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                    
                                }
                                
                            }
                            
                            //saveWallet(viewController: self, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot", index:UInt32())
                            
                            //self.addressBook = checkAddressBook()
                            
                        }
                        
                    }
                    
                } else if wif.hasPrefix("9") || wif.hasPrefix("c") {
                    
                    if let privateKey = BTCPrivateKeyAddressTestnet(string: wif) {
                        
                        UserDefaults.standard.removeObject(forKey: "wif")
                        
                        if let key = BTCKey.init(privateKeyAddress: privateKey) {
                            
                            let privateKeyWIF = key.privateKeyAddressTestnet.string
                            let addressHD = key.addressTestnet.string
                            let publicKey = key.compressedPublicKey.hex()!
                            
                            var bitcoinAddress = String()
                            
                            if self.legacyMode {
                                
                                bitcoinAddress = addressHD
                                
                            } else if self.segwitMode {
                                
                                let compressedPKData = BTCRIPEMD160(BTCSHA256(key.compressedPublicKey as Data!) as Data!) as Data!
                                
                                do {
                                    
                                    bitcoinAddress = try self.segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                                    
                                } catch {
                                    
                                    displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                    
                                }
                                
                            }
                            
                            //saveWallet(viewController: self, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "testnet", type: "hot", index:UInt32())
                            
                            //self.addressBook = checkAddressBook()
                            
                        }
                        
                    }
                    
                }
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "exportKeys") {
            
            if let vc = segue.destination as? ViewController {
                
                vc.exportKeys = true
                vc.walletToExport = self.walletToExport
            }
            
            /*if self.privateKeyToExport != "" {
                
                if let vc = segue.destination as? ViewController {
                    
                    vc.walletName = self.walletNameToExport
                    vc.bitcoinAddress = addressToExport
                    vc.privateKeyWIF = privateKeyToExport
                    vc.exportPrivateKeyFromTable = true
                    vc.exportKeys = true
                }
                
            } else {
                
                if let vc = segue.destination as? ViewController {
                    
                    vc.walletName = self.walletNameToExport
                    vc.bitcoinAddress = addressToExport
                    vc.exportAddressFromTable = true
                    vc.exportKeys = true
                }
                
            }*/
            
        } else if (segue.identifier == "showHistory") {
            
            if let vc = segue.destination as? TransactionHistoryViewController {
                
               vc.wallet = self.wallet
                
            }
            
            
        } else if (segue.identifier == "goToTransactions") {
            
            DispatchQueue.main.async {
                
                if let vc = segue.destination as? TransactionBuilderViewController {
                    
                    vc.walletToSpendFrom = self.wallet
                    print("vc.walletToSpendFrom = \(vc.walletToSpendFrom)")
                    vc.sendingFromAddress = self.wallet["address"] as! String
                    
                }
                
            }
            
        } else if (segue.identifier == "goToChild") {
            
            if let vc = segue.destination as? HDChildViewController {
                
                vc.masterWallet = self.wallet
                vc.exchangeRate = self.exchangeRate
                print("masterWallet = \(vc.masterWallet)")
                
            }
        } else if (segue.identifier == "createAccount") {
            
            if let vc = segue.destination as? ViewController {
                
                vc.createAccount = true
                
            }
        } else if (segue.identifier == "createDice") {
            
            if let vc = segue.destination as? ViewController {
                
                vc.createDiceKey = true
                
            }
        } else if (segue.identifier == "importRecoveryPhrase") {
            
            if let vc = segue.destination as? ViewController {
                
                vc.importSeed = true
                
            }
        }
        
    }
    
    func addPrice(exchangeRate: Double) {
        
        priceLabel.removeFromSuperview()
        priceLabel.frame = CGRect(x: self.view.center.x - 100, y: 25, width: 200, height: 25)
        priceLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 15)
        priceLabel.textColor = UIColor.white
        addShadow(view: priceLabel)
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
        var currencytoshow = currency
        if currency == "SAT" || currency == "BTC" {
            currencytoshow = "USD"
        }
        let usdAmount = 1 * exchangeRate
        let roundedUsdAmount = round(100 * usdAmount) / 100
        let roundedInt = Int(roundedUsdAmount)
        priceLabel.text = "\(sign)\(roundedInt.withCommas()) \(currencytoshow) / 1 BTC"
        priceLabel.textAlignment = .center
        self.view.addSubview(priceLabel)
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
    
    
    func addButtonView() {
        
        let modelName = UIDevice.modelName
        
        if modelName == "Simulator iPhone X" {
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
        
        let createInvoiceButton =  UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) - (self.view.frame.width / 2.25 - (35/2)) - 5, y: 28, width: 35, height: 35))
         createInvoiceButton.showsTouchWhenHighlighted = true
         createInvoiceButton.setImage(#imageLiteral(resourceName: "whiteInvoice.png"), for: .normal)
         createInvoiceButton.addTarget(self, action: #selector(checkforHD), for: .touchUpInside)
         buttonView.addSubview(createInvoiceButton)
        
        let createInvoiceLabel = UILabel(frame: CGRect(x: createInvoiceButton.center.x - (createInvoiceButton.frame.width / 2), y: 64, width: createInvoiceButton.frame.width, height: 12))
        createInvoiceLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        createInvoiceLabel.textColor = UIColor.white
        createInvoiceLabel.textAlignment = .center
        createInvoiceLabel.text = "Invoice"
        buttonView.addSubview(createInvoiceLabel)
        
        let spendButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) - (self.view.frame.width / 4 - (35/2)) - 5, y: 28, width: 35, height: 35))
        spendButton.showsTouchWhenHighlighted = true
        spendButton.setImage(#imageLiteral(resourceName: "whitePay.png"), for: .normal)
        spendButton.addTarget(self, action: #selector(spendFromWallet), for: .touchUpInside)
        buttonView.addSubview(spendButton)
        
        let spendLabel = UILabel(frame: CGRect(x: spendButton.center.x - (spendButton.frame.width / 2), y: 64, width: spendButton.frame.width, height: 12))
        spendLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        spendLabel.textColor = UIColor.white
        spendLabel.textAlignment = .center
        spendLabel.text = "Pay"
        buttonView.addSubview(spendLabel)
        
        let historyButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)), y: 28, width: 35, height: 35))
        historyButton.showsTouchWhenHighlighted = true
        historyButton.setImage(#imageLiteral(resourceName: "whiteHistory.png"), for: .normal)
        historyButton.addTarget(self, action: #selector(getHistoryWallet), for: .touchUpInside)
        buttonView.addSubview(historyButton)
        
        let historyLabel = UILabel(frame: CGRect(x: historyButton.center.x - (historyButton.frame.width / 2), y: 64, width: historyButton.frame.width, height: 12))
        historyLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        historyLabel.textColor = UIColor.white
        historyLabel.textAlignment = .center
        historyLabel.text = "History"
        buttonView.addSubview(historyLabel)
        
        let editButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) + (self.view.frame.width / 4 - (45/2)) - 5, y: 28, width: 35, height: 35))
        editButton.showsTouchWhenHighlighted = true
        editButton.setImage(#imageLiteral(resourceName: "whiteInfinity.png"), for: .normal)
        editButton.addTarget(self, action: #selector(goToChildTable), for: .touchUpInside)
        buttonView.addSubview(editButton)
        
        let editLabel = UILabel(frame: CGRect(x: editButton.center.x - ((editButton.frame.width + 5) / 2), y: 64, width: editButton.frame.width + 5, height: 12))
        editLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        editLabel.textColor = UIColor.white
        editLabel.textAlignment = .center
        editLabel.text = "HD Keys"
        buttonView.addSubview(editLabel)
        
        let exportButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) + (self.view.frame.width / 2.25 - (35/2)) - 5, y: 28, width: 35, height: 35))
        exportButton.showsTouchWhenHighlighted = true
        exportButton.setImage(#imageLiteral(resourceName: "whiteQR.png"), for: .normal)
        exportButton.addTarget(self, action: #selector(exportWallet), for: .touchUpInside)
        buttonView.addSubview(exportButton)
        
        let exportLabel = UILabel(frame: CGRect(x: exportButton.center.x - (exportButton.frame.width / 2), y: 64, width: exportButton.frame.width, height: 12))
        exportLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        exportLabel.textColor = UIColor.white
        exportLabel.textAlignment = .center
        exportLabel.text = "Export"
        buttonView.addSubview(exportLabel)
        
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
            
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    @objc func goToChildTable() {
        
        if let mnemonic = self.wallet["mnemonic"] as? String {
            
            if mnemonic != "" {
                
                performSegue(withIdentifier: "goToChild", sender: self)
                
            } else if let xpub = self.wallet["xpub"] as? String {
                
                if xpub != "" {
                    
                   performSegue(withIdentifier: "goToChild", sender: self)
                    
                } else {
                    
                    displayAlert(viewController: self, title: "Oops", message: "Thats not an HD wallet HD wallets have the ∞ symbol.")
                }
                
            } else {
                
                displayAlert(viewController: self, title: "Oops", message: "Thats not an HD wallet HD wallets have the ∞ symbol.")
                
            }
            
        } else if let xpub = self.wallet["xpub"] as? String {
            
            if xpub != "" {
                
                performSegue(withIdentifier: "goToChild", sender: self)
                
            } else {
                
                displayAlert(viewController: self, title: "Oops", message: "Thats not an HD wallet HD wallets have the ∞ symbol.")
            }
            
        } else {
            
            displayAlert(viewController: self, title: "Oops", message: "Thats not an HD wallet HD wallets have the ∞ symbol.")
        }
        
    }
    
    func editNow() {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: nil, message: "Please select an option", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            if self.wallet["privateKey"] as! String != "" {
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Make Wallet Cold", comment: ""), style: .default, handler: { (action) in
                    
                    DispatchQueue.main.async {
                        
                        let alert = UIAlertController(title: "WARNING!", message: "This will delete the private key and your ability to spend from this wallet in the app, please ensure you have the private key and recovery phrase backed up first.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Make it Cold", comment: ""), style: .destructive, handler: { (action) in
                            
                            for (index, wallets) in self.addressBook.enumerated() {
                                
                                if wallets["address"] as! String == self.wallet["address"] as! String {
                                    
                                    self.addressBook[index]["privateKey"] = ""
                                    self.addressBook[index]["type"] = "cold"
                                    self.addressBook[index]["xpriv"] = ""
                                    self.addressBook[index]["mnemonic"] = ""
                                    self.editWallet(address: wallets["address"] as! String, newValue: "", oldValue: "", keyToEdit: "privateKey")
                                    self.editWallet(address: wallets["address"] as! String, newValue: "", oldValue: "", keyToEdit: "xpriv")
                                    self.editWallet(address: wallets["address"] as! String, newValue: "", oldValue: "", keyToEdit: "mnemonic")
                                    
                                }
                                
                            }
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                            
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }))
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Edit Wallet Name", comment: ""), style: .default, handler: { (action) in
                
                for (index, address) in self.addressBook.enumerated() {
                    
                    if self.wallet["address"] as! String == address["address"] as! String {
                        
                        let oldName = self.addressBook[index]["label"] as! String
                        
                        let alert = UIAlertController(title: "Give \"\(oldName)\" a new name", message: "", preferredStyle: .alert)
                        
                        alert.addTextField { (textField1) in
                            
                            textField1.placeholder = "Optional"
                            
                        }
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Update", comment: ""), style: .default, handler: { (action) in
                            
                            let label = alert.textFields![0].text!
                            self.addressBook[index]["label"] = label
                            self.editWallet(address: address["address"] as! String, newValue: label, oldValue: oldName, keyToEdit: "label")
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }))
            
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            alert.popoverPresentationController?.sourceView = self.view
            
            self.present(alert, animated: true) {
                print("option menu presented")
            }
            
        }
        
    }
    
    @objc func editWalletButton() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        print("editWalletButton")
        
        self.editWalletMode = true
        
        if UserDefaults.standard.object(forKey: "bioMetricsEnabled") != nil {
            
            self.authenticationWithTouchID(item: "")
            
        } else if let _ = KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
            
            var password = String()
            
            let alert = UIAlertController(title: "Please input your password", message: "Please enter your password to edit a wallet", preferredStyle: .alert)
            
            alert.addTextField { (textField1) in
                
                textField1.placeholder = "Enter Password"
                textField1.isSecureTextEntry = true
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Continue", comment: ""), style: .default, handler: { (action) in
                
                password = alert.textFields![0].text!
                
                if password == KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
                    
                    self.editNow()
                    self.editWalletMode = false
                    
                } else {
                    
                    displayAlert(viewController: self, title: "Error", message: "Incorrect password!")
                    self.editWalletMode = false
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                self.editWalletMode = false
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            self.editNow()
            self.editWalletMode = false
        }
        
    }
    
    @objc func spendFromWallet() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
      self.performSegue(withIdentifier: "goToTransactions", sender: self)
        
    }
    
    @objc func getHistoryWallet() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.performSegue(withIdentifier: "showHistory", sender: self)
    }
    
    @objc func goToSettings() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.performSegue(withIdentifier: "goToSettings", sender: self)
        
    }
    
    @objc func createWalletInvoice() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        let modelName = UIDevice.modelName

        self.blurView.frame = self.view.frame
        //self.blurView.backgroundColor = UIColor.white
        self.view.addSubview(self.blurView)
        
        let imageView = UIImageView()
        imageView.image = UIImage(named:"background.jpg")
        imageView.frame = self.view.frame
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.alpha = 0.05
        self.blurView.addSubview(imageView)
        
        if modelName == "Simulator iPhone X" {
            
            self.backButton = UIButton(frame: CGRect(x: 5, y: 30, width: 55, height: 55))
            
            
        } else {
            
            self.backButton = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
            
        }
        
        self.backButton.showsTouchWhenHighlighted = true
        self.backButton.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
        self.backButton.addTarget(self, action: #selector(self.dismissInvoiceView), for: .touchUpInside)
        self.blurView.addSubview(self.backButton)
        
        self.settingsButton.removeFromSuperview()
        
        if modelName == "Simulator iPhone X" {
            
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
        
        print("amount = \(amount)")
        
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
                
                var name = self.wallet["label"] as! String
                if name == "" {
                    name = self.HDAddress
                }
                
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
    
    @objc func goTo(sender: UIButton) {
        
        switch sender {
            
        case self.backUpButton:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            self.share(textToShare: self.textToShare, filename: self.fileName)
            
        case self.infoButton:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            print("go to info")
            self.performSegue(withIdentifier: "goToInfo", sender: self)
            
        case self.settingsGenButton:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            print("go to settings")
            self.performSegue(withIdentifier: "settings", sender: self)
            
        case self.transactionsButton:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            goPay()
            
        default:
            break
        }
        
    }
    
    func goPay() {
        
        addressBook = checkAddressBook()
        
        if self.hotMode {
            
            print("hotmode  = \(self.hotMode)")
            
            if addressBook.count == 1 {
                
                self.wallet = addressBook[0]
                self.performSegue(withIdentifier: "goToTransactions", sender: self)
                
            } else if addressBook.count > 1 {
                
                DispatchQueue.main.async {
                    
                        let alert = UIAlertController(title: "Which Wallet?", message: "Please select which wallet you'd like to spend from", preferredStyle: UIAlertControllerStyle.actionSheet)
                        
                        for wallet in self.addressBook {
                            
                            var walletName = wallet["label"] as! String
                            
                            if walletName == "" {
                                
                                walletName = wallet["address"] as! String
                            }
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString(walletName, comment: ""), style: .default, handler: { (action) in
                                
                                self.wallet = wallet
                                self.performSegue(withIdentifier: "goToTransactions", sender: self)
                                
                            }))
                            
                        }
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("A different one", comment: ""), style: .default, handler: { (action) in
                            
                            self.performSegue(withIdentifier: "goTransactionAgnostic", sender: self)
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                            
                        }))
                        
                        alert.popoverPresentationController?.sourceView = self.view
                        
                        self.present(alert, animated: true) {
                            print("option menu presented")
                        }
                        
                    
                }
                
                
            } else if self.coldMode {
                
                self.performSegue(withIdentifier: "goTransactionAgnostic", sender: self)
                
            }
            
        } else {
            
            self.performSegue(withIdentifier: "goTransactionAgnostic", sender: self)
        }
        
        
        
    }
    
    func showKeyManagementAlert() {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Key Tools", message: "Please select an option", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Create Keys with Dice", comment: ""), style: .default, handler: { (action) in
                
                self.performSegue(withIdentifier: "createDice", sender: self)
                
           }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Import Recovery Phrase", comment: ""), style: .default, handler: { (action) in
                
                self.performSegue(withIdentifier: "importRecoveryPhrase", sender: self)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Create Multi Sig", comment: ""), style: .default, handler: { (action) in
                
                self.performSegue(withIdentifier: "createMultiSig", sender: self)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            alert.popoverPresentationController?.sourceView = self.view
            
            self.present(alert, animated: true) {
                print("option menu presented")
            }
        }
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
    
    func createInvoiceforHD(network: String, address: String, index: UInt32, xpub: String) {
        
        print("createInvoiceforHD")
        print("xpub = \(xpub)")
        
        if let watchOnlyTestKey = BTCKeychain.init(extendedKey: xpub) {
            
            print("watchOnlyTestKey = \(watchOnlyTestKey)")
            
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
    
    @objc func dismissButtonView() {
        
        if self.stopColorChange {
            
            
        } else {
            
            self.stopColorChange = true
        }
        
        let modelName = UIDevice.modelName
        
        DispatchQueue.main.async {
            self.buttonViewVisible = false
            DispatchQueue.main.async {
                
                self.buttonTitle.removeFromSuperview()
                self.view.addSubview(self.transactionsButton)
                self.view.addSubview(self.newAddressButton)
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.transactionsButton.alpha = 1
                    self.newAddressButton.alpha = 1
                    
                    if modelName == "Simulator iPhone X" {
                        //add pricelabel
                        self.buttonView.frame = CGRect(x: 0, y: self.view.frame.maxY + 6, width: self.view.frame.width, height: 160)
                        self.transactionsButton.frame = CGRect(x: 5, y: self.bottomView.frame.minY - 70, width: 85, height: 50)
                        self.newAddressButton.frame = CGRect(x: self.view.frame.maxX - 110, y: self.bottomView.frame.minY - 70, width: 100, height: 50)
                    } else {
                        self.buttonView.frame = CGRect(x: 0, y: self.view.frame.maxY + 6, width: self.view.frame.width, height: 100)
                        self.transactionsButton.frame = CGRect(x: self.view.frame.maxX - 60, y: self.bottomView.frame.minY - 55, width: 50, height: 50)
                        self.newAddressButton.frame = CGRect(x: 5, y: self.bottomView.frame.minY - 55, width: 100, height: 50)
                    }
                    
                })
                
                
            }
        }
        
    }
    
    func decrypt(item: String) -> String {
        
        var decrypted = ""
        
        if let password = KeychainWrapper.standard.string(forKey: "AESPassword") {
            
            if let decryptedCheck = AES256CBC.decryptString(item, password: password) {
                
                decrypted = decryptedCheck.replacingOccurrences(of: ",", with: "")
                
            }
            
        }
        
        return decrypted
        
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
                            
                            let descriptor = self.walletToExport["descriptor"] as! String
                            
                            func getSecret() {
                                
                                let decryptedItem = self.decrypt(item: item)
                                
                                if decryptedItem != "" {
                                    
                                    self.walletToExport["stringToExport"] = decryptedItem
                                    self.performSegue(withIdentifier: "exportKeys", sender: self)
                                }
                            }
                            
                            switch descriptor {
                            case "redemptionScript": self.performSegue(withIdentifier: "exportKeys", sender: self)
                            default:getSecret()
                            }
                            
                        } else {
                            
                            displayAlert(viewController: self, title: "Error", message: "Incorrect password!")
                        }
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                        
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            
        }
        
        var array = [[String:Any]]()
        var name = self.wallet["label"] as! String
        let privateKey = self.wallet["privateKey"] as! String
        let address = self.wallet["address"] as! String
        let publicKey = self.wallet["publicKey"] as! String
        let mnemonic = self.wallet["mnemonic"] as! String
        let xpub = self.wallet["xpub"] as! String
        let xprv = self.wallet["xpriv"] as! String
        let redemptionScript = self.wallet["redemptionScript"] as! String
        
        if name == "" {
            name = address
        }
        
        if privateKey.contains(" ") {
            
            let privateKeyArray = privateKey.split(separator: " ")
            
            for (index, key) in privateKeyArray.enumerated() {
                
                let keyString = String(key)
                
                array.append(["stringToExport":keyString, "descriptor":"privateKey", "title":"Private Key \(index + 1)", "label":name])
                
            }
            
        } else {
          
            array.append(["stringToExport":privateKey, "descriptor":"privateKey", "title":"Private Key", "label":name])
            
        }
        
        if publicKey.contains(" ") {
            
            let publicKeyArray = publicKey.split(separator: " ")
            
            for (index, key) in publicKeyArray.enumerated() {
                
                let keyString = String(key)
                
                array.append(["stringToExport":keyString, "descriptor":"publicKey", "title":"Public Key \(index + 1)", "label":name])
                
            }
            
        } else {
            
            array.append(["stringToExport":publicKey, "descriptor":"publicKey", "title":"Public Key", "label":name])
            
        }
        
        array.append(["stringToExport":address, "descriptor":"address", "title":"Address", "label":name])
        array.append(["stringToExport":mnemonic, "descriptor":"mnemonic", "title":"Recovery Phrase", "label":name])
        array.append(["stringToExport":xpub, "descriptor":"xpub", "title":"XPUB", "label":name])
        array.append(["stringToExport":xprv, "descriptor":"xpriv", "title":"XPRV", "label":name])
        array.append(["stringToExport":redemptionScript, "descriptor":"redemptionScript", "title":"Redemption Script", "label":name])
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Select Item to Export", message: "From: \(name)", preferredStyle: .actionSheet)
            
            for item in array {
                
                let descriptor = item["descriptor"] as! String
                let itemToExport = item["stringToExport"] as! String
                let title = item["title"] as! String
                
                if itemToExport != "" {
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString(title, comment: ""), style: .default, handler: { (action) in
                        
                        self.walletToExport = item
                        
                        switch descriptor {
                        case "privateKey": authorize(item:item["stringToExport"] as! String)
                        case "mnemonic": authorize(item:item["stringToExport"] as! String)
                        case "xpub": authorize(item:item["stringToExport"] as! String)
                        case "xpriv": authorize(item:item["stringToExport"] as! String)
                        case "redemptionScript": authorize(item:item["stringToExport"] as! String)
                        default: self.performSegue(withIdentifier: "exportKeys", sender: self)
                        }
                        
                    }))
                    
                }
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    @objc func getArrays() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        addressBook = checkAddressBook()
        
        
        
        if addressBook.count == 0 {
            
            self.removeSpinner()
            
        }
        
        for (index, _) in addressBook.enumerated() {
            
            addressBook[index]["fiatBalance"] = "loading..."
        }
        addressBookTable.reloadData()
        
        getExchangeRates()
        
    }
    
    func showButtonView() {
        print("buttonView")
        
        let modelName = UIDevice.modelName
        
        if buttonViewVisible == false {
            
            self.buttonViewVisible = true
            DispatchQueue.main.async {
                
                self.buttonTitle.frame = CGRect(x: self.buttonView.center.x - ((self.buttonView.frame.width - 20) / 2), y: 3, width: self.buttonView.frame.width - 20, height: 20)
                
                var text = String()
                
                if let _ = self.wallet["label"] as? String {
                    print("wallet = \(self.wallet)")
                    
                    if self.wallet["label"] as! String != "" {
                        
                        text = self.wallet["label"] as! String
                        
                    } else {
                        
                        text = self.wallet["address"] as! String
                        
                    }
                    
                }
                
                self.buttonTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 15)
                self.buttonTitle.textColor = UIColor.white
                self.buttonTitle.textAlignment = .center
                self.buttonTitle.adjustsFontSizeToFitWidth = true
                self.buttonTitle.text = text
                self.buttonView.addSubview(self.buttonTitle)
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.transactionsButton.removeFromSuperview()
                    self.newAddressButton.removeFromSuperview()
                    
                    if modelName == "Simulator iPhone X" {
                        self.buttonView.frame = CGRect(x: 0, y: self.view.frame.maxY - 160, width: self.view.frame.width, height: 160)
                    } else {
                        
                      self.buttonView.frame = CGRect(x: 0, y: self.view.frame.maxY - 100, width: self.view.frame.width, height: 100)
                    }
                    
                })
                
            }
            
        } else {
            
            
            DispatchQueue.main.async {
                self.buttonTitle.removeFromSuperview()
                
                var text = String()
                
                if let _ = self.wallet["label"] as? String {
                    print("wallet = \(self.wallet)")
                    
                    if self.wallet["label"] as! String != "" {
                        
                        text = self.wallet["label"] as! String
                        
                    } else {
                        
                        text = self.wallet["address"] as! String
                        
                    }
                    
                }
                
                self.buttonTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 15)
                self.buttonTitle.textColor = UIColor.black
                self.buttonTitle.textAlignment = .center
                self.buttonTitle.adjustsFontSizeToFitWidth = true
                self.buttonTitle.text = text
                self.buttonView.addSubview(self.buttonTitle)
            }
            
        }
        
        
    }
    
   @objc func add() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        print("add")
        
        self.importWallet()
    }
    
    func importWallet() {
        
        print("importWallet")
        importView.frame = view.frame
        
        imageImportView.image = UIImage(named:"background.jpg")
        imageImportView.frame = self.view.frame
        imageImportView.contentMode = UIViewContentMode.scaleAspectFill
        imageImportView.alpha = 0.05
        
        
        self.backButton = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
        self.backButton.showsTouchWhenHighlighted = true
        self.backButton.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
        self.backButton.addTarget(self, action: #selector(self.dismissImportView), for: .touchUpInside)
        
        
        self.textInput.frame = CGRect(x: self.view.frame.minX + 25, y: 150, width: self.view.frame.width - 50, height: 50)
        self.textInput.textAlignment = .center
        self.textInput.borderStyle = .roundedRect
        self.textInput.autocorrectionType = .no
        self.textInput.autocapitalizationType = .none
        self.textInput.keyboardAppearance = UIKeyboardAppearance.dark
        self.textInput.backgroundColor = UIColor.groupTableViewBackground
        self.textInput.returnKeyType = UIReturnKeyType.go
        self.textInput.placeholder = "Scan or type an Address or Private Key"
        
        let title = UILabel(frame: CGRect(x: self.view.center.x - ((self.view.frame.width - 50) / 2), y: self.textInput.frame.minY - 65, width: self.view.frame.width - 50, height: 55))
        title.font = UIFont.init(name: "HelveticaNeue-Bold", size: 30)
        title.textColor = UIColor.white
        title.text = "Import Address, Private Key, XPUB or XPRV"
        title.numberOfLines = 0
        addShadow(view: title)
        title.adjustsFontSizeToFitWidth = true
        title.textAlignment = .center
        
        
        self.qrImageView.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.textInput.frame.maxY + 10, width: self.view.frame.width - 50, height: self.view.frame.width - 50)
        addShadow(view:self.qrImageView)
        
        self.uploadButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 140, y: self.view.frame.maxY - 60, width: 130, height: 55))
        self.uploadButton.showsTouchWhenHighlighted = true
        self.uploadButton.setTitle("From Photos", for: .normal)
        addShadow(view: self.uploadButton)
        self.uploadButton.setTitleColor(UIColor.white, for: .normal)
        self.uploadButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        self.uploadButton.addTarget(self, action: #selector(self.chooseQRCodeFromLibrary), for: .touchUpInside)
        
        let createNew = UIButton()
        createNew.frame = CGRect(x: 10, y: self.view.frame.maxY - 60, width: 130, height: 55)
        createNew.showsTouchWhenHighlighted = true
        createNew.setTitle("Create New", for: .normal)
        createNew.setTitleColor(UIColor.white, for: .normal)
        addShadow(view: createNew)
        createNew.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        createNew.addTarget(self, action: #selector(self.createNew), for: .touchUpInside)
        
        func scanQRCode() {
            
            do {
                
                try scanQRNow()
                print("scanQRNow")
                
            } catch {
                
                print("Failed to scan QR Code")
            }
            
        }
        
        DispatchQueue.main.async {
            
            self.view.addSubview(self.importView)
            self.importView.addSubview(self.imageImportView)
            self.importView.addSubview(title)
            self.importView.addSubview(self.backButton)
            self.importView.addSubview(self.textInput)
            self.importView.addSubview(self.qrImageView)
            self.importView.addSubview(self.uploadButton)
            self.importView.addSubview(createNew)
            scanQRCode()
        }
        
    }
    
    @objc func createNew() {
        
        self.dismissImportView()
        self.performSegue(withIdentifier: "createAccount", sender: self)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            
            let ciImage:CIImage = CIImage(image:pickedImage)!
            
            var qrCodeLink = ""
            
            let features=detector.features(in: ciImage)
            
            for feature in features as! [CIQRCodeFeature] {
                
                qrCodeLink += feature.messageString!
            }
            
            print(qrCodeLink)
            
            if qrCodeLink != "" {
                
                DispatchQueue.main.async {
                    
                    self.processKeys(key: qrCodeLink)
                    self.qrImageView.removeFromSuperview()
                    self.avCaptureSession.stopRunning()
                    
                }
                
            }
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func chooseQRCodeFromLibrary() {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    enum error: Error {
        
        case noCameraAvailable
        case videoInputInitFail
        
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
        
        if let inputs = self.avCaptureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.avCaptureSession.removeInput(input)
            }
        }
        
        if let outputs = self.avCaptureSession.outputs as? [AVCaptureMetadataOutput] {
            for output in outputs {
                self.avCaptureSession.removeOutput(output)
            }
        }
        
        self.avCaptureSession.addInput(avCaptureInput)
        self.avCaptureSession.addOutput(avCaptureMetadataOutput)
        
        avCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession)
        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avCaptureVideoPreviewLayer.frame = self.qrImageView.bounds
        self.qrImageView.layer.addSublayer(avCaptureVideoPreviewLayer)
        
        self.avCaptureSession.startRunning()
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            print("metadataOutput")
            
            let machineReadableCode = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if machineReadableCode.type == AVMetadataObject.ObjectType.qr {
                
                stringURL = machineReadableCode.stringValue!
                print("stringURL = \(stringURL)")
                
                processKeys(key: stringURL)
                
                self.qrImageView.removeFromSuperview()
                self.avCaptureSession.stopRunning()
                
            }
        }
    }
    
    func processKeys(key: String) {
        print("processKeys = \(key)")
        
        var success = Bool()
        
        func processPrivateKey(privateKey: String) {
            
            if privateKey.hasPrefix("9") || privateKey.hasPrefix("c") {
                print("testnetMode")
                
                if let privateKey = BTCPrivateKeyAddressTestnet(string: privateKey) {
                    
                    if let key = BTCKey.init(privateKeyAddress: privateKey) {
                        
                        print("privateKey = \(key.privateKeyAddressTestnet)")
                        var bitcoinAddress = String()
                        
                        let privateKeyWIF = key.privateKeyAddressTestnet.string
                        let addressHD = key.addressTestnet.string
                        
                        let publicKey = key.compressedPublicKey.hex()!
                        print("publicKey = \(publicKey)")
                        
                        if self.legacyMode {
                            
                            bitcoinAddress = addressHD
                            
                        }
                        
                        if segwitMode {
                            
                            let compressedPKData = BTCRIPEMD160(BTCSHA256(key.compressedPublicKey as Data!) as Data!) as Data!
                            
                            do {
                                
                                bitcoinAddress = try segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                                
                            } catch {
                                
                                displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                
                            }
                            
                        }
                        
                        DispatchQueue.main.async {
                            self.importView.removeFromSuperview()
                            
                            success = saveWallet(viewController: self, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "testnet", type: "hot", index: UInt32(), label: "", xpriv: "")
                            if success {
                                self.addressBook = checkAddressBook()
                                self.getArrays()
                                displayAlert(viewController: self, title: "Success", message: "You imported a wallet, you can rename it by swiping it left and tapping edit.")
                                
                            } else {
                                displayAlert(viewController: self, title: "Error", message: "There was a problem importing your key, please contact us at BitSenseApp@gmail.com")
                            }
                        }
                        
                    }
                }
                
                
            } else if privateKey.hasPrefix("5") || privateKey.hasPrefix("K") || privateKey.hasPrefix("L") {
                print("mainnetMode")
                
                if let privateKey = BTCPrivateKeyAddress(string: privateKey) {
                    
                    if let key = BTCKey.init(privateKeyAddress: privateKey) {
                        
                        var bitcoinAddress = String()
                        
                        let privateKeyWIF = key.privateKeyAddress.string
                        let addressHD = key.address.string
                        let publicKey = key.compressedPublicKey.hex()!
                        print("publicKey = \(publicKey)")
                        
                        if self.legacyMode {
                            
                            bitcoinAddress = addressHD
                            
                        }
                        
                        if segwitMode {
                            
                            let compressedPKData = BTCRIPEMD160(BTCSHA256(key.compressedPublicKey as Data!) as Data!) as Data!
                            
                            do {
                                
                                bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                                
                            } catch {
                                
                                displayAlert(viewController: self, title: "Error", message: "Please try again.")
                                
                            }
                            
                        }
                        
                        DispatchQueue.main.async {
                            self.importView.removeFromSuperview()
                            
                            success = saveWallet(viewController: self, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot", index: UInt32(), label: "", xpriv: "")
                            if success {
                                self.addressBook = checkAddressBook()
                                self.getArrays()
                                displayAlert(viewController: self, title: "Success", message: "You imported a wallet, you can rename it by swiping it left and tapping edit.")
                                
                            } else {
                                displayAlert(viewController: self, title: "Error", message: "There was a problem importing your key, please contact us at BitSenseApp@gmail.com")
                            }
                        }
                        
                    }
                    
                }
                
            }

        }
        
        if key.hasPrefix("9") || key.hasPrefix("c") || key.hasPrefix("5") || key.hasPrefix("K") || key.hasPrefix("L") {
            
            processPrivateKey(privateKey: key)
            
        } else if key.hasPrefix("1") || key.hasPrefix("3") || key.hasPrefix("bc") || key.hasPrefix("2") {
            
            self.importView.removeFromSuperview()
            
            success = saveWallet(viewController: self, mnemonic: "", xpub: "", address: key, privateKey: "", publicKey: "", redemptionScript: "", network: "mainnet", type: "cold", index: UInt32(), label: "", xpriv: "")
            
            if success {
                self.addressBook = checkAddressBook()
                self.getArrays()
                displayAlert(viewController: self, title: "Success", message: "You imported a wallet, you can rename it by swiping it left and tapping edit.")
                
            } else {
                displayAlert(viewController: self, title: "Error", message: "There was a problem importing your key, please contact us at BitSenseApp@gmail.com")
            }
            
        } else if key.hasPrefix("m") || key.hasPrefix("tb") || key.hasPrefix("2") {
            
            self.importView.removeFromSuperview()
            
            success = saveWallet(viewController: self, mnemonic: "", xpub: "", address: key, privateKey: "", publicKey: "", redemptionScript: "", network: "testnet", type: "cold", index: UInt32(), label: "", xpriv: "")
            if success {
                self.addressBook = checkAddressBook()
                self.getArrays()
                displayAlert(viewController: self, title: "Success", message: "You imported a wallet, you can rename it by swiping it left and tapping edit.")
                
            } else {
                displayAlert(viewController: self, title: "Error", message: "There was a problem importing your key, please contact us at BitSenseApp@gmail.com")
            }
            
        } else if key.hasPrefix("xpub") {
                
            self.importView.removeFromSuperview()
            
            if let keychain = BTCKeychain.init(extendedKey: key) {
                
                let addressHD = (keychain.key(at: 0).address.string)
                keychain.key.isPublicKeyCompressed = true
                let publicKey = (keychain.key(at: 0).compressedPublicKey.hex())!
                
                success = saveWallet(viewController: self, mnemonic: "", xpub: key, address: addressHD, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "cold", index: UInt32(), label: "", xpriv: "")
                if success {
                    self.addressBook = checkAddressBook()
                    self.getArrays()
                    displayAlert(viewController: self, title: "Success", message: "You imported a wallet, you can rename it by swiping it left and tapping edit.")
                    
                } else {
                    displayAlert(viewController: self, title: "Error", message: "There was a problem importing your key, please contact us at BitSenseApp@gmail.com")
                }
            } else {
                displayAlert(viewController: self, title: "Error", message: "We had an issue with your xpub, please contact us at BitSenseApp@gmail.com")
            }
            
        } else if key.hasPrefix("xprv") {
            
            self.importView.removeFromSuperview()
            
            if let keychain = BTCKeychain.init(extendedKey: key) {
                
                let addressHD = (keychain.key(at: 0).address.string)
                let pkHD = (keychain.key(at: 0).privateKeyAddress.string)
                let xpub = keychain.extendedPublicKey!
                keychain.key.isPublicKeyCompressed = true
                let publicKey = (keychain.key(at: 0).compressedPublicKey.hex())!
                
                success = saveWallet(viewController: self, mnemonic: "", xpub: xpub, address: addressHD, privateKey: pkHD, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot", index: UInt32(), label: "", xpriv: key)
                
                if success {
                    self.addressBook = checkAddressBook()
                    self.getArrays()
                    displayAlert(viewController: self, title: "Success", message: "You can rename it by swiping it left and tapping edit.")
                    
                } else {
                    displayAlert(viewController: self, title: "Error", message: "There was a problem importing your key, please contact us at BitSenseApp@gmail.com")
                }
            } else {
                displayAlert(viewController: self, title: "Error", message: "We had an issue with your xpub, please contact us at BitSenseApp@gmail.com")
            }
            
        } else {
            
            displayAlert(viewController: self, title: "Error", message: "Thats not a valid Bitcoin Private Key or Address")
            
        }
        
     }
    
    @objc func dismissImportView() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        DispatchQueue.main.async {
            self.imageImportView.removeFromSuperview()
            self.textInput.removeFromSuperview()
            self.avCaptureSession.stopRunning()
            self.qrImageView.removeFromSuperview()
            self.importView.removeFromSuperview()
            
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return addressBook.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        
        cell.contentView.alpha = 0.8
        cell.selectionStyle = .none
        cell.layer.cornerRadius = 10
        
        let balanceLabel = cell.viewWithTag(1) as! UILabel
        let nameLabel = cell.viewWithTag(2) as! UILabel
        let currencyLabel = cell.viewWithTag(3) as! UILabel
        let descriptorLabel = cell.viewWithTag(4) as! UILabel
        
        nameLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 18)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.textColor = UIColor.white
        balanceLabel.font = UIFont.init(name: "HelveticaNeue", size: 15)
        balanceLabel.textColor = UIColor.white
        currencyLabel.font = UIFont.init(name: "HelveticaNeue", size: 15)
        currencyLabel.textColor = UIColor.white
        descriptorLabel.font = UIFont.init(name: "Helvetica", size: 15)
        
        let label = self.addressBook[indexPath.section]["label"] as! String
        let address = self.addressBook[indexPath.section]["address"] as! String
        let balance = self.addressBook[indexPath.section]["balance"] as! String
        let convertedBalance = self.addressBook[indexPath.section]["fiatBalance"] as! String
        let type = self.addressBook[indexPath.section]["type"] as! String
        let network = self.addressBook[indexPath.section]["network"] as! String
        let xpub = self.addressBook[indexPath.section]["xpub"] as! String
        
        if label != "" {
            
            nameLabel.text = label
            
        } else {
            
            nameLabel.text = address
            
        }
        
        balanceLabel.text = balance
        currencyLabel.text = convertedBalance
        
        if xpub != "" && type == "cold" && network == "mainnet" {
            
            descriptorLabel.text = "👀∞"
            
        } else if xpub != "" && type == "hot" && network == "mainnet" {
            
            descriptorLabel.text = "∞"
            
        } else if xpub != "" && type == "cold" && network == "testnet" {
            
            descriptorLabel.text = "🤓👀∞"
            
        } else if xpub != "" && type == "hot" && network == "testnet" {
            
            descriptorLabel.text = "🤓∞"
            
        } else if xpub == "" && type == "cold" && network == "testnet" {
            
            descriptorLabel.text = "🤓👀"
            
        } else if xpub == "" && type == "hot" && network == "testnet" {
            
            descriptorLabel.text = "🤓"
            
        } else if xpub == "" && type == "cold" && network == "mainnet" {
            
            descriptorLabel.text = "👀"
            
        } else if xpub == "" && type == "hot" && network == "mainnet" {
            
            descriptorLabel.text = ""
            
        } else if type.hasPrefix("multiSig") {
            
            let format1 = type.replacingOccurrences(of: "multiSig-", with: "")
            let format2 = format1.replacingOccurrences(of: "of", with: "-")
            let array = format2.split(separator: "-")
            let m = array[0]
            let n = array[1]
            
            if network == "testnet" {
                descriptorLabel.text = "🤓 \(m) of \(n) MultiSig"
            } else {
               descriptorLabel.text = "\(m) of \(n) MultiSig"
            }
            
        }
        
        return cell
        
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
                        displayAlert(viewController: self, title: "Error", message: "Please check your interent connection.")
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonQuoteResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            if let exchangeCheck = jsonQuoteResult["bpi"] as? NSDictionary {
                                
                                print("exchangeCheck = \(exchangeCheck)")
                                
                                var currencyToShow = self.currency
                                
                                if currencyToShow == "SAT" ||  currencyToShow == "BTC" {
                                    
                                    currencyToShow = "USD"
                                }
                                
                                if let xeCheck = exchangeCheck[currencyToShow] as? NSDictionary {
                                    
                                    if let rateCheck = xeCheck["rate_float"] as? Float {
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.exchangeRate = Double(rateCheck)
                                            
                                            
                                            self.addPrice(exchangeRate: self.exchangeRate)
                                            
                                            for (index, address) in self.addressBook.enumerated() {
                                                
                                                let addressToCheck = address["address"] as! String
                                                let network = address["network"] as! String
                                                let type = address["type"] as! String
                                                self.checkBalance(address: addressToCheck, index: index, network: network, type: type)
                                                
                                            }
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
    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.wallet = addressBook[indexPath.section]
        
        tableView.allowsMultipleSelection = true
        
        let cell = tableView.cellForRow(at: indexPath)!
        
        UIView.animate(withDuration: 0.2, animations: {
            
            cell.alpha = 0
            
        }) { _ in
            
            UIView.animate(withDuration: 0.2, animations: {
                
                cell.alpha = 1
                
            })
            
        }
        
        self.showButtonView()
        
     }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if ableToDelete {
            
            return true
            
        } else {
            
            return false
            
        }
        
     }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            print("edit button tapped")
            
            self.wallet = self.addressBook[editActionsForRowAt.section]
            self.editWalletButton()
            
         }
        
        edit.backgroundColor = .orange
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            print("delete button tapped")
            
            func deleteCell() {
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: "WARNING!", message: "You will lose this wallet FOREVER if you delete it, please ensure you have it backed up first.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (action) in
                        
                        let indexSet = IndexSet(integer: editActionsForRowAt.section)
                        self.removeWallet(address: self.addressBook[editActionsForRowAt.section]["address"] as! String)
                        self.addressBook.remove(at: editActionsForRowAt.section)
                        tableView.deleteSections(indexSet, with: .fade)
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                        
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            
          func authenticateDeleteWithTouchID() {
                
                let localAuthenticationContext = LAContext()
                localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
                
                var authError: NSError?
                let reasonString = "To Delete a Wallet"
                
                if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                    
                    localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                        
                        if success {
                            
                            deleteCell()
                            
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
            
            if UserDefaults.standard.object(forKey: "bioMetricsEnabled") != nil {
                
                authenticateDeleteWithTouchID()
                
            } else if let _ = KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
                
                var password = String()
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Please input your password", message: "Please enter your password to delete a wallet", preferredStyle: .alert)
                    
                    alert.addTextField { (textField1) in
                        
                        textField1.placeholder = "Enter Password"
                        textField1.isSecureTextEntry = true
                        
                    }
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (action) in
                        
                        password = alert.textFields![0].text!
                        
                        if password == KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
                            
                            deleteCell()
                            
                        } else {
                            
                            displayAlert(viewController: self, title: "Error", message: "Incorrect password!")
                        }
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                        
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
            } else {
                
                deleteCell()
                
            }
        }
        delete.backgroundColor = .red
        
        return [delete, edit]
    }
    
    /*func processKeyAndSegue() {
        
        //check if valid if not decrypt
        if let _ = BTCPrivateKeyAddressTestnet.init(string: self.privateKeyToExport) {
            
            self.performSegue(withIdentifier: "exportKeys", sender: self)
            
        } else if let _ = BTCPrivateKeyAddress.init(string: self.privateKeyToExport) {
            
            self.performSegue(withIdentifier: "exportKeys", sender: self)
            
        } else {
            
            if self.privateKeyToExport != "" {
                
                let password = KeychainWrapper.standard.string(forKey: "AESPassword")!
                let decrypted = AES256CBC.decryptString(self.privateKeyToExport, password: password)!
                self.privateKeyToExport = decrypted
                self.performSegue(withIdentifier: "exportKeys", sender: self)
                
            } else {
                
                self.performSegue(withIdentifier: "exportKeys", sender: self)
                
            }
            
            
            
        }
    }*/
    
    func checkBalance(address: String, index: Int, network: String, type: String) {
        print("checkBalance")
        
        ableToDelete = false
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
                                
                                if let dataCheck = jsonAddressResult["data"] as? NSArray {
                                    
                                    if let dictCheck = dataCheck[0] as? NSDictionary {
                                        
                                        for (key, value) in dictCheck {
                                            
                                            if key as! String == "sum_value_unspent" {
                                                
                                                if let btcAmountCheck = value as? String {
                                                    
                                                    let btcAmount = Double(btcAmountCheck)!.avoidNotation
                                                    let satAmount = (Double(btcAmountCheck)! * 100000000).withCommas()
                                                    
                                                    if self.currency == "SAT" {
                                                        self.addressBook[index]["balance"] = satAmount + " SAT"
                                                    } else {
                                                        self.addressBook[index]["balance"] = btcAmount + " BTC"
                                                    }
                                                    
                                                    self.addressBook[index]["fiatBalance"] = self.convertBTCtoCurrency(btcAmount: btcAmount, exchangeRate: self.exchangeRate)
                                                    
                                                    let indexPath = IndexPath(item: 0, section: index)
                                                    DispatchQueue.main.async {
                                                        self.addressBookTable.reloadRows(at: [indexPath], with: .none)
                                                    }
                                                    
                                                    
                                                    DispatchQueue.main.async {
                                                        
                                                        self.removeSpinner()
                                                        
                                                    }
                                                }
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
                                    let satAmount = finalBalanceCheck.withCommas()
                                    
                                    if self.currency == "SAT" {
                                        self.addressBook[index]["balance"] = satAmount + " SAT"
                                    } else {
                                        self.addressBook[index]["balance"] = btcAmount + " BTC"
                                    }
                                    
                                    self.addressBook[index]["fiatBalance"] = self.convertBTCtoCurrency(btcAmount: btcAmount, exchangeRate: self.exchangeRate)
                                    
                                    let indexPath = IndexPath(item: 0, section: index)
                                    DispatchQueue.main.async {
                                        self.addressBookTable.reloadRows(at: [indexPath], with: .none)
                                    }
                                    
                                    DispatchQueue.main.async {
                                        
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
                                
                                if let finalBalanceCheck = jsonAddressResult["balance"] as? Double {
                                    
                                    btcAmount = (finalBalanceCheck / 100000000).avoidNotation
                                    let satAmount = finalBalanceCheck.withCommas()
                                    
                                    if self.currency == "SAT" {
                                        self.addressBook[index]["balance"] = satAmount + " SAT"
                                    } else {
                                        self.addressBook[index]["balance"] = btcAmount + " BTC"
                                    }
                                    
                                    self.addressBook[index]["fiatBalance"] = self.convertBTCtoCurrency(btcAmount: btcAmount, exchangeRate: self.exchangeRate)
                                    
                                    let indexPath = IndexPath(item: 0, section: index)
                                    DispatchQueue.main.async {
                                        self.addressBookTable.reloadRows(at: [indexPath], with: .none)
                                    }
                                    
                                    DispatchQueue.main.async {
                                        
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
            
            url = NSURL(string: "https://api.blockcypher.com/v1/btc/test3/addrs/\(address)/balance?token=a9d88ea606fb4a92b5134d34bc1cb2a0")
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
            self.ableToDelete = true
            
        }
    }
    
    func removeWallet(address: String) {
        
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
                
                for (index, data) in results.enumerated() {
                    
                    if address == data.value(forKey: "address") as? String {
                            
                        context.delete(results[index] as NSManagedObject)
                        print("deleted succesfully")
                        
                        do {
                            
                            try context.save()
                            
                        } catch {
                            
                            print("error deleting")
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
    
    
    func authenticationWithTouchID(item: String) {
        
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
        
        var authError: NSError?
        var reasonString = "To Export a Secret"
        
        if self.editWalletMode {
            
            reasonString = "To edit a wallet"
        }
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    if self.editWalletMode {
                        
                        self.editNow()
                        
                        self.editWalletMode = false
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            
                            let descriptor = self.walletToExport["descriptor"] as! String
                            
                            func getSecret() {
                                
                                let decryptedItem = self.decrypt(item: item)
                                
                                if decryptedItem != "" {
                                    
                                    self.walletToExport["stringToExport"] = decryptedItem
                                    self.performSegue(withIdentifier: "exportKeys", sender: self)
                                }
                            }
                            
                            switch descriptor {
                            case "redemptionScript": self.performSegue(withIdentifier: "exportKeys", sender: self)
                            default:getSecret()
                            }
                            
                        }
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
    
    func addHomeScreen() {
        print("addHomeScreen")
        
        DispatchQueue.main.async {
            
            let modelName = UIDevice.modelName
            
            if self.imageView != nil {
                self.imageView.removeFromSuperview()
            }
            
            self.transactionsButton.removeFromSuperview()
            self.transactionsButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 60, y: self.bottomView.frame.minY - 55, width: 50, height: 50))
            if modelName == "iPhone X" {
                self.transactionsButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 60, y: self.bottomView.frame.minY - 70, width: 55, height: 50))
            }
            self.transactionsButton.showsTouchWhenHighlighted = true
            self.transactionsButton.layer.cornerRadius = 10
            self.transactionsButton.backgroundColor = UIColor.clear
            self.transactionsButton.titleLabel?.textAlignment = .right
            addShadow(view:self.transactionsButton)
            self.transactionsButton.setTitle("Pay", for: .normal)
            self.transactionsButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 25)
            self.transactionsButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            
            self.newAddressButton.removeFromSuperview()
            self.newAddressButton = UIButton(frame: CGRect(x: 5, y: self.bottomView.frame.minY - 55, width: 100, height: 50))//CGRect(x: self.view.frame.maxX - 110, y: self.view.frame.maxY - (58*2), width: 100, height: 50))
            if modelName == "iPhone X" {
                self.newAddressButton = UIButton(frame: CGRect(x: 5, y: self.bottomView.frame.minY - 70, width: 100, height: 50))//CGRect(x: self.view.frame.maxX - 110, y: self.bottomView.frame.minY - 70, width: 100, height: 50))
            }
            self.newAddressButton.showsTouchWhenHighlighted = true
            self.newAddressButton.titleLabel?.textAlignment = .left
            self.newAddressButton.layer.cornerRadius = 10
            self.newAddressButton.backgroundColor = UIColor.clear
            addShadow(view:self.newAddressButton)
            self.newAddressButton.setTitle("Receive", for: .normal)
            self.newAddressButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 25)
            self.newAddressButton.addTarget(self, action: #selector(self.newAddress), for: .touchUpInside)
            
            self.settingsGenButton.removeFromSuperview()
            self.settingsGenButton = UIButton(frame: CGRect(x: 5, y: 18, width: 40, height: 40))
            if modelName == "iPhone X" {
                self.settingsGenButton = UIButton(frame: CGRect(x: 5, y: 28, width: 40, height: 40))
            }
            self.settingsGenButton.showsTouchWhenHighlighted = true
            self.settingsGenButton.setImage(#imageLiteral(resourceName: "settings2.png"), for: .normal)
            self.settingsGenButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            
            let priceButton = UIButton(frame: CGRect(x: (self.view.center.x - (40/2)) - (self.view.frame.width / 2.5 - (40/2)) - 5, y: 10/*16*/, width: 30, height: 30))
            if modelName == "iPhone X" {
                priceButton.frame = CGRect(x: (self.view.center.x - (40/2)) - (self.view.frame.width / 2.5 - (40/2)) - 5, y: 10/*36*/, width: 30, height: 30)
            }
            priceButton.showsTouchWhenHighlighted = true
            priceButton.layer.cornerRadius = 28
            priceButton.setImage(#imageLiteral(resourceName: "whiteQR.png"), for: .normal)
            priceButton.addTarget(self, action: #selector(self.gotocheckbalance), for: .touchUpInside)
            
            
            let toolboxButton = UIButton(frame: CGRect(x: (self.view.center.x - (40/2)) - (self.view.frame.width / 6 - (40/2)) - 5, y: 10/*20*/, width: 35, height: 35))
            if modelName == "iPhone X" {
                toolboxButton.frame = CGRect(x: (self.view.center.x - (40/2)) - (self.view.frame.width / 6 - (40/2)) - 5, y: 10/*40*/, width: 35, height: 35)
            }
            toolboxButton.showsTouchWhenHighlighted = true
            toolboxButton.layer.cornerRadius = 28
            toolboxButton.setImage(#imageLiteral(resourceName: "whiteKey.png"), for: .normal)
            toolboxButton.addTarget(self, action: #selector(self.gotokeytools), for: .touchUpInside)
            
            self.lockButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) + (self.view.frame.width / 6 - (35/2)) + 5, y: 10/*20*/, width: 35, height: 35))
            if modelName == "iPhone X" {
                self.lockButton.frame = CGRect(x: (self.view.center.x - (35/2)) + (self.view.frame.width / 6 - (35/2)) + 5, y: 10/*40*/, width: 35, height: 35)
            }
            self.lockButton.showsTouchWhenHighlighted = true
            self.lockButton.layer.cornerRadius = 28
            if KeychainWrapper.standard.string(forKey: "unlockAESPassword") != nil {
                self.lockButton.setImage(#imageLiteral(resourceName: "whiteLock.png"), for: .normal)
            } else {
                self.lockButton.setImage(#imageLiteral(resourceName: "whiteUnlocked.png"), for: .normal)
                self.getLockingPassword()
            }
            self.lockButton.addTarget(self, action: #selector(self.gotosecuritysettings), for: .touchUpInside)
            
            let addressBookButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) + (self.view.frame.width / 2.5 - (35/2)) + 5, y: 10, width: 35, height: 35))
            if modelName == "iPhone X" {
                addressBookButton.frame = CGRect(x: (self.view.center.x - (35/2)) + (self.view.frame.width / 2.5 - (35/2)) + 5, y: 10, width: 35, height: 35)
            }
            addressBookButton.showsTouchWhenHighlighted = true
            addressBookButton.layer.cornerRadius = 28
            addressBookButton.setImage(#imageLiteral(resourceName: "Add Pin - Trip key.png"), for: .normal)
            addressBookButton.addTarget(self, action: #selector(self.add), for: .touchUpInside)
            
            self.infoButton.removeFromSuperview()
            self.infoButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 45, y: 18, width: 38, height: 38))
            if modelName == "iPhone X" {
                self.infoButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 45, y: 28, width: 38, height: 38))
            }
            self.infoButton.showsTouchWhenHighlighted = true
            self.infoButton.layer.cornerRadius = 28
            self.infoButton.setImage(#imageLiteral(resourceName: "help2.png"), for: .normal)
            self.infoButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            self.view.addSubview(self.transactionsButton)
            self.view.addSubview(self.newAddressButton)
            self.view.addSubview(self.settingsGenButton)
            self.bottomView.addSubview(priceButton)
            self.bottomView.addSubview(toolboxButton)
            self.bottomView.addSubview(self.lockButton)
            self.bottomView.addSubview(addressBookButton)
            self.view.addSubview(self.infoButton)
            
        }
        
    }
    
    @objc func gotokeytools() {
        
        self.showKeyManagementAlert()
    }
    
    @objc func gotosecuritysettings() {
        
        self.performSegue(withIdentifier: "securitySettings", sender: self)
    }
    
    @objc func gotocheckbalance() {
        
        self.performSegue(withIdentifier: "goCheckBalances", sender: self)
    }
    
    func getLockingPassword() {
        
        DispatchQueue.main.async {
            var firstPassword = String()
            var secondPassword = String()
            
            let alert = UIAlertController(title: "Protect your wallet by setting a password that locks and unlocks it.", message: "Please do not forget this password, you will need it to spend your Bitcoin, this is not mandatory but is highly recommended, you can do it later if you want.", preferredStyle: .alert)
            
            alert.addTextField { (textField1) in
                
                textField1.placeholder = "Add Password"
                textField1.isSecureTextEntry = true
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .destructive, handler: { (action) in
                
                firstPassword = alert.textFields![0].text!
                
                let confirmationAlert = UIAlertController(title: "Confirm Password", message: "Please input your password again to make sure there were no typos.", preferredStyle: .alert)
                
                confirmationAlert.addTextField { (textField1) in
                    
                    textField1.placeholder = "Confirm Password"
                    textField1.isSecureTextEntry = true
                    
                }
                
                confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: { (action) in
                    
                    secondPassword = confirmationAlert.textFields![0].text!
                    
                    if firstPassword == secondPassword {
                        
                        let saveSuccessful:Bool = KeychainWrapper.standard.set(secondPassword, forKey: "unlockAESPassword")
                        
                        if saveSuccessful {
                            
                            let retrievedPassword: String? = KeychainWrapper.standard.string(forKey: "unlockAESPassword")
                            print("unlockAESPassword is: \(retrievedPassword!)")
                            
                            displayAlert(viewController: self, title: "Success", message: "You have set your locking/unlocking password.")
                            
                        } else {
                            
                            displayAlert(viewController: self, title: "Error", message: "Unable to save password to keychain, please try again.")
                            
                        }
                        
                    } else {
                        
                        displayAlert(viewController: self, title: "Error", message: "Passwords did not match please start over.")
                        
                    }
                    
                }))
                
                confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                    
                }))
                
                self.present(confirmationAlert, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @objc func newAddress() {
        print("newAddress")
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        addressBook = checkAddressBook()
        let aespassword = KeychainWrapper.standard.string(forKey: "AESPassword")!
        var network = ""
        var address = ""
        
        if addressBook.count > 0 {
            
            self.wallet = addressBook[addressBook.count - 1]
            network = self.wallet["network"] as! String
            address = self.wallet["address"] as! String
            
        }
        
        if addressBook.count == 1 {
            
            if let xpub = self.wallet["xpub"] as? String {
                
                if xpub != "" {
                    
                    if let decryptedXpub = AES256CBC.decryptString(xpub, password: aespassword) {
                        
                        if let index = self.wallet["index"] as? UInt32 {
                            
                            self.createInvoiceforHD(network: network, address: address, index: index + 1, xpub: decryptedXpub)
                            
                        }
                        
                    } else {
                        
                        displayAlert(viewController: self, title: "Error", message: "Error decrypting your xpub.")
                    }
                    
                } else {
                    
                    self.HDAddress = self.wallet["address"] as! String
                    self.createWalletInvoice()
                }
                
            }
            
        } else if addressBook.count > 1 {
            
            DispatchQueue.main.async {
                
                    let alert = UIAlertController(title: "Which Wallet?", message: "Please select which wallet you'd like to receive to", preferredStyle: UIAlertControllerStyle.actionSheet)
                    
                    for (index, wallet) in self.addressBook.enumerated() {
                        
                        var walletName = wallet["label"] as! String
                        
                        if walletName == "" {
                            
                            walletName = wallet["address"] as! String
                        }
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString(walletName, comment: ""), style: .default, handler: { (action) in
                            
                            print("wallet = \(wallet)")
                            self.wallet = wallet
                            
                            if let xpub = wallet["xpub"] as? String {
                                
                                if xpub != "" {
                                    
                                    if let decryptedXpub = AES256CBC.decryptString(xpub, password: aespassword) {
                                        
                                        if let index = self.wallet["index"] as? UInt32 {
                                            
                                            self.createInvoiceforHD(network: network, address: address, index: index + 1, xpub: decryptedXpub)
                                            
                                        }
                                        
                                    } else {
                                        
                                        displayAlert(viewController: self, title: "Error", message: "Error decrypting your xpub.")
                                    }
                                    
                                } else {
                                    
                                    self.wallet = wallet
                                    self.HDAddress = wallet["address"] as! String
                                    self.createWalletInvoice()
                                }
                                
                            } else {
                                
                                self.wallet = wallet
                                self.HDAddress = wallet["address"] as! String
                                self.createWalletInvoice()
                            }
                            
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
        
    }
    
}
