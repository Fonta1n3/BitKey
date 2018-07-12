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

public func createPrivateKey(viewController: UIViewController) -> String {
    
    let segwit = SegwitAddrCoder()
    var hotMode = Bool()
    var legacyMode = Bool()
    var segwitMode = Bool()
    var testnetMode = Bool()
    var mainnetMode = Bool()
    var bitcoinAddress = String()
    var words = ""
    var recoveryPhrase = String()
    
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
                print("xpub = \(String(describing: xpub))")
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
                        return ""
                        
                    }
                    
                }
                
                if hotMode {
                    
                    if legacyMode {
                        
                        saveWallet(viewController: viewController, mnemonic: formatMnemonic2, xpub: xpub, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "testnet", type: "hot", index: 0)
                        
                    } else if segwitMode {
                        
                        saveWallet(viewController: viewController, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "testnet", type: "hot", index: 0)
                    }
                    
                } else {
                    
                    if legacyMode {
                        
                        saveWallet(viewController: viewController, mnemonic: "", xpub: xpub, address: bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "testnet", type: "cold", index: 0)
                        
                    } else if segwitMode {
                        
                        saveWallet(viewController: viewController, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "testnet", type: "cold", index: 0)
                        
                    }
                    
                }
                
                keychain?.key.clear()
                DispatchQueue.main.async {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                return recoveryPhrase
                
            } else if mainnetMode {
                
                let keychain = mnemonic.keychain.derivedKeychain(withPath: "m/44'/0'/0'/0")
                keychain?.key.isPublicKeyCompressed = true
                let privateKeyWIF = (keychain?.key(at: 0).privateKeyAddress.string)!
                let addressHD = (keychain?.key(at: 0).address.string)!
                let publicKey = (keychain?.key(at: 0).compressedPublicKey.hex())!
                //print("publicKey = \(String(describing: publicKey))")
                
                let xpub = (keychain?.extendedPublicKey)!
                let xpriv = keychain?.extendedPrivateKey
                print("xpub = \(String(describing: xpub))")
                print("xpriv = \(String(describing: xpriv))")
                //UserDefaults.standard.set(xpub, forKey: "xpub")
                //UserDefaults.standard.set(0, forKey: "int")
                
                
                if legacyMode {
                    
                    bitcoinAddress = addressHD
                    
                }
                
                if segwitMode {
                    
                    let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain?.key(at: 0).compressedPublicKey as Data!) as Data!) as Data!
                    
                    do {
                        
                        bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                        
                    } catch {
                        
                        displayAlert(viewController: viewController, title: "Error", message: "Please try again.")
                        return recoveryPhrase
                        
                    }
                    
                }
                
                if hotMode {
                    
                    if legacyMode {
                        
                        saveWallet(viewController: viewController, mnemonic: formatMnemonic2, xpub: xpub, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot", index: 0)
                        
                    } else if segwitMode {
                        
                        saveWallet(viewController: viewController, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot", index: 0)
                    }
                    
                } else {
                    
                    if legacyMode {
                        
                        saveWallet(viewController: viewController, mnemonic: "", xpub: xpub, address: bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "cold", index: 0)
                        
                    } else if segwitMode {
                        
                        saveWallet(viewController: viewController, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "cold", index: 0)
                        
                    }
                    
                }
                
                keychain?.key.clear()
                return recoveryPhrase
                
            }
            
        } else {
            
            return ""
            
        }
        
        return ""
        
    } else {
        
        displayAlert(viewController: viewController, title: "Error", message: "We had an error creating a cryptographically secure private key, please try again.")
    }
    
    return ""
    
}

