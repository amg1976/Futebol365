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
   
   @IBOutlet weak var label: UILabel!
   
}

class TvGamesTableDataSource: NSObject, UITableViewDataSource {
   
   private var notificationObserver: NSObjectProtocol?
   
   private (set) var allItems: [FPTGame] = []
   
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
      return allItems.count
   }
   
   func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 1
   }
   
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      var cell = tableView.dequeueReusableCellWithIdentifier(TvGamesTableViewCell.cellIdentifier) as? TvGamesTableViewCell
      cell?.item = allItems[indexPath.row]
      return cell!
   }
   
}

class TvGamesTableDelegate: NSObject, UITableViewDelegate {
   
   //MARK: UITableViewDelegate
   
   func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      
      if let tableCell = cell as? TvGamesTableViewCell {
         tableCell.label?.text = tableCell.item?.title
      }
      
   }
   
}

class TvGamesDataSource {
   
   var allItems: [FPTGame] = []
   
   private func parseXmlToObjects(xmlItems: [SMXMLElement]) {
      var addedNewItems = false
      let query = PFQuery(className: FPTGame.parseClassName())
      for item in xmlItems {
         query.whereKey("guid", equalTo: item.valueWithPath("guid"))
         if let game = query.findObjects()?.first as? FPTGame {
            game.update(xmlElement: item)
         } else {
            var game = FPTGame(xmlElement: item)
            allItems.append(game)
            addedNewItems = true
         }
         
         if addedNewItems {
            allItems.sort({ $0.date.timeIntervalSince1970 < $1.date.timeIntervalSince1970})
            NSNotificationCenter.defaultCenter().postNotificationName(FPTConstants.Notifications.gamesDataSourceUpdatedNotification, object: self)
         }
      }
      
   }
   
   func loadGames() {
      
      let query = PFQuery(className: FPTGame.parseClassName())
      query.whereKey("date", greaterThan: moment().startOf(.Days).date())
      query.orderByAscending("date")
      query.findObjectsInBackgroundWithBlock { (items, error) -> Void in
         if error == nil {
            self.allItems = items as! [FPTGame]
            NSNotificationCenter.defaultCenter().postNotificationName(FPTConstants.Notifications.gamesDataSourceUpdatedNotification, object: self)
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

