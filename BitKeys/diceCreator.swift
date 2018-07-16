//
//  keyCreatorFromEntropy.swift
//  BitKeys
//
//  Created by Peter on 6/16/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import BigInt

public func diceKey(viewController: UIViewController, userRandomness: BigInt) -> [Any] {
    
    var testnetMode = Bool()
    var mainnetMode = Bool()
    var bitcoinAddress = String()
    var words = ""
    var recoveryPhrase = String()
    let data = BigUInt(userRandomness).serialize()
    var success = Bool()
    
    mainnetMode = checkSettingsForKey(keyValue: "mainnetMode")
    testnetMode = checkSettingsForKey(keyValue: "testnetMode")
    
    let sha256OfData = BTCSHA256(data)
        
    var password = ""
        
    if let passwordCheck = KeychainWrapper.standard.string(forKey: "BIP39Password") {
            
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
            let addressHD = (keychain?.key(at: 0).addressTestnet.string)!
            let publicKey = (keychain?.key(at: 0).compressedPublicKey.hex())!
            let xpub = (keychain?.extendedPublicKey)!
            bitcoinAddress = addressHD
                
            success = saveWallet(viewController: viewController, mnemonic: formatMnemonic2, xpub: xpub, address: bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "testnet", type: "cold", index: 0, label: "", xpriv: "")
                
            keychain?.key.clear()
            DispatchQueue.main.async {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            return [recoveryPhrase, success]
                
        } else if mainnetMode {
                
            let keychain = mnemonic.keychain.derivedKeychain(withPath: "m/44'/0'/0'/0")
            keychain?.key.isPublicKeyCompressed = true
            let addressHD = (keychain?.key(at: 0).address.string)!
            let publicKey = (keychain?.key(at: 0).compressedPublicKey.hex())!
            let xpub = (keychain?.extendedPublicKey)!
            bitcoinAddress = addressHD
                    
            success = saveWallet(viewController: viewController, mnemonic: formatMnemonic2, xpub: xpub, address: bitcoinAddress, privateKey: "", publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "cold", index: 0, label: "", xpriv: "")
                
            keychain?.key.clear()
            return [recoveryPhrase, success]
                
        }
            
    } else {
            
        return ["", false]
            
    }
        
    return ["", false]
 
}


