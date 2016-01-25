//
//  HeroRosterViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/3/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit
import Parse

class HeroRosterViewController: UIViewController, UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var heroRosterTable: UITableView!
   
    var userRoster = Roster()
    var activeUser = PFUser.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        heroRosterTable.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.6)
        getRosterFromParse()
        getHerosFromParse()
        getGmSessionLogsFromParse()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        heroRosterTable.reloadData()
    }
    
    func getRosterFromParse() {
        let rosterName = activeUser!.username!
        let query = PFQuery(className: "Roster")
        query.whereKey("name", equalTo: rosterName)
        query.findObjectsInBackgroundWithBlock {
            (Roster: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.loadUserRosterWithDownloadedRosterProperties(Roster!)
            } else {
                print(error)
            }
        }
    }
    
    func loadUserRosterWithDownloadedRosterProperties(rosterFromParse: [PFObject]) {
        dispatch_async(dispatch_get_main_queue()) {
            for object:PFObject in rosterFromParse {
                self.userRoster.userName = object["name"] as! String
                self.userRoster.parseObjectId = object.objectId! as String
                self.userRoster.scenarioRecords = object["scenarioRecords"] as! [String : [String]]
            }
        }
    }
    
    func getHerosFromParse() {
        let rosterName = activeUser!.username!
        let query = PFQuery(className: "Hero")
        query.whereKey("owner", equalTo: rosterName)
        query.findObjectsInBackgroundWithBlock{ (Hero: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.parseTheDownloadedHeros(Hero!)
            } else {
                print(error)
            }
        }
    }
    
    func parseTheDownloadedHeros(downloadedHeros: [PFObject]) {
        dispatch_async(dispatch_get_main_queue()) {
            for object in downloadedHeros {
                let name = object["name"] as! String
                let number = object["number"] as! String
                let heroClass = object["heroClass"] as! String
                let race = object["race"] as! String
                let gender = object["gender"] as! String
                let level = object["level"] as! String
                let faction = object["faction"] as! String
                let prestigePoints = object["prestigePoints"] as! String
                let heroObjectId = object.objectId! as String
                let logIds = object["logIds"] as! [String]
                let downloadedHero = Hero(name: name, number: number, heroClass: heroClass, race: race, gender: gender, level: level, faction: faction, prestigePoints: prestigePoints, log: [], parseObjectId: heroObjectId, logIds: logIds)
                
                self.userRoster.addHeroToRoster(downloadedHero)
            }
            self.heroRosterTable.reloadData()
        }
    }
    
    func getGmSessionLogsFromParse() {
        let rosterName = activeUser!.username!
        let query = PFQuery(className: "GmLog")
        query.whereKey("owner", equalTo: rosterName)
        query.findObjectsInBackgroundWithBlock{ (GmLog: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.parseTheDownloadedGmSessionLogs(GmLog!)
            } else {
                print(error)
            }
        }
    }
    
    func parseTheDownloadedGmSessionLogs(downloadedGmSessionLogs: [PFObject]) {
        dispatch_async(dispatch_get_main_queue()) {
            for object in downloadedGmSessionLogs {
                let name = object["sessionName"] as! String
                let date = object["date"] as! NSDate
                let notes = object["notes"] as! String
                let gmSessionLogObjectId = object.objectId! as String
                let creditForHero = object["creditForHero"] as! String
                let downloadedGmSessionLog = GmSessionLog(name: name, date: date, notes: notes, parseObjectId: gmSessionLogObjectId, creditForHero: creditForHero)
                
                self.userRoster.addGmSessionLog(downloadedGmSessionLog)
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRoster.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString }.count
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("heroNameCell")
        let cellColor = UIColor.clearColor()
        let disclosureImage = UIImage(named: "arrow16x16")
        cell?.backgroundColor = cellColor
        cell?.textLabel?.backgroundColor = cellColor
        cell?.detailTextLabel?.backgroundColor = cellColor
        cell?.imageView?.backgroundColor = cellColor
        cell?.accessoryView = UIImageView(image: disclosureImage)
        cell!.textLabel!.text = userRoster.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString } [indexPath.row].name
        cell!.textLabel!.font = UIFont.boldSystemFontOfSize(17)
        cell!.detailTextLabel!.text = "\(userRoster.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString } [indexPath.row].heroClass), Level \(userRoster.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString } [indexPath.row].level)"
        cell!.detailTextLabel!.font = UIFont.boldSystemFontOfSize(11)
        cell!.imageView?.image = UIImage(named: userRoster.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString } [indexPath.row].heroClass)
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            func deleteHero() {
                let heroToDelete = userRoster.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString }[indexPath.row]
                let query = PFQuery(className:"Hero")
                query.getObjectInBackgroundWithId(heroToDelete.parseObjectId) {
                    (Hero: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    } else if let hero = Hero {
                        for objectId in heroToDelete.logIds {
                            self.removeHeroToDeletesLogsOnParse(objectId)
                        }
                        hero.deleteInBackground()
                    }
                }
                deleteScenariosFromScenarioRecords(heroToDelete)
                userRoster.deleteHeroFromRoster(heroToDelete)
                userRoster.updateScenarioRecordsOnParse(userRoster)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }

            let deleteAlert = UIAlertController(
                title: "About to delete hero", message: "Are you sure?  This action is irreversible.", preferredStyle: .Alert)
            let deleteAction = UIAlertAction(title: "Yes", style: .Destructive, handler: { (actionSheetController) -> Void in deleteHero()
                })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            deleteAlert.addAction(cancelAction)
            deleteAlert.addAction(deleteAction)
            presentViewController(deleteAlert, animated: true, completion: nil)
        }
    }
    
    func removeHeroToDeletesLogsOnParse(logObjectIdToDelete: String) {
        let query = PFQuery(className:"Log")
        query.getObjectInBackgroundWithId(logObjectIdToDelete) {
            (Log: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let log = Log {
                log.deleteInBackground()
            }
        }
    }

    func deleteScenariosFromScenarioRecords(recordsForHero: Hero) {
        for (key, value) in userRoster.scenarioRecords {
            if value[0] == recordsForHero.name {
                userRoster.scenarioRecords[key] = nil
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addHeroSegue" {
            let destVC: HeroDetailViewController = segue.destinationViewController as! HeroDetailViewController
            destVC.userRoster = userRoster
        } else if segue.identifier == "heroDetailSegue" {
            let destVC: HeroDetailViewController = segue.destinationViewController as! HeroDetailViewController
            let selectedIndex = heroRosterTable.indexPathForCell(sender as! UITableViewCell)
            destVC.userRoster = userRoster
            destVC.heroDisplayed = userRoster.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString }[(selectedIndex?.row)!]
            destVC.activateEditMode = true
        } else if segue.identifier == "gmSessionTableSegue" {
            let destVC: GmSessionLogViewController = segue.destinationViewController as! GmSessionLogViewController
            destVC.userRoster = userRoster
        } else {
            let destVC: ScenarioSearchViewController = segue.destinationViewController as! ScenarioSearchViewController
            destVC.userRoster = userRoster
        }
    }

    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        PFUser.logOut()
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {self.navigationController?.navigationBar.alpha = 0.0}, completion: nil)
        navigationController?.popToRootViewControllerAnimated(true)
    }
}
