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
      
      let currentUser = PFUser.currentUser()
      if currentUser != nil {
         // Do stuff with the user
      } else {
         let user = PFUser()
         user.username = "amg1976"
         user.password = "amg1976"
         user.email = "amg1976@gmail.com"
         PFUser.logInWithUsernameInBackground(user.username!, password:user.password!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
               print("user logged in")
            } else {
               self.dummySignup(user!)
            }
         }
      }      
      
      return true
      
   }
   
   func dummySignup(user: PFUser) {
      user.signUpInBackgroundWithBlock {
         (succeeded: Bool, error: NSError?) -> Void in
         if let error = error {
            if let errorString = error.userInfo["error"] as? NSString {
               print("error on signup: \(errorString)")
            }
         } else {
         }
      }
   }
   
}

extension UIAlertController {
   static func showError(message: String) -> UIAlertController {
      let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in }))
      return alert
   }
}