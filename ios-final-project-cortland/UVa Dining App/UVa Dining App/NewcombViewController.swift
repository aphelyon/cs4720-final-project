//
//  NewcombViewController.swift
//  UVa Dining App
//
//  Created by Michael Chang on 11/19/17.
//  Copyright © 2017 Michael Chang. All rights reserved.
//

import UIKit
import SwiftSoup
import Alamofire

class NewcombViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableentries = [String]()
    var friday = false
    var saturday = false
    var sunday = false
    var weekday = false
    
    
    @IBOutlet weak var newcView: UIView!
    @IBOutlet weak var newcStatus: UILabel!
    @IBOutlet weak var currentWeekday: UILabel!
    @IBOutlet weak var operatingHours: UILabel!
    @IBOutlet weak var selector: UISegmentedControl!
    
    
    @IBAction func dismissNewcomb(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var newcTable: UITableView!
    
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableentries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "newcombTableCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MenuItemTableViewCell
        let menuItem = self.tableentries[indexPath.row]
        
        cell.menuItemName.text = menuItem
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        newcView.layer.borderWidth = 2.0
        newcView.layer.borderColor = UIColor.black.cgColor
        let date = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let dateComponents = NSDateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        dateComponents.hour = hour
        dateComponents.minute = minute
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "EST")
        if let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian),
            let date = gregorianCalendar.date(from: dateComponents as DateComponents) {
            let weekday = gregorianCalendar.component(.weekday, from: date)
            
            switch weekday {
            case 1:
                currentWeekday.text = "Sunday"
                self.sunday = true
                
            case 2:
                currentWeekday.text = "Monday"
                self.weekday = true
            case 3:
                currentWeekday.text = "Tuesday"
                self.weekday = true
                
            case 4:
                currentWeekday.text = "Wednesday"
                self.weekday = true
            case 5:
                currentWeekday.text = "Thursday"
                self.weekday = true
            case 6:
                currentWeekday.text = "Friday"
                self.friday = true
            case 7:
                currentWeekday.text = "Saturday"
                self.saturday = true
                
            default:
                print("Invalid")
            }
            let operation = gregorianCalendar.component(.weekday, from: date)
            
            switch operation {
            case 1:
                operatingHours.text = "10:00 am - 8:00 pm"
                
            case (2..<6):
                operatingHours.text = "7:00 am - 8:00 pm"
            case 6:
                operatingHours.text = "7:00 am - 2:15 pm"
            case 7:
                operatingHours.text = "10:00 am - 2:00 pm"
            default:
                print("Invalid")
            }
            
            newcStatus.text = check(time: formatter.date(from: formatter.string(from: date))! as NSDate)
            if (check(time: formatter.date(from: formatter.string(from: date))! as NSDate) == "Closed") {
                newcStatus.textColor = .red
            }
            else {
                newcStatus.textColor = .green
            }
        }
        
        
        Alamofire.request("https://virginia.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=704").responseString { response in
            if let html = response.result.value {
                if html.contains("Brunch") && html.contains("Dinner") {
                    self.selector.setTitle("Brunch", forSegmentAt: 0)
                    self.selector.setTitle("Dinner", forSegmentAt: 1)
                    Alamofire.request("https://virginia.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=704&PeriodId=1422&MenuDate=&Mode=day&UIBuildDateFrom=").responseString { response in
                        if let html2 = response.result.value {
                            let regex = "(name\">[A-Z].*)|(;\">.*</a>)"
                            let matched = try! self.matches(for: regex, in: html2)
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
                    }
                }
                else if html.contains("Brunch") {
                    self.selector.setTitle("Brunch", forSegmentAt: 0)
                    self.selector.setTitle("Brunch", forSegmentAt: 1)
                    Alamofire.request("https://virginia.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=704&PeriodId=1422&MenuDate=&Mode=day&UIBuildDateFrom=").responseString { response in
                        if let html2 = response.result.value {
                            let regex = "(name\">[A-Z].*)|(;\">.*</a>)"
                            let matched = try! self.matches(for: regex, in: html2)
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
                    }
                }

                else if self.friday {
                    self.selector.setTitle("Breakfast", forSegmentAt: 0)
                    self.selector.setTitle("Lunch", forSegmentAt: 1)
                    Alamofire.request("https://virginia.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=704&PeriodId=1421&MenuDate=&Mode=day&UIBuildDateFrom=").responseString { response in
                        if let html2 = response.result.value {
                            let regex = "(name\">[A-Z].*)|(;\">.*</a>)"
                            let matched = try! self.matches(for: regex, in: html2)
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
                    }
                }
                    
                else {
                    self.selector.setTitle("Breakfast", forSegmentAt: 0)
                    self.selector.setTitle("Lunch", forSegmentAt: 1)
                    self.selector.insertSegment(withTitle: "Dinner", at: 2, animated: true)
                    Alamofire.request("https://virginia.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=704&PeriodId=1421&MenuDate=&Mode=day&UIBuildDateFrom=").responseString { response in
                        if let html2 = response.result.value {
                            let regex = "(name\">[A-Z].*)|(;\">.*</a>)"
                            let matched = try! self.matches(for: regex, in: html2)
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
                    }
                    
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                if (self.tableentries.count != 0){
                    print(self.tableentries)
                    self.newcTable.reloadData()
                    print("2")
                    
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        if (self.tableentries.count != 0){
                            print(self.tableentries)
                            self.newcTable.reloadData()
                            print("3")
                            
                        }
                        else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                if (self.tableentries.count != 0){
                                    print(self.tableentries)
                                    self.newcTable.reloadData()
                                    print("4")
                                    
                                }
                                else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                        if (self.tableentries.count != 0){
                                            print(self.tableentries)
                                            self.newcTable.reloadData()
                                            print("5")
                                            
                                        }
                                        else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                if (self.tableentries.count != 0){
                                                    print(self.tableentries)
                                                    self.newcTable.reloadData()
                                                    print("6")
                                                    
                                                }
                                                else {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                        if (self.tableentries.count != 0){
                                                            print(self.tableentries)
                                                            self.newcTable.reloadData()
                                                            print("7")
                                                            
                                                        }
                                                        else {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                                print(self.tableentries)
                                                                self.newcTable.reloadData()
                                                                print("8")
                                                            })
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                })
                }
            })
        }
        self.selector.addTarget(self, action: #selector(segmentedControlValueChanged(segment:)), for:.valueChanged)
        self.selector.addTarget(self, action: #selector(segmentedControlValueChanged(segment:)), for:.touchUpInside)
    }
    
    func segmentedControlValueChanged(segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 && self.sunday {
            print("brunch")
            tableentries = [String]();
            Alamofire.request("https://virginia.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=704&PeriodId=1422&MenuDate=&Mode=day&UIBuildDateFrom=").responseString { response in
                if let html2 = response.result.value {
                    let regex = "(name\">[A-Z].*)|(;\">.*</a>)"
                    let matched = try! self.matches(for: regex, in: html2)
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
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                if (self.tableentries.count != 0){
                    print(self.tableentries)
                    self.newcTable.reloadData()
                    print("1")
                    
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        if (self.tableentries.count != 0){
                            print(self.tableentries)
                            self.newcTable.reloadData()
                            print("2")
                            
                        }
                        else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                if (self.tableentries.count != 0){
                                    print(self.tableentries)
                                    self.newcTable.reloadData()
                                    print("3")
                                    
                                }
                                else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                        if (self.tableentries.count != 0){
                                            print(self.tableentries)
                                            self.newcTable.reloadData()
                                            print("4")
                                            
                                        }
                                        else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                if (self.tableentries.count != 0){
                                                    print(self.tableentries)
                                                    self.newcTable.reloadData()
                                                    print("5")
                                                    
                                                }
                                                else {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                        if (self.tableentries.count != 0){
                                                            print(self.tableentries)
                                                            self.newcTable.reloadData()
                                                            print("6")
                                                            
                                                        }
                                                        else {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                                print(self.tableentries)
                                                                self.newcTable.reloadData()
                                                                print("7")
                                                            })
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            })
        }
        if segment.selectedSegmentIndex == 1 && self.sunday{
            print("dinner")
            tableentries = [String]();
            Alamofire.request("https://virginia.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=704&PeriodId=1424&MenuDate=&Mode=day&UIBuildDateFrom=").responseString { response in
                if let html2 = response.result.value {
                    let regex = "(name\">[A-Z].*)|(;\">.*</a>)"
                    let matched = try! self.matches(for: regex, in: html2)
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
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                if (self.tableentries.count != 0){
                    print(self.tableentries)
                    self.newcTable.reloadData()
                    print("1")
                    
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        if (self.tableentries.count != 0){
                            print(self.tableentries)
                            self.newcTable.reloadData()
                            print("2")
                            
                        }
                        else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                if (self.tableentries.count != 0){
                                    print(self.tableentries)
                                    self.newcTable.reloadData()
                                    print("3")
                                    
                                }
                                else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                        if (self.tableentries.count != 0){
                                            print(self.tableentries)
                                            self.newcTable.reloadData()
                                            print("4")
                                            
                                        }
                                        else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                if (self.tableentries.count != 0){
                                                    print(self.tableentries)
                                                    self.newcTable.reloadData()
                                                    print("5")
                                                    
                                                }
                                                else {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                        if (self.tableentries.count != 0){
                                                            print(self.tableentries)
                                                            self.newcTable.reloadData()
                                                            print("6")
                                                            
                                                        }
                                                        else {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                                print(self.tableentries)
                                                                self.newcTable.reloadData()
                                                                print("7")
                                                            })
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            })
        }
        
        if segment.selectedSegmentIndex == 0 && self.weekday {
            print("breakfast")
            tableentries = [String]();
            Alamofire.request("https://virginia.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=704&PeriodId=1421&MenuDate=&Mode=day&UIBuildDateFrom=").responseString { response in
                if let html2 = response.result.value {
                    let regex = "(name\">[A-Z].*)|(;\">.*</a>)"
                    let matched = try! self.matches(for: regex, in: html2)
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
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                if (self.tableentries.count != 0){
                    print(self.tableentries)
                    self.newcTable.reloadData()
                    print("1")
                    
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        if (self.tableentries.count != 0){
                            print(self.tableentries)
                            self.newcTable.reloadData()
                            print("2")
                            
                        }
                        else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                if (self.tableentries.count != 0){
                                    print(self.tableentries)
                                    self.newcTable.reloadData()
                                    print("3")
                                    
                                }
                                else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                        if (self.tableentries.count != 0){
                                            print(self.tableentries)
                                            self.newcTable.reloadData()
                                            print("4")
                                            
                                        }
                                        else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                if (self.tableentries.count != 0){
                                                    print(self.tableentries)
                                                    self.newcTable.reloadData()
                                                    print("5")
                                                    
                                                }
                                                else {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                        if (self.tableentries.count != 0){
                                                            print(self.tableentries)
                                                            self.newcTable.reloadData()
                                                            print("6")
                                                            
                                                        }
                                                        else {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                                print(self.tableentries)
                                                                self.newcTable.reloadData()
                                                                print("7")
                                                            })
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            })

        }
        
        if segment.selectedSegmentIndex == 1 && self.weekday {
            print("lunch")
            tableentries = [String]();
            Alamofire.request("https://virginia.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=704&PeriodId=1423&MenuDate=&Mode=day&UIBuildDateFrom=").responseString { response in
                if let html2 = response.result.value {
                    let regex = "(name\">[A-Z].*)|(;\">.*</a>)"
                    let matched = try! self.matches(for: regex, in: html2)
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
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                if (self.tableentries.count != 0){
                    print(self.tableentries)
                    self.newcTable.reloadData()
                    print("1")
                    
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        if (self.tableentries.count != 0){
                            print(self.tableentries)
                            self.newcTable.reloadData()
                            print("2")
                            
                        }
                        else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                if (self.tableentries.count != 0){
                                    print(self.tableentries)
                                    self.newcTable.reloadData()
                                    print("3")
                                    
                                }
                                else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                        if (self.tableentries.count != 0){
                                            print(self.tableentries)
                                            self.newcTable.reloadData()
                                            print("4")
                                            
                                        }
                                        else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                if (self.tableentries.count != 0){
                                                    print(self.tableentries)
                                                    self.newcTable.reloadData()
                                                    print("5")
                                                    
                                                }
                                                else {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                        if (self.tableentries.count != 0){
                                                            print(self.tableentries)
                                                            self.newcTable.reloadData()
                                                            print("6")
                                                            
                                                        }
                                                        else {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                                print(self.tableentries)
                                                                self.newcTable.reloadData()
                                                                print("7")
                                                            })
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            })
        }
        if segment.selectedSegmentIndex == 2 && self.weekday {
            print("dinner")
            tableentries = [String]();
            Alamofire.request("https://virginia.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=704&PeriodId=1424&MenuDate=&Mode=day&UIBuildDateFrom=").responseString { response in
                if let html2 = response.result.value {
                    let regex = "(name\">[A-Z].*)|(;\">.*</a>)"
                    let matched = try! self.matches(for: regex, in: html2)
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
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                if (self.tableentries.count != 0){
                    print(self.tableentries)
                    self.newcTable.reloadData()
                    print("1")
                    
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        if (self.tableentries.count != 0){
                            print(self.tableentries)
                            self.newcTable.reloadData()
                            print("2")
                            
                        }
                        else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                if (self.tableentries.count != 0){
                                    print(self.tableentries)
                                    self.newcTable.reloadData()
                                    print("3")
                                    
                                }
                                else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                        if (self.tableentries.count != 0){
                                            print(self.tableentries)
                                            self.newcTable.reloadData()
                                            print("4")
                                            
                                        }
                                        else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                if (self.tableentries.count != 0){
                                                    print(self.tableentries)
                                                    self.newcTable.reloadData()
                                                    print("5")
                                                    
                                                }
                                                else {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                        if (self.tableentries.count != 0){
                                                            print(self.tableentries)
                                                            self.newcTable.reloadData()
                                                            print("6")
                                                            
                                                        }
                                                        else {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                                print(self.tableentries)
                                                                self.newcTable.reloadData()
                                                                print("7")
                                                            })
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            })

        }
        
        if segment.selectedSegmentIndex == 0 && self.friday {
            print("breakfast")
            tableentries = [String]();
            Alamofire.request("https://virginia.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=704&PeriodId=1421&MenuDate=&Mode=day&UIBuildDateFrom=").responseString { response in
                if let html2 = response.result.value {
                    let regex = "(name\">[A-Z].*)|(;\">.*</a>)"
                    let matched = try! self.matches(for: regex, in: html2)
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
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                if (self.tableentries.count != 0){
                    print(self.tableentries)
                    self.newcTable.reloadData()
                    print("1")
                    
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        if (self.tableentries.count != 0){
                            print(self.tableentries)
                            self.newcTable.reloadData()
                            print("2")
                            
                        }
                        else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                if (self.tableentries.count != 0){
                                    print(self.tableentries)
                                    self.newcTable.reloadData()
                                    print("3")
                                    
                                }
                                else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                        if (self.tableentries.count != 0){
                                            print(self.tableentries)
                                            self.newcTable.reloadData()
                                            print("4")
                                            
                                        }
                                        else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                if (self.tableentries.count != 0){
                                                    print(self.tableentries)
                                                    self.newcTable.reloadData()
                                                    print("5")
                                                    
                                                }
                                                else {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                        if (self.tableentries.count != 0){
                                                            print(self.tableentries)
                                                            self.newcTable.reloadData()
                                                            print("6")
                                                            
                                                        }
                                                        else {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                                print(self.tableentries)
                                                                self.newcTable.reloadData()
                                                                print("7")
                                                            })
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            })
        }
        if segment.selectedSegmentIndex == 1 && self.friday {
            print("lunch")
            tableentries = [String]();
            Alamofire.request("https://virginia.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=704&PeriodId=1423&MenuDate=&Mode=day&UIBuildDateFrom=").responseString { response in
                if let html2 = response.result.value {
                    let regex = "(name\">[A-Z].*)|(;\">.*</a>)"
                    let matched = try! self.matches(for: regex, in: html2)
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
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                if (self.tableentries.count != 0){
                    print(self.tableentries)
                    self.newcTable.reloadData()
                    print("1")
                    
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        if (self.tableentries.count != 0){
                            print(self.tableentries)
                            self.newcTable.reloadData()
                            print("2")
                            
                        }
                        else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                if (self.tableentries.count != 0){
                                    print(self.tableentries)
                                    self.newcTable.reloadData()
                                    print("3")
                                    
                                }
                                else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                        if (self.tableentries.count != 0){
                                            print(self.tableentries)
                                            self.newcTable.reloadData()
                                            print("4")
                                            
                                        }
                                        else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                if (self.tableentries.count != 0){
                                                    print(self.tableentries)
                                                    self.newcTable.reloadData()
                                                    print("5")
                                                    
                                                }
                                                else {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                        if (self.tableentries.count != 0){
                                                            print(self.tableentries)
                                                            self.newcTable.reloadData()
                                                            print("6")
                                                            
                                                        }
                                                        else {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                                print(self.tableentries)
                                                                self.newcTable.reloadData()
                                                                print("7")
                                                            })
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            })
        }
        
        if segment.selectedSegmentIndex == 0 && self.saturday {
            print("brunch")
            tableentries = [String]();
            Alamofire.request("https://virginia.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=704&PeriodId=1422&MenuDate=&Mode=day&UIBuildDateFrom=").responseString { response in
                if let html2 = response.result.value {
                    let regex = "(name\">[A-Z].*)|(;\">.*</a>)"
                    let matched = try! self.matches(for: regex, in: html2)
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
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                if (self.tableentries.count != 0){
                    print(self.tableentries)
                    self.newcTable.reloadData()
                    print("1")
                    
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        if (self.tableentries.count != 0){
                            print(self.tableentries)
                            self.newcTable.reloadData()
                            print("2")
                            
                        }
                        else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                if (self.tableentries.count != 0){
                                    print(self.tableentries)
                                    self.newcTable.reloadData()
                                    print("3")
                                    
                                }
                                else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                        if (self.tableentries.count != 0){
                                            print(self.tableentries)
                                            self.newcTable.reloadData()
                                            print("4")
                                            
                                        }
                                        else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                if (self.tableentries.count != 0){
                                                    print(self.tableentries)
                                                    self.newcTable.reloadData()
                                                    print("5")
                                                    
                                                }
                                                else {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                        if (self.tableentries.count != 0){
                                                            print(self.tableentries)
                                                            self.newcTable.reloadData()
                                                            print("6")
                                                            
                                                        }
                                                        else {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                                print(self.tableentries)
                                                                self.newcTable.reloadData()
                                                                print("7")
                                                            })
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            })
        }
        if segment.selectedSegmentIndex == 1 && self.saturday {
            print("brunch")
            tableentries = [String]();
            Alamofire.request("https://virginia.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=704&PeriodId=1422&MenuDate=&Mode=day&UIBuildDateFrom=").responseString { response in
                if let html2 = response.result.value {
                    let regex = "(name\">[A-Z].*)|(;\">.*</a>)"
                    let matched = try! self.matches(for: regex, in: html2)
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
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                if (self.tableentries.count != 0){
                    print(self.tableentries)
                    self.newcTable.reloadData()
                    print("1")
                    
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        if (self.tableentries.count != 0){
                            print(self.tableentries)
                            self.newcTable.reloadData()
                            print("2")
                            
                        }
                        else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                if (self.tableentries.count != 0){
                                    print(self.tableentries)
                                    self.newcTable.reloadData()
                                    print("3")
                                    
                                }
                                else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                        if (self.tableentries.count != 0){
                                            print(self.tableentries)
                                            self.newcTable.reloadData()
                                            print("4")
                                            
                                        }
                                        else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                if (self.tableentries.count != 0){
                                                    print(self.tableentries)
                                                    self.newcTable.reloadData()
                                                    print("5")
                                                    
                                                }
                                                else {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                        if (self.tableentries.count != 0){
                                                            print(self.tableentries)
                                                            self.newcTable.reloadData()
                                                            print("6")
                                                            
                                                        }
                                                        else {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                                print(self.tableentries)
                                                                self.newcTable.reloadData()
                                                                print("7")
                                                            })
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            })
        }
    }
    
    func check(time: NSDate) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "EST")
        if self.weekday {
            guard let
                beginOpen = formatter.date(from: "7:00"),
                let beginClosed = formatter.date(from: "20:00")
                else { return nil }
            if time.compare(beginOpen) == .orderedAscending { return "Closed" }
            if time.compare(beginClosed) == .orderedAscending { return "Open" }
        }
        
        if self.friday {
            guard let
                beginOpen = formatter.date(from: "7:00"),
                let beginClosed = formatter.date(from: "14:15")
                else { return nil }
            if time.compare(beginOpen) == .orderedAscending { return "Closed" }
            if time.compare(beginClosed) == .orderedAscending { return "Open" }
        }
        
        if self.saturday {
            guard let
                beginOpen = formatter.date(from: "10:00"),
                let beginClosed = formatter.date(from: "14:00")
                else { return nil }
            if time.compare(beginOpen) == .orderedAscending { return "Closed" }
            if time.compare(beginClosed) == .orderedAscending { return "Open"}
        }
        
        if self.sunday {
            guard let
                beginOpen = formatter.date(from: "10:00"),
                let beginClosed = formatter.date(from: "20:00")
                else { return nil }
            if time.compare(beginOpen) == .orderedAscending { return "Closed" }
            if time.compare(beginClosed) == .orderedAscending { return "Open" }
        }
        return "Closed"
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
