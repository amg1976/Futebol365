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

class TvGamesTableViewCell: UITableViewCell {
   
   static let cellIdentifier = "TvGamesCellIdentifier"
   var item: FPTGame?
   
   @IBOutlet weak var teams: UILabel!
   @IBOutlet weak var time: UILabel!
   @IBOutlet weak var channelName: UILabel!
   
}

class TvGamesTableDataSource: NSObject, UITableViewDataSource {
   
   private var notificationObserver: NSObjectProtocol?
   
   private (set) var allItems: [TvGamesDataSourceItem] = []
   
   //MARK: NSObject
   
   override init() {
      super.init()
      notificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(FPTConstants.Notifications.gamesDataSourceUpdatedNotification, object: nil, queue: nil) { (notification) -> Void in
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
      var cell = tableView.dequeueReusableCellWithIdentifier(TvGamesTableViewCell.cellIdentifier) as? TvGamesTableViewCell
      cell?.item = allItems[indexPath.section].items[indexPath.row]
      return cell!
   }
   
   func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return allItems[section].date.format(dateFormat: "yyyy-MM-dd")
   }
   
}

class TvGamesTableDelegate: NSObject, UITableViewDelegate {
   
   //MARK: UITableViewDelegate
   
   func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      
      if let tableCell = cell as? TvGamesTableViewCell {
         tableCell.teams.text = "\(tableCell.item!.homeTeam) - \(tableCell.item!.awayTeam)"
         tableCell.time.text = moment(tableCell.item!.date).format(dateFormat: "HH:mm")
         tableCell.channelName.text = tableCell.item?.tvChannel
      }
      
   }
   
}

struct TvGamesDataSourceItem {
   var date: Moment
   var items: [FPTGame]
}

class TvGamesDataSource {
   
   private var allGames: [FPTGame] = []
   private (set) var allItems: [TvGamesDataSourceItem] = []
   
   private func loadDataSourceItems() {
      var allDates = NSSet(array: allGames.map({ return moment($0.date).startOf(.Days).date() })).allObjects
      allDates.sort { (date1, date2) -> Bool in
         return (date1 as! NSDate).timeIntervalSince1970 < (date2 as! NSDate).timeIntervalSince1970
      }
      println(allDates)
      allItems = allDates.map({ (date) -> TvGamesDataSourceItem in
         let newItem = TvGamesDataSourceItem(date: moment(date as! NSDate), items: self.allGames.filter({ (game) -> Bool in
            let currentDate = moment(date as! NSDate)
            return moment(game.date) >= currentDate.startOf(.Days) && moment(game.date) < currentDate.endOf(.Days)
         }))
         return newItem
      })
      NSNotificationCenter.defaultCenter().postNotificationName(FPTConstants.Notifications.gamesDataSourceUpdatedNotification, object: self)
   }
   
   private func parseXmlToObjects(xmlItems: [SMXMLElement]) {

      var addedNewItems = false
      
      let query = PFQuery(className: FPTGame.parseClassName())
      for item in xmlItems {
         query.whereKey("guid", equalTo: item.valueWithPath("guid"))
         if let game = query.findObjects()?.first as? FPTGame {
            game.update(xmlElement: item)
         } else {
            var game = FPTGame(xmlElement: item)
            allGames.append(game)
            addedNewItems = true
         }
      }

      if addedNewItems {
         loadDataSourceItems()
      }
      
   }
   
   func loadGames() {
      
      let query = PFQuery(className: FPTGame.parseClassName())
      query.whereKey("date", greaterThan: moment().startOf(.Days).date())
      query.orderByAscending("date")
      query.findObjectsInBackgroundWithBlock { (items, error) -> Void in
         if error == nil {
            self.allGames = items as! [FPTGame]
            self.loadDataSourceItems()
         } else {
            println("error getting items from local storage: \(error)")
         }
      }
      
      if moment().intervalSince(FPTAppConfiguration.sharedInstance.lastGamesUpdate).days > 1 {
         println("will get data from rss feed")
         let urlRequest = NSURLRequest(URL: NSURL(string: "http://feeds.feedburner.com/futebol365/futebolnatv")!)
         NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue()) { (urlResponse, responseData, responseError) -> Void in
            if responseError == nil {
               println("Got data from rss feed")
               var xmlError: NSError?
               let xmlDoc = SMXMLDocument(data: responseData, error: &xmlError)
               self.parseXmlToObjects(xmlDoc.childNamed("channel").childrenNamed("item") as! [SMXMLElement])
               FPTAppConfiguration.sharedInstance.lastGamesUpdate = moment()
            } else {
               println("error getting xml: \(responseError)")
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
      notificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(FPTConstants.Notifications.gamesDataSourceUpdatedNotification, object: gamesDataSource, queue: nil, usingBlock: { (notification) -> Void in
         self.tableView.reloadData()
      })
      tableView.dataSource = tableDataSource
      tableView.delegate = tableDelegate
      gamesDataSource.loadGames()
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

