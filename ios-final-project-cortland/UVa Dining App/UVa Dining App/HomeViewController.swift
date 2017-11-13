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
 
    @IBAction func login(_ sender: Any) {
        self.performSegue(withIdentifier: "authenticate", sender: self)
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
