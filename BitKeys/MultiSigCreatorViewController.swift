//
//  MultiSigCreatorViewController.swift
//  BitKeys
//
//  Created by Peter on 6/7/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import AVFoundation

class MultiSigCreatorViewController: UIViewController, UITextFieldDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    var testnetMode = Bool()
    var mainnetMode = Bool()
    
    var toggleButton = UIButton()
    var backUpButton = UIButton()
    var backButton = UIButton()
    var textFieldInput = UITextField()
    var numberOfPrivateKeys = Int()
    var numberOfSignatures = Int()
    var getNumberOfPrivateKeysMode = Bool()
    var getNumberOfSignaturesMode = Bool()
    var getPrivateKeysMode = Bool()
    
    let avCaptureSession = AVCaptureSession()
    var videoPreview = UIView()
    var privateKeyImportText = UITextField()
    var stringURL = String()
    var privateKeyArray = [String]()
    
    var QRCode:UIImage!
    var QRCodeImage:UIImage!
    var QRCodeImageView:UIImageView!
    var addressFieldLabel = UILabel()
    var titleLabel = UILabel()
    var textView: UITextView!
    
    var multiSigAddress = String()
    var redemptionScript = String()
    
    var addressMode = Bool()
    var redemptionMode = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("MultiSigCreatorViewController")
        
        textFieldInput.delegate = self
        getNumberOfPrivateKeysMode = true
        addBackButton()
        addTextInput()
        textFieldInput.becomeFirstResponder()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        getUserDefaults()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    
    func getUserDefaults() {
        
        print("checkUserDefaults")
        
        testnetMode = UserDefaults.standard.object(forKey: "testnetMode") as! Bool
        mainnetMode = UserDefaults.standard.object(forKey: "mainnetMode") as! Bool
        
    }
    
    func addBackButton() {
        
        DispatchQueue.main.async {
            
            self.backButton = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
            self.backButton.showsTouchWhenHighlighted = true
            self.backButton.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
            self.backButton.addTarget(self, action: #selector(self.home), for: .touchUpInside)
            self.view.addSubview(self.backButton)
            
        }
        
    }
    
    @objc func home() {
        
        self.dismiss(animated: false, completion: nil)
        
    }
    
    func addTextInput() {
        
        print("addTextInput")
        
        textFieldInput.frame = CGRect(x: self.view.frame.minX + 25, y: 150, width: self.view.frame.width - 50, height: 50)
        textFieldInput.textAlignment = .center
        textFieldInput.borderStyle = .roundedRect
        textFieldInput.backgroundColor = UIColor.groupTableViewBackground
        textFieldInput.adjustsFontSizeToFitWidth = true
        
        
        if getNumberOfPrivateKeysMode {
         
            textFieldInput.placeholder = "How many Private/Public Keys?"
            textFieldInput.keyboardType = UIKeyboardType.decimalPad
            
            
        } else if getPrivateKeysMode {
            
            textFieldInput.placeholder = "Scan or type each Private/Public Key"
            textFieldInput.keyboardType = UIKeyboardType.default
            
        }
        
        textFieldInput.addNextButtonToKeyboard(myAction:  #selector(self.nextButton))
        self.view.addSubview(self.textFieldInput)
        
     }
    
    @objc func nextButton() {
        
        print("nextButton")
        
        if getNumberOfPrivateKeysMode {
            
            nextButtonInGetNumberOfKeysMode()
            
        }
        
        if getNumberOfSignaturesMode {
            
            nextButtonInGetNumberOfSignatureMode()
            
        }
        
        if getPrivateKeysMode {
            
            print("getPrivateKeysMode")
            getRequiredPrivateKeys()
            
        }
        
    }
    
    func nextButtonInGetNumberOfKeysMode() {
        
        print("nextButtonInGetNumberOfKeysMode")
        
        print("number of keys = \(String(describing: self.textFieldInput.text))")
        
        if self.textFieldInput.text != "" {
            
            if (Int(self.textFieldInput.text!)! > 1) {
               
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: NSLocalizedString("Please Confirm:", comment: ""), message: "You would like to create a Multi-Sig wallet which consists of \(self.textFieldInput.text!) Private Keys.", preferredStyle: UIAlertControllerStyle.actionSheet)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                        
                        self.numberOfPrivateKeys = Int(self.textFieldInput.text!)!
                        print("continue with \(self.numberOfPrivateKeys)")
                        self.getNumberOfPrivateKeysMode = false
                        self.getNumberOfSignaturesMode = true
                        self.textFieldInput.text = ""
                        self.textFieldInput.placeholder = "How many signatures required?"
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { (action) in
                        
                        self.textFieldInput.text = ""
                        self.textFieldInput.placeholder = "How many private keys?"
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }))
                    
                    alert.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad
                    
                    self.present(alert, animated: true) {
                        print("option menu presented")
                    }
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    
                    displayAlert(viewController: self, title: "Error", message: "You need to input a number greater then 1.")
                    
                }
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                displayAlert(viewController: self, title: "Error", message: "You need to input a number greater then 1.")
                
            }
            
        }
        
    }
    
    func nextButtonInGetNumberOfSignatureMode() {
        
        print("nextButtonInGetNumberOfSignatureMode")
        
        print("number of keys = \(String(describing: self.textFieldInput.text))")
        
        if self.textFieldInput.text != "" {
            
            if Int(self.textFieldInput.text!)! <= self.numberOfPrivateKeys && Int(self.textFieldInput.text!)! > 0 {
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: NSLocalizedString("Please Confirm:", comment: ""), message: "You would like to create a Multi-Sig wallet which consists of \(self.numberOfPrivateKeys) Private Keys which requires \(String(describing: self.textFieldInput.text!)) signatures to spend Bitcoin.", preferredStyle: UIAlertControllerStyle.actionSheet)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                        
                        self.numberOfSignatures = Int(self.textFieldInput.text!)!
                        print("continue with \(self.numberOfSignatures)")
                        self.getNumberOfPrivateKeysMode = false
                        self.getNumberOfSignaturesMode = false
                        self.getPrivateKeysMode = true
                        self.textFieldInput.text = ""
                        self.textFieldInput.resignFirstResponder()
                        self.textFieldInput.removeFromSuperview()
                        self.addPrivateKeyInput()
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { (action) in
                        
                        self.textFieldInput.text = ""
                        self.textFieldInput.placeholder = "How many signatures required?"
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }))
                    
                    alert.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad
                    
                    self.present(alert, animated: true) {
                        print("option menu presented")
                    }
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    
                    displayAlert(viewController: self, title: "Error", message: "Number of Signatures required can not be greater then the number of Private Keys and must be greater then 0.")
                    
                }
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                displayAlert(viewController: self, title: "Error", message: "You need to input a number greater then 1.")
                
            }
            
        }
        
    }
    
    func addPrivateKeyInput() {
        
        print("addPrivateKeyInput")
        
        self.addTextInput()
        self.addScanner()
        
    }
    
    func getRequiredPrivateKeys() {
        
        if privateKeyArray.count < self.numberOfPrivateKeys {
            
            if self.testnetMode {
                
                if let privateKey = BTCPrivateKeyAddressTestnet(string: self.textFieldInput.text) {
                    
                    privateKeyArray.append(self.textFieldInput.text!)
                    print("privateKeyArray = \(privateKeyArray)")
                    self.textFieldInput.text = ""
                    
                    if privateKeyArray.count == self.numberOfPrivateKeys {
                        
                        print("create the wallet")
                        
                        var publickKeyArray = [Any]()
                        
                        for wif in self.privateKeyArray {
                            
                            print("wif = \(wif)")
                            
                            if let key = BTCKey.init(wif: wif) {
                                
                                print("btckey = \(wif)")
                                
                                key.isPublicKeyCompressed = true
                                
                                if let pubKey = key.publicKey {
                                    
                                    publickKeyArray.append(pubKey)
                                    
                                    if publickKeyArray.count == privateKeyArray.count {
                                        
                                        if let multiSigWallet = BTCScript.init(publicKeys: publickKeyArray, signaturesRequired: UInt(self.numberOfSignatures)) {
                                            
                                            self.multiSigAddress = multiSigWallet.scriptHashAddressTestnet.string
                                            print("multiSigAddress = \(multiSigAddress)")
                                            
                                            self.redemptionScript = multiSigWallet.hex!
                                            print("redemptionScript = \(redemptionScript)")
                                            self.removeScanner()
                                            self.textFieldInput.removeFromSuperview()
                                            self.showAddressQRCode()
                                            self.addressMode = true
                                            self.redemptionMode = false
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            } else {
                                
                                print("error with \(wif)")
                                
                            }
                            
                        }
                        
                    }
                    
                } else {
                    
                    //try it as a publickey
                    privateKeyArray.append(self.textFieldInput.text!)
                    print("privateKeyArray = \(privateKeyArray)")
                    self.textFieldInput.text = ""
                    
                    if privateKeyArray.count == self.numberOfPrivateKeys {
                        
                        var publickKeyArray = [Any]()
                        
                        for pubKey in self.privateKeyArray {
                        
                            publickKeyArray.append(pubKey)
                        
                            if publickKeyArray.count == privateKeyArray.count {
                            
                                if let multiSigWallet = BTCScript.init(publicKeys: publickKeyArray, signaturesRequired: UInt(self.numberOfSignatures)) {
                                
                                    self.multiSigAddress = multiSigWallet.scriptHashAddressTestnet.string
                                    print("multiSigAddress = \(multiSigAddress)")
                                
                                    self.redemptionScript = multiSigWallet.hex!
                                    print("redemptionScript = \(redemptionScript)")
                                    self.removeScanner()
                                    self.textFieldInput.removeFromSuperview()
                                    self.showAddressQRCode()
                                    self.addressMode = true
                                    self.redemptionMode = false
                                
                                }
                            
                            }
                            
                        }
                        
                    }
                
                }
                
            } else if self.mainnetMode {
                
                if let privateKey = BTCPrivateKeyAddress(string: self.textFieldInput.text) {
                    
                    privateKeyArray.append(self.textFieldInput.text!)
                    print("privateKeyArray = \(privateKeyArray)")
                    self.textFieldInput.text = ""
                    
                    if privateKeyArray.count == self.numberOfPrivateKeys {
                        
                        print("create the wallet")
                        
                        var publickKeyArray = [Any]()
                        
                        for wif in self.privateKeyArray {
                            
                            print("wif = \(wif)")
                            
                            if let key = BTCKey.init(wif: wif) {
                                
                                print("btckey = \(wif)")
                                
                                key.isPublicKeyCompressed = true
                                
                                if let pubKey = key.publicKey {
                                    
                                    publickKeyArray.append(pubKey)
                                    
                                    if publickKeyArray.count == privateKeyArray.count {
                                        
                                        if let multiSigWallet = BTCScript.init(publicKeys: publickKeyArray, signaturesRequired: UInt(self.numberOfSignatures)) {
                                            
                                            self.multiSigAddress = multiSigWallet.scriptHashAddress.string
                                            print("multiSigAddress = \(multiSigAddress)")
                                            self.redemptionScript = multiSigWallet.hex!
                                            print("redemptionScript = \(redemptionScript)")
                                            self.removeScanner()
                                            self.textFieldInput.removeFromSuperview()
                                            self.showAddressQRCode()
                                            self.addressMode = true
                                            self.redemptionMode = false
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            } else {
                                
                                print("error with \(wif)")
                                
                            }
                            
                        }
                        
                    }
                    
                } else {
                    
                    //try it as a publickey
                    privateKeyArray.append(self.textFieldInput.text!)
                    print("privateKeyArray = \(privateKeyArray)")
                    self.textFieldInput.text = ""
                    
                    if privateKeyArray.count == self.numberOfPrivateKeys {
                        
                        var publickKeyArray = [Any]()
                        
                        for pubKey in self.privateKeyArray {
                            
                            publickKeyArray.append(pubKey)
                            
                            if publickKeyArray.count == privateKeyArray.count {
                                
                                if let multiSigWallet = BTCScript.init(publicKeys: publickKeyArray, signaturesRequired: UInt(self.numberOfSignatures)) {
                                    
                                    self.multiSigAddress = multiSigWallet.scriptHashAddress.string
                                    print("multiSigAddress = \(multiSigAddress)")
                                    self.redemptionScript = multiSigWallet.hex!
                                    print("redemptionScript = \(redemptionScript)")
                                    self.removeScanner()
                                    self.textFieldInput.removeFromSuperview()
                                    self.showAddressQRCode()
                                    self.addressMode = true
                                    self.redemptionMode = false
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        print("textFieldShouldReturn")
        
        if textField == textFieldInput {
            
            if getNumberOfPrivateKeysMode {
                
              print("number of key = \(String(describing: textField.text))")
                
            }
            
            if getNumberOfSignaturesMode {
                
              print("number of signatures = \(String(describing: textField.text))")
                
            }
            
        }
        
        self.view.endEditing(true)
        return false
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print("textFieldDidEndEditing")
        
        if textField == textFieldInput {
            
            if getNumberOfPrivateKeysMode {
                
                print("textField text in getNumberOfPrivateKeysMode = \(String(describing: textField.text))")
                
            }
            
            if getNumberOfSignaturesMode {
                
                print("textField text in getNumberOfSignaturesMode = \(String(describing: textField.text))")
            }
            
        }
        
    }
    
    func addScanner() {
        print("addScanner")
        
        DispatchQueue.main.async {
            
            self.addTextInput()
            self.addQRScannerView()
            self.scanQRCode()
            
        }
        
    }
    
    func removeScanner() {
        print("removeScanner")
        
        DispatchQueue.main.async {
            
            self.privateKeyImportText.removeFromSuperview()
            self.avCaptureSession.stopRunning()
            self.videoPreview.removeFromSuperview()
            
        }
        
    }
    
    func addQRScannerView() {
        print("addQRScannerView")
        
        self.videoPreview.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.textFieldInput.frame.maxY + 10, width: self.view.frame.width - 50, height: self.view.frame.width - 50)
        self.videoPreview.layer.shadowColor = UIColor.black.cgColor
        self.videoPreview.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        self.videoPreview.layer.shadowRadius = 2.5
        self.videoPreview.layer.shadowOpacity = 0.8
        self.view.addSubview(self.videoPreview)
    }
    
    func scanQRCode() {
        
        do {
            
            try scanQRNow()
            print("scanQRNow")
            
        } catch {
            
            print("Failed to scan QR Code")
            
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
        self.avCaptureSession.addInput(avCaptureInput)
        self.avCaptureSession.addOutput(avCaptureMetadataOutput)
        avCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession)
        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avCaptureVideoPreviewLayer.frame = videoPreview.bounds
        self.videoPreview.layer.addSublayer(avCaptureVideoPreviewLayer)
        
        self.avCaptureSession.startRunning()
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count > 0 {
            print("metadataOutput")
            
            let machineReadableCode = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if machineReadableCode.type == AVMetadataObject.ObjectType.qr {
                
                stringURL = machineReadableCode.stringValue!
                
                print("stringURL = \(stringURL)")
                
                self.textFieldInput.text = stringURL
               
            }
            
        }
        
    }
    
    func showAddressQRCode() {
        print("addQRCodesAndLabels")
        
        self.QRCode = self.generateQrCode(key: self.multiSigAddress)
        self.QRCodeImageView = UIImageView(image: self.QRCode!)
        self.QRCodeImageView.frame = CGRect(x: self.view.frame.minX + 5, y: self.view.frame.minY + 130, width: self.view.frame.width - 10, height: self.view.frame.width - 10)
        self.QRCodeImageView.alpha = 0
        self.view.addSubview(self.QRCodeImageView)
        
        self.addressFieldLabel = UILabel(frame: CGRect(x: self.view.frame.minX + 5, y: self.view.frame.minY + 150 + (self.view.frame.width - 10) - 11, width: self.view.frame.width - 10, height: 13))
        self.addressFieldLabel.font = .systemFont(ofSize: 12)
        self.addressFieldLabel.textColor = UIColor.black
        self.addressFieldLabel.textAlignment = .left
        self.view.addSubview(self.addressFieldLabel)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            
            
        }, completion: { _ in
            
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.QRCodeImageView.alpha = 1
                
            }, completion: { _ in
                
                DispatchQueue.main.async {
                    
                    self.addressFieldLabel.text = "Text Format:"
                    self.titleLabel = UILabel(frame: CGRect(x: self.view.frame.minX, y: self.view.frame.minY + 70, width: self.view.frame.width, height: 50))
                    self.titleLabel.text = "Send Bitcoin To:"
                    self.titleLabel.font = .systemFont(ofSize: 32)
                    self.titleLabel.textColor = UIColor.black
                    self.titleLabel.textAlignment = .center
                    self.view.addSubview(self.titleLabel)
                    
                }
                
                self.textView = UITextView (frame:CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.QRCodeImageView.frame.maxY + 40, width: self.view.frame.width - 50, height: 100))
                self.textView.isEditable = false
                self.textView.isSelectable = true
                self.textView.font = .systemFont(ofSize: 24)
                self.textView.text = self.multiSigAddress
                self.view.addSubview(self.textView)
                self.addBackUpButton()
                self.addToggleButton()
                
            })
            
        })
        
    }
    
    func addToggleButton() {
        
        self.toggleButton.removeFromSuperview()
        self.toggleButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 155, y: 20, width: 150 , height: 55))
        self.toggleButton.showsTouchWhenHighlighted = true
        self.toggleButton.layer.cornerRadius = 10
        self.toggleButton.backgroundColor = UIColor.lightText
        self.toggleButton.layer.shadowColor = UIColor.black.cgColor
        self.toggleButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        self.toggleButton.layer.shadowRadius = 2.5
        self.toggleButton.layer.shadowOpacity = 0.8
        self.toggleButton.setTitle("Show Script", for: .normal)
        self.toggleButton.addTarget(self, action: #selector(self.toggle), for: .touchUpInside)
        self.view.addSubview(self.toggleButton)
        
    }
    
    @objc func toggle() {
        
        if addressMode {
            
            //show redemption
            DispatchQueue.main.async {
                
                self.QRCode = self.generateQrCode(key: self.redemptionScript)
                self.QRCodeImageView.image = self.QRCode
                self.textView.text = self.redemptionScript
                self.titleLabel.text = "Redemption Script:"
                self.toggleButton.setTitle("Show Address", for: .normal)
            }
            
            self.redemptionMode = true
            self.addressMode = false
            
        } else if redemptionMode {
            
            //show address
            DispatchQueue.main.async {
                
                self.QRCode = self.generateQrCode(key: self.multiSigAddress)
                self.QRCodeImageView.image = self.QRCode
                self.textView.text = self.multiSigAddress
                self.titleLabel.text = "Send Bitcoin To:"
                self.toggleButton.setTitle("Show Script", for: .normal)
                
            }
            
            self.redemptionMode = false
            self.addressMode = true
            
        }
        
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
    
    func generateQrCode(key: String) -> UIImage? {
        
        print("generateQrCode")
        
        let ciContext = CIContext()
        let data = key.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let upScaledImage = filter.outputImage?.transformed(by: transform)
            let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
            QRCodeImage = UIImage(cgImage: cgImage!)
            return QRCodeImage
            
        }
        
        return nil
        
    }
    
    @objc func airDropImage() {
        
        print("airDropImage")
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        if addressMode {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Address QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.QRCodeImage) {
                    
                    let fileName = getDocumentsDirectory().appendingPathComponent("multisigAddress.png")
                    
                    try? data.write(to: fileName)
                    
                    let objectsToShare = [fileName]
                    DispatchQueue.main.async {
                        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        self.present(activityController, animated: true, completion: nil)
                    }
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Address Text", comment: ""), style: .default, handler: { (action) in
                
                let activityViewController = UIActivityViewController(activityItems: [self.multiSigAddress], applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            alert.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad
            
            self.present(alert, animated: true) {
                print("option menu presented")
            }
            
        } else if redemptionMode {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Redemption Script QR Code", comment: ""), style: .default, handler: { (action) in
                
                if let data = UIImagePNGRepresentation(self.QRCodeImage) {
                    
                    let fileName = getDocumentsDirectory().appendingPathComponent("redemptionScript.png")
                    
                    try? data.write(to: fileName)
                    
                    let objectsToShare = [fileName]
                    DispatchQueue.main.async {
                        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        self.present(activityController, animated: true, completion: nil)
                    }
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Redemption Script Text", comment: ""), style: .default, handler: { (action) in
                
                let activityViewController = UIActivityViewController(activityItems: [self.redemptionScript], applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            alert.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad
            
            self.present(alert, animated: true) {
                print("option menu presented")
            }
        }
        
        
        
    }
    
}


