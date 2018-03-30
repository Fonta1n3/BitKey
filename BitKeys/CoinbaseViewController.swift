//
//  CoinbaseViewController.swift
//  BitKeys
//
//  Created by Peter on 3/21/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit


class CoinbaseViewController: UIViewController {
    
    var button = UIButton()
    
    let accessToken = UserDefaults.standard.string(forKey: "accessToken")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CoinbaseViewController")
        
        addButton()
       
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func viewWillAppear(_ animated: Bool) {
        CoinbaseOAuth.startAuthentication(withClientId: "942e989d2c6fa86b120846408f1c188e2aec25ee9f5395fcce02ea690c568c03", scope: "user balance", redirectUri: "com.fontaine.bitkeys1.coinbase-oauth://coinbase-oauth", meta: nil)
    }
    
    func addButton() {
        
        self.button = UIButton(frame: CGRect(x: self.view.center.x - 50, y: self.view.center.y - 75, width: 150 , height: 55))
        self.button.showsTouchWhenHighlighted = true
        self.button.backgroundColor = .black
        self.button.setTitle("Check Balance", for: .normal)
        self.button.addTarget(self, action: #selector(self.checkBalance), for: .touchUpInside)
        self.view.addSubview(self.button)
    }
    
    @objc func checkBalance() {
        
        let balance = CoinbaseBalance().amount
        print("balance = \(balance)")
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
