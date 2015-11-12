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
   
    var userRoster = Roster(userName: "", heros: [], usedHeroNames: [])
    var activeUser = PFUser.currentUser()
    var downloadedHero = Hero(name: "", number: "", heroClass: "", race: "", gender: "", level: "", log: [], usedLogNames: [], parseObjectId: "")
    var parseHeroName = [String]()
    var parseHeroNumber = [String]()
    var parseHeroClass = [String]()
    var parseHeroRace = [String]()
    var parseHeroGender = [String]()
    var parseHeroLevel = [String]()
    var parseHeroUsedLogNames: [String] = []
    var parseHeroObjectId = [String]()
    var newHeroObjectId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRosterFromParse()
        getHerosFromParse()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        heroRosterTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRoster.heros.count
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("heroNameCell")
        cell!.textLabel!.text = userRoster.heros[indexPath.row].name
        cell!.textLabel!.font = UIFont.boldSystemFontOfSize(17)
        cell!.detailTextLabel!.text = userRoster.heros[indexPath.row].heroClass
        cell!.detailTextLabel!.font = UIFont.boldSystemFontOfSize(11)
        cell!.imageView?.image = UIImage(named: userRoster.heros[indexPath.row].heroClass)
   
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            func deleteHero() {
                let heroToDelete = userRoster.heros[indexPath.row]
                let query = PFQuery(className:"Hero")
                query.getObjectInBackgroundWithId(userRoster.heros[indexPath.row].parseObjectId) {
                    (Hero: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    } else if let hero = Hero {
                        hero.deleteInBackground()
                        print("hero deleted from parse")
                    }
                }

                userRoster.deleteHeroFromRoster(heroToDelete)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "heroDetailSegue" {
            let destVC: HeroDetailViewController = segue.destinationViewController as! HeroDetailViewController
            let selectedIndex = heroRosterTable.indexPathForCell(sender as! UITableViewCell)
            destVC.heroDisplayed = userRoster.heros[(selectedIndex?.row)!]
            destVC.activeRoster = userRoster
        } else {
            let destVC: AddHeroViewController = segue.destinationViewController as! AddHeroViewController
            destVC.activeRoster = userRoster
        }
    }
    
    override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        if(unwindSegue.sourceViewController .isKindOfClass(AddHeroViewController)) {
            let addHero: AddHeroViewController = unwindSegue.sourceViewController as! AddHeroViewController
            newHeroObjectId = addHero.newHeroObjectId
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
                    print("Retreived \(Roster!.count) roster")
                    
                    for object:PFObject in Roster! {
                        self.userRoster.userName = object["name"] as! String
                        if object["hero"] != nil {
                            self.userRoster.heros = object["hero"] as! [Hero]
                        }
                        self.userRoster.usedHeroNames = object["usedHeroNames"] as! [String]
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
                print("Retreived \(Hero!.count) heros")
                dispatch_async(dispatch_get_main_queue()) {
                    for object in Hero! {
                        self.downloadedHero.name = object["name"] as! String
                        self.downloadedHero.number = object["number"] as! String
                        self.downloadedHero.heroClass = object["heroClass"] as! String
                        self.downloadedHero.race = object["race"] as! String
                        self.downloadedHero.gender = object["gender"] as! String
                        self.downloadedHero.level = object["level"] as! String

                        self.parseHeroName.append(self.downloadedHero.name)
                        self.parseHeroNumber.append(self.downloadedHero.number)
                        self.parseHeroClass.append(self.downloadedHero.heroClass)
                        self.parseHeroRace.append(self.downloadedHero.race)
                        self.parseHeroGender.append(self.downloadedHero.gender)
                        self.parseHeroLevel.append(self.downloadedHero.level)
                        self.parseHeroObjectId.append(object.objectId! as String)

                        self.populateUserRoster()
                        self.heroRosterTable.reloadData()
                    }
                }
            }
        }
    }
    
    func populateUserRoster() {
        for (index,_) in parseHeroName.enumerate() {
            userRoster.addHeroToRoster(Hero(name: parseHeroName[index], number: parseHeroNumber[index], heroClass: parseHeroClass[index], race: parseHeroRace[index], gender: parseHeroGender[index], level: parseHeroLevel[index], log: [], usedLogNames: [], parseObjectId: parseHeroObjectId[index]))
            }
         print(userRoster.usedHeroNames)
    }
        
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        PFUser.logOut()
        navigationController?.popToRootViewControllerAnimated(true)
    }
}
