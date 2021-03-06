//
//  ScenarioListViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/30/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit

class ScenarioListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var scenarioTable: UITableView!
    
    var scenarioNameToReturn = String()
    var selectedRow: NSIndexPath?
    var lastSelectedSection: Int?
    var lastSelectedRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if lastSelectedSection != nil {
            selectedRow = NSIndexPath(forRow: lastSelectedRow!, inSection: lastSelectedSection!)
            scenarioNameToReturn = Scenarios().scenarioNames[lastSelectedSection!][lastSelectedRow!]
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Scenarios().seasons.count
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.alpha = 1.0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Scenarios().seasons[section]
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return Scenarios().indexTitles
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Scenarios().scenarioNames[section].count
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
        scenarioNameToReturn = Scenarios().scenarioNames[indexPath.section][indexPath.row]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("scenarioNameCell", forIndexPath: indexPath)
        cell.textLabel!.text = Scenarios().scenarioNames[indexPath.section][indexPath.row]
        if indexPath == selectedRow {
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(17)
        } else {
            cell.textLabel?.font = UIFont.systemFontOfSize(17)
        }
        return cell
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("unwindScenarioSegue", sender: self)
    }
}
