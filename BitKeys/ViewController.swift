//
//  ViewController.swift
//  BitKeys
//
//  Created by Peter on 11/27/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit
import Security

class ViewController: UIViewController {
    
    @IBOutlet var upperLabel: UILabel!
    var privateKeyQRCode:UIImage!
    var privateKeyQRView:UIImageView!
    var privateKeyImage:UIImage!
    var imageView:UIView!
    var numberArray:[String] = []
    var joinedArray:String!
    var bitField:UITextView!
    var myField: UITextView!
    var button = UIButton(type: .custom)
    var bitcoinAddressButton = UIButton(type: .custom)
    var backUpButton = UIButton(type: .custom)
    var privateKeyText:String!
    var bitcoinAddress:String!
    var privateKeyMode:Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        privateKeyMode = true
        showBitcoin()
        
    }
    
    func showBitcoin() {
        
        bitField = UITextView (frame:CGRect(x: view.center.x - (self.view.frame.width / 2), y: view.center.y - (self.view.frame.height / 2), width: self.view.frame.width, height: self.view.frame.height))
        bitField.isUserInteractionEnabled = false
        bitField.font = .systemFont(ofSize: 24)
        self.view.addSubview(bitField)
        
        let bitcoinImage = UIImage(named: "bitcoinIcon.png")
        imageView = UIImageView(image: bitcoinImage!)
        imageView.center = view.center
        imageView.frame = CGRect(x: view.center.x - 100, y: view.center.y - 100, width: 200, height: 200)
        
        let bitcoinDragged = UIPanGestureRecognizer(target: self, action: #selector(self.bitcoinWasDragged(gestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(bitcoinDragged)
        view.addSubview(imageView)
        print("test")
        
    }
    
    func createPrivateKey(randomness: String) -> (privateKeyAddress: String, publicKeyAddress: String) {
        
        let bytesCount = 32 // number of bytes
        var randomNum = "" // hexadecimal version of randomBytes
        var randomBytes = [UInt8](repeating: 0, count: bytesCount) // array to hold randoms bytes
        SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)
        randomNum = randomBytes.map({String(format: "%02hhx", $0)}).joined(separator: "")
        var privateKey:String!
        
        if let newData = randomNum.data(using: String.Encoding.utf8){
            
            let keyPair = BTCKey.init()
            
            let  privateKey2 = keyPair?.privateKeyAddress!.description
            var privateKey3 = privateKey2?.components(separatedBy: " ")
            privateKey = privateKey3![1].replacingOccurrences(of: ">", with: "")
            print("privateKey = \(privateKey!)")
            
            let bitcoinAddress1 = keyPair?.compressedPublicKeyAddress.description
            var bitcoinAddress2 = bitcoinAddress1?.components(separatedBy: " ")
            bitcoinAddress = bitcoinAddress2![1].replacingOccurrences(of: ">", with: "")
            print("bitcoinAddress = \(bitcoinAddress)")
            
            return (privateKey, bitcoinAddress)
        }
        
        return ("", "")
    }
    
    @objc func bitcoinWasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        print("flightWasDragged")
        
        let translation = gestureRecognizer.translation(in: view)
        let bitcoinView = gestureRecognizer.view!
        bitcoinView.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        let xFromCenter = bitcoinView.center.x - self.view.bounds.width / 2
        
        numberArray.append(String(describing: abs(Int(xFromCenter))))
        
        let shuffledArray = self.numberArray.shuffled()
        let string = String(describing: shuffledArray)
        let stringFormat1 = string.replacingOccurrences(of: ", ", with: "")
        let stringFormat2 = stringFormat1.replacingOccurrences(of: "\"", with: "")
        let stringFormat3 = stringFormat2.replacingOccurrences(of: "[", with: "")
        let stringFormat4 = stringFormat3.replacingOccurrences(of: "]", with: "")
        bitField.text = stringFormat4
        
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            
            UIView.animate(withDuration: 0.5, animations: {
                
                bitcoinView.center =  self.view.center
                
            }, completion: { _ in
                
                let privateKey = self.createPrivateKey(randomness: stringFormat4).privateKeyAddress
                
                if privateKey != "" {
                  
                    self.privateKeyText = privateKey
                    self.privateKeyQRCode = self.generateQrCode(key: privateKey)
                    self.privateKeyQRView = UIImageView(image: self.privateKeyQRCode!)
                    self.privateKeyQRView.center = self.view.center
                    self.privateKeyQRView.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.view.center.y - ((self.view.frame.width - 50)/2), width: self.view.frame.width - 50, height: self.view.frame.width - 50)
                    self.privateKeyQRView.alpha = 0
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        self.imageView.alpha = 0
                        self.bitField.alpha = 0
                        
                    }, completion: { _ in
                        
                        self.imageView.removeFromSuperview()
                        self.bitField.removeFromSuperview()
                        self.view.addSubview(self.privateKeyQRView)
                        
                        UIView.animate(withDuration: 0.5, animations: {
                            
                            self.privateKeyQRView.alpha = 1
                            
                        }, completion: { _ in
                            
                            self.upperLabel.text = "Bitcoin Private Key"
                            self.myField = UITextView (frame:CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.view.center.y + ((self.view.frame.width - 50)/2), width: self.view.frame.width - 50, height: 100))
                            self.myField.text = privateKey
                            self.myField.isEditable = false
                            self.myField.isSelectable = true
                            self.myField.font = .systemFont(ofSize: 24)
                            self.view.addSubview(self.myField)
                            self.addHomeButton()
                            self.addBackUpButton()
                            
                        })
                        
                    })
                    
                } else {
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "There was an error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .destructive, handler: { (action) in
                            
                            self.privateKeyQRCode = nil
                            self.privateKeyImage = nil
                            self.privateKeyQRView.image = nil
                            self.upperLabel.text = ""
                            self.myField.text = ""
                            self.imageView.removeFromSuperview()
                            self.imageView = nil
                            self.button.removeFromSuperview()
                            self.backUpButton.removeFromSuperview()
                            self.numberArray.removeAll()
                            self.joinedArray = ""
                            self.privateKeyText = ""
                            self.showBitcoin()
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
                
            })
            
        }
        
    }
    
    func addHomeButton() {
        
        DispatchQueue.main.async {
            self.button = UIButton(frame: CGRect(x: 0, y: 0, width: 100 , height: 55))
            self.button.backgroundColor = .black
            self.button.setTitle("Back", for: .normal)
            self.button.addTarget(self, action: #selector(self.home), for: .touchUpInside)
            self.view.addSubview(self.button)
            
            self.bitcoinAddressButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 150, y: 0, width: 150 , height: 55))
            self.bitcoinAddressButton.backgroundColor = .black
            self.bitcoinAddressButton.setTitle("Show Address", for: .normal)
            self.bitcoinAddressButton.addTarget(self, action: #selector(self.getAddress), for: .touchUpInside)
            self.view.addSubview(self.bitcoinAddressButton)
        }
        
    }
    
    @objc func getAddress() {
        
        if privateKeyMode {
           
            DispatchQueue.main.async {
                
                self.upperLabel.text = "Bitcoin Address"
                self.myField.text = self.bitcoinAddress
                self.privateKeyQRCode = self.generateQrCode(key: self.bitcoinAddress)
                self.privateKeyQRView.image = self.privateKeyQRCode!
                self.bitcoinAddressButton.setTitle("Show Private Key", for: .normal)
                self.privateKeyMode = false
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                self.upperLabel.text = "Bitcoin Private Key"
                self.myField.text = self.privateKeyText
                self.privateKeyQRCode = self.generateQrCode(key: self.privateKeyText)
                self.privateKeyQRView.image = self.privateKeyQRCode!
                self.bitcoinAddressButton.setTitle("Show Address", for: .normal)
                self.privateKeyMode = true
                
            }
            
        }
        
    }
    
    @objc func home() {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Have you saved this Private Key?", message: "Ensure you have saved this before going back if you'd like to use this Private Key in the future.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("I saved it, go back", comment: ""), style: .destructive, handler: { (action) in
                
                self.privateKeyQRCode = nil
                self.privateKeyImage = nil
                self.privateKeyQRView.image = nil
                self.upperLabel.text = ""
                self.myField.text = ""
                self.imageView.removeFromSuperview()
                self.imageView = nil
                self.button.removeFromSuperview()
                self.backUpButton.removeFromSuperview()
                self.numberArray.removeAll()
                self.joinedArray = ""
                self.privateKeyText = ""
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
            self.backUpButton.backgroundColor = .black
            self.backUpButton.setTitle("Back Up / Share / Save / Copy", for: .normal)
            self.backUpButton.addTarget(self, action: #selector(self.airDropImage), for: .touchUpInside)
            self.view.addSubview(self.backUpButton)
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
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Private Key Text", comment: ""), style: .default, handler: { (action) in
                    
                    let textToShare = [self.privateKeyText]
                    let activityViewController = UIActivityViewController(activityItems: [textToShare as Any], applicationActivities: nil)
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

