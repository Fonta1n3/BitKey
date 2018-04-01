//
//  DiceKeyCreatorViewController.swift
//  BitKeys
//
//  Created by Peter on 3/27/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit

class DiceKeyCreatorViewController: UIViewController {
    
    var diceButton = UIButton()
    var testBaseSixNumber:String = "013204210253401135012500542231151255200403534241023010345253121220450343033405200200405235000334425"
    
    @IBOutlet var scrollView: UIScrollView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        /*
        if let newData = testBaseSixNumber.data(using: String.Encoding.utf8){
            
            let shaOfKey = BTCSHA256(newData)
            let keys = BTCKey.init(privateKey: shaOfKey as! Data)
            
            var privateKey:String!
            let  privateKey2 = keys?.privateKeyAddress!.description
            var privateKey3 = privateKey2?.components(separatedBy: " ")
            privateKey = privateKey3![1].replacingOccurrences(of: ">", with: "")
            print("privateKey = \(privateKey!)")
            
            var bitcoinAddress:String!
            let bitcoinAddress1 = keys?.address.description
            var bitcoinAddress2 = bitcoinAddress1?.components(separatedBy: " ")
            bitcoinAddress = bitcoinAddress2![1].replacingOccurrences(of: ">", with: "")
            print("bitcoinAddress = \(bitcoinAddress!)")
            
            
        }
        */
        
        showDice()
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        scrollView.contentSize = CGSize(width: 414, height: 1850)
    }

    func showDice() {
        
        var xvalue = 25;
        var yvalue = 40
        
        var zero = 0
        
        for i in 0..<20 {
            
            //zero = zero + 1
            
            for i in 0..<5 {
                
                zero = zero + 1
                self.diceButton = UIButton(frame: CGRect(x: xvalue, y: yvalue, width: 65, height: 65))
                self.diceButton.tag = zero
                print("tag = \(self.diceButton.tag)")
                self.diceButton.showsTouchWhenHighlighted = true
                self.diceButton.backgroundColor = .gray
                self.diceButton.setTitle("\(0)", for: .normal)
                self.diceButton.titleLabel?.textColor = UIColor.white
                self.diceButton.addTarget(self, action: #selector(self.tapDice), for: .touchUpInside)
                self.scrollView.addSubview(self.diceButton)
                xvalue = xvalue + 75
            }
            xvalue=25;
            yvalue = yvalue + 90
        }
    }
    

    @objc func tapDice(sender: UIButton!) {
        
        let diceNumber = Int((sender.titleLabel?.text)!)
        
        if diceNumber == 0 {
            DispatchQueue.main.async {
                sender.setTitle("1", for: .normal)
                sender.backgroundColor = .black
            }
        } else if diceNumber == 1 {
            DispatchQueue.main.async {
                sender.setTitle("2", for: .normal)
                sender.backgroundColor = .black
            }
        } else if diceNumber == 2 {
            DispatchQueue.main.async {
                sender.setTitle("3", for: .normal)
                sender.backgroundColor = .black
            }
        } else if diceNumber == 3 {
            DispatchQueue.main.async {
                sender.setTitle("4", for: .normal)
                sender.backgroundColor = .black
            }
        } else if diceNumber == 4 {
            DispatchQueue.main.async {
                sender.setTitle("5", for: .normal)
                sender.backgroundColor = .black
            }
        } else if diceNumber == 5 {
            DispatchQueue.main.async {
                sender.setTitle("6", for: .normal)
                sender.backgroundColor = .black
            }
        } else if diceNumber == 6 {
            DispatchQueue.main.async {
                sender.setTitle("1", for: .normal)
                sender.backgroundColor = .black
            }
        }
        
    }
    
}

extension Data {
    func hex(separator:String = "") -> String {
        return (self.map { String(format: "%02X", $0) }).joined(separator: separator)
    }
}
