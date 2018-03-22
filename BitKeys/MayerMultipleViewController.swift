//
//  MayerMultipleViewController.swift
//  BitKeys
//
//  Created by Peter on 3/21/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit

class MayerMultipleViewController: UIViewController {
    
    var button = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("MayerMultipleViewController")
        
        self.button = UIButton(frame: CGRect(x: 0, y: 0, width: 100 , height: 55))
        self.button.showsTouchWhenHighlighted = true
        self.button.backgroundColor = .black
        self.button.setTitle("Back", for: .normal)
        self.button.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        self.view.addSubview(self.button)
        
        getMayerMultiple()
    }

    @objc func goBack() {
        
        self.dismiss(animated: false, completion: nil)
    }
    

    func getMayerMultiple() {
        
        var url:NSURL!
        url = NSURL(string: "https://blockchain.info/charts/market-price?timespan=200days&format=json")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    
                    
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
                                            
                                            print(error as Any)
                                            
                                            
                                        } else {
                                            
                                            if let urlContent = data {
                                                
                                                do {
                                                    
                                                    let jsonQuoteResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                                                    
                                                    if let exchangeCheck = jsonQuoteResult["bpi"] as? NSDictionary {
                                                        
                                                        if let usdCheck = exchangeCheck["USD"] as? NSDictionary {
                                                            
                                                            if let rateCheck = usdCheck["rate_float"] as? Float {
                                                                
                                                                DispatchQueue.main.async {
                                                                    
                                                                    
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
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                
                                task.resume()
                                
                                
                            }
                            
                        } catch {
                            
                            print("JSon processing failed")
                            
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
