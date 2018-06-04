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

    override func viewDidLoad() {
        super.viewDidLoad()

        print("SweepViewController")
        privateKeyImportText.delegate = self
        checkUserDefaults()
        addScanner()
        addBackButton()
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
        
        if self.testnetMode {
            print("testnetMode")
            
            if let privateKey = BTCPrivateKeyAddressTestnet(string: stringURL) {
                
                if let key = BTCKey.init(privateKeyAddress: privateKey) {
                    
                    print("privateKey = \(key.privateKeyAddressTestnet)")
                    privateKeyImportText.removeFromSuperview()
                    self.removeScanner()
                    
                    DispatchQueue.main.async {
                        
                        let alert = UIAlertController(title: "Alert!", message: "This will overwrite your existing Private Key and Bitcoin Address and you will lose your Bitcoin if you have not backed them up, are you sure you want to proceed?\n\nThis is the new private key: \(self.stringURL)", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes, import this wallet", comment: ""), style: .destructive, handler: { (action) in
                            
                            UserDefaults.standard.set(self.stringURL, forKey: "wif")
                            self.dismiss(animated: true, completion: nil)
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                            
                            self.addScanner()
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                    
                }
            }
            
            
        } else if self.mainnetMode {
            print("mainnetMode")
            
            if let privateKey = BTCPrivateKeyAddress(string: stringURL) {
                
                if let key = BTCKey.init(privateKeyAddress: privateKey) {
                    
                    print("privateKey = \(key.privateKeyAddress)")
                    privateKeyImportText.removeFromSuperview()
                    self.removeScanner()
                    
                    DispatchQueue.main.async {
                        
                        let alert = UIAlertController(title: "Alert!", message: "This will overwrite your existing Private Key and Bitcoin Address and you will lose your Bitcoin if you have not backed them up, are you sure you want to proceed?\n\nThis is the new private key: \(self.stringURL)", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes, import this wallet", comment: ""), style: .destructive, handler: { (action) in
                            
                            UserDefaults.standard.set(self.stringURL, forKey: "wif")
                            self.dismiss(animated: true, completion: nil)
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                            
                            self.addScanner()
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
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
    
    func checkUserDefaults() {
        
        print("checkUserDefaults")
        
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
                
                if self.testnetMode {
                    print("testnetMode")
                    
                    if let privateKey = BTCPrivateKeyAddressTestnet(string: stringURL) {
                        
                        if let key = BTCKey.init(privateKeyAddress: privateKey) {
                            
                            print("privateKey = \(key.privateKeyAddressTestnet)")
                            privateKeyImportText.removeFromSuperview()
                            self.removeScanner()
                            
                            DispatchQueue.main.async {
                                
                                let alert = UIAlertController(title: "Alert!", message: "This will overwrite your existing Private Key and Bitcoin Address and you will lose your Bitcoin if you have not backed them up, are you sure you want to proceed?\n\nThis is the new private key: \(self.stringURL)", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes, import this wallet", comment: ""), style: .destructive, handler: { (action) in
                                    
                                    UserDefaults.standard.set(self.stringURL, forKey: "wif")
                                    self.dismiss(animated: true, completion: nil)
                                    
                                }))
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                                    
                                    self.addScanner()
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }

                            
                        }
                    }
                    
                    
                } else if self.mainnetMode {
                    print("mainnetMode")
                    
                    if let privateKey = BTCPrivateKeyAddress(string: stringURL) {
                        
                        if let key = BTCKey.init(privateKeyAddress: privateKey) {
                            
                            print("privateKey = \(key.privateKeyAddress)")
                            privateKeyImportText.removeFromSuperview()
                            self.removeScanner()
                            
                            DispatchQueue.main.async {
                                
                                let alert = UIAlertController(title: "Alert!", message: "This will overwrite your existing Private Key and Bitcoin Address and you will lose your Bitcoin if you have not backed them up, are you sure you want to proceed?\n\nThis is the new private key: \(self.stringURL)", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes, import this wallet", comment: ""), style: .destructive, handler: { (action) in
                                    
                                    UserDefaults.standard.set(self.stringURL, forKey: "wif")
                                    self.dismiss(animated: true, completion: nil)
                                    
                                }))
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                                    
                                    self.addScanner()
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func addBackButton() {
        
        DispatchQueue.main.async {
            self.backButton = UIButton(frame: CGRect(x: 5, y: 20, width: 90, height: 55))
            self.backButton.showsTouchWhenHighlighted = true
            self.backButton.layer.cornerRadius = 10
            self.backButton.backgroundColor = UIColor.lightText
            self.backButton.layer.shadowColor = UIColor.black.cgColor
            self.backButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.backButton.layer.shadowRadius = 2.5
            self.backButton.layer.shadowOpacity = 0.8
            self.backButton.setTitle("Back", for: .normal)
            self.backButton.addTarget(self, action: #selector(self.home), for: .touchUpInside)
            self.view.addSubview(self.backButton)
        }
    }
    
    @objc func home() {
        
        self.dismiss(animated: false, completion: nil)
        
    }

}
