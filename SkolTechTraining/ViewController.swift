//
//  ViewController.swift
//  SkolTechTraining
//
//  Created by Денис Тисов on 23/01/16.
//  Copyright © 2016 Денис Тисов. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var valueAtMaturity: UITextField!
    @IBOutlet var interestRate: UITextField!
    @IBOutlet var numberOfPayments: UITextField!
    @IBOutlet var couponPayments: UITextField!
    @IBOutlet var marketPrice: UITextField!
    
    let url : String = "http://192.168.0.104:8080"
    
    
    var taskId : String! = ""
    var returnedMarketPrice : String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        marketPrice.enabled = false
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sendPostRequest(objectForRequest : Dictionary<String, AnyObject> ) {
        var request = NSMutableURLRequest(URL: NSURL(string: "\(url)/calculator")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        
        
        do{
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(objectForRequest, options: NSJSONWritingOptions(rawValue: 0))
            print(NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding))
            
            // use jsonData
        } catch {
            print("Error while creating json")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        //        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            print("Body: \(strData)")
            
            self.taskId = String(strData)
            var err: NSError?
            var json : NSDictionary!
            do{
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSDictionary
                
            } catch {
                print("Error while getting response")
            }

                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    var success = parseJSON["success"] as? String
                    print("Succes: \(success)")
                    
                }
                
            
        })
        
        task.resume()

    }
    


    @IBAction func buttonOnClickEvent(sender: AnyObject) {
        
        sendPostRequest(["valueAtMaturity": self.valueAtMaturity.text!,
            "interestRate": self.interestRate.text!,
            "numberOfPayments": self.numberOfPayments.text!,
            "couponPayment" : self.couponPayments.text!,
            "marketPrice" : ""])
        
        while(self.taskId == ""){
            
        }
        
        
        sendGetRequest({ (responseData:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            do{
                var json = try NSJSONSerialization.JSONObjectWithData(responseData!, options: .AllowFragments) as? NSDictionary
                
                if let item = json!["marketPrice"]  {
                       print("Market price: \(item)")
                        self.returnedMarketPrice = String(item)
                }
                
            } catch {
                print("Error while getting response")
            }
            
        })
        
        while(self.returnedMarketPrice == ""){
            
        
    }
    self.marketPrice.text = self.returnedMarketPrice
        
    }
    
    func sendGetRequest(completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> Void {
        if let id = self.taskId {
            print("Task id \(taskId!)")
            let requestURL = NSURL(string:"\(self.url)/bond/\(id)")!
            
            let request = NSMutableURLRequest(URL: requestURL)
            request.HTTPMethod = "GET"
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler:completionHandler)
            task.resume()
        }
        
        
    }

}

