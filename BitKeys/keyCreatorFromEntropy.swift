//
//  keyCreatorFromEntropy.swift
//  BitKeys
//
//  Created by Peter on 6/16/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import Foundation
import BigInt

public func createPrivateKey(viewController: UIViewController, userRandomness: BigInt) -> (privateKeyAddress: String, publicKeyAddress: String, recoveryPhrase: String) {
    
    let segwit = SegwitAddrCoder()
    
    //var coldMode = Bool()
    var hotMode = Bool()
    var legacyMode = Bool()
    var segwitMode = Bool()
    var testnetMode = Bool()
    var mainnetMode = Bool()
    var data = BigUInt(userRandomness).serialize()
    var bitcoinAddress = String()
    //var privateKey = String()
    var words = ""
    var recoveryPhrase = String()
    
    hotMode = checkSettingsForKey(keyValue: "hotMode")
    //coldMode = checkSettingsForKey(keyValue: "coldMode")
    legacyMode = checkSettingsForKey(keyValue: "legacyMode")
    segwitMode = checkSettingsForKey(keyValue: "segwitMode")
    mainnetMode = checkSettingsForKey(keyValue: "mainnetMode")
    testnetMode = checkSettingsForKey(keyValue: "testnetMode")
    
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
            let privateKeyWIF = (keychain?.key(at: 0).privateKeyAddressTestnet.string)!
            let addressHD = (keychain?.key(at: 0).addressTestnet.string)!
            let publicKey = (keychain?.key(at: 0).compressedPublicKey.hex())!
            //let xpub = keychain?.bitcoinTestnet.extendedPublicKey
            //let xpriv = keychain?.bitcoinTestnet.extendedPrivateKey
            //let watchOnlyTestKey = BTCKeychain.init(extendedKey: xpub)
            //let childkeychain = watchOnlyTestKey?.key(at: 2).addressTestnet
            
            if legacyMode {
                    
                bitcoinAddress = addressHD
                
            }
                
            if segwitMode {
                    
                let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain?.key(at: 0).compressedPublicKey as Data!) as Data!) as Data!
                    
                do {
                        
                    bitcoinAddress = try segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                        
                } catch {
                        
                    displayAlert(viewController: viewController, title: "Error", message: "Please try again.")
                    return("", "", "")
                        
                }
                    
            }
                
            if hotMode {
                    
                saveWallet(viewController: viewController, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "testnet", type: "hot")
                    
            } else {
                    
                saveWallet(viewController: viewController, address: bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "testnet", type: "cold")
                    
            }
                
            keychain?.key.clear()
            data.removeAll()
            return (privateKeyWIF, bitcoinAddress, recoveryPhrase)
                
        } else if mainnetMode {
                
            let keychain = mnemonic.keychain.derivedKeychain(withPath: "m/44'/0'/0'/0")
            keychain?.key.isPublicKeyCompressed = true
            let privateKeyWIF = (keychain?.key(at: 0).privateKeyAddress.string)!
            let addressHD = (keychain?.key(at: 0).address.string)!
            let publicKey = (keychain?.key(at: 0).compressedPublicKey.hex())!
            //print("publicKey = \(String(describing: publicKey))")
                
            //let xpub = keychain?.extendedPublicKey
            //let xpriv = keychain?.extendedPrivateKey
            //print("xpub = \(String(describing: xpub))")
            //print("xpriv = \(String(describing: xpriv))")
            //UserDefaults.standard.set(xpub, forKey: "xpub")
            //UserDefaults.standard.set(0, forKey: "int")
            //let watchOnlyTestKey = BTCKeychain.init(extendedKey: xpub)
            //let childkeychain = watchOnlyTestKey?.key(at: 2).address
            //print("childkeychain address = \(String(describing: childkeychain))")
            
                
            if legacyMode {
                    
                bitcoinAddress = addressHD
                    
            }
                
            if segwitMode {
                    
                let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain?.key(at: 0).compressedPublicKey as Data!) as Data!) as Data!
                
                do {
                        
                    bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                        
                } catch {
                        
                    displayAlert(viewController: viewController, title: "Error", message: "Please try again.")
                    return("", "", recoveryPhrase)
                        
                }
                    
            }
                
            if hotMode {
                    
                saveWallet(viewController: viewController, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot")
                    
            } else {
                    
                saveWallet(viewController: viewController, address: bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "cold")
                    
            }
                
            keychain?.key.clear()
            data.removeAll()
            return (privateKeyWIF, bitcoinAddress, recoveryPhrase)
                
        }
            
    } else {
            
        data.removeAll()
        return("", "", "")
            
    }
        
    data.removeAll()
    return("", "", "")
    
    
}

