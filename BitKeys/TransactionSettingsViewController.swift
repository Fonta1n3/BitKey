//
//  TransactionSettingsViewController.swift
//  BitKeys
//
//  Created by Peter on 6/28/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import CoreData

class TransactionSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var settingsArray = [[String:Any]]()
    var backButton = UIButton()
    var high = Bool()
    var medium = Bool()
    var low = Bool()
    var customFee = UInt16()
    var customFeeBool = Bool()
    var BTC = Bool()
    var USD = Bool()
    var EUR = Bool()
    var SAT = Bool()
    var GBP = Bool()
    var sections = [String()]
    var currency = String()
    @IBOutlet var settingsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("TransactionsSettingsTableTableViewController")
        
        settingsTable.delegate = self
        addButtons()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        high = checkTransactionSettingsForKey(keyValue: "high") as! Bool
        medium = checkTransactionSettingsForKey(keyValue: "medium") as! Bool
        low = checkTransactionSettingsForKey(keyValue: "low") as! Bool
        BTC = checkTransactionSettingsForKey(keyValue: "bitcoin") as! Bool
        SAT = checkTransactionSettingsForKey(keyValue: "satoshi") as! Bool
        USD = checkTransactionSettingsForKey(keyValue: "dollar") as! Bool
        GBP = checkTransactionSettingsForKey(keyValue: "pounds") as! Bool
        EUR = checkTransactionSettingsForKey(keyValue: "euro") as! Bool
        customFee = checkTransactionSettingsForKey(keyValue: "customFee") as! UInt16
        
        if customFee != 0 {
            
            customFeeBool = true
            
        } else {
            
            customFeeBool = false
            
        }
        
        sections = ["Currency Preference", "Fee Preference"]
        settingsArray = [["Bitcoin":BTC,"Satoshis":SAT, "US Dollar":USD, "Euro":EUR, "British Pound":GBP], ["High":high, "Medium":medium,"Low":low, "Custom Fee":customFeeBool]]
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sections[section]
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor.white
        (view as! UITableViewHeaderFooterView).textLabel?.textAlignment = .center
        (view as! UITableViewHeaderFooterView).textLabel?.font = UIFont.init(name: "HelveticaNeue", size: 15)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.darkGray
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 70
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        var explanationLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: 60))
        explanationLabel.textColor = UIColor.darkGray
        explanationLabel.numberOfLines = 0
        explanationLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        
        if section == 0 {
            
            explanationLabel.text = "We will remeber the currency you select here so that when you input the amount into your future transactions the amount will automatically be denominated in that currency. We get the exchange rate from \"https://api.coindesk.com/v1/bpi/currentprice.json\". 1 Bitcoin = 100,000,000 Satoshis."
            footerView.addSubview(explanationLabel)
            
            
        } else if section == 1 {
            
            footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
            explanationLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: 60))
            explanationLabel.textColor = UIColor.darkGray
            explanationLabel.numberOfLines = 0
            explanationLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
            explanationLabel.text = "You can either input a custom fee which is denomianted in Satoshis or choose a preference. High preference is designed to get your transaction mined within the next block and is the most expensive, we recommend a low mining fee preference as it usually gets the transaction mined quickly at a reasonable rate and therefore set it as default."
            footerView.addSubview(explanationLabel)
            
        }
        
        return footerView
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionSettingsCell", for: indexPath)
        
        cell.selectionStyle = .none
        
        let dictionary = settingsArray[indexPath.section]
        let key = Array(dictionary.keys)[indexPath.row]
        let value = Array(dictionary.values)[indexPath.row]
        
        if value as! Bool == true {
                
            cell.isSelected = true
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            cell.textLabel?.textColor = UIColor.black
            
        } else {
                
            cell.isSelected = false
            cell.accessoryType = UITableViewCellAccessoryType.none
            cell.textLabel?.textColor = UIColor.lightGray
                
        }
            
        
        cell.textLabel?.text = key
        
        if key.hasPrefix("C") && customFee != 0 {
            
            cell.textLabel?.text = "Custom Fee set to \(String(describing: customFee)) Satoshis"
            
        }
        
        return cell
        
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
                                
                                if (key?.hasPrefix("C"))! {
                                    
                                    self.getCustomFee(cell: cell, index: selectedIndex.section)
                                    
                                } else {
                                  
                                    self.saveSettings(forValue: true, forKey: key!)
                                    self.settingsArray[selectedIndex.section][key!] = true
                                    cell.textLabel?.textColor = UIColor.black
                                    
                                }
                               
                            }
                            
                        } else if selectedIndex.section == section && cell.isSelected {
                            
                            cell.isSelected = false
                            cell.accessoryType = UITableViewCellAccessoryType.none
                            cell.selectionStyle = .none
                            let key = cell.textLabel?.text!
                            
                            if (key?.hasPrefix("C"))! {
                                
                                self.customFee = 0
                                self.saveSettings(forValue: false, forKey: "Custom Fee")
                                cell.textLabel?.text = "Custom Fee"
                                
                            } else {
                                
                               self.saveSettings(forValue: false, forKey: key!)
                                
                            }
                            
                            self.settingsArray[selectedIndex.section][key!] = false
                            cell.textLabel?.textColor = UIColor.lightGray
                            
                            
                        } else if selectedIndex.section == section && cell.isSelected == false {
                            
                            cell.isSelected = false
                            cell.accessoryType = UITableViewCellAccessoryType.none
                            cell.selectionStyle = .none
                            let key = cell.textLabel?.text!
                            
                            if (key?.hasPrefix("C"))! {
                                
                                self.customFee = 0
                                self.saveSettings(forValue: false, forKey: "Custom Fee")
                                cell.textLabel?.text = "Custom Fee"
                                
                            } else {
                                
                                self.saveSettings(forValue: false, forKey: key!)
                                
                            }
                            
                            self.settingsArray[selectedIndex.section][key!] = false
                            cell.textLabel?.textColor = UIColor.lightGray
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        updateTableViewSelections(selectedIndex: indexPath)
        
    }
    
    func getCustomFee(cell: UITableViewCell, index: Int) {
        
        let alert = UIAlertController(title: "Set a mining fee in Satoshis", message: "Please enter your custom mining fee in Satoshis, please make sure you are aware of the risks of setting custom fees, setting too low of a fee may result in a transaction that never gets confirmed.", preferredStyle: .alert)
        
        alert.addTextField { (textField1) in
            
            textField1.placeholder = "Fee in Satoshis"
            textField1.keyboardType = UIKeyboardType.decimalPad
            
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Set Fee", comment: ""), style: .default, handler: { (action) in
            
            let fee = UInt16(alert.textFields![0].text!)
            self.customFee = fee!
            cell.textLabel?.text = "Custom Fee set to \(self.customFee) Satoshis"
            cell.textLabel?.textColor = UIColor.black
            self.settingsArray[index]["Custom Fee"] = true
            self.saveSettings(forValue: true, forKey: "Custom Fee")
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveSettings(forValue: Bool, forKey: String) {
        
        var key = String()
        var value:Any!
        
        if forKey.hasPrefix("C") {
            
            key = "customFee"
            
        }
        
        switch(forKey) {
        case "Bitcoin":key = "bitcoin"
        case "Satoshis":key = "satoshi"
        case "US Dollar":key = "dollar"
        case "Euro":key = "euro"
        case "British Pound":key = "pounds"
        case "High":key = "high"
        case "Medium":key = "medium"
        case "Low":key = "low"
        default: break
        }
        
        switch(key) {
        case "high":value = forValue
        case "medium":value = forValue
        case "low":value = forValue
        case "customFee":value = customFee
        case "bitcoin":value = forValue
        case "satoshi":value = forValue
        case "dollar":value = forValue
        case "euro":value = forValue
        case "pounds":value = forValue
        default: break
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TransactionSettings")
        
        do {
            
            let results = try context.fetch(fetchRequest) as [NSManagedObject]
            
            if results.count > 0 {
                
                for data in results {
                    
                    if let _ = data.value(forKey: key) as? Any {
                        
                        results[0].setValue(value, forKey: key)
                        
                    }
                    
                    do {
                        
                        try context.save()
                        
                    } catch {
                        
                        print("Failed saving")
                        
                    }
                    
                }
                
            } else {
                
                print("no results so create one")
                let entity = NSEntityDescription.entity(forEntityName: "TransactionSettings", in: context)
                let mySettings = NSManagedObject(entity: entity!, insertInto: context)
                mySettings.setValue(value, forKey: key)
                
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

