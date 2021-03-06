//
//  HeroSessionLogViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/5/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit
import Parse

class HeroSessionLogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var sessionLogTable: UITableView!
    
    var activeUser = PFUser.currentUser()
    var userRoster = Roster?()
    var heroDisplayed = Hero?()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionLogTable.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.6)
        if heroDisplayed!.log.count == 0 {
            getSessionLogsFromParse()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        sessionLogTable.reloadData()
    }
    
    func getSessionLogsFromParse() {
        let rosterName = activeUser!.username!
        let logQuery = PFQuery(className: "Log")
        logQuery.whereKey("owner", equalTo: rosterName)
        logQuery.findObjectsInBackgroundWithBlock{ (Log: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.filterSessionLogsForDisplayedHero(Log!)
                }
            } else {
                print(error)
            }
        }
    }
    
    func filterSessionLogsForDisplayedHero(logsToFilter: [PFObject]) {
        for object in logsToFilter {
            if (object["logForHero"] as! String) == self.heroDisplayed?.name {
                let name = object["sessionName"] as! String
                let date = object["date"] as! NSDate
                let notes = object["notes"] as! String
                let logObjectId = object.objectId! as String
                let downloadedSessionLog = SessionLog(name: name, date: date, notes: notes, parseObjectId: logObjectId)
                
                heroDisplayed?.addSessionLog(downloadedSessionLog)
            }
        }
        sessionLogTable.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heroDisplayed!.log.sort { $0.date.compare($1.date) == .OrderedAscending }.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("sessionLogCell")
        let cellColor = UIColor.clearColor()
        let disclosureImage = UIImage(named: "arrow16x16")
        let sortedSessionLogs = heroDisplayed!.log.sort { $0.date.compare($1.date) == .OrderedAscending }
        cell?.backgroundColor = cellColor
        cell?.textLabel?.backgroundColor = cellColor
        cell?.detailTextLabel?.backgroundColor = cellColor
        cell?.imageView?.backgroundColor = cellColor
        cell?.accessoryView = UIImageView(image: disclosureImage)
        cell?.textLabel!.text = sortedSessionLogs[indexPath.row].name
        cell!.textLabel!.font = UIFont.boldSystemFontOfSize(17)
        cell?.detailTextLabel!.text = SessionLog().stringFromDate(sortedSessionLogs[indexPath.row].date)
        cell!.detailTextLabel!.font = UIFont.boldSystemFontOfSize(11)
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            func deleteSession() {
                let sessionToDelete = heroDisplayed!.log.sort { $0.date.compare($1.date) == .OrderedAscending }[indexPath.row]
                let query = PFQuery(className:"Log")
                query.getObjectInBackgroundWithId(sessionToDelete.parseObjectId) {
                    (Log: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    } else if let log = Log {
                        log.deleteInBackground()
                    }
                }
                userRoster?.scenarioRecords[sessionToDelete.name] = nil
                heroDisplayed?.deleteSessionLog(sessionToDelete)
                updateHeroLogIdsOnParse()
                userRoster!.updateScenarioRecordsOnParse(userRoster!)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            
            let deleteAlert = UIAlertController(
                title: "About to delete session log", message: "Are you sure?  This action is irreversible.", preferredStyle: .Alert)
            let deleteAction = UIAlertAction(title: "Yes", style: .Destructive, handler: { (actionSheetController) -> Void in deleteSession()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            deleteAlert.addAction(cancelAction)
            deleteAlert.addAction(deleteAction)
            presentViewController(deleteAlert, animated: true, completion: nil)
        }
    }
    
    func updateHeroLogIdsOnParse() {
        let query = PFQuery(className:"Hero")
        query.getObjectInBackgroundWithId(heroDisplayed!.parseObjectId) {
            (Hero: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let hero = Hero {
                hero["logIds"] = self.heroDisplayed?.logIds
                hero.saveInBackground()
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destVC: LogDetailViewController = segue.destinationViewController as! LogDetailViewController
        destVC.heroDisplayed = heroDisplayed
        destVC.userRoster = userRoster
        if segue.identifier == "viewSessionLogSegue" {
            let selectedIndex = sessionLogTable.indexPathForCell(sender as! UITableViewCell)
            destVC.activateEditMode = true
            destVC.heroLogDisplayed = heroDisplayed!.log.sort { $0.date.compare($1.date) == .OrderedAscending }[(selectedIndex?.row)!]
        }
    }
}
