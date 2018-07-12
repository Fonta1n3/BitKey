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
import CoreData
import AVFoundation
import AES256CBC

class SecuritySettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var uploadButton = UIButton()
    let imagePicker = UIImagePickerController()
    var segwitMode = Bool()
    var legacyMode = Bool()
    var segwit = SegwitAddrCoder()
    var textInput = UITextField()
    var qrImageView = UIView()
    var stringURL = String()
    let avCaptureSession = AVCaptureSession()
    let importView = UIView()
    @IBOutlet var securitySettingsTable: UITableView!
    var securityArray = [[String:Bool]]()
    var backButton = UIButton()
    var sections = [String()]
    var isBIP39PasswordSet = Bool()
    var isEncryptionPasswordSet = Bool()
    var isBiometricsEnabled = Bool()
    var createBackupBool = Bool()
    var filenames = [String]()
    var changeBIP39password = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        securitySettingsTable.delegate = self
        addButtons()
        
   }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        textInput.resignFirstResponder()
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
        securityArray = [["Set BIP39 Password":isBIP39PasswordSet], ["Enable Biometrics":isBiometricsEnabled, "Set Lock/Unlock Password":isEncryptionPasswordSet], ["Create Backup":Bool(), "Restore From Backup":Bool()]]
        securitySettingsTable.reloadData()
        
        segwitMode = checkSettingsForKey(keyValue: "segwitMode")
        legacyMode = checkSettingsForKey(keyValue: "legacyMode")
        
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
            
        } else if section == 2 {
            
            return 110
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
            
            explanationLabel.text = "A BIP39 password is used to create a dual factor recovery phrase, meaning you will need to type in the BIP39 password along with your recovery phrase in order to restore your Bitcoin. A dual factor recovery phrase is highly recommended as even if someone finds your recovery phrase they won't have access to your Bitcoin unless they also know your BIP39 password."
            footerView.addSubview(explanationLabel)
            
            
        } else if section == 1 {
            
            explanationLabel.text = "If Biometric is enabled then when it comes time to unlock your wallet or spend Bitcoin you will be able to either use Touch ID or the face scanner to lock/unlock your wallet instead of the password you created."
            footerView.addSubview(explanationLabel)
            
        } else if section == 2 {
            
            footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 110))
            explanationLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: 100))
            explanationLabel.textColor = UIColor.darkGray
            explanationLabel.numberOfLines = 0
            explanationLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
            footerView.backgroundColor = UIColor.white
            explanationLabel.backgroundColor = UIColor.white
            
            explanationLabel.text = "Creating a back up will save your encrpyted private keys as QR Codes in a photo album called \"BitSense\". You will need to write down the encyrption key to restore your back up incase you lose this device. To restore the back up just tap the restore button here, then input the password (only if your on a different device) and scan each encrypted QR Code, remember if your using the same device you will NOT need to input the password even if you deleted and reinstalled BitSense."
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
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        tableView.allowsMultipleSelection = true
        
        if let cell = self.securitySettingsTable.cellForRow(at: indexPath) {
            
            let dictionary = securityArray[indexPath.section]
            let key = Array(dictionary.keys)[indexPath.row]
            
            if key == "Create Backup" {
                
               self.authorizeBackUpCreation()
                
            } else if key == "Restore From Backup" {
                
                self.importWallet()
                
            }
            
            if indexPath.section == 0 {
                
                if key == "Set BIP39 Password" {
                    
                    if isBIP39PasswordSet {
                        
                        self.setBIP39Password()
                        
                    } else {
                        
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
    
    func authorizeBackUpCreation() {
        
        print("authorizeBackUpCreation")
        
        if UserDefaults.standard.object(forKey: "bioMetricsEnabled") != nil {
            
            createBackupBool = true
            self.authenticationWithTouchID()
        
        } else if KeychainWrapper.standard.string(forKey: "unlockAESPassword") != nil {
            
            var password = String()
            
            let alert = UIAlertController(title: "Please input your password", message: "Please enter your password to create a backup", preferredStyle: .alert)
            
            alert.addTextField { (textField1) in
                
                textField1.placeholder = "Enter Password"
                textField1.isSecureTextEntry = true
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Continue", comment: ""), style: .default, handler: { (action) in
                
                password = alert.textFields![0].text!
                
                if password == KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
                    
                    self.giveUserEncryptionPassword()
                    
                } else {
                    
                    displayAlert(viewController: self, title: "Error", message: "Incorrect password!")
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            self.authorizeBackUpCreation()
            
        }
    }
    
    func addAlertForShare(keysToBackUp: [String]) {
        
        
        var qrCodeImages = [UIImage]()
        //var filenames = [String]()
        
        var overFirstSave = false
        
        for (index, key) in keysToBackUp.enumerated() {
            
            let ciContext = CIContext()
            let data = key.data(using: String.Encoding.ascii)
            var qrCodeImage = UIImage()
            
            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let upScaledImage = filter.outputImage?.transformed(by: transform)
                let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
                qrCodeImage = UIImage(cgImage: cgImage!)
                qrCodeImages.append(qrCodeImage)
                //filenames.append("\(self.filenames[index])")
                
                if let data = UIImagePNGRepresentation(qrCodeImage) {
                    
                    let fileName = getDocumentsDirectory().appendingPathComponent("\(self.filenames[index])" + ".png")
                    
                    try? data.write(to: fileName)
                    
                    do {
                        
                        if !overFirstSave {
                            
                            CustomPhotoAlbum.shared.save(image: UIImage(contentsOfFile: fileName.path)!)
                            overFirstSave = true
                            
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                
                                CustomPhotoAlbum.shared.save(image: UIImage(contentsOfFile: fileName.path)!)
                                
                            })
                            
                        }
                        
                    } catch {
                        
                        print(error)
                        
                    }
                    
                }
                
            }
            
        }

        
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: "Back Up Created", message: "Please check your photo albums and you will see a new album called \"BitSense\".\n\nThese QR codes are your encrypted back up, each QR Code is an encrypted Private Key from your wallet.\n\nIn order to restore them you will need to tap the \"Restore From Back Up\" button in your security settings and then scan each QR Code and input the \"Back Up Password\" we just gave you.\n\nIf you are Restoring a back up from the same device and have not deleted the app since you created the back up, you will not be forced to input the password.\n\nIf you have any questions please contact us at f0nta1n3@protonmail.com", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                    
                    
                }))
                
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
    }
    
    func getKeys() -> [String] {
        
        var keyArray = [String]()
        var appDelegate = AppDelegate()
        
        if let appDelegateCheck = UIApplication.shared.delegate as? AppDelegate {
            
            appDelegate = appDelegateCheck
            
        } else {
            
            displayAlert(viewController: self, title: "Error", message: "Something strange has happened and we do not have access to app delegate, please try again.")
            
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AddressBook")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(fetchRequest) as [NSManagedObject]
            
            if results.count > 0 {
                
                for data in results {
                    
                    if let privateKeyCheck = data.value(forKey: "privateKey") as? String {
                        
                        if privateKeyCheck != "" {
                            
                           keyArray.append(privateKeyCheck)
                            
                            if data.value(forKey: "label") as? String != "" {
                                
                                self.filenames.append(data.value(forKey: "label") as! String)
                                
                            } else {
                                
                                self.filenames.append(data.value(forKey: "address") as! String)
                            }
                            
                        }
                        
                   }
                    
                    
                    
                }
                
            } else {
                
                print("no results")
                
            }
            
        } catch {
            
            print("Failed")
            
        }
        
        return keyArray
        
    }
    
    func giveUserEncryptionPassword() {
        
        let encryptionPassword = KeychainWrapper.standard.string(forKey: "AESPassword")!
        
        print("encryptionPassword = \(encryptionPassword)")
        
        let alert = UIAlertController(title: "Write this Back Up password down you will need it!\n\n\(String(describing: encryptionPassword))\n\n(all letters are lower case)", message: "Keep this Back Up password safe as your back up will be totally useless without it if you were to lose your device or delete the app.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Continue", comment: ""), style: .default, handler: { (action) in
            
            self.confirmEncryptionKeyForBackUp()
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func confirmEncryptionKeyForBackUp() {
        
        UIPasteboard.general.string = ""
        let encryptionPassword = KeychainWrapper.standard.string(forKey: "AESPassword")!
        var secondPassword = String()
        
        let alert = UIAlertController(title: "Input Back Up password to Proceed", message: "Please input the password we just gave you to proceed, you should have written it down, if you didn't you will need to start over.", preferredStyle: .alert)
        
        alert.addTextField { (textField1) in
            
            textField1.placeholder = "Back Up Password"
            textField1.isSecureTextEntry = true
            
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: { (action) in
            
            secondPassword = alert.textFields![0].text!
            print("secondpassword = \(secondPassword)")
            
            if encryptionPassword == secondPassword {
                
                self.createBackup()
                
            } else {
                
                displayAlert(viewController: self, title: "Error", message: "Passwords did not match please start over.")
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func createBackup() {
        
        print("createBackup")
        
        if let keyArray = self.getKeys() as? [String] {
            
            self.addAlertForShare(keysToBackUp: keyArray)
            print("keyArray = \(keyArray)")
            
        } else {
            
            displayAlert(viewController: self, title: "Oops", message: "Looks like you don't have any private keys saved to the device. Put the wallet in \"Hot Mode\" then either import a private key or create a new one by moving the Bitcoin around.")
        }
        
    }
    
    @objc func dismissImportView() {
        
        DispatchQueue.main.async {
            
            self.qrImageView.removeFromSuperview()
            self.avCaptureSession.stopRunning()
            self.textInput.removeFromSuperview()
            self.avCaptureSession.stopRunning()
            self.qrImageView.removeFromSuperview()
            self.importView.removeFromSuperview()
            
        }
        
    }
    
    func importWallet() {
        
        print("importWallet")
        importView.frame = view.frame
        importView.backgroundColor = UIColor.white
        
        let imageView = UIImageView()
        imageView.image = UIImage(named:"background.jpg")
        imageView.frame = self.view.frame
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.alpha = 0.05
        self.importView.addSubview(imageView)
        
        self.backButton = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
        self.backButton.showsTouchWhenHighlighted = true
        self.backButton.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
        self.backButton.addTarget(self, action: #selector(self.dismissImportView), for: .touchUpInside)
        
        self.textInput.frame = CGRect(x: self.view.frame.minX + 25, y: 150, width: self.view.frame.width - 50, height: 50)
        self.textInput.textAlignment = .center
        self.textInput.borderStyle = .roundedRect
        self.textInput.autocorrectionType = .no
        self.textInput.autocapitalizationType = .none
        self.textInput.backgroundColor = UIColor.groupTableViewBackground
        self.textInput.isSecureTextEntry = true
        self.textInput.placeholder = "Back Up Password"
        
        self.uploadButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 140, y: self.view.frame.maxY - 60, width: 130, height: 55))
        self.uploadButton.showsTouchWhenHighlighted = true
        self.uploadButton.setTitle("From Photos", for: .normal)
        self.uploadButton.setTitleColor(UIColor.blue, for: .normal)
        self.uploadButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        self.uploadButton.addTarget(self, action: #selector(self.chooseQRCodeFromLibrary), for: .touchUpInside)
        
        self.qrImageView.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.textInput.frame.maxY + 10, width: self.view.frame.width - 50, height: self.view.frame.width - 50)
        addShadow(view:self.qrImageView)
        
        DispatchQueue.main.async {
            
            self.view.addSubview(self.importView)
            self.importView.addSubview(self.backButton)
            self.importView.addSubview(self.textInput)
            self.importView.addSubview(self.qrImageView)
            self.importView.addSubview(self.uploadButton)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
            self.importView.addGestureRecognizer(tapGesture)
            
            displayAlert(viewController: self, title: "Alert", message: "If you are restoring a back up that was made on a different device, you will need to type in the \"Back Up Password\" that was given to you. If its the same device you can just scan your encrypted QR Codes and leave the password input blank.")
            
        }
        
        
        func scanQRCode() {
            
            do {
                
                try scanQRNow()
                print("scanQRNow")
                
            } catch {
                
                print("Failed to scan QR Code")
            }
            
        }
        
        scanQRCode()
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func chooseQRCodeFromLibrary() {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            
            let ciImage:CIImage = CIImage(image:pickedImage)!
            
            var qrCodeLink = ""
            
            let features=detector.features(in: ciImage)
            
            for feature in features as! [CIQRCodeFeature] {
                
                qrCodeLink += feature.messageString!
            }
            
            print(qrCodeLink)
            
            if qrCodeLink != "" {
                
                DispatchQueue.main.async {
                    if self.textInput.text == "" {
                        
                        let password = KeychainWrapper.standard.string(forKey: "AESPassword")!
                        print("password = \(password)")
                        
                        if let decrypted = AES256CBC.decryptString(qrCodeLink, password: password) as? String {
                            
                            print("decrypted = \(decrypted)")
                            self.processKey(decryptedKey: decrypted)
                            self.avCaptureSession.stopRunning()
                            
                        } else {
                            
                            displayAlert(viewController: self, title: "Error", message: "Password incorrect, take a deep breath, relax and try again. Remember all the letters are lower case, if you see an \"l\" it is a lower case \"L\" not an upper case \"I")
                        }
                        
                        
                    } else {
                        
                        let password = self.textInput.text!
                        print("password = \(password)")
                        
                        if let decrypted = AES256CBC.decryptString(qrCodeLink, password: password) as? String {
                            
                            print("decrypted = \(decrypted)")
                            self.processKey(decryptedKey: decrypted)
                            self.avCaptureSession.stopRunning()
                            
                            
                        } else {
                            
                            displayAlert(viewController: self, title: "Error", message: "Password incorrect, take a deep breath, relax and try again. Remember all the letters are lower case, if you see an \"l\" it is a lower case \"L\" not an upper case \"I")
                        }
                        
                        
                    }
                }
                
            }
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    enum error: Error {
        
        case noCameraAvailable
        case videoInputInitFail
        
    }
    
    func scanQRNow() throws {
        
        guard let avCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            
            print("no camera")
            throw error.noCameraAvailable
            
        }
        
        guard let avCaptureInput = try? AVCaptureDeviceInput(device: avCaptureDevice) else {
            
            print("failed to int camera")
            throw error.videoInputInitFail
        }
        
        
        let avCaptureMetadataOutput = AVCaptureMetadataOutput()
        avCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        if let inputs = self.avCaptureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.avCaptureSession.removeInput(input)
            }
        }
        
        if let outputs = self.avCaptureSession.outputs as? [AVCaptureMetadataOutput] {
            for output in outputs {
                self.avCaptureSession.removeOutput(output)
            }
        }
        
        self.avCaptureSession.addInput(avCaptureInput)
        self.avCaptureSession.addOutput(avCaptureMetadataOutput)
        
        avCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession)
        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avCaptureVideoPreviewLayer.frame = self.qrImageView.bounds
        self.qrImageView.layer.addSublayer(avCaptureVideoPreviewLayer)
        
        self.avCaptureSession.startRunning()
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            print("metadataOutput")
            
            let machineReadableCode = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if machineReadableCode.type == AVMetadataObject.ObjectType.qr {
                
                stringURL = machineReadableCode.stringValue!
                print("stringURL = \(stringURL)")
                
                
                if self.textInput.text == "" {
                    
                    let password = KeychainWrapper.standard.string(forKey: "AESPassword")!
                    print("password = \(password)")
                    
                    if let decrypted = AES256CBC.decryptString(self.stringURL, password: password) as? String {
                        
                        print("decrypted = \(decrypted)")
                        self.processKey(decryptedKey: decrypted)
                        self.avCaptureSession.stopRunning()
                        
                    } else {
                        
                        displayAlert(viewController: self, title: "Error", message: "Password incorrect, take a deep breath, relax and try again. Remember all the letters are lower case, if you see an \"l\" it is a lower case \"L\" not an upper case \"I")
                    }
                    
                    
                } else {
                    
                    let password = self.textInput.text!
                    print("password = \(password)")
                    
                    if let decrypted = AES256CBC.decryptString(self.stringURL, password: password) as? String {
                        
                        print("decrypted = \(decrypted)")
                        self.processKey(decryptedKey: decrypted)
                        self.avCaptureSession.stopRunning()
                        
                        
                    } else {
                        
                        displayAlert(viewController: self, title: "Error", message: "Password incorrect, take a deep breath, relax and try again. Remember all the letters are lower case, if you see an \"l\" it is a lower case \"L\" not an upper case \"I")
                    }
                    
                    
                }
                
            }
        }
    }
    
    func processKey(decryptedKey: String) {
        
        if decryptedKey.hasPrefix("9") || decryptedKey.hasPrefix("c") {
            print("testnetMode")
            
            if let privateKey = BTCPrivateKeyAddressTestnet(string: decryptedKey) {
                
                if let key = BTCKey.init(privateKeyAddress: privateKey) {
                    
                    var bitcoinAddress = String()
                    let privateKeyWIF = key.privateKeyAddressTestnet.string
                    let addressHD = key.addressTestnet.string
                    let publicKey = key.compressedPublicKey.hex()!
                    print("publicKey = \(publicKey)")
                    
                    if self.legacyMode {
                        
                        bitcoinAddress = addressHD
                        
                    }
                    
                    if segwitMode {
                        
                        let compressedPKData = BTCRIPEMD160(BTCSHA256(key.compressedPublicKey as Data!) as Data!) as Data!
                        
                        do {
                            
                            bitcoinAddress = try segwit.encode(hrp: "tb", version: 0, program: compressedPKData!)
                            
                        } catch {
                            
                            displayAlert(viewController: self, title: "Error", message: "Please try again.")
                            
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.avCaptureSession.startRunning()
                    }
                    
                    saveWallet(viewController: self, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "testnet", type: "hot", index: UInt32())
                    
                }
                
            }
            
        } else if decryptedKey.hasPrefix("5") || decryptedKey.hasPrefix("K") || decryptedKey.hasPrefix("L") {
            print("mainnetMode")
            
            if let privateKey = BTCPrivateKeyAddress(string: decryptedKey) {
                
                if let key = BTCKey.init(privateKeyAddress: privateKey) {
                    
                    print("privateKey = \(key.privateKeyAddress)")
                    var bitcoinAddress = String()
                    
                    let privateKeyWIF = key.privateKeyAddress.string
                    let addressHD = key.address.string
                    let publicKey = key.compressedPublicKey.hex()!
                    print("publicKey = \(publicKey)")
                    
                    if self.legacyMode {
                        
                        bitcoinAddress = addressHD
                        
                    }
                    
                    if segwitMode {
                        
                        let compressedPKData = BTCRIPEMD160(BTCSHA256(key.compressedPublicKey as Data!) as Data!) as Data!
                        
                        do {
                            
                            bitcoinAddress = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                            
                        } catch {
                            
                            displayAlert(viewController: self, title: "Error", message: "Please try again.")
                            
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.avCaptureSession.startRunning()
                    }
                    
                    saveWallet(viewController: self, mnemonic: "", xpub: "", address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot", index: UInt32())
                    
                }
                
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
    
    func setBIP39Now() {
        
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

    
    
    func setBIP39Password() {
        
        if isBIP39PasswordSet {
            
            if UserDefaults.standard.object(forKey: "bioMetricsEnabled") != nil {
                
                self.changeBIP39password = true
                self.authenticationWithTouchID()
                
            } else if KeychainWrapper.standard.string(forKey: "unlockAESPassword") != nil {
                
                
                var password = String()
                
                let alert = UIAlertController(title: "Please input your password", message: "Please enter your password to reset your BIP39 password", preferredStyle: .alert)
                
                alert.addTextField { (textField1) in
                    
                    textField1.placeholder = "Enter Password"
                    textField1.isSecureTextEntry = true
                    
                }
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Continue", comment: ""), style: .default, handler: { (action) in
                    
                    password = alert.textFields![0].text!
                    
                    if password == KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
                        
                        self.setBIP39Now()
                        
                    } else {
                        
                        displayAlert(viewController: self, title: "Error", message: "Incorrect password!")
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                    
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                
            } else {
                
                setBIP39Now()
                
            }
            
        } else {
            
            setBIP39Now()
            
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
        var reasonString = "To Lock and Unlock the Wallet"
        
        if createBackupBool {
            
            reasonString = "To create a backup"
            
        } else if self.changeBIP39password {
            
            reasonString = "To reset BIP39 password"
            
        }
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    if UserDefaults.standard.object(forKey: "bioMetricsEnabled") != nil {
                        
                        if self.createBackupBool {
                            
                            DispatchQueue.main.async {
                                
                                self.giveUserEncryptionPassword()
                                self.createBackupBool = false
                                
                            }
                            
                        } else if self.changeBIP39password {
                            
                            DispatchQueue.main.async {
                                
                                self.setBIP39Now()
                                self.changeBIP39password = false
                            }
                            
                        }
                        
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
