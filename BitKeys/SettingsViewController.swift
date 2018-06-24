//
//  SettingsViewController.swift
//  BitKeys
//
//  Created by Peter on 5/21/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var settingsTable: UITableView!
    
    var backButton = UIButton()
    var segwitMode = Bool()
    var legacyMode = Bool()
    var hotMode = Bool()
    var coldMode = Bool()
    var testnetMode = Bool()
    var mainnetMode = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()

        print("SettingsViewController")
        
        settingsTable.delegate = self
        
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        getUserDefaults()
        addButtons()
        settingsTable.reloadData()
    }
    
    func getUserDefaults() {
        
        print("checkUserDefaults")
        
        coldMode = UserDefaults.standard.object(forKey: "coldMode") as! Bool
        hotMode = UserDefaults.standard.object(forKey: "hotMode") as! Bool
        legacyMode = UserDefaults.standard.object(forKey: "legacyMode") as! Bool
        segwitMode = UserDefaults.standard.object(forKey: "segwitMode") as! Bool
        testnetMode = UserDefaults.standard.object(forKey: "testnetMode") as! Bool
        mainnetMode = UserDefaults.standard.object(forKey: "mainnetMode") as! Bool
        
    }
 
    func addButtons() {
        
        print("addButtons")
        
        DispatchQueue.main.async {
            
            self.backButton.removeFromSuperview()
            self.backButton = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
            self.backButton.showsTouchWhenHighlighted = true
            self.backButton.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
            self.backButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
            self.view.addSubview(self.backButton)
            
        }
        
    }
    
    @objc func goBack() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                cell.textLabel?.text = "Hot Mode"
                
                if self.hotMode {
                    
                    cell.isSelected = true
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    
                } else if self.hotMode == false {
                    
                    cell.isSelected = false
                    cell.accessoryType = UITableViewCellAccessoryType.none
                    
                }
                
            } else if indexPath.row == 1 {
                
                cell.textLabel?.text = "Cold Mode"
                
                if self.coldMode {
                    
                    cell.isSelected = true
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    
                } else if self.coldMode == false {
                    
                    cell.isSelected = false
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
                
            }
            
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                
                cell.textLabel?.text = "Legacy Mode"
                
                if self.legacyMode {
                    
                    cell.isSelected = true
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    
                } else if self.legacyMode == false {
                    
                    cell.isSelected = false
                    cell.accessoryType = UITableViewCellAccessoryType.none
                    
                }
                
            } else if indexPath.row == 1 {
                
                cell.textLabel?.text = "Segwit Mode"
                
                if self.segwitMode {
                    
                    cell.isSelected = true
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    
                } else if self.segwitMode == false {
                    
                    cell.isSelected = false
                    cell.accessoryType = UITableViewCellAccessoryType.none
                    
                }
                
            }
            
        } else if indexPath.section == 2 {
            
            if indexPath.row == 0 {
                
                cell.textLabel?.text = "Mainnet Mode"
                
                if self.mainnetMode {
                    
                    cell.isSelected = true
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    
                } else if self.mainnetMode == false {
                    
                    cell.isSelected = false
                    cell.accessoryType = UITableViewCellAccessoryType.none
                    
                }
                
            } else if indexPath.row == 1 {
                
                cell.textLabel?.text = "Testnet Mode"
                
                if self.testnetMode {
                    
                    cell.isSelected = true
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    
                } else if self.testnetMode == false {
                    
                    cell.isSelected = false
                    cell.accessoryType = UITableViewCellAccessoryType.none
                    
                }
                
            }
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            
            return "Key Management Settings"
            
        } else if section == 1 {
            
            return "Address Format Settings"
            
        } else if section == 2 {
            
            return "Network Settings"
            
        }
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)!
        
        if indexPath.section == 0 {
          
            //"Hot Mode"
            if indexPath.row == 0 {
                
                if cell.isSelected {
                    
                    cell.isSelected = false
                    
                    if cell.accessoryType == UITableViewCellAccessoryType.none {
                        
                        cell.accessoryType = UITableViewCellAccessoryType.checkmark
                        
                        self.hotMode = true
                        self.coldMode = false
                        
                    } else {
                        
                        cell.accessoryType = UITableViewCellAccessoryType.none
                        
                        self.hotMode = false
                        self.coldMode = true
                        
                    }
                    
                }
                //Cold Mode
            } else if indexPath.row == 1 {
                
                if cell.isSelected {
                    
                    cell.isSelected = false
                    
                    if cell.accessoryType == UITableViewCellAccessoryType.none {
                        
                        cell.accessoryType = UITableViewCellAccessoryType.checkmark
                        
                        self.coldMode = true
                        self.hotMode = false
                        
                    } else {
                        
                        cell.accessoryType = UITableViewCellAccessoryType.none
                        
                        self.coldMode = false
                        self.hotMode = true
                        
                    }
                    
                }
                
            }
            
            UserDefaults.standard.synchronize()
            self.settingsTable.reloadData()
            
        } else if indexPath.section == 1 {
            
            //"Legacy Mode"
            if indexPath.row == 0 {
                
                if cell.isSelected {
                    
                    cell.isSelected = false
                    
                    if cell.accessoryType == UITableViewCellAccessoryType.none {
                        
                        cell.accessoryType = UITableViewCellAccessoryType.checkmark
                        
                        self.legacyMode = true
                        self.segwitMode = false
                        
                    } else {
                        
                        cell.accessoryType = UITableViewCellAccessoryType.none
                        
                        self.legacyMode = false
                        self.segwitMode = true
                        
                    }
                    
                }
                
                //segwit mode
            } else if indexPath.row == 1 {
                
                if cell.isSelected {
                    
                    cell.isSelected = false
                    
                    if cell.accessoryType == UITableViewCellAccessoryType.none {
                        
                        cell.accessoryType = UITableViewCellAccessoryType.checkmark
                        
                        self.segwitMode = true
                        self.legacyMode = false
                        
                    } else {
                        
                        cell.accessoryType = UITableViewCellAccessoryType.none
                        
                        self.segwitMode = false
                        self.legacyMode = true
                        
                    }
                    
                }
                
            }
            UserDefaults.standard.synchronize()
            self.settingsTable.reloadData()
                
        } else if indexPath.section == 2 {
                
                //mainnet mode
                if indexPath.row == 0 {
                    
                    if cell.isSelected {
                        
                        cell.isSelected = false
                        
                        if cell.accessoryType == UITableViewCellAccessoryType.none {
                            
                            cell.accessoryType = UITableViewCellAccessoryType.checkmark
                            
                            self.mainnetMode = true
                            self.testnetMode = false
                            
                        } else {
                            
                            cell.accessoryType = UITableViewCellAccessoryType.none
                            
                            self.mainnetMode = false
                            self.testnetMode = true
                            
                        }
                        
                    }
                    
                    //testnet mode
                } else if indexPath.row == 1 {
                    
                    if cell.isSelected {
                        
                        cell.isSelected = false
                        
                        if cell.accessoryType == UITableViewCellAccessoryType.none {
                            
                            cell.accessoryType = UITableViewCellAccessoryType.checkmark
                            
                            self.testnetMode = true
                            self.mainnetMode = false
                            
                        } else {
                            
                            cell.accessoryType = UITableViewCellAccessoryType.none
                            
                            self.testnetMode = false
                            self.mainnetMode = true
                            
                        }
                        
                    }
                    
                }
            
            UserDefaults.standard.set(self.testnetMode, forKey: "testnetMode")
            UserDefaults.standard.set(self.mainnetMode, forKey: "mainnetMode")
            UserDefaults.standard.set(self.segwitMode, forKey: "segwitMode")
            UserDefaults.standard.set(self.legacyMode, forKey: "legacyMode")
            UserDefaults.standard.set(self.coldMode, forKey: "coldMode")
            UserDefaults.standard.set(self.hotMode, forKey: "hotMode")
            UserDefaults.standard.synchronize()
            self.settingsTable.reloadData()

            }
            
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }

}
