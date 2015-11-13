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
    var activeRoster = Roster?()
    var heroDisplayed = Hero?()
    var downloadedSessionLog = SessionLog(name: "", date: "", notes: "", parseObjectId: "")
    var parseSessionLogName = [String]()
    var parseSessionLogDate = [String]()
    var parseSessionLogNotes = [String]()
    var parseSessionLogObjectId = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if heroDisplayed!.log.count == 0 {
            getSessionLogsFromParse()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        sessionLogTable.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (heroDisplayed?.log.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("sessionLogCell")
        cell?.textLabel!.text = heroDisplayed!.log[indexPath.row].name
        cell!.textLabel!.font = UIFont.boldSystemFontOfSize(17)
        cell?.detailTextLabel!.text = heroDisplayed!.log[indexPath.row].date
        cell!.detailTextLabel!.font = UIFont.boldSystemFontOfSize(11)
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            func deleteSession() {
                let sessionToDelete = heroDisplayed?.log[indexPath.row]
               
                
                let query = PFQuery(className:"Log")
                query.getObjectInBackgroundWithId(heroDisplayed!.log[indexPath.row].parseObjectId) {
                    (Log: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    } else if let log = Log {
                        log.deleteInBackground()
                        
                        print("session log deleted from parse")
                    }
                }
                heroDisplayed?.deleteSessionLog(sessionToDelete!)
                print(heroDisplayed?.logIds)
                updateHeroLogIdsParse()
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destVC: LogDetailViewController = segue.destinationViewController as! LogDetailViewController
        destVC.heroDisplayed = heroDisplayed
        destVC.activeRoster = activeRoster
        if segue.identifier == "viewSessionLogSegue" {
            let selectedIndex = sessionLogTable.indexPathForCell(sender as! UITableViewCell)
            destVC.activateEditMode = true
            destVC.heroLogDisplayed = heroDisplayed!.log[(selectedIndex?.row)!]
        }
    }
    
    func unwindForSegueHeroSession(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
          sessionLogTable.reloadData()
    }
    
    func getSessionLogsFromParse() {
        let rosterName = "\(activeUser!.username!)'s hero roster"
        let logQuery = PFQuery(className: "Log")
        logQuery.whereKey("owner", equalTo: rosterName)
        
        logQuery.findObjectsInBackgroundWithBlock{ (Log: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Retreived \(Log!.count) logs")
                dispatch_async(dispatch_get_main_queue()) {
                    // If the query succeeds, all logs for the active user will be pulled down.  We need to filter them in order to populate the table with logs for the currently displayed hero.
                    for object in Log! {
                        // The if statement below will make sure that only logs which match the name of the current hero will be fetched.
                        if (object["logForHero"] as! String) == self.heroDisplayed?.name {
                            // The if/contains statment makes sure that as a log is fetched and added to the parse arrays, the for loop won't fetch the same log again if it has already been stored.
                            if self.parseSessionLogName.contains(object["sessionName"] as! String) == false {
    
                                self.downloadedSessionLog.name = object["sessionName"] as! String
                                self.downloadedSessionLog.date = object["date"] as! String
                                self.downloadedSessionLog.notes = object["notes"] as! String
          
                                self.parseSessionLogName.append(self.downloadedSessionLog.name)
                                self.parseSessionLogDate.append(self.downloadedSessionLog.date)
                                self.parseSessionLogNotes.append(self.downloadedSessionLog.notes)
                                self.parseSessionLogObjectId.append(object.objectId! as String)
                            }
                        }
                    }
                    self.populateSessionLog()
                    self.sessionLogTable.reloadData()
                }
            }
        }
    }
    
    func populateSessionLog() {
        for (index,_) in parseSessionLogName.enumerate() {
            heroDisplayed?.addSessionLog(SessionLog(name: parseSessionLogName[index], date: parseSessionLogDate[index], notes: parseSessionLogNotes[index], parseObjectId: parseSessionLogObjectId[index]))
        }
    }
    func updateHeroLogIdsParse() {
        let query = PFQuery(className:"Hero")
        query.getObjectInBackgroundWithId(heroDisplayed!.parseObjectId) {
            (Hero: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let hero = Hero {
                hero["logIds"] = self.heroDisplayed?.logIds
                hero.saveInBackground()
                print("hero updated on parse")
            }
        }
    }

}
