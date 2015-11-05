//
//  HeroRosterViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/3/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit

class HeroRosterViewController: UIViewController, UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var heroRosterTable: UITableView!

    var userRoster = Roster(userName: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        print(userRoster.userName)
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
        cell?.textLabel!.text = userRoster.heros[indexPath.row].name
        cell?.detailTextLabel!.text = userRoster.heros[indexPath.row].heroClass
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            func deleteHero() {
                let heroToDelete = userRoster.heros[indexPath.row]
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
}
