//
//  SettingsViewController.swift
//  BitKeys
//
//  Created by Peter on 5/21/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var backButton = UIButton()
    var segwitButton = UIButton()
    var legacyButton = UIButton()
    var hotModeButton = UIButton()
    var coldModeButton = UIButton()
    var testnetModeButton = UIButton()
    var mainnetModeButton = UIButton()
    var advancedModeButton = UIButton()
    var simpleModeButton = UIButton()
    
    var simpleMode = Bool()
    var advancedMode = Bool()
    var segwitMode = Bool()
    var legacyMode = Bool()
    var hotMode = Bool()
    var coldMode = Bool()
    var testnetMode = Bool()
    var mainnetMode = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("SettingsViewController")
        
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        checkUserDefaults()
        addButtons()
    }
    
    func checkUserDefaults() {
        
        print("checkUserDefaults")
        
        if UserDefaults.standard.object(forKey: "simpleMode") != nil {
            
            simpleMode = UserDefaults.standard.object(forKey: "simpleMode") as! Bool
            
        } else {
            
            simpleMode = true
            
        }
        
        if UserDefaults.standard.object(forKey: "advancedMode") != nil {
            
            advancedMode = UserDefaults.standard.object(forKey: "advancedMode") as! Bool
            
        } else {
            
            advancedMode = false
            
        }
        
        if UserDefaults.standard.object(forKey: "coldMode") != nil {
            
            coldMode = UserDefaults.standard.object(forKey: "coldMode") as! Bool
            
        } else {
            
            coldMode = true
            
        }
        
        if UserDefaults.standard.object(forKey: "hotMode") != nil {
            
            hotMode = UserDefaults.standard.object(forKey: "hotMode") as! Bool
            
        } else {
            
            hotMode = false
            
        }
        
        if UserDefaults.standard.object(forKey: "legacyMode") != nil {
            
            legacyMode = UserDefaults.standard.object(forKey: "legacyMode") as! Bool
            
        } else {
            
            legacyMode = true
            
        }
        
        if UserDefaults.standard.object(forKey: "segwitMode") != nil {
            
            segwitMode = UserDefaults.standard.object(forKey: "segwitMode") as! Bool
            
        } else {
            
            segwitMode = false
            
        }
        
        if UserDefaults.standard.object(forKey: "testnetMode") != nil {
            
            testnetMode = UserDefaults.standard.object(forKey: "testnetMode") as! Bool
            
        } else {
            
            testnetMode = false
            
        }
        
        if UserDefaults.standard.object(forKey: "mainnetMode") != nil {
            
            mainnetMode = UserDefaults.standard.object(forKey: "mainnetMode") as! Bool
            
        } else {
            
            mainnetMode = true
            
        }
    }
    
    func setDefaults() {
        
        UserDefaults.standard.set(true, forKey: "legacyMode")
        UserDefaults.standard.set(false, forKey: "segwitMode")
        UserDefaults.standard.set(true, forKey: "hotMode")
        UserDefaults.standard.set(false, forKey: "coldMode")
        UserDefaults.standard.set(true, forKey: "mainnetMode")
        UserDefaults.standard.set(false, forKey: "testnetMode")
        UserDefaults.standard.set(false, forKey: "advancedMode")
        UserDefaults.standard.set(true, forKey: "simpleMode")
        
    }

    func addButtons() {
        
        print("addButtons")
        
        DispatchQueue.main.async {
            
            self.backButton.removeFromSuperview()
            self.backButton = UIButton(frame: CGRect(x: 5, y: 20, width: 90, height: 55))
            self.backButton.showsTouchWhenHighlighted = true
            self.backButton.layer.cornerRadius = 10
            self.backButton.backgroundColor = UIColor.lightText
            self.backButton.layer.shadowColor = UIColor.black.cgColor
            self.backButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.backButton.layer.shadowRadius = 2.5
            self.backButton.layer.shadowOpacity = 0.8
            self.backButton.setTitle("Back", for: .normal)
            self.backButton.addTarget(self, action: #selector(self.goTo(sender:)), for: .touchUpInside)
            self.view.addSubview(self.backButton)
            
            self.simpleModeButton.removeFromSuperview()
            
            self.simpleModeButton = UIButton(frame: CGRect(x: 10, y: 100, width: self.view.frame.width - 20, height: 50))
            self.simpleModeButton.showsTouchWhenHighlighted = true
            self.simpleModeButton.layer.cornerRadius = 10
            self.simpleModeButton.layer.shadowColor = UIColor.black.cgColor
            self.simpleModeButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.simpleModeButton.layer.shadowRadius = 2.5
            self.simpleModeButton.layer.shadowOpacity = 0.8
            self.simpleModeButton.addTarget(self, action: #selector(self.goTo(sender:)), for: .touchUpInside)
            
            if self.simpleMode {
                
                self.simpleModeButton.backgroundColor = UIColor.lightText
                self.simpleModeButton.setTitle("Simple Mode - ON", for: .normal)
                
                self.setDefaults()
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.hotModeButton.alpha = 0
                    self.coldModeButton.alpha = 0
                    self.segwitButton.alpha = 0
                    self.legacyButton.alpha = 0
                    self.testnetModeButton.alpha = 0
                    self.mainnetModeButton.alpha = 0
                    
                }, completion: { (true) in
                    
                    self.hotModeButton.removeFromSuperview()
                    self.coldModeButton.removeFromSuperview()
                    self.segwitButton.removeFromSuperview()
                    self.legacyButton.removeFromSuperview()
                    self.testnetModeButton.removeFromSuperview()
                    self.mainnetModeButton.removeFromSuperview()
                    
                })
                
            } else {
                
                self.simpleModeButton.backgroundColor = UIColor.groupTableViewBackground
                self.simpleModeButton.setTitleColor(UIColor.black, for: .normal)
                self.simpleModeButton.setTitle("Simple Mode - OFF", for: .normal)
                
            }
            
            self.view.addSubview(self.simpleModeButton)
            
            self.advancedModeButton.removeFromSuperview()
            
            self.advancedModeButton = UIButton(frame: CGRect(x: 10, y: 155, width: self.view.frame.width - 20, height: 50))
            self.advancedModeButton.showsTouchWhenHighlighted = true
            self.advancedModeButton.layer.cornerRadius = 10
            self.advancedModeButton.layer.shadowColor = UIColor.black.cgColor
            self.advancedModeButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.advancedModeButton.layer.shadowRadius = 2.5
            self.advancedModeButton.layer.shadowOpacity = 0.8
            self.advancedModeButton.addTarget(self, action: #selector(self.goTo(sender:)), for: .touchUpInside)
            
            if self.advancedMode {
                
                self.advancedModeButton.backgroundColor = UIColor.lightText
                self.advancedModeButton.setTitle("Advanced Mode - ON", for: .normal)
                
            } else {
                
                self.advancedModeButton.backgroundColor = UIColor.groupTableViewBackground
                self.advancedModeButton.setTitleColor(UIColor.black, for: .normal)
                self.advancedModeButton.setTitle("Advanced Mode - OFF", for: .normal)
                
                self.setDefaults()
                
            }
            
            self.view.addSubview(self.advancedModeButton)
            
            self.segwitButton.removeFromSuperview()
            
            self.segwitButton = UIButton(frame: CGRect(x: 10, y: 460, width: self.view.frame.width - 20, height: 50))
            self.segwitButton.showsTouchWhenHighlighted = true
            self.segwitButton.layer.cornerRadius = 10
            self.segwitButton.layer.shadowColor = UIColor.black.cgColor
            self.segwitButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.segwitButton.layer.shadowRadius = 2.5
            self.segwitButton.layer.shadowOpacity = 0.8
            self.segwitButton.addTarget(self, action: #selector(self.goTo(sender:)), for: .touchUpInside)
            
            if self.segwitMode {
                
                self.segwitButton.backgroundColor = UIColor.lightText
                self.segwitButton.setTitle("Segwit Mode - ON", for: .normal)
                
            } else {
                
                self.segwitButton.backgroundColor = UIColor.groupTableViewBackground
                self.segwitButton.setTitleColor(UIColor.black, for: .normal)
                self.segwitButton.setTitle("Segwit Mode - OFF", for: .normal)
                
            }
            
            self.view.addSubview(self.segwitButton)
             
            self.legacyButton.removeFromSuperview()
            
            self.legacyButton = UIButton(frame: CGRect(x: 10, y: 515, width: self.view.frame.width - 20, height: 50))
            self.legacyButton.showsTouchWhenHighlighted = true
            self.legacyButton.layer.cornerRadius = 10
            self.legacyButton.layer.shadowColor = UIColor.black.cgColor
            self.legacyButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.legacyButton.layer.shadowRadius = 2.5
            self.legacyButton.layer.shadowOpacity = 0.8
            self.legacyButton.addTarget(self, action: #selector(self.goTo(sender:)), for: .touchUpInside)
            
            if self.legacyMode {
                
                self.legacyButton.backgroundColor = UIColor.lightText
                self.legacyButton.setTitle("Legacy Mode - ON", for: .normal)
                
            } else {
                
                self.legacyButton.backgroundColor = UIColor.groupTableViewBackground
                self.legacyButton.setTitleColor(UIColor.black, for: .normal)
                self.legacyButton.setTitle("Legacy Mode - OFF", for: .normal)
                
            }
            
            self.view.addSubview(self.legacyButton)
            
            self.hotModeButton.removeFromSuperview()
            
            self.hotModeButton = UIButton(frame: CGRect(x: 10, y: 220, width: self.view.frame.width - 20, height: 50))
            self.hotModeButton.showsTouchWhenHighlighted = true
            self.hotModeButton.layer.cornerRadius = 10
            self.hotModeButton.layer.shadowColor = UIColor.black.cgColor
            self.hotModeButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.hotModeButton.layer.shadowRadius = 2.5
            self.hotModeButton.layer.shadowOpacity = 0.8
            self.hotModeButton.addTarget(self, action: #selector(self.goTo(sender:)), for: .touchUpInside)
            
            if self.hotMode {
                
                self.hotModeButton.backgroundColor = UIColor.lightText
                self.hotModeButton.setTitle("Hot Mode - ON", for: .normal)
                
            } else {
                
                self.hotModeButton.backgroundColor = UIColor.groupTableViewBackground
                self.hotModeButton.setTitleColor(UIColor.black, for: .normal)
                self.hotModeButton.setTitle("Hot Mode - OFF", for: .normal)
                
            }
            
            self.view.addSubview(self.hotModeButton)
            
            
            self.coldModeButton.removeFromSuperview()
            
            self.coldModeButton = UIButton(frame: CGRect(x: 10, y: 275, width: self.view.frame.width - 20, height: 50))
            self.coldModeButton.showsTouchWhenHighlighted = true
            self.coldModeButton.layer.cornerRadius = 10
            self.coldModeButton.layer.shadowColor = UIColor.black.cgColor
            self.coldModeButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.coldModeButton.layer.shadowRadius = 2.5
            self.coldModeButton.layer.shadowOpacity = 0.8
            self.coldModeButton.addTarget(self, action: #selector(self.goTo(sender:)), for: .touchUpInside)
            
            if self.coldMode {
                
                self.coldModeButton.backgroundColor = UIColor.lightText
                self.coldModeButton.setTitle("Cold Mode - ON", for: .normal)
                
            } else {
                
                self.coldModeButton.backgroundColor = UIColor.groupTableViewBackground
                self.coldModeButton.setTitleColor(UIColor.black, for: .normal)
                self.coldModeButton.setTitle("Cold Mode - OFF", for: .normal)
                
            }
            
            self.view.addSubview(self.coldModeButton)
            
            self.testnetModeButton.removeFromSuperview()
            
            self.testnetModeButton = UIButton(frame: CGRect(x: 10, y: 340, width: self.view.frame.width - 20, height: 50))
            self.testnetModeButton.showsTouchWhenHighlighted = true
            self.testnetModeButton.layer.cornerRadius = 10
            self.testnetModeButton.layer.shadowColor = UIColor.black.cgColor
            self.testnetModeButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.testnetModeButton.layer.shadowRadius = 2.5
            self.testnetModeButton.layer.shadowOpacity = 0.8
            self.testnetModeButton.addTarget(self, action: #selector(self.goTo(sender:)), for: .touchUpInside)
            
            if self.testnetMode {
                
                self.testnetModeButton.backgroundColor = UIColor.lightText
                self.testnetModeButton.setTitle("Testnet Mode - ON", for: .normal)
                
            } else {
                
                self.testnetModeButton.backgroundColor = UIColor.groupTableViewBackground
                self.testnetModeButton.setTitleColor(UIColor.black, for: .normal)
                self.testnetModeButton.setTitle("Testnet Mode - OFF", for: .normal)
                
            }
            
            self.view.addSubview(self.testnetModeButton)
            
            self.mainnetModeButton.removeFromSuperview()
            
            self.mainnetModeButton = UIButton(frame: CGRect(x: 10, y: 395, width: self.view.frame.width - 20, height: 50))
            self.mainnetModeButton.showsTouchWhenHighlighted = true
            self.mainnetModeButton.layer.cornerRadius = 10
            self.mainnetModeButton.layer.shadowColor = UIColor.black.cgColor
            self.mainnetModeButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.mainnetModeButton.layer.shadowRadius = 2.5
            self.mainnetModeButton.layer.shadowOpacity = 0.8
            self.mainnetModeButton.addTarget(self, action: #selector(self.goTo(sender:)), for: .touchUpInside)
            
            if self.mainnetMode {
                
                self.mainnetModeButton.backgroundColor = UIColor.lightText
                self.mainnetModeButton.setTitle("Mainnet Mode - ON", for: .normal)
                
            } else {
                
                self.mainnetModeButton.backgroundColor = UIColor.groupTableViewBackground
                self.mainnetModeButton.setTitleColor(UIColor.black, for: .normal)
                self.mainnetModeButton.setTitle("Mainnet Mode - OFF", for: .normal)
                
            }
            
            self.view.addSubview(self.mainnetModeButton)
             
            
             
        }
        
    }
    
   @objc func goTo(sender: UIButton) {
    
        print("goTo")
        
        switch sender {
            
        case self.backButton:
            
            print("back button")
            self.dismiss(animated: false, completion: nil)
            
        case self.advancedModeButton:
            
            print("advancedModeButton")
            
            if advancedMode {
                
                sender.setTitle("Advanced Mode - OFF", for: .normal)
                sender.backgroundColor = UIColor.groupTableViewBackground
                sender.setTitleColor(UIColor.black, for: .normal)
                self.advancedMode = false
                UserDefaults.standard.set(self.simpleMode, forKey: "advancedMode")
                
                self.simpleModeButton.setTitle("Simple Mode - ON", for: .normal)
                self.simpleModeButton.backgroundColor = UIColor.lightText
                self.simpleModeButton.setTitleColor(UIColor.white, for: .normal)
                self.simpleMode = true
                UserDefaults.standard.set(self.simpleMode, forKey: "simpleMode")
                
                self.setDefaults()
                
                DispatchQueue.main.async {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        self.hotModeButton.alpha = 0
                        self.coldModeButton.alpha = 0
                        self.segwitButton.alpha = 0
                        self.legacyButton.alpha = 0
                        self.testnetModeButton.alpha = 0
                        self.mainnetModeButton.alpha = 0
                        
                    }, completion: { (true) in
                        
                        self.hotModeButton.removeFromSuperview()
                        self.coldModeButton.removeFromSuperview()
                        self.segwitButton.removeFromSuperview()
                        self.legacyButton.removeFromSuperview()
                        self.testnetModeButton.removeFromSuperview()
                        self.mainnetModeButton.removeFromSuperview()
                        
                    })
                    
                }
                
            } else {
                
                sender.setTitle("Advanced Mode - ON", for: .normal)
                sender.backgroundColor = UIColor.lightText
                sender.setTitleColor(UIColor.white, for: .normal)
                self.advancedMode = true
                UserDefaults.standard.set(self.advancedMode, forKey: "advancedMode")
                
                self.simpleModeButton.setTitle("Simple Mode - OFF", for: .normal)
                self.simpleModeButton.backgroundColor = UIColor.groupTableViewBackground
                self.simpleModeButton.setTitleColor(UIColor.black, for: .normal)
                self.simpleMode = false
                UserDefaults.standard.set(self.simpleMode, forKey: "simpleMode")
                
                self.hotModeButton.alpha = 0
                self.coldModeButton.alpha = 0
                self.segwitButton.alpha = 0
                self.legacyButton.alpha = 0
                self.testnetModeButton.alpha = 0
                self.mainnetModeButton.alpha = 0
                
                self.view.addSubview(hotModeButton)
                self.view.addSubview(coldModeButton)
                self.view.addSubview(segwitButton)
                self.view.addSubview(legacyButton)
                self.view.addSubview(testnetModeButton)
                self.view.addSubview(mainnetModeButton)
                
                DispatchQueue.main.async {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        self.hotModeButton.alpha = 1
                        self.coldModeButton.alpha = 1
                        self.segwitButton.alpha = 1
                        self.legacyButton.alpha = 1
                        self.testnetModeButton.alpha = 1
                        self.mainnetModeButton.alpha = 1
                        
                    }, completion: { (true) in
                        
                    })
                    
                }
                
            }
            
        case self.simpleModeButton:
            
            print("simpleModeButton")
            
            if simpleMode {
                
                sender.setTitle("Simple Mode - OFF", for: .normal)
                sender.backgroundColor = UIColor.groupTableViewBackground
                sender.setTitleColor(UIColor.black, for: .normal)
                self.simpleMode = false
                UserDefaults.standard.set(self.simpleMode, forKey: "simpleMode")
                
                self.advancedModeButton.setTitle("Advanced Mode - ON", for: .normal)
                self.advancedModeButton.backgroundColor = UIColor.lightText
                self.advancedModeButton.setTitleColor(UIColor.white, for: .normal)
                self.advancedMode = true
                UserDefaults.standard.set(self.advancedMode, forKey: "advancedMode")
                
                self.hotModeButton.alpha = 0
                self.coldModeButton.alpha = 0
                self.segwitButton.alpha = 0
                self.legacyButton.alpha = 0
                self.testnetModeButton.alpha = 0
                self.mainnetModeButton.alpha = 0
                
                self.view.addSubview(hotModeButton)
                self.view.addSubview(coldModeButton)
                self.view.addSubview(segwitButton)
                self.view.addSubview(legacyButton)
                self.view.addSubview(testnetModeButton)
                self.view.addSubview(mainnetModeButton)
                
                DispatchQueue.main.async {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        self.hotModeButton.alpha = 1
                        self.coldModeButton.alpha = 1
                        self.segwitButton.alpha = 1
                        self.legacyButton.alpha = 1
                        self.testnetModeButton.alpha = 1
                        self.mainnetModeButton.alpha = 1
                        
                    }, completion: { (true) in
                        
                    })
                    
                }
                
            } else {
                
                sender.setTitle("Simple Mode - ON", for: .normal)
                sender.backgroundColor = UIColor.lightText
                sender.setTitleColor(UIColor.white, for: .normal)
                self.simpleMode = true
                UserDefaults.standard.set(self.simpleMode, forKey: "simpleMode")
                
                self.advancedModeButton.setTitle("Advanced Mode - OFF", for: .normal)
                self.advancedModeButton.backgroundColor = UIColor.groupTableViewBackground
                self.advancedModeButton.setTitleColor(UIColor.black, for: .normal)
                self.advancedMode = false
                UserDefaults.standard.set(self.advancedMode, forKey: "advancedMode")
                
                self.setDefaults()
                
                DispatchQueue.main.async {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        self.hotModeButton.alpha = 0
                        self.coldModeButton.alpha = 0
                        self.segwitButton.alpha = 0
                        self.legacyButton.alpha = 0
                        self.testnetModeButton.alpha = 0
                        self.mainnetModeButton.alpha = 0
                        
                    }, completion: { (true) in
                        
                        self.hotModeButton.removeFromSuperview()
                        self.coldModeButton.removeFromSuperview()
                        self.segwitButton.removeFromSuperview()
                        self.legacyButton.removeFromSuperview()
                        self.testnetModeButton.removeFromSuperview()
                        self.mainnetModeButton.removeFromSuperview()
                        
                    })
                    
                }
                
            }
            
        case self.segwitButton:
            
            print("segwit button")
            
            if segwitMode {
                
                sender.setTitle("Segwit Mode - OFF", for: .normal)
                sender.backgroundColor = UIColor.groupTableViewBackground
                sender.setTitleColor(UIColor.black, for: .normal)
                self.segwitMode = false
                UserDefaults.standard.set(self.segwitMode, forKey: "segwitMode")
                
                self.legacyButton.setTitle("Legacy Mode - ON", for: .normal)
                self.legacyButton.backgroundColor = UIColor.lightText
                self.legacyButton.setTitleColor(UIColor.white, for: .normal)
                self.legacyMode = true
                UserDefaults.standard.set(self.legacyMode, forKey: "legacyMode")
                
            } else {
                
                sender.setTitle("Segwit Mode - ON", for: .normal)
                sender.backgroundColor = UIColor.lightText
                sender.setTitleColor(UIColor.white, for: .normal)
                self.segwitMode = true
                UserDefaults.standard.set(self.segwitMode, forKey: "segwitMode")
                
                self.legacyButton.setTitle("Legacy Mode - OFF", for: .normal)
                self.legacyButton.backgroundColor = UIColor.groupTableViewBackground
                self.legacyButton.setTitleColor(UIColor.black, for: .normal)
                self.legacyMode = false
                UserDefaults.standard.set(self.legacyMode, forKey: "legacyMode")
                
            }
            
        case self.legacyButton:
            
            print("legacy button")
            
            if legacyMode {
                
                sender.setTitle("Legacy Mode - OFF", for: .normal)
                sender.backgroundColor = UIColor.groupTableViewBackground
                sender.setTitleColor(UIColor.black, for: .normal)
                self.legacyMode = false
                UserDefaults.standard.set(self.legacyMode, forKey: "legacyMode")
                
                self.segwitButton.setTitle("Segwit Mode - ON", for: .normal)
                self.segwitButton.backgroundColor = UIColor.lightText
                self.segwitButton.setTitleColor(UIColor.white, for: .normal)
                self.segwitMode = true
                UserDefaults.standard.set(self.segwitMode, forKey: "segwitMode")
                
            } else {
                
                sender.setTitle("Legacy Mode - ON", for: .normal)
                sender.backgroundColor = UIColor.lightText
                sender.setTitleColor(UIColor.white, for: .normal)
                self.legacyMode = true
                UserDefaults.standard.set(self.legacyMode, forKey: "legacyMode")
                
                self.segwitButton.setTitle("Segwit Mode - OFF", for: .normal)
                self.segwitButton.backgroundColor = UIColor.groupTableViewBackground
                self.segwitButton.setTitleColor(UIColor.black, for: .normal)
                self.segwitMode = false
                UserDefaults.standard.set(self.segwitMode, forKey: "segwitMode")
                
            }
            
        case self.hotModeButton:
            
            print("Hot mode button")
            
            if hotMode {
                
                sender.setTitle("Hot Mode - OFF", for: .normal)
                sender.backgroundColor = UIColor.groupTableViewBackground
                sender.setTitleColor(UIColor.black, for: .normal)
                self.hotMode = false
                UserDefaults.standard.set(self.hotMode, forKey: "hotMode")
                
                self.coldModeButton.setTitle("Cold Mode - ON", for: .normal)
                self.coldModeButton.backgroundColor = UIColor.lightText
                self.coldModeButton.setTitleColor(UIColor.white, for: .normal)
                self.coldMode = true
                UserDefaults.standard.set(self.coldMode, forKey: "coldMode")
                
            } else {
                
                sender.setTitle("Hot Mode - ON", for: .normal)
                sender.backgroundColor = UIColor.lightText
                sender.setTitleColor(UIColor.white, for: .normal)
                self.hotMode = true
                UserDefaults.standard.set(self.hotMode, forKey: "hotMode")
                
                self.coldModeButton.setTitle("Cold Mode - OFF", for: .normal)
                self.coldModeButton.backgroundColor = UIColor.groupTableViewBackground
                self.coldModeButton.setTitleColor(UIColor.black, for: .normal)
                self.coldMode = false
                UserDefaults.standard.set(self.coldMode, forKey: "coldMode")
                
            }
        
        case self.coldModeButton:
            
            print("Cold mode button")
            
            if coldMode {
                
                sender.setTitle("Cold Mode - OFF", for: .normal)
                sender.backgroundColor = UIColor.groupTableViewBackground
                sender.setTitleColor(UIColor.black, for: .normal)
                self.coldMode = false
                UserDefaults.standard.set(self.coldMode, forKey: "coldMode")
                
                self.hotModeButton.setTitle("Hot Mode - ON", for: .normal)
                self.hotModeButton.backgroundColor = UIColor.lightText
                self.hotModeButton.setTitleColor(UIColor.white, for: .normal)
                self.hotMode = true
                UserDefaults.standard.set(self.hotMode, forKey: "hotMode")
                
            } else {
                
                sender.setTitle("Cold Mode - ON", for: .normal)
                sender.backgroundColor = UIColor.lightText
                sender.setTitleColor(UIColor.white, for: .normal)
                self.coldMode = true
                UserDefaults.standard.set(self.coldMode, forKey: "coldMode")
                
                self.hotModeButton.setTitle("Hot Mode - OFF", for: .normal)
                self.hotModeButton.backgroundColor = UIColor.groupTableViewBackground
                self.hotModeButton.setTitleColor(UIColor.black, for: .normal)
                self.hotMode = false
                UserDefaults.standard.set(self.hotMode, forKey: "hotMode")
                
            }
            
        case self.testnetModeButton:
            
            print("Testnet mode button")
            
            if testnetMode {
                
                sender.setTitle("Testnet Mode - OFF", for: .normal)
                sender.backgroundColor = UIColor.groupTableViewBackground
                sender.setTitleColor(UIColor.black, for: .normal)
                self.testnetMode = false
                UserDefaults.standard.set(self.testnetMode, forKey: "testnetMode")
                
                self.mainnetModeButton.setTitle("Mainnet Mode - ON", for: .normal)
                self.mainnetModeButton.backgroundColor = UIColor.lightText
                self.mainnetModeButton.setTitleColor(UIColor.white, for: .normal)
                self.mainnetMode = true
                UserDefaults.standard.set(self.mainnetMode, forKey: "mainnetMode")
                
            } else {
                
                sender.setTitle("Testnet Mode - ON", for: .normal)
                sender.backgroundColor = UIColor.lightText
                sender.setTitleColor(UIColor.white, for: .normal)
                self.testnetMode = true
                UserDefaults.standard.set(self.testnetMode, forKey: "testnetMode")
                
                self.mainnetModeButton.setTitle("Mainnet Mode - OFF", for: .normal)
                self.mainnetModeButton.backgroundColor = UIColor.groupTableViewBackground
                self.mainnetModeButton.setTitleColor(UIColor.black, for: .normal)
                self.mainnetMode = false
                UserDefaults.standard.set(self.mainnetMode, forKey: "mainnetMode")
                
            }
            
        case self.mainnetModeButton:
            
            print("Mainnet mode button")
            
            if mainnetMode {
                
                sender.setTitle("Mainnet Mode - OFF", for: .normal)
                sender.backgroundColor = UIColor.groupTableViewBackground
                sender.setTitleColor(UIColor.black, for: .normal)
                self.mainnetMode = false
                UserDefaults.standard.set(self.mainnetMode, forKey: "mainnetMode")
                
                self.testnetModeButton.setTitle("Testnet Mode - ON", for: .normal)
                self.testnetModeButton.backgroundColor = UIColor.lightText
                self.testnetModeButton.setTitleColor(UIColor.white, for: .normal)
                self.testnetMode = true
                UserDefaults.standard.set(self.testnetMode, forKey: "testnetMode")
                
            } else {
                
                sender.setTitle("Mainnet Mode - ON", for: .normal)
                sender.backgroundColor = UIColor.lightText
                sender.setTitleColor(UIColor.white, for: .normal)
                self.mainnetMode = true
                UserDefaults.standard.set(self.mainnetMode, forKey: "mainnetMode")
                
                self.testnetModeButton.setTitle("Testnet Mode - OFF", for: .normal)
                self.testnetModeButton.backgroundColor = UIColor.groupTableViewBackground
                self.testnetModeButton.setTitleColor(UIColor.black, for: .normal)
                self.testnetMode = false
                UserDefaults.standard.set(self.testnetMode, forKey: "testnetMode")
                
            }
            
            
            
        
        default:
            break
        }
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }

}
