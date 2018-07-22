//
//  LogInViewController.swift
//  BitKeys
//
//  Created by Peter on 7/18/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import LocalAuthentication

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    let passwordInput = UITextField()
    let labelTitle = UILabel()
    let lockView = UIView()
    let touchIDButton = UIButton()
    let imageView = UIImageView()
    let fingerPrintView = UIImageView()
    var viewdidJustLoad = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordInput.delegate = self
        lockView.frame = self.view.frame
        lockView.backgroundColor = UIColor.black
        lockView.alpha = 1
        lockView.removeFromSuperview()
        view.addSubview(lockView)
        
        imageView.image = UIImage(named: "whiteLock.png")
        imageView.alpha = 1
        imageView.frame = CGRect(x: self.view.center.x - 40, y: 40, width: 80, height: 80)
        imageView.removeFromSuperview()
        lockView.addSubview(imageView)
        
        passwordInput.frame = CGRect(x: 50, y: imageView.frame.maxY + 80, width: view.frame.width - 100, height: 50)
        passwordInput.keyboardType = UIKeyboardType.default
        passwordInput.layer.cornerRadius = 10
        passwordInput.backgroundColor = UIColor.white
        passwordInput.alpha = 0
        passwordInput.textColor = UIColor.black
        passwordInput.placeholder = "Password"
        passwordInput.isSecureTextEntry = true
        passwordInput.returnKeyType = UIReturnKeyType.go
        passwordInput.textAlignment = .center
        passwordInput.keyboardAppearance = UIKeyboardAppearance.dark
        
        labelTitle.frame = CGRect(x: self.view.center.x - ((view.frame.width - 100) / 2), y: passwordInput.frame.minY - 50, width: view.frame.width - 100, height: 50)
        labelTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 30)
        labelTitle.textColor = UIColor.white
        labelTitle.alpha = 0
        labelTitle.numberOfLines = 0
        labelTitle.text = "Unlock"
        labelTitle.textAlignment = .center
        
        touchIDButton.frame = CGRect(x: view.center.x - 50, y: view.frame.maxY - 140, width: 100, height: 100)
        touchIDButton.setImage(UIImage(named: "greenFingerPrint.png"), for: .normal)
        touchIDButton.backgroundColor = UIColor.clear
        touchIDButton.alpha = 0
        touchIDButton.addTarget(self, action: #selector(authenticationWithTouchID), for: .touchUpInside)
        
        showUnlockScreen()
        
        viewdidJustLoad = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        
    }
    
    func showUnlockScreen() {
        
        viewdidJustLoad = false
        
        if UserDefaults.standard.object(forKey: "bioMetricsEnabled") != nil && UserDefaults.standard.object(forKey: "bioMetricsEnabled") as! Bool {
            
            self.lockView.addSubview(self.touchIDButton)
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.touchIDButton.alpha = 1
                
            }, completion: { _ in
                
                self.authenticationWithTouchID()
                
                DispatchQueue.main.async {
                    UIImpactFeedbackGenerator().impactOccurred()
                }
                
            })
            
        } else {
            
            self.passwordInput.removeFromSuperview()
            lockView.addSubview(passwordInput)
            passwordInput.becomeFirstResponder()
            self.labelTitle.removeFromSuperview()
            lockView.addSubview(labelTitle)
            
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.passwordInput.alpha = 1
                self.labelTitle.alpha = 1
                
            })
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        print("textFieldDidEndEditing")
        
        let retrievedPassword: String? = KeychainWrapper.standard.string(forKey: "unlockAESPassword")
        
        if self.passwordInput.text != "" {
            
            if self.passwordInput.text! == retrievedPassword {
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.lockView.alpha = 0
                    self.passwordInput.alpha = 0
                    self.labelTitle.alpha = 0
                    
                }, completion: { _ in
                    
                    self.dismiss(animated: true, completion: nil)
                    
                })
                
            } else {
                
                displayAlert(viewController: self, title: "Error", message: "Wrong password!")
            }
            
        } else {
            
            shakeAlert(viewToShake: self.passwordInput)
        }
    }
    
    func fallbackToPassword() {
        
        DispatchQueue.main.async {
            
            self.passwordInput.removeFromSuperview()
            self.lockView.addSubview(self.passwordInput)
            self.passwordInput.becomeFirstResponder()
            self.labelTitle.removeFromSuperview()
            self.lockView.addSubview(self.labelTitle)
            
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            
            self.touchIDButton.removeFromSuperview()
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.passwordInput.alpha = 1
                self.labelTitle.alpha = 1
            })
        }

    }
    
    @objc func authenticationWithTouchID() {
        print("authenticationWithTouchID")
        
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Password"
        
        var authError: NSError?
        let reasonString = "To Unlock"
        
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    print("success")
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    
                } else {
                    //TODO: User did not authenticate successfully, look at error and take appropriate action
                    guard let error = evaluateError else {
                        return
                    }
                    
                    
                    
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    
                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                    
                    /*if self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code) == "The user chose to use the fallback" || self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code) == "Too many failed attempts." {
                        
                        //self.fallbackToPassword()
                        
                    } else {
                        displayAlert(viewController: self, title: "Error", message: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    }*/
                    
                    //displayAlert(viewController: self, title: "Error", message: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            if self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code) != "Too many failed attempts." {
               
            }
            //displayAlert(viewController: self, title: "Error", message: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
            //self.fallbackToPassword()
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    
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
            self.fallbackToPassword()
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            self.fallbackToPassword()
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            self.fallbackToPassword()
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            //self.fallbackToPassword()
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            self.fallbackToPassword()
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            self.fallbackToPassword()
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            self.fallbackToPassword()
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            self.fallbackToPassword()
            
        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }

}

extension UIViewController {
    
    func topViewController() -> UIViewController! {
        if self.isKind(of: UITabBarController.self) {
            let tabbarController =  self as! UITabBarController
            return tabbarController.selectedViewController!.topViewController()
        } else if (self.isKind(of: UINavigationController.self)) {
            let navigationController = self as! UINavigationController
            return navigationController.visibleViewController!.topViewController()
        } else if ((self.presentedViewController) != nil){
            let controller = self.presentedViewController
            return controller!.topViewController()
        } else {
            return self
        }
    }
    
}
