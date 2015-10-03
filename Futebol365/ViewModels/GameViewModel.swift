//
//  GameViewModel.swift
//  Futebol365
//
//  Created by Adriano Goncalves on 03/10/2015.
//  Copyright © 2015 Adriano Goncalves. All rights reserved.
//

import UIKit
import Parse
import SwiftMoment

class GameViewModel {

   private (set) var game: FPTGame
   
   var homeTeamName: String { return game.homeTeamName }
   var awayTeamName: String { return game.awayTeamName }
   var teamsText: String { return "\(homeTeamNameWithFavourite()) - \(awayTeamNameWithFavourite())" }
   var timeText: String { return game.dateMoment.format("HH:mm") }
   var channelNameText: String { return game.tvChannel }
   private (set) var teamsFont: UIFont
   private (set) var teamsTextColor: UIColor
   private (set) var timeTextColor: UIColor
   private (set) var channelNameTextColor: UIColor
   
   init(game: FPTGame) {
      self.game = game
      
      let timeSinceGameStart = moment().intervalSince(game.dateMoment)
      if timeSinceGameStart.seconds > 0 {
         if timeSinceGameStart.minutes <= 120 {
            let green = UIColor(red: 0, green: 128/255, blue: 0, alpha: 1)
            teamsFont = UIFont.systemFontOfSize(20.0, weight: UIFontWeightLight)
            teamsTextColor = green
            timeTextColor = green
            channelNameTextColor = green
         } else {
            teamsFont = UIFont.systemFontOfSize(20.0, weight: UIFontWeightThin)
            teamsTextColor = UIColor.lightGrayColor()
            timeTextColor = UIColor.lightGrayColor()
            channelNameTextColor = UIColor.lightGrayColor()
         }
      } else {
         teamsFont = UIFont.systemFontOfSize(20.0, weight: UIFontWeightLight)
         teamsTextColor = UIColor.darkGrayColor()
         timeTextColor = UIColor.darkGrayColor()
         channelNameTextColor = UIColor.darkGrayColor()
      }
      
   }
   
   private func homeTeamNameWithFavourite() -> String {
      return homeTeamName + (game.homeTeamCurrentUserFavourite ? " *" : "")
   }

   private func awayTeamNameWithFavourite() -> String {
      return awayTeamName + (game.awayTeamCurrentUserFavourite ? " *" : "")
   }

}
