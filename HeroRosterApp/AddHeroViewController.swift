//
//  AddHeroViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/3/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit

class AddHeroViewController: UIViewController, UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var heroStatsTable: UITableView!
    
    
    var statToDisplay = Int()
    var classSelected = String()
    var raceSelected = String()
    var genderSelected = String()
    var levelSelected = String()
    let detailsToEdit = ["Class", "Race", "Gender", "Level"]
    var cellLabel = String()


    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        heroStatsTable.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("heroCell") as UITableViewCell!
        if cell.detailTextLabel!.text == "Detail" {
            cell.detailTextLabel?.hidden = true
        }
        cell.textLabel!.text = detailsToEdit[indexPath.row]
        let statLabel = cell.textLabel!.text
        switch statLabel! {
        case "Class":
            if cellLabel == statLabel {
                cell.detailTextLabel!.text = HeroStats().heroClass[statToDisplay]
                cell.detailTextLabel?.hidden = false
                classSelected = cell.detailTextLabel!.text!
            }
        case "Race":
            if cellLabel == statLabel {
                cell.detailTextLabel!.text = HeroStats().race[statToDisplay]
                cell.detailTextLabel?.hidden = false
                raceSelected = cell.detailTextLabel!.text!
            }
        case "Gender":
            if cellLabel == statLabel {
                cell.detailTextLabel!.text = HeroStats().gender[statToDisplay]
                cell.detailTextLabel?.hidden = false
                genderSelected = cell.detailTextLabel!.text!
            }
        case "Level":
            if cellLabel == statLabel {
                cell.detailTextLabel!.text = HeroStats().level[statToDisplay]
                cell.detailTextLabel?.hidden = false
                levelSelected = cell.detailTextLabel!.text!
            }
        default:
            print("not a valid return")
        }
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // This segue will display the appropriate tableview based on which cell was touched.
        // This segue will also send the string value of the touched cell over to the next view so that the user can see which one is still active by displaying a checkmark.
        
        let destVC: HeroStatOptionsViewController = segue.destinationViewController as! HeroStatOptionsViewController
        
        let selectedIndex = heroStatsTable.indexPathForCell(sender as! UITableViewCell)
        cellLabel = detailsToEdit[(selectedIndex?.row)!]
        destVC.navBarTitle = cellLabel
        switch cellLabel {
        case "Class":
            destVC.heroStatsArrayToDisplay = HeroStats().heroClass
            destVC.statFromPreviousView = classSelected
            
        case "Race":
            destVC.heroStatsArrayToDisplay = HeroStats().race
            destVC.statFromPreviousView = raceSelected
            
        case "Gender":
            destVC.heroStatsArrayToDisplay = HeroStats().gender
            destVC.statFromPreviousView = genderSelected
            
        case "Level":
            destVC.heroStatsArrayToDisplay = HeroStats().level
            destVC.statFromPreviousView = levelSelected
            
        default:
            print("no action")
        }
    }
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        if(unwindSegue.sourceViewController .isKindOfClass(HeroStatOptionsViewController)) {
            let heroStat: HeroStatOptionsViewController = unwindSegue.sourceViewController as! HeroStatOptionsViewController
            
            statToDisplay = heroStat.chosenStat
        }
    }


}
