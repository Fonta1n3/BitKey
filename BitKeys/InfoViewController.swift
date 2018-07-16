//
//  InfoViewController.swift
//  BitKeys
//
//  Created by Peter on 6/9/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController, UITextViewDelegate {
    
    var button = UIButton()
    var textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        print("InfoViewController")
        
        let imageView = UIImageView()
        imageView.image = UIImage(named:"background.jpg")
        imageView.frame = self.view.frame
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.alpha = 0.05
        self.view.addSubview(imageView)
        textView.delegate = self
        addBackButton()
        addTextView()
        
    }
    
     func addBackButton() {
        print("addBackButton")
        
        DispatchQueue.main.async {
            
            self.button.removeFromSuperview()
            self.button = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
            self.button.showsTouchWhenHighlighted = true
            self.button.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
            self.button.addTarget(self, action: #selector(self.back), for: .touchUpInside)
            self.view.addSubview(self.button)
            
        }
        
    }
    
    func addTextView() {
        
        textView = UITextView (frame:CGRect(x: 10, y: self.button.frame.maxY + 75, width: self.view.frame.width - 20, height: self.view.frame.height))
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.backgroundColor = UIColor.clear
        //textView.font = UIFont.init(name: "HelveticaNeue-Light", size: 18)
        
        textView.text = """
        
        Have a question, email us at BitSenseApp@gmail.com
        
        How to Use BitSense?
        
        If your using BitSense for the first time you will notice it created a wallet for you. You should have saved the recovery phrase and kept it somewhere safe incase you lose this device, if you didn't please start over!
        
        On the home screen you will see your wallets, you can tap each one to get options specific to that wallet. Tap the \"Pay\" button to pay from your wallet or the \"Receive\" button to create an invoice for your wallet.
        
        The wallet that BitSense creates for you is whats called a HD wallet (Heirarchical Determinsitic) and adheres to BIP44 standards. This means whenever you tap the "Receive" BitSense will generate an invoice for you that anyone can scan to send you Bitcoin. BitSense will never reuse the same address when creating invoices. We can do this because your wallet is an HD wallet and they are capable of deriving an infinite number of private keys and addresses from your recovery phrase which is why its so important that you write it down and save it.
        
        Each address and private key that is derived from your recovery phrase is numbered (indexed) in order starting from 0 and goes to essentially infinity. When you tap the wallet a pop up will come up from the bottom of your screen and give you multiple options. If you tap \"HD Keys\" button which has an infinity symbol you will see the first twenty private key/address pairs that your recovery phrase produces with their index number shown too (#0, #1, #2). You can see the next twenty by tapping the plus button again and again and again, displaying in increments of twenty working our way up.
        
        BitSense will check the balance of all twenty of these addresses when you tap \"HD Keys\" and whne you tap the plus sign, you can also tap each individual key for options to spend directly from that key, to create an invoice for that specific key, check transaction history for that key, save that key to your home screen wallet and finally export that key. This is a powerful tool. BitSense does not store any of these keys in anyway, we create them programmatically on demand. All we save is your master or parent wallet from which we can derive the children.
        
        If you do not want to use HD wallets thats fine too, you can just save one of the HD keys and it will be saved as a new wallet independent of the HD keys, meaning when you tap it you will be able to create an invoice for that same address multiple times, we only increment the invoice addresses for HD wallets, if you don't see the infinity symbol on your wallet then it will reuse your address over and over. Also you can import other wallets by scanning private keys or inputting recovery phrases. If you scan a private key that will be the only private key and address associated with that wallet.
        
        That brings us to they symbols BitSense uses to identify they type of wallet each one is:
        
        ∞
        
        This infinity symbol shows that the wallet is an HD wallet, you can tap \"HD Keys\" to see all the associated private keys and addresses and their balances. The private key and address on the home screen wallet is the 0 index and when you view the child keys it shows 0 to 20.
        
        👀
        
        This means your wallet is a watch only wallet and no private key is saved on the device for that wallet. You will only be able to receive Bitcoin and check the balances. You can also spend from it but you will need to manually scan or input the private key when trying to make the transaction. You can put BitSense into hot mode or cold mode in the settings and create watch only or hot wallets at your hearts desire.
        
        🤓
        
        This means that the wallet is on the \"Testnet\" and is for testing purposes only. You can put BitSense into testnet mode or mainnet mode in the settings. This is not real money and for testing purposes only. tBTC or tSAT means testnet bitcoin and testnet satoshis.
        
        If there is no symbol that simply means its a plain old private key and address on the Bitcoin mainnet network.
        
        Is BitSense secure?
        
        Whilst in Hot Mode the moment BitSense creates a private key it encrypts it and then saves it onto your device locally. The encryption is AES256CBC. The key that is used to encrypt the private keys is generated the first time you open the app and stored to your devices keychain which is also encrypted by Apple and is extremely secure. Even the FBI can’t access these encrypted keys on the keychain (apparently).
        
        BitSense creates a random Bitcoin native segwit Bech32 address and then reduces the number of characters down to 32 and uses this as your encryption key. We do this because the Bech32 format is easy to read and doesn't contain ambiguous characters like uppercase I's and lower case l's which can be easily confused (as you can see), you will appreciate that if you utilize our \"Create Back Up\" feature in the security settings which will require you to write this key down and save it as an emergency back up. This will save your private keys from your wallets on your home screen, this will NOT save your HD derived keys.
        
        We never upload your encrypted private keys, passwords or encryption keys to the internet in anyway. BitSense is designed to work with as little internet connectivity as possible, as far as key creation and management is concerned absolutley everything happens offline and on your device only, fully encrypted and stored on the keychain. Even when making a transaction you can turn the wifi off and put the phone in airplane mode when it comes to using your private key to sign the transaction.
        
        In Cold Mode you can spend your cold storage Bitcoins by inputting the debit and credit addresses and then scanning the debit private key, during the scanning of the private key your phone can be disconnected from the internet and we prompt you to do so. In hot mode the process is effortless and the decryption and signing of the the transaction by the private key all happens locally and without you even noticing. You can use BitSense in Cold Mode in which we never store any private key (encrypted or not) to your device.
        
        In the security settings you can choose to set a lock/unlock password which will require you to either input the password or do a biometric scan every time you want to spend Bitcoin or whenever you try to export a private key. You will also need it whenever you try and do security sensitive things like create backups and make changes to existing security settings.
        
        Invoices:
        
        If they are denominated in anything other then Bitcoin or Satoshis they will not work across other wallets and will only be usable by other BitSense users. If they are denominated in Bitcoin or Satoshis they adhere to BIP21 and will work on the majority of Bitcoin wallets. We do not support BIP70 and are not compatible with it.
        
        Segwit Mode:
        
        In Segwit mode the recovery phrase is no longer BIP44 compatible and will only work in BitSense to recover funds, therefore you can not expect to put that recovery phrase in another wallet and get a bech32 address, however it will work in BitSense as long as you are in Segwit Mode. We are working on this feature and will be upgrading our segwit compatibility in the future. For now all you can do is create bech32 addresses/private keys and check balances, you can not yet spend from them yet.
        
        Multi Sig:
        
        This is what I am working on now, the next major update will include full multi sig P2SH compatibility.
        
        
        BitSense Principles:
        
        We are FOSS (Free Open Sourced Software). You can take a look at the code at https://github.com/FontaineDenton/BitKey/tree/master/BitKeys 
        
        BitSense puts you the user in ultimate control of your private keys. You can export your private key and make your hot wallet cold at any time. You can put the app into cold mode and carry out transactions in a way that ensures no private key is ever saved anywhere. It is the perfect app for taking control of your own private keys. The likes of Coinbase and other exchanges are security holes and highly risky to store your Bitcoin on.
        
        Your Bitcoin your way, in BitSense I allow flexibility in that you can create many wallets in different formats and on different networks. For beginners the default mode is set to be as user friendly as possible, for advanced users you can go into the settings and make the changes you would like to make. Please make sure you do your research and understand the settings before changing them. Also play around with the app and test it out before you use real Bitcoin if you'd like, just put the app into testnet mode.
        
        BitSense supports segwit and Bech32 however we are starting simple, we are working to add full funcitonality for segwit but for now the app only allows creation of bech32 addresses and balance checking, sending transactions are coming soon.
        
        Security, ease of use and full flexibilty of all the powerful utilities Bitcoin provides are our mission to provide you as a user. This app is new and is a work in progress, we will constantly be improving it and making it as decentralized and independent as possible. For now we rely on BlockCypher's api for broadcasting transactions, in the future we hope to become fully autonomous and ideally allow users to run their own full node on the device. For now we are starting simple and ensuring we have a secure easy to use product that delivers some much needed common sense to the Bitcoin software space.
        
        
        I need help! If you are a developer and want to contribute please do contact me, I am making this 100% on my own and could use some help, find me on twitter @f0nta1n3 and reach out. This app is non profit and made out of love for Bitcoin only, if you'd like to donate please feel free to do so at:
        
        bc1qhnwtlwpyr5l7av6kd684wyretre5s2tgdefplt
        
        or
        
        17AWn578gsaXvWJAPgo7dH5ZbA6EWKDYsu
        
        
        
        
        """
        
        textView.attributedText = attributedText()
        
        self.view.addSubview(self.textView)
    }
    
    func attributedText()-> NSAttributedString
    {
        let string = textView.text as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSAttributedStringKey.font:UIFont.init(name: "HelveticaNeue-Light", size: 18)])
        
        let boldFontAttribute = [NSAttributedStringKey.font: UIFont.init(name: "HelveticaNeue-Bold", size: 20)]
        
        // Part of string to be bold
        attributedString.addAttributes(boldFontAttribute as [NSAttributedStringKey : Any], range: string.range(of: "How to Use BitSense?"))
        attributedString.addAttributes(boldFontAttribute as [NSAttributedStringKey : Any], range: string.range(of: "Why do I need to move the Bitcoin around?"))
        attributedString.addAttributes(boldFontAttribute as [NSAttributedStringKey : Any], range: string.range(of: "BitSense Principles:"))
        attributedString.addAttributes(boldFontAttribute as [NSAttributedStringKey : Any], range: string.range(of: "Is BitSense secure?"))
        attributedString.addAttributes(boldFontAttribute as [NSAttributedStringKey : Any], range: string.range(of: "BitSense Story:"))
        attributedString.addAttributes(boldFontAttribute as [NSAttributedStringKey : Any], range: string.range(of: "bc1q549843s7q4g4rzsxjtvyltkern5dj92lnm4vh9"))
        attributedString.addAttributes(boldFontAttribute as [NSAttributedStringKey : Any], range: string.range(of: "1BDpHh9iWGSzP29pYDenhnpx8acX9SnCUL"))
        
        // 4
        return attributedString
    }
    
    func addBoldText(fullString: NSString, boldPartOfString: NSString, font: UIFont!, boldFont: UIFont!) -> NSAttributedString {
        
        let nonBoldFontAttribute = [NSAttributedStringKey.font:font!]
            let boldFontAttribute = [NSAttributedStringKey.font:boldFont!]
            let boldString = NSMutableAttributedString(string: fullString as String, attributes:nonBoldFontAttribute)
            boldString.addAttributes(boldFontAttribute, range: fullString.range(of: boldPartOfString as String))
        return boldString
        
    }
    
    @objc func back() {
        
        self.dismiss(animated: true, completion: nil)
        
    }

}
