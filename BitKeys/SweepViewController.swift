//
//  SweepViewController.swift
//  BitKeys
//
//  Created by Peter on 6/5/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import AVFoundation

class SweepViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate {
    
    var backButton = UIButton()
    var testnetMode = Bool()
    var mainnetMode = Bool()
    var imageView:UIView!
    let avCaptureSession = AVCaptureSession()
    var videoPreview = UIView()
    var privateKeyImportText = UITextField()
    var stringURL = String()
    var addressBook: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        print("SweepViewController")
        privateKeyImportText.delegate = self
        getUserDefaults()
        addScanner()
        addBackButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
       getUserDefaults()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addScanner() {
        print("addScanner")
        
        DispatchQueue.main.async {
            self.addQRScannerView()
            self.addTextInput()
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
        
        self.videoPreview.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.view.center.y - ((self.view.frame.width - 50)/2), width: self.view.frame.width - 50, height: self.view.frame.width - 50)
        self.view.addSubview(self.videoPreview)
    }
    
    func addTextInput() {
        print("addTextInput")
        
        self.privateKeyImportText.frame = CGRect(x: self.view.frame.minX + 5, y: self.videoPreview.frame.minY - 55, width: self.view.frame.width - 10, height: 50)
        self.privateKeyImportText.textAlignment = .center
        self.privateKeyImportText.borderStyle = .roundedRect
        self.privateKeyImportText.autocorrectionType = .no
        self.privateKeyImportText.autocapitalizationType = .none
        self.privateKeyImportText.backgroundColor = UIColor.groupTableViewBackground
        self.privateKeyImportText.returnKeyType = UIReturnKeyType.go
        self.privateKeyImportText.placeholder = "Scan or Type Private Key"
        self.view.addSubview(self.privateKeyImportText)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        self.view.endEditing(true)
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing")
        privateKeyImportText.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        
        stringURL = privateKeyImportText.text!
        
        if stringURL.hasPrefix("9") || stringURL.hasPrefix("c") {
            print("testnetMode")
            
            if let privateKey = BTCPrivateKeyAddressTestnet(string: stringURL) {
                
                if let key = BTCKey.init(privateKeyAddress: privateKey) {
                    
                    print("privateKey = \(key.privateKeyAddressTestnet)")
                    privateKeyImportText.removeFromSuperview()
                    self.removeScanner()
                    
                    var privateKeyHD = String()
                    var addressHD = String()
                    
                    privateKeyHD = key.privateKeyAddressTestnet.description
                    addressHD = key.addressTestnet.description
                    
                    let privateKey3 = privateKeyHD.components(separatedBy: " ")
                    let privateKeyWIF = privateKey3[1].replacingOccurrences(of: ">", with: "")
                    
                    let publicKey = key.compressedPublicKey.hex()!
                    print("publicKey = \(publicKey)")
                    
                    let legacyAddress2 = (addressHD.description).components(separatedBy: " ")
                    let bitcoinAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                    
                    saveWallet(viewController: self, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "testnet", type: "hot")
                        
                }
                
            }
            
        } else if stringURL.hasPrefix("5") || stringURL.hasPrefix("K") || stringURL.hasPrefix("L") {
            print("mainnetMode")
            
            if let privateKey = BTCPrivateKeyAddress(string: stringURL) {
                
                if let key = BTCKey.init(privateKeyAddress: privateKey) {
                    
                    privateKeyImportText.removeFromSuperview()
                    self.removeScanner()
                    
                    var privateKeyHD = String()
                    var addressHD = String()
                    
                    privateKeyHD = key.privateKeyAddress.description
                    addressHD = key.address.description
                    
                    let privateKey3 = privateKeyHD.components(separatedBy: " ")
                    let privateKeyWIF = privateKey3[1].replacingOccurrences(of: ">", with: "")
                    
                    let publicKey = key.compressedPublicKey.hex()!
                    print("publicKey = \(publicKey)")
                    
                    let legacyAddress2 = (addressHD.description).components(separatedBy: " ")
                    let bitcoinAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                    
                    saveWallet(viewController: self, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot")
                    
                }
                
            }
            
        }

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
    
    func getUserDefaults() {
        
        print("checkUserDefaults")
        
        if UserDefaults.standard.object(forKey: "addressBook") != nil {
            
            addressBook = UserDefaults.standard.object(forKey: "addressBook") as! [[String: Any]]
            
        }
        
        testnetMode = UserDefaults.standard.object(forKey: "testnetMode") as! Bool
        mainnetMode = UserDefaults.standard.object(forKey: "mainnetMode") as! Bool
        
    }
    

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count > 0 {
            print("metadataOutput")
            
            let machineReadableCode = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if machineReadableCode.type == AVMetadataObject.ObjectType.qr {
                
                stringURL = machineReadableCode.stringValue!
                
                print("stringURL = \(stringURL)")
                
                if stringURL.hasPrefix("9") || stringURL.hasPrefix("c") {
                    print("testnetMode")
                    
                    if let privateKey = BTCPrivateKeyAddressTestnet(string: stringURL) {
                        
                        if let key = BTCKey.init(privateKeyAddress: privateKey) {
                            
                            print("privateKey = \(key.privateKeyAddressTestnet)")
                            privateKeyImportText.removeFromSuperview()
                            self.removeScanner()
                            
                            var privateKeyHD = String()
                            var addressHD = String()
                            
                            privateKeyHD = key.privateKeyAddressTestnet.description
                            addressHD = key.addressTestnet.description
                            
                            let privateKey3 = privateKeyHD.components(separatedBy: " ")
                            let privateKeyWIF = privateKey3[1].replacingOccurrences(of: ">", with: "")
                            
                            
                            let publicKey = key.compressedPublicKey.hex()!
                            print("publicKey = \(publicKey)")
                            
                            let legacyAddress2 = (addressHD.description).components(separatedBy: " ")
                            let bitcoinAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                            
                            saveWallet(viewController: self, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "testnet", type: "hot")
                            
                        }
                    }
                    
                    
                } else if stringURL.hasPrefix("5") || stringURL.hasPrefix("K") || stringURL.hasPrefix("L") {
                    print("mainnetMode")
                    
                    if let privateKey = BTCPrivateKeyAddress(string: stringURL) {
                        
                        if let key = BTCKey.init(privateKeyAddress: privateKey) {
                            
                            print("privateKey = \(key.privateKeyAddress)")
                            privateKeyImportText.removeFromSuperview()
                            self.removeScanner()
                            
                            var privateKeyHD = String()
                            var addressHD = String()
                            
                            privateKeyHD = key.privateKeyAddress.description
                            addressHD = key.address.description
                            
                            let privateKey3 = privateKeyHD.components(separatedBy: " ")
                            let privateKeyWIF = privateKey3[1].replacingOccurrences(of: ">", with: "")
                            
                            let publicKey = key.compressedPublicKey.hex()!
                            print("publicKey = \(publicKey)")
                            
                            let legacyAddress2 = (addressHD.description).components(separatedBy: " ")
                            let bitcoinAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                            
                            saveWallet(viewController: self, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot")
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
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
        
        self.dismiss(animated: true, completion: nil)
        
    }

}
