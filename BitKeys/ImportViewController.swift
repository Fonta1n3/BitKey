//
//  ImportViewController.swift
//  BitKeys
//
//  Created by Peter on 7/21/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import AVFoundation

class ImportViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let importView = UIView()
    let backButton = UIButton()
    let textInput = UITextField()
    let qrImageView = UIImageView()
    let uploadButton = UIButton()
    let imageImportView = UIImageView()
    let avCaptureSession = AVCaptureSession()
    let imagePicker = UIImagePickerController()
    var stringURL = String()
    var segwitMode = Bool()
    var legacyMode = Bool()
    let segwit = SegwitAddrCoder()
    var addressBook = [[String: Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        textInput.delegate = self
        importWallet()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addressBook = checkAddressBook()
        legacyMode = checkSettingsForKey(keyValue: "legacyMode")
        segwitMode = checkSettingsForKey(keyValue: "segwitMode")
    }

   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "createNewWallet") {
            
            if let vc = segue.destination as? ViewController {
                
                vc.createAccount = true
                
            }
        }
    }
    
    func importWallet() {
        
        print("importWallet")
        importView.frame = view.frame
        importView.backgroundColor = UIColor(hex: "49E900")
        
        imageImportView.image = UIImage(named:"background.jpg")
        imageImportView.frame = self.view.frame
        imageImportView.contentMode = UIViewContentMode.scaleAspectFill
        imageImportView.alpha = 0.05
        
        self.backButton.frame = CGRect(x: 5, y: 20, width: 55, height: 55)
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
        
        self.uploadButton.frame = CGRect(x: self.view.frame.maxX - 140, y: self.view.frame.maxY - 60, width: 130, height: 55)
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
        
        self.performSegue(withIdentifier: "createNewWallet", sender: self)
        
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
                processKeys(key: stringURL)
                self.avCaptureSession.stopRunning()
                self.avCaptureSession.startRunning()
                
            }
        }
    }
    
    func processKeys(key: String) {
        
        var success = Bool()
        
        func processPrivateKey(privateKey: String) {
            
            if privateKey.hasPrefix("9") || privateKey.hasPrefix("c") {
                
                if let privateKey = BTCPrivateKeyAddressTestnet(string: privateKey) {
                    
                    if let key = BTCKey.init(privateKeyAddress: privateKey) {
                        
                        var bitcoinAddress = String()
                        let privateKeyWIF = key.privateKeyAddressTestnet.string
                        let addressHD = key.addressTestnet.string
                        let publicKey = key.compressedPublicKey.hex()!
                        
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
                            
                            success = saveWallet(viewController: self, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "testnet", type: "hot", index: UInt32(), label: "", xpriv: "")
                            
                            if success {
                                
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
                            
                            success = saveWallet(viewController: self, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot", index: UInt32(), label: "", xpriv: "")
                            
                            if success {
                                
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
            
            success = saveWallet(viewController: self, mnemonic: "", xpub: "", address: key, privateKey: "", publicKey: "", redemptionScript: "", network: "mainnet", type: "cold", index: UInt32(), label: "", xpriv: "")
            
            if success {
                
                displayAlert(viewController: self, title: "Success", message: "You imported a wallet, you can rename it by swiping it left and tapping edit.")
                
            } else {
                displayAlert(viewController: self, title: "Error", message: "There was a problem importing your key, please contact us at BitSenseApp@gmail.com")
            }
            
        } else if key.hasPrefix("m") || key.hasPrefix("tb") || key.hasPrefix("2") {
            
            success = saveWallet(viewController: self, mnemonic: "", xpub: "", address: key, privateKey: "", publicKey: "", redemptionScript: "", network: "testnet", type: "cold", index: UInt32(), label: "", xpriv: "")
            if success {
                
                displayAlert(viewController: self, title: "Success", message: "You imported a wallet, you can rename it by swiping it left and tapping edit.")
                
            } else {
                displayAlert(viewController: self, title: "Error", message: "There was a problem importing your key, please contact us at BitSenseApp@gmail.com")
            }
            
        } else if key.hasPrefix("xpub") {
            
            if let keychain = BTCKeychain.init(extendedKey: key) {
                
                let addressHD = (keychain.key(at: 0).address.string)
                keychain.key.isPublicKeyCompressed = true
                let publicKey = (keychain.key(at: 0).compressedPublicKey.hex())!
                
                success = saveWallet(viewController: self, mnemonic: "", xpub: key, address: addressHD, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "cold", index: UInt32(), label: "", xpriv: "")
                if success {
                    
                    displayAlert(viewController: self, title: "Success", message: "You imported a wallet, you can rename it by swiping it left and tapping edit.")
                    
                } else {
                    displayAlert(viewController: self, title: "Error", message: "There was a problem importing your key, please contact us at BitSenseApp@gmail.com")
                }
            } else {
                displayAlert(viewController: self, title: "Error", message: "We had an issue with your xpub, please contact us at BitSenseApp@gmail.com")
            }
            
        } else if key.hasPrefix("xprv") {
            
            if let keychain = BTCKeychain.init(extendedKey: key) {
                
                let addressHD = (keychain.key(at: 0).address.string)
                let pkHD = (keychain.key(at: 0).privateKeyAddress.string)
                let xpub = keychain.extendedPublicKey!
                keychain.key.isPublicKeyCompressed = true
                let publicKey = (keychain.key(at: 0).compressedPublicKey.hex())!
                
                success = saveWallet(viewController: self, mnemonic: "", xpub: xpub, address: addressHD, privateKey: pkHD, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot", index: UInt32(), label: "", xpriv: key)
                
                if success {
                    
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
            self.dismiss(animated: true, completion: nil)
        }
   }
    
}
