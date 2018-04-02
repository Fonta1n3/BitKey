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
    var checkAddressButton = UIButton(type: .custom)
    var privateKeyText:String!
    var bitcoinAddress:String!
    var privateKeyMode:Bool!
    var mayerMultipleButton = UIButton(type: .custom)
    var connected:Bool!
    var diceButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        privateKeyMode = true
        showBitcoin()
        
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
        
        bitField = UITextView (frame:CGRect(x: view.center.x - (self.view.frame.width / 2), y: view.center.y - (self.view.frame.height / 2), width: self.view.frame.width, height: self.view.frame.height))
        bitField.isUserInteractionEnabled = false
        bitField.font = .systemFont(ofSize: 24)
        self.view.addSubview(bitField)
        
        let bitcoinImage = UIImage(named: "bitcoinIcon.png")
        imageView = UIImageView(image: bitcoinImage!)
        imageView.center = view.center
        imageView.frame = CGRect(x: view.center.x - 100, y: view.center.y - 100, width: 200, height: 200)
        
        let bitcoinDragged = UIPanGestureRecognizer(target: self, action: #selector(self.userCreatesRandomness(gestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(bitcoinDragged)
        view.addSubview(imageView)
        
    }
    
    func createPrivateKey(userRandomness: String) -> (privateKeyAddress: String, publicKeyAddress: String) {
        
        let bytesCount = 32 // number of bytes
        var randomNum = userRandomness // hexadecimal version of randomBytes
        var randomBytes = [UInt8](repeating: 0, count: bytesCount) // array to hold randoms bytes
        let secureRandomNumberCheck = SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes) //creates a cryptographicaally secure number based off of the random input provided by the user moving the bitcoin around
        
        //if the secureRandomNumberCheck is not equal to zero then it failed to create a crytpographically secure number
        if secureRandomNumberCheck == 0 {
            
            //randomNum is now a true cryptographically secure random number based on users random input and is turned into hexaadecimal format and joined together as a string
            randomNum = randomBytes.map({String(format: "%02hhx", $0)}).joined(separator: "")
            
            //convert the joined random string back to data
            if let newData = randomNum.data(using: String.Encoding.utf8){
                
                //get 256 bit hash from the cryptographically secure data
                let shaOfKey = BTCSHA256(newData)
                //use the bitcoin library to create the private key based of of the sha256 of the randmoness we created
                let keys = BTCKey.init(privateKey: shaOfKey! as Data)
                var privateKey:String!
                let privateKey2 = keys?.privateKeyAddress!.description
                var privateKey3 = privateKey2?.components(separatedBy: " ")
                privateKey = privateKey3![1].replacingOccurrences(of: ">", with: "")
                let segwitAddress = BTCScriptHashAddress.init(data: keys?.address.data)
                let segwitAddress2 = (segwitAddress?.description)?.components(separatedBy: " ")
                self.bitcoinAddress = segwitAddress2![1].replacingOccurrences(of: ">", with: "")
                
                return (privateKey, self.bitcoinAddress)
                
            } else {
                
                print("error creating a cryptographically secure random number")
                
            }
            
        }
        
        return ("", "")
    }
    
    @objc func userCreatesRandomness(gestureRecognizer: UIPanGestureRecognizer) {
        
        //remove buttons when bitcoin gets dragged
        self.checkAddressButton.removeFromSuperview()
        self.mayerMultipleButton.removeFromSuperview()
        self.diceButton.removeFromSuperview()
        
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
        let string = String(describing: shuffledArray)
        let stringFormat1 = string.replacingOccurrences(of: ", ", with: "")
        let stringFormat2 = stringFormat1.replacingOccurrences(of: "\"", with: "")
        let stringFormat3 = stringFormat2.replacingOccurrences(of: "[", with: "")
        let stringFormat4 = stringFormat3.replacingOccurrences(of: "]", with: "")
        
        //converts even numbers to 0 and odd numbers to 1 for a geeky computer bit look and is purely aesthetic
        let twoToZero = stringFormat4.replacingOccurrences(of: "2", with: "0")
        let fourToZero = twoToZero.replacingOccurrences(of: "4", with: "0")
        let sixToZero = fourToZero.replacingOccurrences(of: "6", with: "0")
        let eightToZero = sixToZero.replacingOccurrences(of: "8", with: "0")
        let threeToOne = eightToZero.replacingOccurrences(of: "3", with: "1")
        let fiveToOne = threeToOne.replacingOccurrences(of: "5", with: "1")
        let sevenToOne = fiveToOne.replacingOccurrences(of: "7", with: "1")
        let nineToOne = sevenToOne.replacingOccurrences(of: "9", with: "1")
        //displays random bits as user drags bitcoin and creates randomness
        bitField.text = nineToOne
        
        //senses user has stopped dragging the bitcoin
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            
            self.isInternetAvailable()
            
            //animates bitcoin back to center screen
            UIView.animate(withDuration: 0.5, animations: {
                
                bitcoinView.center =  self.view.center
                
            }, completion: { _ in
                
                //as soon as user stops moving the bitcoin it takes the user generated random number and uses that to create the truly random cryptographically secure private key
                
                //check if user is in airplane mode
                if self.connected == false {
                  
                    let privateKey = self.createPrivateKey(userRandomness: stringFormat4).privateKeyAddress
                    
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
                    
                } else {
                    
                    DispatchQueue.main.async {
                        self.displayAlert(title: "Device Connection Insecure", message: "Please enable airplane mode to create private keys.")
                        self.imageView.removeFromSuperview()
                        self.bitField.removeFromSuperview()
                        self.numberArray.removeAll()
                        self.showBitcoin()
                    }
                    
                }
                    
                })
                
                
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
            self.checkAddressButton.addTarget(self, action: #selector(self.goToCheckAddress), for: .touchUpInside)
            self.view.addSubview(self.checkAddressButton)
        }
        
    }
    
    func addMayerMultipleButton() {
        
        DispatchQueue.main.async {
            self.mayerMultipleButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.minY, width: self.view.frame.width, height: 55))
            self.mayerMultipleButton.showsTouchWhenHighlighted = true
            self.mayerMultipleButton.backgroundColor = .black
            self.mayerMultipleButton.setTitle("Mayer Multiple", for: .normal)
            self.mayerMultipleButton.addTarget(self, action: #selector(self.goToMayerMultiple), for: .touchUpInside)
            self.view.addSubview(self.mayerMultipleButton)
        }
        
    }
    
    func addDiceButton() {
        
        DispatchQueue.main.async {
            self.diceButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.maxY - 120, width: self.view.frame.width, height: 55))
            self.diceButton.showsTouchWhenHighlighted = true
            self.diceButton.backgroundColor = .black
            self.diceButton.setTitle("Dice Key Creator", for: .normal)
            self.diceButton.addTarget(self, action: #selector(self.goToDiceKeyCreator), for: .touchUpInside)
            self.view.addSubview(self.diceButton)
        }
    }
    
    @objc func goToDiceKeyCreator() {
        
       self.performSegue(withIdentifier: "diceKeyCreator", sender: self)
    }
    
    @objc func goToMayerMultiple() {
        
        self.performSegue(withIdentifier: "goToMayerMultiple", sender: self)
    }
    
    @objc func goToCheckAddress() {
        
        self.performSegue(withIdentifier: "checkAddress", sender: self)
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
    
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
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

