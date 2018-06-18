//
//  keyCreatorFromEntropy.swift
//  BitKeys
//
//  Created by Peter on 6/16/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import Foundation
import BigInt

public func createPrivateKey(viewController: UIViewController, userRandomness: BigInt) -> (privateKeyAddress: String, publicKeyAddress: String) {
    
    let segwit = SegwitAddrCoder()
    
    var coldMode = Bool()
    var hotMode = Bool()
    var legacyMode = Bool()
    var segwitMode = Bool()
    var testnetMode = Bool()
    var mainnetMode = Bool()
    var data = BigUInt(userRandomness).serialize()
    var bitcoinAddress = String()
    var privateKey = String()
    var words = ""
    var recoveryPhrase = String()
    
    if UserDefaults.standard.object(forKey: "coldMode") != nil {
        
        coldMode = UserDefaults.standard.object(forKey: "coldMode") as! Bool
        
    } else {
        
        coldMode = false
        UserDefaults.standard.set(false, forKey: "coldMode")
        
    }
    
    if UserDefaults.standard.object(forKey: "hotMode") != nil {
        
        hotMode = UserDefaults.standard.object(forKey: "hotMode") as! Bool
        
    } else {
        
        hotMode = true
        UserDefaults.standard.set(true, forKey: "hotMode")
        
    }
    
    if UserDefaults.standard.object(forKey: "legacyMode") != nil {
        
        legacyMode = UserDefaults.standard.object(forKey: "legacyMode") as! Bool
        
    } else {
        
        legacyMode = true
        UserDefaults.standard.set(true, forKey: "legacyMode")
        
    }
    
    if UserDefaults.standard.object(forKey: "segwitMode") != nil {
        
        segwitMode = UserDefaults.standard.object(forKey: "segwitMode") as! Bool
        
    } else {
        
        segwitMode = false
        UserDefaults.standard.set(false, forKey: "segwitMode")
        
    }
    
    if UserDefaults.standard.object(forKey: "testnetMode") != nil {
        
        testnetMode = UserDefaults.standard.object(forKey: "testnetMode") as! Bool
        
    } else {
        
        testnetMode = false
        UserDefaults.standard.set(false, forKey: "testnetMode")
        
    }
    
    if UserDefaults.standard.object(forKey: "mainnetMode") != nil {
        
        mainnetMode = UserDefaults.standard.object(forKey: "mainnetMode") as! Bool
        
    } else {
        
        mainnetMode = true
        UserDefaults.standard.set(true, forKey: "mainnetMode")
        
    }
    
    print("data.count = \(data.count)")
    
    
    let sha256OfData = BTCSHA256(data)
        
    var password = ""
        
    if let passwordCheck = UserDefaults.standard.object(forKey: "password") as? String {
            
        password = passwordCheck
    }
        
    if let mnemonic = BTCMnemonic.init(entropy: sha256OfData as Data!, password: password, wordListType: BTCMnemonicWordListType.english) {
            
        words = mnemonic.words.description
            
        let formatMnemonic1 = words.replacingOccurrences(of: "[", with: "")
        let formatMnemonic2 = formatMnemonic1.replacingOccurrences(of: "]", with: "")
        recoveryPhrase = formatMnemonic2.replacingOccurrences(of: ",", with: "")
            
        if testnetMode {
                
            let keychain = mnemonic.keychain.derivedKeychain(withPath: "m/44'/0'/0'/0")
            keychain?.key.isPublicKeyCompressed = true
                
            var privateKeyHD = String()
            var addressHD = String()
                
            privateKeyHD = (keychain?.key(at: 0).privateKeyAddressTestnet.description)!
            addressHD = (keychain?.key(at: 0).addressTestnet.description)!
            print("addressHD = \(addressHD)")
                
            let publicKey = (keychain?.key(at: 0).compressedPublicKey.hex())!
            print("publicKey = \(String(describing: publicKey))")
                
            let xpub = keychain?.bitcoinTestnet.extendedPublicKey
            let xpriv = keychain?.bitcoinTestnet.extendedPrivateKey
            print("xpub = \(String(describing: xpub))")
            print("xpriv = \(String(describing: xpriv))")
            UserDefaults.standard.set(xpub, forKey: "xpub")
            UserDefaults.standard.set(0, forKey: "int")
            let watchOnlyTestKey = BTCKeychain.init(extendedKey: xpub)
            let childkeychain = watchOnlyTestKey?.key(at: 2).addressTestnet
            print("childkeychain address = \(String(describing: childkeychain))")
                
            var privateKey3 = privateKeyHD.components(separatedBy: " ")
            let privateKeyWIF = privateKey3[1].replacingOccurrences(of: ">", with: "")
                
            if legacyMode {
                    
                let legacyAddress2 = (addressHD.description).components(separatedBy: " ")
                print("legacyAddress2 = \(legacyAddress2)")
                bitcoinAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                print("bitcoinAddress = \(bitcoinAddress)")
            }
                
            if segwitMode {
                    
                let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain?.key(at: 0).compressedPublicKey as Data!) as Data!) as Data!
                    
                do {
                        
                    bitcoinAddress = try segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                        
                } catch {
                        
                    displayAlert(viewController: viewController, title: "Error", message: "Please try again.")
                    return("", "")
                        
                }
                    
            }
                
            if hotMode {
                    
                saveWallet(viewController: viewController, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "testnet", type: "hot")
                    
            } else {
                    
                saveWallet(viewController: viewController, address: bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "testnet", type: "cold")
                    
            }
                
            keychain?.key.clear()
            data.removeAll()
            return (privateKeyWIF, bitcoinAddress)
                
        } else if mainnetMode {
                
            let keychain = mnemonic.keychain.derivedKeychain(withPath: "m/44'/0'/0'/0")
            keychain?.key.isPublicKeyCompressed = true
                
            var privateKeyHD = String()
            var addressHD = String()
                
            privateKeyHD = (keychain?.key(at: 0).privateKeyAddress.description)!
            addressHD = (keychain?.key(at: 0).address.description)!
            print("addressHD = \(addressHD)")
                
            let publicKey = (keychain?.key(at: 0).compressedPublicKey.hex())!
            print("publicKey = \(String(describing: publicKey))")
                
            let xpub = keychain?.extendedPublicKey
            let xpriv = keychain?.extendedPrivateKey
            print("xpub = \(String(describing: xpub))")
            print("xpriv = \(String(describing: xpriv))")
            UserDefaults.standard.set(xpub, forKey: "xpub")
            UserDefaults.standard.set(0, forKey: "int")
            let watchOnlyTestKey = BTCKeychain.init(extendedKey: xpub)
            let childkeychain = watchOnlyTestKey?.key(at: 2).address
            print("childkeychain address = \(String(describing: childkeychain))")
                
            let privateKey3 = privateKeyHD.components(separatedBy: " ")
            let privateKeyWIF = privateKey3[1].replacingOccurrences(of: ">", with: "")
                
            if legacyMode {
                    
                let legacyAddress2 = (addressHD.description).components(separatedBy: " ")
                bitcoinAddress = legacyAddress2[1].replacingOccurrences(of: ">", with: "")
                    
            }
                
            if segwitMode {
                    
                let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain?.key(at: 0).compressedPublicKey as Data!) as Data!) as Data!
                
                do {
                        
                    bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                        
                } catch {
                        
                    displayAlert(viewController: viewController, title: "Error", message: "Please try again.")
                    return("", "")
                        
                }
                    
            }
                
            if hotMode {
                    
                saveWallet(viewController: viewController, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot")
                    
            } else {
                    
                saveWallet(viewController: viewController, address: bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "cold")
                    
            }
                
            keychain?.key.clear()
            data.removeAll()
            return (privateKeyWIF, bitcoinAddress)
                
        }
            
    } else {
            
        data.removeAll()
        return("", "")
            
    }
        
    data.removeAll()
    return("", "")
    
    
}

