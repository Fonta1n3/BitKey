//
//  Utilities.swift
//  BitKeys
//
//  Created by Peter on 6/16/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import Foundation
import SystemConfiguration
import AVFoundation

public func showScanner(viewController: UIViewController, frame: CGRect, imageView: UIImageView) -> String {
    
    let avCaptureSession = AVCaptureSession()
    var stringURL = String()
    
    imageView.frame = frame
    viewController.view.addSubview(imageView)
    
    
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
        avCaptureMetadataOutput.setMetadataObjectsDelegate((viewController as! AVCaptureMetadataOutputObjectsDelegate), queue: DispatchQueue.main)
        
        if let inputs = avCaptureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                avCaptureSession.removeInput(input)
            }
        }
        
        if let outputs = avCaptureSession.outputs as? [AVCaptureMetadataOutput] {
            for output in outputs {
                avCaptureSession.removeOutput(output)
            }
        }
        
        avCaptureSession.addInput(avCaptureInput)
        avCaptureSession.addOutput(avCaptureMetadataOutput)
        
        avCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession)
        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avCaptureVideoPreviewLayer.frame = imageView.bounds
        imageView.layer.addSublayer(avCaptureVideoPreviewLayer)
        
        avCaptureSession.startRunning()
        
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
    
    enum error: Error {
        
        case noCameraAvailable
        case videoInputInitFail
        
    }
    
    return stringURL
    
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

public func checkUserDefaults() -> (addressBook: [[String: Any]], simpleMode: Bool, advancedMode: Bool, coldMode: Bool, hotMode: Bool, legacyMode: Bool, segwitMode: Bool, mainnetMode: Bool, testnetMode: Bool) {
    
    print("checkUserDefaults")
    
    var addressBook = [[String: Any]]()
    var simpleMode = Bool()
    var advancedMode = Bool()
    var coldMode = Bool()
    var hotMode = Bool()
    var legacyMode = Bool()
    var segwitMode = Bool()
    var mainnetMode = Bool()
    var testnetMode = Bool()
    
    if UserDefaults.standard.object(forKey: "addressBook") != nil {
        
        addressBook = UserDefaults.standard.object(forKey: "addressBook") as! [[String: Any]]
        print("addressBook = \(addressBook)")
        
    }
    
    if UserDefaults.standard.object(forKey: "simpleMode") != nil {
        
        simpleMode = UserDefaults.standard.object(forKey: "simpleMode") as! Bool
        
    } else {
        
        simpleMode = true
        UserDefaults.standard.set(simpleMode, forKey: "simpleMode")
        
    }
    
    if UserDefaults.standard.object(forKey: "advancedMode") != nil {
        
        advancedMode = UserDefaults.standard.object(forKey: "advancedMode") as! Bool
        
    } else {
        
        advancedMode = false
        UserDefaults.standard.set(advancedMode, forKey: "advancedMode")
        
    }
    
    if UserDefaults.standard.object(forKey: "coldMode") != nil {
        
        coldMode = UserDefaults.standard.object(forKey: "coldMode") as! Bool
        
    } else {
        
        coldMode = false
        UserDefaults.standard.set(coldMode, forKey: "coldMode")
        
    }
    
    if UserDefaults.standard.object(forKey: "hotMode") != nil {
        
        hotMode = UserDefaults.standard.object(forKey: "hotMode") as! Bool
        
    } else {
        
        hotMode = true
        UserDefaults.standard.set(hotMode, forKey: "hotMode")
        
    }
    
    if UserDefaults.standard.object(forKey: "legacyMode") != nil {
        
        legacyMode = UserDefaults.standard.object(forKey: "legacyMode") as! Bool
        
    } else {
        
        legacyMode = true
        UserDefaults.standard.set(legacyMode, forKey: "legacyMode")
        
    }
    
    if UserDefaults.standard.object(forKey: "segwitMode") != nil {
        
        segwitMode = UserDefaults.standard.object(forKey: "segwitMode") as! Bool
        
    } else {
        
        segwitMode = false
        UserDefaults.standard.set(segwitMode, forKey: "segwitMode")
        
    }
    
    if UserDefaults.standard.object(forKey: "testnetMode") != nil {
        
        testnetMode = UserDefaults.standard.object(forKey: "testnetMode") as! Bool
        
    } else {
        
        testnetMode = false
        UserDefaults.standard.set(testnetMode, forKey: "testnetMode")
        
    }
    
    if UserDefaults.standard.object(forKey: "mainnetMode") != nil {
        
        mainnetMode = UserDefaults.standard.object(forKey: "mainnetMode") as! Bool
        
    } else {
        
        mainnetMode = true
        UserDefaults.standard.set(mainnetMode, forKey: "mainnetMode")
        
    }
    
    return (addressBook, simpleMode, advancedMode, coldMode, hotMode, legacyMode, segwitMode, mainnetMode, testnetMode)
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
