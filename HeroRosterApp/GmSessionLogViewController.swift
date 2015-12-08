//
//  GmSessionLogViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 12/8/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit
import Parse

class GmSessionLogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    var activeRoster = Roster?()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeRoster!.gmSessionLogs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("gmSessionLogCell")
        cell?.textLabel!.text = activeRoster!.gmSessionLogs.sort { $0.date.compare($1.date) == .OrderedAscending }[indexPath.row].name
        cell!.textLabel!.font = UIFont.boldSystemFontOfSize(17)
        cell?.detailTextLabel!.text = GmSessionLog().stringFromDate(activeRoster!.gmSessionLogs.sort { $0.date.compare($1.date) == .OrderedAscending }[indexPath.row].date)
        cell!.detailTextLabel!.font = UIFont.boldSystemFontOfSize(11)

        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            func deleteSession() {
                let sessionToDelete = activeRoster!.gmSessionLogs.sort { $0.date.compare($1.date) == .OrderedAscending }[indexPath.row]
                let query = PFQuery(className:"GmLogs")
                query.getObjectInBackgroundWithId(activeRoster!.gmSessionLogs.sort { $0.date.compare($1.date) == .OrderedAscending }[indexPath.row].parseObjectId) {
                    (GmLog: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    } else if let log = GmLog {
                        log.deleteInBackground()
                    }
                }
                activeRoster?.deleteGmSessionLog(sessionToDelete)
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
    
    
}
