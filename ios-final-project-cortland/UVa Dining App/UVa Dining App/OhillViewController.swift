//
//  OhillViewController.swift
//  UVa Dining App
//
//  Created by Michael Chang on 11/24/17.
//  Copyright © 2017 Michael Chang. All rights reserved.
//

import UIKit
import SwiftSoup
import Alamofire


class OhillViewController: UIViewController {
    var tableentries = [] as Array;
    
    @IBAction func dismissOhill(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try! NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        }
        catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request("https://virginia.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=695").responseString { response in
            if let html = response.result.value {
                let regex = "(name\">[A-Z].*)|(;\">.*</a>)"
                let matched = try! self.matches(for: regex, in: html)
                for element in matched {
                    if (element.contains(";\">")) {
                        let start = element.index(element.startIndex, offsetBy: 3)
                        let end = element.index(element.endIndex, offsetBy: -4)
                        let range = start..<end
                        var mySubstring = element[range]
                        if (mySubstring.contains("&amp;")) {
                            mySubstring = mySubstring.replace(target: "&amp;", withString:"&")
                        }
                        self.tableentries.append(mySubstring)
                    }
                    if (element.contains("name")) {
                        let start = element.index(element.startIndex, offsetBy: 6)
                        let end = element.index(element.endIndex, offsetBy: -7)
                        let range = start..<end
                        var mySubstring = element[range]
                        if (mySubstring.contains("&amp;")) {
                            mySubstring = mySubstring.replace(target: "&amp;", withString:"&")
                        }
                        self.tableentries.append(mySubstring)
                    }
                }
            }
            print(self.tableentries)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
