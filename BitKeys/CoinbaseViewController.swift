//
//  CoinbaseViewController.swift
//  BitKeys
//
//  Created by Peter on 3/21/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit


class CoinbaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoinbaseOAuth.startAuthentication(withClientId: "942e989d2c6fa86b120846408f1c188e2aec25ee9f5395fcce02ea690c568c03", scope: "user balance", redirectUri: "com.fontaine.BitKeys1.coinbase-oauth://coinbase-oauth", meta: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
