//
//  AppDelegate.swift
//  Futebol365
//
//  Created by Adriano Goncalves on 23/08/2015.
//  Copyright (c) 2015 Adriano Goncalves. All rights reserved.
//

import UIKit

import Bolts
import Parse
import ParseCrashReporting
import SwiftMoment

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
   
   var window: UIWindow?
   
   func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
      
      Parse.enableLocalDatastore()
      ParseCrashReporting.enable()
      Parse.setApplicationId("0N1kCdAA5d2A7vMyrEqJON06vZVfjp4z5NSgjNzD", clientKey: "oHQ9MeJ64rJoFdQgqqbfiJSB12qXBrBhsjTiTu8y")
      
      return true
      
   }
   
}

extension Moment {
   func date() -> NSDate {
      return NSDate(timeIntervalSince1970: self.epoch())
   }
}
