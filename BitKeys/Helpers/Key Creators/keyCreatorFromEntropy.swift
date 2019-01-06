//
//  keyCreatorFromEntropy.swift
//  BitKeys
//
//  Created by Peter on 6/16/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import Security

public func createPrivateKey(viewController: UIViewController, label: String) -> [Any] {
    
    let segwit = SegwitAddrCoder()
    var hotMode = Bool()
    var legacyMode = Bool()
    var segwitMode = Bool()
    var testnetMode = Bool()
    var mainnetMode = Bool()
    var bitcoinAddress = String()
    var words = ""
    var recoveryPhrase = String()
    var success = Bool()
    
    hotMode = checkSettingsForKey(keyValue: "hotMode")
    legacyMode = checkSettingsForKey(keyValue: "legacyMode")
    segwitMode = checkSettingsForKey(keyValue: "segwitMode")
    mainnetMode = checkSettingsForKey(keyValue: "mainnetMode")
    testnetMode = checkSettingsForKey(keyValue: "testnetMode")
    
    let bytesCount = 32
    var randomNum = ""
    var randomBytes = [UInt8](repeating: 0, count: bytesCount)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)
    
    if status == errSecSuccess {
        
        randomNum = randomBytes.map({String(format: "%02hhx", $0)}).joined(separator: "")
        let sha256OfData = BTCSHA256(BTCDataFromHex(randomNum))
        
        var password = ""
        
        if let passwordCheck = KeychainWrapper.standard.string(forKey: "BIP39Password") {
            
            password = passwordCheck
            
        }
        
        if let mnemonic = BTCMnemonic.init(entropy: sha256OfData as Data!, password: password, wordListType: BTCMnemonicWordListType.english) {
            
            words = mnemonic.words.description
            let formatMnemonic1 = words.replacingOccurrences(of: "[", with: "")
            let formatMnemonic2 = formatMnemonic1.replacingOccurrences(of: "]", with: "")
            print("formatMnemonic2 = \(formatMnemonic2)")
            recoveryPhrase = formatMnemonic2.replacingOccurrences(of: ",", with: "")
            
            if testnetMode {
                
                let keychain = mnemonic.keychain.derivedKeychain(withPath: "m/44'/0'/0'/0")
                keychain?.key.isPublicKeyCompressed = true
                let privateKeyWIF = (keychain?.key(at: 0).privateKeyAddressTestnet.string)!
                let addressHD = (keychain?.key(at: 0).addressTestnet.string)!
                let publicKey = (keychain?.key(at: 0).compressedPublicKey.hex())!
                let xpub = (keychain?.extendedPublicKey)!
                let xpriv = (keychain?.extendedPrivateKey)!
                
                if legacyMode {
                    
                    bitcoinAddress = addressHD
                    
                }
                
                if segwitMode {
                    
                    let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain?.key(at: 0).compressedPublicKey as Data!) as Data!) as Data!
                    
                    do {
                        
                        bitcoinAddress = try segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                        
                    } catch {
                        
                        displayAlert(viewController: viewController, title: "Error", message: "Please try again.")
                        return ["", false]
                        
                    }
                    
                }
                
                if hotMode {
                    
                    if legacyMode {
                        
                        success = saveWallet(viewController: viewController, mnemonic: formatMnemonic2, xpub: xpub, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "testnet", type: "hot", index: 0, label: label, xpriv: xpriv)
                        
                    } else if segwitMode {
                        
                        success = saveWallet(viewController: viewController, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "testnet", type: "hot", index: 0, label: label, xpriv: "")
                    }
                    
                } else {
                    
                    if legacyMode {
                        
                        success = saveWallet(viewController: viewController, mnemonic: "", xpub: xpub, address: bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "testnet", type: "cold", index: 0, label: label, xpriv: "")
                        
                    } else if segwitMode {
                        
                        success = saveWallet(viewController: viewController, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "testnet", type: "cold", index: 0, label: label, xpriv: "")
                        
                    }
                    
                }
                
                keychain?.key.clear()
                DispatchQueue.main.async {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                return [recoveryPhrase, success]
                
            } else if mainnetMode {
                
                let keychain = mnemonic.keychain.derivedKeychain(withPath: "m/44'/0'/0'/0")
                keychain?.key.isPublicKeyCompressed = true
                let privateKeyWIF = (keychain?.key(at: 0).privateKeyAddress.string)!
                let addressHD = (keychain?.key(at: 0).address.string)!
                let publicKey = (keychain?.key(at: 0).compressedPublicKey.hex())!
                let xpub = (keychain?.extendedPublicKey)!
                let xpriv = (keychain?.extendedPrivateKey)!
                
                if legacyMode {
                    
                    bitcoinAddress = addressHD
                    
                }
                
                if segwitMode {
                    
                    let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain?.key(at: 0).compressedPublicKey as Data!) as Data!) as Data!
                    
                    do {
                        
                        bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                        
                    } catch {
                        
                        displayAlert(viewController: viewController, title: "Error", message: "Please try again.")
                        return ["", false]
                        
                    }
                    
                }
                
                if hotMode {
                    
                    if legacyMode {
                        
                        success = saveWallet(viewController: viewController, mnemonic: formatMnemonic2, xpub: xpub, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot", index: 0, label: label, xpriv: xpriv)
                        
                    } else if segwitMode {
                        
                        success = saveWallet(viewController: viewController, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot", index: 0, label: label, xpriv: "")
                    }
                    
                } else {
                    
                    if legacyMode {
                        
                        success = saveWallet(viewController: viewController, mnemonic: "", xpub: xpub, address: bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "cold", index: 0, label: label, xpriv: "")
                        
                    } else if segwitMode {
                        
                        success = saveWallet(viewController: viewController, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "cold", index: 0, label: label, xpriv: "")
                        
                    }
                    
                }
                
                keychain?.key.clear()
                return [recoveryPhrase, success]
                
            }
            
        } else {
            
            return ["", false]
            
        }
        
        return ["", false]
        
    } else {
        
        displayAlert(viewController: viewController, title: "Error", message: "We had an error creating a cryptographically secure private key, please try again.")
    }
    
    return ["", false]
    
}

