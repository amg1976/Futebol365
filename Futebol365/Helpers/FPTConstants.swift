//
//  FPTConstants.swift
//  Futebol365
//
//  Created by Adriano Goncalves on 25/08/2015.
//  Copyright (c) 2015 Adriano Goncalves. All rights reserved.
//

import UIKit

class FPTConstants {

   class Error {

      static let UserErrorDomain = "com.amg.Futebol365.PFUser"
      
      enum UserErrorCode: Int {
         case MissingLoggedInUser = 0
      }

   }
   
   class Notifications {
      static let GamesDataSourceUpdatedNotification = "com.amg.Futebol365.GamesDataSourceUpdatedNotification"
      static let FavouritesUpdatedNotification = "com.amg.Futebol365.FavouritesUpdatedNotification"
   }

}
