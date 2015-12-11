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
    var downloadedHero = Hero()
    var downloadedGmSessionLog = GmSessionLog()
    var parseHeroName = [String]()
    var parseHeroNumber = [String]()
    var parseHeroClass = [String]()
    var parseHeroRace = [String]()
    var parseHeroGender = [String]()
    var parseHeroLevel = [String]()
    var parseHeroFaction = [String]()
    var parseHeroPrestigePoints = [String]()
    var parseHeroUsedLogNames: [String] = []
    var parseHeroObjectId = [String]()
    var parseHeroLogIds = [[String]]()
    var parseGmSessionLogName = [String]()
    var parseGmSessionLogDate = [NSDate]()
    var parseGmSessionLogNotes = [String]()
    var parseGmSessionLogObjectId = [String]()
    var parseGmSessionLogCreditForHero = [String]()
    
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
        cell!.detailTextLabel!.text = userRoster.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString } [indexPath.row].heroClass
        cell!.detailTextLabel!.font = UIFont.boldSystemFontOfSize(11)
        cell!.imageView?.image = UIImage(named: userRoster.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString } [indexPath.row].heroClass)
   
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            func deleteHero() {
                let heroToDelete = userRoster.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString }[indexPath.row]
                let query = PFQuery(className:"Hero")
                query.getObjectInBackgroundWithId(userRoster.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString }[indexPath.row].parseObjectId) {
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
    
    func deleteScenariosFromScenarioRecords(recordsForHero: Hero) {
        for (key, value) in userRoster.scenarioRecords {
            if value[0] == recordsForHero.name {
                userRoster.scenarioRecords[key] = nil
            }
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addHeroSegue" {
            let destVC: HeroDetailViewController = segue.destinationViewController as! HeroDetailViewController
            destVC.activeRoster = userRoster
        } else if segue.identifier == "heroDetailSegue" {
            let destVC: HeroDetailViewController = segue.destinationViewController as! HeroDetailViewController
            destVC.activeRoster = userRoster
            let selectedIndex = heroRosterTable.indexPathForCell(sender as! UITableViewCell)
            destVC.heroDisplayed = userRoster.heros.sort { $0.name.lowercaseString < $1.name.lowercaseString }[(selectedIndex?.row)!]
            destVC.activateEditMode = true
        } else if segue.identifier == "gmSessionTableSegue" {
            let destVC: GmSessionLogViewController = segue.destinationViewController as! GmSessionLogViewController
            destVC.activeRoster = userRoster
        } else {
            let destVC: ScenarioSearchViewController = segue.destinationViewController as! ScenarioSearchViewController
            destVC.activeRoster = userRoster
        }
    }

    func getRosterFromParse() {
        let rosterName = activeUser!.username!
        let query = PFQuery(className: "Roster")
        query.whereKey("name", equalTo: rosterName)
        query.findObjectsInBackgroundWithBlock {
            (Roster: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    for object:PFObject in Roster! {
                        self.userRoster.userName = object["name"] as! String
                        self.userRoster.parseObjectId = object.objectId! as String
                        self.userRoster.scenarioRecords = object["scenarioRecords"] as! [String : [String]]
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func getHerosFromParse() {
        let rosterName = activeUser!.username!
        let query = PFQuery(className: "Hero")
        query.whereKey("owner", equalTo: rosterName)
        query.findObjectsInBackgroundWithBlock{ (Hero: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    for object in Hero! {
                        self.downloadedHero.name = object["name"] as! String
                        self.downloadedHero.number = object["number"] as! String
                        self.downloadedHero.heroClass = object["heroClass"] as! String
                        self.downloadedHero.race = object["race"] as! String
                        self.downloadedHero.gender = object["gender"] as! String
                        self.downloadedHero.level = object["level"] as! String
                        self.downloadedHero.faction = object["faction"] as! String
                        self.downloadedHero.prestigePoints = object["prestigePoints"] as! String
                        self.downloadedHero.logIds = object["logIds"] as! [String]

                        self.parseHeroName.append(self.downloadedHero.name)
                        self.parseHeroNumber.append(self.downloadedHero.number)
                        self.parseHeroClass.append(self.downloadedHero.heroClass)
                        self.parseHeroRace.append(self.downloadedHero.race)
                        self.parseHeroGender.append(self.downloadedHero.gender)
                        self.parseHeroLevel.append(self.downloadedHero.level)
                        self.parseHeroFaction.append(self.downloadedHero.faction)
                        self.parseHeroPrestigePoints.append(self.downloadedHero.prestigePoints)
                        self.parseHeroObjectId.append(object.objectId! as String)
                        self.parseHeroLogIds.append(self.downloadedHero.logIds)
                    }
                    self.populateUserRoster()
                    self.heroRosterTable.reloadData()
                }
            }
        }
    }
    
    func populateUserRoster() {
        for (index,_) in parseHeroName.enumerate() {
            userRoster.addHeroToRoster(Hero(name: parseHeroName[index], number: parseHeroNumber[index], heroClass: parseHeroClass[index], race: parseHeroRace[index], gender: parseHeroGender[index], level: parseHeroLevel[index], faction: parseHeroFaction[index], prestigePoints: parseHeroPrestigePoints[index], log: [], parseObjectId: parseHeroObjectId[index], logIds: parseHeroLogIds[index]))
        }
    }
    
    func getGmSessionLogsFromParse() {
        let rosterName = activeUser!.username!
        let query = PFQuery(className: "GmLog")
        query.whereKey("owner", equalTo: rosterName)
        query.findObjectsInBackgroundWithBlock{ (GmLog: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    for object in GmLog! {
                        self.downloadedGmSessionLog.name = object["sessionName"] as! String
                        self.downloadedGmSessionLog.date = object["date"] as! NSDate
                        self.downloadedGmSessionLog.notes = object["notes"] as! String
                        self.downloadedGmSessionLog.creditForHero = object["creditForHero"] as! String
                        
                        self.parseGmSessionLogName.append(self.downloadedGmSessionLog.name)
                        self.parseGmSessionLogDate.append(self.downloadedGmSessionLog.date)
                        self.parseGmSessionLogNotes.append(self.downloadedGmSessionLog.notes)
                        self.parseGmSessionLogObjectId.append(object.objectId! as String)
                        self.parseGmSessionLogCreditForHero.append(self.downloadedGmSessionLog.creditForHero)
                    }
                    self.populateGmSessionLogs()
                }
            } else {
               print("Error: \(error!) \(error!.userInfo)") 
            }
        }
    }
    
    func populateGmSessionLogs() {
        for (index,_) in parseGmSessionLogName.enumerate() {
            userRoster.addGmSessionLog(GmSessionLog(name: parseGmSessionLogName[index], date: parseGmSessionLogDate[index], notes: parseGmSessionLogNotes[index], parseObjectId: parseGmSessionLogObjectId[index], creditForHero: parseGmSessionLogCreditForHero[index]))
        }
    }
        
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        PFUser.logOut()
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {self.navigationController?.navigationBar.alpha = 0.0}, completion: nil)
        navigationController?.popToRootViewControllerAnimated(true)
    }
}
