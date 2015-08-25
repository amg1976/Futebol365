//
//  TvGamesViewController.swift
//  Futebol365
//
//  Created by Adriano Goncalves on 23/08/2015.
//  Copyright (c) 2015 Adriano Goncalves. All rights reserved.
//

import UIKit
import Parse

class TvGamesViewController: UITableViewController, NSURLConnectionDataDelegate {
    
    private var allItems: [FPTGame] = []

    //MARK: TvGamesViewController
    
    private func parseXmlToObjects(xmlItems: [SMXMLElement]) {
        for item in xmlItems {
            var game = FPTGame(xmlElement: item)
            allItems.append(game)
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    private func loadGames() {
        
        let query = PFQuery(className: FPTGame.parseClassName())
        query.findObjectsInBackgroundWithBlock { (items, error) -> Void in
            if error == nil {
                self.allItems = items as! [FPTGame]
                self.tableView.reloadData()
            } else {
                println("error getting items from local storage: \(error)")
            }
        }
/*
        let urlRequest = NSURLRequest(URL: NSURL(string: "http://feeds.feedburner.com/futebol365/futebolnatv")!)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue()) { (urlResponse, responseData, responseError) -> Void in
            if responseError == nil {
                var xmlError: NSError?
                let xmlDoc = SMXMLDocument(data: responseData, error: &xmlError)
                self.parseXmlToObjects(xmlDoc.childNamed("channel").childrenNamed("item") as! [SMXMLElement])
            } else {
                println("error getting xml: \(responseError)")
            }
        }
*/
    }
    
    //MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGames()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                let item = allItems[indexPath.row]
                let detailController = segue.destinationViewController as! DetailViewController
                detailController.item = item
            }
        }

    }
    
    //MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cellIdentifier") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cellIdentifier") as UITableViewCell
        }
        
        return cell!
    }

    //MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let item = allItems[indexPath.row]
        cell.textLabel?.text = item.title
        
    }
    
}

