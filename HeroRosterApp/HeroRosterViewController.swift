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
    override func viewDidLoad() {
        super.viewDidLoad()
        let rosterName = "\(activeUser!.username!)'s hero roster"
        print(activeUser!.username!)
        let query = PFQuery(className: "Roster")
        query.whereKey("name", equalTo: rosterName)
        query.findObjectsInBackgroundWithBlock {
            (Roster: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Retreived \(Roster!.count) objects")
                
                for object:PFObject in Roster! {
                        print("the object retrieved is \(object)")
                    self.userRoster.userName = object["name"] as! String
                    if object["hero"] != nil {
                    self.userRoster.heros = object["hero"] as! [Hero]
                    }
                    self.userRoster.usedHeroNames = object["usedHeroNames"] as! [String]
                    }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print(userRoster.userName, userRoster.heros, userRoster.usedHeroNames)
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
        cell?.textLabel!.text = userRoster.heros[indexPath.row].name
        cell?.detailTextLabel!.text = userRoster.heros[indexPath.row].heroClass
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            func deleteHero() {
                let heroToDelete = userRoster.heros[indexPath.row]
                userRoster.deleteHeroFromRoster(heroToDelete)
                print(userRoster.userName, userRoster.heros, userRoster.usedHeroNames)
                
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
    
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        PFUser.logOut()
        var currentUser = PFUser.currentUser()
        navigationController?.popToRootViewControllerAnimated(true)
    }
}
