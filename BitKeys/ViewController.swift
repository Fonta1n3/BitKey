//
//  ViewController.swift
//  BitKeys
//
//  Created by Peter on 11/27/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit
import Security
import SystemConfiguration
import BigInt


class ViewController: UIViewController, UITextFieldDelegate {
    
    var simpleMode = Bool()
    var advancedMode = Bool()
    var testnetMode = Bool()
    var mainnetMode = Bool()
    var addressMode = Bool()
    var coldMode = Bool()
    var hotMode = Bool()
    var legacyMode = Bool()
    var segwitMode = Bool()
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
    var bitField:UITextView!
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
    var connected:Bool!
    var diceButton = UIButton()
    var transactionsButton = UIButton()
    var parseBitResult = BigInt()
    var bitArray = [String]()
    var zero = 0
    let segwit = SegwitAddrCoder()
    var words = String()
    var privateKeyTitle = UILabel()
    var WIFprivateKeyFieldLabel = UILabel()
    var mnemonicLabel = UILabel()
    var legacyAddress = String()
    var recoveryPhrase = String()
    var recoveryPhraseLabel = UILabel()
    var privateKeyWIF = String()
    var importButton = UIButton()
    var inputMnemonic = UITextField()
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
    var extendedPublicKeyMode = Bool()
    var clearMnemonicButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.object(forKey: "hideExplanation") != nil {
            
            self.hideExplanation = UserDefaults.standard.bool(forKey: "hideExplanation")
            
        } else {
            
            self.hideExplanation = false
            
        }
        
        diceMode = false
        inputMnemonic.delegate = self
        privateKeyMode = true
        
        
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
        
        /*
        if self.imageView == nil {
            
            let bitcoinImage = UIImage(named: "bitcoinIcon.png")
            self.imageView = UIImageView(image: bitcoinImage!)
            self.imageView.center = self.view.center
            self.imageView.frame = CGRect(x: self.view.center.x - 100, y: self.view.center.y - 100, width: 200, height: 200)
            
            
            let bitcoinDragged = UIPanGestureRecognizer(target: self, action: #selector(self.userCreatesRandomness(gestureRecognizer:)))
            self.imageView.isUserInteractionEnabled = true
            self.imageView.addGestureRecognizer(bitcoinDragged)
            self.view.addSubview(self.imageView)
            
        }
        */
        
