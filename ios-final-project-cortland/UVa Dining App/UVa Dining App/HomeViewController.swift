//
//  HomeViewController.swift
//  UVa Dining App
//
//  Created by Michael Chang on 11/8/17.
//  Copyright © 2017 Michael Chang. All rights reserved.
//

import UIKit
import KeychainSwift
import Alamofire
import SwiftSoup
import Firebase
import FirebaseDatabase

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}
class HomeViewController: UIViewController {

    
    @IBAction func lucky(_ sender: Any) {
        print("I'm Feeling Lucky")
    }
    @IBAction func closest(_ sender: Any) {
        print("Restaurants near me")
    }
    @IBAction func luckyLandscape(_ sender: Any) {
        print("I'm Feeling Lucky LandScape")
    }
    @IBAction func closestLandscape(_ sender: Any) {
        print("Restaurants near me LandScape")
    }
    
    @IBOutlet weak var mealExchange: UIView!
    @IBOutlet weak var newcomb: UIImageView!
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var ohill: UIImageView!
    @IBOutlet weak var runk: UIImageView!
    @IBOutlet weak var mealExchangeLandscape: UIImageView!
    
    @IBOutlet weak var mealSwipes: UILabel!
    @IBOutlet weak var plusDollars: UILabel!
   
    @IBOutlet weak var lastUpdated: UILabel!
    
    var plusDollar = "Plus Dollars: "
    var mealSwipe = "Meal Swipes: "
    var lastUpdate = "Last Updated: "
    var pinnumber = "";
    var username = "";
    var password = "";
    var restaurants = [Restaurant]();
    var keychainHome = KeychainSwift();
    var ref: DatabaseReference!
        
