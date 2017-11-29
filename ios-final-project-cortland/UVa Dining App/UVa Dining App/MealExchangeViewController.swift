//
//  MealExchangeViewController.swift
//  UVa Dining App
//
//  Created by Michael Chang on 11/29/17.
//  Copyright © 2017 Michael Chang. All rights reserved.
//

import UIKit

class MealExchangeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var restaurant = Restaurant()
    @IBAction func dismissMealExchange(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var operatingHours: UILabel!
    
    @IBOutlet weak var mealView: UIView!
    @IBOutlet weak var menuItemName: UILabel!
    @IBOutlet weak var currentDay: UILabel!
    
    @IBOutlet weak var mealExchangeHours: UILabel!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.restaurant.menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "mealExchangeItem"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MenuItemTableViewCell
        let menuItem = self.restaurant.menuItems[indexPath.row]
        
        cell.menuItemName.text = menuItem
        
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = restaurant.name!
        mealView.layer.borderWidth = 2.0
        mealView.layer.borderColor = UIColor.black.cgColor
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
                currentDay.text! = "Sunday"
                
            case 2:
                currentDay.text! = "Monday"
            case 3:
                currentDay.text! = "Tuesday"
                
            case 4:
                currentDay.text! = "Wednesday"
            case 5:
                currentDay.text! = "Thursday"
            case 6:
                currentDay.text! = "Friday"
            case 7:
                currentDay.text! = "Saturday"
                
            default:
                print("Invalid")
            }
            let operation = gregorianCalendar.component(.weekday, from: date)
            
            switch operation {
            case 1:
                self.operatingHours.text! = self.restaurant.sundayOpeningHours! + " - " + restaurant.sundayClosingHours!
                self.mealExchangeHours.text! = self.restaurant.sundayMealOpeningHours! + " - " + self.restaurant.sundayMealClosingHours!
                
            case 2:
                self.operatingHours.text! = self.restaurant.mondayOpeningHours! + " - " + restaurant.mondayClosingHours!
                self.mealExchangeHours.text! = self.restaurant.mondayMealOpeningHours! + " - " + self.restaurant.mondayMealClosingHours!
            case 3:
                self.operatingHours.text! = self.restaurant.tuesdayOpeningHours! + " - " + restaurant.tuesdayClosingHours!
                self.mealExchangeHours.text! = self.restaurant.tuesdayMealOpeningHours! + " - " + self.restaurant.tuesdayMealClosingHours!
            case 4:
                self.operatingHours.text! = self.restaurant.wednesdayOpeningHours! + " - " + restaurant.wednesdayClosingHours!
                self.mealExchangeHours.text! = self.restaurant.wednesdayMealOpeningHours! + " - " + self.restaurant.wednesdayMealClosingHours!
            case 5:
                self.operatingHours.text! = self.restaurant.thursdayOpeningHours! + " - " + restaurant.thursdayClosingHours!
                self.mealExchangeHours.text! = self.restaurant.thursdayMealOpeningHours! + " - " + self.restaurant.thursdayMealClosingHours!
            case 6:
                self.operatingHours.text! = self.restaurant.fridayOpeningHours! + " - " + restaurant.fridayClosingHours!
                self.mealExchangeHours.text! = self.restaurant.fridayMealOpeningHours! + " - " + self.restaurant.fridayMealClosingHours!
            case 7:
                self.operatingHours.text! = self.restaurant.saturdayOpeningHours! + " - " + restaurant.saturdayClosingHours!
                self.mealExchangeHours.text! = self.restaurant.saturdayMealOpeningHours! + " - " + self.restaurant.saturdayMealClosingHours!
            default:
                print("Invalid")
            }
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
