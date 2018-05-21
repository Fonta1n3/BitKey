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
    var watchOnlyButton = UIButton()
    var simpleModeButton = UIButton()
    var advancedModeButton = UIButton()
    
    var segwitMode = Bool()
    var legacyMode = Bool()
    var simpleMode = Bool()
    var advancedMode = Bool()
    var watchOnlyMode = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("SettingsViewController")
        
        //checkUserDefaults()
        //addButtons()
        
        
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
        
        if UserDefaults.standard.object(forKey: "advancedMode") != nil {
            
            advancedMode = UserDefaults.standard.object(forKey: "advancedMode") as! Bool
            
        } else {
            
            advancedMode = true
            
        }
        
        if UserDefaults.standard.object(forKey: "simpleMode") != nil {
            
            simpleMode = UserDefaults.standard.object(forKey: "simpleMode") as! Bool
            
        } else {
            
            simpleMode = false
            
        }
        
        if UserDefaults.standard.object(forKey: "watchMode") != nil {
            
            watchOnlyMode = UserDefaults.standard.object(forKey: "watchMode") as! Bool
            
        } else {
            
            watchOnlyMode = true
            
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
            
            self.segwitButton.removeFromSuperview()
            
            self.segwitButton = UIButton(frame: CGRect(x: 10, y: 100, width: self.view.frame.width - 20, height: 50))
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
            
            self.legacyButton = UIButton(frame: CGRect(x: 10, y: 155, width: self.view.frame.width - 20, height: 50))
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
             
            self.watchOnlyButton.removeFromSuperview()
            
            self.watchOnlyButton = UIButton(frame: CGRect(x: 10, y: 210, width: self.view.frame.width - 20, height: 50))
            self.watchOnlyButton.showsTouchWhenHighlighted = true
            self.watchOnlyButton.layer.cornerRadius = 10
            self.watchOnlyButton.layer.shadowColor = UIColor.black.cgColor
            self.watchOnlyButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            self.watchOnlyButton.layer.shadowRadius = 2.5
            self.watchOnlyButton.layer.shadowOpacity = 0.8
            self.watchOnlyButton.addTarget(self, action: #selector(self.goTo(sender:)), for: .touchUpInside)
            
            if self.watchOnlyMode {
                
                self.watchOnlyButton.backgroundColor = UIColor.lightText
                self.watchOnlyButton.setTitle("Watch Only Mode - ON", for: .normal)
                
            } else {
                
                self.watchOnlyButton.backgroundColor = UIColor.groupTableViewBackground
                self.watchOnlyButton.setTitleColor(UIColor.black, for: .normal)
                self.watchOnlyButton.setTitle("Watch Only Mode - OFF", for: .normal)
                
            }
            
            self.view.addSubview(self.watchOnlyButton)
             
            self.simpleModeButton.removeFromSuperview()
            
            self.simpleModeButton = UIButton(frame: CGRect(x: 10, y: 265, width: self.view.frame.width - 20, height: 50))
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
                
            } else {
                
                self.simpleModeButton.backgroundColor = UIColor.groupTableViewBackground
                self.simpleModeButton.setTitleColor(UIColor.black, for: .normal)
                self.simpleModeButton.setTitle("Simple Mode - OFF", for: .normal)
                
            }
            
            self.view.addSubview(self.simpleModeButton)
            
            
            self.advancedModeButton.removeFromSuperview()
            
            self.advancedModeButton = UIButton(frame: CGRect(x: 10, y: 320, width: self.view.frame.width - 20, height: 50))
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
                
            }
            
            self.view.addSubview(self.advancedModeButton)
             
            
             
        }
        
    }
    
   @objc func goTo(sender: UIButton) {
    
        print("goTo")
        
        switch sender {
            
        case self.backButton:
            
            print("back button")
            self.dismiss(animated: false, completion: nil)
            
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
            
        case self.simpleModeButton:
            
            print("simple mode button")
            
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
                
            }
        
        case self.advancedModeButton:
            
            print("advanced mode button")
            
            if advancedMode {
                
                sender.setTitle("Advanced Mode - OFF", for: .normal)
                sender.backgroundColor = UIColor.groupTableViewBackground
                sender.setTitleColor(UIColor.black, for: .normal)
                self.advancedMode = false
                UserDefaults.standard.set(self.advancedMode, forKey: "advancedMode")
                
                self.simpleModeButton.setTitle("Simple Mode - ON", for: .normal)
                self.simpleModeButton.backgroundColor = UIColor.lightText
                self.simpleModeButton.setTitleColor(UIColor.white, for: .normal)
                self.simpleMode = true
                UserDefaults.standard.set(self.simpleMode, forKey: "simpleMode")
                
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
                
            }
            
            
        case self.watchOnlyButton:
            
            print("watch only button")
            
            if watchOnlyMode {
                
                sender.setTitle("Watch Only Mode - OFF", for: .normal)
                sender.backgroundColor = UIColor.groupTableViewBackground
                sender.setTitleColor(UIColor.black, for: .normal)
                self.watchOnlyMode = false
                UserDefaults.standard.set(self.watchOnlyMode, forKey: "watchMode")
                
            } else {
                
                sender.setTitle("Watch Only Mode - ON", for: .normal)
                sender.backgroundColor = UIColor.lightText
                sender.setTitleColor(UIColor.white, for: .normal)
                self.watchOnlyMode = true
                UserDefaults.standard.set(self.watchOnlyMode, forKey: "watchMode")
                
            }
            
        default:
            break
        }
        
    }

}
