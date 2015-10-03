  //
//  TvGamesViewController.swift
//  Futebol365
//
//  Created by Adriano Goncalves on 23/08/2015.
//  Copyright (c) 2015 Adriano Goncalves. All rights reserved.
//

import UIKit
import SwiftMoment
import Parse

class TvGamesTableViewHeader: UITableViewCell {
   static let headerIdentifier = "TvGamesTableViewHeaderIdentifier"

   @IBOutlet weak var date: UILabel!
}

class TvGamesTableViewCell: UITableViewCell {
   
   static let cellIdentifier = "TvGamesCellIdentifier"
   var item: FPTGame?
   
   @IBOutlet weak var teams: UILabel!
   @IBOutlet weak var time: UILabel!
   @IBOutlet weak var channelName: UILabel!
   
   func updateStyle() {
      if let gameItem = item {
         let timeSinceGameStart = moment().intervalSince(gameItem.dateMoment)
         if timeSinceGameStart.seconds > 0 {
            if timeSinceGameStart.minutes <= 120 {
               let green = UIColor(red: 0, green: 128/255, blue: 0, alpha: 1)
               teams.font = UIFont.systemFontOfSize(teams.font.pointSize, weight: UIFontWeightLight)
               teams.textColor = green
               time.textColor = green
               channelName.textColor = green
            } else {
               teams.font = UIFont.systemFontOfSize(teams.font.pointSize, weight: UIFontWeightThin)
               teams.textColor = UIColor.lightGrayColor()
               time.textColor = UIColor.lightGrayColor()
               channelName.textColor = UIColor.lightGrayColor()
            }
         } else {
            teams.font = UIFont.systemFontOfSize(teams.font.pointSize, weight: UIFontWeightLight)
            teams.textColor = UIColor.darkGrayColor()
            time.textColor = UIColor.darkGrayColor()
            channelName.textColor = UIColor.darkGrayColor()
         }
      }
   }
   
}

class TvGamesTableDataSource: NSObject, UITableViewDataSource {
   
   private var notificationObserver: NSObjectProtocol?
   
   private (set) var allItems: [TvGamesDataSourceItem] = []
   
   //MARK: NSObject
   
   override init() {
      super.init()
      notificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(FPTConstants.Notifications.GamesDataSourceUpdatedNotification, object: nil, queue: nil) { (notification) -> Void in
         if let gamesDataSource = notification.object as? TvGamesDataSource {
            self.allItems = gamesDataSource.allItems
         }
      }
   }
   
   deinit {
      if let observer = notificationObserver {
         NSNotificationCenter.defaultCenter().removeObserver(observer)
      }
   }
   
   //MARK: UITableViewDataSource
   
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return allItems[section].items.count
   }
   
   func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return allItems.count
   }
   
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier(TvGamesTableViewCell.cellIdentifier) as? TvGamesTableViewCell
      cell?.item = allItems[indexPath.section].items[indexPath.row]
      return cell!
   }
   
}

class TvGamesTableDelegate: NSObject, UITableViewDelegate {
   
   //MARK: UITableViewDelegate
   
   func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      
      if let tableCell = cell as? TvGamesTableViewCell {
         let homeTeamName = tableCell.item!.homeTeamName + (tableCell.item!.homeTeamCurrentUserFavourite ? " *" : "")
         let awayTeamName = tableCell.item!.awayTeamName + (tableCell.item!.awayTeamCurrentUserFavourite ? " *" : "")
         tableCell.teams.text = "\(homeTeamName) - \(awayTeamName)"
         tableCell.time.text = tableCell.item!.dateMoment.format("HH:mm")
         tableCell.channelName.text = tableCell.item?.tvChannel
         tableCell.updateStyle()
      }
      
   }
   
   func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return 40
   }
   
   func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
      let datasource = tableView.dataSource as? TvGamesTableDataSource
      (view as! TvGamesTableViewHeader).date.text = datasource?.allItems[section].date.format("EEEE, yyyy-MM-dd")
   }
   
   func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      let view = tableView.dequeueReusableCellWithIdentifier(TvGamesTableViewHeader.headerIdentifier) as? TvGamesTableViewHeader
      return view
   }

   func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      tableView.deselectRowAtIndexPath(indexPath, animated: false)
   }
   
}

struct TvGamesDataSourceItem {
   var date: Moment
   var items: [FPTGame]
}

