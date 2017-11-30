//
//  Restaurant.swift
//  UVa Dining App
//
//  Created by Michael Chang on 11/28/17.
//  Copyright © 2017 Michael Chang. All rights reserved.
//

import Foundation

extension Restaurant: Equatable { }

func ==(lhs: Restaurant, rhs: Restaurant) -> Bool {
    return lhs === rhs // === returns true when both references point to the same object
}

class Restaurant {
    var name: String?
    var description: String?
    var menuItems = [String]();
    var latitude: Double?
    var longitude: Double?
    
    
    var mondayOpeningHours: String?
    var mondayClosingHours: String?
    var mondayMealOpeningHours: String?
    var mondayMealClosingHours: String?
    
    var tuesdayOpeningHours: String?
    var tuesdayClosingHours: String?
    var tuesdayMealOpeningHours: String?
    var tuesdayMealClosingHours: String?
    
    var wednesdayOpeningHours: String?
    var wednesdayClosingHours: String?
    var wednesdayMealOpeningHours: String?
    var wednesdayMealClosingHours: String?

    var thursdayOpeningHours: String?
    var thursdayClosingHours: String?
    var thursdayMealOpeningHours: String?
    var thursdayMealClosingHours: String?
    
    var fridayOpeningHours: String?
    var fridayClosingHours: String?
    var fridayMealOpeningHours: String?
    var fridayMealClosingHours: String?
    
    var saturdayOpeningHours: String?
    var saturdayClosingHours: String?
    var saturdayMealOpeningHours: String?
    var saturdayMealClosingHours: String?

    var sundayOpeningHours: String?
    var sundayClosingHours: String?
    var sundayMealOpeningHours: String?
    var sundayMealClosingHours: String?

}
