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
    var selectedRow: NSIndexPath?
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
        
        let paths: [NSIndexPath]
        if let previous = selectedRow {
            paths = [indexPath, previous]
        } else {
            paths = [indexPath]
        }
        
        selectedRow = indexPath
        tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: .None)
        chosenStat = indexPath.row
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("optionCell", forIndexPath: indexPath)
        cell.textLabel!.text = heroStatsArrayToDisplay[indexPath.row]
        
        if indexPath == selectedRow {
            cell.accessoryType = .Checkmark
            
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
}