class TvGamesDataSource {
   
   private var allGames: [FPTGame] = []
   private var favourites: [FPTFavouriteTeam] = []
   private (set) var allItems: [TvGamesDataSourceItem] = []
   
   private func loadDataSourceItems() {
      allGames = allGames.map({
         let currentGame = $0
         currentGame.homeTeamCurrentUserFavourite = (self.favourites.filter({ $0.team == currentGame.homeTeam }).count == 1)
         currentGame.awayTeamCurrentUserFavourite = (self.favourites.filter({ $0.team == currentGame.awayTeam }).count == 1)
         return currentGame
      })
      var allDates = NSSet(array: allGames.map({ return moment($0.date).startOf(.Days).date() })).allObjects
      allDates.sortInPlace { (date1, date2) -> Bool in
         return (date1 as! NSDate).timeIntervalSince1970 < (date2 as! NSDate).timeIntervalSince1970
      }
      allItems = allDates.map({ (date) -> TvGamesDataSourceItem in
         let newItem = TvGamesDataSourceItem(date: moment(date as! NSDate), items: self.allGames.filter({ (game) -> Bool in
            let currentDate = moment(date as! NSDate)
            return game.dateMoment >= currentDate.startOf(.Days) && game.dateMoment < currentDate.endOf(.Days)
         }))
         return newItem
      })
      NSNotificationCenter.defaultCenter().postNotificationName(FPTConstants.Notifications.GamesDataSourceUpdatedNotification, object: self)
   }
   
   func loadGames() {
      PFUser.getCurrentUserFavourites { (favourites, favouritesError) -> Void in
         if favouritesError == nil {
            self.favourites = favourites as! [FPTFavouriteTeam]
            let query = PFQuery(className: FPTGame.parseClassName())
            query.whereKey("date", greaterThan: moment().startOf(.Days).date())
            query.orderByAscending("date")
            query.findObjectsInBackgroundWithBlock { (games, gamesError) -> Void in
               if gamesError == nil {
                  self.allGames = games as! [FPTGame]
                  self.loadDataSourceItems()
               } else {
                  print("error getting items from local storage: \(gamesError)")
               }
            }
         }
      }
      
   }
   
}

class TvGamesViewController: UIViewController, NSURLConnectionDataDelegate {
   
   private let gamesDataSource = TvGamesDataSource()
   private let tableDataSource = TvGamesTableDataSource()
   private let tableDelegate = TvGamesTableDelegate()
   private var notificationObserver: NSObjectProtocol?
   private var favouritesObserver: NSObjectProtocol?
   private var loggedInObserver: NSObjectProtocol?
   private var shouldReloadData = false
   
   @IBOutlet var tableView: UITableView!
   
   //NSObject
   
   deinit {
      if let observer = notificationObserver {
         NSNotificationCenter.defaultCenter().removeObserver(observer)
      }
   }
   
   //MARK: UIViewController
   
   override func viewDidLoad() {
      super.viewDidLoad()
      notificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(FPTConstants.Notifications.GamesDataSourceUpdatedNotification, object: gamesDataSource, queue: nil, usingBlock: { (notification) -> Void in
         self.tableView.reloadData()
      })
      favouritesObserver = NSNotificationCenter.defaultCenter().addObserverForName(FPTConstants.Notifications.FavouritesUpdatedNotification, object: nil, queue: nil, usingBlock: { (notification) -> Void in
         self.shouldReloadData = true
      })
      loggedInObserver = NSNotificationCenter.defaultCenter().addObserverForName(FPTConstants.Notifications.LoggedInUserChangedNotification, object: nil, queue: nil, usingBlock: { (notification) -> Void in
         self.gamesDataSource.loadGames()
      })
      tableView.dataSource = tableDataSource
      tableView.delegate = tableDelegate
      gamesDataSource.loadGames()
      
      let ud = NSUserDefaults(suiteName: "group.com.amg.Futebol365")
   }
   
   override func viewWillAppear(animated: Bool) {
      super.viewWillAppear(animated)
      if shouldReloadData {
         gamesDataSource.loadGames()
         shouldReloadData = false
      }
   }
   
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
      if segue.identifier == "showDetail" {
         if let tableCell = sender as? TvGamesTableViewCell {
            let detailController = segue.destinationViewController as! DetailViewController
            detailController.item = tableCell.item
         }
      }
      
   }
   
}

