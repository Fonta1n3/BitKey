//
//  CoinbaseViewController.swift
//  BitKeys
//
//  Created by Peter on 3/21/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit


class CoinbaseViewController: UIViewController {
    
    let accessToken = UserDefaults.standard.string(forKey: "accessToken")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CoinbaseViewController")
        
        let balance = CoinbaseBalance().amount
        print("balance = \(balance)")
    }
    
    

    override func viewWillAppear(_ animated: Bool) {
        CoinbaseOAuth.startAuthentication(withClientId: "942e989d2c6fa86b120846408f1c188e2aec25ee9f5395fcce02ea690c568c03", scope: "user balance", redirectUri: "com.fontaine.bitkeys1.coinbase-oauth://coinbase-oauth", meta: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
