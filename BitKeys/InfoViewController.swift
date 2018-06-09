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
    
    var text = "How BitSense works?\n\nWhen you download the app BitSense defaults into \"simple mode\", you can then optionally turn your wifi off and turn airplane mode on and create your wallet offline for maximum security.\n\nSimple Mode:\n\n In simple mode the app is whats called a hot wallet. Hot wallets are Bitcoin wallets that store your private key for you so you can easily spend Bitcoin. It is highly recommended you only store small amounts of Bitcoin in a hot wallet as it is possible for people to spend your Bitcoin if they can access your phone, you should treat your hot wallet just like you would treat actual cash.\n\nIn simple mode you can spend Bitcoin with the pay button, check your balance with the balance button, check the price with the price button, get your Bitcoin address with the recieve button, change the settings with the settings button, and most importantly create your Bitcoin private key and address by moving the Bitcoin around.\n\nWhy do I need to move the Bitcoin around?\n\nA Bitcoin wallet is simply a Private Key and an Address whereby your Private Key is like your email password and your Address is like your email address. In order to spend Bitcoin you need your private key just like you need a password to log in to your email acount to send an email, you need an address so that people can send you Bitcoin just like you need an email address so people can send you emails. A Private Key is simply a 76 digit number (more or less) and your address is mathematically derived from your Private Key. In order to create a secure Private Key you need to make sure that the 76 digit number you use to create the private key is truly random, so BitSense uses your finger motion on the screen  to track the numerical coordinates your finger follows, it then converts those numbers to bits (zeros and ones) shuffles them randomonly while you drag (thats the ones and zeros you see when your dragging), once you dragged the Bitcoin around enough to generate a 256 bit number we convert the bits back into a decimal number and use that as the source of randomness to create your private key. In simple mode you have no control of your private key and never see it, it all happens programmatically, we manage it for you. We recommend always using the wallet in advanced and cold mode and doing your homework so that you understand what your wallet is capable of.\n\nAdvanced Mode:\n\nIn \"advanced mode\" BitSense is an entirely different piece of software that gives you ultimate control over your own Private Keys. In advanced mode you can choose between cold mode or hot mode, segwit mode or legacy mode, and testnet mode or mainnet mode. You will see buttons labeled as \"Dice\", \"Multi-Sig\", \"Import\", \"Sweep\", \"Receive\", \"Export\", \"Balance\", \"Pay\", and \"Price\".\n\nDice Button:\n\nThe Dice button allows you to create your private key in the ultimate secure way by inputting actual dice rolls into BitSense. BitSense converts each dice roll number into actual bits (1 = 00, 2 = 01, 3 = 10, 4 = 11, 5 = 0 and 6 = 1) and combines each succesive bit from each dice roll in order from left to right. This is the most secure way possible of creating private keys because the primary risk factor in creating private keys that can be hacked is lack of sufficient entropy (randomness). Think of it this way, humans are terrible at creating random numbers, we love patterns, if a human creates a 76 digit number its not going to be mathematically random and therefore is much more likely to be guessed by another human who could also create that number or by the software that some human wrote. So its far better to use dice to create your private keys for long term storage of high amounts of Bitcoin as using dice is the only way to create mathematically random numbers. It is worth taking the twenty minutes to roll enough dice to get your random number. The best practice is take five casino grade dice, roll them on a hard flat surface so that they bounce off a wall and then from left to right input the dice values into BitSense as they actually appear in front of you. BitSense forces you to input the dice from left to right one at a time, you can only edit the last dice you have input. You will end up with the most secure private key possible and if your serious about storing your wealth in Bitcoin why would you want to trust a computer to think up your private key for you? Remember all software is written by humans and can be faulty, the app simply converts the dice rolls into bits and then into the 76 digit number and then into your private key. The percentage ticker at the top keeps track of how many bits your number is and automatically produces your private key when the number reaches 256 bits.\n\nMulti-Sig:\n\nThe Multi Sig button allows you to create a multi sig wallet by asking you how many private keys are required and how many signatures are required to spend the funds. After you input the info and scan or input the correct amount of private keys in wif format, BitSense will show you your Multi Sig P2SH address and redemption script. This is a cold wallet only and not stored on your phone in any way, its up to you to save the private keys, address and redemption script. We plan to release a hot wallet version for multi sig soon.\n\nImport Button:\n\nThe import button allows you to input a seed or recovery phrase into the app along with an optional password, this is BIP39 compatible and works with famous wallets like Mycelium and Electrum. Everytime you produce a private key in advanced mode you get a recovery phrase with your private key, write it down and store it safely, then if you lose your phone you can use any iphone to download BitSense and import your saved recovery phrase to get your private key back or use it to import a private key from another popular wallet, if your settings are in hot mode then the wallet will save the private key.\n\nSweep Button:\n\nThe Sweep button does the same thing as import but instead of inputting a recovery phrase you simply scan or type in your wif private key and its automatically saved if you are in hot wallet mode, if you are in cold mode then this button does not appear.\n\nExport Button:\n\nThe Export button only appears in hot mode and simply displays your private key and address to you so that you can share or save it.\n\nBalance Button:\n\nIn advanced mode the balance button allows you to scan or input any Bitcoin address to check its balance, you can then save the address you have checked to your address book by tapping the save button and \"Add to Address Book\", when you save an address in this manner your phone will always give you the option of checking your \"Address Book\" until you overwrite it.\n\nPay Button:\n\nIn advanced mode the pay button offers far greater flexibility allowing you to choose the denomination of your Bitcoin in either Bitcoin, Satoshis, USD, EUR or GBP. It also gives the option to sweep all funds which will spend all the Bitcoin in your wallet or cold storage private key. You also have the option of utilizing the Raw Transaction Tool which allows you to input raw transactions to decode them (so that you can verify they are accurate) and to send them by tapping the push button. After you input the amount of Bitcoin you want to send you will get a confirmation message and you will be prompted to choose your miner fee preference, a high preference is desgined to get your transaction mined within one to two blocks and will be expensive, a low fee will get it mined in around 7 blocks (can be less) and the Manually Set option allows you to choose any sized fee denominated in Satoshis, beware if you put a fee in that is too low your transacion may never get mined. If you are in hot mode you will only need to input the address you want to send Bitcoin to, you can do this by scanning an address or typing it in, if you are in cold mode you will have to scan the recieving address then the debit address then you may turn airplane mode on, and scan your private key that you want to debit to create a signature for the transaction, after the signature is created you can turn the internet back on, we do not save your private key at all when you create the signature and even in hot mode your private key is not uploaded to the internet, only the signature gets broadcast. You will then get a final confirmation message which confirms the recieving address, debit address, amount and the actual fee in Satoshis that you will be charged. BitSense does not collect any fees at all it simply goes to the miners who need an economic incentive to mine Bitcoin.\n\nPrice Button:\n\nThe price button in advanced mode gives you a breakdown of what the current mayer multiple is, the spot price in dollars and the % deviation of the spot price from the mayer multiple.\n\nSettings:\n\nAbove we have largely explained the difference between advanced mode and simple mode and also the difference between hot mode and cold mode, user beware that when switching between modes such as hot mode and cold mode your hot wallet WILL BE DELETED, you will always be warned before we delete your private key but once its deleted its gone forever so make sure you always save your back up phrase and be extra careful, Bitcoin is grown up money and you must use it with caution, your keys your responsibility.\n\nTestnet Mode and Mainnet Mode:\n\nTestnet mode has all the same functionality in the app except it uses the play money version of Bitcoin called testnet, where developers can test new software and you can test BitSense out with play money essentially, it is also a good way to show a friend how Bitcoin works, we will be adding an option to fund your testnet address programmatically soon.\n\nMainnet mode is the real deal and all transactions are with real Bitcoin, USE WITH CAUTION, always try a test transaction with a small amount first.\n\nSegwit Mode and Legacy Mode:\n\nThis is a basic wallet and does NOT support spending Bitcoin to or from Bech32 addresses, I support Segwit and want my wallet to offer Bech32 capabliities and as its more adopted will upgrade the wallet, but for now it simply creates a Segwit Bech32 address with a private key and thats it, you can also check balances, transactions will be coming soon. Legacy mode is the default address format for Bitcoin and will always produce legacy addresses for you. You can use Segwit wrapped P2SH addresses in the Pay button whether your in Segwit Mode or Legacy mode, the only thing Segwit Mode does differently is creates Bech32 addresses instead of Legacy addresses as well as checks Bech32 balances."

    override func viewDidLoad() {
        super.viewDidLoad()

        print("InfoViewController")
        textView.delegate = self
        addBackButton()
        addTextView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func addBackButton() {
        print("addBackButton")
        
        DispatchQueue.main.async {
            
            self.button.removeFromSuperview()
            self.button = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
            self.button.showsTouchWhenHighlighted = true
            /*self.button.layer.cornerRadius = 10
            self.button.backgroundColor = UIColor.lightText
            self.button.layer.shadowColor = UIColor.black.cgColor
            self.button.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.button.layer.shadowRadius = 2.5
            self.button.layer.shadowOpacity = 0.8
            self.button.setTitle("Back", for: .normal)*/
            self.button.setImage(#imageLiteral(resourceName: "back.png"), for: .normal)
            self.button.addTarget(self, action: #selector(self.back), for: .touchUpInside)
            self.view.addSubview(self.button)
            
        }
        
    }
    
    func addTextView() {
        
        self.textView = UITextView (frame:CGRect(x: 10, y: self.button.frame.maxY + 75, width: self.view.frame.width - 20, height: self.view.frame.height))
        self.textView.isEditable = false
        self.textView.isSelectable = true
        self.textView.isScrollEnabled = true
        self.textView.font = .systemFont(ofSize: 24)
        self.textView.text = self.text
        self.view.addSubview(self.textView)
    }
    
    @objc func back() {
        
        self.dismiss(animated: true, completion: nil)
        
    }

}
