//
//  MayerMultipleViewController.swift
//  BitKeys
//
//  Created by Peter on 3/21/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit

class MayerMultipleViewController: UIViewController {
    
    var imageView:UIView!
    var button = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("MayerMultipleViewController")
        
        self.button = UIButton(frame: CGRect(x: 5, y: 20, width: 100 , height: 55))
        self.button.showsTouchWhenHighlighted = true
        self.button.layer.cornerRadius = 10
        self.button.backgroundColor = UIColor.lightGray
        self.button.layer.shadowColor = UIColor.black.cgColor
        self.button.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        self.button.layer.shadowRadius = 2.5
        self.button.layer.shadowOpacity = 0.8
        self.button.setTitle("Back", for: .normal)
        self.button.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        self.view.addSubview(self.button)
        
        getMayerMultiple()
    }
    
    func rotateAnimation(imageView:UIImageView,duration: CFTimeInterval = 2.0) {
        
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(.pi * 8.0)
            rotateAnimation.duration = duration
            rotateAnimation.repeatCount = Float.greatestFiniteMagnitude;
            imageView.layer.add(rotateAnimation, forKey: nil)
        
    }
    
    func addSpinner() {
        
            let bitcoinImage = UIImage(named: "bitcoinIcon.png")
            self.imageView = UIImageView(image: bitcoinImage!)
            self.imageView.center = self.view.center
            self.imageView.frame = CGRect(x: self.view.center.x - 100, y: self.view.center.y - 100, width: 200, height: 200)
            self.rotateAnimation(imageView: self.imageView as! UIImageView)
            self.view.addSubview(self.imageView)
        
    }
    
    func removeSpinner() {
        
        DispatchQueue.main.async {
            self.imageView.removeFromSuperview()
        }
    }

    @objc func goBack() {
        
        self.dismiss(animated: false, completion: nil)
    }
    
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
    }
    

    func getMayerMultiple() {
        
        
        self.addSpinner()
        var url:NSURL!
        url = NSURL(string: "https://blockchain.info/charts/market-price?timespan=200days&format=json")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    self.removeSpinner()
                    print(error as Any)
                    DispatchQueue.main.async {
                        self.displayAlert(title: "No internet connection.", message: "You need internet to check the price.")
                    }
                    
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonQuoteResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            if let prices = jsonQuoteResult["values"] as? NSArray {
                                
                                var priceArray = [Int]()
                                
                                for price in prices {
                                    
                                    let daysPrice = (price as! NSDictionary)["y"] as! Double
                                    priceArray.append(Int(daysPrice))
                                    
                                }
                                
                                let twoHundredDayMovingAverage = priceArray.average
                                
                                var url:NSURL!
                                url = NSURL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")
                                
                                let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
                                    
                                    do {
                                        
                                        if error != nil {
                                            self.removeSpinner()
                                            print(error as Any)
                                            DispatchQueue.main.async {
                                                self.displayAlert(title: "No internet connection.", message: "You need internet to check the price.")
                                            }
                                            
                                        } else {
                                            
                                            if let urlContent = data {
                                                
                                                do {
                                                    
                                                    let jsonQuoteResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                                                    
                                                    if let exchangeCheck = jsonQuoteResult["bpi"] as? NSDictionary {
                                                        
                                                        if let usdCheck = exchangeCheck["USD"] as? NSDictionary {
                                                            
                                                            if let rateCheck = usdCheck["rate_float"] as? Float {
                                                                
                                                                DispatchQueue.main.async {
                                                                    
                                                                    self.removeSpinner()
                                                                    
                                                                    let exchangeRate = Double(rateCheck)
                                                                    print("exchangeRate = \(exchangeRate)")
                                                                    let priceDifference = round(100 * (exchangeRate - twoHundredDayMovingAverage)) / 100
                                                                    let percentage = Int((priceDifference / twoHundredDayMovingAverage) * 100)
                                                                    
                                                                    let mayerMultipleLabel = UITextView()
                                                                    mayerMultipleLabel.frame = CGRect(x: self.view.frame.minX + 15, y: self.view.center.y - (self.view.frame.height / 3), width: self.view.frame.width - 30, height: 500)
                                                                    
                                                                    if priceDifference < 0 {
                                                                        
                                                                        mayerMultipleLabel.text = "The Bitcoin Mayer Multiple is \(round(100 * (exchangeRate / twoHundredDayMovingAverage)) / 100) with a current price of $\(round(100 * exchangeRate) / 100) USD and a 200 day moving average of $\(round(100 * twoHundredDayMovingAverage) / 100) USD.\n\nThe current price is $\(priceDifference) USD below the 200 day moving average.\n\nThat is a \(percentage)% deviation from the 200 day moving average."
                                                                        
                                                                    } else if priceDifference > 0 {
                                                                        
                                                                        mayerMultipleLabel.text = "The Bitcoin Mayer Multiple is \(round(100 * (exchangeRate / twoHundredDayMovingAverage)) / 100) with a current price of $\(round(100 * exchangeRate) / 100) USD and a 200 day moving average of $\(round(100 * twoHundredDayMovingAverage) / 100) USD.\n\nThe current price is $\(priceDifference) USD above the 200 day moving average.\n\nThat is a \(percentage)% deviation from the 200 day moving average."
                                                                        
                                                                    } else if priceDifference == 0 {
                                                                        
                                                                        mayerMultipleLabel.text = "The Bitcoin Mayer Multiple is \(round(100 * (exchangeRate / twoHundredDayMovingAverage)) / 100) with a current price of $\(round(100 * exchangeRate) / 100) USD and a 200 day moving average of $\(round(100 * twoHundredDayMovingAverage) / 100) USD.\n\nThe current price is equal to the 200 day moving average.\n\nThat is a \(percentage)% deviation from the 200 day moving average."
                                                                        
                                                                    }
                                                                    
                                                                    mayerMultipleLabel.textColor = UIColor.black
                                                                    mayerMultipleLabel.font = UIFont.systemFont(ofSize: 28)
                                                                    mayerMultipleLabel.textAlignment = .natural
                                                                    self.view.addSubview(mayerMultipleLabel)
                                                                    
                                                                }
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                } catch {
                                                    
                                                    print("JSon processing failed")
                                                    self.removeSpinner()
                                                    DispatchQueue.main.async {
                                                        self.displayAlert(title: "Error, please try again.", message: "")
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                
                                task.resume()
                                
                                
                            }
                            
                        } catch {
                            
                            print("JSon processing failed")
                            self.removeSpinner()
                            DispatchQueue.main.async {
                                self.displayAlert(title: "Error, please try again.", message: "")
                            }
                            
                        }
                    }
                }
            }
        }
        
        task.resume()
        
    }

}

extension Array where Element == Int {
    
    var total: Element {
        return reduce(0, +)
    }
    
    var average: Double {
        return isEmpty ? 0 : Double(reduce(0, +)) / Double(count)
    }
    
}
