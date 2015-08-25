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
    @NSManaged var homeTeam: String
    @NSManaged var awayTeam: String
    var date: Moment {
        return moment(dateString, "yyyy-MM-dd' às 'HH:mm")!
    }
    
    override init() {
        super.init()
    }
    
    init(xmlElement: SMXMLElement) {
        super.init(className:FPTGame.parseClassName())
        
        link = xmlElement.valueWithPath("link")
        title = xmlElement.valueWithPath("title")
        guid = xmlElement.valueWithPath("guid")
        
        let re = Regex("^([a-zA-Z0-9 .]+): (.+) - (.+) \\((\\d{4}-\\d{2}-\\d{2} às \\d{2}:\\d{2})\\)$")
        if re.test(title) {
            for match in re.matches(title) {
                let _title = NSString(string: title)
                tvChannel = _title.substringWithRange(match.rangeAtIndex(1))
                homeTeam = _title.substringWithRange(match.rangeAtIndex(2))
                awayTeam = _title.substringWithRange(match.rangeAtIndex(3))
                dateString = _title.substringWithRange(match.rangeAtIndex(4))
            }
        }
        
        self.saveEventually()
    }

}
