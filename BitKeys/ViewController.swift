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
    var transactionsButton = UIButton()
    var parseBitResult = BigInt()
    var bitArray = [String]()
    var zero = 0
    let segwit = SegwitAddrCoder()
    
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
        addTransactionsButton()
        
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
    
    func createPrivateKey(userRandomness: BigInt) -> (privateKeyAddress: String, publicKeyAddress: String) {
        
        let data = BigUInt(userRandomness).serialize()
        let keys = BTCKey.init(privateKey: data)
        var privateKey:String!
        let privateKey2 = keys?.privateKeyAddress!.description
        var privateKey3 = privateKey2?.components(separatedBy: " ")
        privateKey = privateKey3![1].replacingOccurrences(of: ">", with: "")
        let segwitAddress = keys?.address.description
        let segwitAddress2 = (segwitAddress?.description)?.components(separatedBy: " ")
        self.bitcoinAddress = segwitAddress2![1].replacingOccurrences(of: ">", with: "")
                
        print("privatekey = \(privateKey)")
        print("address = \(self.bitcoinAddress)")
        
        //ripemd160(sha256(compressed_pub_key))
        //bc for mainnet and tb for testnet
        
        let compressedPKData = BTCRIPEMD160(BTCSHA256(keys?.compressedPublicKeyAddress.data) as Data!) as Data!
        print("compressedPKData = \(String(describing: compressedPKData?.hex()))")
        var segwitBech32:String!
        
        do {
        
        segwitBech32 = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
            
            print("segwitBech32 = \(segwitBech32)")
            
            do {
                
                let testBech32 = try segwit.decode(hrp: "bc", addr: segwitBech32)
                print("testBech32 = \(testBech32.program.hex())")
                
            } catch {
                
                
            }
            
        } catch {
            
            
        }
        
        
        
        
        /*
        keys?.isPublicKeyCompressed = true
        let publickey = keys?.publicKey
        print("publickey = \(String(describing: publickey))")
        let compressedPublicKey = keys?.compressedPublicKey.hex()
        print("compressedPublicKey = \(String(describing: compressedPublicKey))")
        let uncompressedPubKey = keys?.uncompressedPublicKey.hex()
        print("uncompressedPubKey = \(String(describing: uncompressedPubKey))")
        let compressedPubKeyAddress = keys?.compressedPublicKeyAddress.data
        print("compressedPubKeyAddress = \(String(describing: keys?.compressedPublicKeyAddress.description))")
        let uncompressedPubKeyAddress = keys?.uncompressedPublicKeyAddress.data
        print("uncompressedPubKeyAddress = \(String(describing: keys?.uncompressedPublicKeyAddress.description))")
        let derPrivateKey = keys?.derPrivateKey.hex()
        print("derPrivateKey = \(String(describing: derPrivateKey))")
        let curvePoint = keys?.curvePoint.description
        print("curvePoint = \(String(describing: curvePoint))")
        let privateKeyRaw = keys?.privateKey.hex()
        print("privateKeyRaw = \(String(describing: privateKeyRaw))")
        let wif = keys?.wif
        print("wif = \(String(describing: wif))")
        
        
        //let script = BTCScript.init(publicKeys: [publickey as Any], signaturesRequired: 1)
        let script = BTCScript.init(address: keys?.address)
        print("scriptRaw = \(String(describing: script))")
        let p2sh = script?.scriptHashAddress
        print("p2sh = \(String(describing: p2sh))")
        let scriptHash = script?.scriptHash
        print("scriptHash = \(String(describing: scriptHash))")
        let scriptHex = scriptHash?.scriptHashAddress
        print("scriptHex = \(String(describing: scriptHex))")
        */
        //calcukate ripemd160 of the sha256 of a public key
        //the p2sh redeemScript in always 22 bytes. it starts with a OP_0 followed by a cononical push of the key hash
        
        /*Let's assume the following Public Key:  publicKey = 03fac6879502c4c939cfaadc45999c7ed7366203ad523ab83ad5502c71621a85bb
         
         *ripemd160(sha256(publicKey)) = 7646c030f7e75b80f0a31cdcab731e6f424f22b2 - hash
         
         *Add version to hash = 00147646c030f7e75b80f0a31cdcab731e6f424f22b2 - redeemScript
         
         *ripemd160(sha256(redeemScript)) = 188ba16284702258959d8bb63bb9a5d979b57875 - hash
         
         *sha256(sha256(redeemScript)) = 55c304447c41caee29f1d7c9779a3a8e9dd00ea7905e286e733049d12e1b479f - hash-for-checksum
         
         --so far so good (I assume)--
         
         *4 byte checksum = 55c30444 - checksum
         
         *'05' + hash + checksum = 05188ba16284702258959d8bb63bb9a5d979b5787555c30444 - this is the part I get wrong I think
         
 
        
        let pubkey = keys?.publicKey
        let sha256pk = BTCSHA256(pubkey as Data!)
        let rmdsha256pk = BTCRIPEMD160(sha256pk as Data!)
        let redeemScript = "0014" + BTCBase58StringWithData(rmdsha256pk as Data!)
        let sha256redeemScript = BTCSHA256(BTCDataFromHex(redeemScript))
        let ripeMDsha256redeemScript = BTCRIPEMD160(sha256redeemScript as Data!)
        let doubleSha = BTCSHA256(BTCSHA256(ripeMDsha256redeemScript as Data!) as Data!)
        
        var arr = [String]()
        for (index, c) in (doubleSha?.hex().enumerated())! {
            
            if index < 8 {
                arr.append(String(c))
            }
            
        }
        let fourbytechecksum = arr.joined()
        
        let rmd160Hex = ripeMDsha256redeemScript?.hex()
        let x = "05" + rmd160Hex! + fourbytechecksum
        let data2 = BTCBase58StringWithData(BTCDataFromHex(x))
        print("segwit = \(String(describing: data2))")
        */
        
        //try this to creat segwit address
        /*var btc = require('bitcore-lib')
         var oldAddress = btc.Address.fromString("1Ek9S3QNnutPV7GhtzR8Lr8yKPhxnUP8iw") // here's the old address
         var oldHash = oldAddress.hashBuffer
         var segwitP2PKH = Buffer.concat([new Buffer("0014","hex"), oldHash]) // 0x00 + 0x14 (pushdata 20 bytes) + old pubkeyhash
         var p2shHash = btc.crypto.Hash.sha256ripemd160(segwitP2PKH)
         var p2shAddress = btc.Address.fromScriptHash(p2shHash)
         var newAddress = p2shAddress.toString()
         // 36ghjA1KSAB1jDYD2RdiexEcY7r6XjmDQk*/
        //let oldAddress = keys?.address
        //let oldHash = oldAddress?.hash
        
        //let p2shHash = BTCRIPEMD160(BTCSHA256(BTCDataFromHex(segwitP2PKH)) as Data!) as Data!
        //let hashAddress = BTCScriptHashAddress.init(data: p2shHash as Data!)
        //print("hashAddress = \(String(describing: hashAddress))")
        
        //let sha = BTCSHA256(keys?.compressedPublicKey as Data!)
        //let ripeMD160 = BTCRIPEMD160(sha as Data!)
        //let ripeMD160Hex = BTCHexFromData(ripeMD160 as Data!)
        
        
        
        
        
        
        
        
        
        //print("redeemScript = \(ripeMD160HexPlus5)")
        //let shaOfRS = BTCSHA256(BTCDataFromHex(ripeMD160HexPlus5))
        //let rmd160 = BTCRIPEMD160(shaOfRS as Data!)
        //let p2shAddress = BTCScript.init(data: rmd160 as Data!)
        //print("p2shAddress = \(String(describing: p2shAddress?.description))")
        //let segwitAddress33 = BTCBase58StringWithData(rmd160 as Data!)
        //print("segwitAddress33 = \(String(describing: segwitAddress33))")
        /*
        let doubleHashRDS = BTCSHA256(BTCSHA256(rmd160 as Data!) as Data!)
        print("doubleHashRDS = \(doubleHashRDS?.hex())")
        
        var arr = [String]()
        for (index, c) in (doubleHashRDS?.hex().enumerated())! {
            
            if index < 8 {
             arr.append(String(c))
            }
            
        }
        let fourbytechecksum = arr.joined()
        print("fourbytechecksum = \(fourbytechecksum)")
        let rmd160Hex = rmd160?.hex()
        let x = "05" + rmd160Hex! + fourbytechecksum
        let data2 = BTCBase58StringWithData(BTCDataFromHex(x))
        print("segwit = \(String(describing: data2))")
       */
        
        
        return (privateKey, self.bitcoinAddress)
        
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
        
        //converts even numbers to 0 and odd numbers to 1 for a geeky computer bit look and is purely aesthetic
        let twoToZero = joinedArray.replacingOccurrences(of: "2", with: "10")
        let fourToZero = twoToZero.replacingOccurrences(of: "4", with: "100")
        let sixToZero = fourToZero.replacingOccurrences(of: "6", with: "110")
        let eightToZero = sixToZero.replacingOccurrences(of: "8", with: "1000")
        let threeToOne = eightToZero.replacingOccurrences(of: "3", with: "11")
        let fiveToOne = threeToOne.replacingOccurrences(of: "5", with: "101")
        let sevenToOne = fiveToOne.replacingOccurrences(of: "7", with: "111")
        let nineToOne = sevenToOne.replacingOccurrences(of: "9", with: "1001")
        
        //displays random bits as user drags bitcoin and creates randomness
        bitField.text = nineToOne
        
        //senses user has stopped dragging the bitcoin
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            
            self.isInternetAvailable()
            
            for character in nineToOne {
                
                self.zero = self.zero + 1
                self.bitArray.append(String(character))
                
                if self.zero == 256 {
                    
                    let bits = self.bitArray.joined()
                    print("bits = \(bits)")
                    
                    self.parseBitResult = self.parseBinary(binary: bits)!
                    print("self.parseBitResult = \(self.parseBitResult)")
                    
                    let privateKey = self.createPrivateKey(userRandomness: self.parseBitResult).privateKeyAddress
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        bitcoinView.center =  self.view.center
                        
                    }, completion: { _ in
                        
                        if self.connected == false {
                            
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
                                        self.zero = 0
                                        self.bitArray.removeAll()
                                        
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
    
    @objc func goTo(sender: UIButton) {
        
        switch sender {
            
        case self.diceButton:
            
            self.performSegue(withIdentifier: "diceKeyCreator", sender: self)
            
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
    
    @objc func goToMayerMultiple() {
        
        self.performSegue(withIdentifier: "goToMayerMultiple", sender: self)
    }
    
    @objc func goToTransaction() {
        
        self.performSegue(withIdentifier: "transaction", sender: self)
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



