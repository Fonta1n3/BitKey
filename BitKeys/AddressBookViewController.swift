//
//  AddressBookViewController.swift
//  BitKeys
//
//  Created by Peter on 6/14/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import LocalAuthentication
import SwiftKeychainWrapper
import AES256CBC

class AddressBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var uploadButton = UIButton()
    let imagePicker = UIImagePickerController()
    var buttonTitle = UILabel()
    var activityIndicator:UIActivityIndicatorView!
    var backUpButton = UIButton()
    var settingsButton = UIButton()
    var privateKeyQRView = UIImageView()
    var privateKeyQRCode = UIImage()
    var privateKeyTitle = UILabel()
    var myField = UITextView()
    var currency = String()
    var createButton = UIButton()
    var amountToSend = UITextField()
    var textToShare = String()
    var fileName = String()
    var editWalletMode = Bool()
    let blurView = UIView()
    var tappedCell = UITableViewCell()
    var buttonViewVisible = Bool()
    var buttonView = UIView()
    var textInput = UITextField()
    var qrImageView = UIView()
    @IBOutlet var addressBookTable: UITableView!
    var stringURL = String()
    let avCaptureSession = AVCaptureSession()
    let importView = UIView()
    var walletNameToExport = String()
    var backButton = UIButton()
    var addButton = UIButton()
    var addressBook: [[String: Any]] = []
    var imageView:UIView!
    var hotMainnetArray = [[String: Any]]()
    var hotTestnetArray = [[String: Any]]()
    var coldMainnetArray = [[String: Any]]()
    var coldTestnetArray = [[String: Any]]()
    var sections = Int()
    var addressToExport = String()
    var privateKeyToExport = String()
    var refresher: UIRefreshControl!
    var multiSigMode = Bool()
    var keyArray = [[String: Any]]()
    var ableToDelete = Bool()
    var wallet = [String:Any]()
    var segwitMode = Bool()
    var legacyMode = Bool()
    var segwit = SegwitAddrCoder()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        addressBookTable.delegate = self
        let imageView = UIImageView()
        imageView.image = UIImage(named:"background.jpg")
        imageView.frame = self.view.frame
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.alpha = 0.02
        self.view.addSubview(imageView)
        textInput.delegate = self
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(self.getArrays), for: UIControlEvents.valueChanged)
        addressBookTable.addSubview(refresher)
        addBackButton()
        addPlusButton()
        
        if UserDefaults.standard.object(forKey: "firstTimeHere") != nil {
            
        } else {
            
            UserDefaults.standard.set(true, forKey: "firstTimeHere")
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                
                return
                
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TransactionSettings")
            
            do {
                
                let results = try context.fetch(fetchRequest) as [NSManagedObject]
                
                if results.count > 0 {
                    
                    
                } else {
                    
                    let entity = NSEntityDescription.entity(forEntityName: "TransactionSettings", in: context)
                    let mySettings = NSManagedObject(entity: entity!, insertInto: context)
                    mySettings.setValue(true, forKey: "dollar")
                    mySettings.setValue(false, forKey: "bitcoin")
                    mySettings.setValue(false, forKey: "satoshi")
                    mySettings.setValue(false, forKey: "pounds")
                    mySettings.setValue(false, forKey: "euro")
                    mySettings.setValue(0, forKey: "customFee")
                    mySettings.setValue(false, forKey: "high")
                    mySettings.setValue(true, forKey: "low")
                    mySettings.setValue(false, forKey: "medium")
                    
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
        
        getArrays()
        
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25, y: self.view.center.y - 25, width: 50, height: 50))
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.activityIndicator.isUserInteractionEnabled = true
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        ableToDelete = false
        legacyMode = checkSettingsForKey(keyValue: "legacyMode")
        segwitMode = checkSettingsForKey(keyValue: "segwitMode")
        
        addButtonView()
        
        if let BTC = checkTransactionSettingsForKey(keyValue: "bitcoin") as? Bool {
            if BTC {
                self.currency = "BTC"
                self.amountToSend.placeholder = "Invoice amount in Bitcoin"
            }
        }
        if let SAT = checkTransactionSettingsForKey(keyValue: "satoshi") as? Bool {
            if SAT {
                self.currency = "SAT"
                self.amountToSend.placeholder = "Invoice amount in Satoshis"
            }
        }
        if let USD = checkTransactionSettingsForKey(keyValue: "dollar") as? Bool {
            if USD {
                self.currency = "USD"
                self.amountToSend.placeholder = "Invoice amount in Dollars"
            }
        }
        if let GBP = checkTransactionSettingsForKey(keyValue: "pounds") as? Bool {
            if GBP {
                self.currency = "GBP"
                self.amountToSend.placeholder = "Invoice amount in Pounds"
            }
        }
        if let EUR = checkTransactionSettingsForKey(keyValue: "euro") as? Bool {
            if EUR {
                self.currency = "EUR"
                self.amountToSend.placeholder = "Invoice amount in Euros"
                
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "goHome") {
            
            if self.privateKeyToExport != "" {
                
                if let vc = segue.destination as? ViewController {
                    
                    vc.walletName = self.walletNameToExport
                    vc.bitcoinAddress = addressToExport
                    vc.privateKeyWIF = privateKeyToExport
                    vc.exportPrivateKeyFromTable = true
                    
                }
                
            } else {
                
                if let vc = segue.destination as? ViewController {
                    
                    vc.walletName = self.walletNameToExport
                    vc.bitcoinAddress = addressToExport
                    vc.exportAddressFromTable = true
                    
                }
                
            }
            
        } else if (segue.identifier == "showHistory") {
            
            if let vc = segue.destination as? TransactionHistoryViewController {
                
               vc.wallet = self.wallet
                
            }
            
            
        } else if (segue.identifier == "goToTransactions") {
            
            DispatchQueue.main.async {
                
                if let vc = segue.destination as? TransactionBuilderViewController {
                    
                    vc.walletToSpendFrom = self.wallet
                    print("vc.walletToSpendFrom = \(vc.walletToSpendFrom)")
                    vc.sendingFromAddress = self.wallet["address"] as! String
                    
                }
                
            }
            
        }
        
    }
    
    func share(textToShare: String, filename: String) {
        
        DispatchQueue.main.async {
            
            let ciContext = CIContext()
            let data = textToShare.data(using: String.Encoding.ascii)
            var qrCodeImage = UIImage()
            
            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let upScaledImage = filter.outputImage?.transformed(by: transform)
                let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
                qrCodeImage = UIImage(cgImage: cgImage!)
                
            }
            
            if let data = UIImagePNGRepresentation(qrCodeImage) {
                
                let fileName = getDocumentsDirectory().appendingPathComponent(filename + ".png")
                
                try? data.write(to: fileName)
                
                let objectsToShare = [fileName]
                
                DispatchQueue.main.async {
                    
                    let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    self.present(activityController, animated: true, completion: nil)
                    
                }
                
            }
            
        }
        
    }
    
    func addExportView() {
        
        self.blurView.frame = self.view.frame
        self.blurView.clipsToBounds = true
        self.view.addSubview(self.blurView)
        
        self.backButton = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
        self.backButton.showsTouchWhenHighlighted = true
        self.backButton.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
        self.backButton.addTarget(self, action: #selector(self.dismissInvoiceView), for: .touchUpInside)
        self.blurView.addSubview(self.backButton)
        
        var stringsToExport = [[String:String]]()
        
        if let privateKey = self.wallet["privateKey"] as? String {
            
            let password = KeychainWrapper.standard.string(forKey: "AESPassword")!
            
            if let decrypted = AES256CBC.decryptString(privateKey, password: password) {
                
                let dict = ["privateKey":"\(decrypted)"]
                stringsToExport.append(dict)
                
            }
            
        }
        
        if let address = self.wallet["address"] as? String {
            
            let dict = ["address":"\(address)"]
            stringsToExport.append(dict)
            
        }
        
        if let publicKey = self.wallet["publicKey"] as? String {
            
            let dict = ["publicKey":"\(publicKey)"]
            stringsToExport.append(dict)
            
        }
        
        if let redemptionScript = self.wallet["redemptionScript"] as? String {
            
            let dict = ["redemptionScript":"\(redemptionScript)"]
            stringsToExport.append(dict)
            
        }
        
        var x:CGFloat = 0
        let y:CGFloat = 0
        
        var frame = CGRect(x: x, y: y, width: self.view.frame.width, height: self.view.frame.height)
        
        var frameArray = [CGRect]()
        
        for (index, item) in stringsToExport.enumerated() {
            
            if index > 1 {
                
                
            }
            frameArray.append(frame)
            
        }
        
        
        
        
    }
    
    func addButtonView() {
        
        let modelName = UIDevice.modelName
        
        if modelName == "iPhone X" {
            buttonView = UIView(frame: CGRect(x: 0, y: self.view.frame.maxY + 6, width: view.frame.width, height: 150))
        } else {
           buttonView = UIView(frame: CGRect(x: 0, y: view.frame.maxY + 6, width: view.frame.width, height: 90))
        }
        
        buttonView.backgroundColor = UIColor.white
        buttonView.layer.shadowColor = UIColor.black.cgColor
        buttonView.layer.shadowOffset = CGSize(width: -2.5, height: -2.5)
        buttonView.layer.shadowRadius = 2.5
        buttonView.layer.shadowOpacity = 0.5
        buttonViewVisible = false
        view.addSubview(buttonView)
        
        let createInvoiceButton =  UIButton(frame: CGRect(x: 10, y: 25, width: 35, height: 35))
         createInvoiceButton.showsTouchWhenHighlighted = true
         createInvoiceButton.setImage(#imageLiteral(resourceName: "bill.png"), for: .normal)
         createInvoiceButton.addTarget(self, action: #selector(createWalletInvoice), for: .touchUpInside)
         buttonView.addSubview(createInvoiceButton)
        
        let createInvoiceLabel = UILabel(frame: CGRect(x: createInvoiceButton.center.x - (createInvoiceButton.frame.width / 2), y: 61, width: createInvoiceButton.frame.width, height: 12))
        createInvoiceLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        createInvoiceLabel.textColor = UIColor.black
        createInvoiceLabel.textAlignment = .center
        createInvoiceLabel.text = "Invoice"
        buttonView.addSubview(createInvoiceLabel)
        
        let spendButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) - (self.view.frame.width / 3.25 - (35/2)) - 5, y: 25, width: 35, height: 35))
        spendButton.showsTouchWhenHighlighted = true
        spendButton.setImage(#imageLiteral(resourceName: "pay.png"), for: .normal)
        spendButton.addTarget(self, action: #selector(spendFromWallet), for: .touchUpInside)
        buttonView.addSubview(spendButton)
        
        let spendLabel = UILabel(frame: CGRect(x: spendButton.center.x - (spendButton.frame.width / 2), y: 61, width: spendButton.frame.width, height: 12))
        spendLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        spendLabel.textColor = UIColor.black
        spendLabel.textAlignment = .center
        spendLabel.text = "Pay"
        buttonView.addSubview(spendLabel)
        
        let historyButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) - (self.view.frame.width / 7.5 - (35/2)) - 5, y: 25, width: 35, height: 35))
        historyButton.showsTouchWhenHighlighted = true
        historyButton.setImage(#imageLiteral(resourceName: "history.png"), for: .normal)
        historyButton.addTarget(self, action: #selector(getHistoryWallet), for: .touchUpInside)
        buttonView.addSubview(historyButton)
        
        let historyLabel = UILabel(frame: CGRect(x: historyButton.center.x - (historyButton.frame.width / 2), y: 61, width: historyButton.frame.width, height: 12))
        historyLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        historyLabel.textColor = UIColor.black
        historyLabel.textAlignment = .center
        historyLabel.text = "History"
        buttonView.addSubview(historyLabel)
        
        let addMultiSigButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) + (self.view.frame.width / 7.5 - (35/2)) - 5, y: 25, width: 35, height: 35))
        addMultiSigButton.showsTouchWhenHighlighted = true
        addMultiSigButton.setImage(#imageLiteral(resourceName: "add.png"), for: .normal)
        addMultiSigButton.addTarget(self, action: #selector(addToMultiSigWallet), for: .touchUpInside)
        buttonView.addSubview(addMultiSigButton)
        
        let multiSigLabel = UILabel(frame: CGRect(x: addMultiSigButton.center.x - (addMultiSigButton.frame.width / 2), y: 61, width: addMultiSigButton.frame.width, height: 12))
        multiSigLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        multiSigLabel.textColor = UIColor.black
        multiSigLabel.textAlignment = .center
        multiSigLabel.text = "MultiSig"
        buttonView.addSubview(multiSigLabel)
        
        let editButton = UIButton(frame: CGRect(x: (self.view.center.x - (35/2)) + (self.view.frame.width / 3.25 - (35/2)) - 5, y: 25, width: 35, height: 35))
        editButton.showsTouchWhenHighlighted = true
        editButton.setImage(#imageLiteral(resourceName: "edit.jpg"), for: .normal)
        editButton.addTarget(self, action: #selector(editWalletButton), for: .touchUpInside)
        buttonView.addSubview(editButton)
        
        let editLabel = UILabel(frame: CGRect(x: editButton.center.x - (editButton.frame.width / 2), y: 61, width: editButton.frame.width, height: 12))
        editLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        editLabel.textColor = UIColor.black
        editLabel.textAlignment = .center
        editLabel.text = "Edit"
        buttonView.addSubview(editLabel)
        
        let exportButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 45, y: 25, width: 35, height: 35))
        exportButton.showsTouchWhenHighlighted = true
        exportButton.setImage(#imageLiteral(resourceName: "qr.png"), for: .normal)
        exportButton.addTarget(self, action: #selector(exportWallet), for: .touchUpInside)
        buttonView.addSubview(exportButton)
        
        let exportLabel = UILabel(frame: CGRect(x: exportButton.center.x - (exportButton.frame.width / 2), y: 61, width: exportButton.frame.width, height: 12))
        exportLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        exportLabel.textColor = UIColor.black
        exportLabel.textAlignment = .center
        exportLabel.text = "Export"
        buttonView.addSubview(exportLabel)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.buttonView.removeFromSuperview()
        buttonViewVisible = false
    }
    
    func editNow() {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: nil, message: "Please select an option", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            if self.wallet["privateKey"] as! String != "" {
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Make Wallet Cold", comment: ""), style: .default, handler: { (action) in
                    
                    DispatchQueue.main.async {
                        
                        let alert = UIAlertController(title: "WARNING!", message: "This will delete the private key and your ability to spend from this wallet in the app, please ensure you have the private key and recovery phrase backed up first.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Make it Cold", comment: ""), style: .destructive, handler: { (action) in
                            
                            for (index, wallets) in self.addressBook.enumerated() {
                                
                                if wallets["address"] as! String == self.wallet["address"] as! String {
                                    
                                    self.addressBook[index]["privateKey"] = ""
                                    self.addressBook[index]["type"] = "cold"
                                    self.editWallet(address: wallets["address"] as! String, newValue: "", oldValue: "", keyToEdit: "privateKey")
                                    
                                }
                                
                            }
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                            
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }))
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Edit Wallet Name", comment: ""), style: .default, handler: { (action) in
                
                for (index, address) in self.addressBook.enumerated() {
                    
                    if self.wallet["address"] as! String == address["address"] as! String {
                        
                        let oldName = self.addressBook[index]["label"] as! String
                        
                        let alert = UIAlertController(title: "Give \"\(oldName)\" a new name", message: "", preferredStyle: .alert)
                        
                        alert.addTextField { (textField1) in
                            
                            textField1.placeholder = "Optional"
                            
                        }
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Update", comment: ""), style: .default, handler: { (action) in
                            
                            let label = alert.textFields![0].text!
                            self.addressBook[index]["label"] = label
                            self.editWallet(address: address["address"] as! String, newValue: label, oldValue: oldName, keyToEdit: "label")
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }))
            
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            alert.popoverPresentationController?.sourceView = self.view
            
            self.present(alert, animated: true) {
                print("option menu presented")
            }
            
        }
        
    }
    
    @objc func editWalletButton() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        print("editWalletButton")
        
        showButtonView()
        self.editWalletMode = true
        
        if UserDefaults.standard.object(forKey: "bioMetricsEnabled") != nil {
            
            self.authenticationWithTouchID()
            
        } else if let _ = KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
            
            var password = String()
            
            let alert = UIAlertController(title: "Please input your password", message: "Please enter your password to edit a wallet", preferredStyle: .alert)
            
            alert.addTextField { (textField1) in
                
                textField1.placeholder = "Enter Password"
                textField1.isSecureTextEntry = true
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Continue", comment: ""), style: .default, handler: { (action) in
                
                password = alert.textFields![0].text!
                
                if password == KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
                    
                    self.editNow()
                    self.editWalletMode = false
                    
                } else {
                    
                    displayAlert(viewController: self, title: "Error", message: "Incorrect password!")
                    self.editWalletMode = false
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                self.editWalletMode = false
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            self.editNow()
            self.editWalletMode = false
        }
        
    }
    
    @objc func spendFromWallet() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
      self.performSegue(withIdentifier: "goToTransactions", sender: self)
        
    }
    
    @objc func getHistoryWallet() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.performSegue(withIdentifier: "showHistory", sender: self)
    }
    
    @objc func goToSettings() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.performSegue(withIdentifier: "goToSettings", sender: self)
        
    }
    
    @objc func createWalletInvoice() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        showButtonView()
        
        let modelName = UIDevice.modelName

        self.blurView.frame = self.view.frame
        self.blurView.backgroundColor = UIColor.white
        self.view.addSubview(self.blurView)
        
        let imageView = UIImageView()
        imageView.image = UIImage(named:"background.jpg")
        imageView.frame = self.view.frame
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.alpha = 0.05
        self.blurView.addSubview(imageView)
        
        if modelName == "iPhone X" {
            
            self.backButton = UIButton(frame: CGRect(x: 5, y: 30, width: 55, height: 55))
            
            
        } else {
            
            self.backButton = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
            
        }
        
        self.backButton.showsTouchWhenHighlighted = true
        self.backButton.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
        self.backButton.addTarget(self, action: #selector(self.dismissInvoiceView), for: .touchUpInside)
        self.blurView.addSubview(self.backButton)
        
        self.settingsButton.removeFromSuperview()
        
        if modelName == "iPhone X" {
            
            self.settingsButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 50, y: 30, width: 45, height: 45))
            
        } else {
            
            self.settingsButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 50, y: 20, width: 45, height: 45))
            
        }
        
        self.settingsButton.showsTouchWhenHighlighted = true
        self.settingsButton.setImage(#imageLiteral(resourceName: "settings2.png"), for: .normal)
        self.settingsButton.addTarget(self, action: #selector(self.goToSettings), for: .touchUpInside)
        self.blurView.addSubview(self.settingsButton)
        
        self.amountToSend.frame = CGRect(x: self.view.frame.minX + 5, y: self.view.frame.minY + 150, width: self.view.frame.width - 10, height: 50)
        self.amountToSend.textAlignment = .center
        self.amountToSend.borderStyle = .roundedRect
        self.amountToSend.backgroundColor = UIColor.groupTableViewBackground
        self.amountToSend.keyboardType = UIKeyboardType.decimalPad
        self.blurView.addSubview(self.amountToSend)
        
        self.createButton = UIButton(frame: CGRect(x: self.view.center.x - 40, y: self.amountToSend.frame.maxY + 10, width: 80, height: 55))
        self.createButton.showsTouchWhenHighlighted = true
        self.createButton.setTitle("Next", for: .normal)
        self.createButton.setTitleColor(UIColor.blue, for: .normal)
        self.createButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        self.createButton.addTarget(self, action: #selector(self.createNow), for: .touchUpInside)
        self.blurView.addSubview(self.createButton)
        
        self.amountToSend.becomeFirstResponder()
        
    }
    
    @objc func createNow() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        if self.amountToSend.text != "" {
            
            self.amountToSend.resignFirstResponder()
            self.amountToSend.removeFromSuperview()
            self.settingsButton.removeFromSuperview()
            self.createButton.removeFromSuperview()
            
            self.addInvoiceView(address: self.wallet["address"] as! String, amount: self.amountToSend.text!, currency: self.currency)
            
        } else {
            
            shakeAlert(viewToShake: self.amountToSend)
        }
        
    }
    
    func generateQrCode(key: String) -> UIImage? {
        print("generateQrCode")
        let ciContext = CIContext()
        let data = key.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let upScaledImage = filter.outputImage?.transformed(by: transform)
            let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
            let qrCode = UIImage(cgImage: cgImage!)
            return qrCode
        }
        
        return nil
        
    }
    
    func addInvoiceView(address: String, amount: String, currency: String) {
        
        print("amount = \(amount)")
        
        if currency != "BTC" && currency != "SAT" {
            
            displayAlert(viewController: self, title: "FYI", message: "This invoice is denominated in \(currency) and not Bitcoin, therefore this invoice will only work for someone who is using BitSense.\n\nInvoices denominated in Bitcoin or Satoshis will work with any wallet that is BIP21 compatible.")
        }
        
        var stringToShare = String()
        var amountToShare = amount
        
        if currency == "SAT" || currency == "BTC" {
            
            if currency == "SAT" {
                
                amountToShare = (Double(amount)! / 100000000).avoidNotation
                
            }
            
            stringToShare = "bitcoin:\(address)?amount=\(amountToShare)"
            
        } else {
            
            stringToShare = "address:\(address)?amount:\(amountToShare)?currency:\(currency)"
            
        }
        
        self.privateKeyQRCode = self.generateQrCode(key: stringToShare)!
        self.textToShare = stringToShare
        self.privateKeyQRView = UIImageView(image: privateKeyQRCode)
        privateKeyQRView.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 70) / 2), y: self.view.center.y - ((self.view.frame.width - 70) / 2), width: self.view.frame.width - 70, height: self.view.frame.width - 70)
        privateKeyQRView.alpha = 0
        addShadow(view: privateKeyQRView)
        self.blurView.addSubview(privateKeyQRView)
        
        UIView.animate(withDuration: 0.5, animations: {
            
        }, completion: { _ in
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.privateKeyQRView.alpha = 1
                
            }, completion: { _ in
                
                DispatchQueue.main.async {
                    
                    self.privateKeyTitle = UILabel(frame: CGRect(x: self.view.center.x - ((self.view.frame.width - 20) / 2), y: self.privateKeyQRView.frame.minY - 80, width: self.view.frame.width - 20, height: 50))
                    self.fileName = "Invoice"
                    self.privateKeyTitle.text = "Invoice\n🤑"
                    self.privateKeyTitle.numberOfLines = 0
                    self.privateKeyTitle.adjustsFontSizeToFitWidth = true
                    self.privateKeyTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 32)
                    self.privateKeyTitle.textColor = UIColor.black
                    self.privateKeyTitle.textAlignment = .center
                    self.blurView.addSubview(self.privateKeyTitle)
                    
                }
                
                var name = self.wallet["label"] as! String
                if name == "" {
                    name = self.wallet["address"] as! String
                }
                
                var foramttedCurrency = String()
                self.myField = UITextView (frame:CGRect(x: self.view.center.x - ((self.view.frame.width - 10)/2), y: self.privateKeyQRView.frame.maxY + 10, width: self.view.frame.width - 10, height: 75))
                self.myField.isEditable = false
                self.myField.backgroundColor = UIColor.clear
                self.myField.isSelectable = true
                self.myField.font = UIFont.init(name: "HelveticaNeue-Light", size: 15)
                
                var amountwithcommas = amount
                
                if Double(amount)! > 100.0 {
                    
                    amountwithcommas = (Double(amount)?.withCommas())!
                    
                }
                
                switch (self.currency) {
                case "USD": foramttedCurrency = "US Dollars"
                case "GBP": foramttedCurrency = "British Pounds"
                case "EUR": foramttedCurrency = "Euros"
                case "SAT": foramttedCurrency = "Satoshis"
                case "BTC": foramttedCurrency = "Bitcoin"
                default: break
                }
                self.myField.text = "Invoice of \(String(describing: amountwithcommas)) \(foramttedCurrency), to be paid to \(name)"
                self.myField.textAlignment = .center
                self.blurView.addSubview(self.myField)
                
                self.backUpButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 90, y: self.view.frame.maxY - 60, width: 80, height: 55))
                self.backUpButton.showsTouchWhenHighlighted = true
                self.backUpButton.setTitle("Share", for: .normal)
                self.backUpButton.setTitleColor(UIColor.blue, for: .normal)
                self.backUpButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
                self.backUpButton.addTarget(self, action: #selector(self.goTo(sender:)), for: .touchUpInside)
                self.blurView.addSubview(self.backUpButton)
                
            })
            
        })
        
    }
    
    @objc func goTo(sender: UIButton) {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.share(textToShare: self.textToShare, filename: self.fileName)
        
    }
    
    @objc func dismissInvoiceView() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.backUpButton.removeFromSuperview()
        self.amountToSend.text = ""
        self.privateKeyTitle.text = ""
        self.privateKeyTitle.removeFromSuperview()
        self.textToShare = ""
        self.fileName = ""
        self.settingsButton.removeFromSuperview()
        self.privateKeyQRView.removeFromSuperview()
        self.createButton.removeFromSuperview()
        self.amountToSend.removeFromSuperview()
        self.myField.removeFromSuperview()
        self.blurView.removeFromSuperview()
    
    }
    
    @objc func addToMultiSigWallet() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        if self.keyArray.count > 0 {
            
            self.keyArray.removeAll()
        }
        
        if self.wallet["publicKey"] as! String != "" && self.wallet["redemptionScript"] as! String == "" {
            
            showButtonView()
            self.multiSigMode = true
            self.tappedCell.accessoryType = UITableViewCellAccessoryType.checkmark
            self.tappedCell.isSelected = true
            self.keyArray.append(self.wallet)
            print("keyArray = \(self.keyArray)")
            
        } else {
            
            displayAlert(viewController: self, title: "Error", message: "This wallet is already associated with another Multi Sig wallet and can't be used to create another Multi Sig.")
        }
        
    }
    
    @objc func exportWallet() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        showButtonView()
        self.addressToExport = self.wallet["address"] as! String
        self.privateKeyToExport = self.wallet["privateKey"] as! String
        self.walletNameToExport = self.wallet["label"] as! String
        
        if self.privateKeyToExport != "" {
            
            if UserDefaults.standard.object(forKey: "bioMetricsEnabled") != nil {
                
                self.authenticationWithTouchID()
                
            } else if let _ = KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
                
                var password = String()
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Please input your password", message: "Please enter your password to export your private key", preferredStyle: .alert)
                    
                    alert.addTextField { (textField1) in
                        
                        textField1.placeholder = "Enter Password"
                        textField1.isSecureTextEntry = true
                        
                    }
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Export", comment: ""), style: .default, handler: { (action) in
                        
                        password = alert.textFields![0].text!
                        
                        if password == KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
                            
                            DispatchQueue.main.async {
                                //self.addExportView()
                                self.processKeyAndSegue()
                            }
                            
                            
                        } else {
                            
                            displayAlert(viewController: self, title: "Error", message: "Incorrect password!")
                        }
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                        
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)

                }
                
                
            } else {
                
                self.processKeyAndSegue()
                //self.addExportView()
                
            }
            
        } else {
            
            self.processKeyAndSegue()
            //self.addExportView()
            
        }
        
    }
    
    @objc func getArrays() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        addressBook = checkAddressBook()
        
        if addressBook.count == 0 {
            
            self.removeSpinner()
            
        }
        
        self.hotMainnetArray.removeAll()
        self.coldMainnetArray.removeAll()
        self.hotTestnetArray.removeAll()
        self.coldTestnetArray.removeAll()
        
        self.sections = 0
        
        for address in self.addressBook {
            
            let network = address["network"] as! String
            let type = address["type"] as! String
            
            if network == "mainnet" && type == "hot" {
                
                self.hotMainnetArray.append(address)
                self.sections = sections + 1
                
            } else if network == "testnet" && type == "hot" {
                
                self.hotTestnetArray.append(address)
                self.sections = sections + 1
                
            } else if network == "mainnet" && type == "cold" {
                
                self.coldMainnetArray.append(address)
                self.sections = sections + 1
                
            } else if network == "testnet" && type == "cold" {
                
                self.coldTestnetArray.append(address)
                self.sections = sections + 1
                
            }
            
        }
        
        for (index, address) in hotMainnetArray.enumerated() {
            
            let addressToCheck = address["address"] as! String
            self.checkBalance(address: addressToCheck, index: index, network: "mainnet", type: "hot")
            
        }
        
        for (index, address) in hotTestnetArray.enumerated() {
            
            let addressToCheck = address["address"] as! String
            self.checkBalance(address: addressToCheck, index: index, network: "testnet", type: "hot")
            
        }
        
        for (index, address) in coldMainnetArray.enumerated() {
            
            let addressToCheck = address["address"] as! String
            self.checkBalance(address: addressToCheck, index: index, network: "mainnet", type: "cold")
            
        }
        
        for (index, address) in coldTestnetArray.enumerated() {
            
            let addressToCheck = address["address"] as! String
            self.checkBalance(address: addressToCheck, index: index, network: "testnet", type: "cold")
            
        }
        
        addressBookTable.reloadData()
        
    }
    
    
    
    func showButtonView() {
        print("buttonView")
        
        let modelName = UIDevice.modelName
        
        if buttonViewVisible == false {
            
            self.buttonViewVisible = true
            DispatchQueue.main.async {
                
                self.buttonTitle.frame = CGRect(x: self.buttonView.center.x - ((self.buttonView.frame.width - 20) / 2), y: 3, width: self.buttonView.frame.width - 20, height: 20)
                
                var text = String()
                
                if let _ = self.wallet["label"] as? String {
                    print("wallet = \(self.wallet)")
                    
                    if self.wallet["label"] as! String != "" {
                        
                        text = self.wallet["label"] as! String
                        
                    } else {
                        
                        text = self.wallet["address"] as! String
                        
                    }
                    
                }
                
                self.buttonTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 15)
                self.buttonTitle.textColor = UIColor.black
                self.buttonTitle.textAlignment = .center
                self.buttonTitle.adjustsFontSizeToFitWidth = true
                self.buttonTitle.text = text
                self.buttonView.addSubview(self.buttonTitle)
                
                UIView.animate(withDuration: 0.3, animations: {
                    if modelName == "iPhone X" {
                        self.buttonView.frame = CGRect(x: 0, y: self.view.frame.maxY - 155, width: self.view.frame.width, height: 150)
                    } else {
                        
                      self.buttonView.frame = CGRect(x: 0, y: self.view.frame.maxY - 90, width: self.view.frame.width, height: 90)
                    }
                    
                }, completion: { _ in
                    
                })
                
            }
            
        } else {
            
            self.buttonViewVisible = false
            DispatchQueue.main.async {
                self.buttonTitle.removeFromSuperview()
                UIView.animate(withDuration: 0.3) {
                    if modelName == "iPhone X" {
                        self.buttonView.frame = CGRect(x: 0, y: self.view.frame.maxY + 6, width: self.view.frame.width, height: 150)
                    } else {
                        self.buttonView.frame = CGRect(x: 0, y: self.view.frame.maxY + 6, width: self.view.frame.width, height: 90)
                        
                    }
                    
                }
            }
            
        }
        
        
    }
    
    func addBackButton() {
        print("addBackButton")
        
        DispatchQueue.main.async {
            
            self.backButton.removeFromSuperview()
            self.backButton = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
            self.backButton.showsTouchWhenHighlighted = true
            self.backButton.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
            self.backButton.addTarget(self, action: #selector(self.back), for: .touchUpInside)
            self.view.addSubview(self.backButton)
            
            let title = UILabel(frame: CGRect(x: self.view.center.x - 75, y: 20, width: 150, height: 55))
            title.font = UIFont.init(name: "HelveticaNeue-Bold", size: 18)
            title.textColor = UIColor.black
            title.text = "Wallets"
            title.textAlignment = .center
            self.view.addSubview(title)
        }
        
    }
    
    func addPlusButton() {
        print("addPlusButton")
        
        DispatchQueue.main.async {
            
            self.addButton.alpha = 0
            self.addButton.removeFromSuperview()
            self.addButton = UIButton(frame: CGRect(x: self.view.frame.width - 60, y: 28, width: 35, height: 35))
            self.addButton.showsTouchWhenHighlighted = true
            self.addButton.setImage(#imageLiteral(resourceName: "add.png"), for: .normal)
            self.addButton.addTarget(self, action: #selector(self.add), for: .touchUpInside)
            self.view.addSubview(self.addButton)
        }
        
    }
    
    @objc func add() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        print("add")
        
        func deselectRows() {
            
            if let rowsToDeselect  = self.addressBookTable.indexPathsForSelectedRows {
                
                for row in rowsToDeselect {
                    
                    self.addressBookTable.deselectRow(at: row, animated: false)
                    let cell = self.addressBookTable.cellForRow(at: row)!
                    cell.accessoryType = UITableViewCellAccessoryType.none
                    
                }
                
                self.multiSigMode = false
                
            }
            
        }
        
        var signaturesRequired = UInt()
        
        if self.keyArray.count > 0 {
            
            //alert to ask how many signatures
            let alert = UIAlertController(title: "How many signatures?", message: "This number needs to be between 1 and \(self.keyArray.count)", preferredStyle: .alert)
            
            alert.addTextField { (textField1) in
                
                textField1.keyboardType = UIKeyboardType.decimalPad
                textField1.placeholder = "1 to \(self.keyArray.count)"
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default, handler: { (action) in
                
                signaturesRequired = UInt(alert.textFields![0].text!)!
                
                if signaturesRequired <= self.keyArray.count {
                    
                    self.createMultiSig(wallets: self.keyArray, signaturesRequired: signaturesRequired)
                    
                } else {
                    
                    displayAlert(viewController: self, title: "Error", message: "Number of signatures exceeds number of keys, please try again but only input a maximum number of signatures that is equal to the number of keys.")
                    
                    deselectRows()
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
                deselectRows()
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            self.importWallet()
            
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
        self.textInput.returnKeyType = UIReturnKeyType.go
        self.textInput.placeholder = "Scan or type an Address or Private Key"
        
        let title = UILabel(frame: CGRect(x: self.view.center.x - ((self.view.frame.width - 50) / 2), y: self.textInput.frame.minY - 65, width: self.view.frame.width - 50, height: 55))
        title.font = UIFont.init(name: "HelveticaNeue-Bold", size: 18)
        title.textColor = UIColor.black
        title.text = "Import Address or Private Key"
        title.adjustsFontSizeToFitWidth = true
        title.textAlignment = .center
        self.importView.addSubview(title)
        
        self.qrImageView.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.textInput.frame.maxY + 10, width: self.view.frame.width - 50, height: self.view.frame.width - 50)
        addShadow(view:self.qrImageView)
        
        self.uploadButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 140, y: self.view.frame.maxY - 60, width: 130, height: 55))
        self.uploadButton.showsTouchWhenHighlighted = true
        self.uploadButton.setTitle("From Photos", for: .normal)
        self.uploadButton.setTitleColor(UIColor.blue, for: .normal)
        self.uploadButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        self.uploadButton.addTarget(self, action: #selector(self.chooseQRCodeFromLibrary), for: .touchUpInside)
        
        DispatchQueue.main.async {
            
            self.view.addSubview(self.importView)
            self.importView.addSubview(self.backButton)
            self.importView.addSubview(self.textInput)
            self.importView.addSubview(self.qrImageView)
            self.importView.addSubview(self.uploadButton)
            
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
                    
                    self.processKeys(key: qrCodeLink)
                    self.qrImageView.removeFromSuperview()
                    self.avCaptureSession.stopRunning()
                    
                }
                
            }
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func chooseQRCodeFromLibrary() {
        
        present(imagePicker, animated: true, completion: nil)
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
                
                processKeys(key: stringURL)
                
                self.qrImageView.removeFromSuperview()
                self.avCaptureSession.stopRunning()
                
            }
        }
    }
    
    func processKeys(key: String) {
        print("processKeys = \(key)")
        
        func processPrivateKey(privateKey: String) {
            
            if privateKey.hasPrefix("9") || privateKey.hasPrefix("c") {
                print("testnetMode")
                
                if let privateKey = BTCPrivateKeyAddressTestnet(string: privateKey) {
                    
                    if let key = BTCKey.init(privateKeyAddress: privateKey) {
                        
                        print("privateKey = \(key.privateKeyAddressTestnet)")
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
                            self.importView.removeFromSuperview()
                            
                            saveWallet(viewController: self, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "testnet", type: "hot")
                        }
                        
                    }
                }
                
                
            } else if privateKey.hasPrefix("5") || privateKey.hasPrefix("K") || privateKey.hasPrefix("L") {
                print("mainnetMode")
                
                if let privateKey = BTCPrivateKeyAddress(string: privateKey) {
                    
                    if let key = BTCKey.init(privateKeyAddress: privateKey) {
                        
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
                            self.importView.removeFromSuperview()
                            
                            saveWallet(viewController: self, address: bitcoinAddress, privateKey: privateKeyWIF, publicKey: publicKey, redemptionScript: "", network: "mainnet", type: "hot")
                        }
                        
                    }
                    
                }
                
            }

        }
        
        if key.hasPrefix("9") || key.hasPrefix("c") || key.hasPrefix("5") || key.hasPrefix("K") || key.hasPrefix("L") {
            
            processPrivateKey(privateKey: key)
            
        } else if key.hasPrefix("1") || key.hasPrefix("3") || key.hasPrefix("bc") || key.hasPrefix("2") {
            
            self.importView.removeFromSuperview()
            
            saveWallet(viewController: self, address: key, privateKey: "", publicKey: "", redemptionScript: "", network: "mainnet", type: "cold")
            
        } else if key.hasPrefix("m") || key.hasPrefix("tb") || key.hasPrefix("2") {
            
            self.importView.removeFromSuperview()
            
            saveWallet(viewController: self, address: key, privateKey: "", publicKey: "", redemptionScript: "", network: "testnet", type: "cold")
            
        } else {
            
            displayAlert(viewController: self, title: "Error", message: "Thats not a valid Bitcoin Private Key or Address")
            
        }
        
     }
    
    @objc func dismissImportView() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        DispatchQueue.main.async {
            
            self.textInput.removeFromSuperview()
            self.avCaptureSession.stopRunning()
            self.qrImageView.removeFromSuperview()
            self.importView.removeFromSuperview()
            
        }
        
    }
    
    func createMultiSig(wallets: [[String:Any]], signaturesRequired: UInt) {
        
        var testnet = Bool()
        var mainnet = Bool()
        var isMultiSig = Bool()
        var network = ""
        
        func deselectRows() {
            
            DispatchQueue.main.async {
                if let rowsToDeselect  = self.addressBookTable.indexPathsForSelectedRows {
                    
                    for row in rowsToDeselect {
                        
                        self.addressBookTable.deselectRow(at: row, animated: false)
                        let cell = self.addressBookTable.cellForRow(at: row)!
                        cell.accessoryType = UITableViewCellAccessoryType.none
                        
                    }
                    
                }
                
                self.keyArray.removeAll()
                self.multiSigMode = false
            }
            
        }
        
        for wallet in wallets {
            
            if wallet["network"] as! String == "mainnet" {
                
                mainnet = true
                network = "mainnet"
                
            } else {
                
                testnet = true
                network = "testnet"
                
            }
            
            if wallet["redemptionScript"] as! String != "" {
                
                isMultiSig = true
                
            }
            
        }
        
        if isMultiSig {
            
            deselectRows()
            
            displayAlert(viewController: self, title: "Error", message: "You can not create a MultiSig Wallet with a Wallet that is already associated with another MultiSig Wallet.")
            
            
        } else {
            
            if mainnet && testnet {
                
                deselectRows()
                
                displayAlert(viewController: self, title: "Error", message: "You can not create a multi sig wallet with a testnet wallet and a mainnet wallet, choose wallets only from the same network.")
                
                
            } else {
                
                var publickKeyArray = [Any]()
                
                for wallet in wallets {
                    
                    let publicKeyData = BTCDataFromHex(wallet["publicKey"] as! String)
                    publickKeyArray.append(publicKeyData as Data!)
                    
                }
                
                if let multiSigWallet = BTCScript.init(publicKeys: publickKeyArray, signaturesRequired: signaturesRequired) {
                    
                    var multiSigAddress1 = String()
                    
                    if network == "testnet" {
                        
                        multiSigAddress1 = multiSigWallet.scriptHashAddressTestnet.string
                        
                    } else if network == "mainnet" {
                        
                        multiSigAddress1 = multiSigWallet.scriptHashAddress.string
                        
                    }
                    
                    let multiSigAddress = multiSigAddress1
                    let redemptionScript = multiSigWallet.hex!
                    
                    for (index, wallet) in self.addressBook.enumerated() {
                        
                        for address in wallets {
                            
                            if wallet["address"] as! String == address["address"] as! String {
                                
                                self.addressBook[index]["redemptionScript"] = redemptionScript
                                self.editWallet(address: wallet["address"] as! String, newValue: redemptionScript, oldValue: "", keyToEdit: "redemptionScript")
                                
                            }
                            
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                        deselectRows()
                        
                        saveWallet(viewController: self, address: multiSigAddress, privateKey: "", publicKey: "", redemptionScript: redemptionScript, network: network, type: "cold")
                        
                    }
                    
                } else {
                    
                    deselectRows()
                    
                    displayAlert(viewController: self, title: "Error", message: "Sorry there was an error creating your multi sig wallet")
                    
                    
                }
                
            }
        }
        
    }
    
    @objc func back() {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 4
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor.white
        (view as! UITableViewHeaderFooterView).textLabel?.textAlignment = .center
        (view as! UITableViewHeaderFooterView).textLabel?.font = UIFont.init(name: "HelveticaNeue-Light", size: 15)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.darkGray
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 80
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70))
        let explanationLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: 60))
        explanationLabel.textColor = UIColor.darkGray
        footerView.backgroundColor = UIColor.clear
        explanationLabel.backgroundColor = UIColor.clear
        explanationLabel.numberOfLines = 0
        explanationLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 10)
        
        if section == 0 && self.hotMainnetArray.count > 0 {
            
            explanationLabel.text = "These are your Hot Wallets on the main Bitcoin network. The app stores your encrypted private keys which allows you to spend from them effortlessly. You should only keep spending money in these wallets. Balance only shows transactions that have at least one confirmation."
            footerView.addSubview(explanationLabel)
            return footerView
            
        } else if section == 1 && self.hotTestnetArray.count > 0 {
            
            explanationLabel.text = "These are your Hot Wallets on the test Bitcoin network. The app stores your encrypted private keys which allows you to spend from them effortlessly. This is NOT real money and is only for testing purposes. Balance only shows transactions that have at least one confirmation."
            footerView.addSubview(explanationLabel)
            return footerView
            
        } else if section == 2 && self.coldMainnetArray.count > 0 {
            
            explanationLabel.text = "These are your cold wallets on the main Bitcoin network. We do NOT store the private keys for these wallets, you can only check the balances, if you put the app in cold mode then you can scan the private key whilst making a transaction to spend from these wallets. Balance only shows transactions that have at least one confirmation."
            footerView.addSubview(explanationLabel)
            return footerView
            
        } else if section == 3 && self.coldTestnetArray.count > 0 {
            
            explanationLabel.text = "These are your cold wallets on the test network. We do NOT store the private keys for these wallets. This is NOT real money and is only for testing purposes. Balance only shows transactions that have at least one confirmation."
            footerView.addSubview(explanationLabel)
            return footerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.addressBookTable {
           
            if section == 0 {
                
                return hotMainnetArray.count
                
            } else if section == 1 {
                
                return hotTestnetArray.count
                
            } else if section == 2 {
                
                return coldMainnetArray.count
                
            } else if section == 3 {
                
                return coldTestnetArray.count
                
            }
            
        }
        
       return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        
        cell.textLabel?.font = UIFont.init(name: "HelveticaNeue-Light", size: 15)
        
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.white
        cell.alpha = 1
        
        let balanceLabel = cell.viewWithTag(1) as! UILabel
        let nameLabel = cell.viewWithTag(2) as! UILabel
        
        if indexPath.section == 0 {
            
            let label = self.hotMainnetArray[indexPath.row]["label"] as! String
            let address = self.hotMainnetArray[indexPath.row]["address"] as! String
            let balance = self.hotMainnetArray[indexPath.row]["balance"] as! String
            
            if label != "" {
                
                nameLabel.text = "\(label)"
                //nameLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 100, height: 40)
                //nameLabel.adjustsFontSizeToFitWidth = true
                    
            } else {
                
                nameLabel.text = "\(address)"
                //nameLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 200, height: 40)
                //nameLabel.adjustsFontSizeToFitWidth = true
            }
            
            balanceLabel.text = "\(balance)"
            
        } else if indexPath.section == 1 {
            
            let label = self.hotTestnetArray[indexPath.row]["label"] as! String
            let address = self.hotTestnetArray[indexPath.row]["address"] as! String
            let balance = self.hotTestnetArray[indexPath.row]["balance"] as! String
            
            if label != "" {
                
                nameLabel.text = "\(label)"
                //nameLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 100, height: 40)
                //nameLabel.adjustsFontSizeToFitWidth = true
                
            } else {
                
                nameLabel.text = "\(address)"
                //nameLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 200, height: 40)
                //nameLabel.adjustsFontSizeToFitWidth = true
            }
            
            balanceLabel.text = "\(balance)"
            
        } else if indexPath.section == 2 {
            
            let label = self.coldMainnetArray[indexPath.row]["label"] as! String
            let address = self.coldMainnetArray[indexPath.row]["address"] as! String
            let balance = self.coldMainnetArray[indexPath.row]["balance"] as! String
            
            if label != "" {
                
                nameLabel.text = "\(label)"
                //nameLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 200, height: 40)
                //nameLabel.adjustsFontSizeToFitWidth = true
                
            } else {
                
                nameLabel.text = "\(address)"
                //nameLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 200, height: 40)
                //nameLabel.adjustsFontSizeToFitWidth = true
            }
            
            balanceLabel.text = "\(balance)"
            
        } else if indexPath.section == 3 {
            
            let label = self.coldTestnetArray[indexPath.row]["label"] as! String
            let address = self.coldTestnetArray[indexPath.row]["address"] as! String
            let balance = self.coldTestnetArray[indexPath.row]["balance"] as! String
            
            if label != "" {
                
                nameLabel.text = "\(label)"
                //nameLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 100, height: 40)
                //nameLabel.adjustsFontSizeToFitWidth = true
                
            } else {
                
                nameLabel.text = "\(address)"
                //nameLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 200, height: 40)
                //nameLabel.adjustsFontSizeToFitWidth = true
                
            }
            
            balanceLabel.text = "\(balance)"
            
        }
        
        if multiSigMode {
            
            if cell.isSelected {
                
                cell.isSelected = false
                
                if cell.accessoryType == UITableViewCellAccessoryType.none {
                    
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    
                } else {
                    
                    cell.accessoryType = UITableViewCellAccessoryType.none
                    
                }
                
            }
            
        }
        
         nameLabel.adjustsFontSizeToFitWidth = true
         balanceLabel.adjustsFontSizeToFitWidth = true
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 && self.hotMainnetArray.count > 0 {
            
            return "Hot - Mainnet"
            
        } else if section == 1 && self.hotTestnetArray.count > 0 {
            
            return "Hot - Testnet"
            
        } else if section == 2 && self.coldMainnetArray.count > 0 {
            
            return "Cold - Mainnet"
            
        } else if section == 3 && self.coldTestnetArray.count > 0 {
            
            return "Cold - Testnet"
            
        }
        
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        tableView.allowsMultipleSelection = true
        
        let cell = tableView.cellForRow(at: indexPath)!
        
       if indexPath.section == 0 {
            
            for (index, wallet) in self.addressBook.enumerated() {
                
                if self.hotMainnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String {
                    
                    if multiSigMode != true {
                        
                        if cell.isSelected {
                            
                            cell.isSelected = false
                            cell.accessoryType = UITableViewCellAccessoryType.none
                            
                        }
                        self.wallet = wallet
                      self.showKeyManagementAlert(wallet: self.addressBook[index], cell: cell)
                        self.showButtonView()
                        
                        
                    } else {
                        
                        if self.addressBook[index]["publicKey"] as! String != "" {
                            
                            if cell.isSelected {
                                
                                cell.isSelected = false
                                
                                if cell.accessoryType == UITableViewCellAccessoryType.none {
                                    
                                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                                    self.keyArray.append(self.addressBook[index])
                                    print("keyArray = \(self.keyArray)")
                                    
                                } else {
                                    
                                    cell.accessoryType = UITableViewCellAccessoryType.none
                                    
                                    for (index2, key) in self.keyArray.enumerated() {
                                        
                                        if key["address"] as! String == self.addressBook[index]["address"] as! String {
                                            
                                            self.keyArray.remove(at: index2)
                                            
                                            if keyArray.count == 0 {
                                                
                                                self.multiSigMode = false
                                                
                                            }
                                        }
                                    }
                                    
                                }
                                
                            }
                            
                        } else {
                            
                            if cell.isSelected {
                                
                                cell.isSelected = false
                                cell.accessoryType = UITableViewCellAccessoryType.none
                            }
                            
                            displayAlert(viewController: self, title: "Error", message: "This wallet does not contain a public key and therefore we can not use it to create a multi sig wallet.")
                            
                        }
                        
                    }
                    
                }
                
            }
            
        } else if indexPath.section == 1 {
            
            for (index, wallet) in self.addressBook.enumerated() {
                
                if self.hotTestnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String{
                    
                    if multiSigMode != true {
                        
                        if cell.isSelected {
                            
                            cell.isSelected = false
                            cell.accessoryType = UITableViewCellAccessoryType.none
                            
                        }
                        self.wallet = wallet
                        self.showKeyManagementAlert(wallet: self.addressBook[index], cell: cell)
                        showButtonView()
                        
                    } else {
                        
                        if self.addressBook[index]["publicKey"] as! String != "" {
                            
                            if cell.isSelected {
                                
                                cell.isSelected = false
                                
                                if cell.accessoryType == UITableViewCellAccessoryType.none {
                                    
                                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                                    self.keyArray.append(self.addressBook[index])
                                    print("keyArray = \(self.keyArray)")
                                    
                                } else {
                                    
                                    cell.accessoryType = UITableViewCellAccessoryType.none
                                    
                                    for (index2, key) in self.keyArray.enumerated() {
                                        
                                        if key["address"] as! String == self.addressBook[index]["address"] as! String {
                                            
                                            self.keyArray.remove(at: index2)
                                            
                                            if keyArray.count == 0 {
                                                
                                                self.multiSigMode = false
                                                
                                            }
                                        }
                                    }
                                }
                                
                            }
                            
                        } else {
                            
                            if cell.isSelected {
                                
                                cell.isSelected = false
                                cell.accessoryType = UITableViewCellAccessoryType.none
                            }
                            
                            displayAlert(viewController: self, title: "Error", message: "This wallet does not contain a public key and therefore we can not use it to create a multi sig wallet.")
                            
                        }
                        
                    }
                    
                }
                
            }
            
        } else if indexPath.section == 2 {
            
            for (index, wallet) in self.addressBook.enumerated() {
                
                if self.coldMainnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String{
                    
                    if multiSigMode != true {
                        
                        if cell.isSelected {
                            
                            cell.isSelected = false
                            cell.accessoryType = UITableViewCellAccessoryType.none
                            
                        }
                        self.wallet = wallet
                        self.showKeyManagementAlert(wallet: self.addressBook[index], cell: cell)
                        showButtonView()
                        
                    } else {
                        
                        if self.addressBook[index]["publicKey"] as! String != "" {
                            
                            if cell.isSelected {
                                
                                cell.isSelected = false
                                
                                if cell.accessoryType == UITableViewCellAccessoryType.none {
                                    
                                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                                    self.keyArray.append(self.addressBook[index])
                                    print("keyArray = \(self.keyArray)")
                                    
                                } else {
                                    
                                    cell.accessoryType = UITableViewCellAccessoryType.none
                                    
                                    for (index2, key) in self.keyArray.enumerated() {
                                        
                                        if key["address"] as! String == self.addressBook[index]["address"] as! String {
                                            
                                            self.keyArray.remove(at: index2)
                                            
                                            if keyArray.count == 0 {
                                                
                                                self.multiSigMode = false
                                                
                                            }
                                        }
                                    }
                                }
                                
                            }
                            
                        } else {
                            
                            if cell.isSelected {
                                
                                cell.isSelected = false
                                cell.accessoryType = UITableViewCellAccessoryType.none
                            }
                            
                            displayAlert(viewController: self, title: "Error", message: "This wallet does not contain a public key and therefore we can not use it to create a multi sig wallet.")
                        }
                        
                    }
                    
                }
                
            }
            
        } else if indexPath.section == 3 {
            
            for (index, wallet) in self.addressBook.enumerated() {
                
                if self.coldTestnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String{
                    
                    if multiSigMode != true {
                        
                        if cell.isSelected {
                            
                            cell.isSelected = false
                            cell.accessoryType = UITableViewCellAccessoryType.none
                            
                        }
                        
                        self.showKeyManagementAlert(wallet: self.addressBook[index], cell: cell)
                        self.wallet = wallet
                        showButtonView()
                        
                    } else {
                        
                        if self.addressBook[index]["publicKey"] as! String != "" {
                           
                            if multiSigMode {
                                
                                if cell.isSelected {
                                    
                                    cell.isSelected = false
                                    
                                    if cell.accessoryType == UITableViewCellAccessoryType.none {
                                        
                                        cell.accessoryType = UITableViewCellAccessoryType.checkmark
                                        self.keyArray.append(self.addressBook[index])
                                        print("keyArray = \(self.keyArray)")
                                        
                                    } else {
                                        
                                        cell.accessoryType = UITableViewCellAccessoryType.none
                                        
                                        for (index2, key) in self.keyArray.enumerated() {
                                            
                                            if key["address"] as! String == self.addressBook[index]["address"] as! String {
                                                
                                                self.keyArray.remove(at: index2)
                                                
                                                if keyArray.count == 0 {
                                                    
                                                    self.multiSigMode = false
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                        } else {
                            
                            if cell.isSelected {
                                
                                cell.isSelected = false
                                cell.accessoryType = UITableViewCellAccessoryType.none
                            }
                            
                            displayAlert(viewController: self, title: "Error", message: "This wallet does not contain a public key and therefore we can not use it to create a multi sig wallet.")
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if ableToDelete {
            
            return true
            
        } else {
            
            return false
            
        }
        
     }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
       if editingStyle == .delete {
            
            func deleteCell() {
                
                let cell = self.addressBookTable.cellForRow(at: indexPath)!
                let balanceLabel = cell.viewWithTag(1) as! UILabel
                
                var allowDelete = Bool()
                
                for addr in self.addressBook {
                    
                    if (addr["address"] as! String).hasPrefix("tb") {
                        
                        allowDelete = true
                        
                    }
                }
                
                if isInternetAvailable() == false || balanceLabel.text != "" || allowDelete != false {
                    
                    if indexPath.section == 0 {
                        
                        for (index, wallet) in self.addressBook.enumerated() {
                            
                            if self.hotMainnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String {
                                
                                DispatchQueue.main.async {
                                    
                                    let alert = UIAlertController(title: "WARNING!", message: "You will lose this wallet FOREVER if you delete it, please ensure you have it backed up first.", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (action) in
                                        
                                        self.addressBook.remove(at: index)
                                        self.removeWallet(address: wallet["address"] as! String)
                                        self.hotMainnetArray.remove(at: indexPath.row)
                                        tableView.deleteRows(at: [indexPath], with: .fade)
                                        
                                    }))
                                    
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                                        
                                        
                                    }))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                }
                                
                            }
                            
                        }
                        
                    } else if indexPath.section == 1 {
                        
                        for (index, wallet) in self.addressBook.enumerated() {
                            
                            if self.hotTestnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String {
                                
                                DispatchQueue.main.async {
                                    
                                    let alert = UIAlertController(title: "WARNING!", message: "You will lose this wallet FOREVER if you delete it, please ensure you have it backed up first.", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (action) in
                                        
                                        self.addressBook.remove(at: index)
                                        self.removeWallet(address: wallet["address"] as! String)
                                        self.hotTestnetArray.remove(at: indexPath.row)
                                        tableView.deleteRows(at: [indexPath], with: .fade)
                                        
                                    }))
                                    
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                                        
                                        
                                    }))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                }
                                
                            }
                            
                        }
                        
                    } else if indexPath.section == 2 {
                        
                        for (index, wallet) in self.addressBook.enumerated() {
                            
                            if self.coldMainnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String {
                                
                                DispatchQueue.main.async {
                                    
                                    let alert = UIAlertController(title: "WARNING!", message: "You will lose this wallet FOREVER if you delete it, please ensure you have it backed up first.", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (action) in
                                        
                                        self.addressBook.remove(at: index)
                                        self.removeWallet(address: wallet["address"] as! String)
                                        self.coldMainnetArray.remove(at: indexPath.row)
                                        tableView.deleteRows(at: [indexPath], with: .fade)
                                        
                                    }))
                                    
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                                        
                                        
                                    }))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                }
                                
                            }
                            
                        }
                        
                    } else if indexPath.section == 3 {
                        
                        for (index, wallet) in self.addressBook.enumerated() {
                            
                            if self.coldTestnetArray[indexPath.row]["address"] as! String == wallet["address"] as! String {
                                
                                DispatchQueue.main.async {
                                    
                                    let alert = UIAlertController(title: "WARNING!", message: "You will lose this wallet FOREVER if you delete it, please ensure you have it backed up first.", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (action) in
                                        
                                        self.addressBook.remove(at: index)
                                        self.removeWallet(address: wallet["address"] as! String)
                                        self.coldTestnetArray.remove(at: indexPath.row)
                                        tableView.deleteRows(at: [indexPath], with: .fade)
                                        
                                    }))
                                    
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                                        
                                        
                                    }))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                
            }
        
        func authenticateDeleteWithTouchID() {
            
            let localAuthenticationContext = LAContext()
            localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
            
            var authError: NSError?
            let reasonString = "To Delete a Wallet"
            
            if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                
                localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                    
                    if success {
                        
                        deleteCell()
                        
                    } else {
                        //TODO: User did not authenticate successfully, look at error and take appropriate action
                        guard let error = evaluateError else {
                            return
                        }
                        
                        displayAlert(viewController: self, title: "Error", message: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                        
                        print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                        
                        //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                        
                    }
                }
            } else {
                
                guard let error = authError else {
                    return
                }
                //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
                displayAlert(viewController: self, title: "Error", message: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
            }
            
        }
            
            if UserDefaults.standard.object(forKey: "bioMetricsEnabled") != nil {
                
                authenticateDeleteWithTouchID()
                
            } else if let _ = KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
                
                var password = String()
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Please input your password", message: "Please enter your password to delete a wallet", preferredStyle: .alert)
                    
                    alert.addTextField { (textField1) in
                        
                        textField1.placeholder = "Enter Password"
                        textField1.isSecureTextEntry = true
                        
                    }
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (action) in
                        
                        password = alert.textFields![0].text!
                        
                        if password == KeychainWrapper.standard.string(forKey: "unlockAESPassword") {
                            
                            deleteCell()
                            
                        } else {
                            
                            displayAlert(viewController: self, title: "Error", message: "Incorrect password!")
                        }
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                        
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
            } else {
                
                deleteCell()
                
            }
            
        }
        
     }
    
    func processKeyAndSegue() {
        
        //check if valid if not decrypt
        if let _ = BTCPrivateKeyAddressTestnet.init(string: self.privateKeyToExport) {
            
            self.performSegue(withIdentifier: "goHome", sender: self)
            
        } else if let _ = BTCPrivateKeyAddress.init(string: self.privateKeyToExport) {
            
            self.performSegue(withIdentifier: "goHome", sender: self)
            
        } else {
            
            if self.privateKeyToExport != "" {
                
                let password = KeychainWrapper.standard.string(forKey: "AESPassword")!
                let decrypted = AES256CBC.decryptString(self.privateKeyToExport, password: password)!
                self.privateKeyToExport = decrypted
                self.performSegue(withIdentifier: "goHome", sender: self)
                
            } else {
                
                self.performSegue(withIdentifier: "goHome", sender: self)
                
            }
            
            
            
        }
    }
    
    func showKeyManagementAlert(wallet: [String: Any], cell: UITableViewCell) {
        print("showKeyManagementAlert")
        
        if self.multiSigMode != true {
            
            //self.wallet = wallet
            self.tappedCell = cell
            
        }
        
    }
    
    func checkBalance(address: String, index: Int, network: String, type: String) {
        print("checkBalance")
        
        ableToDelete = false
        addSpinner()
        var url:NSURL!
        var btcAmount = ""
        
        func getSegwitBalance() {
            
            let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
                
                do {
                    
                    if error != nil {
                        
                        print(error as Any)
                        self.removeSpinner()
                        
                    } else {
                        
                        if let urlContent = data {
                            
                            do {
                                
                                let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                                
                                if let btcAmountCheck = ((jsonAddressResult["data"] as? NSArray)?[0] as? NSDictionary)?["sum_value_unspent"] as? Double {
                                    
                                    let btcAmount = btcAmountCheck.avoidNotation
                                    
                                    if network == "mainnet" && type == "hot" {
                                        
                                        self.hotMainnetArray[index]["balance"] = btcAmount + " BTC"
                                        DispatchQueue.main.async {
                                            UIImpactFeedbackGenerator().impactOccurred()
                                        }
                                        
                                    } else if network == "testnet" && type == "hot" {
                                        
                                        self.hotTestnetArray[index]["balance"] = btcAmount + " tBTC"
                                        DispatchQueue.main.async {
                                            UIImpactFeedbackGenerator().impactOccurred()
                                        }
                                        
                                    } else if network == "mainnet" && type == "cold" {
                                        
                                        self.coldMainnetArray[index]["balance"] = btcAmount + " BTC"
                                        DispatchQueue.main.async {
                                            UIImpactFeedbackGenerator().impactOccurred()
                                        }
                                        
                                    } else if network == "testnet" && type == "cold" {
                                        
                                        self.coldTestnetArray[index]["balance"] = btcAmount + " tBTC"
                                        DispatchQueue.main.async {
                                            UIImpactFeedbackGenerator().impactOccurred()
                                        }
                                        
                                    }
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.addressBookTable.reloadData()
                                        self.removeSpinner()
                                        
                                    }
                                    
                                } else {
                                    
                                    self.removeSpinner()
                                    
                                }
                                
                            } catch {
                                
                                print("JSon processing failed")
                                self.removeSpinner()
                                
                            }
                        }
                    }
                }
            }
            
            task.resume()
        }
        
        func getLegacyBalance() {
          
            let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
                
                do {
                    
                    if error != nil {
                        
                        print(error as Any)
                        self.removeSpinner()
                        
                    } else {
                        
                        if let urlContent = data {
                            
                            do {
                                
                                let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                                
                                if let finalBalanceCheck = jsonAddressResult["final_balance"] as? Double {
                                    
                                    btcAmount = (finalBalanceCheck / 100000000).avoidNotation
                                    
                                    if network == "mainnet" && type == "hot" {
                                        
                                        self.hotMainnetArray[index]["balance"] = btcAmount + " BTC"
                                        DispatchQueue.main.async {
                                            UIImpactFeedbackGenerator().impactOccurred()
                                        }
                                        
                                    } else if network == "testnet" && type == "hot" {
                                        
                                        self.hotTestnetArray[index]["balance"] = btcAmount + " tBTC"
                                        DispatchQueue.main.async {
                                            UIImpactFeedbackGenerator().impactOccurred()
                                        }
                                        
                                    } else if network == "mainnet" && type == "cold" {
                                        
                                        self.coldMainnetArray[index]["balance"] = btcAmount + " BTC"
                                        DispatchQueue.main.async {
                                            UIImpactFeedbackGenerator().impactOccurred()
                                        }
                                        
                                    } else if network == "testnet" && type == "cold" {
                                        
                                        self.coldTestnetArray[index]["balance"] = btcAmount + " tBTC"
                                        DispatchQueue.main.async {
                                            UIImpactFeedbackGenerator().impactOccurred()
                                        }
                                        
                                    }
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.addressBookTable.reloadData()
                                        self.removeSpinner()
                                        
                                        
                                    }
                                    
                                } else {
                                    
                                    self.removeSpinner()
                                    
                                }
                                
                            } catch {
                                
                                print("JSon processing failed")
                                self.removeSpinner()
                            }
                        }
                    }
                }
            }
            
            task.resume()
            
        }
        
        func getTestNetBalance() {
            
            let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
                
                do {
                    
                    if error != nil {
                        
                        print(error as Any)
                        self.removeSpinner()
                        
                    } else {
                        
                        if let urlContent = data {
                            
                            do {
                                
                                let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                                
                                if let finalBalanceCheck = jsonAddressResult["balance"] as? Double {
                                    
                                    btcAmount = (finalBalanceCheck / 100000000).avoidNotation
                                    
                                    if network == "mainnet" && type == "hot" {
                                        
                                        self.hotMainnetArray[index]["balance"] = btcAmount + " BTC"
                                        DispatchQueue.main.async {
                                            UIImpactFeedbackGenerator().impactOccurred()
                                        }
                                        
                                    } else if network == "testnet" && type == "hot" {
                                        
                                        self.hotTestnetArray[index]["balance"] = btcAmount + " tBTC"
                                        DispatchQueue.main.async {
                                            UIImpactFeedbackGenerator().impactOccurred()
                                        }
                                        
                                    } else if network == "mainnet" && type == "cold" {
                                        
                                        self.coldMainnetArray[index]["balance"] = btcAmount + " BTC"
                                        DispatchQueue.main.async {
                                            UIImpactFeedbackGenerator().impactOccurred()
                                        }
                                        
                                    } else if network == "testnet" && type == "cold" {
                                        
                                        self.coldTestnetArray[index]["balance"] = btcAmount + " tBTC"
                                            DispatchQueue.main.async {
                                            UIImpactFeedbackGenerator().impactOccurred()
                                        }
                                        
                                        
                                    }
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.addressBookTable.reloadData()
                                        self.removeSpinner()
                                        
                                    }
                                    
                                } else {
                                    
                                    self.removeSpinner()
                                    
                                }
                                
                            } catch {
                                
                                print("JSon processing failed")
                                self.removeSpinner()
                            }
                        }
                    }
                }
            }
            
            task.resume()
            
        }
        
        if address.hasPrefix("1") || address.hasPrefix("3") {
            
            url = NSURL(string: "https://blockchain.info/rawaddr/\(address)")
            getLegacyBalance()
            
        } else if address.hasPrefix("m") || address.hasPrefix("2") || address.hasPrefix("n") {
            
            url = NSURL(string: "https://api.blockcypher.com/v1/btc/test3/addrs/\(address)/balance?token=a9d88ea606fb4a92b5134d34bc1cb2a0")
            
            getTestNetBalance()
            
        } else if address.hasPrefix("b") {
            
            url = NSURL(string: "https://api.blockchair.com/bitcoin/dashboards/address/\(address)")
            getSegwitBalance()
            
        } else if address.hasPrefix("t") {
            
            displayAlert(viewController: self, title: "Error", message: "We are unable to find a balance for address: \(address).\n\nWe can not find a testnet blockexplorer that is bech32 compatible, if you know of one please email us at tripkeyapp@gmail.com")
            
        }
        
        
    }
    
    func addSpinner() {
        
        /*DispatchQueue.main.async {
            
            if self.imageView != nil {
              self.imageView.removeFromSuperview()
            }
            let bitcoinImage = UIImage(named: "Bitsense image.png")
            self.imageView = UIImageView(image: bitcoinImage!)
            self.imageView.center = self.view.center
            self.imageView.frame = CGRect(x: self.view.center.x - 25, y: 20, width: 50, height: 50)
            rotateAnimation(imageView: self.imageView as! UIImageView)
            self.view.addSubview(self.imageView)
            
        }*/
        
    }
    
    func removeSpinner() {
        
        DispatchQueue.main.async {
            
            self.activityIndicator.stopAnimating()
            self.refresher.endRefreshing()
            self.ableToDelete = true
            
        }
    }
    
    func removeWallet(address: String) {
        
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
                
                for (index, data) in results.enumerated() {
                    
                    if address == data.value(forKey: "address") as? String {
                            
                        context.delete(results[index] as NSManagedObject)
                        print("deleted succesfully")
                        
                        do {
                            
                            try context.save()
                            
                        } catch {
                            
                            print("error deleting")
                        }
                        
                    }
                    
                }
                
            } else {
                
                print("no results")
                
            }
            
        } catch {
            
            print("Failed")
            
        }
    }
    
    func editWallet(address: String, newValue: String, oldValue: String, keyToEdit: String) {
        
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
                    
                    if address == data.value(forKey: "address") as? String {
                        
                        if keyToEdit == "label" {
                            
                            data.setValue(newValue, forKey: keyToEdit)
                            displayAlert(viewController: self, title: "Success", message: "You updated \"\(oldValue)\" to \"\(newValue)\". Swipe the table to refresh it.")
                            
                        } else if keyToEdit == "privateKey" {
                            
                            data.setValue(newValue, forKey: keyToEdit)
                            data.setValue("cold", forKey: "type")
                            displayAlert(viewController: self, title: "Success", message: "The wallet is now cold. Swipe the table to refresh it.")
                            
                        } else {
                            
                            data.setValue(newValue, forKey: keyToEdit)
                            
                        }
                        
                        print("edited succesfully")
                        
                        do {
                            
                            try context.save()
                            
                        } catch {
                            
                            print("error editing")
                            
                        }
                        
                    }
                    
                }
                
            } else {
                
                print("no results")
                
            }
            
        } catch {
            
            print("Failed")
            
        }
    }
    
    
    func authenticationWithTouchID() {
        
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
        
        var authError: NSError?
        var reasonString = "To Export a Private Key"
        
        if self.editWalletMode {
            
            reasonString = "To edit a wallet"
        }
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    if self.editWalletMode {
                        
                        self.editNow()
                        
                        self.editWalletMode = false
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            
                            self.processKeyAndSegue()
                            
                        }
                    }
                    
                    
                } else {
                    //TODO: User did not authenticate successfully, look at error and take appropriate action
                    guard let error = evaluateError else {
                        return
                    }
                    
                    displayAlert(viewController: self, title: "Error", message: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    
                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                    
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            displayAlert(viewController: self, title: "Error", message: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    
}
