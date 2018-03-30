//
//  DiceKeyCreatorViewController.swift
//  BitKeys
//
//  Created by Peter on 3/27/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit

class DiceKeyCreatorViewController: UIViewController {
    
    var testBaseSixNumber:String = "013204210253401135012500542231151255200403534241023010345253121220450343033405200200405235000334425"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    

}

extension Data {
    func hex(separator:String = "") -> String {
        return (self.map { String(format: "%02X", $0) }).joined(separator: separator)
    }
}
