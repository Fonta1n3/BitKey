//
//  SecuritySettingsViewController.swift
//  BitKeys
//
//  Created by Peter on 6/29/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import LocalAuthentication

class SecuritySettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var securitySettingsTable: UITableView!
    var securityArray = [[String:Bool]]()
    var backButton = UIButton()
    var sections = [String()]
    var isBIP39PasswordSet = Bool()
    var isEncryptionPasswordSet = Bool()
    var isBiometricsEnabled = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        securitySettingsTable.delegate = self
        addButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ = KeychainWrapper.standard.string(forKey: "BIP39Password") {
            
            isBIP39PasswordSet = true
            
        } else {
            
            isBIP39PasswordSet = false
            
        }
        
        if UserDefaults.standard.object(forKey: "bioMetricsEnabled") != nil {
            
            isBiometricsEnabled = true
            
        }
        
        if let _ = KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
            
            isEncryptionPasswordSet = true
            
        } else {
            
            isEncryptionPasswordSet = false
            
        }
        
        sections = ["BIP39 Password", "Encryption Management", "Secure Backup"]
        securityArray = [["Set BIP39 Password":isBIP39PasswordSet], ["Enable Biometrics":isBiometricsEnabled, "Set Lock/Unlock Password":isEncryptionPasswordSet], ["Create Backup":Bool()]]
        securitySettingsTable.reloadData()
        
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
        
        return securityArray.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return securityArray[section].count
        
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
        
        if section == 0 {
            
            return 90
            
        }
        
        return 70
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        var explanationLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: 60))
        explanationLabel.textColor = UIColor.darkGray
        footerView.backgroundColor = UIColor.white
        explanationLabel.backgroundColor = UIColor.white
        explanationLabel.numberOfLines = 0
        explanationLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        
        if section == 0 {
            
            footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 90))
            explanationLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: 90))
            explanationLabel.textColor = UIColor.darkGray
            explanationLabel.numberOfLines = 0
            explanationLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
            footerView.backgroundColor = UIColor.white
            explanationLabel.backgroundColor = UIColor.white
            
            explanationLabel.text = "A BIP39 password is used to create a dual factor recovery phrase, meaning you will need to type in the BIP39 password along with your recovery phrase in order to restore your Bitcoin. If you do not create a BIP39 password then you will not need to input a password along with your recovery phrase to recover your Bitcoin. A dual factor recovery phrase is highly recommended as even if someone finds your recovery phrase they won't have access to your Bitcoin unless they also know your BIP39 password."
            footerView.addSubview(explanationLabel)
            
            
        } else if section == 1 {
            
            explanationLabel.text = "If Biometric is enabled then when it comes time to unlock your wallet or spend Bitcoin you will be able to either use Touch ID or the face scanner to lock/unlock your wallet instead of the password you created."
            footerView.addSubview(explanationLabel)
            
        } else if section == 2 {
            
            explanationLabel.text = "You can either input a custom fee which is denomianted in Satoshis or choose a preference. High preference is designed to get your transaction mined within the next block and is the most expensive, we recommend a low mining fee preference as it usually gets the transaction mined quickly at a reasonable rate and therefore set it as default."
            footerView.addSubview(explanationLabel)
            
        }
        
        return footerView
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "securityCell", for: indexPath)
        
        cell.selectionStyle = .none
        
        let dictionary = securityArray[indexPath.section]
        var key = Array(dictionary.keys)[indexPath.row]
        let value = Array(dictionary.values)[indexPath.row]
        
        if indexPath.section == 0 {
            
            if key == "Set BIP39 Password" {
            
                if isBIP39PasswordSet {
                    
                    key = "Reset BIP39 Password"
                    
                }
                
                cell.textLabel?.textColor = UIColor.blue
                
            }
            
        }
        
        if indexPath.section == 1 {
            
            if key == "Set Lock/Unlock Password" {
                
                if isEncryptionPasswordSet {
                    
                    key = "Reset Lock/Unlock Password"
                    
                } else {
                    
                    key = "Set Lock/Unlock Password"
                }
                
                cell.textLabel?.textColor = UIColor.blue
                
            }
            
        }
        
        if key == "Enable Biometrics" {
            
            if indexPath.section == 1 && value == true {
                
                cell.isSelected = true
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
                cell.textLabel?.textColor = UIColor.black
                key = "Biometrics On"
                
            } else if indexPath.section == 1 && value == false {
                
                cell.isSelected = false
                cell.accessoryType = UITableViewCellAccessoryType.none
                cell.textLabel?.textColor = UIColor.lightGray
                key = "Biometrics Off"
                
            }
            
        }
        
        if indexPath.section == 2 {
            
            cell.textLabel?.textColor = UIColor.blue
            
        }
        
        cell.textLabel?.text = key
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.allowsMultipleSelection = true
        
        if let cell = self.securitySettingsTable.cellForRow(at: indexPath) {
            
            let dictionary = securityArray[indexPath.section]
            let key = Array(dictionary.keys)[indexPath.row]
            
            if indexPath.section == 0 {
                
                if key == "Set BIP39 Password" {
                    
                    if isBIP39PasswordSet {
                        
                        //reset it
                        self.setBIP39Password()
                        
                    } else {
                        
                        //set it
                        self.setBIP39Password()
                        
                    }
                    
                }
            
            } else if indexPath.section == 1 {
                
                if cell.isSelected {
                    
                    cell.isSelected = false
                    
                    if cell.accessoryType == UITableViewCellAccessoryType.none {
                        
                        if key == "Enable Biometrics" {
                            
                            self.authenticationWithTouchID()
                            
                        }
                        
                    } else {
                        
                        if key == "Enable Biometrics" {
                            
                            cell.accessoryType = UITableViewCellAccessoryType.none
                            cell.textLabel?.textColor = UIColor.lightGray
                            cell.textLabel?.text = "Biometrics Off"
                            UserDefaults.standard.removeObject(forKey: "bioMetricsEnabled")
                            self.isBiometricsEnabled = false
                            
                        }
                        
                    }
                    
                }
                
                if key == "Set Lock/Unlock Password" {
                    
                    if isEncryptionPasswordSet {
                        
                        self.setLockUnlockPassword()
                        
                    } else {
                        
                        self.setLockUnlockPassword()
                        
                    }
                    
                }
                
            } else if indexPath.section == 2 {
                
                
            }
            
        }
        
    }
    
    func setLockUnlockPassword() {
        
        DispatchQueue.main.async {
            func setPassword() {
                
                var firstPassword = String()
                var secondPassword = String()
                
                let alert = UIAlertController(title: "Protect your wallet by setting a password that locks and unlocks it.", message: "Please do not forget this password, and make sure your Bitcoin recovery phrases are backed up, if you lose the password and have no back ups you will lose your Bitcoin.", preferredStyle: .alert)
                
                alert.addTextField { (textField1) in
                    
                    textField1.placeholder = "Add Password"
                    textField1.isSecureTextEntry = true
                    
                }
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .destructive, handler: { (action) in
                    
                    firstPassword = alert.textFields![0].text!
                    
                    let confirmationAlert = UIAlertController(title: "Confirm Password", message: "Please input your password again to make sure there were no typos.", preferredStyle: .alert)
                    
                    confirmationAlert.addTextField { (textField1) in
                        
                        textField1.placeholder = "Confirm Password"
                        textField1.isSecureTextEntry = true
                        
                    }
                    
                    confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: { (action) in
                        
                        secondPassword = confirmationAlert.textFields![0].text!
                        
                        if firstPassword == secondPassword {
                            
                            let saveSuccessful:Bool = KeychainWrapper.standard.set(secondPassword, forKey: "unlockAESPassword")
                            
                            if saveSuccessful {
                                
                                let retrievedPassword: String? = KeychainWrapper.standard.string(forKey: "unlockAESPassword")
                                print("unlockAESPassword is: \(retrievedPassword!)")
                                
                                self.isEncryptionPasswordSet = true
                                self.securitySettingsTable.reloadData()
                                
                                displayAlert(viewController: self, title: "Success", message: "You have set your locking/unlocking password.")
                                
                            } else {
                                
                                displayAlert(viewController: self, title: "Error", message: "Unable to save password to keychain, please try again.")
                                
                            }
                            
                        } else {
                            
                            displayAlert(viewController: self, title: "Error", message: "Passwords did not match please start over.")
                            
                        }
                        
                    }))
                    
                    confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                        
                        
                    }))
                    
                    self.present(confirmationAlert, animated: true, completion: nil)
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                    
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
            if KeychainWrapper.standard.string(forKey: "unlockAESPassword") != nil {
                
                var password = String()
                
                let alert = UIAlertController(title: "Please input your old password", message: "Please enter your exisiting password to reset it.", preferredStyle: .alert)
                
                alert.addTextField { (textField1) in
                    
                    textField1.placeholder = "Enter Password"
                    textField1.isSecureTextEntry = true
                    
                }
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Unlock", comment: ""), style: .destructive, handler: { (action) in
                    
                    password = alert.textFields![0].text!
                    
                    if password == KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
                        
                        setPassword()
                        
                    } else {
                        
                        displayAlert(viewController: self, title: "Error", message: "Incorrect password!")
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                    
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                setPassword()
                
            }
        }
        
    }
    
    
    func setBIP39Password() {
        
        DispatchQueue.main.async {
            var firstPassword = String()
            var secondPassword = String()
            
            let alert = UIAlertController(title: "BIP39 Password", message: "Please create a BIP39 password, this will require you to remember your password along with your recovery phrase to import your Bitcoin, this is fully compatible with all BIP39 wallets.", preferredStyle: .alert)
            
            alert.addTextField { (textField1) in
                
                textField1.placeholder = "Add Password"
                textField1.isSecureTextEntry = true
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .destructive, handler: { (action) in
                
                firstPassword = alert.textFields![0].text!
                
                let confirmationAlert = UIAlertController(title: "Confirm Password", message: "Please input your password again to make sure there were no typos.", preferredStyle: .alert)
                
                confirmationAlert.addTextField { (textField1) in
                    
                    textField1.placeholder = "Confirm Password"
                    textField1.isSecureTextEntry = true
                    
                }
                
                confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: { (action) in
                    
                    secondPassword = confirmationAlert.textFields![0].text!
                    
                    if firstPassword == secondPassword {
                        
                        KeychainWrapper.standard.removeObject(forKey: "BIP39Password")
                        
                        let saveSuccessful:Bool = KeychainWrapper.standard.set(firstPassword, forKey: "BIP39Password")
                        
                        if saveSuccessful {
                            
                            let retrievedPassword: String? = KeychainWrapper.standard.string(forKey: "BIP39Password")
                            print("BIP39Password is: \(retrievedPassword!)")
                            
                            displayAlert(viewController: self, title: "Success", message: "You have succesfully added a password that will be used when creating all your future wallets, please ensure you don't forget as you will need it along with your recovery phrase to recover your Bitcoin.")
                            
                            self.isBIP39PasswordSet = true
                            self.securitySettingsTable.reloadData()
                            
                        } else {
                            
                            displayAlert(viewController: self, title: "Error", message: "Unable to save the password! Please try again.")
                            
                        }
                        
                    } else {
                        
                        displayAlert(viewController: self, title: "Error", message: "Passwords did not match please start over.")
                        
                    }
                    
                }))
                
                confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                    
                    
                }))
                
                self.present(confirmationAlert, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func savePasswordtoKeychain(password: String, forKey: String) {
        
        if password != "" {
            
            let saveSuccessful:Bool = KeychainWrapper.standard.set(password, forKey: forKey)
            print("Save was successful: \(saveSuccessful)")
            
        }
        
    }
    
    func getPassword(forKey: String) {
        
        let retrievedPassword: String? = KeychainWrapper.standard.string(forKey: forKey)
        print("Retrieved passwork is: \(retrievedPassword!)")
        
    }
    
    func deletePassword(forKey: String) {
        
        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: forKey)
        print("Delete was successful: \(removeSuccessful)")
        
    }
    
    func authenticationWithTouchID() {
        
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
        
        var authError: NSError?
        let reasonString = "To Lock and Unlock the Wallet"
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    //TODO: User authenticated successfully, take appropriate action
                    
                    if UserDefaults.standard.object(forKey: "bioMetricsEnabled") != nil {
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            
                            UserDefaults.standard.set(true, forKey: "bioMetricsEnabled")
                            let cell = self.securitySettingsTable.cellForRow(at: IndexPath(row: 1, section: 1))!
                            cell.accessoryType = UITableViewCellAccessoryType.checkmark
                            cell.textLabel?.textColor = UIColor.black
                            cell.textLabel?.text = "Biometrics On"
                            self.isBiometricsEnabled = true
                            
                            displayAlert(viewController: self, title: "Success", message: "You can now lock and unlock your wallet with biometrics")
                            
                        }
                        
                        
                    }
                    
                    
                    
                } else {
                    //TODO: User did not authenticate successfully, look at error and take appropriate action
                    guard let error = evaluateError else {
                        return
                    }
                    
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    
                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                    
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
        }
    }
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
                
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
            default:
                message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."
                
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"
                
            default:
                message = "Did not find error code on LAError object"
            }
        }
        
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }

}
