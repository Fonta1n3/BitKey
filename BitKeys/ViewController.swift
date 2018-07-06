//
//  ViewController.swift
//  BitKeys
//
//  Created by Peter on 11/27/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit
import AES256CBC
import BigInt
import AVFoundation
import CoreData
import LocalAuthentication
import SwiftKeychainWrapper

class ViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var myLabel = UILabel()
    var uploadButton = UIButton()
    let imagePicker = UIImagePickerController()
    let qrimageview = UIImageView()
    var walletName = String()
    var textToShare = String()
    var filename = String()
    var recoveryMode = Bool()
    var videoPreview:UIView!
    let avCaptureSession = AVCaptureSession()
    var stringURL = String()
    var password = ""
    var exportPrivateKeyFromTable = Bool()
    var exportAddressFromTable = Bool()
    var testnetMode = Bool()
    var mainnetMode = Bool()
    var addressMode = Bool()
    var coldMode = Bool()
    var hotMode = Bool()
    var legacyMode = Bool()
    var segwitMode = Bool()
    var addressBookButton = UIButton()
    var infoButton = UIButton()
    var priceButton = UIButton()
    var lockButton = UIButton()
    var scanQRCodeButton = UIButton()
    var toolboxButton = UIButton()
    var settingsButton = UIButton()
    var diceMode = Bool()
    @IBOutlet var scrollView: UIScrollView!
    var privateKeyQRCode:UIImage!
    var privateKeyQRView:UIImageView!
    var privateKeyImage:UIImage!
    var recoveryPhraseQRView:UIImageView!
    var recoveryPhraseImage:UIImage!
    var imageView:UIView!
    var numberArray:[String] = []
    var joinedArray:String!
    var bitField = UITextView()
    var myField: UITextView!
    var mnemonicView: UITextView!
    var button = UIButton(type: .custom)
    var bitcoinAddressButton = UIButton(type: .custom)
    var backUpButton = UIButton(type: .custom)
    var checkAddressButton = UIButton(type: .custom)
    var privateKeyText:String!
    var bitcoinAddress:String!
    var privateKeyMode:Bool!
    var segwitAddressMode:Bool!
    var legacyAddressMode:Bool!
    var mayerMultipleButton = UIButton(type: .custom)
    var diceButton = UIButton()
    var transactionsButton = UIButton()
    var parseBitResult = BigInt()
    var bitArray = [String]()
    var zero = 0
    let segwit = SegwitAddrCoder()
    var words = ""
    var privateKeyTitle = UILabel()
    var WIFprivateKeyFieldLabel = UILabel()
    var mnemonicLabel = UILabel()
    var legacyAddress = String()
    var recoveryPhrase = String()
    var recoveryPhraseLabel = UILabel()
    var privateKeyWIF = String()
    var importButton = UIButton()
    var inputMnemonic = UITextField()
    var inputPassword = UITextField()
    var outputMnemonic = UITextView()
    var wordArray = [String]()
    var importAction = UIButton()
    var listArray = [String]()
    var hideExplanation:Bool!
    var diceArray = [UIButton]()
    var tappedIndex = Int()
    var randomBits = [String]()
    var percentageLabel = UILabel()
    var joinedBits = String()
    var bitCount:Int! = 0
    var clearButton = UIButton()
    var newAddressButton = UIButton()
    var watchOnlyMode = Bool()
    var clearMnemonicButton = UIButton()
    var addressBook: [[String: Any]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        let imageView = UIImageView()
        imageView.image = UIImage(named:"background.jpg")
        imageView.frame = self.view.frame
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.alpha = 0.05
        self.view.addSubview(imageView)
        diceMode = false
        inputMnemonic.delegate = self
        inputPassword.delegate = self
        privateKeyMode = true
        addHomeScreen()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        inputMnemonic.resignFirstResponder()
        inputPassword.resignFirstResponder()
        //amountToSend.resignFirstResponder()
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        
        if self.diceMode {
            
          self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 3700)
            
        } else if watchOnlyMode {
            
            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 1000)
           
        } else {
            
            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 1500)
        }
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
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
            
        }
        
        if UserDefaults.standard.object(forKey: "hideExplanation") != nil {
            
            self.hideExplanation = UserDefaults.standard.bool(forKey: "hideExplanation")
            
        } else {
            
            self.hideExplanation = false
            
        }
        
        addressBook = checkAddressBook()
        
        hotMode = checkSettingsForKey(keyValue: "hotMode")
        coldMode = checkSettingsForKey(keyValue: "coldMode")
        legacyMode = checkSettingsForKey(keyValue: "legacyMode")
        segwitMode = checkSettingsForKey(keyValue: "segwitMode")
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
        
        
       words = ""
        
        if exportPrivateKeyFromTable {
            
            self.showPrivateKeyAndAddressQRCodes()
            self.exportPrivateKeyFromTable = false
            
        } else if exportAddressFromTable {
            
            print("exportAddressFromTable")
            
            self.watchOnlyMode = true
            
            for key in self.addressBook {
                
                if key["address"] as! String == self.bitcoinAddress {
                    
                    let walletName = key["label"] as! String
                    self.showAddressQRCodes(walletName: walletName)
                    
                } else if key["redemptionScript"] as! String == self.bitcoinAddress {
                    
                    let walletName = key["label"] as! String
                    self.showAddressQRCodes(walletName: walletName)
                    
                }
                
            }
            
            self.exportAddressFromTable = false
            
        }
        
        if UserDefaults.standard.object(forKey: "wif") != nil {
           
            ensureBackwardsCompatibility()
            
        }
        
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
                            
                            saveWallet(viewController: self, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot")
                            
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
                            
                            saveWallet(viewController: self, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "testnet", type: "hot")
                            
                            //self.addressBook = checkAddressBook()
                            
                        }
                        
                    }
                    
                }
                    
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
            
        
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.inputPassword {
            
            self.password = self.inputPassword.text!
            print("self.password = \(self.password)")
            
        }
    }
    
    @objc func importMnemonic() {
        print("importMnemonic")
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.importButton.removeFromSuperview()
        self.recoveryPhrase = ""
        self.wordArray.removeAll()
        self.words = ""
        self.listArray.removeAll()
        self.outputMnemonic.text = ""
        self.inputPassword.text = ""
        
       if isInternetAvailable() {
            
            DispatchQueue.main.async {
                displayAlert(viewController: self, title: "Security Alert", message: "You are connected to the internet, for maximum security please enable airplane mode before you enter your recovery phrase.")
            }
        }
        
        
        self.removeHomeScreen()
        
        self.inputPassword.frame = CGRect(x: self.view.frame.minX + 5, y: 100, width: self.view.frame.width - 10, height: 50)
        self.inputPassword.textAlignment = .center
        self.inputPassword.borderStyle = .roundedRect
        self.inputPassword.autocapitalizationType = .none
        self.inputPassword.autocorrectionType = .no
        self.inputPassword.isSecureTextEntry = true
        self.inputPassword.placeholder = "Password (Optional)"
        self.inputPassword.backgroundColor = UIColor.groupTableViewBackground
        self.inputPassword.returnKeyType = UIReturnKeyType.next
        self.inputPassword.spellCheckingType = .no
        self.view.addSubview(self.inputPassword)
        
        self.inputMnemonic.frame = CGRect(x: self.view.frame.minX + 5, y: self.inputPassword.frame.maxY + 10, width: self.view.frame.width - 10, height: 50)
        self.inputMnemonic.textAlignment = .center
        self.inputMnemonic.borderStyle = .roundedRect
        self.inputMnemonic.autocapitalizationType = .none
        self.inputMnemonic.autocorrectionType = .no
        self.inputMnemonic.placeholder = "Type each word one by one"
        self.inputMnemonic.backgroundColor = UIColor.groupTableViewBackground
        self.inputMnemonic.returnKeyType = UIReturnKeyType.next
        self.inputMnemonic.spellCheckingType = .no
        self.view.addSubview(self.inputMnemonic)
        self.inputMnemonic.becomeFirstResponder()
        
        self.outputMnemonic.frame = CGRect(x: self.view.frame.minX + 5, y: self.inputMnemonic.frame.maxY + 100, width: self.view.frame.width - 10, height: 200)
        self.outputMnemonic.textAlignment = .left
        self.outputMnemonic.isEditable = false
        self.outputMnemonic.backgroundColor = UIColor.clear
        self.outputMnemonic.font = UIFont.init(name: "HelveticaNeue-Bold", size: 22)
        self.outputMnemonic.returnKeyType = UIReturnKeyType.done
        self.view.addSubview(self.outputMnemonic)
        
        self.addBackButton()
        self.addImportActionButton()
        self.addScanQRCodeButton()
        self.addClearMnemonicButton()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        
        let noSpaces = self.inputMnemonic.text!.replacingOccurrences(of: " ", with: "")
        self.wordArray.append(noSpaces.lowercased())
        self.listArray.append(noSpaces.lowercased() + "  ")
        self.outputMnemonic.text = self.listArray.joined()
        self.inputMnemonic.text = ""
        return false
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing")
        return true
    }
    
    func parseBinary(binary: String) -> BigInt? {
        
        var result:BigInt = 0
        
        for digit in binary {
            
            switch(digit) {
            case "0":result = result * 2
            case "1":result = result * 2 + 1
            default: return nil
                
            }
            
        }
        
        return result
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.zero = 0
        self.bitArray.removeAll()
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    
    func addHomeScreen() {
        print("addHomeScreen")
        
        DispatchQueue.main.async {
            
            let modelName = UIDevice.modelName
            
            self.bitField.frame = self.view.frame
            self.bitField.isUserInteractionEnabled = false
            self.view.addSubview(self.bitField)
            
            let imageView = UIImageView()
            imageView.image = UIImage(named:"background.jpg")
            imageView.frame = self.bitField.frame
            imageView.contentMode = UIViewContentMode.scaleAspectFill
            imageView.alpha = 0.05
            self.bitField.addSubview(imageView)
            
            
            if self.imageView != nil {
                self.imageView.removeFromSuperview()
            }
            
            let bitcoinImage = UIImage(named: "Bitsense image.png")
            self.imageView = UIImageView(image: bitcoinImage!)
            self.imageView.center = self.view.center
            self.imageView.frame = CGRect(x: self.view.center.x - 100, y: self.view.center.y - 100, width: 200, height: 200)
            let bitcoinDragged = UIPanGestureRecognizer(target: self, action: #selector(self.userCreatesRandomness(gestureRecognizer:)))
            bitcoinDragged.delegate = self
            self.imageView.isUserInteractionEnabled = true
            self.imageView.addGestureRecognizer(bitcoinDragged)
            addShadow(view:self.imageView)
            
            self.checkAddressButton.removeFromSuperview()
            self.checkAddressButton = UIButton(frame: CGRect(x: 5, y: self.view.frame.maxY - 55, width: 85, height: 50))
            if modelName == "iPhone X" {
                self.checkAddressButton = UIButton(frame: CGRect(x: 5, y: self.view.frame.maxY - 85, width: 85, height: 50))
            }
            self.checkAddressButton.showsTouchWhenHighlighted = true
            self.checkAddressButton.layer.cornerRadius = 10
            self.checkAddressButton.backgroundColor = UIColor.black
            addShadow(view:self.checkAddressButton)
            self.checkAddressButton.setTitle("Balance", for: .normal)
            self.checkAddressButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 18)
            self.checkAddressButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            
            self.transactionsButton.removeFromSuperview()
            self.transactionsButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 90, y: self.view.frame.maxY - 55, width: 85, height: 50))
            if modelName == "iPhone X" {
                self.transactionsButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 90, y: self.view.frame.maxY - 85, width: 85, height: 50))
            }
            self.transactionsButton.showsTouchWhenHighlighted = true
            self.transactionsButton.layer.cornerRadius = 10
            self.transactionsButton.backgroundColor = UIColor.black
            addShadow(view:self.transactionsButton)
            self.transactionsButton.setTitle("Pay", for: .normal)
            self.transactionsButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 18)
            self.transactionsButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            
            self.newAddressButton.removeFromSuperview()
            self.newAddressButton = UIButton(frame: CGRect(x: self.view.center.x - (85/2), y: self.view.frame.maxY - 55, width: 85, height: 50))
            if modelName == "iPhone X" {
                self.newAddressButton = UIButton(frame: CGRect(x: self.view.center.x - (85/2), y: self.view.frame.maxY - 85, width: 85, height: 50))
            }
            self.newAddressButton.showsTouchWhenHighlighted = true
            self.newAddressButton.titleLabel?.textAlignment = .center
            self.newAddressButton.layer.cornerRadius = 10
            self.newAddressButton.backgroundColor = UIColor.black
            addShadow(view:self.newAddressButton)
            self.newAddressButton.setTitle("Receive", for: .normal)
            self.newAddressButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 18)
            self.newAddressButton.addTarget(self, action: #selector(self.newAddress), for: .touchUpInside)
            
            
            self.settingsButton.removeFromSuperview()
            self.settingsButton = UIButton(frame: CGRect(x: 5, y: 20, width: 45, height: 45))
            if modelName == "iPhone X" {
                self.settingsButton = UIButton(frame: CGRect(x: 5, y: 40, width: 45, height: 45))
            }
            self.settingsButton.showsTouchWhenHighlighted = true
            self.settingsButton.layer.cornerRadius = 28
            self.settingsButton.setImage(#imageLiteral(resourceName: "settings2.png"), for: .normal)
            self.settingsButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            
            
            self.priceButton.removeFromSuperview()
            self.priceButton = UIButton(frame: CGRect(x: (self.view.center.x - (40/2)) - (self.view.frame.width / 3.25 - (40/2)) - 5, y: 16, width: 50, height: 50))
            if modelName == "iPhone X" {
                self.priceButton = UIButton(frame: CGRect(x: (self.view.center.x - (40/2)) - (self.view.frame.width / 3.25 - (40/2)) - 5, y: 36, width: 50, height: 50))
            }
            self.priceButton.showsTouchWhenHighlighted = true
            self.priceButton.layer.cornerRadius = 28
            self.priceButton.setImage(#imageLiteral(resourceName: "price.png"), for: .normal)
            self.priceButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            
            
            self.toolboxButton.removeFromSuperview()
            self.toolboxButton = UIButton(frame: CGRect(x: (self.view.center.x - (40/2)) - (self.view.frame.width / 8 - (40/2)) - 5, y: 20, width: 40, height: 40))
            if modelName == "iPhone X" {
                self.toolboxButton = UIButton(frame: CGRect(x: (self.view.center.x - (40/2)) - (self.view.frame.width / 8 - (40/2)) - 5, y: 40, width: 40, height: 40))
            }
            self.toolboxButton.showsTouchWhenHighlighted = true
            self.toolboxButton.layer.cornerRadius = 28
            self.toolboxButton.setImage(#imageLiteral(resourceName: "keys.png"), for: .normal)
            self.toolboxButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            
            self.lockButton.removeFromSuperview()
            self.lockButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) + (self.view.frame.width / 8 - (35/2)) + 5, y: 20, width: 35, height: 35))
            if modelName == "iPhone X" {
                self.lockButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) + (self.view.frame.width / 8 - (35/2)) + 5, y: 40, width: 35, height: 35))
            }
            self.lockButton.showsTouchWhenHighlighted = true
            self.lockButton.layer.cornerRadius = 28
            self.lockButton.setImage(#imageLiteral(resourceName: "lock.jpg"), for: .normal)
            self.lockButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            
            self.addressBookButton.removeFromSuperview()
            self.addressBookButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) + (self.view.frame.width / 3.25 - (35/2)) + 5, y: 22, width: 35, height: 35))
            if modelName == "iPhone X" {
                self.addressBookButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) + (self.view.frame.width / 3.25 - (35/2)) + 5, y: 42, width: 35, height: 35))
            }
            self.addressBookButton.showsTouchWhenHighlighted = true
            self.addressBookButton.layer.cornerRadius = 28
            self.addressBookButton.setImage(#imageLiteral(resourceName: "addressBook.png"), for: .normal)
            self.addressBookButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            
            self.infoButton.removeFromSuperview()
            self.infoButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 50, y: 20, width: 45, height: 45))
            if modelName == "iPhone X" {
                self.infoButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 50, y: 40, width: 45, height: 45))
            }
            self.infoButton.showsTouchWhenHighlighted = true
            self.infoButton.layer.cornerRadius = 28
            self.infoButton.setImage(#imageLiteral(resourceName: "help2.png"), for: .normal)
            self.infoButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            
            
            self.view.addSubview(self.imageView)
            self.view.addSubview(self.checkAddressButton)
            self.view.addSubview(self.transactionsButton)
            self.view.addSubview(self.newAddressButton)
            self.view.addSubview(self.settingsButton)
            self.view.addSubview(self.priceButton)
            self.view.addSubview(self.toolboxButton)
            self.view.addSubview(self.lockButton)
            self.view.addSubview(self.addressBookButton)
            self.view.addSubview(self.infoButton)
            
        }
        
    }
    
    func removeHomeScreen() {
        print("removeHomeScreen")
        
        DispatchQueue.main.async {
            
            self.addressBookButton.removeFromSuperview()
            self.priceButton.removeFromSuperview()
            self.lockButton.removeFromSuperview()
            self.toolboxButton.removeFromSuperview()
            self.infoButton.removeFromSuperview()
            self.newAddressButton.removeFromSuperview()
            self.importButton.removeFromSuperview()
            self.transactionsButton.removeFromSuperview()
            self.diceButton.removeFromSuperview()
            self.checkAddressButton.removeFromSuperview()
            self.settingsButton.removeFromSuperview()
            self.bitField.removeFromSuperview()
            self.imageView.removeFromSuperview()
            
        }
        
    }
    
    @objc func userCreatesRandomness(gestureRecognizer: UIPanGestureRecognizer) {
        
            self.addressBookButton.removeFromSuperview()
            self.toolboxButton.removeFromSuperview()
            self.priceButton.removeFromSuperview()
            self.lockButton.removeFromSuperview()
            self.infoButton.removeFromSuperview()
            self.checkAddressButton.removeFromSuperview()
            self.diceButton.removeFromSuperview()
            self.transactionsButton.removeFromSuperview()
            self.importButton.removeFromSuperview()
            self.newAddressButton.removeFromSuperview()
            self.settingsButton.removeFromSuperview()
            
            let translation = gestureRecognizer.translation(in: view)
            let bitcoinView = gestureRecognizer.view!
            bitcoinView.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
            let xFromCenter = bitcoinView.center.x - self.view.bounds.width / 2
            numberArray.append(String(describing: abs(Int(xFromCenter))))
            var shuffledArray = self.numberArray.shuffled()
            var joinedArray = shuffledArray.joined()
            var evenNumbersToZeros = joinedArray.replacingOccurrences(of: "[2468]", with: "0", options: .regularExpression, range: nil)
            var allToBits = evenNumbersToZeros.replacingOccurrences(of: "[3579]", with: "1", options: .regularExpression, range: nil)
            self.bitField.text = allToBits
            self.bitField.font = UIFont.init(name: "HelveticaNeue-Light", size: 25)
            self.bitField.alpha = 0.25
        
            if gestureRecognizer.state == UIGestureRecognizerState.began {
                DispatchQueue.main.async {
                    rotateAnimation(imageView: self.imageView as! UIImageView)
                }
            }
            
            if allToBits.count > 800 {
                
                self.imageView.alpha = 0
            }
            
            if gestureRecognizer.state == UIGestureRecognizerState.ended {
                
                if allToBits.count < 800 {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        bitcoinView.center =  self.view.center
                        
                    }, completion: { _ in
                        
                        DispatchQueue.main.async {
                            
                            let alert = UIAlertController(title: "Keep Going!", message: "Please move the Bitcoin around more so we have a large enough number to generate a private key, it should not take more then 10 seconds of your time, this ensures we create a really large really random number that makes your Bitcoin ultra secure.", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                
                            }))
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                                
                                self.removeBitField()
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    })
                    
                } else {
                    
                    self.imageView.removeFromSuperview()
                    
                    for character in allToBits {
                        
                        self.bitArray.append(String(character))
                        
                    }
                    
                    var bit256Array = [String]()
                    
                    for (index, bit) in self.bitArray.enumerated() {
                        
                        if index < 256 {
                            
                            bit256Array.append(bit)
                            
                            if bit256Array.count == 256 {
                                
                                let bits = bit256Array.joined()
                                
                                self.parseBitResult = self.parseBinary(binary: bits)!
                                
                                UIView.animate(withDuration: 0.5, animations: {
                                    
                                    bitcoinView.center =  self.view.center
                                    
                                }, completion: { _ in
                                    
                                    DispatchQueue.main.async {
                                        allToBits = ""
                                        evenNumbersToZeros = ""
                                        self.bitField.text = ""
                                        shuffledArray.removeAll()
                                        joinedArray = ""
                                        self.bitArray.removeAll()
                                        self.numberArray.removeAll()
                                    }
                                    
                                    if self.hotMode {
                                        
                                        self.privateKeyWIF = createPrivateKey(viewController: self, userRandomness: self.parseBitResult).privateKeyAddress
                                        self.bitcoinAddress = createPrivateKey(viewController: self, userRandomness: self.parseBitResult).publicKeyAddress
                                        self.words = createPrivateKey(viewController: self, userRandomness: self.parseBitResult).recoveryPhrase
                                        
                                        if self.privateKeyWIF != "" {
                                            
                                            self.showRecoveryPhraseAndQRCode()
                                            
                                            if isInternetAvailable() {
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    displayAlert(viewController: self, title: "Security Alert", message: "You should only create private keys offline. Please enable airplane mode, turn off wifi and try again.")
                                                }
                                                
                                            }
                                            
                                        } else {
                                            
                                            DispatchQueue.main.async {
                                                
                                                let alert = UIAlertController(title: "There was an error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                    self.removeBitField()
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                            }
                                            
                                        }
                                        
                                    } else {
                                        
                                        self.privateKeyWIF = createPrivateKey(viewController: self, userRandomness: self.parseBitResult).privateKeyAddress
                                        self.bitcoinAddress = createPrivateKey(viewController: self, userRandomness: self.parseBitResult).publicKeyAddress
                                        self.words = createPrivateKey(viewController: self, userRandomness: self.parseBitResult).recoveryPhrase
                                        
                                        if self.privateKeyWIF != "" {
                                            
                                            self.showRecoveryPhraseAndQRCode()
                                            
                                        } else {
                                            
                                            DispatchQueue.main.async {
                                                
                                                let alert = UIAlertController(title: "There was an error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .destructive, handler: { (action) in
                                                    
                                                    self.removeBitField()
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                })
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
        
    }
    
    func removeBitField() {
        
        DispatchQueue.main.async {
            
            self.bitField.text = ""
            self.bitField.removeFromSuperview()
            self.privateKeyQRCode = nil
            self.privateKeyImage = nil
            self.privateKeyTitle.text = ""
            self.imageView.removeFromSuperview()
            self.imageView = nil
            self.button.removeFromSuperview()
            self.backUpButton.removeFromSuperview()
            self.numberArray.removeAll()
            self.joinedArray = ""
            self.privateKeyText = ""
            self.zero = 0
            self.bitArray.removeAll()
            self.addHomeScreen()
            
        }
        
        
    }
    
    func showAddressQRCodes(walletName: String) {
        print("addQRCodesAndLabels")
        
        diceMode = false
        self.importAction.removeFromSuperview()
        self.outputMnemonic.removeFromSuperview()
            
        self.privateKeyQRCode = self.generateQrCode(key: self.bitcoinAddress)
        self.privateKeyQRView = UIImageView(image: self.privateKeyQRCode!)
        self.privateKeyQRView.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 70) / 2), y: self.view.center.y - ((self.view.frame.width - 70) / 2), width: self.view.frame.width - 70, height: self.view.frame.width - 70)
        self.privateKeyQRView.alpha = 0
        addShadow(view: self.privateKeyQRView)
        self.view.addSubview(self.privateKeyQRView)
            
       /* self.WIFprivateKeyFieldLabel = UILabel(frame: CGRect(x: self.view.frame.minX + 5, y: self.privateKeyQRView.frame.maxY + 30, width: self.view.frame.width - 10, height: 13))
        
        self.WIFprivateKeyFieldLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 12)
        self.WIFprivateKeyFieldLabel.textColor = UIColor.black
        self.WIFprivateKeyFieldLabel.textAlignment = .left
        self.view.addSubview(self.WIFprivateKeyFieldLabel)*/
            
        UIView.animate(withDuration: 0.5, animations: {
                
            self.imageView.alpha = 0
            //self.bitField.alpha = 0
                
        }, completion: { _ in
                
            self.removeHomeScreen()
                
            UIView.animate(withDuration: 0.5, animations: {
                    
                self.privateKeyQRView.alpha = 1
                    
            }, completion: { _ in
                    
                DispatchQueue.main.async {
                        UIImpactFeedbackGenerator().impactOccurred()
                    //self.WIFprivateKeyFieldLabel.text = "Text Format:"
                    self.privateKeyTitle = UILabel(frame: CGRect(x: self.view.center.x - ((self.view.frame.width - 20) / 2), y: self.privateKeyQRView.frame.minY - 60, width: self.view.frame.width - 20, height: 50))
                    
                    if self.bitcoinAddress.count > 45 {
                        
                        self.privateKeyTitle.text = "Redemption Script"
                        self.filename = "redemptionScript"
                        
                    } else {
                        
                       self.privateKeyTitle.text = "Send Bitcoin to \"\(walletName)\""
                        self.filename = "bitcoinAddress"
                        
                    }
                    
                    self.textToShare = self.bitcoinAddress
                    
                    self.privateKeyTitle.adjustsFontSizeToFitWidth = true
                    self.privateKeyTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 20)
                    self.privateKeyTitle.textColor = UIColor.black
                    self.privateKeyTitle.textAlignment = .center
                    self.view.addSubview(self.privateKeyTitle)
                        
                }
                
                self.myLabel = UILabel (frame:CGRect(x: self.view.center.x - ((self.view.frame.width - 20)/2), y: self.privateKeyQRView.frame.maxY, width: self.view.frame.width - 20, height: 50))
                self.myLabel.textAlignment = .center
                self.myLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 18)
                self.myLabel.text = self.bitcoinAddress
                self.myLabel.adjustsFontSizeToFitWidth = true
                self.view.addSubview(self.myLabel)
                
                    
                /*self.myField = UITextView (frame:CGRect(x: self.view.center.x - ((self.view.frame.width - 10)/2), y: self.WIFprivateKeyFieldLabel.frame.maxY, width: self.view.frame.width - 10, height: 150))
                self.myField.isEditable = false
                self.myField.isSelectable = true
                self.myField.textAlignment = .center
                self.myField.backgroundColor = UIColor.clear
                self.myField.font = UIFont.init(name: "HelveticaNeue-Light", size: 18)
                self.myField.text = self.bitcoinAddress
                self.view.addSubview(self.myField)*/
                self.addHomeButton()
                self.addBackUpButton()
                self.zero = 0
                self.bitArray.removeAll()
                    
            })
                
        })

    }
    
    @objc func importNow() {
        print("importNow")
        
        if let testInputMnemonic = BTCMnemonic.init(words: self.wordArray, password: self.inputPassword.text!, wordListType: BTCMnemonicWordListType.english) {
           
            self.removeHomeScreen()
            self.inputMnemonic.resignFirstResponder()
            self.inputMnemonic.removeFromSuperview()
            self.inputPassword.removeFromSuperview()
            self.scanQRCodeButton.removeFromSuperview()
            self.uploadButton.removeFromSuperview()
            
            let recoveryPhrase = testInputMnemonic.words.description
            let formatMnemonic1 = recoveryPhrase.replacingOccurrences(of: "[", with: "")
            let formatMnemonic2 = formatMnemonic1.replacingOccurrences(of: "]", with: "")
            let formateMnemonic3 = formatMnemonic2.replacingOccurrences(of: "\"", with: "")
            self.words = formateMnemonic3.replacingOccurrences(of: ",", with: "")
            
            let keychain = testInputMnemonic.keychain.derivedKeychain(withPath: "m/44'/0'/0'/0")
            keychain?.key.isPublicKeyCompressed = true
            
            let publicKey = (keychain?.key(at: 0).compressedPublicKey.hex())!
            var addressHD = String()
            
            var network = ""
            
            if testnetMode {
                
                network = "testnet"
                
                self.privateKeyWIF = (keychain?.key(at: 0).privateKeyAddressTestnet.string)!
                addressHD = (keychain?.key(at: 0).addressTestnet.string)!
                
            } else if mainnetMode {
                
                network = "mainnet"
                
                self.privateKeyWIF = (keychain?.key(at: 0).privateKeyAddress.string)!
                addressHD = (keychain?.key(at: 0).address.string)!
                
            }
            
            if self.legacyMode {
                
                self.bitcoinAddress = addressHD
                
            }
            
            if segwitMode {
                
                let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain?.key(at: 0).compressedPublicKey as Data!) as Data!) as Data!
                
                do {
                    
                    if mainnetMode {
                        
                        self.bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                        
                    } else if testnetMode {
                        
                        self.bitcoinAddress = try segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                        
                    }
                    
                } catch {
                    
                    displayAlert(viewController: self, title: "Error", message: "Please try again.")
                    
                }
                
            }
            
            if self.hotMode {
                
                saveWallet(viewController: self, address: self.bitcoinAddress, privateKey: self.privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: network, type: "hot")
                
            } else {
                
                saveWallet(viewController: self, address: self.bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: network, type: "cold")
            }
            
            keychain?.key.clear()
            
            self.showPrivateKeyAndAddressQRCodes()
            
        } else {
            
            print("error = \(self.wordArray)")
            DispatchQueue.main.async {
                self.outputMnemonic.text = ""
                self.wordArray.removeAll()
                self.password = ""
                self.inputPassword.text = ""
                self.listArray.removeAll()
                displayAlert(viewController: self, title: "Error", message: "Sorry that phrase is not BIP39 compatible, make sure you enter the correct words with no misspellings and no spaces after each word.")
            }
        }
        
        
    }
    
    func addHomeButton() {
        
        print("addHomeButton")
        
        
            DispatchQueue.main.async {
                
                self.button.removeFromSuperview()
                self.button = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
                self.button.showsTouchWhenHighlighted = true
                self.button.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
                self.button.addTarget(self, action: #selector(self.home), for: .touchUpInside)
                self.view.addSubview(self.button)
                
            }
            
        
    }
    
    func addImportActionButton() {
        print("addImportActionButton")
        
        DispatchQueue.main.async {
            self.importAction = UIButton(frame: CGRect(x: self.view.center.x - 45, y: self.inputMnemonic.frame.maxY + 10, width: 90, height: 50))
            self.importAction.showsTouchWhenHighlighted = true
            self.importAction.titleLabel?.textAlignment = .center
            self.importAction.setTitle("Import", for: .normal)
            self.importAction.setTitleColor(UIColor.blue, for: .normal)
            self.importAction.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
            self.importAction.addTarget(self, action: #selector(self.importNow), for: .touchUpInside)
            self.view.addSubview(self.importAction)
        }
        
    }
    
    func addScanQRCodeButton() {
        print("addScanQRCodeButton")
        
        DispatchQueue.main.async {
            self.scanQRCodeButton.removeFromSuperview()
            self.scanQRCodeButton = UIButton(frame: CGRect(x: self.view.center.x - 25, y: 20, width: 50, height: 50))
            self.scanQRCodeButton.showsTouchWhenHighlighted = true
            self.scanQRCodeButton.titleLabel?.textAlignment = .center
            self.scanQRCodeButton.layer.cornerRadius = 10
            self.scanQRCodeButton.setImage(#imageLiteral(resourceName: "qr.png"), for: .normal)
            self.scanQRCodeButton.addTarget(self, action: #selector(self.scanRecoveryPhrase), for: .touchUpInside)
            self.view.addSubview(self.scanQRCodeButton)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func chooseQRCodeFromLibrary() {
        
        present(imagePicker, animated: true, completion: nil)
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
                    
                    self.scanQRCodeButton.removeFromSuperview()
                    self.outputMnemonic.text = qrCodeLink
                    self.wordArray = qrCodeLink.wordList
                    
                    for word in self.wordArray {
                        
                        self.listArray.append(word + " ")
                        
                    }
                    
                }
                
                self.qrimageview.removeFromSuperview()
                self.avCaptureSession.stopRunning()
            }
            
       }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func scanRecoveryPhrase() {
        
        self.inputMnemonic.resignFirstResponder()
        self.inputPassword.resignFirstResponder()
        
        self.qrimageview.frame = CGRect(x: 25, y: self.importAction.frame.maxY + 10, width: self.view.frame.width - 50, height: self.view.frame.width - 20)
        addShadow(view: self.qrimageview)
        
        self.uploadButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 140, y: self.view.frame.maxY - 60, width: 130, height: 55))
        self.uploadButton.showsTouchWhenHighlighted = true
        self.uploadButton.setTitle("From Photos", for: .normal)
        self.uploadButton.setTitleColor(UIColor.blue, for: .normal)
        self.uploadButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        self.uploadButton.addTarget(self, action: #selector(self.chooseQRCodeFromLibrary), for: .touchUpInside)
        self.view.addSubview(self.uploadButton)
        
        DispatchQueue.main.async {
            self.view.addSubview(self.qrimageview)
        }
        
        func scanQRCode() {
            
            do {
                
                try scanQRNow()
                print("scanQRNow")
                
            } catch {
                
                print("Failed to scan QR Code")
            }
            
        }
        
        DispatchQueue.main.async {
            scanQRCode()
        }
        
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
            let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.avCaptureSession)
            avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            avCaptureVideoPreviewLayer.frame = self.qrimageview.bounds
            self.qrimageview.layer.addSublayer(avCaptureVideoPreviewLayer)
            self.avCaptureSession.startRunning()
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            print("metadataOutput")
            
            let machineReadableCode = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if machineReadableCode.type == AVMetadataObject.ObjectType.qr {
                
                stringURL = machineReadableCode.stringValue!
                print("stringURL = \(stringURL)")
                
                DispatchQueue.main.async {
                    
                    self.scanQRCodeButton.removeFromSuperview()
                    self.outputMnemonic.text = self.stringURL
                    self.wordArray = self.stringURL.wordList
                    
                    for word in self.wordArray {
                        
                        self.listArray.append(word + " ")
                        
                    }
                    
                }
                
                self.qrimageview.removeFromSuperview()
                self.avCaptureSession.stopRunning()
                
            }
        }
    }
    
    @objc func newAddress() {
        print("newAddress")
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        addressBook = checkAddressBook()
        
        DispatchQueue.main.async {
            
                if self.addressBook.count > 1 {
                    
                    let alert = UIAlertController(title: "Which Wallet?", message: "Please select which wallet you'd like to receive to", preferredStyle: UIAlertControllerStyle.actionSheet)
                    
                    for (index, wallet) in self.addressBook.enumerated() {
                        
                        let walletName = wallet["label"] as! String
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString(walletName, comment: ""), style: .default, handler: { (action) in
                            
                            self.watchOnlyMode = true
                            self.bitcoinAddress = self.addressBook[index]["address"] as! String
                            self.showAddressQRCodes(walletName: walletName)
                            
                        }))
                        
                    }
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                        
                    }))
                    
                    alert.popoverPresentationController?.sourceView = self.view
                    
                    self.present(alert, animated: true) {
                        print("option menu presented")
                    }
                    
                } else if self.addressBook.count == 1 {
                    
                    self.watchOnlyMode = true
                    let walletName = self.addressBook[0]["label"] as! String
                    self.bitcoinAddress = self.addressBook[0]["address"] as! String
                    self.showAddressQRCodes(walletName: walletName)
                    
                } else if self.addressBook.count == 0 {
                    
                    shakeAlert(viewToShake: self.imageView)
                    
                }

        }

    }
    
    func addBackButton() {
        print("addBackButton")
        
        DispatchQueue.main.async {
            
            self.button.removeFromSuperview()
            self.button = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
            self.button.showsTouchWhenHighlighted = true
            self.button.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
            self.button.addTarget(self, action: #selector(self.back), for: .touchUpInside)
            self.view.addSubview(self.button)
            
        }
        
    }
    
    @objc func back() {
        print("back")
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        for dice in self.diceArray {
            dice.removeFromSuperview()
        }
        
        self.qrimageview.removeFromSuperview()
        if self.myField != nil {
            self.myField.removeFromSuperview()
        }
        self.uploadButton.removeFromSuperview()
        self.scanQRCodeButton.removeFromSuperview()
        self.imageView.removeFromSuperview()
        self.diceArray.removeAll()
        self.tappedIndex = 0
        self.percentageLabel.removeFromSuperview()
        self.inputMnemonic.resignFirstResponder()
        self.inputMnemonic.removeFromSuperview()
        self.inputPassword.removeFromSuperview()
        self.importAction.removeFromSuperview()
        self.importButton.removeFromSuperview()
        self.button.removeFromSuperview()
        self.clearMnemonicButton.removeFromSuperview()
        self.clearButton.removeFromSuperview()
        self.addHomeScreen()
        
    }
    
    @objc func getAddress() {
        print("getAddress")
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        func togglePrivateKeyAddressAndRecoveryPhrase() {
            
            if recoveryMode {
                
                self.myField.text = self.words
                self.privateKeyQRCode = self.generateQrCode(key: self.words)
                self.privateKeyQRView.image = self.privateKeyQRCode!
                
                DispatchQueue.main.async {
                    
                    self.privateKeyTitle.text = "Recovery Phrase"
                    self.WIFprivateKeyFieldLabel.text = "Save this to restore your funds:"
                    
                }
                
                self.recoveryMode = false
                self.addressMode = true
                self.privateKeyMode = false
                
                self.textToShare = self.words
                self.filename = "recoveryPhrase"
                
            } else if addressMode {
                
                DispatchQueue.main.async {
                    
                    self.myField.text = self.bitcoinAddress
                    self.privateKeyQRCode = self.generateQrCode(key: self.bitcoinAddress)
                    self.privateKeyQRView.image = self.privateKeyQRCode!
                    
                    if self.segwitMode {
                        
                        DispatchQueue.main.async {
                            self.privateKeyTitle.text = "Segwit Address"
                            self.WIFprivateKeyFieldLabel.text = ""
                            
                        }
                        
                    } else if self.legacyMode {
                        
                        DispatchQueue.main.async {
                            self.privateKeyTitle.text = "Legacy Bitcoin Address"
                            self.WIFprivateKeyFieldLabel.text = ""
                        }
                        
                    }
                    
                    self.privateKeyTitle.adjustsFontSizeToFitWidth = true
                    self.recoveryMode = false
                    self.addressMode = false
                    self.privateKeyMode = true
                    
                }
                
                self.textToShare = self.bitcoinAddress
                self.filename = "bitcoinAddress"
                
            } else if privateKeyMode {
                
                DispatchQueue.main.async {
                    
                    self.privateKeyTitle.text = "Bitcoin Private Key"
                    self.WIFprivateKeyFieldLabel.text = ""
                    self.myField.text = self.privateKeyText
                    self.privateKeyQRCode = self.generateQrCode(key: self.privateKeyText)
                    self.privateKeyQRView.image = self.privateKeyQRCode!
                    self.recoveryMode = true
                    self.addressMode = false
                    self.privateKeyMode = false
                    
                }
                
                self.textToShare = self.privateKeyWIF
                self.filename = "privateKey"
                
            }
            
        }
        
        func togglePrivateKeyAndAddress() {
            
            if privateKeyMode {
                
                DispatchQueue.main.async {
                    
                    self.myLabel.text = self.bitcoinAddress
                    self.privateKeyQRCode = self.generateQrCode(key: self.bitcoinAddress)
                    self.privateKeyQRView.image = self.privateKeyQRCode!
                    
                    if self.segwitMode {
                        
                        DispatchQueue.main.async {
                            self.privateKeyTitle.text = "Address"
                            
                            if self.walletName != "" {
                                
                                self.privateKeyTitle.text = "\"" + self.walletName + "\"" + " " + "Address"
                                
                            }
                            
                            self.WIFprivateKeyFieldLabel.text = "Native Segwit Bech32 Format:"
                            
                        }
                        
                    } else if self.legacyMode {
                        
                        DispatchQueue.main.async {
                            self.privateKeyTitle.text = "Address"
                            
                            if self.walletName != "" {
                                
                                self.privateKeyTitle.text = "\"" + self.walletName + "\"" + " " + "Address"
                                
                            }
                            
                            self.WIFprivateKeyFieldLabel.text = ""
                        }
                        
                    }
                    
                    self.privateKeyTitle.adjustsFontSizeToFitWidth = true
                    self.privateKeyMode = false
                    
                }
                
                self.textToShare = self.bitcoinAddress
                self.filename = "bitcoinAddress"
                
            } else {
                
                DispatchQueue.main.async {
                    
                    self.privateKeyTitle.text = "Private Key"
                    
                    if self.walletName != "" {
                        
                        self.privateKeyTitle.text = "\"" + self.walletName + "\"" + " " + "Private Key"
                        
                    }
                    
                    self.WIFprivateKeyFieldLabel.text = ""
                    self.myLabel.text = self.privateKeyText
                    self.privateKeyQRCode = self.generateQrCode(key: self.privateKeyText)
                    self.privateKeyQRView.image = self.privateKeyQRCode!
                    self.privateKeyMode = true
                    
                }
                
                self.textToShare = self.privateKeyWIF
                self.filename = "privateKey"
                
            }
        }
    
        if self.diceMode != true {
            
            togglePrivateKeyAndAddress()
            
        } else if diceMode {
            
            togglePrivateKeyAddressAndRecoveryPhrase()
            
        }
        
    }
    
    func showPrivateKeyAndAddressQRCodes() {
        print("showPrivateKeyAndAddressQRCodes")
        
        self.removeHomeScreen()
        self.outputMnemonic.removeFromSuperview()
        self.inputMnemonic.removeFromSuperview()
        self.inputPassword.removeFromSuperview()
        self.clearMnemonicButton.removeFromSuperview()
        self.button.removeFromSuperview()
        self.importAction.removeFromSuperview()
        
        
        func addButtons() {
            
            self.button.removeFromSuperview()
            self.button = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
            self.button.showsTouchWhenHighlighted = true
            self.button.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
            self.button.addTarget(self, action: #selector(self.home), for: .touchUpInside)
            self.view.addSubview(self.button)
            
            self.bitcoinAddressButton.removeFromSuperview()
            self.bitcoinAddressButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 90, y: 20, width: 80, height: 55))
            self.bitcoinAddressButton.setTitle("Next", for: .normal)
            self.bitcoinAddressButton.setTitleColor(UIColor.blue, for: .normal)
            self.bitcoinAddressButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
            self.bitcoinAddressButton.addTarget(self, action: #selector(self.getAddress), for: .touchUpInside)
            self.view.addSubview(self.bitcoinAddressButton)
            
        }
        
        if self.diceMode != true {
            
            self.privateKeyMode = true
            
        } else if self.diceMode {
            
            self.recoveryMode = true
            
        }
        
        self.privateKeyText = self.privateKeyWIF
        self.privateKeyQRCode = self.generateQrCode(key: self.privateKeyWIF)
        self.privateKeyQRView = UIImageView(image: self.privateKeyQRCode!)
        self.privateKeyQRView.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 70) / 2), y: self.view.center.y - ((self.view.frame.width - 70) / 2), width: self.view.frame.width - 70, height: self.view.frame.width - 70)
        addShadow(view: self.privateKeyQRView)
        self.privateKeyQRView.alpha = 0
        self.view.addSubview(self.privateKeyQRView)
        
        /*self.WIFprivateKeyFieldLabel = UILabel(frame: CGRect(x: self.view.frame.minX + 5, y: self.privateKeyQRView.frame.maxY + 30, width: self.view.frame.width - 10, height: 13))
        self.WIFprivateKeyFieldLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 12)
        self.WIFprivateKeyFieldLabel.textColor = UIColor.black
        self.WIFprivateKeyFieldLabel.textAlignment = .left
        self.view.addSubview(self.WIFprivateKeyFieldLabel)*/
        
        self.textToShare = self.privateKeyWIF
        self.filename = "privateKey"
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.imageView.alpha = 0
            //self.bitField.alpha = 0
            
        }, completion: { _ in
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.privateKeyQRView.alpha = 1
                
            }, completion: { _ in
                DispatchQueue.main.async {
                    UIImpactFeedbackGenerator().impactOccurred()
                }
                //self.WIFprivateKeyFieldLabel.text = ""
                
                self.privateKeyTitle = UILabel(frame: CGRect(x: self.view.center.x - ((self.view.frame.width - 20) / 2), y: self.privateKeyQRView.frame.minY - 60, width: self.view.frame.width - 20, height: 50))
                self.privateKeyTitle.text = "Private Key"
                
                if self.walletName != "" {
                    
                    self.privateKeyTitle.text = "\"" + self.walletName + "\"" + " " + "Private Key"
                    
                }
                
                self.privateKeyTitle.adjustsFontSizeToFitWidth = true
                self.privateKeyTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 20)
                self.privateKeyTitle.textColor = UIColor.black
                self.privateKeyTitle.textAlignment = .center
                self.view.addSubview(self.privateKeyTitle)
                
                self.myLabel = UILabel (frame:CGRect(x: self.view.center.x - ((self.view.frame.width - 20)/2), y: self.privateKeyQRView.frame.maxY, width: self.view.frame.width - 20, height: 50))
                
                self.myLabel.textAlignment = .center
                self.myLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 18)
                self.myLabel.text = self.privateKeyWIF
                self.myLabel.adjustsFontSizeToFitWidth = true
                self.view.addSubview(self.myLabel)
                
                /*self.myField = UITextView (frame:CGRect(x: self.view.center.x - ((self.view.frame.width - 10)/2), y: self.WIFprivateKeyFieldLabel.frame.maxY, width: self.view.frame.width - 10, height: 150))
                self.myField.isEditable = false
                self.myField.isSelectable = true
                self.myField.backgroundColor = UIColor.clear
                self.myField.textAlignment = .center
                self.myField.font = UIFont.init(name: "HelveticaNeue-Light", size: 18)
                self.myField.text = self.privateKeyWIF
                self.view.addSubview(self.myField)*/
                addButtons()
                self.addBackUpButton()
                self.zero = 0
                self.bitArray.removeAll()
                
            })
            
        })
        
    }
    
    
    func showRecoveryPhraseAndQRCode() {
        
        print("showPrivateKeyAndAddressQRCodes")
        
        self.recoveryMode = true
        
        self.removeHomeScreen()
        self.outputMnemonic.removeFromSuperview()
        self.inputMnemonic.removeFromSuperview()
        self.inputPassword.removeFromSuperview()
        self.clearMnemonicButton.removeFromSuperview()
        self.button.removeFromSuperview()
        self.importAction.removeFromSuperview()
        
        
        func addButtons() {
            
            self.button.removeFromSuperview()
            self.button = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
            self.button.showsTouchWhenHighlighted = true
            self.button.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
            self.button.addTarget(self, action: #selector(self.home), for: .touchUpInside)
            self.view.addSubview(self.button)
            
        }
        
        diceMode = false
        
        self.privateKeyTitle = UILabel(frame: CGRect(x: self.view.center.x - ((self.view.frame.width - 20) / 2), y: 25, width: self.view.frame.width - 20, height: 50))
        self.privateKeyTitle.text = "Recovery Phrase"
        self.privateKeyTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 30)
        self.privateKeyTitle.textColor = UIColor.black
        self.privateKeyTitle.textAlignment = .center
        self.privateKeyTitle.alpha = 0
        self.view.addSubview(self.privateKeyTitle)
        
        self.mnemonicLabel = UILabel(frame: CGRect(x: self.view.center.x - ((self.view.frame.width - 10) / 2), y: self.privateKeyTitle.frame.maxY + 5, width: self.view.frame.width - 10, height: 13))
        self.mnemonicLabel.text = "You must save this phrase in order to recover lost funds!"
        self.mnemonicLabel.adjustsFontSizeToFitWidth = true
        self.mnemonicLabel.font = .systemFont(ofSize: 12)
        self.mnemonicLabel.textColor = UIColor.red
        self.mnemonicLabel.textAlignment = .center
        self.mnemonicLabel.alpha = 0
        self.view.addSubview(self.mnemonicLabel)
        
        self.mnemonicView = UITextView (frame:CGRect(x: self.view.center.x - ((self.view.frame.width - 10) / 2), y: self.mnemonicLabel.frame.maxY + 1, width: self.view.frame.width - 10, height: 130))
        self.mnemonicView.text = self.words
        self.mnemonicView.backgroundColor = UIColor.clear
        self.mnemonicView.isEditable = false
        self.mnemonicView.isSelectable = true
        self.mnemonicView.textAlignment = .natural
        self.mnemonicView.font = UIFont.init(name: "HelveticaNeue-Light", size: 20)
        self.mnemonicView.alpha = 0
        self.view.addSubview(self.mnemonicView)
        
        self.recoveryPhraseImage = self.generateQrCode(key: self.words)
        self.recoveryPhraseQRView = UIImageView(image: self.recoveryPhraseImage!)
        self.recoveryPhraseQRView.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 70) / 2), y: self.mnemonicView.frame.maxY + 10, width: self.view.frame.width - 70, height: self.view.frame.width - 70)
        self.recoveryPhraseQRView.alpha = 0
        addShadow(view: self.recoveryPhraseQRView)
        self.view.addSubview(self.recoveryPhraseQRView)
        
        self.textToShare = self.words
        self.filename = "recoveryPhrase"
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.imageView.alpha = 0
            //self.bitField.alpha = 0
            
        }, completion: { _ in
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.recoveryPhraseQRView.alpha = 1
                self.recoveryPhraseLabel.alpha = 1
                self.mnemonicLabel.alpha = 1
                self.mnemonicView.alpha = 1
                self.privateKeyTitle.alpha = 1
                
            }, completion: { _ in
                DispatchQueue.main.async {
                    UIImpactFeedbackGenerator().impactOccurred()
                }
                self.scrollView.setContentOffset(.zero, animated: false)
                addButtons()
                self.addBackUpButton()
                self.zero = 0
                self.bitArray.removeAll()
                
            })
            
        })
        
    }
    
    @objc func home() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        print("home")
        
        func goBack() {
            
            DispatchQueue.main.async {
                
                self.myLabel.removeFromSuperview()
                self.walletName = ""
                self.mnemonicLabel.removeFromSuperview()
                self.recoveryPhraseLabel.removeFromSuperview()
                if self.recoveryPhraseQRView != nil {
                    self.recoveryPhraseQRView.removeFromSuperview()
                }
                if self.mnemonicView != nil {
                    self.mnemonicView.removeFromSuperview()
                }
                self.words = ""
                self.watchOnlyMode = false
                self.bitcoinAddressButton.removeFromSuperview()
                
                if self.privateKeyQRView != nil {
                    
                    self.privateKeyQRView.image = nil
                    self.privateKeyQRCode = nil
                    self.privateKeyImage = nil
                    self.privateKeyQRView.image = nil
                    if self.myField != nil {
                       self.myField.text = ""
                    }
                    
                    
                }
                
                self.privateKeyTitle.text = ""
                self.imageView.removeFromSuperview()
                self.imageView = nil
                self.button.removeFromSuperview()
                self.backUpButton.removeFromSuperview()
                self.privateKeyText = ""
                self.WIFprivateKeyFieldLabel.removeFromSuperview()
                self.addHomeScreen()
                
            }
            
        }
        
        if self.recoveryMode {
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: "Have you saved the recovery phrase?", message: "If you have not saved it you will lose your Bitcoin if you lose this phone or delete this app!\n\nWe DO NOT save the recovery phrase on your behalf.\n\nWe do make this super easy for you, just tap the share button in the bottom right corner of the screen.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes, I saved it", comment: ""), style: .destructive, handler: { (action) in
                    
                    goBack()
                    self.recoveryMode = false
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: { (action) in
                    
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
           
            goBack()
            
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
            privateKeyImage = UIImage(cgImage: cgImage!)
            return privateKeyImage
        }
        
        return nil
        
    }
    
    func addBackUpButton() {
         print("addBackUpButton")
        DispatchQueue.main.async {
            self.backUpButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 90, y: self.view.frame.maxY - 60, width: 80, height: 55))
            self.backUpButton.showsTouchWhenHighlighted = true
            self.backUpButton.setTitle("Share", for: .normal)
            self.backUpButton.setTitleColor(UIColor.blue, for: .normal)
            self.backUpButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
            self.backUpButton.addTarget(self, action: #selector(self.goTo(sender:)), for: .touchUpInside)
            self.view.addSubview(self.backUpButton)
        }
        
    }
   
    func showKeyManagementAlert() {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Key Tools", message: "Please select an option", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Create Keys with Dice", comment: ""), style: .default, handler: { (action) in
                
                self.removeHomeScreen()
                self.showDice()
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Import Keys with Recovery Phrase", comment: ""), style: .default, handler: { (action) in
                
                self.importMnemonic()
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Sweep a Private Key", comment: ""), style: .default, handler: { (action) in
                
                self.performSegue(withIdentifier: "sweep", sender: self)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Create a Multi Sig", comment: ""), style: .default, handler: { (action) in
                
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
    
    @objc func goTo(sender: UIButton) {
        print("goTo")
        
        switch sender {
            
        case self.backUpButton:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            self.addAlertForShare(textToShare: self.textToShare, filename: self.filename)
            
        case self.addressBookButton:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            print("addressBookButton")
            
            self.addressBook = checkAddressBook()
            
            if addressBook.count == 0 {
                
                displayAlert(viewController: self, title: "Your address book is empty.", message: "Move the Bitcoin around to create your first wallet which will be saved to your address book.")
            }
            
            self.performSegue(withIdentifier: "goToAddressBook", sender: self)
            
        case self.lockButton:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            print("lock button")
            //self.addPasswordAlert()
            self.performSegue(withIdentifier: "securitySettings", sender: self)
            
        case self.priceButton:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            print("price button")
            self.performSegue(withIdentifier: "goToMayerMultiple", sender: self)
            
        case self.toolboxButton:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            print("tool box button")
            self.showKeyManagementAlert()
                
        case self.infoButton:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            print("go to info")
            self.performSegue(withIdentifier: "goToInfo", sender: self)
            
        case self.settingsButton:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            print("go to settings")
            self.performSegue(withIdentifier: "settings", sender: self)
            
        case self.diceButton:
            
            sender.removeFromSuperview()
            self.importButton.removeFromSuperview()
            self.removeHomeScreen()
            self.showDice()
            
        case self.transactionsButton:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            self.performSegue(withIdentifier: "transaction", sender: self)
                
        case self.checkAddressButton:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            self.performSegue(withIdentifier: "checkAddress", sender: self)
            
        default:
            break
        }
        
    }
    
   func addAlertForShare(textToShare: String, filename: String) {
        
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
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Text", comment: ""), style: .default, handler: { (action) in
                
                let textToShare = [textToShare]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
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
    
    func addPercentageCompleteLabel() {
        print("addPercentageCompleteLabel")
        DispatchQueue.main.async {
            self.percentageLabel.frame = CGRect(x: self.view.frame.maxX / 2 - 50, y: self.view.frame.minY + 10, width: 100, height: 50)
            let percentage:Double = (Double(self.bitCount) / 256.0) * 100.0
            self.percentageLabel.text = "\(Int(percentage))%"
            self.percentageLabel.textColor = UIColor.black
            self.percentageLabel.backgroundColor = UIColor.white
            self.percentageLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 30)
            self.percentageLabel.textAlignment = .center
            self.view.addSubview(self.percentageLabel)
        }
    }
    
    func addClearButton() {
        print("addClearButton")
        
        DispatchQueue.main.async {
            self.clearButton.removeFromSuperview()
            self.clearButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 60, y: 20, width: 55 , height: 55))
            self.clearButton.setImage(#imageLiteral(resourceName: "clear.png"), for: .normal)
            self.clearButton.addTarget(self, action: #selector(self.tapClearDice), for: .touchUpInside)
            self.view.addSubview(self.clearButton)
        }
        
    }
    
    func addClearMnemonicButton() {
        print("addClearMnemonicButton")
        
        DispatchQueue.main.async {
            self.clearMnemonicButton.removeFromSuperview()
            self.clearMnemonicButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 60, y: 20, width: 55 , height: 55))
            self.clearMnemonicButton.setImage(#imageLiteral(resourceName: "clear.png"), for: .normal)
            self.clearMnemonicButton.addTarget(self, action: #selector(self.tapClearMnemonic), for: .touchUpInside)
            self.view.addSubview(self.clearMnemonicButton)
        }
        
    }
    
    @objc func tapClearMnemonic() {
        print("tapClearMnemonic")
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        DispatchQueue.main.async {
            
            if self.wordArray.count > 0 {
                
                self.wordArray.removeLast()
                self.listArray.removeLast()
                self.outputMnemonic.text = self.listArray.joined()
                
            }
            
         }
        
    }
    
    @objc func tapClearDice() {
        print("tapClearDice")
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        clearDice()
        
    }
    
    func clearDice() {
        print("clearDice")
        for dice in self.diceArray {
            dice.removeFromSuperview()
        }
        self.diceArray.removeAll()
        self.tappedIndex = 0
        self.percentageLabel.removeFromSuperview()
        self.showDice()
        
    }
    
    func creatBitKey() {
        print("creatBitKey")
        for dice in self.diceArray {
            
            let diceNumber = Int((dice.titleLabel?.text)!)!
            
            if diceNumber != 0 {
                
                if dice.tag < self.tappedIndex {
                    
                    switch diceNumber {
                        
                    case 1:
                        self.randomBits.append("00")
                    case 2:
                        self.randomBits.append("01")
                    case 3:
                        self.randomBits.append("10")
                    case 4:
                        self.randomBits.append("11")
                    case 5:
                        self.randomBits.append("0")
                    case 6:
                        self.randomBits.append("1")
                    default: break
                        
                    }
                    
                    self.joinedBits = randomBits.joined()
                    
                    self.bitCount = 0
                    self.percentageLabel.removeFromSuperview()
                    
                    for _ in self.joinedBits {
                        self.bitCount = bitCount + 1
                    }
                    
                    self.addPercentageCompleteLabel()
                    
                    if self.bitCount > 255 {
                        
                        DispatchQueue.main.async {
                            
                            if self.bitCount == 257 {
                                self.joinedBits.removeLast()
                            }
                            
                            self.parseBitResult = self.parseBinary(binary: self.joinedBits)!
                            
                            var count = 0
                            for _ in self.joinedBits {
                                count = count + 1
                            }
                            
                            self.percentageLabel.removeFromSuperview()
                            self.clearButton.removeFromSuperview()
                            
                            for dice in self.diceArray {
                                dice.removeFromSuperview()
                            }
                            self.diceArray.removeAll()
                            self.tappedIndex = 0
                            
                            self.privateKeyWIF = createPrivateKey(viewController: self, userRandomness: self.parseBitResult).privateKeyAddress
                            self.bitcoinAddress = createPrivateKey(viewController: self, userRandomness: self.parseBitResult).publicKeyAddress
                            self.words = createPrivateKey(viewController: self, userRandomness: self.parseBitResult).recoveryPhrase
                            
                            self.button.removeFromSuperview()
                            self.diceMode = true
                            self.showPrivateKeyAndAddressQRCodes()
                            
                        }
                        
                    } else {
                        
                    }
                    
                }
                
            }
            
        }
        
        self.randomBits.removeAll()
        
    }
    
    @objc func tapDice(sender: UIButton!) {
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        let diceNumber = Int((sender.titleLabel?.text)!)!
        
        func addDiceValue() {
            
            switch diceNumber {
                
            case 0:
                DispatchQueue.main.async {
                    sender.setTitle("1", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "one.png"), for: .normal)
                }
            case 1:
                DispatchQueue.main.async {
                    sender.setTitle("2", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "two.png"), for: .normal)
                }
            case 2:
                DispatchQueue.main.async {
                    sender.setTitle("3", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "three.png"), for: .normal)
                }
            case 3:
                DispatchQueue.main.async {
                    sender.setTitle("4", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "four.png"), for: .normal)
                }
            case 4:
                DispatchQueue.main.async {
                    sender.setTitle("5", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "five.png"), for: .normal)
                }
            case 5:
                DispatchQueue.main.async {
                    sender.setTitle("6", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "six.png"), for: .normal)
                }
            case 6:
                DispatchQueue.main.async {
                    sender.setTitle("1", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "one.png"), for: .normal)
                }
            default:
                break
                
            }
            
        }
        
        if isInternetAvailable() == false {
            
            if sender.tag == 1 && diceNumber == 0 {
                
                self.tappedIndex = sender.tag
                addDiceValue()
                
            } else if sender.tag == self.tappedIndex + 1 {
                
                self.tappedIndex = sender.tag
                addDiceValue()
                creatBitKey()
                
            } else if sender.tag == self.tappedIndex {
                
                addDiceValue()
                
            } else if self.hideExplanation == false {
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: NSLocalizedString("You must input dice values in order.", comment: ""), message: "In order for the key to be cryptographically secure you must input the actual values of your dice as they appear to you from left to right, in order row by row.\n\nStart with the top left dice and work your way to the right being very careful to ensure you input the dice values correctly.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Ok, got it", comment: ""), style: .default, handler: { (action) in
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Why?", comment: ""), style: .default, handler: { (action) in
                        
                        displayAlert(viewController: self, title: "", message: "We make it impossible for you to input the dice values out of order becasue we don't want you to accidentally create a Private Key that is not based on true cryptographic secure randomness. We also do this to make it impossible for you to accidentaly tap and change a value of a dice you have already input. Secure keys ARE WORTH the effort!")
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Start Over", comment: ""), style: .destructive, handler: { (action) in
                        
                        self.clearDice()
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Don't show me this again", comment: ""), style: .destructive, handler: { (action) in
                        
                        UserDefaults.standard.set(true, forKey: "hideExplanation")
                        UserDefaults.standard.synchronize()
                        self.hideExplanation = true
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                displayAlert(viewController: self, title: "Turn on airplane mode to create private keys securely.", message: "The idea is to never let your Bitcoin private key touch the interent, secure keys are worth the effort.")
            }
        }
    }
    
    func showDice() {
        print("showDice")
        
        diceMode = true
        self.addBackButton()
        self.addClearButton()
        self.outputMnemonic.removeFromSuperview()
        var xvalue:Int!
        var width:Int!
        var height:Int!
        
        if self.view.frame.width == 414 {
         
            xvalue = 25
            width = 65
            height = 65
            
        } else {
            
            xvalue = 14
            width = 50
            height = 50
        }
        
        var yvalue = 80
        var zero = 0
        
        self.view.addSubview(self.scrollView)
        
        for _ in 0..<40 {
            
            for _ in 0..<5 {
                
                zero = zero + 1
                self.diceButton = UIButton(frame: CGRect(x: xvalue, y: yvalue, width: width, height: height))
                self.diceButton.setImage(#imageLiteral(resourceName: "images-6.png"), for: .normal)
                self.diceButton.tag = zero
                self.diceButton.showsTouchWhenHighlighted = true
                self.diceButton.backgroundColor = .white
                self.diceButton.setTitle("\(0)", for: .normal)
                self.diceButton.titleLabel?.textColor = UIColor.white
                self.diceButton.addTarget(self, action: #selector(self.tapDice), for: .touchUpInside)
                self.diceArray.append(self.diceButton)
                self.scrollView.addSubview(self.diceButton)
                
                if self.view.frame.width == 414 {
                    
                 xvalue = xvalue + 75
                    
                } else {
                    
                    xvalue = xvalue + 60
                }
                
            }
            
            if self.view.frame.width == 414 {
              
                xvalue = 25
                
            } else {
                
                xvalue = 14
            }
            
            yvalue = yvalue + 90
            
        }
        
    }
    
}



