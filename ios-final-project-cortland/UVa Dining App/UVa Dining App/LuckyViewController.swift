//
//  LuckyViewController.swift
//  UVa Dining App
//
//  Created by Michael Chang on 11/29/17.
//  Copyright © 2017 Michael Chang. All rights reserved.
//

import UIKit
import CoreMotion

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

class LuckyViewController: UIViewController {
    var restaurants = [Restaurant]()
    var confirmed: Bool?
    
    lazy var motionManager = CMMotionManager()
    
    @IBOutlet weak var shakeLabel: UILabel!
    @IBOutlet weak var random: UILabel!
    @IBOutlet weak var randomMenu: UILabel!
    @IBOutlet weak var randomMenuLand: UILabel!
    @IBAction func confirm(_ sender: Any) {
        confirmed = true
    }
    @IBAction func cancel(_ sender: Any) {
        confirmed = false
        randomMenu.text! = ""
        randomMenuLand.text! = ""
    }
    
    @IBAction func restaurantPage(_ sender: Any) {
        if random.text != ""  {
            self.performSegue(withIdentifier: "luckyPage", sender: self)
        }
    }
    override func motionEnded(_ motion: UIEventSubtype,
                              with: UIEvent?) {
        if motion == .motionShake && !confirmed!{
            restaurants.shuffle()
            print(random.text = restaurants[0].name)
        }
        if motion == .motionShake && confirmed!{
            restaurants[0].menuItems.shuffle()
            randomMenu.text! = restaurants[0].menuItems[0]
            randomMenuLand.text! = restaurants[0].menuItems[0]
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "luckyPage") {
            let destinationVC = segue.destination as! UINavigationController
            let targetController = destinationVC.topViewController as! MealExchangeViewController
            targetController.restaurant = restaurants[0]
        }
        
    }
    
    @IBAction func dismissLucky(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        random.text! = ""
        randomMenu.text! = ""
        randomMenuLand.text! = ""
        confirmed = false
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
