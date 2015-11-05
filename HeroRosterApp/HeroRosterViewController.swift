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
        print(userRoster.usedHeroNames)
        
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
            let heroToDelete = userRoster.heros[indexPath.row]
            userRoster.deleteHeroFromRoster(heroToDelete)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "heroDetailSegue" {
            let destVC: HeroTabBarController = segue.destinationViewController as! HeroTabBarController
            let selectedIndex = heroRosterTable.indexPathForCell(sender as! UITableViewCell)
            destVC.heroSelected = userRoster.heros[(selectedIndex?.row)!]
            destVC.activeRoster = userRoster
        } else {
            let destVC: AddHeroViewController = segue.destinationViewController as! AddHeroViewController
            destVC.activeRoster = userRoster
        }
    }
}
