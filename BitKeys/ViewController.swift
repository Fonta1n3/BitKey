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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.object(forKey: "hideExplanation") != nil {
            
            self.hideExplanation = UserDefaults.standard.bool(forKey: "hideExplanation")
            
        } else {
            
            self.hideExplanation = false
            
        }
        
        inputMnemonic.delegate = self
        privateKeyMode = true
        showBitcoin()
        
        print("width  = \(view.frame.width)")
        
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 3700)
        
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
    
    func showBitcoin() {
        
        addCheckAddressButton()
        addMayerMultipleButton()
        addDiceButton()
        addTransactionsButton()
        addImportButton()
        
        bitField = UITextView (frame:CGRect(x: view.center.x - (self.view.frame.width / 2), y: view.center.y - (self.view.frame.height / 2), width: self.view.frame.width, height: self.view.frame.height))
        bitField.isUserInteractionEnabled = false
        bitField.font = .systemFont(ofSize: 24)
        self.view.addSubview(bitField)
        
        let bitcoinImage = UIImage(named: "bitcoinIcon.png")
        imageView = UIImageView(image: bitcoinImage!)
        imageView.center = view.center
        imageView.frame = CGRect(x: view.center.x - 100, y: view.center.y - 100, width: 200, height: 200)
        rotateAnimation(imageView: imageView as! UIImageView)
        
        let bitcoinDragged = UIPanGestureRecognizer(target: self, action: #selector(self.userCreatesRandomness(gestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(bitcoinDragged)
        view.addSubview(imageView)
        
    }
    
    func derivePrivateKeyFromMasterKey(keychain: BTCKeychain) -> (privateKeyAddress: String, legacyAddress: String, segwitAddress: String) {
        
        let privateKeyHD = keychain.key.privateKeyAddress
        let addressHD = keychain.key.address
        print("privateKeyHD = \(String(describing: privateKeyHD))")
        print("addressHD = \(String(describing: addressHD))")
        let privateKey2 = privateKeyHD!.description
        var privateKey3 = privateKey2.components(separatedBy: " ")
        self.privateKeyWIF = privateKey3[1].replacingOccurrences(of: ">", with: "")
        let legacyAddress1 = addressHD!.description
        let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
        self.legacyAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
        
        let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain.key.compressedPublicKey as Data!) as Data!) as Data!
        
        do {
            //bc for mainnet and tb for testnet
            self.bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
            print("segwitBech32 = \(self.bitcoinAddress)")
            
        } catch {
            
            self.displayAlert(title: "Error", message: "Please try again.")
            return("", "", "")
        }
        
        print("privatekey = \(self.privateKeyWIF)")
        print("address = \(self.bitcoinAddress)")
        keychain.key.clear()
        
        return (self.privateKeyWIF, self.legacyAddress, self.bitcoinAddress)
        
    }
    
    func createPrivateKey(userRandomness: BigInt) -> (privateKeyAddress: String, publicKeyAddress: String) {
        
        let data = BigUInt(userRandomness).serialize()
        let mnemonic = BTCMnemonic.init(entropy: data, password: "", wordListType: BTCMnemonicWordListType.english)
        self.words = (mnemonic?.words.description)!
        let formatMnemonic1 = self.words.replacingOccurrences(of: "[", with: "")
        let formatMnemonic2 = formatMnemonic1.replacingOccurrences(of: "]", with: "")
        self.recoveryPhrase = formatMnemonic2.replacingOccurrences(of: ",", with: "")
        let extendedKey = mnemonic?.keychain
        let keychain = extendedKey
        //save pubkey to create future addresses
        let privateKeyHD = keychain?.key.privateKeyAddress
        let addressHD = keychain?.key.address
        let privateKey2 = privateKeyHD!.description
        var privateKey3 = privateKey2.components(separatedBy: " ")
        self.privateKeyWIF = privateKey3[1].replacingOccurrences(of: ">", with: "")
        let legacyAddress1 = addressHD!.description
        let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
        self.legacyAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
        
        let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain?.key.compressedPublicKey as Data!) as Data!) as Data!
        
        do {
            //bc for mainnet and tb for testnet
            self.bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
            print("segwitBech32 = \(self.bitcoinAddress)")
            
        } catch {
            
            self.displayAlert(title: "Error", message: "Please try again.")
            return("", "")
        }
        print("privatekey = \(self.privateKeyWIF)")
        print("address = \(self.bitcoinAddress)")
        keychain?.key.clear()
        
        return (self.privateKeyWIF, self.bitcoinAddress)
        
    }
    
    @objc func importMnemonic() {
        
        self.isInternetAvailable()
        
        if self.connected == true {
            
            DispatchQueue.main.async {
                self.displayAlert(title: "Security Alert", message: "You are connected to the internet, for maximum security please enable airplane mode before you enter your recovery phrase.")
            }
        }
        
        self.imageView.removeFromSuperview()
        self.checkAddressButton.removeFromSuperview()
        self.mayerMultipleButton.removeFromSuperview()
        self.diceButton.removeFromSuperview()
        self.transactionsButton.removeFromSuperview()
        self.importButton.removeFromSuperview()
        
        self.inputMnemonic.frame = CGRect(x: self.view.frame.minX + 5, y: self.view.frame.minY + 100, width: self.view.frame.width - 10, height: 50)
        self.inputMnemonic.textAlignment = .center
        self.inputMnemonic.borderStyle = .roundedRect
        self.inputMnemonic.autocapitalizationType = .none
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
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        
        self.wordArray.append(self.inputMnemonic.text!)
        self.listArray.append(self.inputMnemonic.text! + "  ")
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
    
    @objc func userCreatesRandomness(gestureRecognizer: UIPanGestureRecognizer) {
        
        //remove buttons when bitcoin gets dragged
        self.checkAddressButton.removeFromSuperview()
        self.mayerMultipleButton.removeFromSuperview()
        self.diceButton.removeFromSuperview()
        self.transactionsButton.removeFromSuperview()
        self.importButton.removeFromSuperview()
        
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
                        
                        if self.connected == false {
                            
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
                                        self.showBitcoin()
                                        
                                    }))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                }
                                
                            }
                            
                        } else {
                            DispatchQueue.main.async {
                                self.zero = 0
                                self.bitArray.removeAll()
                                self.displayAlert(title: "Your devices connection may not be secure.", message: "You should only create private keys offline. Please enable airplane mode, turn off wifi and try again.")
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
        
        self.privateKeyText = self.privateKeyWIF
        self.privateKeyQRCode = self.generateQrCode(key: self.privateKeyWIF)
        self.privateKeyQRView = UIImageView(image: self.privateKeyQRCode!)
        self.privateKeyQRView.frame = CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 120, width: self.scrollView.frame.width - 10, height: self.scrollView.frame.width - 10)
        self.privateKeyQRView.alpha = 0
        self.scrollView.addSubview(self.privateKeyQRView)
        
        self.WIFprivateKeyFieldLabel = UILabel(frame: CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 140 + (self.scrollView.frame.width - 10) - 11, width: self.scrollView.frame.width - 10, height: 13))
        self.WIFprivateKeyFieldLabel.font = .systemFont(ofSize: 12)
        self.WIFprivateKeyFieldLabel.textColor = UIColor.black
        self.WIFprivateKeyFieldLabel.textAlignment = .left
        self.scrollView.addSubview(self.WIFprivateKeyFieldLabel)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.imageView.alpha = 0
            self.bitField.alpha = 0
            
        }, completion: { _ in
            
            self.imageView.removeFromSuperview()
            self.bitField.removeFromSuperview()
            self.view.addSubview(self.scrollView)
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.privateKeyQRView.alpha = 1
                
                
            }, completion: { _ in
                
                self.scrollView.setContentOffset(.zero, animated: false)
                
                self.WIFprivateKeyFieldLabel.text = "WIF Format:"
                
                self.privateKeyTitle = UILabel(frame: CGRect(x: self.scrollView.frame.minX, y: self.scrollView.frame.minY + 60, width: self.scrollView.frame.width, height: 50))
                self.privateKeyTitle.text = "Bitcoin Private Key"
                self.privateKeyTitle.font = .systemFont(ofSize: 32)
                self.privateKeyTitle.textColor = UIColor.black
                self.privateKeyTitle.textAlignment = .center
                self.scrollView.addSubview(self.privateKeyTitle)
                
                self.myField = UITextView (frame:CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.privateKeyQRView.frame.maxY + 30, width: self.view.frame.width - 50, height: 100))
                self.myField.isEditable = false
                self.myField.isSelectable = true
                self.myField.font = .systemFont(ofSize: 24)
                self.myField.text = self.privateKeyWIF
                self.scrollView.addSubview(self.myField)
                self.addHomeButton()
                self.addBackUpButton()
                self.zero = 0
                self.bitArray.removeAll()
                
                self.mnemonicLabel = UILabel(frame: CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 270 + (self.scrollView.frame.width - 10) - 11, width: self.scrollView.frame.width - 10, height: 13))
                self.mnemonicLabel.text = "Recovery Phrase:"
                self.mnemonicLabel.font = .systemFont(ofSize: 12)
                self.mnemonicLabel.textColor = UIColor.black
                self.mnemonicLabel.textAlignment = .left
                self.scrollView.addSubview(self.mnemonicLabel)
                
                self.mnemonicView = UITextView (frame:CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 275 + (self.scrollView.frame.width - 10), width: self.scrollView.frame.width - 10, height: 175))
                self.mnemonicView.text = self.recoveryPhrase
                self.mnemonicView.isEditable = false
                self.mnemonicView.isSelectable = true
                self.mnemonicView.font = .systemFont(ofSize: 24)
                self.scrollView.addSubview(self.mnemonicView)
                
                self.recoveryPhraseLabel = UILabel(frame: CGRect(x: self.scrollView.frame.minX + 5, y: self.mnemonicView.frame.maxY + 10, width: self.scrollView.frame.width - 10, height: 50))
                self.recoveryPhraseLabel.text = "Recovery QR Code"
                self.recoveryPhraseLabel.font = .systemFont(ofSize: 32)
                self.recoveryPhraseLabel.textColor = UIColor.black
                self.recoveryPhraseLabel.textAlignment = .center
                self.scrollView.addSubview(self.recoveryPhraseLabel)
                
                self.recoveryPhraseImage = self.generateQrCode(key: self.recoveryPhrase)
                self.recoveryPhraseQRView = UIImageView(image: self.recoveryPhraseImage!)
                self.recoveryPhraseQRView.frame = CGRect(x: self.scrollView.frame.minX + 5, y: self.mnemonicView.frame.maxY + 80, width: self.scrollView.frame.width - 10, height: self.scrollView.frame.width - 10)
                self.scrollView.addSubview(self.recoveryPhraseQRView)
                
            })
            
        })
    }
    
    @objc func importNow() {
        
        
        if let testInputMnemonic = BTCMnemonic.init(words: self.wordArray, password: "", wordListType: BTCMnemonicWordListType.english) {
           
            self.checkAddressButton.removeFromSuperview()
            self.mayerMultipleButton.removeFromSuperview()
            self.diceButton.removeFromSuperview()
            self.transactionsButton.removeFromSuperview()
            self.importButton.removeFromSuperview()
            self.inputMnemonic.resignFirstResponder()
            self.inputMnemonic.removeFromSuperview()
            
            let extendedKeyInput = testInputMnemonic.keychain
            print("keychainPrivKey = \(String(describing: extendedKeyInput?.extendedPrivateKey))")
            self.privateKeyWIF = self.derivePrivateKeyFromMasterKey(keychain: extendedKeyInput!).privateKeyAddress
            addQRCodesAndLabels()
            
        } else {
            
            print("error = \(self.wordArray)")
        }
        
        
    }
    
    func addHomeButton() {
        
        DispatchQueue.main.async {
            self.button = UIButton(frame: CGRect(x: 0, y: 0, width: 100 , height: 55))
            self.button.showsTouchWhenHighlighted = true
            self.button.backgroundColor = .black
            self.button.setTitle("Back", for: .normal)
            self.button.addTarget(self, action: #selector(self.home), for: .touchUpInside)
            self.view.addSubview(self.button)
            
            self.bitcoinAddressButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 150, y: 0, width: 150 , height: 55))
            self.bitcoinAddressButton.showsTouchWhenHighlighted = true
            self.bitcoinAddressButton.backgroundColor = .black
            self.bitcoinAddressButton.setTitle("Show Address", for: .normal)
            self.bitcoinAddressButton.addTarget(self, action: #selector(self.getAddress), for: .touchUpInside)
            self.view.addSubview(self.bitcoinAddressButton)
        }
    }
    
    func addImportActionButton() {
        
        DispatchQueue.main.async {
            self.importAction = UIButton(frame: CGRect(x: 0, y: self.inputMnemonic.frame.maxY + 10, width: self.view.frame.width , height: 50))
            self.importAction.showsTouchWhenHighlighted = true
            self.importAction.titleLabel?.textAlignment = .center
            self.importAction.backgroundColor = .black
            self.importAction.setTitle("Import", for: .normal)
            self.importAction.addTarget(self, action: #selector(self.importNow), for: .touchUpInside)
            self.view.addSubview(self.importAction)
        }
        
    }
    
    func addBackButton() {
        
        DispatchQueue.main.async {
            self.button = UIButton(frame: CGRect(x: 0, y: 0, width: 100 , height: 55))
            self.button.showsTouchWhenHighlighted = true
            self.button.backgroundColor = .black
            self.button.setTitle("Back", for: .normal)
            self.button.addTarget(self, action: #selector(self.back), for: .touchUpInside)
            self.view.addSubview(self.button)
        }
    }
    
    @objc func back() {
        
        self.inputMnemonic.resignFirstResponder()
        self.inputMnemonic.removeFromSuperview()
        self.importButton.removeFromSuperview()
        self.showBitcoin()
    }
    
    @objc func getAddress() {
        
        if privateKeyMode {
           
            DispatchQueue.main.async {
                
                self.privateKeyTitle.text = "Segwit Address"
                self.WIFprivateKeyFieldLabel.text = "Native Segwit Bech32 Format:"
                self.myField.text = self.bitcoinAddress
                self.privateKeyQRCode = self.generateQrCode(key: self.bitcoinAddress)
                self.privateKeyQRView.image = self.privateKeyQRCode!
                self.bitcoinAddressButton.setTitle("Show Legacy", for: .normal)
                self.privateKeyMode = false
                self.segwitAddressMode = true
                self.legacyAddressMode = false
                
            }
            
        } else if segwitAddressMode {
            
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
        }
    }
    
    @objc func home() {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Have you saved this Private Key?", message: "Ensure you have saved this before going back if you'd like to use this Private Key in the future.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("I saved it, go back", comment: ""), style: .destructive, handler: { (action) in
                
                self.privateKeyQRView.image != nil
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
                self.showBitcoin()
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func generateQrCode(key: String) -> UIImage? {
        
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
        
        DispatchQueue.main.async {
            self.backUpButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.maxY - 55, width: self.view.frame.width, height: 55))
            self.backUpButton.showsTouchWhenHighlighted = true
            self.backUpButton.backgroundColor = .black
            self.backUpButton.setTitle("Back Up / Share / Save / Copy", for: .normal)
            self.backUpButton.addTarget(self, action: #selector(self.airDropImage), for: .touchUpInside)
            self.view.addSubview(self.backUpButton)
        }
        
    }
    
    func addCheckAddressButton() {
        
        DispatchQueue.main.async {
            self.checkAddressButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.maxY - 55, width: self.view.frame.width, height: 55))
            self.checkAddressButton.showsTouchWhenHighlighted = true
            self.checkAddressButton.backgroundColor = .black
            self.checkAddressButton.setTitle("Check Balance", for: .normal)
            self.checkAddressButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            self.view.addSubview(self.checkAddressButton)
        }
        
    }
    
    func addMayerMultipleButton() {
        
        DispatchQueue.main.async {
            self.mayerMultipleButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.minY, width: self.view.frame.width, height: 55))
            self.mayerMultipleButton.showsTouchWhenHighlighted = true
            self.mayerMultipleButton.backgroundColor = .black
            self.mayerMultipleButton.setTitle("Price Check", for: .normal)
            self.mayerMultipleButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            self.view.addSubview(self.mayerMultipleButton)
        }
        
    }
    
    func addTransactionsButton() {
        
        DispatchQueue.main.async {
            self.transactionsButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.minY + 65, width: self.view.frame.width, height: 55))
            self.transactionsButton.showsTouchWhenHighlighted = true
            self.transactionsButton.backgroundColor = .black
            self.transactionsButton.setTitle("Send", for: .normal)
            self.transactionsButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            self.view.addSubview(self.transactionsButton)
        }
        
    }
    
    func addDiceButton() {
        
        DispatchQueue.main.async {
            self.diceButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.maxY - 120, width: self.view.frame.width, height: 55))
            self.diceButton.showsTouchWhenHighlighted = true
            self.diceButton.backgroundColor = .black
            self.diceButton.setTitle("Dice Key Creator", for: .normal)
            self.diceButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            self.view.addSubview(self.diceButton)
        }
    }
    
    func addImportButton() {
        
        DispatchQueue.main.async {
            self.importButton = UIButton(frame: CGRect(x: 0, y: self.diceButton.frame.minY - 65, width: self.view.frame.width, height: 55))
            self.importButton.showsTouchWhenHighlighted = true
            self.importButton.backgroundColor = .black
            self.importButton.setTitle("Import", for: .normal)
            self.importButton.addTarget(self, action: #selector(self.importMnemonic), for: .touchUpInside)
            self.view.addSubview(self.importButton)
        }
    }
    
    @objc func goTo(sender: UIButton) {
        
        switch sender {
            
        case self.diceButton:
            
            self.view.addSubview(self.scrollView)
            self.imageView.removeFromSuperview()
            self.checkAddressButton.removeFromSuperview()
            self.mayerMultipleButton.removeFromSuperview()
            self.diceButton.removeFromSuperview()
            self.transactionsButton.removeFromSuperview()
            self.importButton.removeFromSuperview()
            self.showDice()
            self.addBackButton()
            self.addClearButton()
            
        case self.mayerMultipleButton:
            
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
        
    }
    
    func getDocumentsDirectory() -> URL {
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
            rotateAnimation.toValue = CGFloat(.pi * 2.0)
            rotateAnimation.duration = duration
            rotateAnimation.repeatCount = Float.greatestFiniteMagnitude;
            imageView.layer.add(rotateAnimation, forKey: nil)
        }
        
    }
    
    
    func addPercentageCompleteLabel() {
        
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
        
        self.clearButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 100, y: 0, width: 100 , height: 55))
        self.clearButton.showsTouchWhenHighlighted = true
        self.clearButton.backgroundColor = .black
        self.clearButton.setTitle("Clear", for: .normal)
        self.clearButton.addTarget(self, action: #selector(self.tapClearDice), for: .touchUpInside)
        self.view.addSubview(self.clearButton)
    }
    
    @objc func tapClearDice() {
        
        clearDice()
        
    }
    
    func clearDice() {
        
        for dice in self.diceArray {
            dice.removeFromSuperview()
        }
        self.diceArray.removeAll()
        self.tappedIndex = 0
        self.percentageLabel.removeFromSuperview()
        self.showDice()
        
    }
    
    func creatBitKey() {
        
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
        
        var yvalue = 60
        var zero = 0
        
        for _ in 0..<40 {
            
            for _ in 0..<5 {
                
                zero = zero + 1
                self.diceButton = UIButton(frame: CGRect(x: xvalue, y: yvalue, width: width, height: height))
                self.diceButton.setImage(#imageLiteral(resourceName: "images-6.png"), for: .normal)
                self.diceButton.tag = zero
                self.diceButton.showsTouchWhenHighlighted = true
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



