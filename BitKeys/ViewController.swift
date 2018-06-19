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
import AVFoundation

class ViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    var videoPreview:UIView!
    let avCaptureSession = AVCaptureSession()
    var stringURL = String()
    var password = ""
    var exportPrivateKeyFromTable = Bool()
    var exportAddressFromTable = Bool()
    var toolBoxTapped = Bool()
    var simpleMode = Bool()
    var advancedMode = Bool()
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
    var multiSigButton = UIButton()
    var sweepButton = UIButton()
    var settingsButton = UIButton()
    var exportButton = UIButton()
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
    var extendedPublicKeyMode = Bool()
    var clearMnemonicButton = UIButton()
    var addressBook: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.object(forKey: "hideExplanation") != nil {
            
            self.hideExplanation = UserDefaults.standard.bool(forKey: "hideExplanation")
            
        } else {
            
            self.hideExplanation = false
            
        }
        
        toolBoxTapped = true
        diceMode = false
        inputMnemonic.delegate = self
        inputPassword.delegate = self
        privateKeyMode = true
        addHomeScreen()
        
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
        
        
        
        addressBook = checkUserDefaults().addressBook
        advancedMode = checkUserDefaults().advancedMode
        simpleMode = checkUserDefaults().simpleMode
        hotMode = checkUserDefaults().hotMode
        coldMode = checkUserDefaults().coldMode
        legacyMode = checkUserDefaults().legacyMode
        segwitMode = checkUserDefaults().segwitMode
        mainnetMode = checkUserDefaults().mainnetMode
        testnetMode = checkUserDefaults().testnetMode
        
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
                    
                }
                
            }
            
            self.exportAddressFromTable = false
            
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
        self.outputMnemonic.font = UIFont.systemFont(ofSize: 22, weight: .regular)
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
            
            self.bitField = UITextView (frame:CGRect(x: self.view.center.x - (self.view.frame.width / 2), y: self.view.center.y - (self.view.frame.height / 2), width: self.view.frame.width, height: self.view.frame.height))
            self.bitField.isUserInteractionEnabled = false
            self.bitField.font = .systemFont(ofSize: 24)
            self.view.addSubview(self.bitField)
            
            if self.imageView != nil {
                self.imageView.removeFromSuperview()
            }
            
            let bitcoinImage = UIImage(named: "img_311477.png")
            self.imageView = UIImageView(image: bitcoinImage!)
            self.imageView.center = self.view.center
            self.imageView.frame = CGRect(x: self.view.center.x - 100, y: self.view.center.y - 100, width: 200, height: 200)
            let bitcoinDragged = UIPanGestureRecognizer(target: self, action: #selector(self.userCreatesRandomness(gestureRecognizer:)))
            bitcoinDragged.delegate = self
            self.imageView.isUserInteractionEnabled = true
            self.imageView.addGestureRecognizer(bitcoinDragged)
            self.imageView.layer.shadowColor = UIColor.black.cgColor
            self.imageView.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.imageView.layer.shadowRadius = 2.5
            self.imageView.layer.shadowOpacity = 0.8
            self.view.addSubview(self.imageView)
            
            self.addCheckAddressButton()
            self.addPayButton()
            self.addReceiveButton()
            
            self.settingsButton.removeFromSuperview()
            self.settingsButton = UIButton(frame: CGRect(x: 5, y: 20, width: 45, height: 45))
            self.settingsButton.showsTouchWhenHighlighted = true
            self.settingsButton.layer.cornerRadius = 28
            self.settingsButton.setImage(#imageLiteral(resourceName: "settings2.png"), for: .normal)
            self.settingsButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            self.view.addSubview(self.settingsButton)
            
            self.infoButton.removeFromSuperview()
            self.infoButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 50, y: 20, width: 45, height: 45))
            self.infoButton.showsTouchWhenHighlighted = true
            self.infoButton.layer.cornerRadius = 28
            self.infoButton.setImage(#imageLiteral(resourceName: "help2.png"), for: .normal)
            self.infoButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            self.view.addSubview(self.infoButton)
            
            self.lockButton.removeFromSuperview()
            self.lockButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) + (self.view.frame.width / 5 - (35/2)) + 5, y: 20, width: 35, height: 35))
            self.lockButton.showsTouchWhenHighlighted = true
            self.lockButton.layer.cornerRadius = 28
            self.lockButton.setImage(#imageLiteral(resourceName: "lock.jpg"), for: .normal)
            self.lockButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            self.view.addSubview(self.lockButton)
            
            self.priceButton.removeFromSuperview()
            self.priceButton = UIButton(frame: CGRect(x: (self.view.center.x - (40/2)) - (self.view.frame.width / 3 - (40/2)) - 5, y: 16, width: 50, height: 50))
            self.priceButton.showsTouchWhenHighlighted = true
            self.priceButton.layer.cornerRadius = 28
            self.priceButton.setImage(#imageLiteral(resourceName: "price.png"), for: .normal)
            self.priceButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            self.view.addSubview(self.priceButton)
            
            self.toolboxButton.removeFromSuperview()
            self.toolboxButton = UIButton(frame: CGRect(x: (self.view.center.x - (40/2)) - (self.view.frame.width / 5 - (40/2)) - 5, y: 20, width: 40, height: 40))
            self.toolboxButton.showsTouchWhenHighlighted = true
            self.toolboxButton.layer.cornerRadius = 28
            self.toolboxButton.setImage(#imageLiteral(resourceName: "keys.png"), for: .normal)
            self.toolboxButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            self.view.addSubview(self.toolboxButton)
            
            self.addressBookButton.removeFromSuperview()
            self.addressBookButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) + (self.view.frame.width / 3 - (35/2)) + 5, y: 22, width: 35, height: 35))
            self.addressBookButton.showsTouchWhenHighlighted = true
            self.addressBookButton.layer.cornerRadius = 28
            self.addressBookButton.setImage(#imageLiteral(resourceName: "addressBook.png"), for: .normal)
            self.addressBookButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
            self.view.addSubview(self.addressBookButton)
            
        }
        
    }
    
    func addPayButton() {
        
        self.transactionsButton.removeFromSuperview()
        self.transactionsButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 90, y: self.view.frame.maxY - 55, width: 85, height: 50))
        self.transactionsButton.showsTouchWhenHighlighted = true
        self.transactionsButton.layer.cornerRadius = 10
        self.transactionsButton.backgroundColor = UIColor.black
        self.transactionsButton.layer.shadowColor = UIColor.black.cgColor
        self.transactionsButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        self.transactionsButton.layer.shadowRadius = 2.5
        self.transactionsButton.layer.shadowOpacity = 0.8
        self.transactionsButton.setTitle("Pay", for: .normal)
        self.transactionsButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
        self.view.addSubview(self.transactionsButton)
        
    }
    
    func addReceiveButton() {
        
        self.newAddressButton.removeFromSuperview()
        self.newAddressButton = UIButton(frame: CGRect(x: self.view.center.x - (85/2), y: self.view.frame.maxY - 55, width: 85, height: 50))
        self.newAddressButton.showsTouchWhenHighlighted = true
        self.newAddressButton.titleLabel?.textAlignment = .center
        self.newAddressButton.layer.cornerRadius = 10
        self.newAddressButton.backgroundColor = UIColor.black
        self.newAddressButton.layer.shadowColor = UIColor.black.cgColor
        self.newAddressButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        self.newAddressButton.layer.shadowRadius = 2.5
        self.newAddressButton.layer.shadowOpacity = 0.8
        self.newAddressButton.setTitle("Receive", for: .normal)
        self.newAddressButton.addTarget(self, action: #selector(self.newAddress), for: .touchUpInside)
        self.view.addSubview(self.newAddressButton)
        
    }
    
    func addSweepButton() {
        
        self.sweepButton.removeFromSuperview()
        self.sweepButton = UIButton(frame: CGRect(x: 5, y: self.diceButton.frame.maxY + 10, width: 85, height: 50))
        self.sweepButton.showsTouchWhenHighlighted = true
        self.sweepButton.layer.cornerRadius = 10
        self.sweepButton.backgroundColor = UIColor.black
        self.sweepButton.layer.shadowColor = UIColor.black.cgColor
        self.sweepButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        self.sweepButton.layer.shadowRadius = 2.5
        self.sweepButton.layer.shadowOpacity = 0.8
        self.sweepButton.setTitle("Sweep", for: .normal)
        self.sweepButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
        self.view.addSubview(self.sweepButton)
        
    }
    
    func addExportButton() {
        
        self.exportButton.removeFromSuperview()
        self.exportButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 90, y: self.transactionsButton.frame.minY - 60, width: 85, height: 50))
        self.exportButton.showsTouchWhenHighlighted = true
        self.exportButton.titleLabel?.textAlignment = .center
        self.exportButton.layer.cornerRadius = 10
        self.exportButton.backgroundColor = UIColor.black
        self.exportButton.layer.shadowColor = UIColor.black.cgColor
        self.exportButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        self.exportButton.layer.shadowRadius = 2.5
        self.exportButton.layer.shadowOpacity = 0.8
        self.exportButton.setTitle("Export", for: .normal)
        self.exportButton.addTarget(self, action: #selector(self.export), for: .touchUpInside)
        self.view.addSubview(self.exportButton)
        
    }
    
    func addImportButton() {
        
        self.importButton.removeFromSuperview()
        self.importButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 90, y: self.exportButton.frame.minY - 60, width: 85, height: 50))
        self.importButton.showsTouchWhenHighlighted = true
        self.importButton.layer.cornerRadius = 10
        self.importButton.backgroundColor = UIColor.black
        self.importButton.layer.shadowColor = UIColor.black.cgColor
        self.importButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        self.importButton.layer.shadowRadius = 2.5
        self.importButton.layer.shadowOpacity = 0.8
        self.importButton.setTitle("Import", for: .normal)
        self.importButton.addTarget(self, action: #selector(self.importMnemonic), for: .touchUpInside)
        self.view.addSubview(self.importButton)
        
    }
    
    func addMultiSigButton() {
        
        self.multiSigButton.removeFromSuperview()
        self.multiSigButton = UIButton(frame: CGRect(x: self.view.center.x - (85/2), y: self.newAddressButton.frame.minY - 60, width: 85, height: 50))
        self.multiSigButton.showsTouchWhenHighlighted = true
        self.multiSigButton.layer.cornerRadius = 10
        self.multiSigButton.backgroundColor = UIColor.black
        self.multiSigButton.layer.shadowColor = UIColor.black.cgColor
        self.multiSigButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        self.multiSigButton.layer.shadowRadius = 2.5
        self.multiSigButton.layer.shadowOpacity = 0.8
        self.multiSigButton.setTitle("Multi-Sig", for: .normal)
        self.multiSigButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
        self.view.addSubview(self.multiSigButton)
        
    }
    
    func addDiceButton() {
        
        self.diceButton.removeFromSuperview()
        self.diceButton = UIButton(frame: CGRect(x: 5, y: self.settingsButton.frame.minY + 60, width: 85, height: 50))
        self.diceButton.showsTouchWhenHighlighted = true
        self.diceButton.layer.cornerRadius = 10
        self.diceButton.backgroundColor = UIColor.black
        self.diceButton.layer.shadowColor = UIColor.black.cgColor
        self.diceButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        self.diceButton.layer.shadowRadius = 2.5
        self.diceButton.layer.shadowOpacity = 0.8
        self.diceButton.setTitle("Dice", for: .normal)
        self.diceButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
        self.view.addSubview(self.diceButton)
        
    }
    
    func addCheckAddressButton() {
        
        self.checkAddressButton.removeFromSuperview()
        self.checkAddressButton = UIButton(frame: CGRect(x: 5, y: self.view.frame.maxY - 55, width: 85, height: 50))
        self.checkAddressButton.showsTouchWhenHighlighted = true
        self.checkAddressButton.layer.cornerRadius = 10
        self.checkAddressButton.backgroundColor = UIColor.black
        self.checkAddressButton.layer.shadowColor = UIColor.black.cgColor
        self.checkAddressButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        self.checkAddressButton.layer.shadowRadius = 2.5
        self.checkAddressButton.layer.shadowOpacity = 0.8
        self.checkAddressButton.setTitle("Balance", for: .normal)
        self.checkAddressButton.addTarget(self, action: #selector(self.goTo), for: .touchUpInside)
        self.view.addSubview(self.checkAddressButton)
        
    }
    
    func removeHomeScreen() {
        print("removeHomeScreen")
        
        DispatchQueue.main.async {
            
            self.addressBookButton.removeFromSuperview()
            self.priceButton.removeFromSuperview()
            self.lockButton.removeFromSuperview()
            self.toolboxButton.removeFromSuperview()
            self.infoButton.removeFromSuperview()
            self.multiSigButton.removeFromSuperview()
            self.sweepButton.removeFromSuperview()
            self.exportButton.removeFromSuperview()
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
        self.multiSigButton.removeFromSuperview()
        self.sweepButton.removeFromSuperview()
        self.checkAddressButton.removeFromSuperview()
        self.diceButton.removeFromSuperview()
        self.transactionsButton.removeFromSuperview()
        self.importButton.removeFromSuperview()
        self.newAddressButton.removeFromSuperview()
        self.exportButton.removeFromSuperview()
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
        bitField.text = allToBits
        
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
                                
                            print("bitnumber = \(bits.count)")
                                
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
                                            
                                        if self.advancedMode {
                                            
                                            self.showPrivateKeyAndAddressQRCodes()
                                                
                                            if isInternetAvailable() {
                                                    
                                                DispatchQueue.main.async {
                                                        
                                                    displayAlert(viewController: self, title: "Security Alert", message: "You should only create private keys offline. Please enable airplane mode, turn off wifi and try again.")
                                                }
                                                    
                                            }
                                                
                                        } else if self.simpleMode {
                                                
                                            DispatchQueue.main.async {
                                                    
                                                displayAlert(viewController: self, title: "Success", message: "You've created a Bitcoin wallet, congratulations!")
                                                
                                                self.removeBitField()
                                                
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
                                        
                                    if isInternetAvailable() {
                                            
                                        if self.advancedMode {
                                                
                                            DispatchQueue.main.async {
                                                    
                                                displayAlert(viewController: self, title: "Security Alert", message: "You should only create private keys offline. Please enable airplane mode, turn off wifi and try again.")
                                            }
                                                
                                        }
                                            
                                    }
                                        
                                    self.privateKeyWIF = createPrivateKey(viewController: self, userRandomness: self.parseBitResult).privateKeyAddress
                                    self.bitcoinAddress = createPrivateKey(viewController: self, userRandomness: self.parseBitResult).publicKeyAddress
                                    self.words = createPrivateKey(viewController: self, userRandomness: self.parseBitResult).recoveryPhrase
                                        
                                    if self.privateKeyWIF != "" {
                                            
                                        if self.advancedMode {
                                                
                                            self.showPrivateKeyAndAddressQRCodes()
                                                
                                        } else {
                                                
                                            DispatchQueue.main.async {
                                                    
                                                displayAlert(viewController: self, title: "Success", message: "You've created a Bitcoin wallet, congratulations!")
                                                    
                                                self.removeBitField()
                                                
                                            }
                                                
                                        }
                                    
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
        self.privateKeyQRView.frame = CGRect(x: self.view.frame.minX + 5, y: self.view.frame.minY + 130, width: self.view.frame.width - 10, height: self.view.frame.width - 10)
        self.privateKeyQRView.alpha = 0
        self.view.addSubview(self.privateKeyQRView)
            
        self.WIFprivateKeyFieldLabel = UILabel(frame: CGRect(x: self.view.frame.minX + 5, y: self.view.frame.minY + 150 + (self.view.frame.width - 10) - 11, width: self.view.frame.width - 10, height: 13))
        self.WIFprivateKeyFieldLabel.font = .systemFont(ofSize: 12)
        self.WIFprivateKeyFieldLabel.textColor = UIColor.black
        self.WIFprivateKeyFieldLabel.textAlignment = .left
        self.view.addSubview(self.WIFprivateKeyFieldLabel)
            
        UIView.animate(withDuration: 0.5, animations: {
                
            self.imageView.alpha = 0
            self.bitField.alpha = 0
                
        }, completion: { _ in
                
            self.removeHomeScreen()
                
            UIView.animate(withDuration: 0.5, animations: {
                    
                self.privateKeyQRView.alpha = 1
                    
            }, completion: { _ in
                    
                //self.scrollView.setContentOffset(.zero, animated: false)
                    
                DispatchQueue.main.async {
                        
                    self.WIFprivateKeyFieldLabel.text = "Text Format:"
                    self.privateKeyTitle = UILabel(frame: CGRect(x: self.view.frame.minX + 20, y: self.view.frame.minY + 70, width: self.view.frame.width - 40, height: 50))
                    self.privateKeyTitle.text = "Send Bitcoin to \"\(walletName)\""
                    self.privateKeyTitle.adjustsFontSizeToFitWidth = true
                    self.privateKeyTitle.font = .systemFont(ofSize: 32)
                    self.privateKeyTitle.textColor = UIColor.black
                    self.privateKeyTitle.textAlignment = .center
                    self.view.addSubview(self.privateKeyTitle)
                        
                }
                    
                self.myField = UITextView (frame:CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.privateKeyQRView.frame.maxY + 40, width: self.view.frame.width - 50, height: 100))
                self.myField.isEditable = false
                self.myField.isSelectable = true
                self.myField.font = .systemFont(ofSize: 24)
                self.myField.text = self.bitcoinAddress
                self.view.addSubview(self.myField)
                self.addHomeButton()
                self.addBackUpButton()
                self.zero = 0
                self.bitArray.removeAll()
                    
            })
                
        })

    }
    
    @objc func importNow() {
        
        if let testInputMnemonic = BTCMnemonic.init(words: self.wordArray, password: self.password, wordListType: BTCMnemonicWordListType.english) {
           
            self.removeHomeScreen()
            self.inputMnemonic.resignFirstResponder()
            self.inputMnemonic.removeFromSuperview()
            self.inputPassword.removeFromSuperview()
            self.scanQRCodeButton.removeFromSuperview()
            
            let recoveryPhrase = testInputMnemonic.words.description
            let formatMnemonic1 = recoveryPhrase.replacingOccurrences(of: "[", with: "")
            let formatMnemonic2 = formatMnemonic1.replacingOccurrences(of: "]", with: "")
            let formateMnemonic3 = formatMnemonic2.replacingOccurrences(of: "\"", with: "")
            self.words = formateMnemonic3.replacingOccurrences(of: ",", with: "")
            
            let keychain = testInputMnemonic.keychain.derivedKeychain(withPath: "m/44'/0'/0'/0")
            print("keychainPrivKey = \(String(describing: keychain?.extendedPrivateKey))")
            keychain?.key.isPublicKeyCompressed = true
            
            let publicKey = (keychain?.key(at: 0).compressedPublicKey.hex())!
            var privateKeyHD = String()
            var addressHD = String()
            
            var network = ""
            
            if testnetMode {
                
                network = "testnet"
                
                privateKeyHD = (keychain?.key(at: 0).privateKeyAddressTestnet.description)!
                addressHD = (keychain?.key(at: 0).addressTestnet.description)!
                
            } else if mainnetMode {
                
                network = "mainnet"
                
                privateKeyHD = (keychain?.key(at: 0).privateKeyAddress.description)!
                addressHD = (keychain?.key(at: 0).address.description)!
                
            }
            
            var privateKey3 = privateKeyHD.components(separatedBy: " ")
            self.privateKeyWIF = privateKey3[1].replacingOccurrences(of: ">", with: "")
            
            
            if self.legacyMode {
                
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
        
        if self.advancedMode {
            
            DispatchQueue.main.async {
                
                self.button.removeFromSuperview()
                self.button = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
                self.button.showsTouchWhenHighlighted = true
                self.button.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
                self.button.addTarget(self, action: #selector(self.home), for: .touchUpInside)
                self.view.addSubview(self.button)
                
                if self.coldMode {
                    
                    self.bitcoinAddressButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 60, y: 20, width: 55 , height: 55))
                    self.bitcoinAddressButton.setImage(#imageLiteral(resourceName: "switch.jpg"), for: .normal)
                    self.bitcoinAddressButton.addTarget(self, action: #selector(self.getAddress), for: .touchUpInside)
                    self.view.addSubview(self.bitcoinAddressButton)
                }
                
 
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                self.button.removeFromSuperview()
                self.button = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
                self.button.showsTouchWhenHighlighted = true
                self.button.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
                self.button.addTarget(self, action: #selector(self.home), for: .touchUpInside)
                self.view.addSubview(self.button)
                
            }
            
        }
        
    }
    
    func addImportActionButton() {
        print("addImportActionButton")
        
        DispatchQueue.main.async {
            self.importAction = UIButton(frame: CGRect(x: 10, y: self.inputMnemonic.frame.maxY + 10, width: self.view.frame.width - 20, height: 50))
            self.importAction.showsTouchWhenHighlighted = true
            self.importAction.titleLabel?.textAlignment = .center
            self.importAction.layer.cornerRadius = 10
            self.importAction.backgroundColor = UIColor.black
            self.importAction.layer.shadowColor = UIColor.black.cgColor
            self.importAction.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.importAction.layer.shadowRadius = 2.5
            self.importAction.layer.shadowOpacity = 0.8
            self.importAction.setTitle("Import", for: .normal)
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
    
    @objc func scanRecoveryPhrase() {
        
        self.inputMnemonic.resignFirstResponder()
        
        self.imageView.frame = CGRect(x: 10, y: self.importAction.frame.maxY + 10, width: self.view.frame.width - 20, height: self.view.frame.width - 20)
        
        DispatchQueue.main.async {
            self.view.addSubview(self.imageView)
        }
        
        func scanQRCode() {
            
            do {
                
                try scanQRNow()
                print("scanQRNow")
                
            } catch {
                
                print("Failed to scan QR Code")
            }
            
        }
        
        scanQRCode()
        
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
        avCaptureVideoPreviewLayer.frame = self.imageView.bounds
        self.imageView.layer.addSublayer(avCaptureVideoPreviewLayer)
        
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
                    //self.words = self.stringURL
                    
                    for word in self.wordArray {
                        
                        self.listArray.append(word + " ")
                        
                    }
                    
                }
                
                self.imageView.removeFromSuperview()
                self.avCaptureSession.stopRunning()
                
            }
        }
    }
    
    @objc func export() {
        
        if let wif = UserDefaults.standard.object(forKey: "wif") as? String {
            
            if UserDefaults.standard.object(forKey: "seed") != nil {
                
             self.words = UserDefaults.standard.object(forKey: "seed") as! String
                
            }
            
            self.privateKeyWIF = wif
            
            if testnetMode {
                
                let privateKey = BTCPrivateKeyAddressTestnet.init(string: wif)
                let addressHD = privateKey?.key.addressTestnet
                
                if self.legacyMode {
                    
                    let legacyAddress2 = (addressHD?.description)?.components(separatedBy: " ")
                    self.bitcoinAddress = legacyAddress2![1].replacingOccurrences(of: ">", with: "")
                    
                } else if segwitMode {
                    
                    
                    let compressedPKData = BTCRIPEMD160(BTCSHA256(privateKey?.key.compressedPublicKey as Data!) as Data!) as Data!
                    
                    do {
                        
                        self.bitcoinAddress = try segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                        
                    } catch {
                        
                        displayAlert(viewController: self, title: "Error", message: "Please try again.")
                    }
                    
                }
                
            } else if mainnetMode {
                
                let privateKey = BTCPrivateKeyAddress.init(string: wif)
                let addressHD = privateKey?.key.address
                
                if self.legacyMode {
                    
                    let legacyAddress2 = (addressHD?.description)?.components(separatedBy: " ")
                    self.bitcoinAddress = legacyAddress2![1].replacingOccurrences(of: ">", with: "")
                    
                } else if segwitMode {
                    
                    
                    let compressedPKData = BTCRIPEMD160(BTCSHA256(privateKey?.key.compressedPublicKey as Data!) as Data!) as Data!
                    
                    do {
                        
                        self.bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                            
                    } catch {
                        
                        displayAlert(viewController: self, title: "Error", message: "Please try again.")
                    }
                    
                }
                
            }
            
            showPrivateKeyAndAddressQRCodes()
            
        } else {
            
            shakeAlert(viewToShake: self.imageView)
            
        }
        
    }
    
    @objc func newAddress() {
        print("newAddress")
        
        self.addressBook = checkUserDefaults().addressBook
        
        //action alert to ask which wallet youd like to receiev to
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
                
                self.present(alert, animated: true, completion: nil)
                
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
        
        for dice in self.diceArray {
            dice.removeFromSuperview()
        }
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
                    self.privateKeyMode = false
                    
                }

                
            } else {
                
                DispatchQueue.main.async {
                    
                    self.privateKeyTitle.text = "Bitcoin Private Key"
                    self.WIFprivateKeyFieldLabel.text = "WIF Format:"
                    self.myField.text = self.privateKeyText
                    self.privateKeyQRCode = self.generateQrCode(key: self.privateKeyText)
                    self.privateKeyQRView.image = self.privateKeyQRCode!
                    self.privateKeyMode = true
                    
                }
                
            }
            
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
            self.bitcoinAddressButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 60, y: 20, width: 55 , height: 55))
            self.bitcoinAddressButton.setImage(#imageLiteral(resourceName: "switch.jpg"), for: .normal)
            self.bitcoinAddressButton.addTarget(self, action: #selector(self.getAddress), for: .touchUpInside)
            self.view.addSubview(self.bitcoinAddressButton)
            
        }
        
        self.privateKeyMode = true
        diceMode = false
        
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
                addButtons()
                self.addBackUpButton()
                self.zero = 0
                self.bitArray.removeAll()
                
                print("self.words = \(self.words)")
                
                if self.words != "" {
                   
                    self.mnemonicLabel = UILabel(frame: CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 280 + (self.scrollView.frame.width - 10) - 11, width: self.scrollView.frame.width - 10, height: 13))
                    self.mnemonicLabel.text = "Recovery Phrase:"
                    self.mnemonicLabel.font = .systemFont(ofSize: 12)
                    self.mnemonicLabel.textColor = UIColor.black
                    self.mnemonicLabel.textAlignment = .left
                    self.scrollView.addSubview(self.mnemonicLabel)
                    
                    self.mnemonicView = UITextView (frame:CGRect(x: self.scrollView.frame.minX + 5, y: self.scrollView.frame.minY + 285 + (self.scrollView.frame.width - 10), width: self.scrollView.frame.width - 10, height: 175))
                    self.mnemonicView.text = self.words//self.recoveryPhrase
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
                    
                    self.recoveryPhraseImage = self.generateQrCode(key: self.words)
                    self.recoveryPhraseQRView = UIImageView(image: self.recoveryPhraseImage!)
                    self.recoveryPhraseQRView.frame = CGRect(x: self.scrollView.frame.minX + 5, y: self.mnemonicView.frame.maxY + 90, width: self.scrollView.frame.width - 10, height: self.scrollView.frame.width - 10)
                    self.scrollView.addSubview(self.recoveryPhraseQRView)
                    
                }
                
            })
            
        })
        
    }
    
    @objc func home() {
        
        print("home")
        
        DispatchQueue.main.async {
            
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
            self.backUpButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 60, y: self.view.frame.maxY - 60, width: 55, height: 55))
            self.backUpButton.showsTouchWhenHighlighted = true
            self.backUpButton.setImage(#imageLiteral(resourceName: "backUp.jpg"), for: .normal)
            self.backUpButton.addTarget(self, action: #selector(self.airDropImage), for: .touchUpInside)
            self.view.addSubview(self.backUpButton)
        }
        
    }
    
    func showHideTools() {
        print("showHideTools")
        
        if toolBoxTapped == false {
            
            toolBoxTapped = true
            
            DispatchQueue.main.async {
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.sweepButton.alpha = 0
                    self.exportButton.alpha = 0
                    self.importButton.alpha = 0
                    self.mayerMultipleButton.alpha = 0
                    self.multiSigButton.alpha = 0
                    self.diceButton.alpha = 0
                    
                }, completion: { _ in
                    
                    self.sweepButton.removeFromSuperview()
                    self.exportButton.removeFromSuperview()
                    self.importButton.removeFromSuperview()
                    self.mayerMultipleButton.removeFromSuperview()
                    self.multiSigButton.removeFromSuperview()
                    self.diceButton.removeFromSuperview()
                    
                })
                
            }
            
        } else if toolBoxTapped == true {
            
            toolBoxTapped = false
            
            
                
                DispatchQueue.main.async {
                    
                    self.addImportButton()
                    self.addMultiSigButton()
                    self.addDiceButton()
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        
                        self.diceButton.alpha = 1
                        self.multiSigButton.alpha = 1
                        self.mayerMultipleButton.alpha = 1
                        self.importButton.alpha = 1
                        self.sweepButton.alpha = 1
                        self.exportButton.alpha = 1
                        
                    })
                    
                }
            
            if self.hotMode {
                
                DispatchQueue.main.async {
                    
                    self.addSweepButton()
                    self.addExportButton()
                    
                }
                
            }
            
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
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func addPasswordAlert() {
        
        var firstPassword = String()
        var secondPassword = String()
        
        let alert = UIAlertController(title: "BIP39 Password", message: "Please create a password, this will require you to remember your password along with your recovery phrase to import your Bitcoin, this is fully compatible with all BIP39 wallets.", preferredStyle: .alert)
        
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
                    
                    UserDefaults.standard.set(secondPassword, forKey: "password")
                    
                    displayAlert(viewController: self, title: "Success", message: "You have succesfully added a password that will be used when creating all your future wallets, please ensure you don't forget as you will need it along with your recovery phrase to recover your Bitcoin.")
                    
                } else {
                    
                    displayAlert(viewController: self, title: "Error", message: "Passwords did not match please start over.")
                    
                }
                
            }))
            
            confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                
                
            }))
            
            self.present(confirmationAlert, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func goTo(sender: UIButton) {
        print("goTo")
        
        switch sender {
            
        case self.addressBookButton:
            
            print("addressBookButton")
            self.performSegue(withIdentifier: "goToAddressBook", sender: self)
            
        case self.lockButton:
            
            print("lock button")
            
            if UserDefaults.standard.object(forKey: "password") != nil {
                
                let alert = UIAlertController(title: "Alert!", message: "This will overwrite your existing password, are you sure you want to continue?", preferredStyle: UIAlertControllerStyle.alert)
                
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { (action) in
                    
                    self.addPasswordAlert()
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                self.addPasswordAlert()
                
            }
            
        case self.priceButton:
            
            print("price button")
            self.performSegue(withIdentifier: "goToMayerMultiple", sender: self)
            
        case self.toolboxButton:
            
            print("tool box button")
            self.showKeyManagementAlert()
            
        case self.infoButton:
            
            print("go to info")
            self.performSegue(withIdentifier: "goToInfo", sender: self)
            
        case self.sweepButton:
            
            print("go to sweep")
            self.performSegue(withIdentifier: "sweep", sender: self)
            
        case self.settingsButton:
            
            print("go to settings")
            self.performSegue(withIdentifier: "settings", sender: self)
            
        case self.diceButton:
            
            sender.removeFromSuperview()
            self.importButton.removeFromSuperview()
            self.removeHomeScreen()
            self.showDice()
            
        case self.transactionsButton:
            
            self.performSegue(withIdentifier: "transaction", sender: self)
                
        case self.checkAddressButton:
            
            if simpleMode && addressBook.count == 0 {
                
                shakeAlert(viewToShake: self.imageView)
                
            } else {
                
                self.performSegue(withIdentifier: "checkAddress", sender: self)
                
            }
            
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
        
        let alert = UIAlertController(title: "Share", message: "You can share the QR Code or the text format of the address however you'd like", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        if self.extendedPublicKeyMode {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("XPUB QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.privateKeyImage) {
                    
                    let fileName = getDocumentsDirectory().appendingPathComponent("xpubKey.png")
                    
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
            
        } else if self.segwitMode {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.privateKeyImage) {
                    
                    let fileName = getDocumentsDirectory().appendingPathComponent("segwitAddress.png")
                    
                    try? data.write(to: fileName)
                    
                    let objectsToShare = [fileName]
                    DispatchQueue.main.async {
                        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        self.present(activityController, animated: true, completion: nil)
                    }
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Text", comment: ""), style: .default, handler: { (action) in
                
                let textToShare = [self.bitcoinAddress]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else if self.legacyMode {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.privateKeyImage) {
                    
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
                
                let textToShare = [self.bitcoinAddress]
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
        
        var network = ""
        
        if self.testnetMode {
            
            network = "testnet"
            
        } else {
            
            network = "mainnet"
        }
        
        if hotMode {
            
            /*alert.addAction(UIAlertAction(title: NSLocalizedString("Add to Address Book", comment: ""), style: .default, handler: { (action) in
                
                saveWallet(viewController: self, address: self.bitcoinAddress, privateKey: self.privateKeyWIF, publicKey: "", redemptionScript: "", network: network, type: "hot")
                
            }))*/
            
        } else {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Add to Address Book", comment: ""), style: .default, handler: { (action) in
                
                saveWallet(viewController: self, address: self.bitcoinAddress, privateKey: "", publicKey: "", redemptionScript: "", network: network, type: "cold")
                
            }))
        }
        
        if self.privateKeyMode {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Private Key QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.privateKeyQRCode) {
                    
                    let fileName = getDocumentsDirectory().appendingPathComponent("privateKey.png")
                    
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
            
            if self.words != "" {
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Recovery Phrase QR Code", comment: ""), style: .default, handler: { (action) in
                    
                    if let data = UIImagePNGRepresentation(self.recoveryPhraseImage) {
                        
                        let fileName = getDocumentsDirectory().appendingPathComponent("recoveryPhrase.png")
                        
                        try? data.write(to: fileName)
                        
                        let objectsToShare = [fileName]
                        
                        DispatchQueue.main.async {
                            
                            let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                            self.present(activityController, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Recovery Phrase Text", comment: ""), style: .default, handler: { (action) in
                    
                    let textToShare = [self.recoveryPhrase]
                    let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                    
                }))
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
        } else if self.legacyMode {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Legacy Address QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.privateKeyImage) {
                    
                    let fileName = getDocumentsDirectory().appendingPathComponent("bitcoinAddress.png")
                    
                    try? data.write(to: fileName)
                    
                    let objectsToShare = [fileName]
                    DispatchQueue.main.async {
                        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        self.present(activityController, animated: true, completion: nil)
                    }
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Legacy Address Text", comment: ""), style: .default, handler: { (action) in
                
                let textToShare = [self.bitcoinAddress]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                
            }))
            
            if self.words != "" {
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Recovery Phrase QR Code", comment: ""), style: .default, handler: { (action) in
                    
                    if let data = UIImagePNGRepresentation(self.recoveryPhraseImage) {
                        
                        let fileName = getDocumentsDirectory().appendingPathComponent("recoveryPhrase.png")
                        
                        try? data.write(to: fileName)
                        
                        let objectsToShare = [fileName]
                        
                        DispatchQueue.main.async {
                            
                            let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                            self.present(activityController, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Recovery Phrase Text", comment: ""), style: .default, handler: { (action) in
                    
                    let textToShare = [self.recoveryPhrase]
                    let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                    
                }))
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else if self.segwitMode {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Segwit Address QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.privateKeyImage) {
                    
                    let fileName = getDocumentsDirectory().appendingPathComponent("segwitAddress.png")
                    
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
            
            if self.words != ""  {
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Recovery Phrase QR Code", comment: ""), style: .default, handler: { (action) in
                    
                    if let data = UIImagePNGRepresentation(self.recoveryPhraseImage) {
                        
                        let fileName = getDocumentsDirectory().appendingPathComponent("recoveryPhrase.png")
                        
                        try? data.write(to: fileName)
                        
                        let objectsToShare = [fileName]
                        
                        DispatchQueue.main.async {
                            
                            let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                            self.present(activityController, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Recovery Phrase Text", comment: ""), style: .default, handler: { (action) in
                    
                    let textToShare = [self.recoveryPhrase]
                    let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                    
                }))
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
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
            
            if self.wordArray.count > 0 {
                
                self.wordArray.removeLast()
                self.listArray.removeLast()
                self.outputMnemonic.text = self.listArray.joined()
                
            }
            
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



