//
//  FPTTeam.swift
//  Futebol365
//
//  Created by Adriano Goncalves on 10/09/2015.
//  Copyright (c) 2015 Adriano Goncalves. All rights reserved.
//

import UIKit
import Parse

class FPTTeam: PFObject, PFSubclassing {
   
   //MARK: NSObject
   
   override class func initialize() {
      struct Static {
         static var onceToken : dispatch_once_t = 0;
      }
      dispatch_once(&Static.onceToken) {
         self.registerSubclass()
      }
   }
   
   //MARK: PFSubclassing
   
   static func parseClassName() -> String {
      return "FPTTeam"
   }
   
   //MARK: FPTTeam
   
   @NSManaged var name: String
   
   override init() {
      super.init()
   }
   
}
