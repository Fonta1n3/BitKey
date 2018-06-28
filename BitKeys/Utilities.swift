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


public func isWalletEncryptedFromCoreData() -> Bool {
    
    var bool = Bool()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Wallet")
    //request.predicate = NSPredicate(format: "age = %@", "12")
    request.returnsObjectsAsFaults = false
    do {
        
        let result = try context.fetch(request)
        
        for data in result as! [NSManagedObject] {
            
            bool = data.value(forKey: "isEncrypted") as! Bool
        }
        
    } catch {
        
        print("Failed")
        
    }
    
    return bool
}

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

public extension Double {
    
    func withCommas() -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
    
}

public extension UITextField {
    
    func addNextButtonToKeyboard(myAction:Selector){
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: MultiSigCreatorViewController(), action: myAction)
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.inputAccessoryView = doneToolbar
        
    }
}