        checkUserDefaults()
        addHomeScreen()
        
    }
    
    func checkUserDefaults() {
        
        print("checkUserDefaults")
        
        if UserDefaults.standard.object(forKey: "simpleMode") != nil {
            
            simpleMode = UserDefaults.standard.object(forKey: "simpleMode") as! Bool
            
        } else {
            
            simpleMode = true
            
        }
        
        if UserDefaults.standard.object(forKey: "advancedMode") != nil {
            
            advancedMode = UserDefaults.standard.object(forKey: "advancedMode") as! Bool
            
        } else {
            
            advancedMode = false
            
        }
        
        if UserDefaults.standard.object(forKey: "coldMode") != nil {
            
            coldMode = UserDefaults.standard.object(forKey: "coldMode") as! Bool
            
        } else {
            
            coldMode = true
            
        }
        
        if UserDefaults.standard.object(forKey: "hotMode") != nil {
            
            hotMode = UserDefaults.standard.object(forKey: "hotMode") as! Bool
            
        } else {
            
            hotMode = false
            
        }
        
        if UserDefaults.standard.object(forKey: "legacyMode") != nil {
            
            legacyMode = UserDefaults.standard.object(forKey: "legacyMode") as! Bool
            
        } else {
            
            legacyMode = true
            
        }
        
        if UserDefaults.standard.object(forKey: "segwitMode") != nil {
            
            segwitMode = UserDefaults.standard.object(forKey: "segwitMode") as! Bool
            
        } else {
            
            segwitMode = false
            
        }
        
        if UserDefaults.standard.object(forKey: "testnetMode") != nil {
            
            testnetMode = UserDefaults.standard.object(forKey: "testnetMode") as! Bool
            
        } else {
            
            testnetMode = false
            
        }
        
        if UserDefaults.standard.object(forKey: "mainnetMode") != nil {
            
            mainnetMode = UserDefaults.standard.object(forKey: "mainnetMode") as! Bool
            
        } else {
            
            mainnetMode = true
            
        }
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
    
    func derivePrivateKeyFromMasterKey(keychain: BTCKeychain) -> (privateKeyAddress: String, legacyAddress: String, segwitAddress: String) {
        
        let privateKeyHD = keychain.key.privateKeyAddress
        let addressHD = keychain.key.address
        let privateKey2 = privateKeyHD!.description
        var privateKey3 = privateKey2.components(separatedBy: " ")
        self.privateKeyWIF = privateKey3[1].replacingOccurrences(of: ">", with: "")
        let legacyAddress1 = addressHD!.description
        let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
        self.legacyAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
        let xpub = keychain.extendedPublicKey
        UserDefaults.standard.set(xpub, forKey: "xpub")
        UserDefaults.standard.set(1, forKey: "int")
        
        let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain.key.compressedPublicKey as Data!) as Data!) as Data!
        
        do {
            //bc for mainnet and tb for testnet
            self.bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
            
        } catch {
            
            self.displayAlert(title: "Error", message: "Please try again.")
            return("", "", "")
        }
        
        keychain.key.clear()
        
        return (self.privateKeyWIF, self.legacyAddress, self.bitcoinAddress)
        
    }
    
    func createPrivateKey(userRandomness: BigInt) -> (privateKeyAddress: String, publicKeyAddress: String) {
        
        var data = BigUInt(userRandomness).serialize()
        let mnemonic = BTCMnemonic.init(entropy: data, password: "", wordListType: BTCMnemonicWordListType.english)
        self.words = (mnemonic?.words.description)!
        print("self.words = \(self.words)")
        let formatMnemonic1 = self.words.replacingOccurrences(of: "[", with: "")
        let formatMnemonic2 = formatMnemonic1.replacingOccurrences(of: "]", with: "")
        self.recoveryPhrase = formatMnemonic2.replacingOccurrences(of: ",", with: "")
        let keychain = mnemonic?.keychain.derivedKeychain(withPath: "m/0'/0'")
        keychain?.key.isPublicKeyCompressed = true
        
        var privateKeyHD = String()
        var addressHD = String()
        
        if testnetMode {
           
            privateKeyHD = (keychain?.key(withPath: "0'").privateKeyAddressTestnet.description)!
            addressHD = (keychain?.key(withPath: "0'").addressTestnet.description)!
            
        } else if mainnetMode {
            
            privateKeyHD = (keychain?.key(withPath: "0'").privateKeyAddress.description)!
            addressHD = (keychain?.key(withPath: "0'").address.description)!
            
        }
        
        //let privateKey2 = privateKeyHD!.description
        var privateKey3 = privateKeyHD.components(separatedBy: " ")
        self.privateKeyWIF = privateKey3[1].replacingOccurrences(of: ">", with: "")
        
        if self.hotMode {
            
            UserDefaults.standard.set(self.privateKeyWIF, forKey: "wif")
        }
        
        if self.legacyMode {
            
            //let legacyAddress1 = addressHD!.description
            let legacyAddress2 = (addressHD.description).components(separatedBy: " ")
            self.bitcoinAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
            
        }
        
        let xpub = keychain?.extendedPublicKey
        let xpriv = keychain?.extendedPrivateKey
        print("xpub = \(String(describing: xpub))")
        print("xpriv = \(String(describing: xpriv))")
        UserDefaults.standard.set(xpub, forKey: "xpub")
        UserDefaults.standard.set(0, forKey: "int")
        
        if segwitMode {
          
            let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain?.key(withPath: "0'").compressedPublicKey as Data!) as Data!) as Data!
            
            do {
                //bc for mainnet and tb for testnet
                if mainnetMode {
                    
                  self.bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                    
                } else if testnetMode {
                    
                   self.bitcoinAddress = try segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                    
                }
                
                
            } catch {
                
                self.displayAlert(title: "Error", message: "Please try again.")
                return("", "")
            }
            
        }
        
        keychain?.key.clear()
        data.removeAll()
        return (self.privateKeyWIF, self.bitcoinAddress)
        
    }
    
    @objc func importMnemonic() {
        print("importMnemonic")
        
        self.isInternetAvailable()
        self.importButton.removeFromSuperview()
        
        self.recoveryPhrase = ""
        self.wordArray.removeAll()
        self.words = ""
        self.listArray.removeAll()
        
        if self.connected == true {
            
            DispatchQueue.main.async {
                self.displayAlert(title: "Security Alert", message: "You are connected to the internet, for maximum security please enable airplane mode before you enter your recovery phrase.")
            }
        }
        
        self.removeHomeScreen()
        
        self.inputMnemonic.frame = CGRect(x: self.view.frame.minX + 5, y: self.view.frame.minY + 100, width: self.view.frame.width - 10, height: 50)
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
        self.outputMnemonic.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        self.outputMnemonic.returnKeyType = UIReturnKeyType.done
        self.view.addSubview(self.outputMnemonic)
        self.addBackButton()
        
        self.addImportActionButton()
        
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
    
    func createNewAddress() {
        //store hdpubkey to create infinite addresses
        
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
            
            self.bitField = UITextView (frame:CGRect(x: self.view.center.x - (self.view.frame.width / 2), y: self.view.center.y - (self.view.frame.height / 2), width: self.view.frame.width, height: self.view.frame.height))
            self.bitField.isUserInteractionEnabled = false
            self.bitField.font = .systemFont(ofSize: 24)
            self.view.addSubview(self.bitField)
            
            if self.imageView != nil {
                self.imageView.removeFromSuperview()
            }
            
            let bitcoinImage = UIImage(named: "bitcoinIcon.png")
            self.imageView = UIImageView(image: bitcoinImage!)
            self.imageView.center = self.view.center
            self.imageView.frame = CGRect(x: self.view.center.x - 100, y: self.view.center.y - 100, width: 200, height: 200)
            let bitcoinDragged = UIPanGestureRecognizer(target: self, action: #selector(self.userCreatesRandomness(gestureRecognizer:)))
            self.imageView.isUserInteractionEnabled = true
            
            if self.advancedMode {
                
             self.imageView.addGestureRecognizer(bitcoinDragged)
                
            }
            
            self.view.addSubview(self.imageView)
            
            self.checkAddressButton.removeFromSuperview()
            self.checkAddressButton = UIButton(frame: CGRect(x: 5, y: self.view.frame.maxY - 60, width: 90, height: 55))
            self.checkAddressButton.showsTouchWhenHighlighted = true
            self.checkAddressButton.layer.cornerRadius = 10
            self.checkAddressButton.backgroundColor = UIColor.lightText
            self.checkAddressButton.layer.shadowColor = UIColor.black.cgColor
            self.checkAddressButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.checkAddressButton.layer.shadowRadius = 2.5
            self.checkAddressButton.layer.shadowOpacity = 0.8
            self.checkAddressButton.setTitle("Balance", for: .normal)
            self.checkAddressButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            self.view.addSubview(self.checkAddressButton)
            
            self.mayerMultipleButton.removeFromSuperview()
            self.mayerMultipleButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 95, y: self.view.frame.maxY - 60, width: 90, height: 55))
            self.mayerMultipleButton.showsTouchWhenHighlighted = true
            self.mayerMultipleButton.layer.cornerRadius = 10
            self.mayerMultipleButton.backgroundColor = UIColor.lightText
            self.mayerMultipleButton.layer.shadowColor = UIColor.black.cgColor
            self.mayerMultipleButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.mayerMultipleButton.layer.shadowRadius = 2.5
            self.mayerMultipleButton.layer.shadowOpacity = 0.8
            self.mayerMultipleButton.setTitle("Price", for: .normal)
            self.mayerMultipleButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            self.view.addSubview(self.mayerMultipleButton)
            
            self.transactionsButton.removeFromSuperview()
            self.transactionsButton = UIButton(frame: CGRect(x: self.view.center.x - 45, y: self.view.frame.maxY - 60, width: 90, height: 55))
            self.transactionsButton.showsTouchWhenHighlighted = true
            self.transactionsButton.layer.cornerRadius = 10
            self.transactionsButton.backgroundColor = UIColor.lightText
            self.transactionsButton.layer.shadowColor = UIColor.black.cgColor
            self.transactionsButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.transactionsButton.layer.shadowRadius = 2.5
            self.transactionsButton.layer.shadowOpacity = 0.8
            self.transactionsButton.setTitle("Send", for: .normal)
            self.transactionsButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            self.view.addSubview(self.transactionsButton)
            
            if self.advancedMode {
                
                self.diceButton.removeFromSuperview()
                self.diceButton = UIButton(frame: CGRect(x: 5, y: self.view.frame.minY + 20, width: 90, height: 55))
                self.diceButton.showsTouchWhenHighlighted = true
                self.diceButton.layer.cornerRadius = 10
                self.diceButton.backgroundColor = UIColor.lightText
                self.diceButton.layer.shadowColor = UIColor.black.cgColor
                self.diceButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
                self.diceButton.layer.shadowRadius = 2.5
                self.diceButton.layer.shadowOpacity = 0.8
                self.diceButton.setTitle("Dice", for: .normal)
                self.diceButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
                self.view.addSubview(self.diceButton)
            
                self.importButton.removeFromSuperview()
                self.importButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 95, y: self.view.frame.minY + 20, width: 90, height: 55))
                self.importButton.showsTouchWhenHighlighted = true
                self.importButton.layer.cornerRadius = 10
                self.importButton.backgroundColor = UIColor.lightText
                self.importButton.layer.shadowColor = UIColor.black.cgColor
                self.importButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
                self.importButton.layer.shadowRadius = 2.5
                self.importButton.layer.shadowOpacity = 0.8
                self.importButton.setTitle("Import", for: .normal)
                self.importButton.addTarget(self, action: #selector(self.importMnemonic), for: .touchUpInside)
                self.view.addSubview(self.importButton)
                
                if UserDefaults.standard.object(forKey: "xpub") != nil {
                    
                    self.newAddressButton.removeFromSuperview()
                    self.newAddressButton = UIButton(frame: CGRect(x: self.view.center.x - 45, y: 20, width: 90, height: 55))
                    self.newAddressButton.showsTouchWhenHighlighted = true
                    self.newAddressButton.titleLabel?.textAlignment = .center
                    self.newAddressButton.layer.cornerRadius = 10
                    self.newAddressButton.backgroundColor = UIColor.lightText
                    self.newAddressButton.layer.shadowColor = UIColor.black.cgColor
                    self.newAddressButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
                    self.newAddressButton.layer.shadowRadius = 2.5
                    self.newAddressButton.layer.shadowOpacity = 0.8
                    self.newAddressButton.setTitle("Address", for: .normal)
                    self.newAddressButton.addTarget(self, action: #selector(self.newAddress), for: .touchUpInside)
                    self.view.addSubview(self.newAddressButton)
                    
                }
                
            }
            
            self.settingsButton.removeFromSuperview()
            self.settingsButton = UIButton(frame: CGRect(x: 5, y: self.view.frame.maxY - 125, width: 90, height: 55))
            self.settingsButton.showsTouchWhenHighlighted = true
            self.settingsButton.layer.cornerRadius = 10
            self.settingsButton.backgroundColor = UIColor.lightText
            self.settingsButton.layer.shadowColor = UIColor.black.cgColor
            self.settingsButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.settingsButton.layer.shadowRadius = 2.5
            self.settingsButton.layer.shadowOpacity = 0.8
            self.settingsButton.setTitle("Settings", for: .normal)
            self.settingsButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            self.view.addSubview(self.settingsButton)
            
        }
        
    }
    
    func removeHomeScreen() {
        print("removeHomeScreen")
        
        DispatchQueue.main.async {
            
            self.newAddressButton.removeFromSuperview()
            self.importButton.removeFromSuperview()
            self.transactionsButton.removeFromSuperview()
            self.diceButton.removeFromSuperview()
            self.mayerMultipleButton.removeFromSuperview()
            self.checkAddressButton.removeFromSuperview()
            self.imageView.removeFromSuperview()
            self.settingsButton.removeFromSuperview()
            self.bitField.removeFromSuperview()
            
        }
        
    }
    
    @objc func userCreatesRandomness(gestureRecognizer: UIPanGestureRecognizer) {
        
        //remove buttons when bitcoin gets dragged
        self.checkAddressButton.removeFromSuperview()
        self.mayerMultipleButton.removeFromSuperview()
        self.diceButton.removeFromSuperview()
        self.transactionsButton.removeFromSuperview()
        self.importButton.removeFromSuperview()
        self.newAddressButton.removeFromSuperview()
        self.settingsButton.removeFromSuperview()
        
        //set up the drag ability and postion of the bitcoin
        let translation = gestureRecognizer.translation(in: view)
        let bitcoinView = gestureRecognizer.view!
        bitcoinView.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        //gets our source of the numbers that are displayed by tracking the x axis of the bitcoin from the center as user drags it
        let xFromCenter = bitcoinView.center.x - self.view.bounds.width / 2
        //converts negative numbers to positive numbers and appends them to an array of numbers which is the user radnomness, and conerts to string
        numberArray.append(String(describing: abs(Int(xFromCenter))))
        //takes the user generated randomness and then randomizes it a step further by randomnly shuffling the indexes of the array
        let shuffledArray = self.numberArray.shuffled()
        //converts the array into a string
        //let string = String(describing: shuffledArray)
        let joinedArray = shuffledArray.joined()
        
        //converts numbers to bits
        let oneToBits = joinedArray.replacingOccurrences(of: "1", with: "0")
        let twoToBits = oneToBits.replacingOccurrences(of: "2", with: "1")
        let threeToBits = twoToBits.replacingOccurrences(of: "3", with: "0")
        let fourToBits = threeToBits.replacingOccurrences(of: "4", with: "1")
        let fiveToBits = fourToBits.replacingOccurrences(of: "5", with: "0")
        let sixToBits = fiveToBits.replacingOccurrences(of: "6", with: "1")
        let sevenToBits = sixToBits.replacingOccurrences(of: "7", with: "0")
        let eightToBits = sevenToBits.replacingOccurrences(of: "8", with: "1")
        let nineToBits = eightToBits.replacingOccurrences(of: "9", with: "0")
        
        //displays random bits as user drags bitcoin and creates randomness
        bitField.text = nineToBits
        
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            DispatchQueue.main.async {
                self.rotateAnimation(imageView: self.imageView as! UIImageView)
            }
        }
        
        //senses user has stopped dragging the bitcoin
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            
            self.isInternetAvailable()
            
            for character in nineToBits {
                
                self.zero = self.zero + 1
                self.bitArray.append(String(character))
                
                if self.zero == 256 {
                    
                    let bits = self.bitArray.joined()
                    
                    self.parseBitResult = self.parseBinary(binary: bits)!
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        bitcoinView.center =  self.view.center
                        
                    }, completion: { _ in
                        
                        if self.connected == true {
                           
                            DispatchQueue.main.async {
                                
                                self.displayAlert(title: "Security Alert", message: "You should only create private keys offline. Please enable airplane mode, turn off wifi and try again.")
                            }
                            
                        }
                            
                            self.privateKeyWIF = self.createPrivateKey(userRandomness: self.parseBitResult).privateKeyAddress
                            
                            if self.privateKeyWIF != "" {
                                
                                self.addQRCodesAndLabels()
                                
                            } else {
                                
                                DispatchQueue.main.async {
                                    
                                    let alert = UIAlertController(title: "There was an error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .destructive, handler: { (action) in
                                        
                                        self.privateKeyQRCode = nil
                                        self.privateKeyImage = nil
                                        self.privateKeyQRView.image = nil
                                        self.privateKeyTitle.text = ""
                                        self.myField.text = ""
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
                                        
                                    }))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                    })
                }
            }
            
            if self.zero < 256 {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    bitcoinView.center =  self.view.center
                    
                }, completion: { _ in
                    
                    self.zero = 0
                    self.bitArray.removeAll()
                    
                    DispatchQueue.main.async {
                        self.displayAlert(title: "I'm sick, and the only prescription is more randomness!", message: "Please move the Bitcoin around more so we have a large enough number to generate a private key.")
                    }
                })
            }
        }
    }
    
    func addQRCodesAndLabels() {
        print("addQRCodesAndLabels")
        
        self.addressMode = true
        self.diceButton.removeFromSuperview()
        self.importButton.removeFromSuperview()
        self.clearMnemonicButton.removeFromSuperview()
        self.button.removeFromSuperview()
        self.importAction.removeFromSuperview()
        
        if self.watchOnlyMode {
            
            diceMode = false
            self.importAction.removeFromSuperview()
            self.outputMnemonic.removeFromSuperview()
            DispatchQueue.main.async {
                self.view.addSubview(self.scrollView)
            }
            
            self.privateKeyQRCode = self.generateQrCode(key: self.bitcoinAddress)
            self.privateKeyQRView = UIImageView(image: self.privateKeyQRCode!)
            self.privateKeyQRView.frame = CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 130, width: self.scrollView.frame.width - 10, height: self.scrollView.frame.width - 10)
            self.privateKeyQRView.alpha = 0
            self.scrollView.addSubview(self.privateKeyQRView)
            
            self.WIFprivateKeyFieldLabel = UILabel(frame: CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 150 + (self.scrollView.frame.width - 10) - 11, width: self.scrollView.frame.width - 10, height: 13))
            self.WIFprivateKeyFieldLabel.font = .systemFont(ofSize: 12)
            self.WIFprivateKeyFieldLabel.textColor = UIColor.black
            self.WIFprivateKeyFieldLabel.textAlignment = .left
            self.scrollView.addSubview(self.WIFprivateKeyFieldLabel)
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.imageView.alpha = 0
                self.bitField.alpha = 0
                
            }, completion: { _ in
                
                self.removeHomeScreen()
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.privateKeyQRView.alpha = 1
                    
                    
                }, completion: { _ in
                    
                    self.scrollView.setContentOffset(.zero, animated: false)
                    
                    DispatchQueue.main.async {
                        
                        self.WIFprivateKeyFieldLabel.text = "Legacy Format:"
                        self.privateKeyTitle = UILabel(frame: CGRect(x: self.scrollView.frame.minX, y: self.scrollView.frame.minY + 70, width: self.scrollView.frame.width, height: 50))
                        self.privateKeyTitle.text = "Legacy Bitcoin Address"
                        self.privateKeyTitle.font = .systemFont(ofSize: 32)
                        self.privateKeyTitle.textColor = UIColor.black
                        self.privateKeyTitle.textAlignment = .center
                        self.scrollView.addSubview(self.privateKeyTitle)
                        
                    }
                    
                    self.myField = UITextView (frame:CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.privateKeyQRView.frame.maxY + 40, width: self.view.frame.width - 50, height: 100))
                    self.myField.isEditable = false
                    self.myField.isSelectable = true
                    self.myField.font = .systemFont(ofSize: 24)
                    self.myField.text = self.bitcoinAddress
                    self.scrollView.addSubview(self.myField)
                    self.addHomeButton()
                    self.addBackUpButton()
                    self.zero = 0
                    self.bitArray.removeAll()
                    
                    
                })
            })
            
        } else {
            
            self.privateKeyMode = true
            diceMode = false
            self.outputMnemonic.removeFromSuperview()
            self.inputMnemonic.removeFromSuperview()
            
            DispatchQueue.main.async {
                self.view.addSubview(self.scrollView)
            }
            
            
            self.privateKeyText = self.privateKeyWIF
            self.privateKeyQRCode = self.generateQrCode(key: self.privateKeyWIF)
            self.privateKeyQRView = UIImageView(image: self.privateKeyQRCode!)
            self.privateKeyQRView.frame = CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 130, width: self.scrollView.frame.width - 10, height: self.scrollView.frame.width - 10)
            self.privateKeyQRView.alpha = 0
            self.scrollView.addSubview(self.privateKeyQRView)
            
            self.WIFprivateKeyFieldLabel = UILabel(frame: CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 150 + (self.scrollView.frame.width - 10) - 11, width: self.scrollView.frame.width - 10, height: 13))
            self.WIFprivateKeyFieldLabel.font = .systemFont(ofSize: 12)
            self.WIFprivateKeyFieldLabel.textColor = UIColor.black
            self.WIFprivateKeyFieldLabel.textAlignment = .left
            self.scrollView.addSubview(self.WIFprivateKeyFieldLabel)
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.imageView.alpha = 0
                self.bitField.alpha = 0
                
            }, completion: { _ in
                
                self.removeHomeScreen()
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.privateKeyQRView.alpha = 1
                    
                    
                }, completion: { _ in
                    
                    self.scrollView.setContentOffset(.zero, animated: false)
                    
                    self.WIFprivateKeyFieldLabel.text = "WIF Format:"
                    
                    self.privateKeyTitle = UILabel(frame: CGRect(x: self.scrollView.frame.minX, y: self.scrollView.frame.minY + 70, width: self.scrollView.frame.width, height: 50))
                    self.privateKeyTitle.text = "Bitcoin Private Key"
                    self.privateKeyTitle.font = .systemFont(ofSize: 32)
                    self.privateKeyTitle.textColor = UIColor.black
                    self.privateKeyTitle.textAlignment = .center
                    self.scrollView.addSubview(self.privateKeyTitle)
                    
                    self.myField = UITextView (frame:CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.privateKeyQRView.frame.maxY + 40, width: self.view.frame.width - 50, height: 100))
                    self.myField.isEditable = false
                    self.myField.isSelectable = true
                    self.myField.font = .systemFont(ofSize: 24)
                    self.myField.text = self.privateKeyWIF
                    self.scrollView.addSubview(self.myField)
                    self.addHomeButton()
                    self.addBackUpButton()
                    self.zero = 0
                    self.bitArray.removeAll()
                    
                    self.mnemonicLabel = UILabel(frame: CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 280 + (self.scrollView.frame.width - 10) - 11, width: self.scrollView.frame.width - 10, height: 13))
                    self.mnemonicLabel.text = "Recovery Phrase:"
                    self.mnemonicLabel.font = .systemFont(ofSize: 12)
                    self.mnemonicLabel.textColor = UIColor.black
                    self.mnemonicLabel.textAlignment = .left
                    self.scrollView.addSubview(self.mnemonicLabel)
                    
                    self.mnemonicView = UITextView (frame:CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 285 + (self.scrollView.frame.width - 10), width: self.scrollView.frame.width - 10, height: 175))
                    self.mnemonicView.text = self.recoveryPhrase
                    self.mnemonicView.isEditable = false
                    self.mnemonicView.isSelectable = true
                    self.mnemonicView.font = .systemFont(ofSize: 24)
                    self.scrollView.addSubview(self.mnemonicView)
                    
                    self.recoveryPhraseLabel = UILabel(frame: CGRect(x: self.scrollView.frame.minX + 5, y: self.mnemonicView.frame.maxY + 20, width: self.scrollView.frame.width - 10, height: 50))
                    self.recoveryPhraseLabel.text = "Recovery QR Code"
                    self.recoveryPhraseLabel.font = .systemFont(ofSize: 32)
                    self.recoveryPhraseLabel.textColor = UIColor.black
                    self.recoveryPhraseLabel.textAlignment = .center
                    self.scrollView.addSubview(self.recoveryPhraseLabel)
                    
                    self.recoveryPhraseImage = self.generateQrCode(key: self.recoveryPhrase)
                    self.recoveryPhraseQRView = UIImageView(image: self.recoveryPhraseImage!)
                    self.recoveryPhraseQRView.frame = CGRect(x: self.scrollView.frame.minX + 5, y: self.mnemonicView.frame.maxY + 90, width: self.scrollView.frame.width - 10, height: self.scrollView.frame.width - 10)
                    self.scrollView.addSubview(self.recoveryPhraseQRView)
                    
                })
                
            })
            
            
        }
        
        
    }
    
    @objc func importNow() {
        
        
        if let testInputMnemonic = BTCMnemonic.init(words: self.wordArray, password: "", wordListType: BTCMnemonicWordListType.english) {
           
            self.removeHomeScreen()
            self.inputMnemonic.resignFirstResponder()
            self.inputMnemonic.removeFromSuperview()
            
            let extendedKeyInput = testInputMnemonic.keychain
            print("keychainPrivKey = \(String(describing: extendedKeyInput?.extendedPrivateKey))")
            self.recoveryPhrase = self.listArray.joined()
            self.privateKeyWIF = self.derivePrivateKeyFromMasterKey(keychain: extendedKeyInput!).privateKeyAddress
            self.addQRCodesAndLabels()
            
        } else {
            
            print("error = \(self.wordArray)")
            DispatchQueue.main.async {
                self.outputMnemonic.text = ""
                self.wordArray.removeAll()
                self.listArray.removeAll()
                self.displayAlert(title: "Error", message: "Sorry that phrase is not BIP39 compatible, make sure you enter the correct words with no misspellings and no spaces after each word.")
            }
        }
        
        
    }
    
    func addHomeButton() {
        
        print("addHomeButton")
        
        DispatchQueue.main.async {
            
            self.button.removeFromSuperview()
            self.button = UIButton(frame: CGRect(x: 5, y: 20, width: 90, height: 55))
            self.button.showsTouchWhenHighlighted = true
            self.button.layer.cornerRadius = 10
            self.button.backgroundColor = UIColor.lightText
            self.button.layer.shadowColor = UIColor.black.cgColor
            self.button.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.button.layer.shadowRadius = 2.5
            self.button.layer.shadowOpacity = 0.8
            self.button.setTitle("Back", for: .normal)
            self.button.addTarget(self, action: #selector(self.home), for: .touchUpInside)
            self.view.addSubview(self.button)
            
            self.bitcoinAddressButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 155, y: 20, width: 150 , height: 55))
            self.bitcoinAddressButton.showsTouchWhenHighlighted = true
            self.bitcoinAddressButton.layer.cornerRadius = 10
            self.bitcoinAddressButton.backgroundColor = UIColor.lightText
            self.bitcoinAddressButton.layer.shadowColor = UIColor.black.cgColor
            self.bitcoinAddressButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.bitcoinAddressButton.layer.shadowRadius = 2.5
            self.bitcoinAddressButton.layer.shadowOpacity = 0.8
            
            if self.watchOnlyMode {
                
                self.bitcoinAddressButton.setTitle("Show XPUB", for: .normal)
                
            } else {
                
               self.bitcoinAddressButton.setTitle("Show Address", for: .normal)
                
            }
            
            self.bitcoinAddressButton.addTarget(self, action: #selector(self.getAddress), for: .touchUpInside)
            self.view.addSubview(self.bitcoinAddressButton)
        }
    }
    
    func addImportActionButton() {
        print("addImportActionButton")
        
        DispatchQueue.main.async {
            self.importAction = UIButton(frame: CGRect(x: 10, y: self.inputMnemonic.frame.maxY + 10, width: self.view.frame.width - 20, height: 50))
            self.importAction.showsTouchWhenHighlighted = true
            self.importAction.titleLabel?.textAlignment = .center
            self.importAction.layer.cornerRadius = 10
            self.importAction.backgroundColor = UIColor.lightText
            self.importAction.layer.shadowColor = UIColor.black.cgColor
            self.importAction.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.importAction.layer.shadowRadius = 2.5
            self.importAction.layer.shadowOpacity = 0.8
            self.importAction.setTitle("Import", for: .normal)
            self.importAction.addTarget(self, action: #selector(self.importNow), for: .touchUpInside)
            self.view.addSubview(self.importAction)
        }
        
    }
    
    @objc func newAddress() {
        print("newAddress")
        
        watchOnlyMode = true
        self.removeHomeScreen()
        
        let int = UInt32((UserDefaults.standard.object(forKey: "int") as! Int) + 1)
        UserDefaults.standard.set(int, forKey: "int")
        print("int = \(int)")
        
        let xpub = UserDefaults.standard.object(forKey: "xpub") as! String
        let childKeychain = BTCKeychain.init(extendedKey: xpub)
        let newAddress = childKeychain?.key(at: int).address
        
        let legacyAddress1 = (newAddress?.description)!
        let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
        self.bitcoinAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
        self.addQRCodesAndLabels()
        
    }
    
    func addBackButton() {
        print("addBackButton")
        DispatchQueue.main.async {
            self.button.removeFromSuperview()
            self.button = UIButton(frame: CGRect(x: 5, y: 20, width: 90, height: 55))
            self.button.showsTouchWhenHighlighted = true
            self.button.layer.cornerRadius = 10
            self.button.backgroundColor = UIColor.lightText
            self.button.layer.shadowColor = UIColor.black.cgColor
            self.button.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.button.layer.shadowRadius = 2.5
            self.button.layer.shadowOpacity = 0.8
            self.button.setTitle("Back", for: .normal)
            self.button.addTarget(self, action: #selector(self.back), for: .touchUpInside)
            self.view.addSubview(self.button)
        }
    }
    
    @objc func back() {
        print("back")
        
        for dice in self.diceArray {
            dice.removeFromSuperview()
        }
        self.diceArray.removeAll()
        self.tappedIndex = 0
        self.percentageLabel.removeFromSuperview()
        self.inputMnemonic.resignFirstResponder()
        self.inputMnemonic.removeFromSuperview()
        self.importAction.removeFromSuperview()
        self.importButton.removeFromSuperview()
        self.button.removeFromSuperview()
        self.clearMnemonicButton.removeFromSuperview()
        self.clearButton.removeFromSuperview()
        self.addHomeScreen()
        
    }
    
    @objc func getAddress() {
        print("getAddress")
        
    
        if watchOnlyMode {
            print("watchOnlyMode")
            
            if addressMode {
                print("addressMode")
                
                DispatchQueue.main.async {
                    
                    let xpub = UserDefaults.standard.object(forKey: "xpub") as! String
                    self.privateKeyTitle.text = "Extended Public Key"
                    self.privateKeyTitle.adjustsFontSizeToFitWidth = true
                    self.WIFprivateKeyFieldLabel.text = "xpub:"
                    self.myField.text = xpub
                    self.privateKeyQRCode = self.generateQrCode(key: xpub)
                    self.privateKeyQRView.image = self.privateKeyQRCode!
                    self.bitcoinAddressButton.setTitle("Show Address", for: .normal)
                    self.addressMode = false
                    
                }
                
            } else {
                print("extendedPublicKeyMode")
                
                DispatchQueue.main.async {
                    
                    self.myField.text = self.bitcoinAddress
                    self.privateKeyQRCode = self.generateQrCode(key: self.bitcoinAddress)
                    self.privateKeyQRView.image = self.privateKeyQRCode!
                    self.privateKeyTitle.text = "Legacy Bitcoin Address"
                    self.WIFprivateKeyFieldLabel.text = "Legacy Format:"
                    self.privateKeyTitle.adjustsFontSizeToFitWidth = true
                    self.bitcoinAddressButton.setTitle("Show XPUB", for: .normal)
                    self.addressMode = true
                    
                }
                
            }
            
        } else {
            
            if privateKeyMode {
                
                DispatchQueue.main.async {
                    
                    self.myField.text = self.bitcoinAddress
                    self.privateKeyQRCode = self.generateQrCode(key: self.bitcoinAddress)
                    self.privateKeyQRView.image = self.privateKeyQRCode!
                    
                    if self.segwitMode {
                        
                        DispatchQueue.main.async {
                            self.privateKeyTitle.text = "Segwit Address"
                            self.WIFprivateKeyFieldLabel.text = "Native Segwit Bech32 Format:"
                            
                        }
                        
                    } else if self.legacyMode {
                        
                        DispatchQueue.main.async {
                            self.privateKeyTitle.text = "Legacy Bitcoin Address"
                            self.WIFprivateKeyFieldLabel.text = "Legacy Format:"
                        }
                        
                    }
                    
                    self.privateKeyTitle.adjustsFontSizeToFitWidth = true
                    self.bitcoinAddressButton.setTitle("Show Private Key", for: .normal)
                    self.privateKeyMode = false
                    //self.extendedPublicKeyMode = false
                    
                }

                
            } else {
                
                DispatchQueue.main.async {
                    
                    self.privateKeyTitle.text = "Bitcoin Private Key"
                    self.WIFprivateKeyFieldLabel.text = "WIF Format:"
                    self.myField.text = self.privateKeyText
                    self.privateKeyQRCode = self.generateQrCode(key: self.privateKeyText)
                    self.privateKeyQRView.image = self.privateKeyQRCode!
                    self.bitcoinAddressButton.setTitle("Show Address", for: .normal)
                    self.privateKeyMode = true
                    //self.segwitAddressMode = false
                    //self.privateKeyMode = true
                    
                }
                
            }/* else if segwitAddressMode {
                
                DispatchQueue.main.async {
                    
                    self.privateKeyTitle.text = "Legacy Bitcoin Address"
                    self.privateKeyTitle.adjustsFontSizeToFitWidth = true
                    self.WIFprivateKeyFieldLabel.text = "Legacy Format:"
                    self.myField.text = self.legacyAddress
                    self.privateKeyQRCode = self.generateQrCode(key: self.legacyAddress)
                    self.privateKeyQRView.image = self.privateKeyQRCode!
                    self.bitcoinAddressButton.setTitle("Show Private Key", for: .normal)
                    self.privateKeyMode = false
                    self.segwitAddressMode = false
                    self.legacyAddressMode = true
                    
                }
                
            } else if legacyAddressMode {
                
                DispatchQueue.main.async {
                    
                    self.privateKeyTitle.text = "Bitcoin Private Key"
                    self.WIFprivateKeyFieldLabel.text = "WIF Format:"
                    self.myField.text = self.privateKeyText
                    self.privateKeyQRCode = self.generateQrCode(key: self.privateKeyText)
                    self.privateKeyQRView.image = self.privateKeyQRCode!
                    self.bitcoinAddressButton.setTitle("Show Segwit", for: .normal)
                    self.privateKeyMode = false
                    self.segwitAddressMode = false
                    self.privateKeyMode = true
                    
                }
            }*/
            
        }
        
        
    }
    
    @objc func home() {
        print("home")
        DispatchQueue.main.async {
            
            var title = String()
            var message = String()
            
            if self.watchOnlyMode {
                
                title = "Have you saved the Address?"
                message = "Ensure you have saved this before going back otherwise the addresses will be lost, we do save your \"extended public key\" for you so you can always create a new address based on the last private key you created/imported."
                
            } else {
                
                title = "Have you saved this Private Key?"
                message = "Ensure you have saved this before going back if you'd like to use this Private Key in the future."
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("I saved it, go back", comment: ""), style: .destructive, handler: { (action) in
                
                if self.watchOnlyMode {
                    
                    self.watchOnlyMode = false
                    self.bitcoinAddressButton.removeFromSuperview()
                    self.privateKeyQRView.image = nil
                    self.privateKeyQRCode = nil
                    self.privateKeyImage = nil
                    self.privateKeyQRView.image = nil
                    self.privateKeyTitle.text = ""
                    self.myField.text = ""
                    self.imageView.removeFromSuperview()
                    self.imageView = nil
                    self.button.removeFromSuperview()
                    self.backUpButton.removeFromSuperview()
                    self.privateKeyText = ""
                    self.WIFprivateKeyFieldLabel.removeFromSuperview()
                    self.addHomeScreen()
                    
                } else {
                    
                    self.bitcoinAddressButton.removeFromSuperview()
                    self.privateKeyQRView.image = nil
                    self.privateKeyQRCode = nil
                    self.privateKeyImage = nil
                    self.privateKeyQRView.image = nil
                    self.privateKeyTitle.text = ""
                    self.myField.text = ""
                    self.imageView.removeFromSuperview()
                    self.imageView = nil
                    self.button.removeFromSuperview()
                    self.backUpButton.removeFromSuperview()
                    self.numberArray.removeAll()
                    self.joinedArray = ""
                    self.privateKeyText = ""
                    self.zero = 0
                    self.bitArray.removeAll()
                    self.mnemonicView.removeFromSuperview()
                    self.mnemonicLabel.removeFromSuperview()
                    self.recoveryPhraseQRView.removeFromSuperview()
                    self.recoveryPhraseLabel.removeFromSuperview()
                    self.WIFprivateKeyFieldLabel.removeFromSuperview()
                    self.addHomeScreen()
                }
                
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
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
            self.backUpButton = UIButton(frame: CGRect(x: self.view.center.x - 150, y: self.view.frame.maxY - 60, width: 300, height: 55))
            self.backUpButton.showsTouchWhenHighlighted = true
            self.backUpButton.layer.cornerRadius = 10
            self.backUpButton.backgroundColor = UIColor.lightText
            self.backUpButton.layer.shadowColor = UIColor.black.cgColor
            self.backUpButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.backUpButton.layer.shadowRadius = 2.5
            self.backUpButton.layer.shadowOpacity = 0.8
            self.backUpButton.setTitle("Back Up / Share / Save / Copy", for: .normal)
            self.backUpButton.addTarget(self, action: #selector(self.airDropImage), for: .touchUpInside)
            self.view.addSubview(self.backUpButton)
        }
        
    }
    
    @objc func goTo(sender: UIButton) {
        print("goTo")
        
        switch sender {
            
        case self.settingsButton:
            
            print("go to settings")
            self.performSegue(withIdentifier: "settings", sender: self)
            
        case self.diceButton:
            
            sender.removeFromSuperview()
            self.importButton.removeFromSuperview()
            self.removeHomeScreen()
            self.showDice()
            
        case self.mayerMultipleButton:
            
            if self.imageView != nil {
                
                self.imageView.removeFromSuperview()
                self.imageView = nil
            }
            
            self.performSegue(withIdentifier: "goToMayerMultiple", sender: self)
            
        case self.transactionsButton:
            
            self.performSegue(withIdentifier: "transaction", sender: self)
            
        case self.checkAddressButton:
            
            self.performSegue(withIdentifier: "checkAddress", sender: self)
            
        default:
            break
        }
        
       
    }
    
    @objc func airDropImage() {
        
        print("airDropImage")
        
        DispatchQueue.main.async {
            
            if self.watchOnlyMode {
                
                self.watchOnlyAlert()
                
            } else {
                
                self.privateKeyAlert()
                
            }
        }
    }
    
    func watchOnlyAlert() {
        print("watchOnlyAlert")
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        if self.extendedPublicKeyMode {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("XPUB QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.privateKeyImage) {
                    
                    let fileName = self.getDocumentsDirectory().appendingPathComponent("xpubKey.png")
                    
                    try? data.write(to: fileName)
                    
                    let objectsToShare = [fileName]
                    DispatchQueue.main.async {
                        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        self.present(activityController, animated: true, completion: nil)
                    }
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("XPUB Key Text", comment: ""), style: .default, handler: { (action) in
                
                let activityViewController = UIActivityViewController(activityItems: [self.myField.text!], applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
           
            
            
        } else if self.segwitAddressMode {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Segwit Address QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.privateKeyImage) {
                    
                    let fileName = self.getDocumentsDirectory().appendingPathComponent("segwitAddress.png")
                    
                    try? data.write(to: fileName)
                    
                    let objectsToShare = [fileName]
                    DispatchQueue.main.async {
                        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        self.present(activityController, animated: true, completion: nil)
                    }
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Segwit Address Text", comment: ""), style: .default, handler: { (action) in
                
                let textToShare = [self.bitcoinAddress]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else if self.legacyAddressMode {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Legacy Address QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.privateKeyImage) {
                    
                    let fileName = self.getDocumentsDirectory().appendingPathComponent("bitcoinAddress.png")
                    
                    try? data.write(to: fileName)
                    
                    let objectsToShare = [fileName]
                    DispatchQueue.main.async {
                        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        self.present(activityController, animated: true, completion: nil)
                    }
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Legacy Address Text", comment: ""), style: .default, handler: { (action) in
                
                let textToShare = [self.legacyAddress]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
           

        }
        
    }
    
    func privateKeyAlert() {
        
        print("privateKeyAlert")
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        if self.privateKeyMode {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Private Key QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.privateKeyImage) {
                    
                    let fileName = self.getDocumentsDirectory().appendingPathComponent("privateKey.png")
                    
                    try? data.write(to: fileName)
                    
                    let objectsToShare = [fileName]
                    
                    DispatchQueue.main.async {
                        
                        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        self.present(activityController, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Recovery Phrase QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.recoveryPhraseImage) {
                    
                    let fileName = self.getDocumentsDirectory().appendingPathComponent("recoveryPhrase.png")
                    
                    try? data.write(to: fileName)
                    
                    let objectsToShare = [fileName]
                    
                    DispatchQueue.main.async {
                        
                        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        self.present(activityController, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Private Key Text", comment: ""), style: .default, handler: { (action) in
                
                let activityViewController = UIActivityViewController(activityItems: [self.privateKeyText], applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Recovery Phrase Text", comment: ""), style: .default, handler: { (action) in
                
                let textToShare = [self.recoveryPhrase]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
        } else if self.legacyAddressMode {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Legacy Address QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.privateKeyImage) {
                    
                    let fileName = self.getDocumentsDirectory().appendingPathComponent("bitcoinAddress.png")
                    
                    try? data.write(to: fileName)
                    
                    let objectsToShare = [fileName]
                    DispatchQueue.main.async {
                        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        self.present(activityController, animated: true, completion: nil)
                    }
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Recovery Phrase QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.recoveryPhraseImage) {
                    
                    let fileName = self.getDocumentsDirectory().appendingPathComponent("recoveryPhrase.png")
                    
                    try? data.write(to: fileName)
                    
                    let objectsToShare = [fileName]
                    
                    DispatchQueue.main.async {
                        
                        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        self.present(activityController, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Legacy Address Text", comment: ""), style: .default, handler: { (action) in
                
                let textToShare = [self.legacyAddress]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Recovery Phrase Text", comment: ""), style: .default, handler: { (action) in
                
                let textToShare = [self.recoveryPhrase]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
        } else if self.segwitAddressMode {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Segwit Address QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.privateKeyImage) {
                    
                    let fileName = self.getDocumentsDirectory().appendingPathComponent("segwitAddress.png")
                    
                    try? data.write(to: fileName)
                    
                    let objectsToShare = [fileName]
                    DispatchQueue.main.async {
                        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        self.present(activityController, animated: true, completion: nil)
                    }
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Recovery Phrase QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.recoveryPhraseImage) {
                    
                    let fileName = self.getDocumentsDirectory().appendingPathComponent("recoveryPhrase.png")
                    
                    try? data.write(to: fileName)
                    
                    let objectsToShare = [fileName]
                    
                    DispatchQueue.main.async {
                        
                        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        self.present(activityController, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Segwit Address Text", comment: ""), style: .default, handler: { (action) in
                
                let textToShare = [self.bitcoinAddress]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Recovery Phrase Text", comment: ""), style: .default, handler: { (action) in
                
                let textToShare = [self.recoveryPhrase]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        print("getDocumentsDirectory")
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
    }
    
    func rotateAnimation(imageView:UIImageView,duration: CFTimeInterval = 2.0) {
        
        DispatchQueue.main.async {
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(.pi * 8.0)
            rotateAnimation.duration = duration
            rotateAnimation.repeatCount = Float.greatestFiniteMagnitude;
            imageView.layer.add(rotateAnimation, forKey: nil)
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
            self.percentageLabel.font = UIFont.systemFont(ofSize: 30)
            self.percentageLabel.textAlignment = .center
            self.view.addSubview(self.percentageLabel)
        }
    }
    
    func addClearButton() {
        print("addClearButton")
        
        DispatchQueue.main.async {
            self.clearButton.removeFromSuperview()
            self.clearButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 105, y: 20, width: 100 , height: 55))
            self.clearButton.showsTouchWhenHighlighted = true
            self.clearButton.backgroundColor = UIColor.lightText
            self.clearButton.layer.cornerRadius = 10
            self.clearButton.layer.shadowColor = UIColor.black.cgColor
            self.clearButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.clearButton.layer.shadowRadius = 2.5
            self.clearButton.layer.shadowOpacity = 0.8
            self.clearButton.setTitle("Clear", for: .normal)
            self.clearButton.addTarget(self, action: #selector(self.tapClearDice), for: .touchUpInside)
            self.view.addSubview(self.clearButton)
        }
        
    }
    
    func addClearMnemonicButton() {
        print("addClearMnemonicButton")
        
        DispatchQueue.main.async {
            self.clearMnemonicButton.removeFromSuperview()
            self.clearMnemonicButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 105, y: 20, width: 100 , height: 55))
            self.clearMnemonicButton.showsTouchWhenHighlighted = true
            self.clearMnemonicButton.backgroundColor = UIColor.lightText
            self.clearMnemonicButton.layer.cornerRadius = 10
            self.clearMnemonicButton.layer.shadowColor = UIColor.black.cgColor
            self.clearMnemonicButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.clearMnemonicButton.layer.shadowRadius = 2.5
            self.clearMnemonicButton.layer.shadowOpacity = 0.8
            self.clearMnemonicButton.setTitle("Clear", for: .normal)
            self.clearMnemonicButton.addTarget(self, action: #selector(self.tapClearMnemonic), for: .touchUpInside)
            self.view.addSubview(self.clearMnemonicButton)
        }
        
    }
    
    @objc func tapClearMnemonic() {
        print("tapClearMnemonic")
        DispatchQueue.main.async {
            
            self.wordArray.removeAll()
            self.listArray.removeAll()
            self.outputMnemonic.text = ""
            
        }
    }
    
    @objc func tapClearDice() {
        print("tapClearDice")
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
                            
                            let alert = UIAlertController(title: NSLocalizedString("Are you sure you have input the dice values correctly?", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes, I'm sure", comment: ""), style: .default, handler: { (action) in
                                
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
                                
                                self.privateKeyWIF = self.createPrivateKey(userRandomness: self.parseBitResult).privateKeyAddress
                                self.button.removeFromSuperview()
                                self.addQRCodesAndLabels()
                                
                            }))
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("No, let me check", comment: ""), style: .default, handler: { (action) in
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                        
                    } else {
                        
                    }
                    
                }
                
            }
            
        }
        
        self.randomBits.removeAll()
        
    }
    
    @objc func tapDice(sender: UIButton!) {
        
        self.isInternetAvailable()
        
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
        
        if self.connected == false {
            
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
                        
                        self.displayAlert(title: "", message: "We make it impossible for you to input the dice values out of order becasue we don't want you to accidentally create a Private Key that is not based on true cryptographic secure randomness. We also do this to make it impossible for you to accidentaly tap and change a value of a dice you have already input. Secure keys ARE WORTH the effort!")
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Start Over", comment: ""), style: .destructive, handler: { (action) in
                        
                        self.clearDice()
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Don't show me this again", comment: ""), style: .destructive, handler: { (action) in
                        
                        UserDefaults.standard.set(true, forKey: "hideExplanation")
                        self.hideExplanation = true
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                self.displayAlert(title: "Turn on airplane mode to create private keys securely.", message: "The idea is to never let your Bitcoin private key touch the interent, secure keys are worth the effort.")
            }
        }
    }
    
    func showDice() {
        print("showDice")
        
        diceMode = true
        //self.clearMnemonicButton.removeFromSuperview()
        self.addBackButton()
        self.addClearButton()
        self.outputMnemonic.removeFromSuperview()
        self.isInternetAvailable()
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

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}



