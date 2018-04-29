//
//  DiceKeyCreatorViewController.swift
//  BitKeys
//
//  Created by Peter on 3/27/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import SystemConfiguration
import BigInt

class DiceKeyCreatorViewController: UIViewController {
    
    @IBOutlet var upperLabel: UILabel!
    var privateKeyTitle: UILabel!
    var clearButton = UIButton()
    var diceButton = UIButton()
    var backButton = UIButton()
    var diceArray = [UIButton]()
    var createKeysButton = UIButton()
    var privateKey = String()
    var bitcoinAddress = String()
    var tappedIndex = Int()
    var privateKeyQRCode:UIImage!
    var privateKeyQRView:UIImageView!
    var privateKeyImage:UIImage!
    var imageView:UIView!
    var bitField: UITextView!
    var privateKeyMode:Bool!
    var connected:Bool!
    var privateKeyText:String!
    var bitcoinAddressButton = UIButton()
    var backUpButton = UIButton(type: .custom)
    var randomBits = [String]()
    var hideExplanation:Bool!
    var bitCount:Int! = 0
    var percentageLabel = UILabel()
    var base10Field = UITextView()
    var hexField = UITextView()
    var WIFprivateKeyField = UITextView()
    var WIFprivateKeyFieldLabel = UILabel()
    var bitFieldLabel = UILabel()
    var base10Label = UILabel()
    var hexLabel = UILabel()
    var joinedBits = String()
    var parseBitResult = BigInt()
    var hexString = String()
    let segwit = SegwitAddrCoder()
    
    @IBOutlet var scrollView: UIScrollView!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.object(forKey: "hideExplanation") != nil {
            
            self.hideExplanation = UserDefaults.standard.bool(forKey: "hideExplanation")
            
        } else {
            
            self.hideExplanation = false
            
        }
        
