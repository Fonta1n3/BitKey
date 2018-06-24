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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    
    func addSpinner() {
        
        DispatchQueue.main.async {
            rotateAnimation(imageView: self.imageView as! UIImageView)
        }
        
    }
    
    func removeSpinner() {
        
        DispatchQueue.main.async {
            self.imageView.removeFromSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("MayerMultipleViewController")
        
        let bitcoinImage = UIImage(named: "Bitsense image.png")
        self.imageView = UIImageView(image: bitcoinImage!)
        self.imageView.center = self.view.center
        self.imageView.frame = CGRect(x: self.view.center.x - 25, y: 20, width: 50, height: 50)
        self.view.addSubview(self.imageView)
        
        self.button = UIButton(frame: CGRect(x: 5, y: 20, width: 55, height: 55))
        self.button.showsTouchWhenHighlighted = true
        self.button.setImage(#imageLiteral(resourceName: "back2.png"), for: .normal)
        self.button.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        self.view.addSubview(self.button)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        getMayerMultiple()
        self.addSpinner()
        
    }
    
    

    @objc func goBack() {
        
        self.dismiss(animated: true, completion: nil)
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
                        displayAlert(viewController: self, title: "No internet connection.", message: "You need internet to check the price.")
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
                                                displayAlert(viewController: self, title: "No internet connection.", message: "You need internet to check the price.")
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
                                                                    
                                                                    //if self.simpleMode {
                                                                        
                                                                        
                                                                        
                                                                    //} else {
                                                                        
                                                                        if priceDifference < 0 {
                                                                            
                                                                            mayerMultipleLabel.text = "The Bitcoin Mayer Multiple is \(round(100 * (exchangeRate / twoHundredDayMovingAverage)) / 100) with a current price of $\(round(100 * exchangeRate) / 100) USD and a 200 day moving average of $\(round(100 * twoHundredDayMovingAverage) / 100) USD.\n\nThe current price is $\(priceDifference) USD below the 200 day moving average.\n\nThat is a \(percentage)% deviation from the 200 day moving average."
                                                                            
                                                                        } else if priceDifference > 0 {
                                                                            
                                                                            mayerMultipleLabel.text = "The Bitcoin Mayer Multiple is \(round(100 * (exchangeRate / twoHundredDayMovingAverage)) / 100) with a current price of $\(round(100 * exchangeRate) / 100) USD and a 200 day moving average of $\(round(100 * twoHundredDayMovingAverage) / 100) USD.\n\nThe current price is $\(priceDifference) USD above the 200 day moving average.\n\nThat is a \(percentage)% deviation from the 200 day moving average."
                                                                            
                                                                        } else if priceDifference == 0 {
                                                                            
                                                                            mayerMultipleLabel.text = "The Bitcoin Mayer Multiple is \(round(100 * (exchangeRate / twoHundredDayMovingAverage)) / 100) with a current price of $\(round(100 * exchangeRate) / 100) USD and a 200 day moving average of $\(round(100 * twoHundredDayMovingAverage) / 100) USD.\n\nThe current price is equal to the 200 day moving average.\n\nThat is a \(percentage)% deviation from the 200 day moving average."
                                                                            
                                                                        }
                                                                        
                                                                    //}
                                                                    
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
                                                        displayAlert(viewController: self, title: "Error, please try again.", message: "")
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
                                displayAlert(viewController: self, title: "Error, please try again.", message: "")
                            }
                            
                        }
                    }
                }
            }
        }
        
        task.resume()
        
    }

}


