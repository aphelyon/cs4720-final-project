//
//  HomeViewController.swift
//  UVa Dining App
//
//  Created by Michael Chang on 11/8/17.
//  Copyright © 2017 Michael Chang. All rights reserved.
//

import UIKit
import KeychainSwift

class HomeViewController: UIViewController {

    
    @IBOutlet weak var newcomb: UIImageView!
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var ohill: UIImageView!
    @IBOutlet weak var runk: UIImageView!
    
    @IBOutlet weak var mealSwipes: UILabel!
    @IBOutlet weak var plusDollars: UILabel!
   
    @IBOutlet weak var lastUpdated: UILabel!
    
    var plusDollar = "Plus Dollars: "
    var mealSwipe = "Meal Swipes: "
    var lastUpdate = "Last Updated: "
    var pinnumber = "";
    var username = "";
    var password = "";
    var keychainHome = KeychainSwift();
    
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
            let keychain = UserDefaults.standard.object(forKey: "keychain") as? KeychainSwift
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
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plusDollars.text = plusDollar
        mealSwipes.text = mealSwipe
        lastUpdated.text = lastUpdate
        balanceView.layer.cornerRadius = 10
        
        balanceView.layer.borderWidth = 0.5
        balanceView.layer.borderColor = UIColor.black.cgColor
        
        balanceView.layer.shadowColor = UIColor.black.cgColor
        balanceView.layer.shadowOffset = CGSize(width: 3, height: 3)
        balanceView.layer.shadowOpacity = 0.5
        balanceView.layer.shadowRadius = 3.0
        newcomb.layer.cornerRadius = 8.0
        newcomb.clipsToBounds = true
        ohill.layer.cornerRadius = 8.0
        ohill.clipsToBounds = true
        runk.layer.cornerRadius = 8.0
        runk.clipsToBounds = true
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
