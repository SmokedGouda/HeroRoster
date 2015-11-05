//
//  HeroSessionLogViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/5/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit

class HeroSessionLogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var sessionLogTable: UITableView!
    
    var heroDisplayed = Hero?()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        sessionLogTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (heroDisplayed?.log.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("sessionLogCell")
        cell?.textLabel!.text = heroDisplayed!.log[indexPath.row].name
        return cell!
    }
  

}
