//
//  FPTAppConfiguration.swift
//  Futebol365
//
//  Created by Adriano Goncalves on 25/08/2015.
//  Copyright (c) 2015 Adriano Goncalves. All rights reserved.
//

import UIKit
import SwiftMoment

class FPTAppConfiguration {

    static let sharedInstance: FPTAppConfiguration = FPTAppConfiguration()

    var lastGamesUpdate: Moment {
        set {
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(double: newValue.epoch()), forKey: "lastGamesUpdate")
        }
        get {
            if let timeInterval = NSUserDefaults.standardUserDefaults().objectForKey("lastGamesUpdate") as? NSNumber {
                let result = moment(timeInterval.doubleValue)
                return result
            }
            return moment(NSTimeIntervalSince1970)
        }
    }
}
