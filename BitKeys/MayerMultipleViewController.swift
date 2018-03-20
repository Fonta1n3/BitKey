//
//  MayerMultipleViewController.swift
//  BitKeys
//
//  Created by Peter on 3/21/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit

class MayerMultipleViewController: UIViewController {
    
    var button = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("MayerMultipleViewController")
        
        self.button = UIButton(frame: CGRect(x: 0, y: 0, width: 100 , height: 55))
        self.button.showsTouchWhenHighlighted = true
        self.button.backgroundColor = .black
        self.button.setTitle("Back", for: .normal)
        self.button.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        self.view.addSubview(self.button)
    }

    @objc func goBack() {
        
        self.dismiss(animated: false, completion: nil)
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
