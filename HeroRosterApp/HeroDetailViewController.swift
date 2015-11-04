//
//  HeroDetailViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/3/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit

class HeroDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var heroNameLabel: UILabel!
    @IBOutlet weak var heroNumberLabel: UILabel!
    var usedHeroNames = [String]()
    var classDisplayed = String()
    var raceDisplayed = String()
    var genderDisplayed = String()
    var levelDisplayed = String()
    let detailToDisplay = ["Class", "Race", "Gender", "Level"]
    var heroDisplayed = Hero?()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarVC = self.tabBarController as? HeroTabBarController
        heroDisplayed = tabBarVC!.heroSelected
        usedHeroNames = tabBarVC!.activeRosterUsedHeroNames
        heroNameLabel.text = heroDisplayed?.name
        heroNumberLabel.text = heroDisplayed?.number
        


        
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
        cell.textLabel!.text = detailToDisplay[indexPath.row]
        let statLabel = cell.textLabel!.text
        switch statLabel! {
        case "Class":
                cell.detailTextLabel!.text = heroDisplayed?.heroClass
                cell.detailTextLabel?.hidden = false
                classDisplayed = cell.detailTextLabel!.text!

        case "Race":
                cell.detailTextLabel!.text = heroDisplayed?.race
                cell.detailTextLabel?.hidden = false
                raceDisplayed = cell.detailTextLabel!.text!
          
        case "Gender":
                cell.detailTextLabel!.text = heroDisplayed?.gender
                cell.detailTextLabel?.hidden = false
                genderDisplayed = cell.detailTextLabel!.text!
            
        case "Level":
                cell.detailTextLabel!.text = heroDisplayed?.level
                cell.detailTextLabel?.hidden = false
                levelDisplayed = cell.detailTextLabel!.text!
            
        default:
            print("not a valid return")
        }
        return cell

    }
}
