//
//  HeroDetailViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/3/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit

class HeroDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate {
    
    @IBOutlet weak var heroDetailTable: UITableView!
    @IBOutlet weak var heroNameTextField: UITextField!
    @IBOutlet weak var heroNumberTextField: UITextField!
    @IBOutlet weak var editHeroButton: UIButton!
    
    var usedHeroNames = [String]()
    var classDisplayed = String()
    var raceDisplayed = String()
    var genderDisplayed = String()
    var levelDisplayed = String()
    let detailToDisplay = ["Class", "Race", "Gender", "Level"]
    var heroDisplayed = Hero?()
    var tableEditState = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heroNameTextField.enabled = false
        heroNumberTextField.enabled = false
        
        let tabBarVC = self.tabBarController as? HeroTabBarController
        heroDisplayed = tabBarVC!.heroSelected
        usedHeroNames = tabBarVC!.activeRosterUsedHeroNames
        heroNameTextField.text = heroDisplayed?.name
        heroNumberTextField.text = heroDisplayed?.number
      
        
        


        
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
        if tableEditState == true {
            heroDetailTable.allowsSelection = true
            cell.accessoryType = .DisclosureIndicator
        } else {
            heroDetailTable.allowsSelection = false
            cell.accessoryType = .None
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
  
    @IBAction func editHeroButtonPressed(sender: UIButton) {
        let buttonLabel = editHeroButton.titleLabel!.text!
        switch buttonLabel {
            case "Edit Hero":
                editHeroButton.setTitle("Save", forState: UIControlState.Normal)
                tableEditState = true
                heroNameTextField.enabled = true
                heroNumberTextField.enabled = true
                heroDetailTable.reloadData()
            
            default:
                editHeroButton.setTitle("Edit Hero", forState: UIControlState.Normal)
                tableEditState = false
                heroNameTextField.enabled = false
                heroNumberTextField.enabled = false
                heroDetailTable.reloadData()
         }
    }
}
