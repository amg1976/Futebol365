//
//  NextGamesExtensionViewController.swift
//  NextGameExtension
//
//  Created by Adriano Goncalves on 12/09/2015.
//  Copyright © 2015 Adriano Goncalves. All rights reserved.
//

import UIKit
import NotificationCenter
import Parse
import SwiftMoment

class NextGamesExtensionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NCWidgetProviding {
   
   private var items: [FPTGame] = []
   private var needsUpdate = false
   private var currentUser: PFUser?

   @IBOutlet weak var tableView: UITableView!
   
   //MARK: UIViewController
   
   override func awakeFromNib() {
      super.awakeFromNib()
      
      if !Parse.isLocalDatastoreEnabled() {
         Parse.enableDataSharingWithApplicationGroupIdentifier("group.com.amg.Futebol365", containingApplication: "com.amg.Futebol365")
         Parse.setApplicationId("0N1kCdAA5d2A7vMyrEqJON06vZVfjp4z5NSgjNzD", clientKey: "oHQ9MeJ64rJoFdQgqqbfiJSB12qXBrBhsjTiTu8y")
      }
      
      self.currentUser = PFUser.currentUser()
      
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 62
   }
   
   //MARK: NCWidgetProviding
   
   func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
      // Perform any setup necessary in order to update the view.
      
      // If an error is encountered, use NCUpdateResult.Failed
      // If there's no update required, use NCUpdateResult.NoData
      // If there's an update, use NCUpdateResult.NewData

      var result = NCUpdateResult.NoData
      
      getItems { (items, error) -> Void in
         if error == nil && items != nil {
            result = .NewData
            self.items = items!
            self.tableView.reloadData()
            self.preferredContentSize = self.tableView.contentSize
            self.needsUpdate = false
         } else {
            result = .NoData
         }
         completionHandler(result)
      }
   }
   
   func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
      return UIEdgeInsetsMake(4, 4, 4, 4)
   }
   
   //MARK: UITableViewDataSource
   
   func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 1
   }
   
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return items.count > 5 ? 5 : items.count
   }
   
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("NextGamesExtensionCellIdentifier") as! NextGamesExtensionCell
      return cell
   }
   
   func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      if let cell = cell as? NextGamesExtensionCell {
         let game = items[indexPath.row]
         cell.teamsLabel.text = "\(currentUser?.username) \(game.homeTeamName) - \(game.awayTeamName)"
         cell.dateLabel.text = game.dateMoment.format("HH:mm") + " @ " + game.tvChannel
      }
   }
   
   //MARK: Private
   
   private func getItems(completionBlock: (items: [FPTGame]?, error: NSError?)->Void) {
      
      let query1 = PFQuery(className: FPTGame.parseClassName())
      query1.whereKey("date", greaterThan: moment().substract(120, TimeUnit.Minutes).date())
      query1.whereKey("date", lessThanOrEqualTo: moment().endOf(TimeUnit.Days).date())
      query1.orderByAscending("date")
      
      let query2 = query1.copy() as! PFQuery
      
      let finalQuery = PFQuery.orQueryWithSubqueries([query1, query2])

      PFUser.getCurrentUserFavourites { (favourites, error) -> Void in
         if error == nil && favourites?.count > 0 {
            let favouriteTeams = (favourites as! [FPTFavouriteTeam]).map({ $0.team })
            query1.whereKey("homeTeam", containedIn: favouriteTeams)
            query2.whereKey("awayTeam", containedIn: favouriteTeams)
            finalQuery.findObjectsInBackgroundWithBlock({ (games, error) -> Void in
               if error == nil {
                  completionBlock(items: games as? [FPTGame], error: nil)
               } else {
                  completionBlock(items: nil, error: error)
                  print("error getting items from local storage: \(error)")
               }
            })
         } else {
            query1.findObjectsInBackgroundWithBlock({ (games, error) -> Void in
               if error == nil {
                  completionBlock(items: games as? [FPTGame], error: nil)
               } else {
                  completionBlock(items: nil, error: error)
                  print("error getting items from local storage: \(error)")
               }
            })
         }
      }

   }
   
}

class NextGamesExtensionCell: UITableViewCell {
   @IBOutlet weak var teamsLabel: UILabel!
   @IBOutlet weak var dateLabel: UILabel!
}
