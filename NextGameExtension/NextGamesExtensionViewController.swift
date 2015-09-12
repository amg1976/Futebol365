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
   
   @IBOutlet weak var tableView: UITableView!
   
   //MARK: UIViewController
   
   override func awakeFromNib() {
      super.awakeFromNib()
      
      Parse.setApplicationId("0N1kCdAA5d2A7vMyrEqJON06vZVfjp4z5NSgjNzD", clientKey: "oHQ9MeJ64rJoFdQgqqbfiJSB12qXBrBhsjTiTu8y")
      
      getItems { (items, error) -> Void in
         if error == nil && items != nil {
            self.needsUpdate = true
            self.items = items!
            self.tableView.reloadData()
            self.preferredContentSize = self.tableView.contentSize
         }
      }
      
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
         cell.teamsLabel.text = "\(game.homeTeamName) - \(game.awayTeamName)"
         cell.dateLabel.text = game.dateMoment.format("HH:mm") + " @ " + game.tvChannel
      }
   }
   
   //MARK: Private
   
   private func getItems(completionBlock: (items: [FPTGame]?, error: NSError?)->Void) {

      let query = PFQuery(className: FPTGame.parseClassName())
      query.whereKey("date", greaterThan: moment().substract(120, TimeUnit.Minutes).date())
      query.whereKey("date", lessThanOrEqualTo: moment().endOf(TimeUnit.Days).date())
      query.orderByAscending("date")
      query.findObjectsInBackgroundWithBlock { (items, error) -> Void in
         if error == nil {
            completionBlock(items: items as? [FPTGame], error: nil)
         } else {
            completionBlock(items: nil, error: error)
            print("error getting items from local storage: \(error)")
         }
      }
   
   }
   
}

class NextGamesExtensionCell: UITableViewCell {
   @IBOutlet weak var teamsLabel: UILabel!
   @IBOutlet weak var dateLabel: UILabel!
}
