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
        //textView.font = UIFont.init(name: "HelveticaNeue-Light", size: 18)
        
        textView.text = """
        
        How to Use BitSense?
        
        Simply move the Bitcoin around until it disappears then you will be given a recovery phrase that you should write down in case you lose your device or accidentally delete the app. That way you can use your recovery phrase to recover your Bitcoin.
        
        You can then tap on the Address Book button to see your wallet. It will show the balance of that wallet in Bitcoin. You have lots of options in the Address Book and you can create lots of wallets.
        
        To receive Bitcoin you can tap the receive button on the home screen and it will show you your Bitcoin Address where anyone on the world can send you Bitcoin. If you want someone to send you Bitcoin you can either show it to them in person or tap the share button and share the text of the address or QR code anyway you’d like, this is the only piece of information needed for someone to send you Bitcoin.
        
        To spend Bitcoin tap the Pay button. BitSense has a lot of settings that are customizable, by default we denominate your transaction in US Dollars, you can change that by tapping the settings button on the pay page.
        
        You can check any balance by tapping the Balance button, from there you can scan or input any Bitcoin address or tap the address book.
        
        
        Why do I need to move the Bitcoin around?
        
        A Bitcoin wallet is simply a Private Key which is really just a large random number. In order for your Private Key to be unhackable it should be as random as possible. If the Private Key is not random then it gives a hacker an advantage at guessing what your Private Key is, for example it is more likely for a hacker to guess the number 11111111111111111111111 then 9237532487584593829339825.
        
        To create randomness we use your finger motion on the device to track your X and Y coordinates across the screen, these coordinates are just numbers, we convert the even numbers to 0's and the odd numbers to 1's. As your swiping and creating this long string of 1's and 0's we are also randomly shuffling those 1's and 0's to add another layer of randomness. We wait until you have a string of 1's and 0's that is 800 digits in length and then convert those ones and zeros into bits, and we randomnly select 256 of those 800 bits to create a 256 bit number (which in normal number format that you are used to is about 76 digits in length and approximately equivalent to the number of atoms in the visible universe!).
        
        We then put that 256 bit number through a SHA256 algorithm to add an extra layer of randomness and to guarantee the result is 256 bits, this is your Private Key.
        
        
        BitSense Principles:
        
        We are FOSS (Free Open Sourced Software). You can take a look at the code at https://github.com/FontaineDenton/BitKey/tree/master/BitKeys
        
        BitSense puts you the user in ultimate control of your private keys. You can export your private key and make your hot wallet cold at any time. You can put the app into cold mode and carry out transactions in a way that ensures no private key is ever saved anywhere. It is the perfect app for taking control of your own private keys. The likes of Coinbase and other exchanges are security holes and highly risky to store your Bitcoin on.
        
        Your Bitcoin your way, in BitSense I allow flexibility in that you can create many wallets in different formats and on different networks. For beginners the default mode is set to be as user friendly as possible, for advanced users you can go into the settings and make the changes you would like to make. Please make sure you do your research and understand the settings before changing them. Also play around with the app and test it out before you use real Bitcoin if you'd like, just put the app into testnet mode.
        
        BitSense supports segwit and Bech32 however we are starting simple, we are working to add full funcitonality for segwit but for now the app only allows creation of bech32 addresses and balance checking, sending transactions are coming soon.
        
        Security, ease of use and full flexibilty of all the powerful utilities Bitcoin provides are our mission to provide you as a user. This app is new and is a work in progress, we will constantly be improving it and making it as decentralized and independent as possible. For now we rely on BlockCypher's api for broadcasting transactions, in the future we hope to become fully autonomous and ideally allow users to run their own full node on the device. For now we are starting simple and ensuring we have a secure easy to use product that delivers some much needed common sense to the Bitcoin software space.
        
        
        Is BitSense secure?
        
        Whilst in Hot Mode the moment BitSense creates a private key it encrypts it and then saves it onto your device locally. The encryption is AES256CBC. The key that is used to encrypt the private keys is generated the first time you open the app and stored to your devices keychain which is also encrypted by Apple and is extremely secure. Even the FBI can’t access these encrypted keys on the keychain (apparently).
        
        BitSense creates a random Bitcoin native segwit Bech32 address and then reduces the number of characters down to 32 and uses this as your encryption key. We do this because the Bech32 format is easy to read and doesn't contain ambiguous characters like uppercase I's and lower case l's which can be easily confused (as you can see), you will appreciate that if you utilize our \"Create Back Up\" feature in the security settings which will require you to write this key down and save it as an emergency back up.
        
        We never upload your encrypted private keys, passwords or encryption keys to the internet in anyway. BitSense is designed to work with as little internet connectivity as possible, as far as key creation and management is concerned absolutley everything happens offline and on your device only, fully encrypted and stored on the keychain. Even when making a transaction you can turn the wifi off and put the phone in airplane mode when it comes to using your private key to sign the transaction.
        
        In Cold Mode you can spend your cold storage Bitcoins by inputting the debit and credit addresses and then scanning the debit private key, during the scanning of the private key your phone can be disconnected from the internet and we prompt you to do so. In hot mode the process is effortless and the decryption and signing of the the transaction by the private key all happens locally and without you even noticing. You can use BitSense in Cold Mode in which we never store any private key (encrypted or not) to your device.
        
        In the security settings you can choose to set a lock/unlock password which will require you to either input the password or do a biometric scan every time you want to spend Bitcoin or whenever you try to export a private key. You will also need it whenever you try and do security sensitive things like create backups and make changes to existing security settings.
        
        BitSense Story:
        
        I am a solo independent developer and started making BitSense because I could not beleive at how complicated and confusing most Bitcoin software is to use. It is not beginner friendly, also simple apps like being able to create a private key and address on an iPhone did not exist. BitSense was inspired by www.bitaddress.org where you can create cold storage wallets offline, in BitSense's very first release that is all it did.  It still does that but in a much more secure way and also allows lots of extremely powerful options for advanced users and offers full hot wallet capabilities. It is a true tool kit for Bitcoin and I hope you enjoy using it. It is a constant work in progress and more features and improvements will be made constantly. We vow to always keep it backwards compatible so that when the app updates you won't have to do anything that would compromise your Bitcoin. I love Bitcoin and made this app primarily for myself, I hope others find it useful and it helps people to use Bitcoin more easily and securely. If you have any questions I am on twitter @f0nta1n3, please reach out with any questions, comments or concerns, I will be happy to help.
        
        I need help! If you are a developer and want to contribute please do contact me, I am making this 100% on my own and could use some help, find me on twitter @f0nta1n3 and reach out. This app is non profit and made out of love for Bitcoin only, if you'd like to donate please feel free to do so at:
        
        bc1q549843s7q4g4rzsxjtvyltkern5dj92lnm4vh9
        
        or
        
        1BDpHh9iWGSzP29pYDenhnpx8acX9SnCUL
        
        
        
        
        """
        
        textView.attributedText = attributedText()
        
        /*let normalFont = UIFont.init(name: "HelveticaNeue-Light", size: 18)
        let boldFont = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        self.textView.attributedText = addBoldText(fullString: textView.text as NSString, boldPartOfString: ["How to Use BitSense?", "Why do I need to move the Bitcoin around?"], font: normalFont!, boldFont: boldFont!)*/
        
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
