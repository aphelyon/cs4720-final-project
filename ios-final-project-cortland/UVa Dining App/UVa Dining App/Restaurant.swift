//
//  Restaurant.swift
//  UVa Dining App
//
//  Created by Michael Chang on 11/28/17.
//  Copyright © 2017 Michael Chang. All rights reserved.
//

import Foundation

class Restaurant {
    var name: String?
    var description: String?
    var mealExchange: Bool?
    var menuItems = [menuItem]();
    var latitude: Double?
    var longitude: Double?
    var openingHours: String?
    var closingHours: String?
    var mealExchangeOpen: String?
    var mealExchangeClosed: String?
}
