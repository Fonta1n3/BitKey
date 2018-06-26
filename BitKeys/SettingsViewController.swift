//
//  SettingsViewController.swift
//  BitKeys
//
//  Created by Peter on 5/21/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var settingsTable: UITableView!
    
    var rowSelections = [Int:Int]()
    var backButton = UIButton()
    var segwitMode = Bool()
    var legacyMode = Bool()
    var hotMode = Bool()
    var coldMode = Bool()
    var testnetMode = Bool()
    var mainnetMode = Bool()
    var sections = ["Key Management Setting", "Address Format Settings", "Nework Settings"]
    var settingsArray = [[String:Bool]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("SettingsViewController")
        
        settingsTable.delegate = self
        
        
        
        /*let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        
        do {
           
           let result = try context.execute(request)
            
        } catch {
            
           print("error")
        }*/
   }

    override func viewDidAppear(_ animated: Bool) {
        
        addButtons()
        
        hotMode = checkSettingsForKey(keyValue: "hotMode")
        coldMode = checkSettingsForKey(keyValue: "coldMode")
        legacyMode = checkSettingsForKey(keyValue: "legacyMode")
        segwitMode = checkSettingsForKey(keyValue: "segwitMode")
        mainnetMode = checkSettingsForKey(keyValue: "mainnetMode")
        testnetMode = checkSettingsForKey(keyValue: "testnetMode")
        
        settingsArray = [["Hot Mode":hotMode, "Cold Mode":coldMode], ["Legacy Mode":legacyMode, "Segwit Mode":segwitMode], ["Mainnet Mode":mainnetMode, "Testnet Mode":testnetMode]]
        
        settingsTable.reloadData()
        
    }
    
    func addButtons() {
        
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
        
        return settingsArray.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return settingsArray[section].count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        cell.selectionStyle = .none
        
        let dictionary = settingsArray[indexPath.section]
        let key = Array(dictionary.keys)[indexPath.row]
        let value = Array(dictionary.values)[indexPath.row]
        
        if value == true {
            
            cell.isSelected = true
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            cell.textLabel?.textColor = UIColor.black
            
        } else if value == false {
            
            cell.isSelected = false
            cell.accessoryType = UITableViewCellAccessoryType.none
            cell.textLabel?.textColor = UIColor.lightGray
            
        }
        
        cell.textLabel?.text = key
        
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sections[section]
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        var explanationLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: 60))
        explanationLabel.textColor = UIColor.darkGray
        explanationLabel.numberOfLines = 0
        explanationLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        
        if section == 0 {
            
            explanationLabel.text = "When Hot Mode is enabled all the private keys you create will be saved to your address book enabling effortless spending. In Cold Mode we never save your private key on the device, you will have to scan or type in the private key manually to create the signature for the transaction."
            footerView.addSubview(explanationLabel)
            
            
        } else if section == 1 {
            
            footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
            explanationLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: 60))
            explanationLabel.textColor = UIColor.darkGray
            explanationLabel.numberOfLines = 0
            explanationLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
            explanationLabel.text = "In Segwit mode all the addresses you create for your wallets will be bech32 native segwit addresses. We do not yet support spending from bech32 addresses but are working on it. In legacy mode all addresses produced are legacy addresses."
            footerView.addSubview(explanationLabel)
            
        } else if section == 2 {
            
            footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
            explanationLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: 50))
            explanationLabel.textColor = UIColor.darkGray
            explanationLabel.numberOfLines = 0
            explanationLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
            explanationLabel.text = "In Testnet Mode you have the option to test the app on Bitcoins test network \"Testnet\" or in Mainnet Mode go straight to the real deal Bitcoin network \"Mainnet\"."
            footerView.addSubview(explanationLabel)
            
        }
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 2 {
            
            return 50
        }
        
        return 70
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        func updateTableViewSelections(deselectedIndex: IndexPath) {
            
            for section in 0 ..< tableView.numberOfSections {
                
                for row in 0 ..< tableView.numberOfRows(inSection: section) {
                    
                    if let cell = self.settingsTable.cellForRow(at: IndexPath(row: row, section: section)) {
                        
                        if deselectedIndex.row == row && cell.isSelected {
                            
                            if deselectedIndex.section == section {
                              
                                cell.isSelected = false
                                cell.accessoryType = UITableViewCellAccessoryType.none
                                cell.selectionStyle = .none
                                
                            }
                            
                        } else if deselectedIndex.row == row && cell.isSelected == false {
                            
                            if deselectedIndex.section == section {
                                
                                cell.isSelected = true
                                cell.accessoryType = UITableViewCellAccessoryType.checkmark
                                cell.selectionStyle = .none
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
                
        }
        
        updateTableViewSelections(deselectedIndex: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.allowsMultipleSelection = true
        
        func updateTableViewSelections(selectedIndex: IndexPath) {
            
            for section in 0 ..< tableView.numberOfSections {
                
                for row in 0 ..< tableView.numberOfRows(inSection: section) {
                    
                    if let cell = self.settingsTable.cellForRow(at: IndexPath(row: row, section: section)) {
                        
                        if selectedIndex.row == row && cell.isSelected {
                            
                            if selectedIndex.section == section {
                                
                                cell.isSelected = true
                                cell.accessoryType = UITableViewCellAccessoryType.checkmark
                                cell.selectionStyle = .none
                                let key = cell.textLabel?.text!
                                self.saveSettings(bool: true, forKey: key!)
                                self.settingsArray[selectedIndex.section][key!] = true
                                cell.textLabel?.textColor = UIColor.black
                                
                            }
                            
                        } else if selectedIndex.section == section && cell.isSelected {
                            
                            cell.isSelected = false
                            cell.accessoryType = UITableViewCellAccessoryType.none
                            cell.selectionStyle = .none
                            let key = cell.textLabel?.text!
                            self.saveSettings(bool: false, forKey: key!)
                            self.settingsArray[selectedIndex.section][key!] = false
                            cell.textLabel?.textColor = UIColor.lightGray

                            
                        } else if selectedIndex.section == section && cell.isSelected == false {
                            
                            cell.isSelected = false
                            cell.accessoryType = UITableViewCellAccessoryType.none
                            cell.selectionStyle = .none
                            let key = cell.textLabel?.text!
                            self.saveSettings(bool: false, forKey: key!)
                            self.settingsArray[selectedIndex.section][key!] = false
                            cell.textLabel?.textColor = UIColor.lightGray

                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        updateTableViewSelections(selectedIndex: indexPath)
        
    }
    
    func saveSettings(bool: Bool, forKey: String) {
        
        var key = String()
        
        switch(forKey) {
        case "Hot Mode":key = "hotMode"
        case "Cold Mode":key = "coldMode"
        case "Segwit Mode":key = "segwitMode"
        case "Legacy Mode":key = "legacyMode"
        case "Mainnet Mode":key = "mainnetMode"
        case "Testnet Mode":key = "testnetMode"
        default: break
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Settings")
        
        do {
            
            let results = try context.fetch(fetchRequest) as [NSManagedObject]
            
            if results.count > 0 {
                    
                for data in results {
                        
                    if let _ = data.value(forKey: key) as? Bool {
                            
                        results[0].setValue(bool, forKey: key)
                        
                    } else {
                            
                        data.setValue(bool, forKey: key)
                            
                    }
                        
                    do {
                            
                        try context.save()
                        
                    } catch {
                            
                        print("Failed saving")
                            
                    }
                        
                }
                    
            } else {
                    
                print("no results so create one")
                let entity = NSEntityDescription.entity(forEntityName: "Settings", in: context)
                let mySettings = NSManagedObject(entity: entity!, insertInto: context)
                mySettings.setValue(bool, forKey: key)
                    
                do {
                        
                    try context.save()
                    
                } catch {
                        
                    print("Failed saving")
                        
                    }
                    
                }
                
            } catch {
            
            print("Failed")
            
        }
        
   }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }

}
