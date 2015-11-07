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
        print(heroDisplayed!.name)
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
        cell?.detailTextLabel!.text = heroDisplayed!.log[indexPath.row].date
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            func deleteSession() {
                let sessionToDelete = heroDisplayed?.log[indexPath.row]
                heroDisplayed?.deleteSessionLog(sessionToDelete!)
                
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
        if segue.identifier == "viewSessionLogSegue" {
            let selectedIndex = sessionLogTable.indexPathForCell(sender as! UITableViewCell)
            destVC.activateEditMode = true
            destVC.sessionName = heroDisplayed!.log[(selectedIndex?.row)!].name
            destVC.date = heroDisplayed!.log[(selectedIndex?.row)!].date
            destVC.notes = heroDisplayed!.log[(selectedIndex?.row)!].notes
            destVC.heroLogDisplayed = heroDisplayed!.log[(selectedIndex?.row)!]
      
        }
       
    }
    
    func unwindForSegueHeroSession(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
          sessionLogTable.reloadData()
    }
  

}
