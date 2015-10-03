//
//  GameViewModelTests.swift
//  Futebol365
//
//  Created by Adriano Goncalves on 03/10/2015.
//  Copyright © 2015 Adriano Goncalves. All rights reserved.
//

import XCTest
import Futebol365
@testable import Parse

class GameViewModelTests: XCTestCase {
   
   var homeTeam: FPTTeam?
   var awayTeam: FPTTeam?
   var favouriteTeam: FPTTeam?
   var gameWithoutFavourites: FPTGame?
   var gameWithHomeFavourite: FPTGame?
   var gameWithAwayFavourite: FPTGame?
   
   override func setUp() {
      homeTeam = FPTTeam()
      homeTeam?.name = "Real Madrid"
      
      awayTeam = FPTTeam()
      awayTeam?.name = "Barcelona"
      
      favouriteTeam = FPTTeam()
      favouriteTeam?.name = "Benfica"
      
      gameWithoutFavourites = FPTGame()
      gameWithoutFavourites?.homeTeam = homeTeam!
      gameWithoutFavourites?.awayTeam = awayTeam!
      
      gameWithHomeFavourite = FPTGame()
      gameWithHomeFavourite?.homeTeam = favouriteTeam!
      gameWithHomeFavourite?.awayTeam = awayTeam!
      
      gameWithAwayFavourite = FPTGame()
      gameWithAwayFavourite?.homeTeam = homeTeam!
      gameWithAwayFavourite?.awayTeam = favouriteTeam!
   }
   
   func testCanCreateTeamsTextWithoutFavouriteTeams() {
      let viewModel = GameViewModel(game: gameWithoutFavourites!)
      XCTAssertEqual(viewModel.teamsText, "\(homeTeam!.name) - \(awayTeam!.name)")
   }
   
}
