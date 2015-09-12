//
//  FPTGame.swift
//  Futebol365
//
//  Created by Adriano Goncalves on 23/08/2015.
//  Copyright (c) 2015 Adriano Goncalves. All rights reserved.
//

import UIKit
import Parse
import SwiftMoment
import Cent

class FPTGame: PFObject, PFSubclassing {
   
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
      return "FPTGame"
   }
   
   //MARK: FPTGame
   
   @NSManaged var link: String
   @NSManaged var title: String
   @NSManaged var guid: String
   @NSManaged var dateString: String
   @NSManaged var tvChannel: String
   @NSManaged var homeTeam: FPTTeam
   @NSManaged var homeTeamName: String
   @NSManaged var awayTeam: FPTTeam
   @NSManaged var awayTeamName: String
   @NSManaged var date: NSDate
   var dateMoment: Moment {
      return moment(date)
   }
   
   override init() {
      super.init()
   }
   
}