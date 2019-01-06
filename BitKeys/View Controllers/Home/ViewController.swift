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
    
    var infoView = UIView()
    var walletToExport = [String:Any]()
    var stopColorChange = Bool()
    let noButton = UIButton()
    let yesButton = UIButton()
    let labelTitle = UILabel()
    var name = String()
    let nameInput = UITextField()
    let alertView = UIView()
    var createAccount = Bool()
    var createDiceKey = Bool()
    var exportKeys = Bool()
    var importSeed = Bool()
    var backButton = UIButton()
    var modeLabel = UILabel()
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
    var scanQRCodeButton = UIButton()
    var diceMode = Bool()
    @IBOutlet var scrollView: UIScrollView!
    var privateKeyQRCode:UIImage!
    var privateKeyQRView:UIImageView!
    var privateKeyImage:UIImage!
    var recoveryPhraseQRView:UIImageView!
    var recoveryPhraseImage:UIImage!
    var imageView:UIView!
    var myField = UILabel()
    var mnemonicView: UITextView!
    var button = UIButton(type: .custom)
    var bitcoinAddressButton = UIButton(type: .custom)
    var backUpButton = UIButton(type: .custom)
    var privateKeyText:String!
    var bitcoinAddress:String!
    var privateKeyMode:Bool!
    var segwitAddressMode:Bool!
    var legacyAddressMode:Bool!
    var diceButton = UIButton()
    var parseBitResult = BigInt()
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
    var watchOnlyMode = Bool()
    var clearMnemonicButton = UIButton()
    var addressBook = [[String: Any]]()
    var tappedShare = Bool()
    var backgroundColours = [UIColor()]
    var backgroundLoop:Int = 0
    var tapGesture = UITapGestureRecognizer()
    let imageViewSuccess = UIImageView()
    var firstPassword = String()
    var secondPassword = String()
    let bIP39infoButton = UIButton()
    let explainerLabel = UILabel()
    
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
        view.addSubview(imageView)
        alertView.addSubview(imageView)
        diceMode = false
        inputMnemonic.delegate = self
        inputPassword.delegate = self
        nameInput.delegate = self
        privateKeyMode = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        
        if createAccount {
            
            self.view.backgroundColor = UIColor.black
            createNewAccount()
        }
        
        if createDiceKey {
            
            showDice()
        }
        
        if importSeed {
            
            importMnemonic()
        }
        
        if exportKeys {
            
            exportWallet(wallet: self.walletToExport)
        }
        
        yesButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        yesButton.titleLabel?.textAlignment = .right
        yesButton.backgroundColor = UIColor.clear
        yesButton.showsTouchWhenHighlighted = true
        addShadow(view: yesButton)
        yesButton.setTitleColor(UIColor.white, for: .normal)
        
        noButton.showsTouchWhenHighlighted = true
        addShadow(view: noButton)
        noButton.backgroundColor = UIColor.clear
        noButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        noButton.setTitleColor(UIColor.white, for: .normal)
        
        percentageLabel.frame = CGRect(x: view.frame.maxX / 2 - 50, y: view.frame.minY + 10, width: 100, height: 50)
        percentageLabel.textColor = UIColor.white
        percentageLabel.backgroundColor = UIColor.clear
        addShadow(view: percentageLabel)
        percentageLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 30)
        percentageLabel.textAlignment = .center
        
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        inputMnemonic.resignFirstResponder()
        inputPassword.resignFirstResponder()
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
  }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.inputPassword {
            self.password = self.inputPassword.text!
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
        self.inputMnemonic.keyboardAppearance = UIKeyboardAppearance.dark
        self.inputMnemonic.spellCheckingType = .no
        self.view.addSubview(self.inputMnemonic)
        self.inputMnemonic.becomeFirstResponder()
        
        self.outputMnemonic.frame = CGRect(x: self.view.frame.minX + 5, y: self.inputMnemonic.frame.maxY + 100, width: self.view.frame.width - 10, height: 200)
        self.outputMnemonic.textAlignment = .left
        self.outputMnemonic.isEditable = false
        self.outputMnemonic.textColor = UIColor.white
        addShadow(view: self.outputMnemonic)
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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    
    
    
    func createNewAccount() {
        
        getWalletName()
    }
    
    func getWalletName() {
        
        alertView.frame = self.view.frame
        alertView.backgroundColor = UIColor.black
        alertView.alpha = 0
        nameInput.keyboardType = UIKeyboardType.default
        nameInput.layer.cornerRadius = 10
        nameInput.backgroundColor = UIColor.white
        nameInput.textColor = UIColor.black
        nameInput.textAlignment = .center
        nameInput.keyboardAppearance = UIKeyboardAppearance.dark
        nameInput.autocorrectionType = .no
        nameInput.alpha = 0
        labelTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 18)
        labelTitle.textColor = UIColor.white
        labelTitle.numberOfLines = 0
        labelTitle.alpha = 0
        
        let retrievedPassword:String? = KeychainWrapper.standard.string(forKey: "BIP39Password")
        if retrievedPassword == nil || retrievedPassword == "" {
            
            DispatchQueue.main.async {
                self.labelTitle.text = "First things first, please set a \"Dual Factor\" password that protects your Bitcoin incase you lose this device."
                self.labelTitle.textAlignment = .natural
                self.nameInput.placeholder = "Dual Factor Password"
                self.nameInput.isSecureTextEntry = true
                self.yesButton.setTitle("Next", for: .normal)
                self.yesButton.addTarget(self, action: #selector(self.firstBIP39Password), for: .touchUpInside)
                
                self.bIP39infoButton.setTitle("What's this?", for: .normal)
                self.bIP39infoButton.titleLabel?.textAlignment = .center
                self.bIP39infoButton.setTitleColor(UIColor.white, for: .normal)
                self.bIP39infoButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
                self.bIP39infoButton.addTarget(self, action: #selector(self.showBIP39Info), for: .touchUpInside)
                self.bIP39infoButton.backgroundColor = UIColor.clear
                self.bIP39infoButton.frame = CGRect(x: 50, y: 20, width: self.view.frame.width - 100, height: 20)
                self.labelTitle.frame = CGRect(x: 10, y: self.view.frame.maxY / 8, width: self.view.frame.width - 20, height: 100)
                self.nameInput.frame = CGRect(x: 10, y: self.labelTitle.frame.maxY + 10, width: self.view.frame.width - 20, height: 50)
                self.yesButton.frame = CGRect(x: self.view.center.x - 40, y: self.nameInput.frame.maxY + 10, width: 80, height: 50)
                self.view.addSubview(self.alertView)
                self.alertView.addSubview(self.labelTitle)
                self.alertView.addSubview(self.bIP39infoButton)
                self.alertView.addSubview(self.nameInput)
                self.alertView.addSubview(self.yesButton)
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                self.labelTitle.frame = CGRect(x: 50, y: self.view.frame.maxY / 5, width: self.view.frame.width - 100, height: 50)
                self.labelTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 20)
                self.labelTitle.text = "Give your wallet a name:"
                self.nameInput.placeholder = "Wallet Name"
                self.nameInput.isSecureTextEntry = false
                self.labelTitle.textAlignment = .center
                self.nameInput.frame = CGRect(x: 50, y: self.labelTitle.frame.maxY + 10, width: self.view.frame.width - 100, height: 50)
                self.yesButton.frame = CGRect(x: self.view.center.x - 40, y: self.nameInput.frame.maxY + 30, width: 80, height: 50)
                self.yesButton.setTitle("Next", for: .normal)
                self.yesButton.addTarget(self, action: #selector(self.dismissNameInput), for: .touchUpInside)
                self.view.addSubview(self.alertView)
                self.alertView.addSubview(self.labelTitle)
                self.alertView.addSubview(self.nameInput)
                self.alertView.addSubview(self.yesButton)
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alertView.alpha = 1
            self.labelTitle.alpha = 1
            self.yesButton.alpha = 1
            self.nameInput.alpha = 1
        }) { _ in
            self.nameInput.becomeFirstResponder()
        }
        
    }
    
    @objc func firstBIP39Password() {
        
        if self.nameInput.text != "" {
            
            DispatchQueue.main.async {
                self.labelTitle.text = "Please confirm the \"Dual Factor\" password to ensure there were no typos."
                self.firstPassword = self.nameInput.text!
                self.nameInput.text = ""
                self.yesButton.setTitle("Verify", for: .normal)
                self.yesButton.removeTarget(self, action: #selector(self.firstBIP39Password), for: .touchUpInside)
                self.yesButton.addTarget(self, action: #selector(self.secondBIP39Password), for: .touchUpInside)
                
            }
        } else {
            shakeAlert(viewToShake: self.nameInput)
        }
    }
    
    @objc func secondBIP39Password() {
        
        if self.nameInput.text != "" {
            
            self.secondPassword = self.nameInput.text!
            
            if self.firstPassword == self.secondPassword {
                
                let saveSuccessful:Bool = KeychainWrapper.standard.set(self.secondPassword, forKey: "BIP39Password")
                
                if saveSuccessful {
                    
                    self.yesButton.removeTarget(self, action: #selector(self.secondBIP39Password), for: .touchUpInside)
                    self.nameInput.text = ""
                    self.nameInput.resignFirstResponder()
                    self.bIP39infoButton.removeFromSuperview()
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.alertView.alpha = 0
                            self.labelTitle.alpha = 0
                            self.yesButton.alpha = 0
                            self.nameInput.alpha = 0
                        }) { _ in
                            self.alertView.removeFromSuperview()
                            self.labelTitle.removeFromSuperview()
                            self.yesButton.removeFromSuperview()
                            self.nameInput.removeFromSuperview()
                            self.getWalletName()
                        }
                    }
                    
                } else {
                    
                    displayAlert(viewController: self, title: "Error", message: "Unable to save the password! Please try again.")
                    
                }
            } else {
                displayAlert(viewController: self, title: "Error", message: "Passwords did not match, try again.")
            }
        } else {
            shakeAlert(viewToShake: self.nameInput)
        }
    }
    
    @objc func showBIP39Info() {
        
        DispatchQueue.main.async {
            self.nameInput.resignFirstResponder()
            self.infoView.frame = self.view.frame
            self.infoView.backgroundColor = UIColor.black
            self.infoView.alpha = 0
            self.view.addSubview(self.infoView)
            
            self.explainerLabel.frame = CGRect(x: 25, y: 40, width: self.view.frame.width - 50, height: self.view.frame.height - 110)
            self.explainerLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 18)
            self.explainerLabel.adjustsFontSizeToFitWidth = true
            self.explainerLabel.textColor = UIColor.white
            self.explainerLabel.numberOfLines = 0
            self.explainerLabel.text = "Your \"Dual Factor\" password is what is known as a \"BIP39 Passphrase\". When you create a new wallet we will give you a \"Recovery Phrase\" which allows you to restore your wallet on a different device should you lose this one. The \"Dual Factor\" password protects your Bitcoin by requiring you to input the \"Dual Factor\" password whenever you try and import your wallet using your \"Recovery Phrase\". This means even if someone knows your \"Recovery Phrase\" they still would not have access to your Bitcoin unless they also knew your \"Dual Factor\" password.\n\nIt's extremely important you remember this password as without it you will not be able to import your wallet using your \"Recovery Phrase\". To learn more visit: https:\\wwww.xxx"
            self.explainerLabel.textAlignment = .natural
            self.explainerLabel.alpha = 0
            self.infoView.addSubview(self.explainerLabel)
            
            let gotItButton = UIButton()
            gotItButton.frame = CGRect(x: 10, y: self.view.frame.maxY - 60, width: 80, height: 50)
            gotItButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
            gotItButton.setTitle("Got it", for: .normal)
            gotItButton.titleLabel?.textAlignment = .right
            gotItButton.addTarget(self, action: #selector(self.dimsissBIP39Explainer), for: .touchUpInside)
            self.infoView.addSubview(gotItButton)
            
            UIView.animate(withDuration: 0.2, animations: {
                self.infoView.alpha = 1
                self.explainerLabel.alpha = 1
                gotItButton.alpha = 1
            })
        }
    }
    
    @objc func dimsissBIP39Explainer() {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.infoView.alpha = 0
            self.explainerLabel.alpha = 0
        }) { _ in
            self.infoView.removeFromSuperview()
            self.explainerLabel.removeFromSuperview()
        }
        
    }
    
    @objc func dismissNameInput() {
        
        if self.nameInput.text != "" {
            
            self.name = self.nameInput.text!
           
            UIView.animate(withDuration: 0.2, animations: {
                
                self.nameInput.alpha = 0
                self.labelTitle.alpha = 0
                self.yesButton.alpha = 0
                
            }) { _ in
                
                self.nameInput.removeFromSuperview()
                self.labelTitle.removeFromSuperview()
                self.yesButton.removeFromSuperview()
                
                var array = [String(), Bool()] as [Any]
                array = createPrivateKey(viewController: self, label: self.name)
                
                if array[1] as! Bool{
                    
                    self.words = array[0] as! String
                    self.success()
                    
                } else {
                    
                    displayAlert(viewController: self, title: "Error", message: "There was an error creating your wallet, please contact us to let us know what happened at BitSenseApp@gmail.com")
                    
                }
                
            }
            
        } else {
            
            shakeAlert(viewToShake: self.nameInput)
            
        }
        
        
    }
    
    func exportWallet(wallet: [String:Any]) {
        print("exportWallet")
        
        let imageView = UIImageView()
        imageView.image = UIImage(named:"background.jpg")
        imageView.frame = self.view.frame
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.alpha = 0.05
        self.view.addSubview(imageView)
        
        let walletName = wallet["label"] as! String
        let stringToExport = wallet["stringToExport"] as! String
        let descriptor = wallet["descriptor"] as! String
        let titleLabel = wallet["title"] as! String
        var title = ""
        
        switch descriptor {
        case "publicKey": title = "\(titleLabel)\n\nFor \"\(walletName)\""
            self.filename = "publicKey"
        case "privateKey": title = "\(titleLabel)\n\nFor \"\(walletName)\""
            self.filename = "privateKey"
        case "address": title = "\(titleLabel)\n\nFor \"\(walletName)\""
            self.filename = "address"
        case "mnemonic": title = "\(titleLabel)\n\nFor \"\(walletName)\""
            self.filename = "mnemonic"
        case "redemptionScript": title = "\(titleLabel)\n\nFor \"\(walletName)\""
            self.filename = "redemptionScript"
        case "xpub": title = "\(titleLabel)\n\nFor \"\(walletName)\""
            self.filename = "xpub"
        case "xpriv": title = "\(titleLabel)\n\nFor \"\(walletName)\""
            self.filename = "xprv"
        default:
            break
        }
        
        self.textToShare = stringToExport
        
        diceMode = false
        self.importAction.removeFromSuperview()
        self.outputMnemonic.removeFromSuperview()
        
        self.privateKeyQRCode = self.generateQrCode(key: stringToExport)
        self.privateKeyQRView = UIImageView(image: self.privateKeyQRCode!)
        self.privateKeyQRView.frame = CGRect(x: 35, y: self.view.center.y - ((self.view.frame.width - 70) / 2), width: self.view.frame.width - 70, height: self.view.frame.width - 70)
        self.privateKeyQRView.alpha = 0
        addShadow(view: self.privateKeyQRView)
        self.view.addSubview(self.privateKeyQRView)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.privateKeyQRView.alpha = 1
            
        }, completion: { _ in
            
            DispatchQueue.main.async {
                
                UIImpactFeedbackGenerator().impactOccurred()
                
                self.privateKeyTitle.frame = CGRect(x: 10, y: self.privateKeyQRView.frame.minY - 100, width: self.view.frame.width - 20, height: 100)
                self.privateKeyTitle.adjustsFontSizeToFitWidth = true
                self.privateKeyTitle.text = title
                self.privateKeyTitle.numberOfLines = 0
                self.privateKeyTitle.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
                self.privateKeyTitle.textColor = UIColor.white
                addShadow(view: self.privateKeyTitle)
                self.privateKeyTitle.textAlignment = .center
                self.view.addSubview(self.privateKeyTitle)
                
            }
            
            self.myLabel = UILabel (frame:CGRect(x: self.view.center.x - ((self.view.frame.width - 20)/2), y: self.privateKeyQRView.frame.maxY, width: self.view.frame.width - 20, height: 100))
            self.myLabel.textAlignment = .center
            addShadow(view: self.myLabel)
            self.myLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 18)
            self.myLabel.textColor = UIColor.white
            self.myLabel.numberOfLines = 0
            self.myLabel.text = stringToExport
            self.myLabel.adjustsFontSizeToFitWidth = true
            self.view.addSubview(self.myLabel)
            
            self.addHomeButton()
            self.addBackUpButton()
            
        })
        
    }
    
    func getImportWalletName() {
        
        alertView.frame = self.view.frame
        alertView.backgroundColor = UIColor.black
        alertView.alpha = 0
        self.view.addSubview(alertView)
        
        labelTitle.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 100) / 2), y: self.view.frame.maxY / 5, width: self.view.frame.width - 100, height: 50)
        labelTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 20)
        labelTitle.textColor = UIColor.white
        labelTitle.numberOfLines = 0
        labelTitle.text = "Give your wallet a name"
        labelTitle.textAlignment = .center
        labelTitle.alpha = 0
        alertView.addSubview(labelTitle)
        
        nameInput.frame = CGRect(x: 50, y: labelTitle.frame.maxY + 10, width: self.view.frame.width - 100, height: 50)
        nameInput.keyboardType = UIKeyboardType.default
        nameInput.layer.cornerRadius = 10
        nameInput.backgroundColor = UIColor.white
        nameInput.textColor = UIColor.black
        nameInput.isSecureTextEntry = false
        nameInput.textAlignment = .center
        nameInput.keyboardAppearance = UIKeyboardAppearance.dark
        nameInput.alpha = 0
        alertView.addSubview(self.nameInput)
        
        yesButton.frame = CGRect(x: self.view.center.x - 40, y: nameInput.frame.maxY + 60, width: 80, height: 50)
        yesButton.setTitle("Next", for: .normal)
        yesButton.addTarget(self, action: #selector(self.importNow), for: .touchUpInside)
        alertView.addSubview(yesButton)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alertView.alpha = 1
            self.labelTitle.alpha = 1
            self.yesButton.alpha = 1
            self.nameInput.alpha = 1
        }) { _ in
            self.nameInput.becomeFirstResponder()
        }
    }
    
    @objc func importNow() {
        print("importNow")
        
        self.name = self.nameInput.text!
        
        func error() {
            
            DispatchQueue.main.async {
                self.outputMnemonic.text = ""
                self.wordArray.removeAll()
                self.password = ""
                self.inputPassword.text = ""
                self.listArray.removeAll()
                displayAlert(viewController: self, title: "Error", message: "Sorry that phrase is not BIP39 compatible, make sure you enter the correct words with no misspellings and no spaces after each word.")
            }
        }
        
        if self.name == "" {
            
            if let _ = BTCMnemonic.init(words: self.wordArray, password: self.inputPassword.text!, wordListType: BTCMnemonicWordListType.english) {
                
                self.getImportWalletName()
                
            } else {
                
                error()
            }
            
            
        } else {
            
            if self.nameInput.text != "" {
                
                if let testInputMnemonic = BTCMnemonic.init(words: self.wordArray, password: self.inputPassword.text!, wordListType: BTCMnemonicWordListType.english) {
                    
                    self.nameInput.resignFirstResponder()
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        self.alertView.alpha = 0
                        self.labelTitle.alpha = 0
                        self.yesButton.alpha = 0
                        self.nameInput.alpha = 0
                    }, completion: { _ in
                        
                        self.alertView.removeFromSuperview()
                        self.labelTitle.removeFromSuperview()
                        self.yesButton.removeFromSuperview()
                        self.nameInput.removeFromSuperview()
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
                        let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain?.key(at: 0).compressedPublicKey as Data!) as Data!) as Data!
                        var network = ""
                        let xpub = (keychain?.extendedPublicKey)!
                        let xpriv = (keychain?.extendedPrivateKey)!
                        var success = Bool()
                        
                        switch true {
                            
                        case self.testnetMode && self.legacyMode:
                            
                            network = "testnet"
                            self.privateKeyWIF = (keychain?.key(at: 0).privateKeyAddressTestnet.string)!
                            self.bitcoinAddress = (keychain?.key(at: 0).addressTestnet.string)!
                            
                        case self.testnetMode && self.segwitMode:
                            
                            network = "testnet"
                            self.privateKeyWIF = (keychain?.key(at: 0).privateKeyAddressTestnet.string)!
                            do {
                            self.bitcoinAddress = try self.segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                            } catch {
                                displayAlert(viewController: self, title: "Error", message: "We had an issue creating the segwit address, please email us at BitSenseApp@gmail.com")
                            }
                            
                        case self.mainnetMode && self.legacyMode:
                            
                            network = "mainnet"
                            self.privateKeyWIF = (keychain?.key(at: 0).privateKeyAddress.string)!
                            self.bitcoinAddress = (keychain?.key(at: 0).address.string)!
                            
                        case self.mainnetMode && self.segwitMode:
                            
                            network = "mainnet"
                            self.privateKeyWIF = (keychain?.key(at: 0).privateKeyAddress.string)!
                            do {
                                self.bitcoinAddress = try self.segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                            } catch {
                                displayAlert(viewController: self, title: "Error", message: "We had an issue creating the segwit address, please email us at BitSenseApp@gmail.com")
                            }
                            
                        default:
                            break
                        }
                        
                        switch true {
                            
                        case self.hotMode:
                            
                            switch true {
                            case self.legacyMode:
                                success = saveWallet(viewController: self, mnemonic: formateMnemonic3, xpub: xpub, address: self.bitcoinAddress, privateKey: self.privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: network, type: "hot", index: 0, label: self.name, xpriv: xpriv)
                            case self.segwitMode:
                                success = saveWallet(viewController: self, mnemonic: "", xpub: "", address: self.bitcoinAddress, privateKey: self.privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: network, type: "hot", index: 0, label: self.name, xpriv: "")
                            default:
                                break
                            }
                            
                        case self.coldMode:
                            
                            switch true {
                            case self.legacyMode:
                                success = saveWallet(viewController: self, mnemonic: "", xpub: xpub, address: self.bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: network, type: "cold", index: 0, label: self.name, xpriv: xpriv)
                            case self.segwitMode:
                                success = saveWallet(viewController: self, mnemonic: "", xpub: "", address: self.bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: network, type: "cold", index: 0, label: self.name, xpriv: "")
                            default:
                                break
                            }
                            
                        default:
                            break
                        }
                        
                        if success {
                            
                            keychain?.key.clear()
                            self.outputMnemonic.removeFromSuperview()
                            self.inputMnemonic.removeFromSuperview()
                            self.inputPassword.removeFromSuperview()
                            self.clearMnemonicButton.removeFromSuperview()
                            self.importAction.removeFromSuperview()
                            self.showRecoveryPhraseAndQRCode()
                            
                        } else {
                            
                            displayAlert(viewController: self, title: "Error", message: "Something went wrong, please contact us at BitSenseApp@gmail.com.")
                        }
                    })
                    
                } else {
                    
                    error()
                }
                
            } else {
                
                shakeAlert(viewToShake: self.nameInput)
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
            addShadow(view: self.importAction)
            self.importAction.setTitleColor(UIColor.white, for: .normal)
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
            
            let detector:CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            let ciImage:CIImage = CIImage(image:pickedImage)!
            var qrCodeLink = ""
            let features = detector.features(in: ciImage)
            for feature in features as! [CIQRCodeFeature] {
                qrCodeLink += feature.messageString!
            }
            
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
        self.scanQRCodeButton.removeFromSuperview()
        
        self.qrimageview.frame = CGRect(x: 25, y: self.importAction.frame.maxY + 10, width: self.view.frame.width - 50, height: self.view.frame.width - 20)
        addShadow(view: self.qrimageview)
        
        self.uploadButton.removeFromSuperview()
        self.uploadButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 140, y: self.view.frame.maxY - 60, width: 130, height: 55))
        self.uploadButton.showsTouchWhenHighlighted = true
        self.uploadButton.setTitle("From Photos", for: .normal)
        addShadow(view: self.uploadButton)
        self.uploadButton.setTitleColor(UIColor.white, for: .normal)
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
            self.myField.removeFromSuperview()
        self.uploadButton.removeFromSuperview()
        self.scanQRCodeButton.removeFromSuperview()
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
        self.dismiss(animated: true, completion: nil)
        
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
    
    func success() {
        print("success")
        
        labelTitle.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 100) / 2), y: 25, width: self.view.frame.width - 100, height: 150)
        labelTitle.font = UIFont.init(name: "HelveticaNeue-Bold", size: 30)
        labelTitle.textColor = UIColor.white
        labelTitle.backgroundColor = UIColor.clear
        addShadow(view: labelTitle)
        labelTitle.numberOfLines = 0
        labelTitle.adjustsFontSizeToFitWidth = true
        labelTitle.text = "😃\n\nCongratulations!\n\nYou created a Bitcoin Wallet"
        labelTitle.textAlignment = .center
        labelTitle.alpha = 0
        alertView.addSubview(labelTitle)
        
        imageViewSuccess.image = UIImage(named: "whiteCheck")
        imageViewSuccess.frame = CGRect(x: self.view.center.x - 95, y: (self.view.center.y - 95), width: 190, height: 190)
        imageViewSuccess.alpha = 0
        addShadow(view: imageViewSuccess)
        alertView.addSubview(imageViewSuccess)
        
        imageViewSuccess.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: CGFloat(0.20), initialSpringVelocity: CGFloat(6.0), options: UIViewAnimationOptions.allowUserInteraction, animations: {
            
            self.imageViewSuccess.alpha = 1
            self.imageViewSuccess.transform = CGAffineTransform.identity
            
        }, completion: { Void in()
            
            
        })
        
        yesButton.frame = CGRect(x: self.view.center.x - 40, y: self.view.frame.maxY - 100, width: 80, height: 50)
        yesButton.setTitle("OK", for: .normal)
        yesButton.removeTarget(self, action: #selector(self.dismissNameInput), for: .touchUpInside)
        yesButton.addTarget(self, action: #selector(self.dismissSuccess), for: .touchUpInside)
        alertView.addSubview(yesButton)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alertView.alpha = 1
            self.labelTitle.alpha = 1
            self.yesButton.alpha = 1
        })
    }
    
    @objc func dismissSuccess() {
        print("dismisssuccess")
        
        if !isInternetAvailable() {
            
            UIView.animate(withDuration: 0.2, animations: {
                self.imageViewSuccess.alpha = 0
                self.alertView.alpha = 0
                self.labelTitle.alpha = 0
                self.yesButton.alpha = 0
            }) { _ in
                self.alertView.removeFromSuperview()
                self.imageViewSuccess.removeFromSuperview()
                self.labelTitle.removeFromSuperview()
                self.yesButton.removeFromSuperview()
                self.showRecoveryPhraseAndQRCode()
            }
            
        } else {
            
            displayAlert(viewController: self, title: "Security Alert!", message: "You must put your device into airplane mode and turn your wifi off to continue, we are about to display your recovery phrase and for security reasons you should not be connected to the internet when displaying it.")
        }
        
        
        
    }
    
    
    func showRecoveryPhraseAndQRCode() {
        print("showPrivateKeyAndAddressQRCodes")
        
        self.view.backgroundColor = UIColor.black
        let imageView = UIImageView()
        imageView.image = UIImage(named:"background.jpg")
        imageView.frame = self.view.frame
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.alpha = 0.05
        self.view.addSubview(imageView)
        self.recoveryMode = true
        self.outputMnemonic.removeFromSuperview()
        self.inputMnemonic.removeFromSuperview()
        self.inputPassword.removeFromSuperview()
        self.clearMnemonicButton.removeFromSuperview()
        self.button.removeFromSuperview()
        self.importAction.removeFromSuperview()
        
        
        func addButtons() {
            
            self.button.removeFromSuperview()
            self.button = UIButton(frame: CGRect(x: 5, y: self.view.frame.maxY - 60, width: 90, height: 55))
            self.button.showsTouchWhenHighlighted = true
            self.button.setTitle("Done", for: .normal)
            self.button.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
            self.button.backgroundColor = UIColor.clear
            addShadow(view: self.button)
            self.button.setTitleColor(UIColor.white, for: .normal)
            self.button.addTarget(self, action: #selector(self.home), for: .touchUpInside)
            self.view.addSubview(self.button)
            
        }
        
        diceMode = false
        
        self.mnemonicLabel.frame = CGRect(x: 5, y: 25, width: self.view.frame.width - 10, height: 60)
        self.mnemonicLabel.text = "You must save the green phrase to recover lost funds!"
        self.mnemonicLabel.adjustsFontSizeToFitWidth = true
        self.mnemonicLabel.numberOfLines = 0
        self.mnemonicLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 30)
        self.mnemonicLabel.textColor = UIColor.red
        self.mnemonicLabel.textAlignment = .center
        self.mnemonicLabel.alpha = 0
        self.view.addSubview(self.mnemonicLabel)
        
        self.recoveryPhraseImage = self.generateQrCode(key: self.words)
        self.recoveryPhraseQRView = UIImageView(image: self.recoveryPhraseImage!)
        self.recoveryPhraseQRView.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 70) / 2), y: self.view.center.y / 2.5, width: self.view.frame.width - 70, height: self.view.frame.width - 70)
        self.recoveryPhraseQRView.alpha = 0
        self.view.addSubview(self.recoveryPhraseQRView)
        
        let infoButton = UIButton()
        infoButton.frame = CGRect(x: 50, y: self.recoveryPhraseQRView.frame.minY - 25, width: self.view.frame.width - 100, height: 20)
        infoButton.setTitle("What's this?", for: .normal)
        infoButton.titleLabel?.textAlignment = .center
        infoButton.setTitleColor(UIColor.white, for: .normal)
        infoButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        infoButton.addTarget(self, action: #selector(self.showInfo), for: .touchUpInside)
        infoButton.backgroundColor = UIColor.clear
        self.view.addSubview(infoButton)
        
        let label = UILabel()
        label.frame = CGRect(x: 10, y: self.recoveryPhraseQRView.frame.maxY + 5, width: self.view.frame.width - 20, height: 10)
        label.text = "Your Recovery Phrase:"
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.init(name: "HelveticaNeue-Bold", size: 8)
        self.view.addSubview(label)
        
        myField.frame = CGRect(x: 5, y: label.frame.maxY, width: self.view.frame.width - 20, height: 110)
        myField.text = self.words
        myField.backgroundColor = UIColor.black
        myField.clipsToBounds = true
        myField.layer.cornerRadius = 10
        myField.adjustsFontSizeToFitWidth = true
        myField.textColor = UIColor.green
        myField.numberOfLines = 0
        myField.textAlignment = .center
        myField.font = UIFont.init(name: "HelveticaNeue-Bold", size: 18)
        myField.alpha = 0
        self.view.addSubview(self.myField)
        
        self.textToShare = self.words
        self.filename = "recoveryPhrase"
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.recoveryPhraseQRView.alpha = 1
            self.recoveryPhraseLabel.alpha = 1
            self.mnemonicLabel.alpha = 1
            self.myField.alpha = 1
            
        }, completion: { _ in
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            self.scrollView.setContentOffset(.zero, animated: false)
            addButtons()
            self.addBackUpButton()
            DispatchQueue.main.async {
                self.backUpButton.setTitle("Save", for: .normal)
            }
        })
        
    }
    
    @objc func showInfo() {
        
        
        self.infoView.frame = self.view.frame
        self.infoView.backgroundColor = UIColor.black
        self.infoView.alpha = 0
        self.view.addSubview(self.infoView)
        
        labelTitle.frame = CGRect(x: 25, y: 40, width: self.view.frame.width - 50, height: self.view.frame.height - 110)
        labelTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 18)
        labelTitle.textColor = UIColor.white
        labelTitle.numberOfLines = 0
        labelTitle.text = "You must save the green words in the order they appear. You will be able to use that phrase to recover your Bitcoin if you lose this device. We provide you with a QR code which you can simply scan with any device to import or save the phrase easily. If anyone finds your recovery phrase they can steal all your Bitcoin unless you have also set a Dual Factor password.\n\nThis phrase will allow you to import your BitSense wallet into most popular Bitcoin wallets such as: blockchain.info, Coinomi, Samaurai, Mycelium, Electrum, Ledger, Trezor, CoinVault, CoPay, KeepKey (according to the official BIP44 website)\n\nThe recovery phrase is created using BIP39 and BIP44. This is the industry standard, you can test it yourself at https://iancoleman.io/bip39/ which you should only do for testing purposes."
        labelTitle.textAlignment = .natural
        labelTitle.alpha = 0
        self.infoView.addSubview(labelTitle)
        
        yesButton.frame = CGRect(x: 10, y: self.view.frame.maxY - 60, width: 80, height: 50)
        yesButton.setTitle("Got it", for: .normal)
        yesButton.titleLabel?.textAlignment = .right
        yesButton.removeTarget(self, action: #selector(self.dismissSuccess), for: .touchUpInside)
        yesButton.addTarget(self, action: #selector(self.dimsissExplainer), for: .touchUpInside)
        self.infoView.addSubview(yesButton)
        
       UIView.animate(withDuration: 0.2, animations: {
            self.infoView.alpha = 1
            self.labelTitle.alpha = 1
            self.yesButton.alpha = 1
            self.noButton.alpha = 1
        })
        
    }
    
    @objc func dimsissExplainer() {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.infoView.alpha = 0
            self.labelTitle.alpha = 0
            self.yesButton.alpha = 0
        }) { _ in
            self.labelTitle.removeFromSuperview()
            self.yesButton.removeFromSuperview()
            self.alertView.removeFromSuperview()
        }
    }
    
    @objc func home() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        if self.recoveryMode {
            
            alertView.frame = self.view.frame
            alertView.backgroundColor = UIColor.black
            alertView.alpha = 0
            self.view.addSubview(alertView)
            
            labelTitle.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 100) / 2), y: 50, width: self.view.frame.width - 100, height: 200)
            labelTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 30)
            labelTitle.textColor = UIColor.white
            labelTitle.numberOfLines = 0
            labelTitle.text = "Have you saved the recovery phrase?\n\nBe honest..."
            labelTitle.textAlignment = .center
            labelTitle.alpha = 0
            alertView.addSubview(labelTitle)
            
            yesButton.frame = CGRect(x: 10, y: self.view.frame.maxY - 60, width: 80, height: 50)
            yesButton.setTitle("Yes", for: .normal)
            yesButton.titleLabel?.textAlignment = .right
            yesButton.removeTarget(self, action: #selector(self.dimsissExplainer), for: .touchUpInside)
            yesButton.removeTarget(self, action: #selector(self.dismissSuccess), for: .touchUpInside)
            yesButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
            alertView.addSubview(yesButton)
            
            noButton.frame = CGRect(x: self.view.frame.maxX - 90, y: self.view.frame.maxY - 60, width: 80, height: 50)
            noButton.setTitle("No", for: .normal)
            noButton.titleLabel?.textAlignment = .right
            noButton.addTarget(self, action: #selector(self.no), for: .touchUpInside)
            alertView.addSubview(noButton)
            
            UIView.animate(withDuration: 0.2, animations: {
                self.alertView.alpha = 1
                self.labelTitle.alpha = 1
                self.yesButton.alpha = 1
                self.noButton.alpha = 1
            })
            
        } else {
           
            self.goBack()
            
        }
    }
    
    @objc func no() {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alertView.alpha = 0
        }) { _ in
            self.alertView.removeFromSuperview()
        }
    }
    
    @objc func goBack() {
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
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
            self.backUpButton.setTitleColor(UIColor.white, for: .normal)
            self.backUpButton.backgroundColor = UIColor.clear
            addShadow(view: self.backUpButton)
            self.backUpButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
            self.backUpButton.addTarget(self, action: #selector(self.goTo(sender:)), for: .touchUpInside)
            self.view.addSubview(self.backUpButton)
        }
        
    }
   
    
    @objc func goTo(sender: UIButton) {
        print("goTo")
        
        switch sender {
            
        case self.backUpButton:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            
            print("words = \(self.words)")
            
            if self.words != "" {
                
                let retrievedPassword:String? = KeychainWrapper.standard.string(forKey: "BIP39Password")
                
                if retrievedPassword == "" || retrievedPassword == nil {
                    
                    displayAlert(viewController: self, title: "Security Alert!", message: "You can only use this option if your recovery phrase is protected with a Dual Factor Password, if you have not created a Dual factor Password you can only save this by writing it down. To create a Dual Factor Password go to the home screen and tap the Lock button.")
                    
                } else {
                    
                    self.addAlertForShare(textToShare: self.textToShare, filename: self.filename)
                    
                }
                
            } else {
                
                self.addAlertForShare(textToShare: self.textToShare, filename: self.filename)
            }
            
            
        
            
        case self.diceButton:
            
            sender.removeFromSuperview()
            self.importButton.removeFromSuperview()
            self.showDice()
            
        
            
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
            
            if self.textToShare != "" {
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Text", comment: ""), style: .default, handler: { (action) in
                    
                    let textToShare = [textToShare]
                    let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                    
                }))
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in }))
            
            alert.popoverPresentationController?.sourceView = self.view
            
            self.present(alert, animated: true) {
                print("option menu presented")
            }
            
        }
        
    }
    
    func addPercentageCompleteLabel() {
        DispatchQueue.main.async {
            let percentage:Double = (Double(self.bitCount) / 256.0) * 100.0
            self.percentageLabel.text = "\(Int(percentage))%"
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
        
        if self.tappedIndex > 0 {
            self.clearDice(sender: self.diceArray[self.tappedIndex - 1])
        }
        
        
    }
    
    func clearDice(sender: UIButton) {
        print("clearDice")
        
        DispatchQueue.main.async {
            self.tappedIndex = self.tappedIndex - 1
            sender.setTitle("0", for: .normal)
            sender.setImage(#imageLiteral(resourceName: "blackDice.png"), for: .normal)
            self.creatBitKey()
        }
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
                            
                            var array = [Any]()
                            
                            array = diceKey(viewController: self, userRandomness: self.parseBitResult)
                            
                            if array[1] as! Bool {
                            
                                self.words = array[0] as! String
                                self.button.removeFromSuperview()
                                self.diceMode = true
                                self.showRecoveryPhraseAndQRCode()
                                
                            } else {
                                
                                displayAlert(viewController: self, title: "Error", message: "We apologize, that really shouldn't have happened... Please email us at BitSenseApp@gmail.com and let us know what happened so we can fix it.")
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        self.randomBits.removeAll()
        
    }
    
    @objc func tapDice(sender: UIButton!) {
        
        let diceNumber = Int((sender.titleLabel?.text)!)!
        sender.titleLabel?.textColor = UIColor.clear
        sender.titleLabel?.backgroundColor = UIColor.clear
        
        func addDiceValue() {
            
            switch diceNumber {
                
            case 0:
                DispatchQueue.main.async {
                    sender.setTitle("1", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "dice1.png"), for: .normal)
                }
            case 1:
                DispatchQueue.main.async {
                    sender.setTitle("2", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "dice2.png"), for: .normal)
                }
            case 2:
                DispatchQueue.main.async {
                    sender.setTitle("3", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "dice3.png"), for: .normal)
                }
            case 3:
                DispatchQueue.main.async {
                    sender.setTitle("4", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "dice4.png"), for: .normal)
                }
            case 4:
                DispatchQueue.main.async {
                    sender.setTitle("5", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "dice5.png"), for: .normal)
                }
            case 5:
                DispatchQueue.main.async {
                    sender.setTitle("6", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "dice6.png"), for: .normal)
                }
            case 6:
                DispatchQueue.main.async {
                    sender.setTitle("1", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "dice1.png"), for: .normal)
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
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Ok, got it", comment: ""), style: .default, handler: { (action) in }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Why?", comment: ""), style: .default, handler: { (action) in
                        
                        displayAlert(viewController: self, title: "", message: "We make it impossible for you to input the dice values out of order becasue we don't want you to accidentally create a Private Key that is not based on true cryptographic secure randomness. We also do this to make it impossible for you to accidentally tap and change a value of a dice you have already input. Secure keys ARE WORTH the effort!")
                        
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
        let screenWidth = self.view.frame.width
        let width = Int(screenWidth / 6)
        let height = width
        let xSpacing = width / 6
        xvalue = xSpacing
        var yvalue = 80
        var zero = 0
        self.view.addSubview(self.scrollView)
        view.addSubview(percentageLabel)
        
        DispatchQueue.main.async {
            displayAlert(viewController: self, title: "FYI", message: "The purpose of creating a seed with dice is for long term secure storage.\nWhen you have input enough dice rolls (around 140) we will give you the seed you created (the recovery phrase) and we will encrypt and save your XPUB onto BitSense so that you can create infinite addresses for that seed with BitSense. It will be a \"watch only\" wallet. If you want this to be a hot wallet you will need to manually import your recovery phrase in hot mode.")
        }
        
        for _ in 0..<40 {
            for _ in 0..<5 {
                zero = zero + 1
                self.diceButton = UIButton(frame: CGRect(x: xvalue, y: yvalue, width: width, height: height))
                self.diceButton.setImage(#imageLiteral(resourceName: "blackDice.png"), for: .normal)
                self.diceButton.tag = zero
                self.diceButton.showsTouchWhenHighlighted = true
                self.diceButton.backgroundColor = .clear
                self.diceButton.setTitle("\(0)", for: .normal)
                self.diceButton.addTarget(self, action: #selector(self.tapDice), for: .touchUpInside)
                self.diceArray.append(self.diceButton)
                self.scrollView.addSubview(self.diceButton)
                xvalue = xvalue + width + xSpacing
            }
            xvalue = xSpacing
            yvalue = yvalue + 90
        }
        
    }
    
}



