//
//  ClosestTableViewController.swift
//  UVa Dining App
//
//  Created by Michael Chang on 11/29/17.
//  Copyright © 2017 Michael Chang. All rights reserved.
//

import UIKit
import CoreLocation

extension Double {
    func toString() -> String {
        return String(format: "%.2f",self)
    }
}


class ClosestTableViewController: UITableViewController, CLLocationManagerDelegate {

   
    var tableentries = [Restaurant]()
    var index: Int?
    var locationManager: CLLocationManager?
    var currentlatitude: Double?
    var currentlongitude: Double?
    var distances = [Double]()
    var updated: Bool?
    
    @IBAction func dismissClose(_ sender: Any) {
        
        for restaurant in self.tableentries {
            let start = restaurant.name?.index((restaurant.name?.startIndex)!, offsetBy: 0)
            let end = restaurant.name?.index((restaurant.name?.endIndex)!, offsetBy: -12)
            let range = start!..<end!
            restaurant.name = restaurant.name?.substring(with: range)
        }
        self.tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updated = false
    }
    func createLocationManager(startImmediately: Bool){
        locationManager = CLLocationManager()
        if let manager = locationManager{
            manager.delegate = self
            if startImmediately{
                manager.startUpdatingLocation()
                 DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    print(self.currentlongitude)
                    print(self.currentlatitude)
                    var currentLocation = CLLocation(latitude: self.currentlatitude!, longitude: self.currentlongitude!)
                    for restaurant in self.tableentries {
                        var restaurantLocation = CLLocation(latitude: restaurant.latitude!, longitude: restaurant.longitude!)
                        var distanceInMeters = currentLocation.distance(from: restaurantLocation)
                        var distanceInMiles = distanceInMeters/1609.344
                        self.distances.append(distanceInMiles)
                    }
                    if !self.updated! {
                        self.tableentries = self.tableentries.sorted { (t1:Restaurant, t2:Restaurant) -> Bool in
                            return (self.distances[self.tableentries.index(of:t1)!] < self.distances[self.tableentries.index(of:t2)!])
                        }
                        self.distances = self.distances.sorted()
                        for restaurant in self.tableentries {
                            restaurant.name = restaurant.name! + " (" + self.distances[self.tableentries.index(of:restaurant)!].toString() + " miles)"
                    }
                    
                        self.tableView.reloadData()
                        self.updated = true
                    }
                })
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count == 0 {
            //handle error here
            return
        }
        
        let newLocation = locations[0]
        currentlatitude = newLocation.coordinate.latitude
        currentlongitude = newLocation.coordinate.longitude
      //  lat.text = String(newLocation.coordinate.latitude)
      //  lon.text = String(newLocation.coordinate.longitude)
    }
    
    
    
    @IBAction func startGPS(_ sender: Any) {
        // Helper function provided to manage authorization - no edits needed.
        /* Are location services available on this device? */
        if CLLocationManager.locationServicesEnabled(){
            
            /* Do we have authorization to access location services? */
            switch CLLocationManager.authorizationStatus(){
            case .authorizedAlways:
                /* Yes, always */
                createLocationManager(startImmediately: true)
            case .authorizedWhenInUse:
                /* Yes, only when our app is in use  */
                createLocationManager(startImmediately: true)
            case .denied:
                /* No */
                displayAlertWithTitle(title: "Not Determined",
                                      message: "Location services are not allowed for this app")
            case .notDetermined:
                /* We don't know yet, we have to ask */
                createLocationManager(startImmediately: false)
                if let manager = self.locationManager{
                    manager.requestWhenInUseAuthorization()
                }
            case .restricted:
                /* Restrictions have been applied, we have no access
                 to location services */
                displayAlertWithTitle(title: "Restricted",
                                      message: "Location services are not allowed for this app")
            }
            
            
        } else {
            /* Location services are not enabled.
             Take appropriate action: for instance, prompt the
             user to enable the location services */
            displayAlertWithTitle(title: "Not Enabled",
                                  message: "Please enable location services")
            print("Location services are not enabled")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        // Code here is called on an error - no edits needed.
        print("Location manager failed with error = \(error)")
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // Code here is called when authoization changes - no edits needed.
        print("The authorization status of location services is changed to: ", terminator: "")
        
        switch CLLocationManager.authorizationStatus(){
        case .authorizedAlways:
            print("Authorized")
        case .authorizedWhenInUse:
            print("Authorized when in use")
        case .denied:
            print("Denied")
        case .notDetermined:
            print("Not determined")
        case .restricted:
            print("Restricted")
        }

    }
        
    func displayAlertWithTitle(title: String, message: String){
        // Helper function for displaying dialog windows - no edits needed.
        let controller = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "OK",
                                           style: .default,
                                           handler: nil))
        
        present(controller, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath[1]
        self.performSegue(withIdentifier: "closestrestaurant", sender: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.tableentries.count
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "closestrestaurant") {
            let destinationVC = segue.destination as! UINavigationController
            let targetController = destinationVC.topViewController as! MealExchangeViewController
            targetController.restaurant = tableentries[index!]
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "nearMeCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let menuItem = self.tableentries[indexPath.row].name
        
        cell.textLabel?.text = menuItem
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
