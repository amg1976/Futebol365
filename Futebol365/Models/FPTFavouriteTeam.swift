//
//  FPTFavouriteTeam.swift
//  Futebol365
//
//  Created by Adriano Goncalves on 19/09/2015.
//  Copyright © 2015 Adriano Goncalves. All rights reserved.
//

import UIKit
import Parse

class FPTFavouriteTeam: PFObject, PFSubclassing {

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
      return "FPTFavouriteTeam"
   }
   
   //MARK: FPTFavouriteTeam
   
   @NSManaged var team: FPTTeam
   @NSManaged var user: PFUser

}