        privateKeyMode = true
        showDice()
        addBackButton()
        addClearButton()
        
     }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        scrollView.contentSize = CGSize(width: 414, height: 3700)
    }
    
    func removeLabels() {
        
        DispatchQueue.main.async {
            
            self.privateKeyTitle.text = ""
            self.WIFprivateKeyFieldLabel.text = ""
            self.privateKeyTitle.removeFromSuperview()
            self.privateKeyQRView.removeFromSuperview()
            self.WIFprivateKeyFieldLabel.removeFromSuperview()
            self.WIFprivateKeyField.removeFromSuperview()
            self.bitFieldLabel.removeFromSuperview()
            self.bitField.removeFromSuperview()
            self.base10Label.removeFromSuperview()
            self.base10Field.removeFromSuperview()
            self.hexLabel.removeFromSuperview()
            self.hexField.removeFromSuperview()
        }
        
    }
    
    func showAddress() {
        
        DispatchQueue.main.async {
            
            self.scrollView.setContentOffset(.zero, animated: false)
            
            self.privateKeyTitle = UILabel(frame: CGRect(x: self.scrollView.frame.minX, y: self.scrollView.frame.minY + 60, width: self.scrollView.frame.width, height: 50))
            self.privateKeyTitle.text = "Bitcoin Address"
            self.privateKeyTitle.font = .systemFont(ofSize: 32)
            self.privateKeyTitle.textColor = UIColor.black
            self.privateKeyTitle.textAlignment = .center
            self.scrollView.addSubview(self.privateKeyTitle)
            
            self.privateKeyQRCode = self.generateQrCode(key: self.bitcoinAddress)
            self.privateKeyQRView = UIImageView(image: self.privateKeyQRCode!)
            self.privateKeyQRView.frame = CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 120, width: self.scrollView.frame.width - 10, height: self.scrollView.frame.width - 10)
            self.scrollView.addSubview(self.privateKeyQRView)
            
            self.WIFprivateKeyFieldLabel = UILabel(frame: CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 145 + (self.scrollView.frame.width - 10) - 11, width: self.scrollView.frame.width - 10, height: 13))
            self.WIFprivateKeyFieldLabel.text = "Address Format:"
            self.WIFprivateKeyFieldLabel.font = .systemFont(ofSize: 12)
            self.WIFprivateKeyFieldLabel.textColor = UIColor.black
            self.WIFprivateKeyFieldLabel.textAlignment = .left
            self.scrollView.addSubview(self.WIFprivateKeyFieldLabel)
            
            self.WIFprivateKeyField.frame = CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 145 + (self.scrollView.frame.width - 10), width: self.scrollView.frame.width - 10, height: 75)
            self.WIFprivateKeyField.text = self.bitcoinAddress
            self.WIFprivateKeyField.isEditable = false
            self.WIFprivateKeyField.isSelectable = true
            self.WIFprivateKeyField.font = .systemFont(ofSize: 24)
            self.scrollView.addSubview(self.WIFprivateKeyField)
            
        }
        
    }
    
    func showPrivateKey() {
        
        DispatchQueue.main.async {
            
            self.scrollView.setContentOffset(.zero, animated: false)
            
            self.privateKeyTitle = UILabel(frame: CGRect(x: self.scrollView.frame.minX, y: self.scrollView.frame.minY + 60, width: self.scrollView.frame.width, height: 50))
            self.privateKeyTitle.text = "Bitcoin Private Key"
            self.privateKeyTitle.font = .systemFont(ofSize: 32)
            self.privateKeyTitle.textColor = UIColor.black
            self.privateKeyTitle.textAlignment = .center
            self.scrollView.addSubview(self.privateKeyTitle)
            
            self.privateKeyQRCode = self.generateQrCode(key: self.privateKey)
            self.privateKeyQRView = UIImageView(image: self.privateKeyQRCode!)
            self.privateKeyQRView.frame = CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 120, width: self.scrollView.frame.width - 10, height: self.scrollView.frame.width - 10)
            self.scrollView.addSubview(self.privateKeyQRView)
            
            self.WIFprivateKeyFieldLabel = UILabel(frame: CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 145 + (self.scrollView.frame.width - 10) - 11, width: self.scrollView.frame.width - 10, height: 13))
            self.WIFprivateKeyFieldLabel.text = "WIF Format:"
            self.WIFprivateKeyFieldLabel.font = .systemFont(ofSize: 12)
            self.WIFprivateKeyFieldLabel.textColor = UIColor.black
            self.WIFprivateKeyFieldLabel.textAlignment = .left
            self.scrollView.addSubview(self.WIFprivateKeyFieldLabel)
            
            self.WIFprivateKeyField.frame = CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 145 + (self.scrollView.frame.width - 10), width: self.scrollView.frame.width - 10, height: 75)
            self.WIFprivateKeyField.text = self.privateKey
            self.WIFprivateKeyField.isEditable = false
            self.WIFprivateKeyField.isSelectable = true
            self.WIFprivateKeyField.font = .systemFont(ofSize: 24)
            self.scrollView.addSubview(self.WIFprivateKeyField)
            
            self.bitFieldLabel = UILabel(frame: CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 240 + (self.scrollView.frame.width - 10) - 11, width: self.scrollView.frame.width - 10, height: 13))
            self.bitFieldLabel.text = "Bit Format:"
            self.bitFieldLabel.font = .systemFont(ofSize: 12)
            self.bitFieldLabel.textColor = UIColor.black
            self.bitFieldLabel.textAlignment = .left
            self.scrollView.addSubview(self.bitFieldLabel)
            
            self.bitField = UITextView (frame:CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 240 + (self.scrollView.frame.width - 10), width: self.scrollView.frame.width - 10, height: 300))
            self.bitField.text = self.joinedBits
            self.bitField.isEditable = false
            self.bitField.isSelectable = true
            self.bitField.font = .systemFont(ofSize: 24)
            self.scrollView.addSubview(self.bitField)
            
            self.base10Label = UILabel(frame: CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 550 + (self.scrollView.frame.width - 10) - 11, width: self.scrollView.frame.width - 10, height: 13))
            self.base10Label.text = "Decimal Format:"
            self.base10Label.font = .systemFont(ofSize: 12)
            self.base10Label.textColor = UIColor.black
            self.base10Label.textAlignment = .left
            self.scrollView.addSubview(self.base10Label)
            
            self.base10Field = UITextView (frame:CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 550 + (self.scrollView.frame.width - 10), width: self.scrollView.frame.width - 10, height: 150))
            self.base10Field.text = String(self.parseBitResult)
            self.base10Field.isEditable = false
            self.base10Field.isSelectable = true
            self.base10Field.font = .systemFont(ofSize: 24)
            self.scrollView.addSubview(self.base10Field)
            
            self.hexLabel = UILabel(frame: CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 660 + (self.scrollView.frame.width - 10) - 11, width: self.scrollView.frame.width - 10, height: 13))
            self.hexLabel.text = "Hexadecimal Format:"
            self.hexLabel.font = .systemFont(ofSize: 12)
            self.hexLabel.textColor = UIColor.black
            self.hexLabel.textAlignment = .left
            self.scrollView.addSubview(self.hexLabel)
            
            self.hexField = UITextView (frame:CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 660 + (self.scrollView.frame.width - 10), width: self.scrollView.frame.width - 10, height: 100))
            self.hexField.text = self.hexString
            self.hexField.isEditable = false
            self.hexField.isSelectable = true
            self.hexField.font = .systemFont(ofSize: 24)
            self.scrollView.addSubview(self.hexField)
            
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

    func showDice() {
        
        self.isInternetAvailable()
        
        var xvalue = 25;
        var yvalue = 60
        var zero = 0
        
        for _ in 0..<40 {
                
            for _ in 0..<5 {
                
                zero = zero + 1
                self.diceButton = UIButton(frame: CGRect(x: xvalue, y: yvalue, width: 65, height: 65))
                self.diceButton.setImage(#imageLiteral(resourceName: "images-6.png"), for: .normal)
                self.diceButton.tag = zero
                self.diceButton.showsTouchWhenHighlighted = true
                self.diceButton.setTitle("\(0)", for: .normal)
                self.diceButton.titleLabel?.textColor = UIColor.white
                self.diceButton.addTarget(self, action: #selector(self.tapDice), for: .touchUpInside)
                self.diceArray.append(self.diceButton)
                self.scrollView.addSubview(self.diceButton)
                xvalue = xvalue + 75
            }
            
            xvalue = 25
            yvalue = yvalue + 90
            
        }
       
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
                    
                    print("bitCount = \(self.bitCount!)")
                    
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
                                
                                print("bitCount after = \(count)")
                                print("parseBitResult = \(String(describing: self.parseBitResult))")
                                
                                self.addBackUpButton()
                                self.addKeyToggleButton()
                                self.percentageLabel.removeFromSuperview()
                                self.clearButton.removeFromSuperview()
                                
                                for dice in self.diceArray {
                                    dice.removeFromSuperview()
                                }
                                self.diceArray.removeAll()
                                self.tappedIndex = 0
                                
                                self.hexString = String(self.parseBitResult, radix: 16)
                                print("hexString = \(self.hexString)")
                                
                                let data = BigUInt(self.parseBitResult).serialize()
                                let mnemonic = BTCMnemonic.init(entropy: data, password: "", wordListType: BTCMnemonicWordListType.english)
                                print("mnemonic = \(String(describing: mnemonic?.words))")
                                let extendedKey = mnemonic?.keychain
                                let keychain = extendedKey
                                print("keychainPrivKey = \(String(describing: keychain?.extendedPrivateKey))")
                                //save pubkey to create future addresses
                                print("keychainPubKey = \(String(describing: keychain?.extendedPublicKey))")
                                let privateKeyHD = keychain?.key.privateKeyAddress
                                let addressHD = keychain?.key.address
                                print("privateKeyHD = \(String(describing: privateKeyHD))")
                                print("addressHD = \(String(describing: addressHD))")
                                
                                //var privateKeyWIF:String!
                                var legacyAddress:String!
                                let privateKey2 = privateKeyHD!.description
                                var privateKey3 = privateKey2.components(separatedBy: " ")
                                self.privateKey = privateKey3[1].replacingOccurrences(of: ">", with: "")
                                let legacyAddress1 = addressHD!.description
                                let legacyAddress2 = (legacyAddress1.description).components(separatedBy: " ")
                                legacyAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                                
                                let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain?.key.compressedPublicKeyAddress.data) as Data!) as Data!
                                print("compressedPKData = \(String(describing: compressedPKData?.hex()))")
                                
                                do {
                                    //bc for mainnet and tb for testnet
                                    self.bitcoinAddress = try self.segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                                    print("segwitBech32 = \(self.bitcoinAddress)")
                                    
                                } catch {
                                    
                                    self.displayAlert(title: "Error", message: "Please try again.")
                                    
                                }
                                print("privatekey = \(self.privateKey)")
                                print("address = \(self.bitcoinAddress)")
                                
                                keychain?.key.clear()
                                
                                DispatchQueue.main.async {
                                    self.showPrivateKey()
                                }
                                
                            }))
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("No, let me check", comment: ""), style: .default, handler: { (action) in
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                        
                    } else {
                        
                        print("bitcount not 256")
                    }
                    
                }
                
            }
            
        }
        
        self.randomBits.removeAll()
            
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
    
    
    func clearDice() {
        
        for dice in self.diceArray {
            dice.removeFromSuperview()
        }
        self.diceArray.removeAll()
        self.tappedIndex = 0
        self.percentageLabel.removeFromSuperview()
        self.showDice()
        
    }
    
    @objc func tapClearDice() {
        
        clearDice()
        
    }
    
    @objc func home() {
        
        if self.privateKey != "" {
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: "Have you saved this Private Key?", message: "Ensure you have saved this before going back if you'd like to use this Private Key in the future.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("I saved it, go back", comment: ""), style: .destructive, handler: { (action) in
                    
                    self.dismiss(animated: false, completion: nil)
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            
            self.dismiss(animated: false, completion: nil)
            
        }
        
        
    }
    
    @objc func getAddress() {
        
        if privateKeyMode {
            
            DispatchQueue.main.async {
                
                self.removeLabels()
                self.bitcoinAddressButton.setTitle("Show Private Key", for: .normal)
                self.showAddress()
                self.privateKeyMode = false
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                self.removeLabels()
                self.bitcoinAddressButton.setTitle("Show Address", for: .normal)
                self.showPrivateKey()
                self.privateKeyMode = true
                
            }
        }
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
    
    func addClearButton() {
        
        self.clearButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 100, y: 0, width: 100 , height: 55))
        self.clearButton.showsTouchWhenHighlighted = true
        self.clearButton.backgroundColor = .black
        self.clearButton.setTitle("Clear", for: .normal)
        self.clearButton.addTarget(self, action: #selector(self.tapClearDice), for: .touchUpInside)
        self.view.addSubview(self.clearButton)
    }
    
    func addKeyToggleButton() {
        
        DispatchQueue.main.async {
            self.bitcoinAddressButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 150, y: 0, width: 150 , height: 55))
            self.bitcoinAddressButton.showsTouchWhenHighlighted = true
            self.bitcoinAddressButton.backgroundColor = .black
            self.bitcoinAddressButton.setTitle("Show Address", for: .normal)
            self.bitcoinAddressButton.addTarget(self, action: #selector(self.getAddress), for: .touchUpInside)
            self.view.addSubview(self.bitcoinAddressButton)
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
    
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
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
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Private Key Text", comment: ""), style: .default, handler: { (action) in
                    
                    let textToShare = [self.privateKeyText!]
                    let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                
            } else {
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Bitcoin Address QR Code", comment: ""), style: .default, handler: { (action) in
                    
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
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Bitcoin Address Text", comment: ""), style: .default, handler: { (action) in
                    
                    let textToShare = [self.bitcoinAddress]
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
    
}

extension Data {
    func hex(separator:String = "") -> String {
        return (self.map { String(format: "%02X", $0) }).joined(separator: separator)
    }
}


