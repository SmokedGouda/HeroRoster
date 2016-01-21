//
//  HeroStatOptionsViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/3/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit
import Parse

class HeroStatOptionsViewController: UIViewController, UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var heroStatTable: UITableView!
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    
    var userRoster = Roster?()
    var navBarTitle = String()
    var chosenStat: Int?
    var lastSelectedRow: Int?
    var selectedRow: NSIndexPath?
    var heroStatsArrayToDisplay = [String]()
    var nameToReturn = String()
    var activateHeroNameTable = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleAndBackgroundColorForTableView()
        preselectRowWithAnyDataFromPreviousView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setTitleAndBackgroundColorForTableView() {
        heroStatTable.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.6)
        navigationBarTitle.title = navBarTitle
    }
    
    func preselectRowWithAnyDataFromPreviousView() {
        if lastSelectedRow != nil {
            selectedRow = NSIndexPath(forRow: lastSelectedRow!, inSection: 0)
            chosenStat = selectedRow!.row
            if activateHeroNameTable == true {
                nameToReturn = userRoster!.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString } [chosenStat!].name
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = Int()
        if activateHeroNameTable == true {
            rowCount = userRoster!.heros.count
        } else {
            rowCount = heroStatsArrayToDisplay.count
        }
        return rowCount
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let paths: [NSIndexPath]
        if let previous = selectedRow {
            paths = [indexPath, previous]
        } else {
            paths = [indexPath]
        }
        selectedRow = indexPath
        tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: .None)
        chosenStat = indexPath.row
        if activateHeroNameTable == true {
            nameToReturn = userRoster!.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString } [chosenStat!].name
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("optionCell", forIndexPath: indexPath)
        let cellColor = UIColor.clearColor()
        cell.backgroundColor = cellColor
        cell.textLabel?.backgroundColor = cellColor
        cell.detailTextLabel?.backgroundColor = cellColor
        cell.imageView?.backgroundColor = cellColor
        cell.textLabel!.font = UIFont.boldSystemFontOfSize(17)
        if activateHeroNameTable == true {
            cell.textLabel!.text = userRoster!.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString } [indexPath.row].name
            cell.imageView?.image = UIImage(named: userRoster!.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString } [indexPath.row].heroClass)
        } else {
            cell.textLabel!.text = heroStatsArrayToDisplay[indexPath.row]
            if navigationBarTitle.title == "Class" {
                cell.imageView?.image = UIImage(named: HeroStats().heroClass[indexPath.row])
            } else if navigationBarTitle.title == "Gender" {
                cell.imageView?.image = UIImage(named: HeroStats().gender[indexPath.row])
            }
        }
        if indexPath == selectedRow {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("unwindHeroStatOptionsSegue", sender: self)
    }
}
