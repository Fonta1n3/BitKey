//
//  Utilities.swift
//  BitKeys
//
//  Created by Peter on 6/16/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import Foundation
import SystemConfiguration
import CoreData
import LocalAuthentication

public func checkAddressBook() -> [[String:Any]] {
    
    print("checkAddressBook")
    
    var addressBook = [[String:Any]]()
    
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return addressBook
    }
    
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AddressBook")
    request.returnsObjectsAsFaults = false
    request.resultType = .dictionaryResultType
    
    do {
        
        if let results = try context.fetch(request) as? [[String:Any]] {
            
            for data in results {
                
                addressBook.append(data)
                
            }
            
        }
        
        
        
    } catch {
        
        print("Failed")
        
    }
    
    return addressBook
    
}

public func checkSettingsForKey(keyValue: String) -> Bool {
    
    
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return false
    }
    
    var bool = Bool()
    
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
    
    do {
        
        if let results = try context.fetch(request) as? [NSManagedObject] {
            
            for data in results {
                
                if let _ = data.value(forKey: keyValue) as? Bool {
                    
                    bool = data.value(forKey: keyValue) as! Bool
                    
                }
                
            }
            
        }
        
        
        
    } catch {
        
        print("Failed")
        
    }
    
    return bool
}

public func checkTransactionSettingsForKey(keyValue: String) -> Any {
    
    
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return false
    }
    
    var value:Any!
    
    if keyValue == "currency" {
        
        value = String()
        
    } else if keyValue == "customFee" {
        
        value = UInt16()
        
    } else if keyValue == "high" || keyValue == "medium" || keyValue == "low" {
        
        value = Bool()
        
    }
    
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TransactionSettings")
    
    do {
        
        if let results = try context.fetch(request) as? [NSManagedObject] {
            
            for data in results {
                
                if let _ = data.value(forKey: keyValue) as? Any {
                    
                    value = data.value(forKey: keyValue) as Any
                    
                }
                
            }
            
        }
        
        
        
    } catch {
        
        print("Failed")
        
    }
    
    return value
}

public func displayAlert(viewController: UIViewController, title: String, message: String) {
    
    let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
    viewController.present(alertcontroller, animated: true, completion: nil)
    
}

public func isInternetAvailable() -> Bool {
    
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    }) else {
        return false
    }
    
    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return false
    }
    
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    return (isReachable && !needsConnection)
    
}

public func getDocumentsDirectory() -> URL {
    print("getDocumentsDirectory")
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

public func shakeAlert(viewToShake: UIView) {
    print("shakeAlert")
    
    let animation = CABasicAnimation(keyPath: "position")
    animation.duration = 0.07
    animation.repeatCount = 4
    animation.autoreverses = true
    animation.fromValue = NSValue(cgPoint: CGPoint(x: viewToShake.center.x - 10, y: viewToShake.center.y))
    animation.toValue = NSValue(cgPoint: CGPoint(x: viewToShake.center.x + 10, y: viewToShake.center.y))
    
    DispatchQueue.main.async {
        
        viewToShake.layer.add(animation, forKey: "position")
        
    }
}

public func rotateAnimation(imageView:UIImageView,duration: CFTimeInterval = 2.0) {
    
    DispatchQueue.main.async {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 8.0)
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = Float.greatestFiniteMagnitude;
        imageView.layer.add(rotateAnimation, forKey: nil)
    }
    
}

public func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
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

public func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
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

public extension Array where Element == Int {
    
    var total: Element {
        return reduce(0, +)
    }
    
    var average: Double {
        return isEmpty ? 0 : Double(reduce(0, +)) / Double(count)
    }
    
}

public extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

public extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

public extension String {
    var wordList: [String] {
        return components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
    }
}

public extension Float {
    
    var avoidNotation: String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 8
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(for: self) ?? ""
        
    }
}

public extension Int {
    
    var avoidNotation: String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 8
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(for: self) ?? ""
        
    }
}

public extension Double {
    
    var avoidNotation: String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 8
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(for: self) ?? ""
        
    }
}

public extension Int {
    
    func withCommas() -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
    
}

public extension UInt16 {
    
    func withCommas() -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
    
}

public extension Double {
    
    func withCommas() -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
    
}

public func addShadow(view: UIView) {
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        view.layer.shadowRadius = 2.5
        view.layer.shadowOpacity = 0.8
}



public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
                switch identifier {
                case "iPod5,1":                                 return "iPod Touch 5"
                case "iPod7,1":                                 return "iPod Touch 6"
                case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
                case "iPhone4,1":                               return "iPhone 4s"
                case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
                case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
                case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
                case "iPhone7,2":                               return "iPhone 6"
                case "iPhone7,1":                               return "iPhone 6 Plus"
                case "iPhone8,1":                               return "iPhone 6s"
                case "iPhone8,2":                               return "iPhone 6s Plus"
                case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
                case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
                case "iPhone8,4":                               return "iPhone SE"
                case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
                case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
                case "iPhone10,3", "iPhone10,6":                return "iPhone X"
                case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
                case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
                case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
                case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
                case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
                case "iPad6,11", "iPad6,12":                    return "iPad 5"
                case "iPad7,5", "iPad7,6":                      return "iPad 6"
                case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
                case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
                case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
                case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
                case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
                case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
                case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
                case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
                case "AppleTV5,3":                              return "Apple TV"
                case "AppleTV6,2":                              return "Apple TV 4K"
                case "AudioAccessory1,1":                       return "HomePod"
                case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
                default:                                        return identifier
                }
            #elseif os(tvOS)
                switch identifier {
                case "AppleTV5,3": return "Apple TV 4"
                case "AppleTV6,2": return "Apple TV 4K"
                case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
                default: return identifier
                }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}
    
extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
    