    func displayAlertWithTitle(title: String, message: String){
        let controller = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "OK",
                                           style: .default,
                                           handler: nil))
        
        present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func update(_ sender: Any) {
        if (UserDefaults.standard.object(forKey: "loggedIn") != nil) {
        let alert = UIAlertController(title: "Update", message: "Enter your pin please.", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.text = ""
                textField.keyboardType = .numberPad
                textField.isSecureTextEntry = true;
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                self.pinnumber = (alert?.textFields![0].text)!
                if (self.pinnumber.characters.count != 4) {
                    self.displayAlertWithTitle(title: "Incorrect Pin Length",
                                               message: "Please enter a 4-digit pin")
                }
                else {
                    if ((self.keychainHome.get(self.pinnumber)) != nil) {
                        self.username = (self.keychainHome.get(self.pinnumber)!)
                        self.password = (self.keychainHome.get(self.pinnumber + "x")!)
                        self.performSegue(withIdentifier: "update", sender: self)
                    }
                    else {
                        self.displayAlertWithTitle(title: "Incorrect Pin",
                                                   message: "Please enter the correct pin")
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        else {
            self.displayAlertWithTitle(title: "You are not logged in",
                                       message: "Please log in.")
        }
    }
    
    
    @IBAction func login(_ sender: Any) {
        if (UserDefaults.standard.object(forKey: "loggedIn") == nil) {
            self.performSegue(withIdentifier: "login", sender: self)
        }
        else {
            self.displayAlertWithTitle(title: "You are already logged in",
                                       message: "You don't need to login again!")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "update") {
            let destinationVC = segue.destination as! UINavigationController
            let targetController = destinationVC.topViewController as! ViewController
            targetController.username = self.username
            targetController.password = self.password
        }
        if (segue.identifier == "mealExchange") {
            let destinationVC = segue.destination as! UINavigationController
            let targetController = destinationVC.topViewController as! RestaurantTableViewController
            targetController.tableentries = self.restaurants
        }
        
    }
    
    func newcombTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {

            self.performSegue(withIdentifier: "newcomb", sender: self)
        }
    }
    
    func ohillTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            
            self.performSegue(withIdentifier: "ohill", sender: self)
        }
    }
    
    func runkTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            
            self.performSegue(withIdentifier: "runk", sender: self)
        }
    }
    
    func mealTapped(gesture: UIGestureRecognizer) {
        self.performSegue(withIdentifier: "mealExchange", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.standard.object(forKey: "plusDollar") != nil) {
            plusDollars.text = UserDefaults.standard.object(forKey: "plusDollar") as? String
        }
        else {
            plusDollars.text = self.plusDollar
        }
        if (UserDefaults.standard.object(forKey: "mealSwipe") != nil) {
            mealSwipes.text = UserDefaults.standard.object(forKey: "mealSwipe") as? String
        }
        else {
            mealSwipes.text = self.mealSwipe
        }
        if (UserDefaults.standard.object(forKey: "date") != nil) {
            lastUpdated.text = UserDefaults.standard.object(forKey: "date") as? String
        }
        else {
            lastUpdated.text = self.lastUpdate
        }
        balanceView.layer.cornerRadius = 10
        
        balanceView.layer.borderWidth = 0.5
        balanceView.layer.borderColor = UIColor.black.cgColor
        mealExchange.layer.cornerRadius = 10
        
        mealExchange.layer.borderWidth = 0.5
        mealExchange.layer.borderColor = UIColor.black.cgColor
        balanceView.layer.shadowColor = UIColor.black.cgColor
        balanceView.layer.shadowOffset = CGSize(width: 3, height: 3)
        balanceView.layer.shadowOpacity = 0.5
        balanceView.layer.shadowRadius = 3.0
        newcomb.layer.cornerRadius = 8.0
        newcomb.clipsToBounds = true
       let newcombGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.newcombTapped(gesture:)))
        newcomb.addGestureRecognizer(newcombGesture)
        newcomb.isUserInteractionEnabled = true
        ohill.layer.cornerRadius = 8.0
        ohill.clipsToBounds = true
        let ohillGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.ohillTapped(gesture:)))
        ohill.addGestureRecognizer(ohillGesture)
        ohill.isUserInteractionEnabled = true
        runk.layer.cornerRadius = 8.0
        runk.clipsToBounds = true
        let runkGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.runkTapped(gesture:)))
        runk.addGestureRecognizer(runkGesture)
        runk.isUserInteractionEnabled = true
        let mealGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.mealTapped(gesture:)))
        mealExchange.addGestureRecognizer(mealGesture)
        mealExchange.isUserInteractionEnabled = true
        let mealLandGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.mealTapped(gesture:)))
        mealExchangeLandscape.addGestureRecognizer(mealLandGesture)
        mealExchangeLandscape.isUserInteractionEnabled = true
        ref = Database.database().reference()
        ref.child("Restaurants/MealExchange").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            for (restaurantEntry, datr) in value! {
                var restaurant = Restaurant()
                for (key, value) in (datr as? NSDictionary)! {
                    var keyString = key as! String
                    if (keyString == "menuItems") {
                        var menuItems = [String]();
                        for (items, item) in (value as? NSDictionary)! {
                            menuItems.append(item as! String)
                        }
                        restaurant.menuItems = menuItems
                    }
                    else {
                        if (keyString == "name") {
                            restaurant.name = value as? String
                        }
                        if (keyString == "description") {
                            restaurant.description = value as? String
                        }
                        if (keyString == "latitude") {
                            restaurant.latitude = value as? Double
                        }
                        if (keyString == "longitude") {
                            restaurant.longitude = value as? Double
                        }
                        if (keyString == "mondayOpeningHours") {
                            restaurant.mondayOpeningHours = value as? String
                        }
                        if (keyString == "tuesdayOpeningHours") {
                            restaurant.tuesdayOpeningHours = value as? String
                        }
                        if (keyString == "wednesdayOpeningHours") {
                            restaurant.wednesdayOpeningHours = value as? String
                        }
                        if (keyString == "thursdayOpeningHours") {
                            restaurant.thursdayOpeningHours = value as? String
                        }
                        if (keyString == "fridayOpeningHours") {
                            restaurant.fridayOpeningHours = value as? String
                        }
                        if (keyString == "saturdayOpeningHours") {
                            restaurant.saturdayOpeningHours = value as? String
                        }
                        if (keyString == "sundayOpeningHours") {
                            restaurant.sundayOpeningHours = value as? String
                        }
                        if (keyString == "mondayClosingHours") {
                            restaurant.mondayClosingHours = value as? String
                        }
                        if (keyString == "tuesdayClosingHours") {
                            restaurant.tuesdayClosingHours = value as? String
                        }
                        if (keyString == "wednesdayClosingHours") {
                            restaurant.wednesdayClosingHours = value as? String
                        }
                        if (keyString == "thursdayClosingHours") {
                            restaurant.thursdayClosingHours = value as? String
                        }
                        if (keyString == "fridayClosingHours") {
                            restaurant.fridayClosingHours = value as? String
                        }
                        if (keyString == "saturdayClosingHours") {
                            restaurant.saturdayClosingHours = value as? String
                        }
                        if (keyString == "sundayClosingHours") {
                            restaurant.sundayClosingHours = value as? String
                        }
                        if (keyString == "mondayMealOpeningHours") {
                            restaurant.mondayMealOpeningHours = value as? String
                        }
                        if (keyString == "tuesdayMealOpeningHours") {
                            restaurant.tuesdayMealOpeningHours = value as? String
                        }
                        if (keyString == "wednesdayMealOpeningHours") {
                            restaurant.wednesdayMealOpeningHours = value as? String
                        }
                        if (keyString == "thursdayMealOpeningHours") {
                            restaurant.thursdayMealOpeningHours = value as? String
                        }
                        if (keyString == "fridayMealOpeningHours") {
                            restaurant.fridayMealOpeningHours = value as? String
                        }
                        if (keyString == "saturdayMealOpeningHours") {
                            restaurant.saturdayMealOpeningHours = value as? String
                        }
                        if (keyString == "sundayMealOpeningHours") {
                            restaurant.sundayMealOpeningHours = value as? String
                        }
                        if (keyString == "mondayMealClosingHours") {
                            restaurant.mondayMealClosingHours = value as? String
                        }
                        if (keyString == "tuesdayMealClosingHours") {
                            restaurant.tuesdayMealClosingHours = value as? String
                        }
                        if (keyString == "wednesdayMealClosingHours") {
                            restaurant.wednesdayMealClosingHours = value as? String
                        }
                        if (keyString == "thursdayMealClosingHours") {
                            restaurant.thursdayMealClosingHours = value as? String
                        }
                        if (keyString == "fridayMealClosingHours") {
                            restaurant.fridayMealClosingHours = value as? String
                        }
                        if (keyString == "saturdayMealClosingHours") {
                            restaurant.saturdayMealClosingHours = value as? String
                        }
                        if (keyString == "sundayMealClosingHours") {
                            restaurant.sundayMealClosingHours = value as? String
                        }
                        
                    }
                }
                self.restaurants.append(restaurant)
            }
            
        })
    }
    
    @IBAction func unwindToHomeView(segue:UIStoryboardSegue) {
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
