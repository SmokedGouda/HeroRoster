//
//  HeroStatOptionsViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/3/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit

class HeroStatOptionsViewController: UIViewController, UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    
    
    var navBarTitle = String()
    var chosenStat = Int()
    var lastSelectedRow: NSIndexPath? = nil
    var statFromPreviousView = String()
    var heroStatsArrayToDisplay = [String]()
    var detailedStatFromStartView = String()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarTitle.title = navBarTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heroStatsArrayToDisplay.count
    }
    
    @IBAction func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // This allows the checkmark to disappear from the current cell when a new cell is touched.
        if let last = lastSelectedRow {
            let oldSelectedCell = tableView.cellForRowAtIndexPath(last)
            oldSelectedCell!.accessoryType = .None
        }
        
        // This will place a checkmark on the cell which is touched.
        lastSelectedRow = indexPath
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell!.accessoryType = .Checkmark
        
        chosenStat = indexPath.row
        cell!.textLabel?.text = heroStatsArrayToDisplay[chosenStat]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("optionCell", forIndexPath: indexPath)
        cell.textLabel!.text = heroStatsArrayToDisplay[indexPath.row]
        
        // When the table loads, this will put a checkmark on the cell which was displayed on the previous view.
        
        if cell.textLabel!.text! == statFromPreviousView {
            cell.accessoryType = .Checkmark
            lastSelectedRow = indexPath
        }
        return cell
    }
}
