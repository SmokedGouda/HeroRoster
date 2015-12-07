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
   
    var userRoster = Roster(userName: "", heros: [], usedHeroNames: [], parseObjectId: "")
    var sortedHeros = [Hero]()
    var activeUser = PFUser.currentUser()
    var downloadedHero = Hero(name: "", number: "", heroClass: "", race: "", gender: "", level: "", faction: "", prestigePoints: "", log: [], parseObjectId: "", logIds: [])
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRosterFromParse()
        getHerosFromParse()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        heroRosterTable.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRoster.heros.count
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("heroNameCell")
        sortedHeros = userRoster.heros.sort { $0.name.compare($1.name) == .OrderedAscending }
        cell!.textLabel!.text = sortedHeros[indexPath.row].name
        cell!.textLabel!.font = UIFont.boldSystemFontOfSize(17)
        cell!.detailTextLabel!.text = sortedHeros[indexPath.row].heroClass
        cell!.detailTextLabel!.font = UIFont.boldSystemFontOfSize(11)
        cell!.imageView?.image = UIImage(named: sortedHeros[indexPath.row].heroClass)
   
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            func deleteHero() {
                let heroToDelete = sortedHeros[indexPath.row]
                let query = PFQuery(className:"Hero")
                query.getObjectInBackgroundWithId(sortedHeros[indexPath.row].parseObjectId) {
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
            destVC.heroDisplayed = sortedHeros[(selectedIndex?.row)!]
            destVC.activateEditMode = true
        } else {
            let destVC: ScenarioSearchViewController = segue.destinationViewController as! ScenarioSearchViewController
            destVC.activeRoster = userRoster
        }
    }

    func getRosterFromParse() {
        let rosterName = "\(activeUser!.username!)'s hero roster"
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
        let rosterName = "\(activeUser!.username!)'s hero roster"
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
        
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        PFUser.logOut()
        navigationController?.popToRootViewControllerAnimated(true)
    }
}
