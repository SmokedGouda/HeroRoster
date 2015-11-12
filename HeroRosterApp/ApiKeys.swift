//
//  ApiKeys.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/12/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import Foundation

let applicationId = valueForAPIKey(keyname: "API_APPLICATION_ID")
let clientID = valueForAPIKey(keyname:  "API_CLIENT_ID")

func valueForAPIKey(keyname keyname:String) -> String {
    let filePath = NSBundle.mainBundle().pathForResource("ApiKeys", ofType:"plist")
    let plist = NSDictionary(contentsOfFile:filePath!)
    
    let value:String = plist?.objectForKey(keyname) as! String
    return value
}

